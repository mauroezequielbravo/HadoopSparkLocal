# 🚀 Guía de Inicio Rápido - Apache Hive

## Verificación Rápida

Después de ejecutar `docker-compose up -d`, espera 2-3 minutos y verifica:

```powershell
# Ver estado de todos los servicios
docker-compose ps

# Todos deberían mostrar "Up" y "healthy"
```

## Primer Uso - Checklist

### ✅ 1. Verificar servicios básicos

```powershell
# Hadoop HDFS
curl http://localhost:9870

# HiveServer2 Web UI
curl http://localhost:10002
```

### ✅ 2. Probar conexión a Beeline

```powershell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -e "SHOW DATABASES;"
```

### ✅ 3. Crear tu primera tabla

```powershell
# Conectarse a Beeline interactivamente
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

Dentro de Beeline:

```sql
-- Crear base de datos de prueba
CREATE DATABASE IF NOT EXISTS quickstart;
USE quickstart;

-- Crear tabla simple
CREATE TABLE IF NOT EXISTS test_table (
    id INT,
    name STRING,
    value DOUBLE
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- Insertar datos de prueba
INSERT INTO test_table VALUES 
    (1, 'alpha', 10.5),
    (2, 'beta', 20.3),
    (3, 'gamma', 15.7);

-- Consultar
SELECT * FROM test_table;

-- Salir
!quit
```

### ✅ 4. Probar desde Jupyter (PySpark)

Abre http://localhost:8888 y crea un nuevo notebook:

```python
from pyspark.sql import SparkSession

# Crear sesión con Hive
spark = SparkSession.builder \
    .appName("QuickStart") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .config("hive.metastore.uris", "thrift://hive-metastore:9083") \
    .enableHiveSupport() \
    .getOrCreate()

# Ver bases de datos
spark.sql("SHOW DATABASES").show()

# Consultar tabla
df = spark.sql("SELECT * FROM quickstart.test_table")
df.show()

# Análisis básico
df.describe().show()
```

## Comandos Útiles del Día a Día

### Gestión de Servicios

```powershell
# Iniciar
docker-compose up -d

# Ver logs específicos
docker-compose logs -f hive-server

# Reiniciar Hive sin afectar otros servicios
docker-compose restart hive-metastore hive-server

# Detener todo
docker-compose down
```

### Trabajar con HDFS

```powershell
# Listar warehouse de Hive
docker exec hadoop-master hdfs dfs -ls /user/hive/warehouse

# Ver contenido de una base de datos
docker exec hadoop-master hdfs dfs -ls /user/hive/warehouse/quickstart.db

# Subir archivo CSV para cargar en Hive
docker cp datos.csv hadoop-master:/tmp/
docker exec hadoop-master hdfs dfs -put /tmp/datos.csv /user/hive/data/
```

### Consultas Rápidas desde PowerShell

```powershell
# Ejecutar consulta sin entrar a Beeline
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -e "SELECT COUNT(*) FROM quickstart.test_table;"

# Ejecutar script SQL
docker exec -i hive-server beeline -u jdbc:hive2://localhost:10000 -f /ruta/al/script.sql
```

### Verificar Metastore (PostgreSQL)

```powershell
# Conectar a PostgreSQL
docker exec -it postgres-hive-metastore psql -U hive -d metastore

# Dentro de psql:
# \dt              -- Ver tablas del metastore
# SELECT * FROM "DBS";  -- Ver bases de datos de Hive
# \q               -- Salir
```

## Ejemplos Prácticos

### Ejemplo 1: Cargar CSV a Hive

1. Crear archivo `empleados.csv`:
```csv
1,Juan Perez,Ventas,50000
2,Maria Garcia,IT,65000
3,Carlos Lopez,Marketing,55000
```

2. Copiar al contenedor:
```powershell
docker cp empleados.csv hadoop-master:/tmp/
```

3. Crear tabla y cargar en Beeline:
```sql
USE quickstart;

CREATE TABLE empleados (
    id INT,
    nombre STRING,
    departamento STRING,
    salario DECIMAL(10,2)
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/tmp/empleados.csv' INTO TABLE empleados;

SELECT * FROM empleados;
```

### Ejemplo 2: Tabla Particionada

```sql
-- Crear tabla particionada por año y mes
CREATE TABLE ventas (
    producto STRING,
    cantidad INT,
    precio DECIMAL(10,2)
)
PARTITIONED BY (anio INT, mes INT)
STORED AS PARQUET;

-- Insertar datos
INSERT INTO TABLE ventas PARTITION (anio=2024, mes=10)
VALUES 
    ('Laptop', 10, 1200.00),
    ('Mouse', 50, 25.50),
    ('Teclado', 30, 85.00);

-- Consultar partición específica
SELECT * FROM ventas WHERE anio=2024 AND mes=10;

-- Ver particiones
SHOW PARTITIONS ventas;
```

### Ejemplo 3: JOIN entre tablas

```sql
-- Crear tabla de departamentos
CREATE TABLE departamentos (
    id STRING,
    nombre STRING,
    presupuesto DECIMAL(12,2)
) ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

INSERT INTO departamentos VALUES
    ('Ventas', 'Departamento de Ventas', 500000),
    ('IT', 'Tecnología e Información', 800000),
    ('Marketing', 'Marketing y Publicidad', 350000);

-- JOIN
SELECT 
    e.nombre,
    e.salario,
    d.nombre as dept_nombre,
    d.presupuesto
FROM empleados e
JOIN departamentos d ON e.departamento = d.id;
```

## Monitoreo

### URLs de Monitoreo

| Servicio | URL | Descripción |
|----------|-----|-------------|
| HDFS | http://localhost:9870 | NameNode UI |
| YARN | http://localhost:8088 | ResourceManager |
| HiveServer2 | http://localhost:10002 | HiveServer2 Web UI |
| Spark | http://localhost:8080 | Spark Master UI |
| Jupyter | http://localhost:8888 | Notebooks |

### Verificar Salud del Sistema

```powershell
# Ver uso de disco de HDFS
docker exec hadoop-master hdfs dfsadmin -report

# Ver bases de datos y tablas
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -e "SHOW DATABASES; SHOW TABLES;"

# Ver logs recientes de HiveServer2
docker-compose logs --tail=50 hive-server
```

## Troubleshooting Rápido

### Problema: "Connection refused" al conectar a Beeline

```powershell
# 1. Verificar que HiveServer2 esté corriendo
docker-compose ps hive-server

# 2. Ver logs
docker-compose logs hive-server

# 3. Verificar que el Metastore esté disponible
docker exec hive-server nc -zv hive-metastore 9083

# 4. Si es necesario, reiniciar
docker-compose restart hive-metastore hive-server
```

### Problema: Tabla no se puede crear

```powershell
# Verificar conectividad con HDFS
docker exec hive-server hdfs dfs -ls /

# Verificar permisos en HDFS
docker exec hadoop-master hdfs dfs -ls -R /user/hive/

# Recrear directorios con permisos
docker exec hadoop-master hdfs dfs -mkdir -p /user/hive/warehouse
docker exec hadoop-master hdfs dfs -chmod -R 777 /user/hive/
```

### Problema: "Schema verification failed"

```powershell
# Reinicializar el schema del Metastore
docker exec -it hive-metastore schematool -dbType postgres -initSchema

# Si persiste, eliminar y recrear volumen de PostgreSQL
docker-compose down
docker volume rm hive-metastore-postgres-data
docker-compose up -d
```

## Siguientes Pasos

1. **Lee la documentación completa**: [docs/HIVE_Documentacion.md](../docs/HIVE_Documentacion.md)
2. **Practica con datasets reales**: Descarga datasets CSV y prueba cargarlos
3. **Integra con Spark**: Usa DataFrames de Spark sobre tablas de Hive
4. **Optimiza consultas**: Aprende sobre particiones, bucketing y formatos (Parquet, ORC)

---

**¡Éxito con Apache Hive! 🐝**
