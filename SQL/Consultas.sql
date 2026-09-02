--- PANORAMA GENERAL
--1 ¿Cuál es el precio promedio de las propiedades?
SELECT AVG(TRY_CAST(price AS DECIMAL(15,2))) AS precio_promedio
FROM dbo.[realtor-data];

--2. ¿Cuál es el precio mediano de las propiedades?
SELECT DISTINCT
       PERCENTILE_CONT(0.5) 
       WITHIN GROUP (ORDER BY TRY_CAST(price AS DECIMAL(15,2))) 
       OVER () AS precio_mediano
FROM dbo.[realtor-data];

--- ANÁLISIS GEOGRÁFICO
--3. ¿Qué ciudades tienen las propiedades más caras?
SELECT DISTINCT city AS Ciudad, 
       COUNT(*) AS 'Cantidad de propiedades',
	   CAST(AVG(TRY_CAST(price AS DECIMAL(15,2))) AS DECIMAL(15,2)) AS Promedio
FROM dbo.[realtor-data]
GROUP BY city
ORDER BY  Promedio DESC;

--4. ¿Cuál es el precio promedio por estado?
SELECT state AS Estado,
       CAST(AVG(TRY_CAST(price AS DECIMAL(15,2))) AS DECIMAL(15,2)) AS Promedio
FROM dbo.[realtor-data]
GROUP BY state
ORDER BY Promedio DESC;

--5. ¿Dónde existe mayor cantidad de propiedades?
SELECT city AS Ciudad,
       COUNT(*) AS Cantidad
FROM dbo.[realtor-data]
GROUP BY city
ORDER BY Cantidad DESC;

--6. ¿Qué porcentaje de las propiedades corresponde a cada estado?
SELECT state AS Estado,   
       COUNT(*) AS Cantidad,  
       CONCAT(
           CAST(
               (COUNT(*) * 100.0 /
               (SELECT COUNT(*) 
                FROM dbo.[realtor-data]))
               AS DECIMAL(10,4)
           ),
           '%'
       ) AS Porcentaje
FROM dbo.[realtor-data]  
GROUP BY state;

--- CARACTERÍSTICAS DE LAS PROPIEDADES
--7. ¿Cómo cambia el precio según número de dormitorios?
SELECT TRY_CAST(bed AS INT) AS 'N° de Habitaciones',
       AVG(TRY_CAST(price AS DECIMAL(15,2)))
FROM dbo.[realtor-data]
GROUP BY bed 
ORDER BY bed ASC;

-- 8. ¿Qué relación existe entre tamaño de la casa y precio?
SELECT 
    house_size AS 'Tamaño',
    price AS 'Precio'
FROM dbo.[realtor-data]
WHERE house_size IS NOT NULL
  AND price IS NOT NULL
ORDER BY house_size ASC;

--- ANÁLISIS DE PRECIOS
--9. ¿Cuáles son las 10 propiedades más caras?
SELECT TOP 10
       street,
       TRY_CAST(price AS DECIMAL(15,2)) AS Precio
FROM dbo.[realtor-data]
ORDER BY Precio DESC;

--10. ¿Cuál es la propiedad más cara de cada ciudad?
SELECT city,
       street,
       TRY_CAST(price AS DECIMAL(15,2)) AS Precio
FROM dbo.[realtor-data] AS p
WHERE TRY_CAST(price AS DECIMAL(15,2)) =
      (SELECT MAX(TRY_CAST(price AS DECIMAL(15,2)))
       FROM dbo.[realtor-data]
       WHERE city = p.city);

--11. ¿Qué propiedades están sobre el precio promedio de su ciudad?
SELECT city,
       price
FROM dbo.[realtor-data] AS p
WHERE TRY_CAST(price AS DECIMAL(15,2)) > (
                SELECT AVG(TRY_CAST(price AS DECIMAL(15,2))) AS 'Precio promedio'
                FROM dbo.[realtor-data]
				WHERE city = p.city);

--12. ¿Cuánto se aleja cada propiedad del precio promedio de su zona?
SELECT city,
       Precio,
       Promedio,
	   Precio - Promedio AS Diferencia
FROM
(
    SELECT city,
	       TRY_CAST(price AS DECIMAL(15,2)) AS Precio,
		   AVG(TRY_CAST(price AS DECIMAL(15,2))) OVER(PARTITION BY city) AS Promedio
	FROM dbo.[realtor-data]
) AS Datos;

---RANKING Y ANÁLISIS AVANZADO
--13. ¿Cuál es el ranking de propiedades por precio dentro de cada ciudad?
SELECT city,
       price,
       RANK() OVER(PARTITION BY city ORDER BY TRY_CAST(price AS DECIMAL(15,2)) DESC ) AS 'Ranking'
FROM dbo.[realtor-data];

--14. ¿Cuáles son las 5 ciudades que mejor combinan alta oferta y precios elevados?
WITH DatosCiudad AS
(
    SELECT city AS Ciudad,
           COUNT(*) AS N_de_Propiedades,
           AVG(TRY_CAST(price AS DECIMAL(15,2))) AS Promedio
    FROM dbo.[realtor-data]
    GROUP BY city
)
SELECT TOP 5 *
FROM DatosCiudad
WHERE N_de_Propiedades > (SELECT AVG(N_de_Propiedades)
                FROM DatosCiudad) 
  AND Promedio > (SELECT AVG(TRY_CAST(price AS DECIMAL(15,2)))
                FROM dbo.[realtor-data])
ORDER BY N_de_Propiedades DESC, Promedio DESC;

---ANÁLISIS TEMPORAL
--15. ¿Cómo evolucionan los precios en el tiempo?
SELECT Año,
       Promedio,
	   LAG(Promedio) OVER(ORDER BY Año) AS 'Promedio Anterior'
FROM (SELECT  YEAR(TRY_CAST(prev_sold_date AS DATE)) AS Año,
              AVG(TRY_CAST(price AS DECIMAL(15,2))) AS Promedio         
      FROM dbo.[realtor-data]
	  GROUP BY YEAR(TRY_CAST(prev_sold_date AS DATE))
     ) AS Datos 
ORDER BY Año ASC;	
