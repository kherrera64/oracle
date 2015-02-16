/*
autor: Carlos Juan
Fecha: 12/09/2012
Descripcion: Obtiene informacion del usuario segun gnusuarios

autor: Kevin Herrera
Fecha: 18/02/2014
Modificacion: Se agrego el campo Correlativo de la tabla NOPERSONALTB

autor: Kevin Herrera
Fecha: 20/02/2014
Modificacion: Se agrego un Outer Join el campo codpers de NOPERSONALTB.

autor: Kevin Herrera
Fecha: 05/03/2014.
Modificacion - Kevin Herrera: Se agrego el campo Idea a el procedimiento
ya que fue agregado a la tabla GNUSUARIOSTB.

*/
  PROCEDURE DATOSUSUARIO
  (
    PUSUARIO  DBAFISICC.GNUSUARIOSTB.usuario%TYPE,
    RETVAL    OUT sys_refcursor
  ) AS 
  BEGIN
    open RETVAL for
    
   select a.CODPERS, C.CORRELATIVO, a.NOMBRE, a.EMAIL, a.USUNAF, a.ACCESO_CC,
    a.ACCESO_CCAUD, a.TRASLADO_REC, a.ACCESO_UPDUFM, a.ACCESO_NOMINA_DOCENTE,
    b.ACCOUNT_STATUS, a.ACTIVO, a.ORACLE, a.REFERENCIA, a.IDEA
   
   from DBAFISICC.GNUSUARIOSTB a, SYS.DBA_USERS B, DBAFISICC.NOPERSONALTB C
   where B.USERNAME(+)=a.USUARIO
   and a.USUARIO=PUSUARIO
   and a.codpers = c.codpers(+);
    
  END DATOSUSUARIO;