/*
autor: Kevin Herrera
FECHA: 18/02/2014
Descripcion: Procedimiento que devuelve todos los usuarios del sistema.
*/
  
procedure USUARIOS  
  (    
    RETVAL  OUT SYS_REFCURSOR  
  )    
  as      
  begin    
  open RETVAL for 

  select USUARIO,NOMBRE,REFERENCIA 
  from DBAFISICC.GNUSUARIOSTB 
  order by  NOMBRE;

end USUARIOS;