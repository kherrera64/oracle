 /*
autor: Kevin Herrera
FECHA: 28/07/2014
Descripcion: Procedimiento que devuelve el concepto opuesto para fraccionamiento
             y el numero de cuotas por carrera.
*/

 PROCEDURE EDOCTA_TIPOFRACCIONAMIENTO
 (
   PCARRERA  DBAFISICC.CACARRERASTB.CARRERA%TYPE DEFAULT NULL,
   PCODIGO   DBAFISICC.CCTIPOMOVTOTB.CODMOVTO%TYPE DEFAULT NULL,
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
    
        SELECT NVL(A.INVERSO,'0') INVERSO, 
              NVL((SELECT COUNT(B.CUOTA) 
                  FROM DBAFISICC.CCMULTASTB B
                  WHERE B.CARRERA = PCARRERA
                  AND B.PERIODO = (SELECT C.PERIODO 
                                      FROM DBAFISICC.CACARRERASTB C
                                      WHERE C.CARRERA = PCARRERA)), '0') CUOTAS
                  
                   FROM DBAFISICC.CCTIPOMOVTOTB A
                   WHERE A.CODMOVTO = PCODIGO;
 
 END EDOCTA_TIPOFRACCIONAMIENTO;                   