 /*
autor: Kevin Herrera
FECHA: 02/05/2014
Descripcion: Procedimiento para Insertar, actualizar y editar los datos de 
             la tabla GNSTATALUMSTB.
*/

PROCEDURE TR_GNSTATALUMSTB  
 (  
   PSTATUS   IN DBAFISICC.GNSTATALUMSTB.STATALUM%TYPE,  
   PNOMBRE   IN DBAFISICC.GNSTATALUMSTB.NOMBRE%TYPE,  
   PACCION   IN VARCHAR2,
   PSQLCODE  OUT NUMBER  
 )
  IS  
  BEGIN  
    
  IF PACCION = 'I'  THEN
  
   INSERT INTO DBAFISICC.GNSTATALUMSTB (STATALUM, NOMBRE)
   VALUES(PSTATUS, PNOMBRE);

  ELSIF PACCION = 'U'  THEN            
    
   UPDATE DBAFISICC.GNSTATALUMSTB 
    SET NOMBRE = PNOMBRE 
    WHERE STATALUM = PSTATUS;
  
  ELSIF PACCION = 'D'  THEN                   
    
   DELETE FROM DBAFISICC.GNSTATALUMSTB
          WHERE STATALUM=PSTATUS;
  
  END IF;  
            
  PSQLCODE := SQLCODE;  
      
  EXCEPTION  
    WHEN OTHERS  THEN  
        PSQLCODE := SQLCODE;

END TR_GNSTATALUMSTB;  