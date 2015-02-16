/*
Nombre:       DBAFISICC.PKG_SEGURIDAD.PERMISOSXCARRERA
Autor:        Luis Merida  
Fecha:        2013-05-02  
Package:      PKG_SEGURIDAD  
Descripcion:  Procedimiento que devuelve los permisos por carrera
              de los usuarios. 
Modificaciones: 
MBARILLAS - 12/07/2013 - Se agregaron los esquemas y tipos de 
datos correspondientes a los parametros, se corrigio la identacion
MBARILLAS - 07/08/2013 - Se agregaron nvl por si existian campos 
null en los permisos
MBARILLAS - 05/09/2013 -se modifico para que incluya los valores 
de los nuevos permisosproveduria y nomina
AALVARADO - 10/09/2013 - Se cambio el nombre de la columna a Proveeduria
MBARILLAS - 11/09/2013 - Se cambio el tipo de dato de el parametro PUSUARIO

Modificacion: Kevin Herrera
Fecha:        02/04/2014
Descripcion:  Se agrego a la tabla causuarioscarrerastb el campo DPI por lo que
              tambien se agrego al select del procedimiento.
*/ 
PROCEDURE PERMISOSXCARRERA
(
    PENTIDAD   dbafisicc.cacarrerastb.facultad%type DEFAULT NULL,
    PENCARGADO dbafisicc.cacarrerastb.encargado%type DEFAULT NULL,
    PSEDE      dbafisicc.cacarrerastb.comentarios%type DEFAULT NULL,
    PGRADO     dbafisicc.cacarrerastb.grado%type DEFAULT NULL,
    PCARRERA   dbafisicc.causuarioscarrerastb.carrera%type DEFAULT NULL,
    PSTATUS    dbafisicc.cacarrerastb.statuc%type DEFAULT NULL,
    PUSUARIO   CLOB,
    RETVAL    OUT SYS_REFCURSOR
)
IS
BEGIN
 open retval for 
    SELECT c.referencia, c.nombre, a.usuario, a.carrera, nvl(a.aud_aca,0) aud_aca, 
    nvl(a.portales,0) portales, nvl(a.secretaria,0) secretaria, 
    nvl(a.info_carrera,0) info_carrera, nvl(a.sotramite,0) sotramite, 
    nvl(a.apertura_fecha,0) apertura_fecha, nvl(a.apertura_cursos,0) 
    apertura_cursos ,nvl(a.apertura_horarios,0) apertura_horarios, 
    nvl(a.apertura_dethora, 0) apertura_dethora,nvl(a.controlacademico,0) 
    controlacademico, nvl(a.asistencia,0) asistencia, nvl(a.notas,0) notas, 
    NVL(A.SOTRAMITE_CA,0) SOTRAMITE_CA, NVL(A.MODIF_NOTA,0) MODIF_NOTA, 
    nvl(a.proveeduria,0) proveduria, nvl(a.nomina,0) nomina, nvl(a.DPI,0) DPI
      FROM dbafisicc.causuarioscarrerastb a, dbafisicc.cacarrerastb b, 
           dbafisicc.gnusuariostb c
          where a.carrera=b.carrera
            and a.usuario = c.usuario
            and (b.entidad= PENTIDAD OR PENTIDAD IS NULL)
            and (b.encargado=PENCARGADO OR PENCARGADO IS NULL)
            and (b.comentarios =PSEDE OR PSEDE IS NULL)
            and (b.grado = PGRADO OR PGRADO IS NULL)
            and (a.carrera = PCARRERA OR PCARRERA IS NULL)
            and (b.statuc = PSTATUS OR PSTATUS IS NULL)
            and (c.usuario IN (SELECT * FROM TABLE(Split_varchar(PUSUARIO,','))))
ORDER BY A.CARRERA;
END PERMISOSXCARRERA;