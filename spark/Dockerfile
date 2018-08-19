#
#
# SPARK CONTAINER FOR STANDALONE CLUSTER OPERATION
#
# Java: OpenJDK-8-JRE
# Spark: v2.1.0
#
#
# Dockerfile Reference
# https://docs.docker.com/engine/reference/builder/#user
#

FROM openjdk:8-jre

# ENVIRONMENT VARIABLES
ENV SPARK_HOME /opt/spark
ENV PYSPARK_PYTHON python3

# RUN groupadd -r spark && useradd -r -g spark spark
# USER spark

COPY archives/spark.tar.gz spark.tar.gz

# INSTALL ADDITIONAL REQUIREMENTS
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p "${SPARK_HOME}" && \
    tar -xzf spark.tar.gz -C "${SPARK_HOME}" --strip-components=1

COPY archives/presto-jdbc-0.208.jar "${SPARK_HOME}/presto-jdbc-0.208.jar"

# JAVA
# JAVA_HOME is already set by the OpenJDK container!
# ENV JAVA_HOME /path/to/java

# EXPOSE PORTS:
# - 8080 for the web ui
# - 7077 is the default master port
EXPOSE 7077 8080

# COPY THE LAUNCH SCRIPT
COPY ["launch.sh", "/"]

# ENTRYPOINT
CMD ["/launch.sh", "master"]