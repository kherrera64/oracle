 /*
autor: Kevin Herrera
FECHA: 05/05/2014
Descripcion: Procedimiento para Insertar, actualizar y editar los datos de 
             la tabla GNTIPOINSTSTB.
*/

PROCEDURE TR_GNTIPOINSTSTB 
 (  
   PTIPO     IN DBAFISICC.GNTIPOINSTSTB.TIPOINST%TYPE,  
   PNOMBRE   IN DBAFISICC.GNTIPOINSTSTB.NOMBRE%TYPE,  
   PACCION   IN VARCHAR2,
   PSQLCODE  OUT NUMBER  
 )
  IS  
  BEGIN  
    
  IF PACCION = 'I'  THEN
  
    INSERT INTO DBAFISICC.GNTIPOINSTSTB(TIPOINST,NOMBRE) 
    VALUES (PTIPO, PNOMBRE);

  ELSIF PACCION = 'U'  THEN            
    
    UPDATE DBAFISICC.GNTIPOINSTSTB  
     SET  NOMBRE = PNOMBRE 
     WHERE TIPOINST = PTIPO;
  
  ELSIF PACCION = 'D'  THEN                   
    
    DELETE FROM  DBAFISICC.GNTIPOINSTSTB 
           WHERE TIPOINST = PTIPO;
  
  END IF;  
            
  PSQLCODE := SQLCODE;  
      
  EXCEPTION  
    WHEN OTHERS  THEN  
        PSQLCODE := SQLCODE;

END TR_GNTIPOINSTSTB;  