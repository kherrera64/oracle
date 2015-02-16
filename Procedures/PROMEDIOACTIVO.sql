 /*
autor: Kevin Herrera
FECHA: 26/03/2014
Descripcion: Procedimiento que devuelve los alumnos por promedio pudiendo
             filtrar por promedio.
*/

PROCEDURE PROMEDIOACTIVO
(
  PCARRERA DBAFISICC.caalumcarrstb.CARRERA%TYPE DEFAULT NULL,
  PPROMEDIO DBAFISICC.caalumnosnotastb.nota%TYPE DEFAULT NULL,
  PSIGNO varchar2,
  RETVAL OUT SYS_REFCURSOR
)
 IS
 BEGIN

 IF PSIGNO = '>' THEN
  OPEN RETVAL FOR
  
   SELECT Carrera, Carnet, Status, Ciclo, Pensum, Alumno, Promedio 
 
    FROM (SELECT  A.carrera,A.carnet,
          decode(A.inscrito,1,'Inscrito','Activo') status,A.ciclo,A.pensum,
          b.nombre1||' '||b.nombre2||' '||b.apellido1||' '||b.apellido2 alumno,
          TRUNC(sum(c.nota*c.umas)/decode(sum(c.umas),0,1,sum(c.umas))) promedio 
          
             FROM DBAFISICC.caalumcarrstb A, DBAFISICC.caalumnostb b, 
             DBAFISICC.caalumnosnotastb c 
             WHERE b.carnet = A.carnet AND c.carrera = A.carrera 
             AND c.carnet = A.carnet 
             AND (A.inscrito = 1 OR (A.inscrito = 0 AND A.statalum = 'A')) 
             AND c.codstatus = 'S6' AND c.tipoasig NOT IN ('EQ') 
             AND A.CARRERA = PCARRERA
             HAVING TRUNC(sum(c.nota*c.umas)/sum(c.umas)) > PPROMEDIO 
             GROUP BY A.carrera,A.carnet,
             decode(A.inscrito,1,'Inscrito','Activo'), A.ciclo, A.pensum,
             b.nombre1||' '||b.nombre2||' '||b.apellido1||' '|| b.apellido2 )
             
    ORDER BY status, promedio DESC;
  
  ELSIF PSIGNO = '<' THEN
   OPEN RETVAL FOR
   
   SELECT Carrera, Carnet, Status, Ciclo, Pensum, Alumno, Promedio 
 
    FROM (SELECT  A.carrera,A.carnet,
          decode(A.inscrito,1,'Inscrito','Activo') status,A.ciclo,A.pensum,
          b.nombre1||' '||b.nombre2||' '||b.apellido1||' '||b.apellido2 alumno,
          TRUNC(sum(c.nota*c.umas)/decode(sum(c.umas),0,1,sum(c.umas))) promedio 
          
             FROM DBAFISICC.caalumcarrstb A, DBAFISICC.caalumnostb b, 
             DBAFISICC.caalumnosnotastb c 
             WHERE b.carnet = A.carnet AND c.carrera = A.carrera 
             AND c.carnet = A.carnet 
             AND (A.inscrito = 1 OR (A.inscrito = 0 AND A.statalum = 'A')) 
             AND c.codstatus = 'S6' AND c.tipoasig NOT IN ('EQ') 
             AND A.CARRERA = PCARRERA
             HAVING TRUNC(sum(c.nota*c.umas)/sum(c.umas)) < PPROMEDIO 
             GROUP BY A.carrera,A.carnet,
             decode(A.inscrito,1,'Inscrito','Activo'), A.ciclo, A.pensum,
             b.nombre1||' '||b.nombre2||' '||b.apellido1||' '|| b.apellido2 )
             
    ORDER BY status, promedio DESC;
     
  ELSIF PSIGNO = '>=' THEN
   OPEN RETVAL FOR
   
   SELECT Carrera, Carnet, Status, Ciclo, Pensum, Alumno, Promedio 
 
    FROM (SELECT  A.carrera,A.carnet,
          decode(A.inscrito,1,'Inscrito','Activo') status,A.ciclo,A.pensum,
          b.nombre1||' '||b.nombre2||' '||b.apellido1||' '||b.apellido2 alumno,
          TRUNC(sum(c.nota*c.umas)/decode(sum(c.umas),0,1,sum(c.umas))) promedio 
          
             FROM DBAFISICC.caalumcarrstb A, DBAFISICC.caalumnostb b, 
             DBAFISICC.caalumnosnotastb c 
             WHERE b.carnet = A.carnet AND c.carrera = A.carrera 
             AND c.carnet = A.carnet 
             AND (A.inscrito = 1 OR (A.inscrito = 0 AND A.statalum = 'A')) 
             AND c.codstatus = 'S6' AND c.tipoasig NOT IN ('EQ') 
             AND A.CARRERA = PCARRERA
             HAVING TRUNC(sum(c.nota*c.umas)/sum(c.umas)) >= PPROMEDIO 
             GROUP BY A.carrera,A.carnet,
             decode(A.inscrito,1,'Inscrito','Activo'), A.ciclo, A.pensum,
             b.nombre1||' '||b.nombre2||' '||b.apellido1||' '|| b.apellido2 )
             
    ORDER BY status, promedio DESC;
     
  ELSIF PSIGNO = '<=' THEN
   OPEN RETVAL FOR
   
   SELECT Carrera, Carnet, Status, Ciclo, Pensum, Alumno, Promedio 
 
    FROM (SELECT  A.carrera,A.carnet,
          decode(A.inscrito,1,'Inscrito','Activo') status,A.ciclo,A.pensum,
          b.nombre1||' '||b.nombre2||' '||b.apellido1||' '||b.apellido2 alumno,
          TRUNC(sum(c.nota*c.umas)/decode(sum(c.umas),0,1,sum(c.umas))) promedio 
          
             FROM DBAFISICC.caalumcarrstb A, DBAFISICC.caalumnostb b, 
             DBAFISICC.caalumnosnotastb c 
             WHERE b.carnet = A.carnet AND c.carrera = A.carrera 
             AND c.carnet = A.carnet 
             AND (A.inscrito = 1 OR (A.inscrito = 0 AND A.statalum = 'A')) 
             AND c.codstatus = 'S6' AND c.tipoasig NOT IN ('EQ') 
             AND A.CARRERA = PCARRERA
             HAVING TRUNC(sum(c.nota*c.umas)/sum(c.umas)) <= PPROMEDIO 
             GROUP BY A.carrera,A.carnet,
             decode(A.inscrito,1,'Inscrito','Activo'), A.ciclo, A.pensum,
             b.nombre1||' '||b.nombre2||' '||b.apellido1||' '|| b.apellido2 )
             
    ORDER BY status, promedio DESC;
  
 ELSIF PSIGNO = '=' THEN
  OPEN RETVAL FOR
   
   SELECT Carrera, Carnet, Status, Ciclo, Pensum, Alumno, Promedio 
 
    FROM (SELECT  A.carrera,A.carnet,
          decode(A.inscrito,1,'Inscrito','Activo') status,A.ciclo,A.pensum,
          b.nombre1||' '||b.nombre2||' '||b.apellido1||' '||b.apellido2 alumno,
          TRUNC(sum(c.nota*c.umas)/decode(sum(c.umas),0,1,sum(c.umas))) promedio 
          
             FROM DBAFISICC.caalumcarrstb A, DBAFISICC.caalumnostb b, 
             DBAFISICC.caalumnosnotastb c 
             WHERE b.carnet = A.carnet AND c.carrera = A.carrera 
             AND c.carnet = A.carnet 
             AND (A.inscrito = 1 OR (A.inscrito = 0 AND A.statalum = 'A')) 
             AND c.codstatus = 'S6' AND c.tipoasig NOT IN ('EQ') 
             AND A.CARRERA = PCARRERA
             HAVING TRUNC(sum(c.nota*c.umas)/sum(c.umas)) = PPROMEDIO 
             GROUP BY A.carrera,A.carnet,
             decode(A.inscrito,1,'Inscrito','Activo'), A.ciclo, A.pensum,
             b.nombre1||' '||b.nombre2||' '||b.apellido1||' '|| b.apellido2 )
             
    ORDER BY status, promedio DESC;
    
  END IF;
   
END PROMEDIOACTIVO;
  