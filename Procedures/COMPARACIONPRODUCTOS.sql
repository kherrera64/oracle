/*AUTOR: KEVIN HERRERA        
  FECHA: 28/01/2014        
  DESCRIPCION: PROCEDIMIENTO CREADO PARA OBTENER LOS DATOS DEL        
  REPORTE DE COMPARACION DE PRODUCTOS DE PROVEEDURIA.  */        
 
  procedure COMPARACIONPRODUCTOS        
  (            
    PENTIDAD  PROVEEDURIA.PYCSOLICITUDTB.ENTIDAD %type,         
    PDIVISION  PROVEEDURIA.PYCSOLICITUDTB.DIVISION %type,       
    PANIO  PROVEEDURIA.PYCFACTURASTB.FECHA %type,     
    RETVAL    OUT SYS_REFCURSOR      
    )as           
    
  begin             
    open RETVAL for  
      
  select ROW_NUMBER() 
   over ( order by T2.PRODUCTO) no, T2.PRODUCTO, max(TO_CHAR(T2.FECHA,'MM')) 
   as FECHA, T2.CATEGORIA, T2.ENTIDAD, min(T2.PRECIO) as MINIMO, 
   avg(t2.precio) as promedio, max(t2.precio) as maximo  
from
   (  select tmp.producto, tmp.precio, tmp.fecha, tmp.categoria, tmp.entidad  
   from
      (  select distinct B.NOMBRE PRODUCTO, E.PRECIO, F.FECHA , 
         g.nombre categoria, j.nombre entidad     
      from
         proveeduria.pycproductosTB b,
         proveeduria.pycdetalleTB c,
         proveeduria.pycsolicitudTB d,
         PROVEEDURIA.pycdetalleentregaTB e,
         PROVEEDURIA.pycenviosTB f,
         PROVEEDURIA.pyccategoriasTB g,
         PROVEEDURIA.pycpedidosTB i,
         dbafisicc.gnentidadestb j,
         proveeduria.pycfacturasTB k       
      where
         c.codcategoria = b.codcategoria     
         and c.codsubcategoria = b.codsubcategoria     
         and c.codproducto = b.codproducto     
         and d.nosolicitud = c.nosolicitud     
         and e.nosolicitud = c.nosolicitud     
         and e.linea =  c.linea     
         and f.noenvio = e.noenvio     
         and g.codcategoria = c.codcategoria     
         and i.pedido = D.pedido     
         and j.entidad = d.entidad     
         and k.nit = f.nit     
         and k.serie = f.serie     
         and K.NUMERO = F.NUMERO     
         and (D.ENTIDAD = PENTIDAD or PENTIDAD is null)     
         and (d.division = PDIVISION or PDIVISION is null)      
         and C.AUTORIZAR = 1      
         and TO_CHAR(K.FECHA,'yyyy') = EXTRACT(YEAR FROM PANIO)
      order by
         CATEGORIA, PRODUCTO  ) TMP  ) T2  
   group by T2.PRODUCTO, T2.CATEGORIA, T2.ENTIDAD;
      
  END COMPARACIONPRODUCTOS;