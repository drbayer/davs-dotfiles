get_aws_tasks() {
    get_aws_tasks_usage() {
        cat <<EOF
List the names of currently running ECS tasks (those started by a named caller)
in the given cluster.

Usage: get_aws_tasks [-c cluster]
  -c cluster  ECS cluster name (default: sre-platform-service-production)
EOF
    }
    trap 'unset -f get_aws_tasks_usage; trap - RETURN' RETURN

    local cluster="sre-platform-service-production"
    local OPTIND opt
    while getopts ":c:" opt; do
        case $opt in
            c) cluster="$OPTARG" ;;
            *) get_aws_tasks_usage; return 1 ;;
        esac
    done

    aws ecs list-tasks --cluster "$cluster" --query '[taskArns]' --output text |
        xargs aws ecs describe-tasks --cluster "$cluster" --query '[tasks][*][*][startedBy]' --output text --tasks |
        grep -o '^[A-Z].*$' |
        sort
}

get_aws_task_status() {
    get_aws_task_status_usage() {
        cat <<EOF
Look up the most recent run of <task> in the axis.<type> tracking table and
print its category, status code, and creation time.

Usage: get_aws_task_status [-t type] [-u user] [-h host] [-p password] <task>
  -t type      table type (default: paymentstasks)
  -u user      mysql user (default: dbayer)
  -h host      mysql host (default: kloverstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com)
  -p password  mysql password (default: prompt)
EOF
    }
    trap 'unset -f get_aws_task_status_usage; trap - RETURN' RETURN

    local type="paymentstasks"
    local user="dbayer"
    local host="kloverstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com"
    local password=""
    local password_set=0
    local OPTIND opt
    while getopts ":t:u:h:p:" opt; do
        case $opt in
            t) type="$OPTARG" ;;
            u) user="$OPTARG" ;;
            h) host="$OPTARG" ;;
            p) password="$OPTARG"; password_set=1 ;;
            *) get_aws_task_status_usage; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    local task="$1"
    if [ -z "$task" ]; then
        get_aws_task_status_usage
        return 1
    fi

    local sql="SELECT category, statuscode, FROM_UNIXTIME(createdat/1000) FROM axis.$type WHERE category = '$task' ORDER BY createdat DESC LIMIT 1"
    if [ "$password_set" -eq 1 ]; then
        mysql -h "$host" -u "$user" -p"$password" -e "$sql"
    else
        mysql -h "$host" -u "$user" -p -e "$sql"
    fi
}

trigger_aws_task() {
    trigger_aws_task_usage() {
        cat <<EOF
Trigger the named scheduled task by publishing {"CATEGORY": "<task>"} to the
sre-platform-schedule-tasks SNS topic.

Usage: trigger_aws_task [-a topic_arn] <task>
  -a topic_arn  SNS topic ARN (default: arn:aws:sns:us-east-2:113934766313:sre-platform-schedule-tasks-production)
EOF
    }
    trap 'unset -f trigger_aws_task_usage; trap - RETURN' RETURN

    local topic_arn="arn:aws:sns:us-east-2:113934766313:sre-platform-schedule-tasks-production"
    local OPTIND opt
    while getopts ":a:" opt; do
        case $opt in
            a) topic_arn="$OPTARG" ;;
            *) trigger_aws_task_usage; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    local task="$1"
    if [ -z "$task" ]; then
        trigger_aws_task_usage
        return 1
    fi

    aws sns publish --topic-arn "$topic_arn" --message "{\"CATEGORY\": \"$task\"}"
}

aws_task_remediation() {
    aws_task_remediation_usage() {
        cat <<EOF
Check whether <task> is currently running and look up its latest tracking-table
status. If the task is not running and the last status code is 1 or 2, prompt
to trigger it via the schedule-tasks SNS topic.

Usage: aws_task_remediation [-c cluster] [-t type] [-u user] [-h host] [-p password] [-a topic_arn] [-y] <task>
  -c cluster    ECS cluster name (default: sre-platform-service-production)
  -t type       table type (default: paymentstasks)
  -u user       mysql user (default: dbayer)
  -h host       mysql host (default: kloverstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com)
  -p password   mysql password (default: prompt)
  -a topic_arn  SNS topic ARN (default: arn:aws:sns:us-east-2:113934766313:sre-platform-schedule-tasks-production)
  -y            bypass confirmation prompt before triggering
EOF
    }
    trap 'unset -f aws_task_remediation_usage; trap - RETURN' RETURN

    local cluster="sre-platform-service-production"
    local type="paymentstasks"
    local user="dbayer"
    local host="kloverstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com"
    local password=""
    local password_set=0
    local topic_arn="arn:aws:sns:us-east-2:113934766313:sre-platform-schedule-tasks-production"
    local bypass=0
    local OPTIND opt
    while getopts ":c:t:u:h:p:a:y" opt; do
        case $opt in
            c) cluster="$OPTARG" ;;
            t) type="$OPTARG" ;;
            u) user="$OPTARG" ;;
            h) host="$OPTARG" ;;
            p) password="$OPTARG"; password_set=1 ;;
            a) topic_arn="$OPTARG" ;;
            y) bypass=1 ;;
            *) aws_task_remediation_usage; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    local task="$1"
    if [ -z "$task" ]; then
        aws_task_remediation_usage
        return 1
    fi

    echo "Checking running tasks in cluster '$cluster'..."
    local running_tasks
    if ! running_tasks=$(get_aws_tasks -c "$cluster"); then
        echo "Failed to list running tasks." >&2
        return 1
    fi
    echo "Running tasks:"
    if [ -z "$running_tasks" ]; then
        echo "  (none)"
    else
        echo "$running_tasks" | sed 's/^/  /'
    fi
    local is_running=0
    if echo "$running_tasks" | grep -qx "$task"; then
        is_running=1
        echo "Task '$task' is currently RUNNING."
    else
        echo "Task '$task' is NOT running."
    fi

    echo
    echo "Checking latest status for '$task'..."
    local status_output status_rc
    if [ "$password_set" -eq 1 ]; then
        status_output=$(get_aws_task_status -t "$type" -u "$user" -h "$host" -p "$password" "$task")
    else
        status_output=$(get_aws_task_status -t "$type" -u "$user" -h "$host" "$task")
    fi
    status_rc=$?
    echo "$status_output"
    if [ "$status_rc" -ne 0 ]; then
        echo "Failed to look up task status." >&2
        return 1
    fi

    local status_code
    status_code=$(echo "$status_output" | awk -v task="$task" '$1 == task { print $2 }' | head -n1)

    if [ -z "$status_code" ]; then
        echo "Could not determine status code for '$task'." >&2
        return 1
    fi

    if [ "$is_running" -eq 1 ]; then
        echo "Task is already running; nothing to trigger."
        return 0
    fi

    if [ "$status_code" != "1" ] && [ "$status_code" != "2" ]; then
        echo "Status code is $status_code (not 1 or 2); nothing to trigger."
        return 0
    fi

    echo "Task '$task' is not running and status code is $status_code."
    if [ "$bypass" -ne 1 ]; then
        local reply
        read -r -p "Trigger '$task'? [y/N] " reply
        case "$reply" in
            y|Y|yes|YES) ;;
            *) echo "Aborted."; return 0 ;;
        esac
    fi

    if ! trigger_aws_task -a "$topic_arn" "$task"; then
        echo "Failed to trigger '$task'." >&2
        return 1
    fi
}
