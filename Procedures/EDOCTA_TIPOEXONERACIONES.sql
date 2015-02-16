/*
autor: Kevin Herrera
FECHA: 28/07/2014
Descripcion: Procedimiento que devuelve los cargos y abonos del estado de cuenta
             para realizar exoneraciones.
             
autor: Kevin Herrera
FECHA: 16/09/2014
Descripcion: Se orden de forma descendente por CARGO_ABONO.

autor: Kevin Herrera
FECHA: 15/10/2014
Descripcion: Se orden por CODMOVTO.
*/

 PROCEDURE EDOCTA_TIPOEXONERACIONES  
 (
   PCARNET   DBAFISICC.CCEDOCTATB.CARNET%TYPE DEFAULT NULL,
   PCARRERA  DBAFISICC.CCEDOCTATB.CARRERA%TYPE DEFAULT NULL,
   RETVAL  OUT SYS_REFCURSOR
 ) 
 AS BEGIN    
  OPEN RETVAL FOR 
  
  
       SELECT A.CORRELATIVO, A.CARGO_ABONO, A.CODMOVTO, B.MOVIMIENTO ,A.CURSO, 
              C.NOMBRE, A.FECHA, A.MONTO SALDO, A.CENTRO 
      
          FROM DBAFISICC.CCEDOCTATB A,  DBAFISICC.CCTIPOMOVTOTB B, 
               DBAFISICC.CACURSOSTB C
          WHERE A.CARNET = PCARNET
          AND A.CARRERA = PCARRERA
          AND A.CODMOVTO NOT IN ('AS','VI','EC','BC','RT','CT','CTE','DT','APF')
          AND B.CODMOVTO = A.CODMOVTO 
          AND C.CURSO(+) = A.CURSO
       ORDER BY A.CARGO_ABONO DESC, A.CODMOVTO;
    
 END EDOCTA_TIPOEXONERACIONES;