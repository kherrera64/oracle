/*
autor: Kevin Herrera
FECHA: 24/04/2014
Descripcion: Procedimiento creado para generar correlativo para los nuevos
             tipos de documentos que se ingresen.
*/    

PROCEDURE GENCODDOCUMENTO
( 
  PCODIGODOCUMENTO out DBAFISICC.GNTIPODOCTOSTB.TIPODOCTO%TYPE
)
 IS
    VCODIGO NUMBER(4);
  BEGIN 
  
    SELECT NVL(MAX(TO_NUMBER(TIPODOCTO)),0)+1 
    INTO VCODIGO
      FROM DBAFISICC.GNTIPODOCTOSTB;

     PCODIGODOCUMENTO := VCODIGO;  
         
END GENCODDOCUMENTO;