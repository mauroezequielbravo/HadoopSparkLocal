FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalación de dependencias básicas
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    curl \
    bash \
    procps \
    openssh-server \
    rsync \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Configuración de variables de entorno para Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
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

# Instalación de Hadoop
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz

# Configuración de directorios de Hadoop
RUN mkdir -p /opt/hadoop/logs \
    && mkdir -p /opt/hadoop/data/namenode \
    && mkdir -p /opt/hadoop/data/datanode

# Configuración de puertos HDFS y YARN
EXPOSE 9000 9870 9864 8088 8042

# Directorio de trabajo
WORKDIR /opt/hadoop

# Comando para iniciar servicios
COPY start-hadoop.sh /start-hadoop.sh
RUN chmod +x /start-hadoop.sh

CMD ["/start-hadoop.sh"]
