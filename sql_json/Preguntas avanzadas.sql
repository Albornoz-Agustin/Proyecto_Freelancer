/* 
	Ejercicios Avanzados de SQL
1- Ranking de Trabajadores Más Rentables
Lista los 10 trabajadores con mayores ganancias totales, mostrando su nombre y la cantidad de proyectos completados.

2- Relación entre Gasto en Marketing y Ganancias
Calcula la correlación entre el gasto_marketing y las ganancias_usd de cada trabajador.

3- Retención de Clientes
Encuentra el porcentaje de clientes que han recontratado a un freelancer al menos una vez.

4- Comparación de Plataformas
Muestra el promedio de ganancias por plataforma (id_plataforma), ordenado de mayor a menor.

5- Trabajadores con Mejor Calificación Promedio
Lista los trabajadores que tienen una calificación promedio del cliente mayor a 4.5 y han completado al menos 5 trabajos.

6- Distribución de Tipos de Proyecto
Cuenta cuántos trabajos corresponden a cada tipo de proyecto (tipo_proyecto) y ordénalos de mayor a menor.

7- Duración Promedio de los Trabajos por Región
Calcula la duración promedio (dias_duracion) de los proyectos en cada región del cliente.

8- Clientes con Mayor Gasto Total
Identifica a los 5 clientes que han gastado más en total en la plataforma.

9- Detección de Anomalías
Encuentra freelancers con ganancias anormalmente altas o bajas comparadas con el promedio de la plataforma.

10- Simulación de Aumento de Tarifas
Calcula cuánto aumentaría la ganancia total si todos los trabajadores subieran su tarifa por hora en un 10%.

*/

-- 1 Ranking de trabajadores más rentables 
-- Lista los 10 trabajadores con mayores ganancias totales, mostrando id y la cantidad de proyectos completados.

SELECT 
	id_freelancer, 
    total_ganado,
    trabajo_completado
		FROM (
			SELECT  fr.id_freelancer,
					f.trabajo_completado,
					ROUND(SUM(f.ganancias_usd / 100),2) AS total_ganado  
				FROM freelancersdb.fact_trabajos f  
					JOIN freelancersdb.dim_freelancer fr ON f.id_freelancer = fr.id_freelancer
			GROUP BY fr.id_freelancer, 
					 f.trabajo_completado
			ORDER BY total_ganado DESC  
			LIMIT 10
) AS top_trabajador;

-- ** La subconsulta es tabular, ya que se hace desde el FROM y quiero que el dato que me devuelva sea una tabla **


-- 2 Relación entre Gasto en Marketing y Ganancias
-- Calcula el margen de ganancia entre el gasto_marketing y las ganancias_usd de cada trabajador.

SELECT
	fr.id_freelancer AS trabajador,
    fr.nombre,
    fr.apellido,
	fr.categoria_trabajo AS categoria,
    f.ganancias_usd,
    fr.gasto_marketing,
	SUM(f.ganancias_usd) - SUM(fr.gasto_marketing) AS margen_ganancia 
		FROM freelancersdb.fact_trabajos f 
			JOIN freelancersdb.dim_freelancer fr ON f.id_freelancer = fr.id_freelancer
        GROUP BY trabajador, fr.nombre, fr.apellido, categoria, f.ganancias_usd, fr.gasto_marketing
        ORDER BY margen_ganancia DESC;

-- 3 Porcentaje(%) de Tasa exito
-- Encuentra el porcentaje promedio de las tasa de exito por cada nivel de experiencia.


SELECT 
		nivel_experiencia AS categoria_exp,
		AVG(tasa_exito) AS promedio_exito
	FROM freelancersdb.dim_freelancer
	GROUP BY 
		categoria_exp
	ORDER BY 
		promedio_exito;

-- 4 Comparación de Plataformas
-- Muestra el promedio de ganancias por plataforma (id_plataforma), ordenado de mayor a menor.

SELECT 
		p.nombre AS plataforma,
		AVG(t.ganancias_usd) AS promedio_ganancias
	FROM freelancersdb.fact_trabajos t
    JOIN freelancersdb.dim_plataformas p ON t.id_plataforma = p.id_plataforma
	GROUP BY 
		plataforma
	ORDER BY 
		promedio_ganancias DESC;
        
-- 5 Trabajadores con Mejor Calificación Promedio
-- Lista los trabajadores que tienen una calificación promedio del cliente mayor a 4.5 y han completado al menos 5 trabajos.

SELECT 
	id_freelancer,
	calificacion_cliente,
    trabajo_completado
FROM freelancersdb.fact_trabajos
WHERE calificacion_cliente >= 4.5
	AND trabajo_completado >= 5
LIMIT 5;

-- 6 Distribución de Tipos de Proyecto
-- Cuenta cuántos trabajos corresponden a cada tipo de proyecto (tipo_proyecto).
    
SELECT
	COUNT(*) AS conteo,
    tipo_proyecto AS categoria
FROM freelancersdb.fact_trabajos
GROUP BY categoria
ORDER BY conteo DESC;


-- 7- Duración Promedio de los Trabajos por Región
-- Calcula la duración promedio (dias_duracion) de los proyectos en cada región del cliente.

SELECT
	c.region AS region,
    AVG(dias_duracion) AS promedio_duracion
FROM freelancersdb.fact_trabajos t
JOIN freelancersdb.dim_clientes c ON t.id_cliente = c.id_cliente
GROUP BY region
ORDER BY promedio_duracion DESC;


-- 8- Identifica a las 3 categorias de trabajo más han ganado y nivel de experiencia

SELECT
	fr.categoria_trabajo AS categoria,
    fr.nivel_experiencia AS experiencia,
    SUM(f.ganancias_usd) AS ganancia_bruta
FROM freelancersdb.fact_trabajos f
	JOIN freelancersdb.dim_freelancer fr ON f.id_freelancer = fr.id_freelancer
GROUP BY 
	categoria, experiencia
ORDER BY
	ganancia_bruta DESC;
    
    
-- 9- Detección de Anomalías
-- Encuentra categorias de trabajo con ganancias anormalmente altas o bajas comparadas con el promedio de la plataforma.


SELECT
	fr.categoria_trabajo AS categoria,
    p.Nombre AS nombre,
    AVG(f.ganancias_usd) AS prom_ganan,
    MIN(f.ganancias_usd) AS min_ganan,
    MAX(f.ganancias_usd) AS max_ganan
FROM freelancersdb.fact_trabajos f
JOIN freelancersdb.dim_freelancer fr ON f.id_freelancer = fr.id_freelancer
JOIN freelancersdb.dim_plataformas p ON f.id_plataforma = p.id_plataforma
GROUP BY
	categoria,
    nombre
ORDER BY
	prom_ganan DESC;


-- 10 Calcula cuánto aumentaría la ganancia total si todos los trabajadores subieran su tarifa por hora en un 10%.

SELECT
	fr.categoria_trabajo AS categoria,
    SUM(ganancias_usd) AS ganancias_actuales, 
    SUM(ganancias_usd * 1.1) AS ganancias_con_aumento
FROM freelancersdb.fact_trabajos f
JOIN freelancersdb.dim_freelancer fr ON f.id_freelancer = fr.id_freelancer
GROUP BY
	categoria
ORDER BY
	ganancias_con_aumento DESC;
