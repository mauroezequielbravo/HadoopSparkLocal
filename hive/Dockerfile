FROM ubuntu:22.04

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalación de dependencias básicas
RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    wget \
    curl \
    bash \
    procps \
    netcat \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Configuración de variables de entorno para Java 8
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

# Instalación de cliente Hadoop (versión ligera - solo binarios necesarios)
ENV HADOOP_VERSION=3.3.6
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop-conf
ENV PATH=$PATH:$HADOOP_HOME/bin

# Descargar e instalar solo Hadoop (Hive lo requiere)
# Nota: Esto es necesario porque Hive requiere hadoop en el PATH
RUN wget -q https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && tar -xzf hadoop-${HADOOP_VERSION}.tar.gz \
    && mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME} \
    && rm hadoop-${HADOOP_VERSION}.tar.gz \
    && mkdir -p ${HADOOP_CONF_DIR}

# Instalación de Apache Hive
ENV HIVE_VERSION=3.1.3
ENV HIVE_HOME=/opt/hive
ENV PATH=$PATH:$HIVE_HOME/bin
ENV HIVE_CONF_DIR=$HIVE_HOME/conf

RUN wget -q https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && tar -xzf apache-hive-${HIVE_VERSION}-bin.tar.gz \
    && mv apache-hive-${HIVE_VERSION}-bin ${HIVE_HOME} \
    && rm apache-hive-${HIVE_VERSION}-bin.tar.gz

# Descargar el conector JDBC de PostgreSQL
RUN wget -q https://jdbc.postgresql.org/download/postgresql-42.7.1.jar -P ${HIVE_HOME}/lib/

# Solucionar conflicto de versiones de Guava entre Hive y Hadoop
RUN rm -f ${HIVE_HOME}/lib/guava-19.0.jar \
    && cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/

# Crear directorios necesarios
RUN mkdir -p ${HIVE_HOME}/logs \
    && mkdir -p /tmp/hive \
    && chmod -R 777 /tmp/hive

# Configurar variables de entorno adicionales
ENV HIVE_AUX_JARS_PATH=${HIVE_HOME}/lib

# Exponer puertos de Hive
# 9083: Metastore Thrift service
# 10000: HiveServer2 (JDBC/Beeline)
# 10002: HiveServer2 Web UI
EXPOSE 9083 10000 10002

# Copiar script de inicio
COPY start-hive.sh /opt/start-hive.sh
RUN chmod +x /opt/start-hive.sh

# Directorio de trabajo
WORKDIR ${HIVE_HOME}

# Comando por defecto
CMD ["/opt/start-hive.sh"]
