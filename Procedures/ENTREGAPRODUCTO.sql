/*AUTOR: KEVIN HERRERA    
  FECHA: 28/01/2014    
  DESCRIPCION: PROCEDIMIENTO CREADO PARA OBTENER LOS DATOS DEL    
  REPORTE DE ENTREGA DE PRODUCTOS DE PROVEEDURIA.  */   
  
  procedure ENTREGAPRODUCTO    
  (     
     PPEDIDO  PROVEEDURIA.PYCPEDIDOSTB.PEDIDO %type,      
     RETVAL    OUT SYS_REFCURSOR 
   )as       
  begin      
     open RETVAL for    
     
  select 
   E.PERIODO, C.CANTIDADAUTORIZADA as AUTORIZADO, 
   NVL(D.CANTIDAD,0) as ENTREGADO, NVL(D.PRECIO, 0) as PRECIO,
   G.NOENVIO as ENVIO, G.FECHA as FECHAENVIO, G.NIT, G.SERIE, G.NUMERO,
   H.FECHA as FECHAFACTURA, F.NOMBRE as PRODUCTO,
   (D.CANTIDAD * D.PRECIO) as TOTAL  
from
   PROVEEDURIA.PYCSOLICITUDTB B,
   PROVEEDURIA.PYCDETALLETB C,
   PROVEEDURIA.PYCDETALLEENTREGATB D,
   PROVEEDURIA.PYCPEDIDOSTB E,
   PROVEEDURIA.PYCPRODUCTOSTB F,
   PROVEEDURIA.PYCENVIOSTB G,
   PROVEEDURIA.PYCFACTURASTB H  
where
   E.PEDIDO = PPEDIDO  
   and C.NOSOLICITUD = B.NOSOLICITUD  
   and D.NOSOLICITUD(+) = C.NOSOLICITUD  
   and D.LINEA(+) = C.LINEA  
   and E.PEDIDO = B.PEDIDO  
   and F.CODCATEGORIA = C.CODCATEGORIA  
   and F.CODSUBCATEGORIA = C.CODSUBCATEGORIA  
   and F.CODPRODUCTO = C.CODPRODUCTO  
   and G.NOENVIO(+) = D.NOENVIO  
   and H.NIT(+) = G.NIT  
   and H.SERIE(+) = G.SERIE  
   and H.NUMERO(+) = G.NUMERO  
   and C.AUTORIZAR = 1;    
end ENTREGAPRODUCTO;