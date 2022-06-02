#!/bin/bash -e

# Parse command line arguments.
prune=false
push=false
for key in "$@"; do
    case $key in
        --prune)
        prune=true
        ;;
        --push)
        push=true
        ;;
    esac
done

# Read the project version.
PROJECT_VERSION="$(cat ./tensorflow_cc/PROJECT_VERSION)"

for tag in ubuntu ubuntu-cuda; do
    docker build --pull -t lbraga/tensorflow_cc:${tag} -f Dockerfiles/${tag} .
    docker tag lbraga/tensorflow_cc:${tag} lbraga/tensorflow_cc:${tag}-"${PROJECT_VERSION}"
    if $push; then
        docker push lbraga/tensorflow_cc:${tag}
        docker push lbraga/tensorflow_cc:${tag}-"${PROJECT_VERSION}"
    fi
    if $prune; then
        docker rmi lbraga/tensorflow_cc:${tag}
        docker rmi lbraga/tensorflow_cc:${tag}-"${PROJECT_VERSION}"
        docker system prune -af
    fi
done
