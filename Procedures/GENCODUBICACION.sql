/*
autor: Kevin Herrera
FECHA: 24/04/2014
Descripcion: Procedimiento creado para generar correlativo para las nuevas
             ubicaciones que se ingresen.
*/    

PROCEDURE GENCODUBICACION
( 
  PCODIGOUBICACION out DBAFISICC.GNUBICACIONESTB.CODIGO%TYPE
)
 IS
    VCODIGO NUMBER(4);
  BEGIN
    
    SELECT NVL(MAX(TO_NUMBER(CODIGO)),0) + 1 
    INTO VCODIGO
      FROM DBAFISICC.GNUBICACIONESTB;
  
     PCODIGOUBICACION := VCODIGO;  
         
END GENCODUBICACION;