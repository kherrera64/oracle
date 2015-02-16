/*
Nombre: SEL_CENTROS
Autor:  Miguel Barillas
Fecha:  16/10/2013
Descripcion: Devuelve los centros con su nombre y codigo
Utiliza: /Mantenimientos/Centros.aspx

Autor: Kevin Herrera
Fecha: 07/06/2014
Modificacion: Se agregan al procedimiento los campos: IDEA, ALIAS, STATUS, 
              TIPO, FECHACREACION, IDEACORR, ZONA, CICLO, UG, UFM
*/
PROCEDURE SEL_CENTROS
  (
    RETVAL OUT SYS_REFCURSOR 
  ) 
  IS BEGIN
   OPEN RETVAL FOR
     
      SELECT A.CODIGO, A.NOMBRE, A.DIRECCION, A.PAIS, A.DEPTO, A.MUNI, 
      A.TELEFONO, A.ENCARGADO, A.EMAIL, A.FAX, A.AGENCIA, A.IDEA, A.ALIAS,
      A.STATUS, A.TIPO, TO_CHAR(A.FECHACREACION, 'dd/MM/yyyy') AS FECHACREACION, 
      A.IDEACORR, A.ZONA, A.CICLO, A.UG, A.UFM
	       
         FROM DBAFISICC.CACENTROSTB A
         
	    ORDER BY A.NOMBRE;

END SEL_CENTROS;