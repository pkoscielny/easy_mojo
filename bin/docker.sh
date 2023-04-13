#!/bin/bash 

# Define local variables.
DOCKER_COMPOSE_FILE="$PWD/docker/docker-compose.yml"
DETACH_MODE="-d"
SERVICE_ID=""
DOTENV="$PWD/config/.env"


function start {
    docker-compose -f $DOCKER_COMPOSE_FILE up $DETACH_MODE $SERVICE_ID
}

function stop {
    docker-compose -f $DOCKER_COMPOSE_FILE stop $SERVICE_ID
}

function build {
    docker-compose -f $DOCKER_COMPOSE_FILE build
}

function rm {
    docker-compose -f $DOCKER_COMPOSE_FILE rm $SERVICE_ID
}

function help {
    echo "
    docker.sh

    Arguments:
        --start   [-s | --service <name>] [-i | --interactive] - start (all services | given service) in interactive or detached mode for unit tests or not.
        --stop    [-s | --service <name>]                      - stop (all services | given service).
        --restart [-s | --service <name>]                      - run stop and start.
        --rm      [-s | --service <name>]                      - remove container.
        -b | --build                                           - build all images.
        -h | --help                                            - print this help.
    "
}


# Export variables.
if [ -f "$DOTENV" ]; then
    ENV_VARS="$(cat $DOTENV | awk '!/^\s*#/' | awk '!/^\s*$/')"

    eval "$(
        printf '%s\n' "$ENV_VARS" | while IFS='' read -r line; do
            key=$(printf '%s\n' "$line" | sed 's/"/\\"/g' | cut -d '=' -f 1)
            key_exported=$(export -p | grep "$key"=)

            # Use env variable only if not exported yet.
            if [ -z "$key_exported" ]; then
                value=$(printf '%s\n' "$line" | cut -d '=' -f 2- | sed 's/"/\\\"/g')
                printf '%s\n' "export $key=\"$value\""
            fi 
        done
    )"

    #export $(grep -v '^#' "$DOTENV" | xargs -d '\n')
fi
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
export USER_NAME=$(id -u -n)
export GROUP_NAME=$(id -g -n)


# Prepare params.
ACTIONS=()
while [[ $# -gt 0  ]]; do
    key="$1"
    case $key in 
        -s|--service)
            SERVICE_ID="${2}"
            shift
            shift
            ;;
        -i|--interactive)
            DETACH_MODE=""
            shift
            ;;
        *)
            # Rest of params.
            ACTIONS+=("$key")
            shift
            ;;
    esac
done  


# Run specific action.
for i in "${!ACTIONS[@]}"; do
  param=${ACTIONS[i]}
  case $param in
    --start)
      start; exit;
      ;;
    --stop)
      stop; exit;
      ;;
    --restart)
      stop; start; exit;
      ;;
    -b|--build)
      build; exit
      ;;
    -r|--rm)
      rm; exit
      ;;
    -h|--help)
      help; exit
      ;;
  esac
done  

help
