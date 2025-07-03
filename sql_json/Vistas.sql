CREATE VIEW vista_ganancias_por_plataforma AS
	SELECT 
		p.Nombre AS plataforma,
		f.categoria_trabajo,
		SUM(ft.ganancias_usd) AS total_ganancias,
		AVG(ft.calificacion_cliente) AS promedio_calificacion
	FROM fact_trabajos ft
		JOIN dim_freelancer f ON ft.id_freelancer = f.id_freelancer
		JOIN dim_plataformas p ON ft.id_plataforma = p.id_plataforma
	GROUP BY 
		p.Nombre, f.categoria_trabajo;