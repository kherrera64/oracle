/*
Autor:  Jorge Velasquez.
Fecha:  09/09/2013
Descripcion: Devuelve todas las carreras especificando entidad, director, sede
		y grado con los filtros recibidos como parametros.
Modificacion: JVELASQUEZ - 10/09/2013 - Se cambio el nombre de la columna de
		PROVEDURIA a PROVEEDURIA.

Modificacion: KHERRERA -20/02/2014 - Se modifico el manejo de null en sede.
*/
 PROCEDURE ENCABEZADO_COMPLETO(
  PUSUARIO      DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%TYPE DEFAULT NULL,
  PPROVEDURIA   DBAFISICC.CAUSUARIOSCARRERASTB.PROVEEDURIA%TYPE DEFAULT NULL,
  PTODOS        number default 1,
  PINCLUYE_IDEA DBAFISICC.CACARRERASTB.ENTIDAD%type default 0,
  PACTIVAS      DBAFISICC.CACARRERASTB.STATUC%type default 1,
  RETVAL        OUT SYS_REFCURSOR
)
IS
BEGIN
  OPEN RETVAL FOR
      SELECT '0' ENTIDAD, ' TODAS' NOMBRE_ENTIDAD, '0' DIRECTOR,
        ' TODOS' NOMBRE_DIRECTOR, '0' SEDE, ' TODAS' NOMBRE_SEDE, '0' GRADO,
        ' TODOS' NOMBRE_GRADO, '0' CARRERA, ' TODAS' NOMBRE_CARRERA
      FROM DUAL
      WHERE PTODOS = 1
    UNION
      SELECT DISTINCT A.ENTIDAD,
        B.ENTIDAD||' - '||B.NOMBRE_CORTO||' - '||B.NOMBRE NOMBRE_ENTIDAD,
        A.ENCARGADO DIRECTOR,
        A.ENCARGADO||' - '||DBAFISICC.PKG_PERSONAL.NOMBRE(A.ENCARGADO,2)
        NOMBRE_DIRECTOR, NVL(a.COMENTARIOS,'0') SEDE, 
        nvl(A.comentarios,' TODAS') NOMBRE_SEDE, A.GRADO,
        C.DESCRIPCION NOMBRE_GRADO, A.CARRERA,
        DBAFISICC.PKG_CARRERA.NOMBRE(A.CARRERA, NULL, 5) NOMBRE_CARRERA
      FROM DBAFISICC.CACARRERASTB A, DBAFISICC.GNENTIDADESTB B,
        DBAFISICC.CAGRADOSTB C, DBAFISICC.CAUSUARIOSCARRERASTB D
      WHERE A.ENTIDAD     = B.ENTIDAD
        AND A.GRADO       = C.GRADO
        AND B.FACULTAD    = '002'
        AND D.CARRERA     = A.CARRERA
        AND (D.USUARIO    = PUSUARIO    OR PUSUARIO    IS NULL)
        AND (D.PROVEEDURIA = PPROVEDURIA OR PPROVEDURIA IS NULL)
        AND (A.ENTIDAD   <> '02'        OR PINCLUYE_IDEA = 1)
        AND (A.STATUC     = 'A'         OR PACTIVAS      = 0)
      order by NOMBRE_CARRERA;
END ENCABEZADO_COMPLETO;