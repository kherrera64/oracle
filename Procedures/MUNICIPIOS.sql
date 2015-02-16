/*
autor: Kevin Herrera
FECHA: 22/04/2014
Descripcion: Procedimiento que devuelve los datos de Municipios.
*/

CREATE OR REPLACE PROCEDURE MUNICIPIOS  
 (
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN
  OPEN RETVAL FOR 
  
      SELECT A.PAIS, A.DEPTO, A.MUNICIP, A.NOMBRE, A.ORDEN, A.MUNI_INE, 
      A.ASEGURADORA, B.NOMBRE AS DEPTONOMBRE, C.NOMBRE AS PAISNOMBRE, 
      B.Depto_INE
        
         FROM DBAFISICC.GNMUNICIPSTB A, DBAFISICC.GNDEPTOSTB B,
         DBAFISICC.GnPaisesTB C
         WHERE B.PAIS = A.PAIS
         AND B.Depto = A.Depto
         AND C.PAIS = A.PAIS
      ORDER BY C.NOMBRE, B.NOMBRE, A.NOMBRE;
      
END MUNICIPIOS;      
