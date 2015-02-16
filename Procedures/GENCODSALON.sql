/*
autor: Kevin Herrera
FECHA: 03/04/2014
Descripcion: Procedimiento creado para generar correlativo para el ingreso
             de Salones.
*/

PROCEDURE GENCODSALON
( 
  PTORRE   DBAFISICC.CATORRESTB.CODIGOTORRE%TYPE,
  PNIVEL   NUMBER,
  PAULA    VARCHAR2,
  PUSUARIO DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
  PSALON   out DBAFISICC.CASALONESTB.SALON%TYPE
 )
  IS
   vcorrelativo number(3);
  BEGIN 
  
  SELECT
  NVL(MAX(TO_NUMBER(SUBSTR(SALON,LENGTH
                                 (PTORRE||LPAD(TO_CHAR(PNIVEL),2,'0'))+1))),0)
      into VCORRELATIVO
        
        FROM DBAFISICC.CASALONESTB
        WHERE TO_CHAR(SUBSTR(SALON,0,LENGTH(PTORRE||LPAD(TO_CHAR(PNIVEL),2,'0'))
                                          ))=PTORRE||LPAD(TO_CHAR(PNIVEL),2,'0')
        AND LENGTH(SALON)>LENGTH(PTORRE||LPAD(TO_CHAR(PNIVEL),2,'0'));
  
    PSALON := PTORRE||LPAD(TO_CHAR(PNIVEL),2,'0')||
                               LPAD(TO_CHAR(VCORRELATIVO+1),2,'0');
        
  END GENCODSALON;