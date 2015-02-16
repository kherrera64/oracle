alter table TEMP_RINGRESOSTIPOPAGO add R varchar2(20);
CREATE TABLE TEMP_RINGRESOSTIPOPAGO
delete from TEMP_RINGRESOSTIPOPAGO;

drop table TEMP_RINGRESOSTIPOPAGO cascade constraints;

  select  CARRERA, ENCARGADO, NOMBRE, COMENTARIOS, 
              CODMOVTO, FACULTAD, FACNAME, PCT, CARNAME, DESMOVTO, R, NDT, NCT, 
              REFECTIVO, RCHEQUESBI, RCHEQUESOT, RTARJETAS, RMQSERIESAG, 
              RMQSERIESIN
          
          from DBAFISICC.TEMP_RINGRESOSTIPOPAGO
              
          
     group by CARRERA, ENCARGADO, NOMBRE, COMENTARIOS, 
              CODMOVTO, FACULTAD, FACNAME, PCT, CARNAME, DESMOVTO, R, NDT, NCT, 
              REFECTIVO, RCHEQUESBI, RCHEQUESOT, RTARJETAS, RMQSERIESAG, 
              RMQSERIESIN;  
              
 create table TEMP_RINGRESOSTIPOPAGO
 (
   CARRERA     varchar(50),
   ENCARGADO   varchar(50),
   NOMBRE      varchar(50),
   COMENTARIOS varchar(50),
   CODMOVTO    varchar(50),
   FACULTAD    varchar(50),
   FACNAME     varchar(50),
   PCT         varchar(50),
   CARNAME     varchar(50),
   DESMOVTO    varchar(50),
   R           number,
   NDT         number,
   NCT         number,
   REFECTIVO   number,
   RCHEQUESBI  number,
   RCHEQUESOT  number,
   RTARJETAS   number,
   RMQSERIESAG number,
   RMQSERIESIN number
 );    
 
  create table TEMP_TARJETASLIQUIDACION
 (
   CARRERA     varchar(50),
   RTARJETAS   varchar(50)
 );                          
