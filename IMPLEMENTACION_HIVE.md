# 📊 Resumen de la Implementación de Apache Hive

## ✅ Archivos Creados

### 🐝 Configuración de Hive
```
hive/
├── Dockerfile                  # Imagen con Hive 3.1.3 + PostgreSQL JDBC
├── start-hive.sh              # Script de inicio para Metastore y HiveServer2
└── config/
    └── hive-site.xml          # Configuración completa de Hive
```

### 🐘 Configuración de PostgreSQL
```
postgres/
└── init-hive-metastore.sh     # Script de inicialización de BD
```

### 📚 Documentación
```
docs/
├── HIVE_Documentacion.md      # Guía completa de Hive (ejemplos SQL, troubleshooting)
└── HIVE_QuickStart.md         # Guía de inicio rápido con ejemplos prácticos
```

### 🔧 Utilidades
```
.env.example                   # Plantilla de variables de entorno
verify-services.ps1            # Script de verificación de servicios
```

### 🐳 Docker Compose Actualizado
```
docker-compose.yml             # Agregados 3 servicios nuevos:
                               # - postgres (puerto 5433)
                               # - hive-metastore
                               # - hive-server
```

## 🏗️ Arquitectura Implementada

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network                           │
│                  (hadoop-spark-network)                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────┐         ┌────────────────┐             │
│  │  PostgreSQL    │────────►│ Hive Metastore │             │
│  │  (puerto 5433) │         │  (puerto 9083) │             │
│  │                │         │                │             │
│  │ Base de datos  │         │ Gestiona       │             │
│  │ para metadata  │         │ metadata       │             │
│  └────────────────┘         └────────┬───────┘             │
│                                      │                     │
│                                      │                     │
│  ┌────────────────┐                  │                     │
│  │  Hadoop HDFS   │◄─────────────────┼──────────┐          │
│  │  (puerto 9870) │                  │          │          │
│  │                │                  │          │          │
│  │ Almacenamiento │                  │          │          │
│  │ distribuido    │                  │          │          │
│  └────────────────┘                  │          │          │
│                                      │          │          │
│  ┌────────────────┐                  │          │          │
│  │  HiveServer2   │◄─────────────────┘          │          │
│  │  (puerto 10000)│                             │          │
│  │  Web UI: 10002 │                             │          │
│  │                │                             │          │
│  │ Servidor SQL   │                             │          │
│  └────────────────┘                             │          │
│                                                 │          │
│  ┌────────────────┐                             │          │
│  │  Spark Master  │◄────────────────────────────┘          │
│  │  + Jupyter     │                                        │
│  │  (puerto 8888) │                                        │
│  │                │  Puede usar tablas de Hive            │
│  │  PySpark       │  via enableHiveSupport()              │
│  └────────────────┘                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Características Implementadas

### ✨ PostgreSQL como Metastore
- ✅ Puerto alternativo **5433** (evita conflictos)
- ✅ Base de datos dedicada `metastore`
- ✅ Usuario específico `hive` con permisos
- ✅ Volumen persistente para datos
- ✅ Script de inicialización automática
- ✅ Health checks configurados

### 🐝 Hive Metastore Service
- ✅ Servicio dedicado independiente
- ✅ Puerto Thrift 9083 para comunicación
- ✅ Configuración optimizada
- ✅ Auto-inicialización del schema
- ✅ Conexión con PostgreSQL
- ✅ Acceso a HDFS configurado

### 🔷 HiveServer2
- ✅ Servidor JDBC en puerto 10000
- ✅ Web UI en puerto 10002
- ✅ Autenticación NONE (desarrollo)
- ✅ Beeline pre-configurado
- ✅ Logs habilitados
- ✅ Particionamiento dinámico habilitado

### 🔗 Integración con Stack Existente
- ✅ Configuración de HDFS compartida
- ✅ Warehouse en `/user/hive/warehouse`
- ✅ Compatible con Spark (enableHiveSupport)
- ✅ Health checks y dependencias configuradas
- ✅ Red Docker compartida

## 📝 Configuraciones Importantes

### hive-site.xml - Configuraciones Clave

| Propiedad | Valor | Descripción |
|-----------|-------|-------------|
| `javax.jdo.option.ConnectionURL` | `jdbc:postgresql://postgres:5432/metastore` | Conexión a PostgreSQL (interno puerto 5432) |
| `hive.metastore.uris` | `thrift://hive-metastore:9083` | URI del Metastore |
| `hive.metastore.warehouse.dir` | `/user/hive/warehouse` | Directorio de datos en HDFS |
| `hive.server2.thrift.port` | `10000` | Puerto JDBC de HiveServer2 |
| `hive.server2.webui.port` | `10002` | Puerto Web UI |
| `fs.defaultFS` | `hdfs://hadoop-master:9000` | NameNode de HDFS |
| `datanucleus.schema.autoCreateAll` | `true` | Auto-crear schema en PostgreSQL |
| `hive.server2.authentication` | `NONE` | Sin autenticación (desarrollo) |

### Variables de Entorno Importantes

```yaml
# Hive Metastore
HIVE_SERVICE=metastore

# HiveServer2
HIVE_SERVICE=hiveserver2
```

## 🚀 Comandos de Uso

### Iniciar el Entorno
```powershell
docker-compose up -d
```

### Verificar Servicios
```powershell
.\verify-services.ps1
```

### Conectarse a Hive
```powershell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

### Ver Logs
```powershell
docker-compose logs -f hive-server
docker-compose logs -f hive-metastore
```

## 🎓 Ejemplos de Uso

### 1. SQL Básico
```sql
CREATE DATABASE mi_db;
USE mi_db;
CREATE TABLE usuarios (id INT, nombre STRING);
INSERT INTO usuarios VALUES (1, 'Juan');
SELECT * FROM usuarios;
```

### 2. Desde PySpark
```python
spark = SparkSession.builder \
    .config("hive.metastore.uris", "thrift://hive-metastore:9083") \
    .enableHiveSupport() \
    .getOrCreate()

spark.sql("SELECT * FROM mi_db.usuarios").show()
```

### 3. Cargar CSV
```sql
CREATE TABLE datos (col1 STRING, col2 INT);
LOAD DATA LOCAL INPATH '/tmp/datos.csv' INTO TABLE datos;
```

## 🔍 Verificación Post-Implementación

### Checklist de Validación

- [ ] PostgreSQL responde en puerto 5433
- [ ] Hive Metastore escucha en puerto 9083
- [ ] HiveServer2 responde en puerto 10000
- [ ] Web UI de Hive accesible en http://localhost:10002
- [ ] Beeline puede conectarse
- [ ] HDFS accesible desde Hive
- [ ] Directorios `/user/hive/warehouse` creados
- [ ] Schema de metastore inicializado
- [ ] Spark puede usar `enableHiveSupport()`

### Comandos de Verificación

```powershell
# 1. Estado de contenedores
docker-compose ps

# 2. PostgreSQL
docker exec postgres-hive-metastore pg_isready

# 3. Metastore
docker exec hive-metastore nc -z localhost 9083

# 4. HiveServer2
docker exec hive-server beeline -u jdbc:hive2://localhost:10000 -e "SHOW DATABASES;"

# 5. HDFS desde Hive
docker exec hive-server hdfs dfs -ls /user/hive/warehouse
```

## 📊 Puertos Expuestos

| Puerto Host | Puerto Container | Servicio | Descripción |
|-------------|------------------|----------|-------------|
| **5433** | 5432 | PostgreSQL | Base de datos Metastore (puerto alternativo) |
| 9083 | 9083 | Hive Metastore | Servicio Thrift |
| 10000 | 10000 | HiveServer2 | JDBC/Beeline |
| 10002 | 10002 | HiveServer2 | Web UI |

## 🎯 Siguientes Pasos Recomendados

1. **Probar la instalación**
   ```powershell
   .\verify-services.ps1
   ```

2. **Seguir Quick Start**
   - Ver: `docs/HIVE_QuickStart.md`

3. **Crear primeras tablas**
   - Usar ejemplos en `docs/HIVE_Documentacion.md`

4. **Integrar con Spark**
   - Abrir Jupyter: http://localhost:8888
   - Probar `enableHiveSupport()`

5. **Explorar Web UIs**
   - HDFS: http://localhost:9870
   - HiveServer2: http://localhost:10002
   - YARN: http://localhost:8088

## 🐛 Troubleshooting Común

### Error: "Connection refused" en Beeline
**Solución:**
```powershell
docker-compose restart hive-metastore hive-server
docker-compose logs -f hive-server
```

### Error: No puede crear tablas
**Solución:**
```powershell
docker exec hadoop-master hdfs dfs -chmod -R 777 /user/hive/
```

### Error: Schema verification failed
**Solución:**
```powershell
docker exec hive-metastore schematool -dbType postgres -initSchema
```

## 📚 Documentación

- **Guía Completa**: `docs/HIVE_Documentacion.md`
- **Quick Start**: `docs/HIVE_QuickStart.md`
- **README Principal**: `README.md` (actualizado)

---

## ✅ Checklist de Implementación Completada

- [x] Dockerfile de Hive con todas las dependencias
- [x] Script de inicio con manejo de servicios
- [x] Configuración completa hive-site.xml
- [x] PostgreSQL como Metastore (puerto 5433)
- [x] Script de inicialización de BD
- [x] Servicios en docker-compose.yml
- [x] Health checks configurados
- [x] Documentación completa
- [x] Guía de inicio rápido
- [x] Script de verificación
- [x] README actualizado
- [x] Ejemplos de uso

**🎉 Implementación completa y lista para usar!**
