/*
 KHERRERA - 26/06/2014 - Se agrega al procedimiento el puesto  000085.
*/
FUNCTION ASISTENCIAFOTO  
 (
 PCARNET   DBAFISICC.CACARNETBITB.CARNET%TYPE
 )

RETURN VARCHAR2 IS
	VResp  DBAFISICC.CACARNETBITB.FOTO%TYPE;
BEGIN

     SELECT FOTO 
       INTO VResp
         FROM DBAFISICC.CACARNETBITB 
         WHERE CARNET = PCARNET;
           
    RETURN VResp;
    
    EXCEPTION
       when OTHERS then
          VResp := NULL;
	  RETURN VResp;
    
      
END ASISTENCIAFOTO;