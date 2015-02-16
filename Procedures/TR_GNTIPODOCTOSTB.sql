 /*
autor: Kevin Herrera
FECHA: 05/05/2014
Descripcion: Procedimiento para Insertar, actualizar y editar los datos de 
             la tabla GNTIPODOCTOSTB.
*/

PROCEDURE TR_GNTIPODOCTOSTB  
 (  
   PTIPO     IN DBAFISICC.GNTIPODOCTOSTB.TIPODOCTO%TYPE,  
   PNOMBRE   IN DBAFISICC.GNTIPODOCTOSTB.NOMBRE%TYPE,  
   PACCION   IN VARCHAR2,
   PSQLCODE  OUT NUMBER  
 )
  IS  
  BEGIN  
    
  IF PACCION = 'I'  THEN
  
   INSERT INTO DBAFISICC.GNTIPODOCTOSTB (TIPODOCTO, NOMBRE)
   values(PTIPO, PNOMBRE);

  ELSIF PACCION = 'U'  THEN            
    
   UPDATE DBAFISICC.GNTIPODOCTOSTB 
    SET NOMBRE = PNOMBRE 
    where tipodocto = PTIPO;
  
  ELSIF PACCION = 'D'  THEN                   
    
   DELETE FROM DBAFISICC.GNTIPODOCTOSTB
          WHERE TIPODOCTO=PTIPO;
  
  END IF;  
            
  PSQLCODE := SQLCODE;  
      
  EXCEPTION  
    WHEN OTHERS  THEN  
        PSQLCODE := SQLCODE;

END TR_GNTIPODOCTOSTB;  