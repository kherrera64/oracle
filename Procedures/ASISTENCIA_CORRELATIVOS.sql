/*
Autor:  Kevin Herrera.
Fecha:  21/07/2014
Descripcion: Procedimiento que devuelve los correlativos por horario
             para la asistencia de alumnos.
*/

PROCEDURE ASISTENCIA_CORRELATIVOS
 (
    PHORARIO  DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE DEFAULT NULL,
    PDIA      DBAFISICC.CAHORARIOSTB.DIA%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
 )
  IS BEGIN
  OPEN RETVAL FOR 
  
     SELECT A.CORRELATIVO
        FROM DBAFISICC.CAHORARIOSTB A
        WHERE A.HORARIO=PHORARIO
        AND A.DIA = PDIA;
  
END ASISTENCIA_CORRELATIVOS;  


