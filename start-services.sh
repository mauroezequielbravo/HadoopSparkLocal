#!/bin/bash

# Configuración de Hadoop
echo "Configurando Hadoop..."

# Configurar JAVA_HOME explícitamente
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$PATH:$JAVA_HOME/bin

# Configurar variables de entorno para Hadoop
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_SECONDARYNAMENODE_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root

# Configurar bash como shell por defecto
export SHELL=/bin/bash
export BASH_ENV=/etc/profile

# Asegurar que los scripts de Hadoop usen bash
export HADOOP_SHELL=/bin/bash

# Generar claves SSH del host
ssh-keygen -A

# Configurar SSH sin contraseña para Hadoop
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
fi
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

# Configurar SSH para aceptar conexiones sin verificación estricta
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
echo "UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config

# Crear directorio para SSH si no existe
mkdir -p /run/sshd

# Iniciar el servicio SSH
/usr/sbin/sshd

# Esperar a que SSH esté disponible
sleep 5

# Formatear el namenode si no existe
if [ ! -d "/opt/hadoop/data/namenode/current" ]; then
  echo "Formateando HDFS NameNode..."
  $HADOOP_HOME/bin/hdfs namenode -format
fi

# Iniciar servicios de Hadoop
echo "Iniciando servicios de Hadoop..."
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# Crear directorio de usuario en HDFS
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root
$HADOOP_HOME/bin/hdfs dfs -chmod -R 755 /user/root

# Configurar Spark para usar Hadoop
echo "Configurando Spark..."
export SPARK_DIST_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)

# Crear directorio de logs para Spark
mkdir -p /opt/spark/logs

# Configurar Spark para usar localhost como hostname público
export SPARK_PUBLIC_DNS=localhost
export SPARK_WORKER_HOST=localhost

# Iniciar Spark Master usando 0.0.0.0 para escuchar en todas las interfaces
echo "Iniciando Spark Master..."
$SPARK_HOME/sbin/start-master.sh --host 0.0.0.0

# Iniciar Spark Worker conectándose al Master
echo "Iniciando Spark Worker..."
$SPARK_HOME/sbin/start-worker.sh --host localhost spark://0.0.0.0:7077

# Crear un notebook de ejemplo para PySpark
# cat > /notebooks/spark_example.ipynb << EOF
# {
#  "cells": [
#   {
#    "cell_type": "code",
#    "execution_count": null,
#    "metadata": {},
#    "source": [
#     "import findspark\n",
#     "findspark.init()\n",
#     "\n",
#     "from pyspark.sql import SparkSession\n",
#     "\n",
#     "# Crear una sesión de Spark\n",
#     "spark = SparkSession.builder\\\n",
#     "    .appName(\"Ejemplo PySpark\")\\\n",
#     "    .master(\"local[*]\")\\\n",
#     "    .getOrCreate()\n",
#     "\n",
#     "# Mostrar información de la sesión\n",
#     "print(f\"Versión de Spark: {spark.version}\")\n",
#     "\n",
#     "# Crear un DataFrame de ejemplo\n",
#     "data = [(\"Juan\", 30), (\"Ana\", 25), (\"Carlos\", 35)]\n",
#     "df = spark.createDataFrame(data, [\"Nombre\", \"Edad\"])\n",
#     "\n",
#     "# Mostrar el DataFrame\n",
#     "df.show()\n",
#     "\n",
#     "# Realizar algunas operaciones\n",
#     "df.select(\"Nombre\").show()\n",
#     "df.filter(df.Edad > 28).show()\n",
#     "\n",
#     "# Acceder a HDFS\n",
#     "# Guardar el DataFrame en HDFS\n",
#     "df.write.mode(\"overwrite\").csv(\"/user/root/personas\")\n",
#     "\n",
#     "# Leer el DataFrame desde HDFS\n",
#     "df_leido = spark.read.csv(\"/user/root/personas\")\n",
#     "df_leido.show()\n"
#    ]
#   }
#  ],
#  "metadata": {
#   "kernelspec": {
#    "display_name": "Python 3",
#    "language": "python",
#    "name": "python3"
#   },
#   "language_info": {
#    "codemirror_mode": {
#     "name": "ipython",
#     "version": 3
#    },
#    "file_extension": ".py",
#    "mimetype": "text/x-python",
#    "name": "python",
#    "nbconvert_exporter": "python",
#    "pygments_lexer": "ipython3",
#    "version": "3.8.10"
#   }
#  },
#  "nbformat": 4,
#  "nbformat_minor": 4
# }
# EOF

# Esperar a que los servicios se inicien completamente
echo "Esperando a que los servicios se inicien..."
sleep 10

# Verificar que los servicios estén funcionando
echo "Verificando servicios..."
jps

# Iniciar Jupyter Notebook
echo "Iniciando Jupyter Notebook..."
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' &

# Mantener el contenedor ejecutándose
echo "Todos los servicios iniciados. Manteniendo el contenedor activo..."
tail -f /dev/null