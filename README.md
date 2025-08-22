# Entorno Hadoop, Spark y Jupyter Notebook

Este proyecto proporciona un entorno Docker con Hadoop, Spark y Jupyter Notebook integrados.

## Persistencia de datos

Los datos de Hadoop se almacenan de forma persistente en el directorio local `./hadoop-data/`, que se monta como volumen en el contenedor. Esto significa que:
- Los datos del HDFS se mantienen entre reinicios del contenedor
- No es necesario reformatear el NameNode cada vez
- Los archivos almacenados en HDFS persisten localmente

## Servicios y puertos

- Jupyter Notebook: http://localhost:8888
- Spark UI: http://localhost:4040
- Spark Master UI: http://localhost:8080
- HDFS NameNode UI: http://localhost:9870
- YARN ResourceManager UI: http://localhost:8088

## Instrucciones de uso

### Inicio desde cero (limpieza completa)

Si quieres empezar completamente desde cero:

```bash
# Detener y eliminar contenedores
docker-compose down -v; docker rmi hadoopsparklocal-hadoop-spark-jupyter; docker volume prune -f; Remove-Item -Recurse -Force ./hadoop-data

# Construir e iniciar contenedores
docker-compose up -d

# Hasta aca solo esta levantado jupyter notebook

# Formatear HDFS NameNode (solo la primera vez o después de limpieza)
# Si el comando da error por JAVA_HOME
# docker exec -it hadoop-spark-jupyter bash -c "ls /usr/lib/jvm/ || find /usr -name 'java*'"
##### docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs namenode -format -force"

# Iniciar Hadoop NameNode
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs --daemon start namenode"

# Iniciar Hadoop DataNode
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs --daemon start datanode"

# YARN
docker exec -it hadoop-spark-jupyter bash -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /etc/profile"
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/sbin/start-yarn.sh"

# Crear directorio de logs de Spark
docker exec hadoop-spark-jupyter bash -c "mkdir -p /opt/spark/logs"

# Iniciar Spark Master
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && export SPARK_CONF_DIR=/opt/spark/conf && nohup java -cp '/opt/spark/jars/*' -Xmx1g org.apache.spark.deploy.master.Master --host localhost --port 7077 --webui-port 8080 > /opt/spark/logs/spark-master.log 2>&1 &"

# Iniciar Spark Worker
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && export SPARK_CONF_DIR=/opt/spark/conf && nohup java -cp '/opt/spark/jars/*' -Xmx1g org.apache.spark.deploy.worker.Worker spark://localhost:7077 --host localhost --webui-port 8081 > /opt/spark/logs/spark-worker.log 2>&1 &"

```

### Script automatizado (recomendado)

Para mayor comodidad, puedes usar el script que automatiza toda la secuencia:

```bash
# En Windows (PowerShell) - Opción más fácil
.\start-all-services.bat

# En Windows (PowerShell) - Con bash
bash .\start-all-services.sh
# O alternativamente:
wsl bash start-all-services.sh

# En Linux/Mac
bash start-all-services.sh
```

### Comandos alternativos usando scripts de Spark

```bash
# Iniciar Spark Master (alternativo)
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && /opt/spark/sbin/start-master.sh"

# Iniciar Spark Worker (alternativo)
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && /opt/spark/sbin/start-worker.sh spark://localhost:7077"
```

2. Acceder a Jupyter Notebook:
   - Abrir en el navegador: http://localhost:8888
   - No se requiere contraseña

3. Acceder a las interfaces web de Hadoop y Spark:
   - HDFS NameNode: http://localhost:9870
   - YARN ResourceManager: http://localhost:8088
   - Spark Master UI: http://localhost:8080 (si se inicia manualmente)
   - Spark Worker UI: http://localhost:8081 (si se inicia manualmente)
   - Spark UI: http://localhost:4040 (disponible cuando se ejecuta una aplicación Spark)

Una vez que todos los servicios estén ejecutándose, podrás acceder a:

- **Jupyter Notebook**: http://localhost:8888
- **Hadoop NameNode Web UI**: http://localhost:9870
- **YARN ResourceManager Web UI**: http://localhost:8088
- **Spark Master Web UI**: http://localhost:8080
- **Spark Worker Web UI**: http://localhost:8081

### Reinicio Manual de Servicios

Si los servicios se detienen o necesitas reiniciarlos manualmente:

#### Hadoop NameNode (HDFS)
```bash
# Formatear NameNode (solo si es necesario)
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && hdfs namenode -format -force"

# Iniciar NameNode
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && nohup java -Dproc_namenode -Xmx1000m org.apache.hadoop.hdfs.server.namenode.NameNode > /opt/hadoop/logs/namenode.log 2>&1 &"

# Iniciar DataNode
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && nohup java -Dproc_datanode -Xmx1000m org.apache.hadoop.hdfs.server.datanode.DataNode > /opt/hadoop/logs/datanode.log 2>&1 &"
```

#### Spark Master y Worker
```bash
# Crear directorio de logs si no existe
docker exec hadoop-spark-jupyter bash -c "mkdir -p /opt/spark/logs"

# Iniciar Spark Master
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && export SPARK_CONF_DIR=/opt/spark/conf && nohup java -cp '/opt/spark/jars/*' -Xmx1g org.apache.spark.deploy.master.Master --host localhost --port 7077 --webui-port 8080 > /opt/spark/logs/spark-master.log 2>&1 &"

# Iniciar Spark Worker (conectado al Master)
docker exec hadoop-spark-jupyter bash -c "export SPARK_HOME=/opt/spark && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk && export SPARK_CONF_DIR=/opt/spark/conf && nohup java -cp '/opt/spark/jars/*' -Xmx1g org.apache.spark.deploy.worker.Worker spark://localhost:7077 --host localhost --webui-port 8081 > /opt/spark/logs/spark-worker.log 2>&1 &"
```

#### Comandos alternativos (si los scripts funcionan)
```bash
# Acceder al contenedor
docker exec -it hadoop-spark-jupyter bash

# Intentar usar scripts de Hadoop (pueden fallar por incompatibilidades de shell)
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

# Intentar usar scripts de Spark
/opt/spark/sbin/start-master.sh
```

#### Verificar servicios
```bash
# Ver procesos de Hadoop y Spark ejecutándose
docker exec hadoop-spark-jupyter bash -c "ps aux | grep -E '(NameNode|DataNode|Master|Worker)' | grep -v grep"

# Verificar puertos activos (incluye Worker en 8081)
docker exec hadoop-spark-jupyter bash -c "netstat -tlnp | grep -E '(8080|8081|7077|9870|8888)'"

# Ver procesos Java (alternativo)
docker exec hadoop-spark-jupyter jps
```

4. Detener los contenedores:

```bash
docker-compose down
```

## Solución de problemas

### Errores comunes

#### Error "Couldn't find datanode to write file. Forbidden"
Este error indica que el DataNode no está ejecutándose. Las causas más comunes son:
- **Crash del DataNode por librerías nativas**: Las librerías nativas de Hadoop pueden causar crashes en Alpine Linux. Los scripts automatizados ya incluyen la solución (`HADOOP_OPTS='-Djava.library.path='`)
- **DataNode no iniciado**: Verifica que el DataNode esté ejecutándose con `docker exec hadoop-spark-jupyter jps`
- **Permisos de HDFS**: Asegúrate de que el directorio de destino tenga los permisos correctos

#### Error "declare: not found" en scripts de Hadoop
Los scripts de Hadoop pueden tener problemas de compatibilidad con el shell. Usa los comandos Java directos documentados arriba en lugar de los scripts.

#### Servicios no inician automáticamente
Si los servicios no se inician automáticamente al crear el contenedor, usa los comandos manuales documentados en la sección "Reinicio Manual de Servicios".

#### Puerto 8080 ocupado
Si el puerto 8080 está ocupado, puedes cambiar el puerto de Spark Master:
```bash
# Cambiar --webui-port a otro puerto disponible
docker exec hadoop-spark-jupyter bash -c "... --webui-port 8081 ..."
```

#### Verificar logs
```bash
# Logs de Hadoop
docker exec hadoop-spark-jupyter tail -f /opt/hadoop/logs/namenode.log
docker exec hadoop-spark-jupyter tail -f /opt/hadoop/logs/datanode.log

# Logs de Spark
docker exec hadoop-spark-jupyter tail -f /opt/spark/logs/spark-master.log
docker exec hadoop-spark-jupyter tail -f /opt/spark/logs/spark-worker.log
```

## Estructura del proyecto

- `Dockerfile`: Configuración para construir la imagen Docker
- `docker-compose.yml`: Configuración para orquestar los servicios
- `start-services.sh`: Script para iniciar todos los servicios
- `notebooks/`: Directorio compartido para los notebooks de Jupyter


## Subir archivo local
```bash
docker cp "C:\Users\xxx\Downloads\xxx.csv" hadoop-spark-jupyter:/tmp/xxx.csv
docker exec hadoop-spark-jupyter bash -c "export HADOOP_HOME=/opt/hadoop && export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 && /opt/hadoop/bin/hdfs dfs -put /tmp/xxx.csv /carpeta/"
```

## Cambiar permisos de una carpeta
```bash
docker exec hadoop-spark-jupyter bash -c "/opt/hadoop/bin/hdfs dfs -chmod 777 /prueba"
```
## Detener servicios
```bash
   docker exec hadoop-spark-jupyter bash -c "hdfs --daemon stop datanode"
   docker exec hadoop-spark-jupyter bash -c "hdfs --daemon stop namenode"
```

## Reiniciar servicios
```bash
   docker exec hadoop-spark-jupyter bash -c "hdfs --daemon start namenode"
   docker exec hadoop-spark-jupyter bash -c "hdfs --daemon start datanode"
```


