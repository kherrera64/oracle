/*
  Autor: Andrea Alvarado 
  Fecha: 06/01/2014
  Descripcion: Devuelve un cursor con los horarios por portal para el reporte de 
  nomina. 
  Modificacion > AALVARADO - 11/01/2014 - Se agrego la funcionalidad para nomina
  de temporal. 
  
  Modificacion > KHERRERA - 07/07/2014 - Se agrego el campo NOMBRETORRE de la
  tabla CATORRESTB. 
  
  Modificacion > KHERRERA - 27/08/2014 - Se agrego outer join con la tabla 
  CATORRESTB.
*/
PROCEDURE HORARIO_NOMINA
(
  PHORARIO DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE,
  PFECHAIMP DBAFISICC.CAHMAINHORARIOSTB.FECHAIMP%TYPE DEFAULT NULL,
  PTEMPORAL NUMBER DEFAULT 0,
  PUSUARIO  DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
  RETVAL    OUT SYS_REFCURSOR
)IS 
BEGIN

  IF PTEMPORAL = 0 THEN 
    OPEN RETVAL FOR 
       SELECT DISTINCT DECODE(A.DIA,1,'DOMINGO',
                         2,'LUNES',
                         3,'MARTES',
                         4,'MIERCOLES',
                         5,'JUEVES',
                         6,'VIERNES',
                         7,'SABADO') DIA, A.TORRE, B.NOMBRETORRE,A.SALON, 
              TO_CHAR(A.HORAINI,'hh24:mi')||' - '||TO_CHAR(A.HORAFIN,'hh24:mi')
              AS HORA
              
           FROM DBAFISICC.CAHORARIOSTB A, DBAFISICC.CATORRESTB B
           WHERE A.HORARIO = PHORARIO
           AND A.TORRE = B.CODIGOTORRE(+)
           
        UNION
        SELECT DISTINCT DECODE(A.DIA,1,'DOMINGO',
                          2,'LUNES',
                          3,'MARTES',
                          4,'MIERCOLES',
                          5,'JUEVES',
                          6,'VIERNES',
                          7,'SABADO') DIA, A.TORRE, B.NOMBRETORRE, A.SALON, 
              TO_CHAR(A.HORAINI,'hh24:mi')||' - '||TO_CHAR(A.HORAFIN,'hh24:mi') 
              AS HORA
          
            FROM DBAFISICC.CAHHORARIOSTB A, DBAFISICC.CATORRESTB B
            WHERE A.HORARIO = PHORARIO
            AND A.FECHAIMP = PFECHAIMP
            AND A.TORRE = B.CODIGOTORRE(+);    
  ELSE
    OPEN RETVAL FOR 
       SELECT DISTINCT DECODE(A.DIA,1,'DOMINGO',
                         2,'LUNES',
                         3,'MARTES',
                         4,'MIERCOLES',
                         5,'JUEVES',
                         6,'VIERNES',
                         7,'SABADO') DIA, A.TORRE, B.NOMBRETORRE, A.SALON, 
              TO_CHAR(A.HORAINI,'hh24:mi')||' - '||TO_CHAR(A.HORAFIN,'hh24:mi') 
              AS HORA
              
            FROM DBAFISICC.CAHORARIOSTMP A, DBAFISICC.CATORRESTB B
            WHERE HORARIO = PHORARIO
            AND A.TORRE = B.CODIGOTORRE;
        
  END IF; 
  
END HORARIO_NOMINA;