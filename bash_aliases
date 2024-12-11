
docker-layer-print-usage ()
{
  echo "Usage: docker-layer layer base-container [...]" >&2
  echo "env vars:" >&2
  echo "  SUFFIX - suffix to override tag with." >&2
}

_DOCKER_DEV_LAYER_BASH_ALIASES_SCRIPT_DIR=$(dirname $(realpath $BASH_SOURCE))

docker-layer ()
{
  echo $_DOCKER_DEV_LAYER_BASH_ALIASES_SCRIPT_DIR
  LAYER=$1
  BASE=$2

  if [ -z $LAYER ]
  then
    echo "ERROR: Please specify layer. Exiting." >&2
    docker-layer-print-usage   
    return 1
  fi

  if [ -z $BASE ]
  then
    echo "ERROR: Please specify base container. Exiting." >&2
    docker-layer-print-usage   
    return 2
  fi

  # TODO: docker build(s) happen in the script run below. No source.
  if ! [ -f $_DOCKER_DEV_LAYER_BASH_ALIASES_SCRIPT_DIR/$LAYER.Dockerfile.sh ]
  then
    echo "FATAL ERROR: Couldn't find '$LAYER.Dockerfile.sh'. Exiting." >&2
    return 4
  fi

  $_DOCKER_DEV_LAYER_BASH_ALIASES_SCRIPT_DIR/$LAYER.Dockerfile.sh ${@:2}
}
