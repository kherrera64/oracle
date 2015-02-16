/*
Autor:  Kevin Herrera.
Fecha:  15/03/2014
Descripcion: Procedimiento que devuelve los datos de asistencia de alumnos.
*/

PROCEDURE ASISTENCIAALUMNOS
 (
    PHORARIO DBAFISICC.CACURSHORATB.HORARIO%TYPE DEFAULT NULL,
    PFECHAINI DBAFISICC.RHHALUMASISTETB.FECHA%TYPE DEFAULT NULL,
    PFECHAFIN DBAFISICC.RHHALUMASISTETB.FECHA%TYPE DEFAULT NULL,
    PFECHAIMP varchar2 DEFAULT NULL, 
    PACCION varchar2,
    RETVAL    OUT SYS_REFCURSOR
 )
  IS
  BEGIN

  IF PACCION = 'A' THEN
   OPEN RETVAL FOR 

     SELECT DISTINCT TO_CHAR(A.FECHA,'dd/MM/yyyy') FECHAPRINT, 
     TO_CHAR(A.FECHA,'d') DIA, FECHA, A.CARNET, B.APELLIDO1|| ' ' ||
     B.APELLIDO2||', '||B.NOMBRE1|| ' ' ||B.NOMBRE2 AS ESTUDIANTE,
     D.CURSO||' - '||D.NOMBRE AS NOMBRE_CURSO, 
     DECODE(A.AUSENCIA , 0, 'S�', 'No') AS ASISTENCIA 
  
       FROM DBAFISICC.RHALUMASISTETB A, DBAFISICC.CAALUMNOSTB B, 
       DBAFISICC.CACURSHORATB C, DBAFISICC.CACURSOSTB D, 
       CACURSOSIMPTB E, GNENTIDADESTB F, CACARRERASTB G 
       WHERE C.HORARIO=PHORARIO 
       AND D.CURSO=C.CURSO 
       AND C.HORARIO=A.HORARIO 
       AND B.CARNET=A.CARNET 
       AND E.CURSO=C.CURSO 
       AND E.CARRERA=C.CARRERA 
       AND E.TIPOASIG=C.TIPOASIG 
       AND E.SECCION=C.SECCION 
       AND G.CARRERA=C.CARRERA 
       AND G.ENTIDAD=F.ENTIDAD 
       AND F.FACULTAD='002' 
       ORDER BY FECHA, ESTUDIANTE;
       
  ELSIF PACCION = 'H' THEN
   OPEN RETVAL FOR     
 
     SELECT DISTINCT TO_CHAR(A.FECHA,'dd/MM/yyyy') FECHAPRINT, 
     TO_CHAR(A.FECHA,'d') DIA, FECHA, A.CARNET, 
     B.APELLIDO1|| ' ' ||B.APELLIDO2||', '||B.NOMBRE1|| ' ' ||B.NOMBRE2 
     AS ESTUDIANTE, D.CURSO||' - '||D.NOMBRE AS NOMBRE_CURSO, 
     DECODE(A.AUSENCIA , 0, 'S�', 'No') AS ASISTENCIA 
                
        FROM DBAFISICC.RHHALUMASISTETB A, DBAFISICC.CAALUMNOSTB B, 
        DBAFISICC.CAHCURSHORATB C, DBAFISICC.CACURSOSTB D, 
        DBAFISICC.CAHCURSOSIMPTB E, DBAFISICC.GNENTIDADESTB F, 
        DBAFISICC.CACARRERASTB G 
               
        WHERE C.HORARIO=PHORARIO 
        AND TRUNC(A.FECHA) between  TRUNC(PFECHAINI) and  Trunc(PFECHAFIN)  
        AND D.CURSO=C.CURSO 
        AND C.HORARIO=A.HORARIO 
        AND C.FECHAIMP=A.FECHAIMP 
        AND B.CARNET=A.CARNET 
        AND E.CURSO=C.CURSO 
        AND E.CARRERA=C.CARRERA 
        AND E.TIPOASIG=C.TIPOASIG 
        AND E.SECCION= C.SECCION 
        AND E.FECHAIMP=C.FECHAIMP 
        AND G.CARRERA=C.CARRERA
        AND G.ENTIDAD=F.ENTIDAD 
        AND F.FACULTAD='002'
        ORDER BY FECHA, ESTUDIANTE;
  
  ELSIF PACCION = 'D'  THEN
   OPEN RETVAL FOR     
   
     SELECT C.NOMBRE1||' '||C.NOMBRE2||' '||C.APELLIDO1||' '||C.APELLIDO2 NOMBRE 
        
        FROM DBAFISICC.RHHDOCENTESTB A, DBAFISICC.NOPUESTOSTB B, 
        DBAFISICC.NOPERSONALTB C
        
        WHERE A.CODPUESTO=B.CODPUESTO
        AND A.CODPERS=C.CODPERS 
        AND A.HORARIO=PHORARIO 
        AND FECHAIMP=TO_DATE(PFECHAIMP,'MM/yyyy')
        AND A.STATUS='A' AND B.CODPUESTO='000010' 
     
     UNION SELECT C.NOMBRE1||' '||C.NOMBRE2||' '||C.APELLIDO1||' '||C.APELLIDO2 
     NOMBRE
       
       FROM DBAFISICC.RHDOCENTESTB A, DBAFISICC.NOPUESTOSTB B, 
       DBAFISICC.NOPERSONALTB C
       WHERE A.CODPUESTO=B.CODPUESTO 
       AND A.CODPERS=C.CODPERS 
       AND A.HORARIO= PHORARIO 
       AND A.STATUS='A'
       AND B.CODPUESTO='000010';
     
  END IF;
END ASISTENCIAALUMNOS;