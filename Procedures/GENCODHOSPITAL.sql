/*
autor: Kevin Herrera
FECHA: 24/04/2014
Descripcion: Procedimiento creado para generar correlativo para los nuevos
             hospitales que se ingresen.
*/    

PROCEDURE GENCODHOSPITAL
( 
  PCODIGOHOSPITAL out DBAFISICC.GNHOSPITALESTB.HOSPITAL%TYPE
)
 IS
    VCODIGO NUMBER(4);
  BEGIN 
  
    SELECT NVL( MAX(HOSPITAL), 0) + 1
    INTO VCODIGO
      FROM DBAFISICC.GNHOSPITALESTB;
  
     PCODIGOHOSPITAL := VCODIGO;  
         
END GENCODHOSPITAL;