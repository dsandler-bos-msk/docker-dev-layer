
docker-layer-print-usage ()
{
  echo "Usage: docker-layer layer base-container [...]" >&2
  echo "env vars:" >&2
  echo "  SUFFIX - suffix to override tag with." >&2
}

docker-layer ()
{
  SCRIPT_DIR=$(dirname $(realpath $0))
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

  if ! [ -f $SCRIPT_DIR/$LAYER.Dockerfile ]
  then
    echo "ERROR: Couldn't find '$LAYER.Dockerfile'. Exiting." >&2
    docker-layer-print-usage   
    return 3
  fi

  # TODO: docker build(s) happen in the script run below. No source.
  if ! [ -f $SCRIPT_DIR/$LAYER.Dockerfile.sh ]
  then
    echo "FATAL ERROR: Couldn't find '$LAYER.Dockerfile.sh'. Exiting." >&2
    return 4
  fi

  $SCRIPT_DIR/$LAYER.Dockerfile.sh ${@:2}
}
