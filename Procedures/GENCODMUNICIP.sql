/*
autor: Kevin Herrera
FECHA: 22/04/2014
Descripcion: Procedimiento creado para generar correlativo para los nuevos
             municipios que se ingresen.
*/    

CREATE OR REPLACE PROCEDURE GENCODMUNICIP
( 
  PPAIS DBAFISICC.GNMUNICIPSTB.PAIS%TYPE,
  PDEPTO DBAFISICC.GNMUNICIPSTB.DEPTO%TYPE,
  PCODIGOMUNICIP out DBAFISICC.GNMUNICIPSTB.MUNICIP%TYPE
)
 IS
    VCODIGO number(4);
  BEGIN 
  
    SELECT NVL( MAX(MUNICIP), 0) + 1
    INTO VCODIGO
      FROM DBAFISICC.GNMUNICIPSTB
      WHERE PAIS = PPAIS
      AND DEPTO = PDEPTO
      AND DEPTO != '9999'
      AND MUNICIP != '9999';

     PCODIGOMUNICIP := VCODIGO;  
         
END GENCODMUNICIP;   