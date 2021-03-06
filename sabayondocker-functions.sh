#!/bin/bash

COMMIT_MESSAGES=(
  '[commit] i went apeshit about that'
  '[emerge] fuck that. i just compiled some shit'
  '[push] i felt so bored that i decided to give everything to dogs'
  '[push] elitarism will kill us all eventually'
  '[commit] i heard someone had an hangover.. i am not sure about that.. really'
  '[emerge] you will hate me for that AHHAHAHAHAHAHA'
)

STILL_RUNNING=(
  'childrens'
  'chickens'
  'hobbits'
  'hamsters'
)

WORLD_ENDING=(
  'FUCKING GODZILLA MANNNN! SERIOUSLY!! STOPPP!'
  'SOMEONE WILL GO APESHIT RIGHT NOW!'
  'You ARE SO FUCKED, i informed the admins here...'
  'GOOD FUCKING LORD. STOP PLEASE. STOP'
)

SABAYON_HOME="${SABAYON_HOME:-/sabayon/arm/}"
SABAYON_CPUS="${SABAYON_CPUS:-5-7}"
SABAYON_MEMORY_RESERVATION="${SABAYON_MEMORY_RESERVATION:-300M}"
SABAYON_MEMORY_SWAP="${SABAYON_MEMORY_SWAP:-710M}"
SABAYON_MEMORY="${SABAYON_MEMORY:-710M}"
SABAYON_COMMAND="${SABAYON_COMMAND:-/bin/bash}"
SABAYON_DOCKER_IMAGE="${SABAYON_DOCKER_IMAGE:-sabayon/entropy-armhfp}"
SABAYON_DOCKER_EXTRA_OPTS="${SABAYON_DOCKER_EXTRA_OPTS}"

[ -e ${SABAYON_HOME}/confs/env ] && . ${SABAYON_HOME}/confs/env


docker_notice() {
  local IMAGE=$1
  local CID=$(docker ps -aq | xargs echo | cut -d ' ' -f 1)

  cowsay " Don't forget to commit your changes to the docker image, or your changes will be lost."
  docker_helper $IMAGE $CID
  if [[ $(docker inspect --format='{{.Config.Image}}' ${CID}) = ${IMAGE} ]]; then
    confirm "[*] Do you want to commit it? [y/N]" && docker commit ${CID} ${IMAGE} || confirm "[*] Do you want to remove it? [y/N]" && docker rm ${CID}
  else
    echo "[!] I'm sorry, this shouldn't happen. But it seems that someone manually created and committed a container"
    exit 1
  fi
}

docker_notice_fail() {
  local IMAGE=$1

  cowsay "Seems something went wrong? i won't help you committing this."
  docker_helper $IMAGE
}

docker_helper() {
  local RANDOM_REASON=${COMMIT_MESSAGES[$RANDOM % ${#COMMIT_MESSAGES[@]}]}
  local IMAGE=$1
  local CID=$2
  echo
  echo "Docker helper:"
  echo "****"
  echo " TO COMMIT CHANGE: docker commit -m '${RANDOM_REASON}' ${CID} ${IMAGE}"
  echo " TO SQUASH: docker_squash ${CID} ${IMAGE}"
  echo " TO DISCARD, REMOVE: docker rm ${CID}"
  echo " TO DO A MAJOR CLEANUP: docker_clean"
  echo "****"
  echo
}

docker_acquire_lock() {
  local IMAGE=${1:-/}
  if ps aux | grep "[d]ocker commit" | grep -q $IMAGE; then
    local RANDOM_REASON=${WORLD_ENDING[$RANDOM % ${#WORLD_ENDING[@]}]}
    cowsay "DON'T!! It seems that someone is committing a container. ${RANDOM_REASON}"
    ps aux | grep "[d]ocker commit" | grep $IMAGE
  	return 1
  else
    if ps aux | grep -q "[d]ocker commit"; then
      echo "[!] No one seems touching your image, but still someone is committing something"
    fi
  	return 0
  fi
}

safety_check() {
  local IMAGE=$1
  local RANDOM_REASON=${STILL_RUNNING[$RANDOM % ${#STILL_RUNNING[@]}]}

  if docker ps | grep -q ${IMAGE}; then
    cowsay "Attention!! It seems there are already ${RANDOM_REASON} running inside the containers. This is just a warning."
  	docker ps || exit 0
    echo
    echo
    echo " Consider pressing CTRL+C and attaching into it (attach to the running pseudo-tty) 'docker attach $(docker ps -q)'."
    echo
  	echo "*****"
  	echo
    echo
    docker_hook $(docker ps | grep ${IMAGE} | awk '{print $1}')
    playground_redirect
    echo "[!!!] Since it would be a pain in the ***hole for the mantainer, i won't allow you to create a container."
    exit $?
    #confirm "[!] Are you sure you want to spawn a new entropy-tracker container? [y/N]" || exit 0
  fi

  if docker ps -a | grep -q ${IMAGE}; then
    cowsay "Attention!! It seems there are unstaged containers... ${RANDOM_REASON} might have left something for us inside?. This is just a warning, nothing really serious. You can ignore me"
  	docker ps -a || exit 0
    echo "*****"
    echo
    playground_redirect
    confirm "[!] Are you sure you want to spawn a new entropy-tracker container? [y/N]" || exit 0
  fi
}

docker_hook() {
  local CID=$1
  if confirmy "[*] Do you want to spawn a new shell on ${CID}? if i'm wrong, press N! [Y/n]"; then
    hook_container $CID
    exit $?
  else
    docker ps
    echo
    echo
    read -r -p "[*] Which one then? Please, paste the correct ID, or i'll just send you to the playground. " response
    hook_container $response
  fi
}

playground_redirect() {
  if confirm "[*] Do you want to spawn a playground_container instead? This means that you will be able only to compile packages(generate tbz2) and your container will be removed on exit [y/N]"; then
    playground_container
    exit $?
  fi
}

confirm () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

confirmy () {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [Y/n]} " response
    case $response in
        [nN][oO]|[nN])
            false
            ;;
        *)
            true
            ;;
    esac
}
