FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalación de dependencias básicas
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    python3 \
    python3-pip \
    wget \
    curl \
    bash \
    procps \
    netcat \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf python3 /usr/bin/python

# Configuración de variables de entorno para Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Instalación de Spark
ENV SPARK_VERSION=3.5.0
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
ENV PYTHONHASHSEED=1

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} \
    && rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Instalación de cliente Hadoop (para conectarse al cluster Hadoop)
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# Instalación de Jupyter y dependencias de PySpark
RUN pip3 install --no-cache-dir \
    jupyter \
    notebook \
    pyspark==${SPARK_VERSION} \
    findspark \
    pandas \
    numpy \
    matplotlib

# Crear directorio de logs para Spark
RUN mkdir -p /opt/spark/logs

# Configuración de puertos
# 8888: Jupyter Notebook
# 8080: Spark Master UI
# 8081: Spark Worker UI
# 4040: Spark Application UI
# 7077: Spark Master (interno)
EXPOSE 8888 8080 8081 4040 7077

# Directorio de trabajo para notebooks
WORKDIR /notebooks
RUN mkdir -p /notebooks

# Comando para iniciar servicios
COPY start-spark.sh /start-spark.sh
RUN chmod +x /start-spark.sh

CMD ["/start-spark.sh"]
