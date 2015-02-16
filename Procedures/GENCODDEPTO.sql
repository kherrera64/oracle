/*
autor: Kevin Herrera
FECHA: 12/04/2014
Descripcion: Procedimiento creado para generar correlativo para los nuevos
             departamentos que se ingresen.
*/    

PROCEDURE GENCODDEPTO
( 
  PPAIS DBAFISICC.GNDEPTOSTB.PAIS%TYPE,
  PCODIGODEPTO out DBAFISICC.GNDEPTOSTB.DEPTO%TYPE
)
 IS
    VCODIGO number(4);
  BEGIN 

    SELECT NVL( MAX(DEPTO), 0) + 1
    INTO VCODIGO
     
      FROM DBAFISICC.GNDEPTOSTB
      WHERE PAIS = PPAIS
      AND DEPTO != '9999';
    
     PCODIGODEPTO := VCODIGO;  
         
END GENCODDEPTO;         