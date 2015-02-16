/*
autor: Luis Mérida
Fecha: 26/09/2012
Descripcion: Devuelve el listado de CARRERAS a las que el 
usuario tiene acceso en base a una entidad ,director, sede y grado enviado
Excluye Facultad de idea y para señalar TODOS manda un 0 como dato.
MODIFICACION: LMERIDA - 27/09/2012 - se agregó la funcionalidad para que 
pueda recibir varias entidades, directores, sedes y grados.

JVELASQUEZ - 03/10/2012 - Agregue parametros para filtrar carreras.
    PACTIVAS - Que define si regresa solo carreras activas 
        1- Solo Activas (predeterminado)
        0 - Todas
    PINCLUYE_IDEA -Determina si vamos a mostrar datos de facultad IDEA
      1 - Incluye Idea
      0 - No incluye. (predeterminado)
 
Autor: Kevin Herrera
Fecha: 05/08/2014  
Modificacion: Se utiliza el campo CENTRONOMBRE de la vista CACARRERASVW en lugar
              del campo centro.
              
JFerrer - 29-08-2014 - Se modifico para que incluya a IDEA por defecto. 
 - Modificacion - 17/09/2014 - Edy Cocon 
  Descripcion: Se agrega el parametro PCENTRO para filtrar por el CENTRO.
  
Autor: Kevin Herrera
Fecha: 09/10/2014  
Modificacion: Se agrega split a PCENTRO para poder filtrar por varios centros.
*/
  PROCEDURE CARRERA
  (
    PUSUARIO  DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE DEFAULT NULL,
    PENTIDAD  IN VARCHAR2 DEFAULT NULL,
    PDIRECTOR IN VARCHAR2 DEFAULT NULL,
    PSEDE     IN VARCHAR2 DEFAULT NULL,
    PGRADO    IN VARCHAR2 DEFAULT NULL,
    PTODOS    IN NUMBER DEFAULT 1,
    PACTIVAS  IN NUMBER DEFAULT 1,
    PINCLUYE_IDEA IN NUMBER DEFAULT 0,
    PCENTRO   IN VARCHAR2 DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
  ) AS 
  BEGIN
    OPEN RETVAL FOR
        SELECT '0' CARRERA, ' TODOS' NOMBRE, ' TODOS' NOMBRE_CORTO
            FROM DUAL
            WHERE PTODOS = 1
            
        UNION SELECT A.CARRERA, DBAFISICC.PKG_CARRERA.NOMBRE(A.CARRERA, NULL, 5) 
                     NOMBRE, DBAFISICC.PKG_CARRERA.NOMBRE(A.CARRERA, NULL, 4) 
                     NOMBRE_CORTO
            FROM DBAFISICC.CACARRERASVW A, DBAFISICC.CAUSUARIOSCARRERASTB B 
            WHERE A.CARRERA = B.CARRERA 
            AND  (A.STATUC = 'A' OR PACTIVAS = 0)
            AND (B.USUARIO = PUSUARIO OR PUSUARIO IS NULL)
            AND (A.ENTIDAD IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PENTIDAD,
                              ','))) OR PENTIDAD IS NULL)
            AND (A.ENCARGADO IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PDIRECTOR,
                                ','))) OR PDIRECTOR IS NULL)
            AND (A.CENTRONOMBRE IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PSEDE,
                                   ','))) OR PSEDE IS NULL)
            AND (A.GRADO IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PGRADO,
                             ','))) OR PGRADO IS NULL)
            AND (A.CENTRO IN(SELECT * FROM TABLE (SPLIT_VARCHAR(PCENTRO,
                             ','))) OR PCENTRO IS NULL)
       ORDER BY NOMBRE;
         
  END CARRERA;