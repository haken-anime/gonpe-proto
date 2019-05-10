#!/usr/bin/env bash

set -eu

download_dirpath="$(mktemp -d)"

main() {
    local protoc_version=$1
    local bin_path=$2
    local google_proto_path=$3
    local protoc_zip_filepath="${download_dirpath}/protoc.zip"
    local download_url=""
    local dist_name="linux"

    case "$(uname -s)" in
        Linux*)
            dist_name="linux"
            ;;
        Darwin*)
            dist_name="osx"
            ;;
        *)
           red "unsupported distribution. please execute from osx or linux."
           exit 1
           ;;
    esac

    local download_url="https://github.com/protocolbuffers/protobuf/releases/download/v${protoc_version}/protoc-${protoc_version}-${dist_name}-$(uname -m).zip"

    green "download protoc.zip"
    curl -sSL "${download_url}" -o "${protoc_zip_filepath}"

    green "unzip"
    unzip "${protoc_zip_filepath}" -d "${download_dirpath}/protoc"

    green "copy protoc binary to dst_path: ${bin_path}"
    cp "${download_dirpath}/protoc/bin/protoc" "${bin_path}"

    green "copy google's proto file: ${google_proto_path}"
    cp -a "${download_dirpath}/protoc/include/google" "${google_proto_path}"
}

cleanup() {
    rm -rf "${download_dirpath}"
}
trap 'cleanup' EXIT

SCRIPT_DIR="$(cd "$(dirname "${0}")" && echo "${PWD}")"
. ${SCRIPT_DIR}/internal/log.sh
main "$@"
