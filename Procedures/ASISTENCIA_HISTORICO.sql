/*MODIFICACION.
AUTOR: KEVIN HERRERA
FECHA: 16/01/2014
DESCRIPCION: MODIFICACION AL PROCEDIMIENTO PARA QUE ESTE PUEDA MANEJAR LOS 
TIPOS DE FECHA EN EL PARAMETRO PFECHAIMP*/ 

PROCEDURE ASISTENCIA_HISTORICO
  (
    PFECHAIMP  IN cahasignastb.fechaimp%TYPE,
    RETVAL    OUT sys_refcursor
  )AS
  
 BEGIN
    OPEN RETVAL FOR
select '' AS USUARIO, b.horario, '' AS DESCRIPCION, '' AS HORA, a.carnet, 
a.carrera, c.apellido1||' '||c.apellido2||', '||c.nombre1||' '||c.nombre2 
AS ALUMNO, '' AS CODPERS, '' AS CATEDRATICO, '' AS TORRE, '' AS SALON,
to_char(a.fechaimp,'dd/MM/yyyy') AS FECHA, '____________' AS Firma, 
(nvl(s.MORAS30,0) + nvl(s.VMORAS30,0) + nvl(s.MORAS60,0) + nvl(s.VMORAS60,0) 
+ nvl(s.MORAS90,0) +nvl(s.VMORAS90,0) + nvl(s.MORAS91,0) +
nvl(s.VMORAS91,0)) AS SALDO

             from  dbafisicc.cahasignastb a, dbafisicc.cahcurshoratb b,
                   dbafisicc.caalumnostb c, dbafisicc.cctemprepdeudas15tb s
                where a.carrera = b.carrera
                and a.curso = b.curso
                and a.seccion = b.seccion
                AND A.TIPOASIG = B.TIPOASIG
                and to_char(a.fechaimp,'dd/MM/yyyy') = 
                to_char(PFECHAIMP,'dd/MM/yyyy')
                and trunc(a.fechaimp) = trunc(b.fechaimp)
                and a.carnet = c.carnet
                and a.codstatus in ('S1', 'S4')
                and a.carnet = s.carnet(+) and a.carrera = s.carrera(+)
                ORDER BY C.APELLIDO1||' '||C.APELLIDO2||', '||C.NOMBRE1||' '||
                c.nombre2 asc;

END ASISTENCIA_HISTORICO;