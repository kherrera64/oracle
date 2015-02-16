/*
Autor:  Kevin Herrera.
Fecha:  21/07/2014
Descripcion: Procedimiento que devuelve los datos de la descripcion y horario
             para la asistencia de alumnos.
*/

PROCEDURE ASISTENCIA_ENCABEZADO
 (
    PHORARIO  DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE DEFAULT NULL,
    PDIA      DBAFISICC.CAHORARIOSTB.DIA%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
 )
  IS BEGIN
  OPEN RETVAL FOR 
  
    SELECT A.HORARIO|| ' - ' ||A.DESCRIPCION AS CURSO , 
    TO_CHAR(B.HORAINI,'HH24:MI') HORAINI, TO_CHAR(B.HORAFIN,'HH24:MI') HORAFIN 
        
        FROM DBAFISICC.CAMAINHORARIOSTB A, DBAFISICC.CAHORARIOSTB B 
        WHERE A.HORARIO=PHORARIO
        AND B.HORARIO = A.HORARIO
        AND B.DIA = PDIA;

END ASISTENCIA_ENCABEZADO;          