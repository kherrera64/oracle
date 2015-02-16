/*
Nombre:       DBAFISICC.PKG_SEGURIDAD.PERMISOS_MODIFICA
Autor:        Miguel Barillas
Fecha:        2013-06-10  
Package:      PKG_SEGURIDAD  
Descripcion:  Procedimiento que modifica los permisos de los usuarios por
              carrera.
Modificacion: Miguel Barillas
Fecha:        05/09/2013
Descripcion:  Se agregaron los parametros PPROVEDURIA y PNOMINA devido a nuevos
              permisos en causuarioscarrerastb
AALVARADO - 10/09/2013 - Se cambio el nombre de la columna a Proveeduria

Modificacion: Kevin Herrera
Fecha:        02/04/2014
Descripcion:  Se agrego el parametro PDPI ya que a la tabla causuarioscarrerastb
              fue agregado el campo DPI
*/ 
 PROCEDURE PERMISOS_MODIFICA  
    (  
    PAUD_ACA          dbafisicc.causuarioscarrerastb.aud_aca%type,
    PPORTALES         dbafisicc.causuarioscarrerastb.portales%type,
    PSECRETARIA       dbafisicc.causuarioscarrerastb.secretaria%type,
    PINFO_CARRERA     dbafisicc.causuarioscarrerastb.info_carrera%type,
    PSOTRAMITE        dbafisicc.causuarioscarrerastb.sotramite%type,
    PAPERTURA_FECHA   dbafisicc.causuarioscarrerastb.apertura_fecha%type,
    PAPERTURA_CURSOS  dbafisicc.causuarioscarrerastb.apertura_cursos%type,
    PAPERTURA_HORARIOS  dbafisicc.causuarioscarrerastb.apertura_horarios%type,
    PAPERTURA_DETHORA dbafisicc.causuarioscarrerastb.apertura_dethora%type,
    PCONTROLACADEMICO dbafisicc.causuarioscarrerastb.controlacademico%type,
    PASISTENCIA       dbafisicc.causuarioscarrerastb.asistencia%type,
    PNOTAS            dbafisicc.causuarioscarrerastb.asistencia%type,
    PSOTRAMITE_CA     dbafisicc.causuarioscarrerastb.sotramite_ca%type,
    PMODIF_NOTA       dbafisicc.causuarioscarrerastb.modif_nota%type,
    PPROVEDURIA       dbafisicc.causuarioscarrerastb.proveeduria%type,
    PNOMINA           dbafisicc.causuarioscarrerastb.nomina%type,
    PCARRERA          dbafisicc.causuarioscarrerastb.carrera%type,
    PUSUARIO          DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%TYPE,
    PDPI              DBAFISICC.CAUSUARIOSCARRERASTB.DPI%TYPE,
    PSQLCODE     OUT NUMBER
    ) IS  
  BEGIN   
  
    UPDATE dbafisicc.causuarioscarrerastb A 
       SET  A.AUD_ACA = PAUD_ACA, 
            A.PORTALES = PPORTALES, 
            A.SECRETARIA = PSECRETARIA, 
            A.INFO_CARRERA = PINFO_CARRERA, 
            A.SOTRAMITE = PSOTRAMITE, 
            A.APERTURA_FECHA = PAPERTURA_FECHA, 
            A.APERTURA_CURSOS = PAPERTURA_CURSOS, 
            A.APERTURA_HORARIOS = PAPERTURA_HORARIOS,
            A.APERTURA_DETHORA = PAPERTURA_DETHORA,
            A.CONTROLACADEMICO = PCONTROLACADEMICO,
            A.ASISTENCIA = PASISTENCIA,
            A.NOTAS = PNOTAS,
            A.SOTRAMITE_CA = PSOTRAMITE_CA, 
            A.MODIF_NOTA = PMODIF_NOTA,
            A.PROVEEDURIA = PPROVEDURIA,
            A.NOMINA = PNOMINA,
            A.DPI = PDPI
      WHERE A.CARRERA = PCARRERA
        AND A.USUARIO = PUSUARIO;
        
      PSQLCODE := SQLCODE;  
      
  END PERMISOS_MODIFICA;