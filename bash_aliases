
docker-layer ()
{
  SCRIPT_DIR=$(dirname $(realpath $0))
  LAYER=$1
  BASE=$2

  if [ -z $LAYER ]
  then
    echo "ERROR: Please specify layer. Exiting." >&2
    echo "Usage: docker-layer layer base-container" >&2
    return 1
  fi

  if [ -z $BASE ]
  then
    echo "ERROR: Please specify base container. Exiting." >&2
    echo "Usage: docker-layer layer base-container" >&2
    return 2
  fi

  if ! [ -f $SCRIPT_DIR/$LAYER.Dockerfile ]
  then
    echo "ERROR: Couldn't find '$LAYER.Dockerfile'. Exiting." >&2
    echo "Usage: docker-layer layer base-container" >&2
    return 3
  fi

  # TODO: docker build(s) happen in the script run below. No source.
  if [ -f $SCRIPT_DIR/$LAYER.Dockerfile.sh ]
  then
    $SCRIPT_DIR/$LAYER.Dockerfile.sh ${@:3}
  fi

  # TODO: no build comand here. Only in the scripts.
  docker build -t ${BASE}_nvim${TAG_SUFFIX} --target nvim_ide $EXTRA_DOCKER_RUN_ARGS -f $SCRIPT_DIR/$LAYER.Dockerfile --build-arg from=$BASE $SCRIPT_DIR
}
