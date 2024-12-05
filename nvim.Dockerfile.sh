#!/bin/bash

SCRIPT_DIR=$(dirname $(realpath $0))

print_usage()
{
  echo "Usage: $(basename $0) base-image language-targets..." >&2
  echo "env vars:" >&2
  echo "  SUFFIX - suffix to override tag with." >&2
}

if ! which jq > /dev/null 2> /dev/null
then
  echo "ERROR: Please install jq. Exiting." >&2
  exit 1
fi

BASE_IMAGE=$1
if [ -z $BASE_IMAGE ]
then
  echo "ERROR: Please specify base images. Exiting." >&2
  print_usage
fi

if [ -z $2 ]
then
  echo "ERROR: Need at least one language target. Exiting." >&2
  print_usage
fi

RUNNING_TAG=$( echo "$BASE_IMAGE" | sha1sum | grep -o ^[a-f0-9]* )

docker build -t $RUNNING_TAG --target nvim_ide_base -f $SCRIPT_DIR/nvim.Dockerfile --build-arg from=$BASE_IMAGE

COC_SETTINGS_JSON='{"languageserver":{}}'

# Loop for through arg
for LANG_TARGET in "${@:2}"
do
  RUNNING_TAG_NEXT=$( echo "$RUNNING_TAG $LANG_TARGET" | sha1sum | grep -o ^[a-f0-9]* )

  ## add matching arg to language layer and add to coc-settings.json 
  ## TODO
  COC_LANG_JSON=nvim.coc.lang.${LANG_TARGET}.json
  if ! [ -f $COC_LANG_JSON ]
  then
    echo "FATAL ERROR: Missing CoC file '$COC_LANG_JSON'. Exiting." >&2
    exit 2
  fi
  COC_SETTINGS_JSON=$(echo $COC_SETTINGS_JSON | jq --argfile lang $COC_LANG_JSON '.languageserver += $lang')

  ## build language layer with FROM=running-name. 
  docker build -t $RUNNING_TAG_NEXT --target nvim_ide_$LANG_TARGET -f $SCRIPT_DIR/nvim.Dockerfile --build-arg from=$RUNNING_TAG

  RUNNING_TAG=$RUNNING_TAG_NEXT
done

# docker build final layer.
if [ -z $SUFFIX ]
then
  SUFFIX=_nvim
fi

echo $COC_SETTINGS_JSON | jq . > coc-settings.json

docker build -t ${BASE_IMAGE}${SUFFIX} --target nvim_ide_final -f $SCRIPT_DIR/nvim.Dockerfile --build-arg from=$RUNNING_TAG

rm coc-settings.json
