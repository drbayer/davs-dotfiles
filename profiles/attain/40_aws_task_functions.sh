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
        grep -o '^[A-Z].*$'
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
