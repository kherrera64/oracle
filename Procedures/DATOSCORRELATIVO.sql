/*
autor: Kevin Herrera
FECHA: 18/02/2014
Descripcion: Procedimiento creado que devuelve los datos de un usuario
segun el codigo de personal
*/
  
 procedure DATOSCORRELATIVO  
  (    
    PCODPERS DBAFISICC.NOPERSONALTB.CODPERS%type default null,
    RETVAL  OUT SYS_REFCURSOR  
  )    
  as      
  begin    
  open RETVAL for 
  
  select CORRELATIVO,NOMBRE1 || ' ' || NOMBRE2 NOMBRE, APELLIDO1 || ' ' || 
  APELLIDO2 APELLIDO,EMAIL 
    from DBAFISICC.NOPERSONALTB 
    where CODPERS=PCODPERS;
 end DATOSCORRELATIVO;