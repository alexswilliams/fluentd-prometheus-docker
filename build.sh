#!/usr/bin/env bash

# If this script fails to run on the `docker buildx` line, try:
# - enabling Experimental Features within docker
# - running `docker buildx create` followed by `docker buildx use ...` to create a builder instance

set -ex

function buildAndPush {
    local fluentVersion=$1
    local promPluginVersion=$2
    local imagename="alexswilliams/fluentd-with-prometheus-plugin"
    local latest="last-build"
    if [ "$3" == "latest" ]; then latest="latest"; fi

    docker buildx build \
        --platform=linux/amd64 \
        --build-arg FLUENT_VERSION=${fluentVersion} \
        --build-arg PROM_PLUGIN_VERSION=${promPluginVersion} \
        --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --build-arg VCS_REF=$(git rev-parse --short HEAD) \
        --tag ${imagename}:${fluentVersion} \
        --tag ${imagename}:${fluentVersion}-${promPluginVersion} \
        --tag ${imagename}:${latest} \
        --push \
        --file Dockerfile .
}

buildAndPush "v1.10.4-debian-1.0" "1.8.0" "latest"

curl -X POST "https://hooks.microbadger.com/images/alexswilliams/fluentd-with-prometheus-plugin/VZtnrWrOcA9tdGmL7na57qDh2JU="
