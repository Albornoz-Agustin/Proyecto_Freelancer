/*
	PARA EMPEZAR CON NUESTRA BASE DE DATOS VAMOS A CREARLA EN PRIMERA INSTACIA,
    LA CUAL VA A CONTENER 4 TABLAS CON UN MODELO ER (ENTIDAD-RELACIÓN).
*/

-- CREATE DATABASE prueba;

CREATE DATABASE FreelancersDB;

-- UTILIZAMOS LA FUNCIÓN USE PARA PODER LLAMAR A LA BASE DE DATOS

USE FreelancersDB;

/*  
	1-	CREACIÓN DE LA TABLA DE DIMENSIÓN "dim_freelancer", LA CUAL VA A ESTAR TRADUCIDA SUS COLUMNAS AL ESPAÑOL PARA
		POSTERIORMENTE INCORPORAR LOS DATOS Y TRADUCIRLOS.
    2-	EN LA COLUMNA DE "categoria_trabajo" Y "nivel_experiencia" SE UTILIZO UN CASE PARA CUANDO COINCIDA CON UNA VALOR DE TEXTO ME DEVUELVA OTRO Y TRADUCIDO
    3- 	SE PUDO VERIFICAR QUE LA COLUMNA "id_trabajador" ES PK Y SON EN TOTAL 1.950 FILAS UNICAS
*/

CREATE TABLE IF NOT EXISTS freelancersdb.dim_freelancer (
    id_trabajo  INT AUTO_INCREMENT PRIMARY KEY,
    id_freelancer INT,
    apellido VARCHAR(255) NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    categoria_trabajo VARCHAR(100),
    nivel_experiencia VARCHAR(50),
    tarifa_por_hora DECIMAL(10,2),
    tasa_exito DECIMAL(10,2),
    tasa_recontratacion DECIMAL(10,2),
    gasto_marketing DECIMAL(10,2)
);

INSERT INTO freelancersdb.dim_freelancer(id_freelancer, apellido, nombre, categoria_trabajo, nivel_experiencia, tarifa_por_hora, tasa_exito, tasa_recontratacion, gasto_marketing)
	SELECT
		ï»¿id_freelancer AS id_freelancer,
        Last_Name AS apellido,
        Name AS nombre,
			CASE
				WHEN Job_Category = 'Graphic Design' THEN 'Diseñoar gráfico'
                WHEN Job_Category = 'Web Development' THEN 'Desarrollo web'
                WHEN Job_Category = 'App Development' THEN 'Desarrollo de aplicaciones web'
                WHEN Job_Category = 'Customer Support' THEN 'Atención al cliente'
                WHEN Job_Category = 'Data Entry' THEN 'Ingresador de datos'
                WHEN Job_Category = 'SEO' THEN 'SEO'
                WHEN Job_Category = 'Digital Marketing' THEN 'Marketing digital'
                WHEN Job_Category = 'Content Writing' THEN 'Escritor de contenido'
				ELSE 'Otro'
            END AS categoria_trabajo,
            CASE
				WHEN Experience_Level = 'Beginner' THEN 'Principiante'
                WHEN Experience_Level = 'Intermediate' THEN 'Intermedio'
                WHEN Experience_Level = 'Expert' THEN 'Experto'
				ELSE 'Otro'
            END AS nivel_experiencia, 
		Hourly_Rate AS tarifa_por_hora,
        Job_Success_Rate AS tasa_exito,
        Rehire_Rate AS tasa_recontratacion,
        Marketing_Spend AS gasto_marketing
	FROM prueba.freelancer_earnings_bd_1;


SHOW ERRORS;

SELECT 
	COUNT(DISTINCT(id_trabajo)) AS conteo
FROM freelancersdb.dim_freelancer;


/*  
	1-	CREACIÓN DE LA TABLA DE DIMENSIONES "dim_clientes", LA CUAL VA A ESTAR TRADUCIDA SUS COLUMNAS AL ESPAÑOL PARA
		POSTERIORMENTE INCORPORAR LOS DATOS Y TRADUCIRLOS.
    2-	LA COLUMNA DE "id_clientes" ES PK Y ES UN AUTO_INCREMENTE YA QUE EN DESDE LA TABLA QUE SE COPIA LOS DATOS NO TIENE DICHA COLUMNA,
		A LO CUAL SE GENERA DE FORMA AUTOMATICA.
*/
    
CREATE TABLE freelancersdb.dim_clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    id_freelancer INT,
    region VARCHAR(100)
);


INSERT INTO freelancersdb.dim_clientes (id_freelancer, region)
	SELECT
		ï»¿id_freelancer AS id_freelancer,
		Client_Region AS region
	FROM prueba.freelancer_earnings_bd_1;
    
SELECT 
	COUNT(DISTINCT(id_cliente)) AS conteo
FROM freelancersdb.dim_clientes;

    
/*  
	1-	CREACIÓN DE LA TABLA DE DIMENSION "dim_plataformas", LA CUAL SE VA A INTRODUCIR LOS DATOS
    2- 	SE PUDO VERIFICAR QUE LA COLUMNA "id_plataforma" ES PK Y ADEMAS DE SER NUESTRA CLAVE PRIMARIA ES UN AUTO_INCREMENT.
*/  

CREATE TABLE freelancersdb.dim_plataformas (
    id_plataforma INT AUTO_INCREMENT PRIMARY KEY,
    id_freelancer INT,
    Nombre VARCHAR(100)
);

INSERT INTO freelancersdb.dim_plataformas (id_freelancer, nombre)
	SELECT
		ï»¿id_freelancer AS id_freelancer,
		Platform AS nombre
	FROM prueba.freelancer_earnings_bd_1;
    
/*  
	1-	CREACIÓN DE LA TABLA DE HECHOS "fact_trabajos", LA CUAL VA A ESTAR TRADUCIDA SUS COLUMNAS AL ESPAÑOL PARA
		POSTERIORMENTE INCORPORAR LOS DATOS Y TRADUCIRLOS.
    2-	LA COLUMNA "id_trabajo" SE UTILIZO COMO PK, NO ES AUTO_INCREMENT YA QUE SE TRAE LOS DATOS UNICOS DE OTRA TABLA Y ADEMAS SE DEFINIERON COMO FK "id_cliente" Y "id_plataforma".
    3-  SE UTILIZO LA FUNCION "JOIN" PARA RELACIONAR LAS TABLAS Y ASI PODER COPIAR LOS DATOS QUE SE NECESITAN LA INFORMACION CORRECTA.
*/  


 CREATE TABLE freelancersdb.fact_trabajos (
    id_trabajo INT PRIMARY KEY,
    id_freelancer INT,
    id_cliente INT,
    id_plataforma INT,
    Fecha_inicio DATE,
    Fecha_finalizacion DATE,
    tipo_proyecto VARCHAR(100),
    metodo_pago VARCHAR(50),
    trabajo_completado INT,
    ganancias_usd DECIMAL(10,2),
    calificacion_cliente DECIMAL(20,2),
    dias_duracion INT,
    FOREIGN KEY (id_trabajo) REFERENCES freelancersdb.dim_freelancer(id_trabajo),
    FOREIGN KEY (id_cliente) REFERENCES freelancersdb.dim_clientes(id_cliente) ON DELETE SET NULL,
    FOREIGN KEY (id_plataforma) REFERENCES freelancersdb.dim_plataformas(id_plataforma) ON DELETE SET NULL
);


INSERT INTO freelancersdb.fact_trabajos (id_trabajo, id_freelancer, id_cliente, id_plataforma, Fecha_inicio, Fecha_finalizacion, tipo_proyecto, metodo_pago, trabajo_completado, ganancias_usd, calificacion_cliente, dias_duracion
)
SELECT
	id_trabajo,
	ï»¿id_freelancer AS id_freelancer,
	id_cliente AS id_cliente,
    id_plataforma AS id_plataforma,
    STR_TO_DATE(Fecha_inicio, '%d/%m/%Y') AS Fecha_inicio,
    STR_TO_DATE(Fecha_finalizacion, '%d/%m/%Y') AS Fecha_finalizacion,
    CASE
        WHEN Project_Type = 'Fixed' THEN 'Fijo'
        WHEN Project_Type = 'Hourly' THEN 'Por hora'
        ELSE 'Otro'
    END AS tipo_proyecto,  
    Payment_Method AS metodo_pago,  
    Job_Completed AS trabajo_completado,  
    Earnings_USD AS ganancias_usd,  
    Client_Rating AS calificacion_cliente,  
    Job_Duration_Days AS dias_duracion  
FROM prueba.freelancer_earnings_bd_1;