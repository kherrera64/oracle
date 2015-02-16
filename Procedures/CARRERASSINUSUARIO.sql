/*
autor: Kevin Herrera
FECHA: 26/02/2014
Descripcion: Procedimiento que devuelve las carreras que no tiene asignadas
el usuario en CAUSUARIOSCARRERASTB.
*/

 procedure CARRERASSINUSUARIO  
  (    
    PUSUARIO DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%type default null,
    PSTATUS DBAFISICC.CACARRERASTB.STATUC%type default null,
    PCODIGO DBAFISICC.CACARRERASTB.CARRERA%type default null,
    PNOMBRE DBAFISICC.CACARRERASTB.NOMBRE%type default null,
    PENTIDAD DBAFISICC.CACARRERASTB.ENTIDAD%type default null,
    RETVAL  OUT SYS_REFCURSOR  
  )    
  as      
  begin    
  open RETVAL for 

  select a.CARRERA,a.NOMBRE || ' - ' || a.COMENTARIOS as NOMBRE 
   from DBAFISICC.CACARRERASTB a 
    where (a.STATUC = PSTATUS or PSTATUS is null)
    and (a.CARRERA like '%'||PCODIGO||'%' or PCODIGO is null)
    and (a.NOMBRE like '%'||PNOMBRE||'%' or PNOMBRE is null)
    and (a.ENTIDAD = PENTIDAD or PENTIDAD IS NULL)
    and a.CARRERA not in(select B.CARRERA 
                         from DBAFISICC.CAUSUARIOSCARRERASTB B 
                         where B.USUARIO=PUSUARIO) 
  order by a.carrera;

END CARRERASSINUSUARIO;