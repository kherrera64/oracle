/* 
Nombre:       DBAFISICC.PKG_CATALOGOSTR.TR_CASALONESTB 
Autor:        Roberto Castro 
Fecha:        01/08/2012 
Package:      PKG_DIGITALIZACION 
Descripcion:  Mantenimiento para salones 

Modificacion: Autor: Kevin Herrera.
Fecha: 03/04/2014 
Descripcion: Se agregaron los campos Abreviatura y Nombre a la tabla 
             CASALONESTB por lo que se agregan tambien como parametros.

*/ 
  PROCEDURE TR_CASALONESTB 
    ( 
    PTORRE            IN DBAFISICC.CASALONESTB.TORRE%TYPE 
    ,PSALON           IN DBAFISICC.CASALONESTB.SALON%TYPE 
    ,PNOMBRE          IN DBAFISICC.CASALONESTB.NOMBRE%TYPE DEFAULT NULL 
    ,PALIAS           IN DBAFISICC.CASALONESTB.ABREVIATURA%TYPE DEFAULT NULL 
    ,PCUPO            IN DBAFISICC.CASALONESTB.CUPO%TYPE DEFAULT NULL 
    ,PINTERNET        IN DBAFISICC.CASALONESTB.INTERNET%TYPE DEFAULT NULL 
    ,PTIPOSALON       IN DBAFISICC.CASALONESTB.TIPOSALON%TYPE DEFAULT NULL 
    ,PAREA            IN DBAFISICC.CASALONESTB.AREA%TYPE DEFAULT NULL 
    ,PCORR_AUDIV      IN DBAFISICC.CASALONESTB.CORR_AUDIV%TYPE DEFAULT NULL 
    ,PMOD_CAN         IN DBAFISICC.CASALONESTB.MOD_CAN%TYPE DEFAULT NULL 
    ,PPANTALLA        IN DBAFISICC.CASALONESTB.PANTALLA%TYPE DEFAULT NULL 
    ,PBOX_CABLES      IN DBAFISICC.CASALONESTB.BOX_CABLES%TYPE DEFAULT NULL 
    ,PBOX_CONTROLS    IN DBAFISICC.CASALONESTB.BOX_CONTROLS%TYPE DEFAULT NULL 
    ,PPROYECTOR       IN DBAFISICC.CASALONESTB.PROYECTOR%TYPE DEFAULT NULL 
    ,PMESAS_CANT      IN DBAFISICC.CASALONESTB.MESAS_CANT%TYPE DEFAULT NULL 
    ,PMESAS_DESC      IN DBAFISICC.CASALONESTB.MESAS_DESC%TYPE DEFAULT NULL 
    ,PSILLAS_CANT     IN DBAFISICC.CASALONESTB.SILLAS_CANT%TYPE DEFAULT NULL 
    ,PSILLAS_DESC     IN DBAFISICC.CASALONESTB.SILLAS_DESC%TYPE DEFAULT NULL 
    ,PPUPITRES_CANT   IN DBAFISICC.CASALONESTB.PUPITRES_CANT%TYPE DEFAULT NULL 
    ,PPUPITRES_DESC   IN DBAFISICC.CASALONESTB.PUPITRES_DESC%TYPE DEFAULT NULL 
    ,PBANCOS_CANT     IN DBAFISICC.CASALONESTB.BANCOS_CANT%TYPE DEFAULT NULL 
    ,PBANCOS_DESC     IN DBAFISICC.CASALONESTB.BANCOS_DESC%TYPE DEFAULT NULL 
    ,PMESADIBUJO_CANT IN DBAFISICC.CASALONESTB.MESADIBUJO_CANT%TYPE DEFAULT NULL 
    ,PMESADIBUJO_DESC IN DBAFISICC.CASALONESTB.MESADIBUJO_DESC%TYPE DEFAULT NULL 
    ,PSQLCODE OUT NUMBER 
    ,PACCION IN VARCHAR2 
    ) IS 
     
  BEGIN 
   
    IF PACCION = 'I' 
    THEN 
 
        INSERT INTO DBAFISICC.CASALONESTB 
          (           
          TORRE 
          ,SALON 
          ,NOMBRE
          ,CUPO 
          ,INTERNET 
          ,TIPOSALON 
          ,AREA 
          ,CORR_AUDIV 
          ,MOD_CAN 
          ,PANTALLA 
          ,BOX_CABLES 
          ,BOX_CONTROLS 
          ,PROYECTOR 
          ,MESAS_CANT 
          ,MESAS_DESC 
          ,SILLAS_CANT 
          ,SILLAS_DESC 
          ,PUPITRES_CANT 
          ,PUPITRES_DESC 
          ,BANCOS_CANT 
          ,BANCOS_DESC 
          ,MESADIBUJO_CANT 
          ,MESADIBUJO_DESC
          ,ABREVIATURA
          ) 
        VALUES 
          ( 
          PTORRE 
          ,PSALON 
          ,PNOMBRE
          ,PCUPO 
          ,PINTERNET 
          ,PTIPOSALON 
          ,PAREA 
          ,PCORR_AUDIV 
          ,PMOD_CAN 
          ,PPANTALLA 
          ,PBOX_CABLES 
          ,PBOX_CONTROLS 
          ,PPROYECTOR 
          ,PMESAS_CANT 
          ,PMESAS_DESC 
          ,PSILLAS_CANT 
          ,PSILLAS_DESC 
          ,PPUPITRES_CANT 
          ,PPUPITRES_DESC 
          ,PBANCOS_CANT 
          ,PBANCOS_DESC 
          ,PMESADIBUJO_CANT 
          ,PMESADIBUJO_DESC 
          ,PALIAS
          ); 
 
    ELSIF PACCION = 'U' 
    THEN 
     
        UPDATE DBAFISICC.CASALONESTB 
            SET  
                CUPO            = PCUPO 
                ,NOMBRE         = PNOMBRE
                ,INTERNET       = PINTERNET 
                ,TIPOSALON      = PTIPOSALON 
                ,AREA           = PAREA 
                ,CORR_AUDIV     = PCORR_AUDIV 
                ,MOD_CAN        = PMOD_CAN 
                ,PANTALLA       = PPANTALLA 
                ,BOX_CABLES     = PBOX_CABLES 
                ,BOX_CONTROLS   = PBOX_CONTROLS 
                ,PROYECTOR      = PPROYECTOR 
                ,MESAS_CANT     = PMESAS_CANT 
                ,MESAS_DESC     = PMESAS_DESC 
                ,SILLAS_CANT    = PSILLAS_CANT 
                ,SILLAS_DESC    = PSILLAS_DESC 
                ,PUPITRES_CANT  = PPUPITRES_CANT 
                ,PUPITRES_DESC  = PPUPITRES_DESC 
                ,BANCOS_CANT    = PBANCOS_CANT 
                ,BANCOS_DESC    = PBANCOS_DESC 
                ,MESADIBUJO_CANT  = PMESADIBUJO_CANT 
                ,MESADIBUJO_DESC  = PMESADIBUJO_DESC
                ,ABREVIATURA      = PALIAS 
            WHERE 
                TORRE  = PTORRE 
                 AND SALON  = PSALON; 
     
    ELSIF PACCION = 'D' 
    THEN 
     
        DELETE FROM DBAFISICC.CASALONESTB 
            WHERE 
                TORRE  = PTORRE 
                 AND SALON  = PSALON; 
     
    END IF; 
     
    PSQLCODE := SQLCODE; 
     
  EXCEPTION 
    WHEN OTHERS 
    THEN 
        PSQLCODE := SQLCODE; 
        
END TR_CASALONESTB; 