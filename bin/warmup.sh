#!/bin/bash 

set -e
set -o pipefail

trap '{ echo "" ; exit 1; }' INT

pushd "$DEMO_WORK_DIR" &>/dev/null || exit 

function dowloadChart(){
  gloo_ee_version=$(helm search repo glooe/gloo -ojson | jq -r '.[0]|.version')
  GLOO_EE_VERSION=${GLOO_EE_VERSION:-gloo_ee_version}
  wget -q "https://storage.googleapis.com/gloo-ee-helm/charts/gloo-ee-${gloo_ee_version}.tgz"
  tar zxf "gloo-ee-${gloo_ee_version}.tgz"
}

function loadImages(){

  images=()
  while IFS='' read -r line; do images+=("$line"); done < <(
  find gloo-ee -name "values.yaml" | while read -r file; do
    yq e '.. | select( . | has("image")) | [ (.image.registry // "quay.io/solo-io" ) + "/" + .image.repository + ":" +.image.tag ] ' -ocsv "$file"
  done | grep -v ",," | sort -u )

  for i in "${images[@]}"
  do
    printf "Pulling and loading image %s\n" "$i"
    crane export "$i" | minikube -p "${1:-minikube}" image load -
  done
}

function cleanup(){
  rm -f "gloo-ee-${gloo_ee_version}.tgz"
}

dowloadChart
loadImages "$1"
cleanup

popd &>/dev/null || exit
