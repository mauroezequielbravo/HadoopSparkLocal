#!/bin/bash

echo "========================================="
echo "Iniciando Contenedor Hadoop"
echo "========================================="

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

echo "Configurando SSH..."

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
echo "Iniciando SSH..."
/usr/sbin/sshd

# Esperar a que SSH esté disponible
sleep 3

# Formatear el namenode si no existe
if [ ! -d "/opt/hadoop/data/namenode/current" ]; then
  echo "Formateando HDFS NameNode..."
  $HADOOP_HOME/bin/hdfs namenode -format -force
fi

# Iniciar servicios de HDFS
echo "Iniciando HDFS (NameNode y DataNode)..."
$HADOOP_HOME/sbin/start-dfs.sh

# Esperar a que HDFS esté listo
echo "Esperando a que HDFS esté listo..."
sleep 10

# Crear directorios de usuario en HDFS
echo "Creando directorios en HDFS..."
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/root
$HADOOP_HOME/bin/hdfs dfs -chmod -R 755 /user/root
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp
$HADOOP_HOME/bin/hdfs dfs -chmod -R 777 /tmp

# Iniciar servicios de YARN
echo "Iniciando YARN (ResourceManager y NodeManager)..."
$HADOOP_HOME/sbin/start-yarn.sh

# Esperar a que YARN se inicialice
sleep 5

# Verificar que los servicios estén funcionando
echo "========================================="
echo "Servicios Hadoop en ejecución:"
echo "========================================="
jps

echo ""
echo "========================================="
echo "URLs de acceso:"
echo "========================================="
echo "HDFS NameNode UI: http://hadoop-master:9870"
echo "YARN ResourceManager UI: http://hadoop-master:8088"
echo "========================================="

# Mantener el contenedor ejecutándose
echo "Contenedor Hadoop listo. Manteniendo activo..."
tail -f /opt/hadoop/logs/*.log 2>/dev/null || tail -f /dev/null
