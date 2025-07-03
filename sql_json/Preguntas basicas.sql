-- 1 Pregunta: ¿Cuáles son los trabajadores y sus tarifas por hora?

SELECT
	id_freelancer,
    tarifa_por_hora
FROM dim_freelancer
ORDER BY tarifa_por_hora DESC;

-- 2 Pregunta: ¿Top 5 de cuantos trabajadores han completado más trabajos?

SELECT
	COUNT(*) AS trabajadores,
    trabajo_completado
FROM fact_trabajos
GROUP BY trabajo_completado
ORDER BY trabajo_completado DESC
LIMIT 5;


-- 3 Listar los 5 trabajadores con la mayor tasa de éxito.

SELECT
	id_freelancer,
    tasa_exito
FROM dim_freelancer
ORDER BY tasa_exito DESC
LIMIT 5;

SHOW ERRORS;

-- 4 Consultas con JOIN // Mostrar los trabajos realizados con el id del trabajador y la plataforma.

SELECT 
	t.nombre,
    p.nombre AS plataforma, 
    f.tipo_proyecto AS proyecto,
    f.ganancias_usd AS ganancias
FROM freelancersdb.fact_trabajos f  
JOIN freelancersdb.dim_freelancer t ON f.id_freelancer = t.id_freelancer  
JOIN freelancersdb.dim_plataformas p ON f.id_plataforma = p.id_plataforma
GROUP BY plataforma,
		 proyecto,
         ganancias,
         t.nombre
ORDER BY ganancias DESC
LIMIT 10;

-- 5 ¿Cuál plaforma fue la que género más dinero?.

SELECT
	p.nombre,
    SUM(t.ganancias_usd ) AS total_ganancias
FROM freelancersdb.fact_trabajos t
JOIN freelancersdb.dim_plataformas p ON t.id_plataforma = p.id_plataforma
GROUP BY p.nombre
ORDER BY total_ganancias DESC;

-- Upwork $2.112.162,00

-- 6 ¿Dónde se concentran mayormente los clientes de los trabajos solicitados?

SELECT
	c.region AS nombre,
    COUNT(t.id_cliente) AS conteo_clientes
FROM freelancersdb.fact_trabajos t
JOIN freelancersdb.dim_clientes c ON t.id_cliente = c.id_cliente
GROUP BY c.region	
ORDER BY conteo_clientes DESC
LIMIT 3;

-- 7 Obtener la calificación promedio dada por los clientes.

SELECT
	c.region AS nombre,
    AVG(t.calificacion_cliente) AS promedio_calificiación
FROM freelancersdb.fact_trabajos t
JOIN freelancersdb.dim_clientes c ON t.id_cliente = c.id_cliente
GROUP BY nombre
ORDER BY promedio_calificiación DESC;

-- Middle East 3.704742 promedio

-- 8 Mostrar la cantidad de trabajos realizados por cada tipo de proyecto.

SELECT
	tipo_proyecto,
    COUNT(*) AS total_trabajos_r
FROM freelancersdb.fact_trabajos
GROUP BY tipo_proyecto
ORDER BY total_trabajos_r DESC;


-- 9 Encontrar trabajadores con más del 80% de éxito y una tarifa superior a $30 por hora

SELECT
	id_freelancer,
    tasa_exito,
    tarifa_por_hora
FROM freelancersdb.dim_freelancer
	WHERE 
		tasa_exito > 80 AND tarifa_por_hora > 30
ORDER BY tasa_exito DESC, id_freelancer;


-- 10 Mostrar el trabajador con más ganancias totales. (Subconsulta)

SELECT 
	id_freelancer, total_ganado 
		FROM (
			SELECT t.id_freelancer, 
					SUM(f.ganancias_usd) AS total_ganado  
				FROM freelancersdb.fact_trabajos f  
				JOIN freelancersdb.dim_freelancer t ON f.id_freelancer = t.id_freelancer  
			GROUP BY t.id_freelancer
			ORDER BY total_ganado DESC  
			LIMIT 1
) AS top_trabajador;

-- 11 Calcular el gasto total en marketing de los freelancers que han ganado más de $5000 en total.

SELECT
	f.id_freelancer AS trabajador,
    SUM(fr.gasto_marketing) AS gasto_total,
    SUM(f.ganancias_usd) AS ganancia_total
FROM freelancersdb.fact_trabajos f
	JOIN freelancersdb.dim_freelancer fr ON f.id_freelancer = fr.id_freelancer
GROUP BY 
	trabajador  
HAVING 
	ganancia_total > 5000  
ORDER BY ganancia_total DESC;



