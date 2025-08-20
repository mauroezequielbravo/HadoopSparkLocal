# Documentación: Gestión de Permisos HDFS y Creación de Directorios

## 📋 Problema Común: Permission Denied en HDFS

### Error Típico
```
Permission denied: user=dr.who, access=WRITE, inode="/":root:supergroup:drwxr-xr-x
```

### Causa
- El directorio raíz `/` de HDFS pertenece a `root:supergroup`
- Tiene permisos `755` (solo el propietario puede escribir)
- Los usuarios no privilegiados no pueden escribir en la raíz

## 🛠️ Solución Recomendada para Producción

### 1. Verificar Estado Actual
```bash
# Acceder al contenedor/servidor Had

# Verificar permisos del directorio raíz
hdfs dfs -ls /
hdfs dfs -getfacl /

# Verificar usuario actual
whoami
```

### 2. Crear Directorio de Usuario (Recomendado)
```bash
# Crear directorio específico para el usuario
hdfs dfs -mkdir -p /user/[NOMBRE_USUARIO]

# Asignar propiedad al usuario
hdfs dfs -chown [NOMBRE_USUARIO]:supergroup /user/[NOMBRE_USUARIO]

# Establecer permisos apropiados
hdfs dfs -chmod 755 /user/[NOMBRE_USUARIO]
```

### 3. Crear Carpeta de Proyecto
```bash
# Crear carpeta específica del proyecto
hdfs dfs -mkdir -p /user/[NOMBRE_USUARIO]/[NOMBRE_PROYECTO]

# Asignar propiedad
hdfs dfs -chown [NOMBRE_USUARIO]:supergroup /user/[NOMBRE_USUARIO]/[NOMBRE_PROYECTO]

# Establecer permisos
hdfs dfs -chmod 755 /user/[NOMBRE_USUARIO]/[NOMBRE_PROYECTO]
```

## 📝 Ejemplo Práctico

### Para usuario 'dr.who' y proyecto 'LakeHousePruebas'
```bash
# Paso 1: Crear directorio de usuario
hdfs dfs -mkdir -p /user/dr.who
hdfs dfs -chown dr.who:supergroup /user/dr.who
hdfs dfs -chmod 755 /user/dr.who

# Paso 2: Crear carpeta del proyecto
hdfs dfs -mkdir -p /user/dr.who/LakeHousePruebas
hdfs dfs -chown dr.who:supergroup /user/dr.who/LakeHousePruebas
hdfs dfs -chmod 755 /user/dr.who/LakeHousePruebas

# Paso 3: Verificar estructura
hdfs dfs -ls -R /user
hdfs dfs -getfacl /user/dr.who/LakeHousePruebas
```

## 🔄 Comandos de Gestión de Permisos

### Cambiar Propietario Recursivamente
```bash
# Cambiar propietario de un directorio y todos sus subdirectorios
hdfs dfs -chown -R [USUARIO]:[GRUPO] [RUTA]

# Ejemplo: Cambiar todas las carpetas de LakeHouse a dr.who
hdfs dfs -chown -R dr.who:supergroup /user/dr.who/LakeHouse/
```

**Descripción**: El comando `chown -R` cambia recursivamente el propietario de un directorio y todos sus contenidos. Útil cuando se crean carpetas desde notebooks que ejecutan como root y necesitan pertenecer al usuario específico.

### Cambiar Permisos Recursivamente
```bash
# Cambiar permisos de un directorio y todos sus subdirectorios
hdfs dfs -chmod -R [PERMISOS] [RUTA]

# Ejemplo: Dar permisos de lectura/escritura recursivamente
hdfs dfs -chmod -R 755 /user/dr.who/LakeHouse/
```

**Descripción**: El comando `chmod -R` cambia recursivamente los permisos de acceso. Los permisos 755 permiten lectura/escritura/ejecución al propietario y lectura/ejecución al grupo y otros.

### Verificar Permisos Específicos
```bash
# Listar permisos de un directorio específico
hdfs dfs -ls -d [RUTA]

# Ejemplo: Ver permisos del directorio staging
hdfs dfs -ls -d /user/dr.who/LakeHouse/staging
```

**Descripción**: El comando `ls -d` muestra información solo del directorio especificado (no su contenido), útil para verificar propietario y permisos de una carpeta específica.

## 🌐 Configuración WebHDFS y CORS

### Habilitar WebHDFS
Para permitir cargas de archivos desde la interfaz web, agregar en `hdfs-site.xml`:
```xml
<property>
    <name>dfs.webhdfs.enabled</name>
    <value>true</value>
</property>
<property>
    <name>dfs.datanode.http.address</name>
    <value>0.0.0.0:9864</value>
</property>
<property>
    <name>dfs.datanode.hostname</name>
    <value>localhost</value>
</property>
```

### Configurar CORS
Para resolver problemas de carga desde navegador, agregar en `core-site.xml`:
```xml
<property>
    <name>hadoop.http.cross-origin.enabled</name>
    <value>true</value>
</property>
<property>
    <name>hadoop.http.cross-origin.allowed-origins</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.http.cross-origin.allowed-methods</name>
    <value>GET,POST,HEAD,PUT,DELETE</value>
</property>
<property>
    <name>hadoop.http.cross-origin.allowed-headers</name>
    <value>X-Requested-With,Content-Type,Accept,Origin</value>
</property>
```

**Nota**: Después de modificar estas configuraciones, es necesario reiniciar los servicios de Hadoop.

## 🔧 Comandos de Verificación

### Verificar Servicios HDFS
```bash
# Ver procesos Java ejecutándose
jps

# Verificar estado de HDFS
hdfs dfsadmin -report

# Verificar conectividad
hdfs dfs -ls /

# Probar WebHDFS
curl -i 'http://localhost:9870/webhdfs/v1/user/dr.who/LakeHouse/staging?op=LISTSTATUS'
```

### Verificar Permisos
```bash
# Listar con permisos detallados
hdfs dfs -ls -la /user/[USUARIO]

# Ver ACLs completas
hdfs dfs -getfacl /user/[USUARIO]/[PROYECTO]

# Verificar espacio disponible
hdfs dfs -df -h
```

## 🌐 Acceso desde Interfaz Web

### HDFS Web UI (Puerto 9870)
1. Abrir navegador: `http://localhost:9870`
2. Ir a `Utilities` → `Browse the file system`
3. Navegar a `/user/[USUARIO]/[PROYECTO]`
4. Usar botón "Upload Files" para subir archivos

### Puertos Importantes
- **HDFS NameNode UI**: 9870
- **YARN ResourceManager**: 8088
- **Spark Master UI**: 8080
- **Spark Application UI**: 4040
- **Jupyter Notebook**: 8888

## ⚠️ Alternativas (Solo para Desarrollo)

### Opción 1: Cambiar Permisos Globales
```bash
# ⚠️ SOLO PARA DESARROLLO - No recomendado en producción
hdfs dfs -chmod 777 /
```

### Opción 2: Usar Usuario Root
```bash
# Cambiar al usuario root
su - root
# O ejecutar comandos específicos como root
sudo -u root hdfs dfs -mkdir /mi_directorio
```

## 🔒 Mejores Prácticas de Seguridad

### 1. Estructura de Directorios
```
/
├── user/
│   ├── usuario1/
│   │   ├── proyecto1/
│   │   └── proyecto2/
│   └── usuario2/
│       └── datos/
├── shared/
│   └── common_data/
└── tmp/
    └── staging/
```

### 2. Permisos Recomendados
- **Directorio raíz (/)**: `755` (root:supergroup)
- **Directorio usuario (/user/username)**: `755` (username:supergroup)
- **Proyectos específicos**: `755` (username:supergroup)
- **Datos compartidos**: `775` (root:shared_group)

### 3. Comandos de Gestión
```bash
# Crear usuario nuevo
hdfs dfs -mkdir -p /user/nuevo_usuario
hdfs dfs -chown nuevo_usuario:supergroup /user/nuevo_usuario
hdfs dfs -chmod 755 /user/nuevo_usuario

# Crear directorio compartido
hdfs dfs -mkdir -p /shared/common
hdfs dfs -chown root:shared_group /shared/common
hdfs dfs -chmod 775 /shared/common

# Limpiar directorio temporal
hdfs dfs -rm -r /tmp/*
```

## 🚨 Solución de Problemas

### Problema: DataNode no responde
```bash
# Verificar logs
tail -f $HADOOP_HOME/logs/hadoop-*-datanode-*.log

# Reiniciar servicios
$HADOOP_HOME/sbin/stop-dfs.sh
$HADOOP_HOME/sbin/start-dfs.sh
```

### Problema: Espacio insuficiente
```bash
# Verificar espacio en disco
df -h

# Verificar espacio HDFS
hdfs dfs -df -h

# Limpiar archivos temporales
hdfs dfs -rm -r /tmp/*
```

### Problema: Usuario no existe
```bash
# Crear usuario en el sistema (si es necesario)
useradd -m nuevo_usuario

# Crear directorio HDFS
hdfs dfs -mkdir -p /user/nuevo_usuario
hdfs dfs -chown nuevo_usuario:supergroup /user/nuevo_usuario
```

## 📚 Referencias

- [Documentación oficial de Hadoop HDFS](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsUserGuide.html)
- [Guía de permisos HDFS](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsPermissionsGuide.html)
- [Comandos HDFS](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HDFSCommands.html)

---

**Nota**: Esta documentación está basada en Hadoop 3.3.6 y puede requerir ajustes para otras versiones.