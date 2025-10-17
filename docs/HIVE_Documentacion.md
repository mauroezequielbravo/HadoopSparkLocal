# 🐝 Apache Hive - Documentación de Uso

## 📋 Descripción

Apache Hive es un sistema de data warehouse construido sobre Hadoop que facilita la lectura, escritura y gestión de grandes conjuntos de datos mediante consultas SQL (HiveQL).

## 🏗️ Arquitectura Implementada

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  ┌──────────────┐  ┌──────────────┐            │
│  │  PostgreSQL  │──│   Hive       │            │
│  │ (Puerto 5433)│  │  Metastore   │            │
│  │              │  │ (Puerto 9083)│            │
│  └──────────────┘  └──────┬───────┘            │
│                           │                     │
│  ┌──────────────┐         │                     │
│  │   Hadoop     │◄────────┼──────────┐          │
│  │   (HDFS)     │         │          │          │
│  │ Puerto 9870  │         │          │          │
│  └──────────────┘         │          │          │
│                           │          │          │
│  ┌──────────────┐         │          │          │
│  │ HiveServer2  │◄────────┘          │          │
│  │ Puerto 10000 │                    │          │
│  │  Web: 10002  │                    │          │
│  └──────────────┘                    │          │
│                                      │          │
│  ┌──────────────┐                    │          │
│  │    Spark     │◄───────────────────┘          │
│  │  + Jupyter   │                               │
│  │ Puerto 8888  │                               │
│  └──────────────┘                               │
└─────────────────────────────────────────────────┘
```

## 🚀 Iniciar los Servicios

### Iniciar todos los contenedores
```powershell
docker-compose up -d
```

### Verificar el estado de los servicios
```powershell
docker-compose ps
```

### Ver logs de Hive
```powershell
# Ver logs del Metastore
docker-compose logs -f hive-metastore

# Ver logs de HiveServer2
docker-compose logs -f hive-server

# Ver logs de PostgreSQL
docker-compose logs -f postgres
```

## 🔌 Puertos Expuestos

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| PostgreSQL | **5433** | Base de datos del Metastore (puerto alternativo) |
| Hive Metastore | 9083 | Servicio Thrift del Metastore |
| HiveServer2 | 10000 | JDBC/Beeline para consultas SQL |
| HiveServer2 Web UI | 10002 | Interfaz web de HiveServer2 |

**Nota:** PostgreSQL usa el puerto **5433** en el host para evitar conflictos con otras instancias de PostgreSQL que puedan estar corriendo en el puerto estándar 5432.

## 💻 Conectarse a Hive

### Opción 1: Usando Beeline (Cliente CLI de Hive)

```powershell
# Acceder al contenedor de HiveServer2
docker exec -it hive-server bash

# Dentro del contenedor, conectarse con Beeline
beeline -u jdbc:hive2://localhost:10000

# O directamente desde PowerShell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

### Opción 2: Desde tu máquina local (si tienes Beeline instalado)

```bash
beeline -u jdbc:hive2://localhost:10000
```

### Opción 3: Conexión JDBC desde aplicaciones

**String de conexión:**
```
jdbc:hive2://localhost:10000
```

**Driver:** `org.apache.hive.jdbc.HiveDriver`

## 📝 Ejemplos de Uso

### 1. Crear una Base de Datos

```sql
-- Crear una base de datos
CREATE DATABASE IF NOT EXISTS mi_database;

-- Usar la base de datos
USE mi_database;

-- Ver bases de datos
SHOW DATABASES;
```

### 2. Crear Tablas

#### Tabla Simple
```sql
CREATE TABLE IF NOT EXISTS empleados (
    id INT,
    nombre STRING,
    departamento STRING,
    salario DECIMAL(10,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
```

#### Tabla con Particiones
```sql
CREATE TABLE IF NOT EXISTS ventas (
    producto STRING,
    cantidad INT,
    precio DECIMAL(10,2)
)
PARTITIONED BY (anio INT, mes INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
```

#### Tabla Externa (datos ya existentes en HDFS)
```sql
CREATE EXTERNAL TABLE IF NOT EXISTS logs (
    timestamp STRING,
    level STRING,
    message STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/hive/external/logs';
```

### 3. Insertar Datos

```sql
-- Insertar datos manualmente
INSERT INTO empleados VALUES 
    (1, 'Juan Perez', 'Ventas', 50000.00),
    (2, 'Maria Garcia', 'IT', 65000.00),
    (3, 'Carlos Lopez', 'Marketing', 55000.00);

-- Insertar desde una consulta
INSERT INTO empleados
SELECT id, nombre, dept, salario 
FROM empleados_temp 
WHERE salario > 40000;
```

### 4. Cargar Datos desde Archivos

```sql
-- Cargar datos desde archivo local del contenedor
LOAD DATA LOCAL INPATH '/tmp/empleados.csv' 
INTO TABLE empleados;

-- Cargar datos desde HDFS
LOAD DATA INPATH '/user/data/empleados.csv' 
INTO TABLE empleados;
```

### 5. Consultas SQL

```sql
-- Consulta simple
SELECT * FROM empleados;

-- Consulta con filtros
SELECT nombre, salario 
FROM empleados 
WHERE departamento = 'IT' 
ORDER BY salario DESC;

-- Agregaciones
SELECT departamento, 
       COUNT(*) as total_empleados,
       AVG(salario) as salario_promedio
FROM empleados
GROUP BY departamento;

-- JOIN entre tablas
SELECT e.nombre, d.nombre_departamento
FROM empleados e
JOIN departamentos d ON e.departamento = d.id;
```

### 6. Trabajar con Particiones

```sql
-- Insertar en tabla particionada
INSERT INTO TABLE ventas PARTITION (anio=2024, mes=1)
VALUES ('Laptop', 5, 1200.00);

-- Consultar partición específica
SELECT * FROM ventas WHERE anio=2024 AND mes=1;

-- Ver particiones
SHOW PARTITIONS ventas;
```

### 7. Operaciones Comunes

```sql
-- Ver tablas
SHOW TABLES;

-- Describir estructura de tabla
DESCRIBE empleados;
DESCRIBE FORMATTED empleados;

-- Ver esquema de tabla
SHOW CREATE TABLE empleados;

-- Eliminar tabla
DROP TABLE IF EXISTS empleados;

-- Truncar tabla (eliminar datos, mantener estructura)
TRUNCATE TABLE empleados;
```

## 🐍 Usar Hive desde PySpark (Jupyter)

### Configurar Spark para usar Hive

```python
from pyspark.sql import SparkSession

# Crear sesión de Spark con soporte para Hive
spark = SparkSession.builder \
    .appName("Spark con Hive") \
    .config("spark.sql.warehouse.dir", "/user/hive/warehouse") \
    .config("hive.metastore.uris", "thrift://hive-metastore:9083") \
    .enableHiveSupport() \
    .getOrCreate()

# Ver bases de datos
spark.sql("SHOW DATABASES").show()

# Usar una base de datos
spark.sql("USE mi_database")

# Consultar tabla de Hive
df = spark.sql("SELECT * FROM empleados")
df.show()

# Crear tabla desde DataFrame
df_pandas = spark.createDataFrame([
    (1, "Juan", "IT", 50000),
    (2, "Maria", "Ventas", 45000)
], ["id", "nombre", "departamento", "salario"])

# Guardar como tabla de Hive
df_pandas.write.mode("overwrite").saveAsTable("empleados_nuevos")
```

## 🔧 Comandos Útiles de Administración

### Verificar conectividad con HDFS desde Hive

```bash
# Acceder al contenedor
docker exec -it hive-server bash

# Ver directorios de Hive en HDFS
hdfs dfs -ls /user/hive/warehouse

# Ver contenido de una tabla
hdfs dfs -ls /user/hive/warehouse/mi_database.db/empleados
```

### Verificar Metastore en PostgreSQL

```powershell
# Conectarse a PostgreSQL (puerto 5433)
docker exec -it postgres-hive-metastore psql -U hive -d metastore

# Ver tablas del metastore
\dt

# Ver información de bases de datos de Hive
SELECT * FROM "DBS";

# Ver información de tablas
SELECT * FROM "TBLS";

# Salir
\q
```

### Reiniciar Servicios

```powershell
# Reiniciar solo los servicios de Hive
docker-compose restart hive-metastore hive-server

# Reiniciar todo el stack
docker-compose restart
```

## 🐛 Troubleshooting

### ⚠️ Error: ClassCastException con URLClassLoader

**Síntoma:** 
```
java.lang.ClassCastException: class jdk.internal.loader.ClassLoaders$AppClassLoader 
cannot be cast to class java.net.URLClassLoader
```

**Causa:** Incompatibilidad entre Hive 3.1.3 y Java 11+

**Solución:** ✅ Ya implementada - el Dockerfile usa Java 8 (`openjdk-8-jdk`)

### ⚠️ Error: User root is not allowed to impersonate

**Síntoma:** 
```
User: root is not allowed to impersonate anonymous
```

**Causa:** Hadoop no tiene configurado el proxy user para Hive

**Solución:** ✅ Ya implementada - `hadoop/config/core-site.xml` incluye:
```xml
<property>
    <name>hadoop.proxyuser.root.groups</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.root.hosts</name>
    <value>*</value>
</property>
```

### 🔄 HiveServer2 tarda mucho en iniciar

**Es normal:** La primera vez puede tardar 2-3 minutos en iniciar completamente.

```powershell
# Verificar si el puerto ya está abierto
docker exec hive-server nc -z localhost 10000 && echo "✅ Listo" || echo "⏳ Aún iniciando"

# Ver progreso en logs
docker-compose logs -f hive-server
```

### Error: No se puede conectar al Metastore

**Verificar:**
1. ¿Está corriendo el contenedor del Metastore?
   ```powershell
   docker-compose ps hive-metastore
   ```

2. Ver logs para errores:
   ```powershell
   docker-compose logs hive-metastore
   ```

3. Verificar conectividad con PostgreSQL:
   ```powershell
   docker exec -it postgres-hive-metastore pg_isready -U postgres
   ```

### Error: No se puede acceder a HDFS

**Verificar:**
1. ¿Está Hadoop corriendo?
   ```powershell
   docker-compose ps hadoop
   ```

2. Probar conexión desde el contenedor de Hive:
   ```powershell
   docker exec hive-server hdfs dfs -ls /
   ```

### Error: Tabla no encontrada

**Verificar:**
1. ¿Estás usando la base de datos correcta?
   ```sql
   USE mi_database;
   SHOW TABLES;
   ```

2. ¿La tabla existe en el Metastore?
   ```sql
   SHOW TABLES;
   ```

### Error: Connection refused al puerto 10000

**Verificar:**
```powershell
# Ver si HiveServer2 está corriendo
docker-compose ps hive-server

# Ver logs completos
docker-compose logs hive-server

# Reiniciar si es necesario
docker-compose restart hive-server
```

## 📚 Recursos Adicionales

- **HiveServer2 Web UI:** http://localhost:10002
- **Hadoop NameNode UI:** http://localhost:9870
- **Spark UI:** http://localhost:4040 (cuando hay una aplicación corriendo)
- **Jupyter Notebook:** http://localhost:8888

## 🛑 Detener los Servicios

```powershell
# Detener todos los contenedores
docker-compose down

# Detener y eliminar volúmenes (¡cuidado! elimina datos)
docker-compose down -v
```

## 📊 Ejemplo Completo: ETL con Hive

```sql
-- 1. Crear base de datos
CREATE DATABASE IF NOT EXISTS analytics;
USE analytics;

-- 2. Crear tabla de staging (datos crudos)
CREATE TABLE IF NOT EXISTS ventas_raw (
    fecha STRING,
    producto STRING,
    categoria STRING,
    cantidad INT,
    precio DECIMAL(10,2)
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 3. Cargar datos
LOAD DATA LOCAL INPATH '/tmp/ventas.csv' INTO TABLE ventas_raw;

-- 4. Crear tabla procesada con particiones
CREATE TABLE IF NOT EXISTS ventas_procesadas (
    producto STRING,
    categoria STRING,
    total_cantidad INT,
    total_ventas DECIMAL(15,2)
)
PARTITIONED BY (anio INT, mes INT)
STORED AS PARQUET;

-- 5. Procesar y cargar datos
INSERT INTO TABLE ventas_procesadas PARTITION (anio=2024, mes=10)
SELECT 
    producto,
    categoria,
    SUM(cantidad) as total_cantidad,
    SUM(cantidad * precio) as total_ventas
FROM ventas_raw
WHERE YEAR(fecha) = 2024 AND MONTH(fecha) = 10
GROUP BY producto, categoria;

-- 6. Consultar resultados
SELECT * FROM ventas_procesadas WHERE anio=2024 AND mes=10;
```

---

**¡Hive está listo para usar! 🎉**
