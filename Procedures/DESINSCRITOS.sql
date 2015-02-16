/*
Autor:  Kevin Herrera.
Fecha:  06/03/2014
Descripcion: Devuelve todos los alumnos que fueron desinscritos, se puede
filtrar por carrera y usuarios.
*/
 procedure DESINSCRITOS  
  (    
    PUSUARIO DBAFISICC.CADESINSCRITOSTB.USUARIO%type default null,
    PCARNET DBAFISICC.CADESINSCRITOSTB.CARNET%type default null,
    PCARRERA DBAFISICC.CAUSUARIOSCARRERASTB.CARRERA%type default null,
    PCICLO DBAFISICC.CADESINSCRITOSTB.CARNET%type default null,
    PSECCION DBAFISICC.CADESINSCRITOSTB.SECCION%type default null,
    RETVAL  OUT SYS_REFCURSOR  
  )    
  as      
  begin    
  open RETVAL for 
  
  SELECT carnet, carrera, TO_CHAR (inscrito, 'dd/MM/yyyy') inscrito,
         TO_CHAR (fecha, 'dd/MM/yyyy') fecha, ciclo, seccion
    from DBAFISICC.CADESINSCRITOSTB
    where (CARNET = PCARNET or PCARNET is null)
    and   (CARRERA = PCARRERA or PCARRERA is null)
    and   (CICLO = PCICLO or PCICLO is null)
    and   (SECCION = PSECCION or PSECCION is null)
    and CARRERA in (select CARRERA 
                        from CAUSUARIOSCARRERASTB 
                        where USUARIO=PUSUARIO) 
  order by fecha desc;
 
 END DESINSCRITOS;