 /*
autor: Kevin Herrera
FECHA: 02/04/2014
Descripcion: Procedimiento creado para generar correlativo para nuevas
             torres que se ingresen.
Modificacion: Autor: Kevin Herrera 
Fecha: 03/04/2014
Descripcion: A los SUBSTR se cambio al parametro final PLENGTH(PTIPO) para 
             que lo haga con cualquier caracter.
*/

PROCEDURE GENCODTORRE
( 
  PTIPO   VARCHAR2,
  PUSUARIO DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE,
  PCODIGOTORRE out DBAFISICC.CATORRESTB.CODIGOTORRE%TYPE
  
)
  IS
  vcorrelativo number(3);
  BEGIN 
   
      SELECT NVL(MAX(TO_NUMBER(SUBSTR(CODIGOTORRE,LENGTH(PTIPO)+1))),0)
      into VCORRELATIVO
        
        FROM DBAFISICC.CATORRESTB
        WHERE TO_CHAR(SUBSTR(CODIGOTORRE,0,LENGTH(PTIPO)))=PTIPO
        AND LENGTH(CODIGOTORRE)>LENGTH(PTIPO);
     
      PCODIGOTORRE := PTIPO||LPAD(TO_CHAR(VCORRELATIVO+1),4-LENGTH(PTIPO),'0');
        
  END GENCODTORRE;