CREATE VIEW vista_freelancer_ganancias AS
	SELECT 
		f.id_freelancer,
		f.apellido,
		f.nombre,
		f.tarifa_por_hora,
		COALESCE(SUM(ft.ganancias_usd), 0) AS total_ganancias,
		COUNT(ft.id_trabajo) AS cantidad_trabajos,
		MIN(ft.Fecha_inicio) AS primer_trabajo,
		MAX(ft.Fecha_finalizacion) AS ultimo_trabajo
	FROM dim_freelancer f
		LEFT JOIN fact_trabajos ft ON f.id_freelancer = ft.id_freelancer
		GROUP BY 
			f.id_freelancer, f.apellido, f.nombre, f.tarifa_por_hora;