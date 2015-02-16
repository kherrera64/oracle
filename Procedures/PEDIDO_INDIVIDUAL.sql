/*
Autor:        Jorge Velasquez
Fecha:        23/09/2013
Descripcion:  Devuelve los datos del pedido necesarios para llenar el reporte
              de pedidos individuales.
Modificacion: JVELASQUEZ - 30/09/2013: Se agrego la capacidad de obtener los
              resultados por solicitud de tramite.
Modificacion: KHERRERA - 30/01/2014: Se agrego el campo CC, el cual es una 
              funcion que devuelve los datos de las carreras por CC.
              
*/
PROCEDURE PEDIDO_INDIVIDUAL
(
  PPEDIDO IN PROVEEDURIA.PYCSOLICITUDTB.PEDIDO%TYPE DEFAULT NULL,
  PSOLTRAMITE IN PROVEEDURIA.PYCSOLICITUDTB.SOLICITUDTRAMITE%TYPE DEFAULT NULL,
  RETVAL  OUT SYS_REFCURSOR
)AS
BEGIN
  open RETVAL for
    SELECT A.NOSOLICITUD, A.SOLICITUDTRAMITE, A.FECHA, A.CODPERIODO,
          DBAFISICC.PKG_PERSONAL.NOMBRE(A.CODPERS,1) DIRECTOR,
          NVL(a.DIVISION, B.ENTIDAD)||'-'||NVL(
          DBAFISICC.PKG_SEGURIDAD.DEPARTAMENTODYN(a.DIVISION),
          B.NOMBRE_CORTO||'-'||B.NOMBRE) ENTIDAD, a.NOPERSONAS, H.NOMBRETORRE,
          a.SALON, a.EXTENSION, a.OBSERVACIONES_PLANO OBSERVACIONES, F.LINEA,
          F.CANTIDADPEDIDA,  F.CANTIDADAUTORIZADA,
          F.COMENTARIOPYC, F.USUARIOS, G.NOMBRE AS PRODUCTO,
          NVL(F.AUTORIZAR,0) as AUTORIZAR, a.PEDIDO,
          PROVEEDURIA.PKG_PROVEEDURIA.SEL_BUSCARCARRERASSOLICITUD(a.NOSOLICITUD)
          CC
        from PROVEEDURIA.PYCSOLICITUDTB a, DBAFISICC.GNENTIDADESTB B,
          PROVEEDURIA.PYCDETALLETB F, PROVEEDURIA.PYCPRODUCTOSTB G,
          DBAFISICC.CATORRESTB H
        WHERE B.FACULTAD(+)       = '002' 
          AND B.Entidad(+)        = A.Entidad
          AND F.NOSOLICITUD       = A.NOSOLICITUD
          AND G.CODCATEGORIA      = F.CODCATEGORIA
          AND G.CODSUBCATEGORIA   = F.CODSUBCATEGORIA
          and G.CODPRODUCTO       = F.CODPRODUCTO
          and H.CODIGOTORRE       = a.TORRE
          and (a.PEDIDO           = PPEDIDO     or PPEDIDO is null)
          and (a.SOLICITUDTRAMITE = PSOLTRAMITE or PSOLTRAMITE is null)
        order by a.NOSOLICITUD, F.LINEA;
END PEDIDO_INDIVIDUAL;