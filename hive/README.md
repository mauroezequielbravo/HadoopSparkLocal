# Apache Hive Configuration

Esta carpeta contiene la configuración de Apache Hive para el entorno Docker.

## 📁 Estructura

```
hive/
├── Dockerfile              # Imagen Docker con Hive 3.1.3
├── start-hive.sh          # Script de inicio
├── config/
│   └── hive-site.xml      # Configuración de Hive
└── README.md              # Este archivo
```

## 🔧 Componentes

### Dockerfile

Construye una imagen con:
- **Ubuntu 22.04** como base
- **OpenJDK 8** para Java ⚠️ **IMPORTANTE: Hive 3.1.3 NO es compatible con Java 11+**
- **Hadoop 3.3.6** (cliente para HDFS - requerido para comandos `hdfs`)
- **Hive 3.1.3** (Metastore y HiveServer2)
- **PostgreSQL JDBC Driver 42.7.1**
- Corrección de conflictos de dependencias (Guava)

> **Nota sobre Hadoop:** Hive requiere los binarios y bibliotecas de Hadoop para acceder a HDFS. No es una duplicación del servicio hadoop-master, sino una instalación cliente necesaria.

### start-hive.sh

Script de inicio que:
- Espera a que PostgreSQL esté disponible
- Espera a que Hadoop HDFS esté listo
- Verifica conectividad con HDFS
- Crea directorios necesarios en HDFS (`/user/hive/warehouse`, `/tmp/hive`)
- Inicializa el schema del Metastore (solo en primer arranque)
- Inicia el servicio apropiado según `$HIVE_SERVICE`:
  - `metastore`: Hive Metastore Service (puerto 9083)
  - `hiveserver2`: HiveServer2 (puertos 10000, 10002)

### config/hive-site.xml

Configuración completa de Hive con:
- **Conexión a PostgreSQL**: `jdbc:postgresql://postgres:5432/metastore`
- **URI del Metastore**: `thrift://hive-metastore:9083`
- **Warehouse**: `/user/hive/warehouse` en HDFS
- **HiveServer2**: Puerto 10000 (JDBC), 10002 (Web UI)
- **HDFS**: Conexión a `hdfs://hadoop-master:9000`
- **Seguridad**: Autenticación deshabilitada (desarrollo)
- **Performance**: Schema auto-create, particiones dinámicas habilitadas

## 🚀 Uso

### En docker-compose.yml

Se crean dos servicios basados en esta imagen:

```yaml
# Metastore Service
hive-metastore:
  build: ./hive
  environment:
    - HIVE_SERVICE=metastore
  ports:
    - "9083:9083"

# HiveServer2 Service
hive-server:
  build: ./hive
  environment:
    - HIVE_SERVICE=hiveserver2
  ports:
    - "10000:10000"  # JDBC
    - "10002:10002"  # Web UI
```

### Construir la imagen

```powershell
docker-compose build hive-metastore hive-server
```

### Iniciar servicios

```powershell
docker-compose up -d hive-metastore hive-server
```

## 🔍 Verificación

### Logs del Metastore
```powershell
docker-compose logs -f hive-metastore
```

### Logs de HiveServer2
```powershell
docker-compose logs -f hive-server
```

### Conectar con Beeline
```powershell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

### Verificar directorios en HDFS
```powershell
docker exec hadoop-master hdfs dfs -ls /user/hive/warehouse
```

## ⚙️ Configuración Personalizada

### Modificar hive-site.xml

Edita `config/hive-site.xml` y reinicia:

```powershell
docker-compose restart hive-metastore hive-server
```

### Cambiar versión de Hive

Modifica en `Dockerfile`:
```dockerfile
ENV HIVE_VERSION=3.1.3
```

### Agregar JARs adicionales

Copia JARs a `/opt/hive/lib/` en el Dockerfile:
```dockerfile
COPY mi-conector.jar ${HIVE_HOME}/lib/
```

## 🐛 Troubleshooting

### Error: "FAILED: SemanticException ... database does not exist"

**Causa**: Base de datos no creada
**Solución**:
```sql
CREATE DATABASE nombre_db;
USE nombre_db;
```

### Error: "Connection refused" a Metastore

**Causa**: Metastore no está corriendo o no inició correctamente
**Solución**:
```powershell
docker-compose logs hive-metastore
docker-compose restart hive-metastore
docker exec hive-metastore nc -z localhost 9083
```

### Error: "java.net.ConnectException: Connection refused" a PostgreSQL

**Causa**: PostgreSQL no está disponible
**Solución**:
```powershell
docker-compose ps postgres
docker-compose logs postgres
docker exec postgres-hive-metastore pg_isready
```

### Error: "Permission denied" en HDFS

**Causa**: Permisos incorrectos en directorios
**Solución**:
```powershell
docker exec hadoop-master hdfs dfs -chmod -R 777 /user/hive/
docker exec hadoop-master hdfs dfs -chmod -R 777 /tmp/hive
```

### Error: Guava version conflict

**Solución**: Ya resuelto en el Dockerfile
```dockerfile
RUN rm ${HIVE_HOME}/lib/guava-19.0.jar \
    && cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/
```

## 📚 Referencias

- [Apache Hive Documentation](https://hive.apache.org/)
- [Hive Configuration Properties](https://cwiki.apache.org/confluence/display/Hive/Configuration+Properties)
- [HiveServer2 Clients](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients)

## 🔗 Puertos

| Puerto | Servicio | Descripción |
|--------|----------|-------------|
| 9083 | Metastore | Thrift service |
| 10000 | HiveServer2 | JDBC/Beeline |
| 10002 | HiveServer2 | Web UI |

## 📝 Notas Importantes

- La imagen base es compartida por ambos servicios (metastore y hiveserver2)
- El servicio a iniciar se determina por la variable `HIVE_SERVICE`
- PostgreSQL debe estar disponible antes de iniciar el Metastore
- HDFS debe estar disponible antes de iniciar cualquier servicio de Hive
- Los health checks verifican disponibilidad de puertos con `nc -z`

## ⚠️ Problemas Conocidos y Soluciones

### Java Version
**Problema:** ClassCastException al usar Java 11+  
**Solución:** Usar Java 8 (OpenJDK 8). Hive 3.1.3 no es compatible con Java 11+.

### User Impersonation
**Problema:** `User: root is not allowed to impersonate anonymous`  
**Solución:** Configurar proxy user en `hadoop/config/core-site.xml`:
```xml
<property>
    <name>hadoop.proxyuser.root.groups</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.root.hosts</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.root.users</name>
    <value>*</value>
</property>
```

### HiveServer2 Initialization
**Nota:** HiveServer2 puede tardar 2-3 minutos en iniciar completamente. Esto es normal. El health check tiene un `start_period` de 120 segundos para permitir esta inicialización.

Para más detalles sobre troubleshooting, consultar `docs/HIVE_Documentacion.md`

---

Para documentación completa de uso, ver: `../docs/HIVE_Documentacion.md`
