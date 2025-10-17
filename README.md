# Entorno Hadoop, Spark, Hive y Jupyter Notebook

Este proyecto proporciona un entorno Docker completo con Hadoop, Spark, Apache Hive y Jupyter Notebook integrados para procesamiento y análisis de Big Data.

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  PostgreSQL  │──│   Hive       │            │
│  │ (Puerto 5433)│  │  Metastore   │            │
│  └──────────────┘  └──────┬───────┘            │
│                           │                     │
│  ┌──────────────┐         │                     │
│  │   Hadoop     │◄────────┼──────────┐          │
│  │   (HDFS)     │         │          │          │
│  └──────────────┘         │          │          │
│                           │          │          │
│  ┌──────────────┐         │          │          │
│  │ HiveServer2  │◄────────┘          │          │
│  └──────────────┘                    │          │
│                                      │          │
│  ┌──────────────┐                    │          │
│  │    Spark     │◄───────────────────┘          │
│  │  + Jupyter   │                               │
│  └──────────────┘                               │
└─────────────────────────────────────────────────┘
```

## 📦 Servicios Disponibles

### Interfaz Web
- **Jupyter Notebook**: http://localhost:8888
- **HDFS NameNode UI**: http://localhost:9870
- **Spark Master UI**: http://localhost:8080
- **YARN ResourceManager UI**: http://localhost:8088
- **Spark Application UI**: http://localhost:4040
- **HiveServer2 Web UI**: http://localhost:10002

### Puertos de Servicios
- **HiveServer2 (JDBC)**: `localhost:10000`
- **Hive Metastore**: `localhost:9083`
- **PostgreSQL**: `localhost:5433` (puerto alternativo para evitar conflictos)

## 🚀 Inicio Rápido

### Iniciar el entorno completo

```powershell
# Construir e iniciar todos los servicios
docker-compose up --build -d

# Ver el estado de los contenedores
docker-compose ps
```

### Ver logs de los servicios

```powershell
# Ver todos los logs
docker-compose logs

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de servicios específicos
docker-compose logs -f hadoop
docker-compose logs -f spark
docker-compose logs -f hive-server
docker-compose logs -f hive-metastore
docker-compose logs -f postgres
```

### Detener y reiniciar servicios

```powershell
# Detener todos los contenedores
docker-compose down

# Reiniciar servicios específicos
docker-compose restart hive-server
docker-compose restart spark

# Detener y eliminar volúmenes (⚠️ elimina datos persistentes)
docker-compose down -v
```

## 🐝 Trabajar con Hive

### Conectarse a HiveServer2 con Beeline

```powershell
# Acceder al contenedor y ejecutar Beeline
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

### Ejemplo rápido de uso

```sql
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS test_db;
USE test_db;

-- Crear tabla
CREATE TABLE IF NOT EXISTS usuarios (
    id INT,
    nombre STRING,
    edad INT
);

-- Insertar datos
INSERT INTO usuarios VALUES (1, 'Juan', 30), (2, 'María', 25);

-- Consultar
SELECT * FROM usuarios;
```

### Usar Hive desde Jupyter (PySpark)

```python
from pyspark.sql import SparkSession

# Crear sesión con soporte Hive
spark = SparkSession.builder \
    .appName("Hive Example") \
    .config("hive.metastore.uris", "thrift://hive-metastore:9083") \
    .enableHiveSupport() \
    .getOrCreate()

# Consultar tabla de Hive
df = spark.sql("SELECT * FROM test_db.usuarios")
df.show()
```

**📖 Documentación completa de Hive:** [docs/HIVE_Documentacion.md](docs/HIVE_Documentacion.md)

## 🔧 Gestión Avanzada

### Acceder a los contenedores

```powershell
# Acceder al contenedor de Hadoop
docker exec -it hadoop-master bash

# Acceder al contenedor de Spark
docker exec -it spark-master bash

# Acceder al contenedor de Hive
docker exec -it hive-server bash

# Acceder a PostgreSQL
docker exec -it postgres-hive-metastore psql -U hive -d metastore
```

### Verificar estado de servicios

```powershell
# Ver procesos Java en Hadoop
docker exec hadoop-master jps

# Ver procesos Java en Spark
docker exec spark-master jps

# Verificar conectividad de Hive con el Metastore
docker exec hive-server nc -zv hive-metastore 9083

# Verificar estado de PostgreSQL
docker exec postgres-hive-metastore pg_isready -U postgres
```

### Subir archivos a HDFS

```powershell
# Copiar archivo local al contenedor
docker cp "archivo.csv" hadoop-master:/tmp/archivo.csv

# Subir archivo a HDFS desde el contenedor
docker exec hadoop-master hdfs dfs -put /tmp/archivo.csv /user/hive/data/

# Ver archivos en HDFS
docker exec hadoop-master hdfs dfs -ls /user/hive/data/
```

**Nota**: También puedes subir archivos directamente desde la interfaz web de HDFS en http://localhost:9870/explorer.html

## 🐛 Solución de Problemas

### Hive no puede conectarse al Metastore

```powershell
# Verificar que PostgreSQL esté corriendo
docker-compose ps postgres

# Ver logs del Metastore
docker-compose logs hive-metastore

# Verificar conectividad
docker exec hive-metastore nc -zv postgres 5432
```

### Error en inicialización de esquema de Hive

```powershell
# Reinicializar el esquema manualmente
docker exec -it hive-metastore bash
schematool -dbType postgres -initSchema

# O eliminar el volumen de PostgreSQL y recrear
docker-compose down -v
docker-compose up -d
```

### HiveServer2 no responde

```powershell
# Ver logs de HiveServer2
docker-compose logs -f hive-server

# Verificar que el Metastore esté disponible
docker exec hive-server nc -zv hive-metastore 9083

# Reiniciar HiveServer2
docker-compose restart hive-server
```

## 📚 Documentación Adicional

- **[Hive - Guía completa de uso](docs/HIVE_Documentacion.md)** - Consultas SQL, ejemplos y comandos
- **[HDFS - Permisos y configuración](docs/HDFS_Permisos_Documentacion.md)** - Gestión de permisos en HDFS

## 🛠️ Estructura del Proyecto

```
HadoopSparkLocal/
├── docker-compose.yml          # Orquestación de servicios
├── hadoop/                     # Configuración de Hadoop
│   ├── Dockerfile
│   ├── start-hadoop.sh
│   └── config/                 # Archivos de configuración HDFS/YARN
├── spark/                      # Configuración de Spark
│   ├── Dockerfile
│   └── start-spark.sh
├── hive/                       # Configuración de Hive
│   ├── Dockerfile
│   ├── start-hive.sh
│   └── config/
│       └── hive-site.xml
├── postgres/                   # Inicialización de PostgreSQL
│   └── init-hive-metastore.sh
├── notebooks/                  # Jupyter notebooks
└── docs/                       # Documentación
    ├── HIVE_Documentacion.md
    └── HDFS_Permisos_Documentacion.md
```

## 🎯 Casos de Uso

### 1. Análisis de datos con SQL (Hive)
- Crear tablas sobre datos en HDFS
- Ejecutar consultas SQL complejas
- Particionamiento y optimización

### 2. Machine Learning con Spark
- Usar PySpark en Jupyter
- Procesamiento distribuido
- Integración con bibliotecas de ML

### 3. ETL (Extract, Transform, Load)
- Cargar datos desde múltiples fuentes
- Transformar con Hive o Spark
- Almacenar en HDFS con formato optimizado

### 4. Data Warehouse
- Usar Hive como capa SQL sobre HDFS
- Metastore compartido entre Hive y Spark
- Consultas desde herramientas BI via JDBC

## ⚠️ Resolución de Problemas Comunes

### Hive: ClassCastException con Java
**Síntoma:** HiveServer2 no inicia, error `ClassCastException` en los logs.  
**Causa:** Hive 3.1.3 no es compatible con Java 11+.  
**Solución:** Verificar que el Dockerfile de Hive use `openjdk-8-jdk`.

### Hive: User root is not allowed to impersonate
**Síntoma:** Error al ejecutar consultas desde Hive.  
**Causa:** Hadoop no tiene configurado proxy user para Hive.  
**Solución:** Verificar que `hadoop/config/core-site.xml` tenga las propiedades `hadoop.proxyuser.root.*` y reiniciar Hadoop.

### HiveServer2 tarda mucho en iniciar
**Síntoma:** El servicio no responde inmediatamente.  
**Causa:** Normal. HiveServer2 requiere 2-3 minutos para inicializar.  
**Solución:** Esperar. El health check tiene un `start_period` de 120 segundos.

### PostgreSQL: Connection refused
**Síntoma:** Hive Metastore no puede conectar a PostgreSQL.  
**Causa:** PostgreSQL aún no está listo.  
**Solución:** Verificar `docker-compose logs postgres-hive-metastore` y esperar.

Para más detalles, consultar:
- `docs/HIVE_Documentacion.md` - Troubleshooting completo
- `docs/HIVE_Implementacion_Final.md` - Resumen de problemas resueltos

---

**💡 Tips:**
- PostgreSQL usa el puerto **5433** (en lugar del estándar 5432) para evitar conflictos con otras instalaciones locales.
- Hive requiere **Java 8**. No usar Java 11+ debido a incompatibilidades.
- HiveServer2 puede tardar varios minutos en inicializar la primera vez.


