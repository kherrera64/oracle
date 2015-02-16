/*
Autor:  Kevin Herrera.
Fecha:  11/03/2014
Descripcion: Devuelve un catalogo de conceptos que se pueden manejar en 
estado de cuenta.
*/
 procedure CONCEPTOSEDOCTA  
  (    
    RETVAL  OUT SYS_REFCURSOR  
  )    
  as      
  begin    
  open RETVAL for 

    select distinct  CONCEPTO, CODMOVTO 
     from  DBAFISICC.CCHEDOCTADETALLETB
      where CONCEPTO is not null
      and CODMOVTO is not null
    order by CONCEPTO;
    
 END CONCEPTOSEDOCTA;    