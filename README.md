# Entorno Hadoop, Spark y Jupyter Notebook

Este proyecto proporciona un entorno Docker con Hadoop, Spark y Jupyter Notebook integrados.

## Servicios disponibles

- **Jupyter Notebook**: http://localhost:8888
- **HDFS NameNode UI**: http://localhost:9870
- **Spark Master UI**: http://localhost:8080
- **YARN ResourceManager UI**: http://localhost:8088
- **Spark UI**: http://localhost:4040

## Comandos básicos

### Crear y ejecutar el contenedor

```bash
# Construir e iniciar el contenedor
docker-compose up --build

# Ejecutar en segundo plano
docker-compose up --build -d
```

### Ver logs del contenedor

```bash
# Ver todos los logs
docker-compose logs

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs hadoop-spark-jupyter
```

### Detener y reiniciar servicios

```bash
# Detener el contenedor
docker-compose down

# Reiniciar el contenedor
docker-compose restart

# Detener y eliminar volúmenes (limpieza completa)
docker-compose down -v
```

### Gestión de servicios internos

```bash
# Detener servicios HDFS
docker exec hadoop-spark-jupyter bash -c "hdfs --daemon stop datanode"
docker exec hadoop-spark-jupyter bash -c "hdfs --daemon stop namenode"

# Iniciar servicios HDFS
docker exec hadoop-spark-jupyter bash -c "hdfs --daemon start namenode"
docker exec hadoop-spark-jupyter bash -c "hdfs --daemon start datanode"
```

## Solución de problemas

### Verificar estado de servicios

```bash
# Ver procesos Java ejecutándose
docker exec hadoop-spark-jupyter jps

# Verificar puertos activos
docker exec hadoop-spark-jupyter bash -c "netstat -tlnp | grep -E '(8080|9870|8888)'"
```

### Acceder al contenedor

```bash
# Acceso interactivo al contenedor
docker exec -it hadoop-spark-jupyter bash
```

### Subir archivos a HDFS

```bash
# Copiar archivo local al contenedor
docker cp "archivo.csv" hadoop-spark-jupyter:/tmp/archivo.csv

# Subir archivo a HDFS
docker exec hadoop-spark-jupyter bash -c "/opt/hadoop/bin/hdfs dfs -put /tmp/archivo.csv /"
```

**Nota**: También puedes subir archivos directamente desde la interfaz web de HDFS en http://localhost:9870/explorer.html


