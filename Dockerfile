FROM alpine:3.18

# Instalación de dependencias básicas
RUN apk add --no-cache \
    openjdk11 \
    python3 \
    py3-pip \
    wget \
    curl \
    bash \
    procps \
    openssh \
    rsync \
    sudo \
    gcc \
    python3-dev \
    musl-dev \
    linux-headers \
    && ln -sf python3 /usr/bin/python \
    && ln -sf /bin/bash /bin/sh

# Configuración de variables de entorno para Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin

# Variables de entorno para usuarios de Hadoop
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

# Configurar bash como shell por defecto para Hadoop
ENV SHELL=/bin/bash
ENV BASH_ENV=/etc/profile

# Crear un wrapper para forzar bash en scripts de Hadoop
RUN echo '#!/bin/bash' > /usr/local/bin/hadoop-bash-wrapper && \
    echo 'exec bash "$@"' >> /usr/local/bin/hadoop-bash-wrapper && \
    chmod +x /usr/local/bin/hadoop-bash-wrapper

# Instalación de Hadoop
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz \
    && rm /bin/sh && ln -s /bin/bash /bin/sh

# Configuración de Hadoop
RUN mkdir -p /opt/hadoop/logs \
    && mkdir -p /hadoop/dfs/name \
    && mkdir -p /hadoop/dfs/data

# Instalación de Spark
ENV SPARK_VERSION=3.5.0
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin
ENV PYTHONHASHSEED=1

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop3 ${SPARK_HOME} \
    && rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Instalación de Jupyter y dependencias de PySpark
RUN pip3 install --no-cache-dir \
    jupyter \
    notebook \
    pyspark==${SPARK_VERSION} \
    findspark \
    pandas \
    numpy \
    matplotlib

# Configuración de puertos
EXPOSE 8888 8080 9870 8088 4040

# Directorio de trabajo
WORKDIR /notebooks
RUN mkdir -p /notebooks

# Comando para iniciar servicios
COPY start-services.sh /start-services.sh
RUN chmod +x /start-services.sh

CMD ["/start-services.sh"]