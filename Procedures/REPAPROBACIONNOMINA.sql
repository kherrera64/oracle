/*
Autor: Kevin Herrera.
Fecha: 11/06/2014
Descripcion: Procedimiento creado para el reporte de RepNomina.rdlc
  
Modificacion > KHERRERA - 07/07/2014 - Se agregaron validaciones en la consulta
segun los parametros que se envian. 

Modificacion > KHERRERA - 07/07/2014 - Se usa el campo FECHA_PROCESO de la tabla
SOSOLTRAMITETB para el rango de fechas

Modificacion > KHERRERA - 16/07/2014 - Se obtienen las carreras por docente 
de la tabla NODOCXCONTRATOCCTB.
*/

PROCEDURE REPAPROBACIONNOMINA
  (
    PINICIO    IN  DBAFISICC.SOSOLTRAMITETB.FECHASOLIC%TYPE,
    PFIN       IN  DBAFISICC.SOSOLTRAMITETB.FECHASOLIC%type default null,
    PTIPO      in  DBAFISICC.NODOCXCONTRATOTB.TIPO%type default null,
    PSTATUS    IN  DBAFISICC.SOSOLTRAMITETB.STATUS%TYPE DEFAULT NULL,
    retval     out sys_refcursor
  )
  IS 
  BEGIN

   IF PTIPO = '6' AND PSTATUS = 'P'  THEN 
     OPEN RETVAL FOR
   
      SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Pendiente' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           and C.PASO in ('3','4')
           AND B.CODPERS = A.CODPERS
           AND A.TIPO='6';
           
   ELSIF PTIPO = '7' AND PSTATUS = 'P' THEN
   OPEN RETVAL FOR
    
      SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Pendiente' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           and C.PASO in ('3','6','7')
           AND B.CODPERS = A.CODPERS
           AND A.TIPO='7';
     
   ELSIF PTIPO = '6' AND PSTATUS = 'A' THEN
   OPEN RETVAL FOR
    
      SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Realizado' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           AND C.PASO = '0'
           and C.PASOANTERIOR = '4'
           AND B.CODPERS = A.CODPERS
           AND A.TIPO='6';    
           
           
   ELSIF PTIPO = '7' AND PSTATUS = 'A' THEN
   OPEN RETVAL FOR
    
      SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Realizado' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           AND C.PASO = '0'
           and C.PASOANTERIOR = '7'
           AND B.CODPERS = A.CODPERS
           AND A.TIPO='7';    
           
           
   ELSIF PTIPO is null AND PSTATUS = 'P' THEN
   OPEN RETVAL FOR
    
      SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Pendiente' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           AND B.CODPERS = A.CODPERS
           AND C.PASO in ('3', '4', '6', '7');
           
   ELSIF PTIPO is null AND PSTATUS = 'A' THEN
   OPEN RETVAL FOR
    
       SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Realizado' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           AND B.CODPERS = A.CODPERS
           AND C.PASO ='0'
           and C.PASOANTERIOR in ('4','7');
           
   ELSE
   OPEN RETVAL FOR
   
      SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Realizado' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           AND B.CODPERS = A.CODPERS
           AND C.PASO ='0'
           and C.PASOANTERIOR in ('4','7')
   
      UNION SELECT A.CODPERS, B.NOMBRE1 || ' ' || B.NOMBRE2 || ' ' || 
      APELLIDO1 || ' ' || APELLIDO2 as NOMBRE, a.CODPUESTO, a.CORRELATIVO,
      'Pendiente' STATUS, a.SALARIO, a.NOPAGOS, a.INICIO_PAGO, a.DESCRIP, 
      a.CONTRATO_INI, a.CONTRATO_FIN, a.FECHA, a.NOMINA, C.SOLICITUD, a.USUARIO, 
      a.TIPO, (select rtrim(LISTAGG(D.Carrera || ', ') 
               WITHIN GROUP (ORDER BY D.Carrera), ', ') carrera
                     FROM DBAFISICC.NODOCXCONTRATOCCTB D
                     WHERE D.CORRELATIVO = A.CORRELATIVO
                     AND D.CODPUESTO = A.CODPUESTO
                     AND D.CODPERS = A.CODPERS) CARRERA
       
           from DBAFISICC.NODOCXCONTRATOTB a, DBAFISICC.NOPERSONALTB B,
           DBAFISICC.SOSOLTRAMITETB C
           where TRUNC(C.FECHA_PROCESO) between TRUNC(PINICIO) and TRUNC(PFIN)
           AND C.SOLICITUD = A.SOLICITUD
           AND B.CODPERS = A.CODPERS
           AND C.PASO in ('3', '4', '6', '7');
           
   END IF;       
           
END REPAPROBACIONNOMINA;