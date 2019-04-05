#!/usr/bin/env bash

set -eu

download_dirpath="$(mktemp -d)"

main() {
    local dst_path=$1
    local protoc_zip_filepath="${download_dirpath}/protoc.zip"
    local download_url=""
    case "$(uname -s)" in
        Linux*)
            download_url="https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-$(uname -m).zip"
            ;;
        Darwin*)
            download_url="https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-osx-$(uname -m).zip"
            ;;
        *)
           red "unsupported distribution. please execute from osx or linux."
           exit 1
           ;;
    esac

    green "download protoc.zip"
    curl -sSL "${download_url}" -o "${protoc_zip_filepath}"

    green "unzip"
    unzip "${protoc_zip_filepath}" -d "${download_dirpath}/protoc"

    green "copy protoc binary to dst_path: ${dst_path}"
    cp "${download_dirpath}/protoc/bin/protoc" "${dst_path}"
}

cleanup() {
    rm -rf "${download_dirpath}"
}
trap 'cleanup' EXIT

SCRIPT_DIR="$(cd "$(dirname "${0}")" && echo "${PWD}")"
. ${SCRIPT_DIR}/internal/log.sh
main "$@"
