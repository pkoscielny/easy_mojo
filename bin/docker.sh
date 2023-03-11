#!/bin/bash 

function start {
    docker-compose -f $DOCKER_COMPOSE_FILE up $DETACH_MODE $SERVICE_ID
}

function stop {
    docker-compose -f $DOCKER_COMPOSE_FILE stop $SERVICE_ID
}

function build {
    docker-compose -f $DOCKER_COMPOSE_FILE build
}

function help {
    echo "
    docker.sh

    Arguments:
        --start   [-s | --service] [-i | --interactive]   - start (all services | given service) in interactive or detached mode.
        --stop    [-s | --service]                        - stop (all services | given service).
        --restart [-s | --service]                        - run stop and start.
        -b | --build                                      - build all images.
        -h | --help                                       - print this help.
    "
}

# Define local variables.
DOCKER_COMPOSE_FILE="$PWD/docker/docker-compose.yml"
DETACH_MODE="-d"
SERVICE_ID=""


# Export variables.
if [ -f "$PWD/config/.env" ]; then
    export $(grep -v '^#' "$PWD/config/.env" | xargs)
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
    -h|--help)
      help; exit
      ;;
  esac
done  

help
