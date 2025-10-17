# 📚 Índice de Documentación

Bienvenido a la documentación del entorno Hadoop + Spark + Hive. Esta guía te ayudará a encontrar rápidamente la información que necesitas.

---

## 🚀 Para Empezar

### Nuevo Usuario
Si eres nuevo en el proyecto, comienza aquí:

1. **[../README.md](../README.md)** - Resumen general del proyecto y arquitectura
2. **[HIVE_QuickStart.md](HIVE_QuickStart.md)** - Guía de inicio rápido de Hive (15 minutos)
3. **[HIVE_Documentacion.md](HIVE_Documentacion.md)** - Documentación completa de Hive

---

## 📖 Documentación por Componente

### Apache Hive

| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| [HIVE_QuickStart.md](HIVE_QuickStart.md) | Guía rápida con ejemplos básicos | 👤 Usuarios |
| [HIVE_Documentacion.md](HIVE_Documentacion.md) | Documentación completa con casos de uso | 👤 Usuarios / 🔧 Desarrolladores |
| [HIVE_Implementacion_Final.md](HIVE_Implementacion_Final.md) | Resumen técnico de la implementación | 🔧 Desarrolladores / 🏗️ DevOps |
| [../hive/README.md](../hive/README.md) | Documentación técnica del contenedor | 🏗️ DevOps |

### HDFS (Hadoop)

| Documento | Descripción | Audiencia |
|-----------|-------------|-----------|
| [HDFS_Permisos_Documentacion.md](HDFS_Permisos_Documentacion.md) | Gestión de permisos y seguridad en HDFS | 👤 Usuarios / 🔧 Desarrolladores |

---

## 🎯 Documentación por Caso de Uso

### Quiero ejecutar consultas SQL sobre datos en HDFS
→ [HIVE_QuickStart.md](HIVE_QuickStart.md) - Sección "Ejemplo Completo"

### Quiero entender la arquitectura de Hive
→ [HIVE_Documentacion.md](HIVE_Documentacion.md) - Sección "Arquitectura"

### Tengo un problema con Hive
→ [HIVE_Documentacion.md](HIVE_Documentacion.md) - Sección "Troubleshooting"  
→ [HIVE_Implementacion_Final.md](HIVE_Implementacion_Final.md) - Sección "Problemas Resueltos"

### Quiero integrar Hive con Spark
→ [HIVE_Documentacion.md](HIVE_Documentacion.md) - Sección "Integración con Spark"

### Quiero modificar la configuración de Hive
→ [../hive/README.md](../hive/README.md) - Sección "Variables de Entorno"  
→ [HIVE_Documentacion.md](HIVE_Documentacion.md) - Sección "Configuración"

### Quiero cargar datos CSV a Hive
→ [HIVE_Documentacion.md](HIVE_Documentacion.md) - Sección "Cargar Datos desde CSV"

### Quiero usar formatos optimizados (Parquet, ORC)
→ [HIVE_Documentacion.md](HIVE_Documentacion.md) - Sección "Formatos de Almacenamiento"

---

## 🔧 Documentación Técnica

### Para Desarrolladores

1. **[HIVE_Implementacion_Final.md](HIVE_Implementacion_Final.md)**
   - Resumen completo de la implementación
   - Problemas encontrados y soluciones
   - Decisiones técnicas justificadas
   - Pruebas realizadas

2. **[../hive/README.md](../hive/README.md)**
   - Detalles del Dockerfile
   - Script de inicio (start-hive.sh)
   - Configuración técnica (hive-site.xml)
   - Health checks y dependencias

3. **[../docker-compose.yml](../docker-compose.yml)**
   - Definición de servicios
   - Redes y volúmenes
   - Variables de entorno

---

## 🐛 Troubleshooting Rápido

### Hive no inicia

1. **Verificar servicios previos:**
   ```powershell
   docker-compose ps
   ```
   - PostgreSQL debe estar "healthy"
   - Hadoop debe estar "healthy"

2. **Ver logs detallados:**
   ```powershell
   docker-compose logs hive-metastore
   docker-compose logs hive-server
   ```

3. **Problemas comunes:**
   - **Java version**: Verificar que use Java 8 (no 11+)
   - **Proxy user**: Verificar configuración en `hadoop/config/core-site.xml`
   - **Timing**: HiveServer2 tarda 2-3 minutos en iniciar

**Documentación detallada:**  
→ [HIVE_Documentacion.md - Sección Troubleshooting](HIVE_Documentacion.md#troubleshooting)

---

## 📊 Ejemplos y Scripts

### Scripts de Verificación
- **[../verify-services.ps1](../verify-services.ps1)** - Verificación automática de todos los servicios
- **[../test-hive.sql](../test-hive.sql)** - Script completo de prueba de Hive

### Notebooks de Ejemplo
- **[../notebooks/spark_example.ipynb](../notebooks/spark_example.ipynb)** - Ejemplo de Spark con Jupyter

---

## 🎓 Recursos de Aprendizaje

### Documentación Oficial

- **Apache Hive**: https://hive.apache.org/
- **HiveQL Language Manual**: https://cwiki.apache.org/confluence/display/Hive/LanguageManual
- **Hadoop**: https://hadoop.apache.org/
- **Apache Spark**: https://spark.apache.org/

### Tutoriales en esta Documentación

1. **Nivel Básico:**
   - [HIVE_QuickStart.md](HIVE_QuickStart.md) - Primeros pasos con Hive

2. **Nivel Intermedio:**
   - [HIVE_Documentacion.md - Casos de Uso](HIVE_Documentacion.md#casos-de-uso)
   - Trabajar con diferentes formatos de archivo
   - Particionamiento de tablas

3. **Nivel Avanzado:**
   - [HIVE_Documentacion.md - Optimización](HIVE_Documentacion.md#optimización-de-consultas)
   - Integración con Spark
   - Bucketing y compresión

---

## 🔄 Actualizaciones de Documentación

| Fecha | Documento | Cambios |
|-------|-----------|---------|
| 2025-10-17 | HIVE_Implementacion_Final.md | ✅ Creación inicial - Resumen completo |
| 2025-10-17 | HIVE_Documentacion.md | ✅ Actualizado troubleshooting con problemas resueltos |
| 2025-10-17 | hive/README.md | ✅ Agregadas notas sobre Java 8 y proxy user |
| 2025-10-17 | README.md | ✅ Agregada sección de resolución de problemas |
| 2025-10-17 | docs/README.md | ✅ Creación de índice de documentación |

---

## 📞 ¿Necesitas Ayuda?

### Orden de búsqueda recomendado:

1. **Buscar en este índice** el caso de uso o problema específico
2. **Consultar [HIVE_Documentacion.md](HIVE_Documentacion.md)** - Troubleshooting y FAQ
3. **Revisar [HIVE_Implementacion_Final.md](HIVE_Implementacion_Final.md)** - Problemas resueltos durante implementación
4. **Ver logs** con `docker-compose logs [servicio]`

### Comandos útiles para diagnóstico:

```powershell
# Estado de todos los servicios
docker-compose ps

# Logs en tiempo real
docker-compose logs -f hive-server

# Verificación automática
.\verify-services.ps1

# Reiniciar un servicio específico
docker-compose restart hive-server
```

---

## ✅ Checklist de Lectura Recomendada

Para un nuevo usuario del sistema:

- [ ] Leer [../README.md](../README.md) - Visión general
- [ ] Seguir [HIVE_QuickStart.md](HIVE_QuickStart.md) - Primer contacto con Hive
- [ ] Ejecutar `.\verify-services.ps1` para validar el entorno
- [ ] Probar el script [../test-hive.sql](../test-hive.sql)
- [ ] Explorar [HIVE_Documentacion.md](HIVE_Documentacion.md) según necesidades

Para un desarrollador que va a modificar el sistema:

- [ ] Leer [HIVE_Implementacion_Final.md](HIVE_Implementacion_Final.md) completo
- [ ] Revisar [../hive/README.md](../hive/README.md) - Detalles técnicos
- [ ] Estudiar [../docker-compose.yml](../docker-compose.yml)
- [ ] Revisar [HIVE_Documentacion.md - Troubleshooting](HIVE_Documentacion.md#troubleshooting)
- [ ] Entender las decisiones técnicas (Java 8, proxy user, etc.)

---

**Última actualización:** 17 de octubre de 2025  
**Versión:** 1.0
