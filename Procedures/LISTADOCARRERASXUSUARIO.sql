/*
autor: Kevin Herrera
FECHA: 26/02/2014
Descripcion: Procedimiento que devuelve las carreras que tiene asignadas
el usuario en CAUSUARIOSCARRERASTB.
*/

 procedure LISTADOCARRERASXUSUARIO  
  (    
    PUSUARIO DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%type default null,
    RETVAL  OUT SYS_REFCURSOR  
  )    
  as      
  begin    
  open RETVAL for 

  select B.USUARIO, a.CARRERA, a.NOMBRE 
    from DBAFISICC.CACARRERASTB a, DBAFISICC.CAUSUARIOSCARRERASTB B 
     where a.CARRERA=B.CARRERA 
     and B.USUARIO=PUSUARIO 
  order by a.CARRERA;

end LISTADOCARRERASXUSUARIO;