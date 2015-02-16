 /*
autor: Kevin Herrera
FECHA: 28/07/2014
Descripcion: Procedimiento que devuelve las solicitudes por alumno para 
             exoneraciones y fraccionamiento.

autor: Kevin Herrera
FECHA: 06/08/2014
Modificacion: Se envia CARRERA_SEDE a SOSOLTRAMITETB.

autor: Kevin Herrera
FECHA: 22/08/2014
Modificacion: Se puede enviar la carrera null.
*/

 PROCEDURE SOLICITUDES_FINANCIERAS  
 (
   PTRAMITE  DBAFISICC.SOSOLTRAMITETB.TRAMITE%TYPE DEFAULT NULL,
   PCARNET   DBAFISICC.SOSOLTRAMITETB.CARNET%TYPE DEFAULT NULL,
   PCARRERA  DBAFISICC.SOSOLTRAMITETB.CARRERA%TYPE DEFAULT NULL,
   PPASO     DBAFISICC.SOSOLTRAMITETB.PASO%TYPE DEFAULT NULL,
   RETVAL    OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  open RETVAL for 

    SELECT to_char(A.SOLICITUD) SOLICITUD
           
           FROM DBAFISICC.SOSOLTRAMITETB A
           WHERE A.TRAMITE = PTRAMITE
           AND A.CARNET = PCARNET
           AND A.PASO = PPASO
           AND (A.CARRERA = PCARRERA or PCARRERA is null)
        ORDER BY A.SOLICITUD; 

END SOLICITUDES_FINANCIERAS;

