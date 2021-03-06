 /*
autor: Kevin Herrera
FECHA: 02/05/2014
Descripcion: Procedimiento para Insertar, actualizar y editar los datos de 
             la tabla GNUBICACIONESTB.
*/

PROCEDURE TR_GNUBICACIONESTB  
 (  
   PCODIGO   IN DBAFISICC.GNUBICACIONESTB.CODIGO%TYPE,  
   PNOMBRE   IN DBAFISICC.GNUBICACIONESTB.DESCRIPCION%TYPE,  
   PACCION   IN VARCHAR2,
   PSQLCODE  OUT NUMBER  
 )
  IS  
  BEGIN  
    
  IF PACCION = 'I'  THEN
   
   INSERT INTO DBAFISICC.GNUBICACIONESTB(CODIGO, DESCRIPCION)
   VALUES(PCODIGO, PNOMBRE);

  ELSIF PACCION = 'U'  THEN            
   
   UPDATE DBAFISICC.GNUBICACIONESTB 
    SET DESCRIPCION = PNOMBRE
    where CODIGO = PCODIGO;   
  
  ELSIF PACCION = 'D'  THEN                   
    
   DELETE FROM DBAFISICC.GNUBICACIONESTB
          WHERE CODIGO = PCODIGO;
  
  END IF;  
            
  PSQLCODE := SQLCODE;  
      
  EXCEPTION  
    WHEN OTHERS  THEN  
        PSQLCODE := SQLCODE;

END TR_GNUBICACIONESTB;  