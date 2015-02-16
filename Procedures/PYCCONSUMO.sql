/*AUTOR: KEVIN HERRERA
  FECHA: 27/01/2013
  DESCRIPCI�N: PROCEDIMIENTO CREADO PARA OBTENER LOS DATOS DEL
  REPORTE DE COMSUMO MENSUAL DE PRODUCTOS DE PROVEEDURIA.
*/
PROCEDURE PYCCONSUMO
  (
    PCODPERIODO  IN PROVEEDURIA.PYCSOLICITUDTB.CODPERIODO %TYPE,
    PENTIDAD  IN PROVEEDURIA.PYCSOLICITUDTB.ENTIDAD%TYPE,
    PDIVISION  IN PROVEEDURIA.PYCSOLICITUDTB.DIVISION%TYPE,
    RETVAL    OUT SYS_REFCURSOR
  )AS
  
 BEGIN
    OPEN RETVAL FOR
 
 SELECT
    SUM(TMP.CANTIDAD) AS CANTIDAD, ROUND(AVG(TMP.PRECIO),2) AS PRECIO,
    TMP.PRODUCTO, TMP.ENTIDAD, TMP.DIVISION, TMP.CATEGORIA    
FROM
    (    SELECT NVL(A.CANTIDAD, 0) AS CANTIDAD,NVL(A.PRECIO, 0) AS PRECIO,
        C.NOMBRE AS PRODUCTO, D.CODPERIODO, E.NOMBRE AS ENTIDAD,
        F.NOMBRE AS DIVISION, G.NOMBRE AS CATEGORIA    
    FROM
        PROVEEDURIA.PYCDETALLEENTREGATB A,
        PROVEEDURIA.PYCDETALLETB B,
        PROVEEDURIA.PYCPRODUCTOSTB C,
        PROVEEDURIA.PYCSOLICITUDTB D,
        DBAFISICC.GNENTIDADESTB E,
        DBAFISICC.GNDIVISIONESTB F,
        PROVEEDURIA.PYCCATEGORIASTB G    
    WHERE
        B.NOSOLICITUD = A.NOSOLICITUD    
        AND B.LINEA = A.LINEA    
        AND B.AUTORIZAR = 1    
        AND C.CODCATEGORIA = B.CODCATEGORIA    
        AND C.CODSUBCATEGORIA = B.CODSUBCATEGORIA    
        AND C.CODPRODUCTO = B.CODPRODUCTO    
        AND D.NOSOLICITUD = B.NOSOLICITUD    
        AND E.ENTIDAD = D.ENTIDAD    
        AND F.FACULTAD = E.FACULTAD    
        AND F.ENTIDAD = E.ENTIDAD    
        AND F.ENTIDAD = D.ENTIDAD    
        AND F.DIVISION = D.DIVISION    
        AND C.CODCATEGORIA = G.CODCATEGORIA    
        AND TO_CHAR(D.CODPERIODO, 'yyyy-MM') = TO_CHAR(PCODPERIODO, 'yyyy-MM')    
        AND ( D.ENTIDAD = PENTIDAD OR PENTIDAD IS NULL)    
        AND ( D.DIVISION = PDIVISION  OR PDIVISION IS NULL)    
    ORDER BY G.NOMBRE, C.NOMBRE ) TMP    
GROUP BY TMP.PRODUCTO, TMP.ENTIDAD, TMP.DIVISION, TMP.CATEGORIA;

END PYCCONSUMO;