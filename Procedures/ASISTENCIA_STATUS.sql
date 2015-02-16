/*
Autor:  Kevin Herrera.
Fecha:  21/07/2014
Descripcion: Procedimiento que devuelve el status por horario de los 
             asistentes de catedra. 
*/

PROCEDURE ASISTENCIA_STATUS
 (
    PHORARIO  DBAFISICC.RHDOCENTESTB.HORARIO%TYPE DEFAULT NULL,
    PCODPERS  DBAFISICC.RHASISTENCIATB.CODPERS%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
 )
  IS BEGIN
  OPEN RETVAL FOR 
  
        SELECT A.STATUS, A.CODPUESTO 
           
               FROM DBAFISICC.RHDOCENTESTB A 
               WHERE A.HORARIO = PHORARIO 
               AND A.CODPERS = PCODPERS;

END ASISTENCIA_STATUS;       
               