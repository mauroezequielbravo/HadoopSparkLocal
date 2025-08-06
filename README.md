# Entorno Hadoop, Spark y Jupyter Notebook

Este proyecto proporciona un entorno Docker con Hadoop, Spark y Jupyter Notebook integrados.

## Servicios y puertos

- Jupyter Notebook: http://localhost:8888
- Spark UI: http://localhost:4040
- Spark Master UI: http://localhost:8080
- HDFS NameNode UI: http://localhost:9870
- YARN ResourceManager UI: http://localhost:8088

## Instrucciones de uso

1. Construir e iniciar los contenedores:

```bash
docker-compose up -d
```

2. Acceder a Jupyter Notebook:
   - Abrir en el navegador: http://localhost:8888
   - No se requiere contraseña

3. Acceder a las interfaces web de Hadoop y Spark:
   - HDFS NameNode: http://localhost:9870
   - YARN ResourceManager: http://localhost:8088
   - Spark UI: http://localhost:4040 (disponible cuando se ejecuta una aplicación Spark)

4. Detener los contenedores:

```bash
docker-compose down
```

## Estructura del proyecto

- `Dockerfile`: Configuración para construir la imagen Docker
- `docker-compose.yml`: Configuración para orquestar los servicios
- `start-services.sh`: Script para iniciar todos los servicios
- `notebooks/`: Directorio compartido para los notebooks de Jupyter