get_aws_tasks() {
    cluster=${1:-sre-platform-service-production}
    aws ecs list-tasks --cluster $cluster --query '[taskArns]' --output text |
        xargs aws ecs describe-tasks --cluster $cluster --query '[tasks][*][*][startedBy]' --output text --tasks |
        grep -o '^[A-Z].*$'
}

get_aws_task_status() {
    task=$1
    type=${2:-paymentstasks}
    user=${3:-dbayer}
    host=${4:-kloverstats.c6zdrrll14uj.us-east-2.rds.amazonaws.com}
    sql="SELECT category, statuscode, FROM_UNIXTIME(createdat/1000) FROM axis.$type WHERE category = '$task' ORDER BY createdat DESC LIMIT 1"
    mysql -h $host -u $user -p -e "$sql"
}
