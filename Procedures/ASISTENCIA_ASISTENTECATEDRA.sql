/*
Autor:  Kevin Herrera.
Fecha:  21/07/2014
Descripcion: Procedimiento que devuelve los datos de asistencia de los 
             asistentes de catedra. 
*/

PROCEDURE ASISTENCIA_ASISTENTECATEDRA
 (
    PHORARIO  DBAFISICC.RHDOCENTESTB.HORARIO%TYPE DEFAULT NULL,
    PCODPERS  DBAFISICC.RHASISTENCIATB.CODPERS%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
 )
  IS BEGIN
  OPEN RETVAL FOR 
    
           SELECT A.CODPERS, C.NOMBRE1||' '||NVL(C.NOMBRE2,'')||' '||
           C.APELLIDO1||' '||NVL(C.APELLIDO2,'') NOMBRE 
              
              FROM DBAFISICC.RHDOCENTESTB A, DBAFISICC.NOPERSONALTB C 
              WHERE A.CODPERS=C.CODPERS 
              AND A.CODPUESTO = '000074' 
              and horario=PHORARIO;
    
 END ASISTENCIA_ASISTENTECATEDRA;