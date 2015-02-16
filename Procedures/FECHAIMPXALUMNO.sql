/*Autor: Kevin Herrera
  Fecha: 24/01/2014
  Descripción: Procedimiento creado para devolver las fechas de 
  Impartido de los cursos que se ha asignado los alumno filtrando
  por carnet y carrera*/

PROCEDURE FECHAIMPXALUMNOS
  (
    PCARNET IN DBAFISICC.CAHASIGNASTB.CARNET%TYPE,
    PCARRERA IN DBAFISICC.CAHASIGNASTB.CARRERA%TYPE,
    RETVAL    OUT SYS_REFCURSOR
  ) AS 
  BEGIN
    OPEN RETVAL FOR 
    
      SELECT DISTINCT TO_CHAR(TRUNC(A.FECHAIMP), 'MM/YYYY') FECHAIMP,
                      TRUNC(A.FECHAIMP) FECHAORDEN
         FROM DBAFISICC.CAHASIGNASTB A
         WHERE A.CARNET = PCARNET
            AND  A.CARRERA = PCARRERA
         ORDER BY FECHAORDEN DESC;
	   
    END FECHAIMPXALUMNOS;