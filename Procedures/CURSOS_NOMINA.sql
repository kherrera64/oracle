/*
  Autor: Andrea Alvarado 
  Fecha: 06/01/2014
  Descripcion: Devuelve un cursor con los cursos por horario para el reporte de 
  nomina. 
  Modificacion > AALVARADO - 11/01/2014 - Se agrego que tenga funcionalidad para
  el reporte de nomina temporal. 
  Modificacion > KHERRERA - 07/07/2014 - Se agrego el campo CICLO de la tabla
  CACURSOSIMPTB. 
*/
PROCEDURE CURSOS_NOMINA
(
  PHORARIO DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE,
  PFECHAIMP DBAFISICC.CAHMAINHORARIOSTB.FECHAIMP%TYPE DEFAULT NULL,
  PUSUARIO  DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
  PTEMPORAL NUMBER DEFAULT 0,
  RETVAL    OUT SYS_REFCURSOR
)IS 
BEGIN

  IF PTEMPORAL = 0 THEN 
      OPEN RETVAL FOR 
      
        SELECT DISTINCT A.HORARIO, A.CURSO, B.PENSUM, B.UMAS, B.CARRERA, 
        B.TIPOASIG, B.CICLO, B.SECCION 
           
           FROM DBAFISICC.CACURSHORATB A, DBAFISICC.CACURSOSIMPTB B 
           WHERE A.CARRERA = B.CARRERA 
           AND A.CURSO = B.CURSO 
           AND A.TIPOASIG = B.TIPOASIG 
           AND A.SECCION = B.SECCION       
           AND A.HORARIO = PHORARIO
          
        UNION
        SELECT DISTINCT A.HORARIO, A.CURSO, B.PENSUM, B.UMAS, B.CARRERA, 
        B.TIPOASIG, B.CICLO, B.SECCION 
           
           FROM DBAFISICC.CAHCURSHORATB A, DBAFISICC.CAHCURSOSIMPTB B 
           WHERE A.CARRERA = B.CARRERA 
           AND A.CURSO = B.CURSO 
           AND A.TIPOASIG = B.TIPOASIG 
           AND A.SECCION = B.SECCION      
           AND A.FECHAIMP = B.FECHAIMP 
           AND A.HORARIO = PHORARIO
           AND A.FECHAIMP = PFECHAIMP;  
           
  ELSE OPEN RETVAL FOR 
  
        SELECT DISTINCT A.HORARIO, A.CURSO, B.PENSUM, B.UMAS, B.CARRERA, 
        B.TIPOASIG, B.CICLO, B.SECCION 
           
           FROM DBAFISICC.CACURSHORATMP A, DBAFISICC.CACURSOSIMPTMP B 
           WHERE A.CARRERA = B.CARRERA 
           AND A.CURSO = B.CURSO 
           AND A.TIPOASIG = B.TIPOASIG 
           AND A.SECCION = B.SECCION       
           AND A.HORARIO = PHORARIO;
          
  END IF; 
  
END CURSOS_NOMINA;