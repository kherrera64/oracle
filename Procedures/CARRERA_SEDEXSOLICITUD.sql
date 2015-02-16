 /*
autor: Kevin Herrera
FECHA: 22/08/2014
Descripcion: Retorna la carrera_sede por solicitud.
*/

 FUNCTION CARRERA_SEDEXSOLICITUD  
 (
   PTRAMITE   DBAFISICC.SOSOLTRAMITETB.TRAMITE%TYPE
 )

RETURN VARCHAR2 IS
	VResp  DBAFISICC.SOSOLTRAMITETB.CARRERA%TYPE;
BEGIN

   SELECT A.CARRERA 
      INTO VResp      
           FROM DBAFISICC.SOSOLTRAMITETB A
           WHERE A.SOLICITUD = PTRAMITE;
           
    RETURN VResp;
    
    EXCEPTION
       when OTHERS then
          VResp := NULL;
	  RETURN VResp;
    
      
END CARRERA_SEDEXSOLICITUD;