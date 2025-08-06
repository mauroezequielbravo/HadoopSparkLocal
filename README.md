# Entorno Hadoop, Spark y Jupyter Notebook

Este proyecto proporciona un entorno Docker con Hadoop, Spark y Jupyter Notebook integrados.

## Servicios y puertos

- Jupyter Notebook: http://localhost:8888
- Spark UI: http://localhost:4040
- Spark Master UI: http://localhost:8080
- HDFS NameNode UI: http://localhost:9870
- YARN ResourceManager UI: http://localhost:8088

## Instrucciones de uso

### Inicio Automático

1. Construir e iniciar los contenedores:

```bash
docker-compose up -d
```

Al ejecutar este comando, el contenedor automáticamente:
- Configura Hadoop (core-site.xml, hdfs-site.xml, mapred-site.xml, yarn-site.xml)
- Formatea HDFS NameNode si es necesario
- Inicia todos los servicios de HDFS y YARN
- Crea directorios necesarios en HDFS
- Inicia Jupyter Notebook
- **Nota**: Spark Master/Worker requieren inicio manual si es necesario

2. Acceder a Jupyter Notebook:
   - Abrir en el navegador: http://localhost:8888
   - No se requiere contraseña

3. Acceder a las interfaces web de Hadoop y Spark:
   - HDFS NameNode: http://localhost:9870
   - YARN ResourceManager: http://localhost:8088
   - Spark Master UI: http://localhost:8080 (si se inicia manualmente)
   - Spark Worker UI: http://localhost:8081 (si se inicia manualmente)
   - Spark UI: http://localhost:4040 (disponible cuando se ejecuta una aplicación Spark)

### Reinicio Manual de Servicios

Si los servicios se detienen o necesitas reiniciarlos manualmente:

#### Opción 1: Scripts de Hadoop (recomendado)
```bash
# Acceder al contenedor
docker exec -it hadoop-spark-jupyter bash

# Iniciar servicios HDFS
$HADOOP_HOME/sbin/start-dfs.sh

# Iniciar servicios YARN
$HADOOP_HOME/sbin/start-yarn.sh
```

#### Opción 2: Comandos individuales
```bash
# Acceder al contenedor
docker exec -it hadoop-spark-jupyter bash

# Iniciar HDFS
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
hdfs --daemon start namenode
hdfs --daemon start datanode

# Iniciar YARN
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
```

#### Iniciar Spark Master y Worker (opcional)
```bash
# Spark Master
/opt/spark/bin/spark-class org.apache.spark.deploy.master.Master --host localhost --port 7077 --webui-port 8080 &

# Spark Worker
/opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker spark://localhost:7077 --webui-port 8081 &
```

#### Verificar servicios
```bash
# Ver procesos Java ejecutándose
jps
```

4. Detener los contenedores:

```bash
docker-compose down
```

## Estructura del proyecto

- `Dockerfile`: Configuración para construir la imagen Docker
- `docker-compose.yml`: Configuración para orquestar los servicios
- `start-services.sh`: Script para iniciar todos los servicios
- `notebooks/`: Directorio compartido para los notebooks de Jupyter