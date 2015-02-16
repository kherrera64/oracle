 /*
autor: Kevin Herrera
FECHA: 02/04/2014
Descripcion: Procedimiento creado para generar correlativo para nuevas
             torres que se ingresen.
*/

PROCEDURE GENCODIGOEVENTO
( 
  HORARIO out varchar2
)
  IS
  BEGIN 
   
      SELECT 'EV' || LPAD(TO_CHAR(COUNT(CODIGO) + 1), 6-LENGTH('EV'),'0')
      INTO HORARIO
            FROM DBAFISICC.CARESERVHORATMP;

 END GENCODIGOEVENTO;