#!/usr/bin/env bash

readonly SCRIPT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd );
readonly ROOT_DIR="${SCRIPT_DIR}/.."

function main
{
  set -o errexit
  set -o pipefail
  set -o nounset
  set -o errtrace

  wget --output-document "${ROOT_DIR}/presto/archives/presto-server-0.208.tar.gz" "https://repo1.maven.org/maven2/com/facebook/presto/presto-server/0.208/presto-server-0.208.tar.gz"
  wget --output-document "${ROOT_DIR}/presto-cli" "https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/0.208/presto-cli-0.208-executable.jar"
  chmod +x "${ROOT_DIR}/presto-cli"
  wget --output-document "${ROOT_DIR}/spark/archives/spark.tar.gz" "http://apache.crihan.fr/dist/spark/spark-2.3.1/spark-2.3.1-bin-hadoop2.7.tgz"
  wget --output-document "${ROOT_DIR}/spark/archives/presto-jdbc-0.208.jar" "https://repo1.maven.org/maven2/com/facebook/presto/presto-jdbc/0.208/presto-jdbc-0.208.jar"
}

main "$@"