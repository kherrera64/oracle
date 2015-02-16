/*
Autor:        Amilcar Martinez 
Fecha:        24/05/2013  
Descripcion:  Devuelve los datos necesarios para impresion de solvencias LASER   
              segun los siguientes paramatros:  
              PCARNET   -> Numero de carnet del alumno, puede recibir varios.  
              PCURSO    -> Codigo de curso que tiene asignado el alumno,  
                           puede recibir varios  
              PCARRERA  -> Codigo carrera, no admite null.  
              RETVAL    -> Devuelve un data set con los datos deseados
Modificacion: (03/06/2013) Amilcar Martinez  Se modifico la condicion para las 
fechas impartidas cuando vienen nulas
Modificacion: (11/06/2013) Amilcar Martinez  Se modificaron las restricciones 
para que muestre los cursos asignados por carnet aunque sean de otra carrera.
Modificacion: (11/02/2014) LMERIDA  se agrego la relacion de el campo carrera, 
de las tablas CAASIGNACIONESTB, CAHASIGNASTB, caalumcarrstb.
19/02/2014 - AALVARADO - Se cambio la forma de buscar si el alumno 
esta inscrito. 

Modificacion: (06/03/2014) Kevin Herrera Se agregaron los parametros de ciclo
y Seccion para que las solvencias puedan ser filtradas por los mismos.

Modificacion: (07/03/2014) Kevin Herrera se agregaron joins a todas las llaves
primarias de la tabla cacursosimptb.
*/  
PROCEDURE REP_SOLVENCIAS_LASER 
( 
   PCARRERA   clob,
   PCARNET    clob, 
   PCURSO     clob,
   PCICLO     IN DBAFISICC.cacursosimptb.CICLO%TYPE DEFAULT NULL,
   PSECCION   IN DBAFISICC.cacursosimptb.SECCION%TYPE DEFAULT NULL,
   PFECHAIMP  VARCHAR2 DEFAULT NULL,
   RETVAL     OUT SYS_REFCURSOR
) 
IS 
BEGIN
IF PFECHAIMP is NULL 
   THEN 
   
      open RETVAL for 
      select  a.CARNET CARNET3, a.CARRERA CARRERA3, a.SECCION, a.tipoasig, 
              b.descrip descripcion, a.curso, a.curso||a.tipoasig const,
              dbafisicc.pkg_alumno.nombre(a.carnet,1) nombre, a.carnet carnet4,
              a.carrera,dbafisicc.pkg_carrera.nombre(a.carrera,g.pensum,2)  
              nombre_corto,a.curso fcurso, 
              dbafisicc.pkg_curso.nombre(a.curso,a.carrera,g.pensum,1) fnombre
         from dbafisicc.CAASIGNACIONESTB a, dbafisicc.catipoasigtb b, 
              dbafisicc.cacursosimptb g
         where a.tipoasig=b.tipoasig 
         and g.curso = a.curso
         and G.SECCION = a.SECCION
         and g.carrera = a.carrera 
         and g.tipoasig = a.tipoasig
         and a.codstatus in ('S1','S4')
         --Verifica que el alumno este inscrito
         and exists 
             (select 1 
                 from dbafisicc.caalumcarrstb c
                 where c.carnet = a.carnet 
                 and c.inscrito = '1' 
                 and C.STATALUM <>'4'
                 and c.universidad = '002')
         and (a.tipoasig not like 'TE' and a.tipoasig not like 'PR' 
              and a.tipoasig not like 'SU')
        
         and (G.CICLO = PCICLO OR PCICLO IS NULL)
         AND (G.SECCION = PSECCION OR PSECCION IS NULL)
         AND (a.carnet IN (SELECT * FROM TABLE (dbafisicc.Split_varchar(PCARNET,
             ','))) or (PCARNET IS NULL))
         
         AND (a.carrera IN (SELECT * FROM TABLE (dbafisicc.Split_varchar(
             PCARRERA,','))) or PCARRERA is null)
         and (a.curso in (SELECT * FROM TABLE (dbafisicc.split_varchar(PCURSO,
              ',')))OR (PCURSO IS NULL))
         order by a.carnet;
    ELSE
      OPEN retval FOR 
          select  a.CARNET CARNET3, a.CARRERA CARRERA3, a.SECCION, a.tipoasig, 
              b.descrip descripcion, a.curso, a.curso||a.tipoasig const,
              dbafisicc.pkg_alumno.nombre(a.carnet,1) nombre, a.carnet carnet4,
              a.carrera,dbafisicc.pkg_carrera.nombre(a.carrera,g.pensum,2)  
              nombre_corto,a.curso fcurso, 
              dbafisicc.pkg_curso.nombre(a.curso,a.carrera,g.pensum,1) fnombre
             from dbafisicc.CAHASIGNASTB A, dbafisicc.catipoasigtb b, 
                dbafisicc.cahcursosimptb g
             where a.tipoasig=b.tipoasig
             and g.curso = a.curso
             and g.seccion = a.seccion
             and g.carrera = a.carrera
             and g.fechaimp = a.fechaimp 
             and g.tipoasig = a.tipoasig
             AND (G.CICLO = PCICLO OR PCICLO IS NULL)
             AND (a.SECCION = PSECCION OR PSECCION IS NULL)
             and a.codstatus in ('S1','S4')
             --Verifica que el alumno estuvo inscrito
             and exists 
                 (select 1 
                     from dbafisicc.cahinscritostb c
                     where c.carnet = a.carnet
                     and a.fechaimp = c.fechainscrito
                     and c.inscrito = '1' 
                     and c.statalum <>'4'
                     and c.universidad = '002')
            AND (a.carnet IN (SELECT * FROM TABLE (dbafisicc.Split_varchar(
                 PCARNET,','))) or (PCARNET IS NULL))
            and (a.tipoasig not like 'TE' and a.tipoasig not like 'PR' 
                and a.tipoasig not like 'SU')
            AND (a.carrera IN (SELECT * FROM TABLE (dbafisicc.Split_varchar(
                PCARRERA,',')))or PCARRERA IS NULL)
            and (a.curso in (SELECT * FROM TABLE (dbafisicc.split_varchar(
                 PCURSO,','))) OR (PCURSO IS NULL))
            AND TO_CHAR(A.fechaimp, 'MM/yyyy')= PFECHAIMP
            order by a.carnet;
      
    END IF;
   
  EXCEPTION 
    WHEN no_data_found then 
      OPEN RETVAL FOR 
         select 'NO SE ENCONTRO DATOS' CARNET3, null CARRERA3, null SECCION, 
            null TIPOASIG, null DESCRIPCION, null CURSO, null CONST,null NOMBRE, 
            null CARNET4, null CARRERA, null NOMBRE_CORTO, null FCURSO, 
            NULL fnombre
            from DUAL; 
END REP_SOLVENCIAS_LASER;
