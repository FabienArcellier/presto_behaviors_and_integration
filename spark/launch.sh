#!/bin/bash

set -e

# Start interactive shell if desired
if [ "$1" == "/bin/bash" ]; then
    exec /bin/bash
else
    # Start Master
    if [ "$1" == "master" ]; then
        exec "${SPARK_HOME}/bin/spark-class" "org.apache.spark.deploy.master.Master"
    # Start Slave
    elif [ "$1" == "slave" ]; then
        if [ -n "$2" ]; then
            exec "${SPARK_HOME}/bin/spark-class" "org.apache.spark.deploy.worker.Worker" "${2}"
        else
            echo "Missing Spark Master URL... exiting"
            exit 1
        fi
    # else: error
    else
        echo "Unknown parameter: $1"
        exit 1
    fi
fi