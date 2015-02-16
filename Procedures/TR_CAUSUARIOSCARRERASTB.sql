/*
autor: Kevin Herrera
FECHA: 26/02/2014
Descripcion: Procedimiento que inserta y elimina carreras por usuario
en la tabla CAUSUARIOSCARRERASTB.
*/

 procedure TR_CAUSUARIOSCARRERASTB  
  (    
    PUSUARIO DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%type default null,
    PCARRERA DBAFISICC.CAUSUARIOSCARRERASTB.CARRERA%type default null,
    PACCION varchar2
    ) 
  is
  begin 
  
  if PACCION = 'I' then
insert into DBAFISICC.causuarioscarrerastb(USUARIO,CARRERA)
  select PUSUARIO, carrera
    from DBAFISICC.cacarrerastb  
    where carrera in (SELECT * FROM TABLE(Split_varchar(PCARRERA,',')));
  
 elsif PACCION = 'D' then
    delete from DBAFISICC.CAUSUARIOSCARRERASTB 
    where USUARIO= PUSUARIO 
    and CARRERA=PCARRERA;
 end if;

END TR_CAUSUARIOSCARRERASTB;