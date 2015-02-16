 /*
autor: Kevin Herrera
FECHA: 22/03/2014
Descripcion: Procedimiento que devuelve el grado academico por codigo de 
             personal.
*/
 PROCEDURE GRADOACADEMICO
(
  PCODPERS DBAFISICC.nopersonaltb.CODPERS%TYPE DEFAULT NULL,
  RETVAL    OUT SYS_REFCURSOR
)
  IS
  BEGIN
  OPEN RETVAL FOR
  
    SELECT GRACAD
        FROM DBAFISICC.nopersonaltb
        WHERE codpers = PCODPERS;
        
END GRADOACADEMICO;