# Proyecto de Análisis de Datos Inmobiliaria (SQL)

## Descripción del proyecto
<p> Este proyecto analiza un dataset de un inmobiliario sintético (bd_inmobiliaria.db) compuesto por una tabla:  realtor-data. El objetivo es responder preguntas de negocio utilizando SQL Intermedio (SELECT, GROUP BY,HAVING, ORDER BY, funciones de agregación, funciones de ventana, subconsultas).</p>

## Herramientas utilizadas:
<p><strong>-Motor de base de datos:</strong> SQL SERVER (desarrollo local)</p>
<p><strong>-Dataset:</strong> USA Real Estate Dataset (Kaggle)</p>
<p><strong>-Lenguaje:</strong> SQL estándar</p>

## Preguntas resultas

### **1. ¿Cuál es el precio promedio de las propiedades?**

```sql
SELECT AVG(TRY_CAST(price AS DECIMAL(15,2))) AS precio_promedio
FROM dbo.[realtor-data];
```
