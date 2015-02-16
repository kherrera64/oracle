  /* 
   Autor: Kevin Herrera
   Fecha: 15/11/2014
   Descripcion: Devuelve el encabezado de los portales ITC
 */

 PROCEDURE ENCABEZADO_ASIGITC
 (
    PCARNET   DBAFISICC.CAALUMCARRSTB.CARNET%TYPE DEFAULT NULL,
    PCARRERA  DBAFISICC.CAALUMCARRSTB.CARRERA%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
 )  
  AS BEGIN
   OPEN RETVAL FOR 
 
        SELECT DISTINCT F.CORRELATIVO, A.DESCRIPCION COMENTARIO, 
               B.NOMBRETORRE TORRE, F.SALON, 
               TO_CHAR(F.HORAINI, 'HH24:MI') HORAINI,
               TO_CHAR(F.HORAFIN, 'HH24:MI') HORAFIN, 
               TO_CHAR(F.FECHAINI, 'dd/MM/yyyy') FECHAINI, 
               TO_CHAR(F.FECHAFIN, 'dd/MM/yyyy') FECHAFIN, 
               A.HORARIO
               
           FROM DBAFISICC.CAMAINHORARIOSTB A, DBAFISICC.CATORRESTB B, 
                DBAFISICC.CAHORARIOSTB C, DBAFISICC.CACURSOSIMPTB D, 
                DBAFISICC.CACURSHORATB E, DBAFISICC.CAITCCURSOSIMPTB F
           WHERE A.STATUS = 'A' 
           AND A.HORARIO = F.HORARIO
           AND F.STATUS = 'A'
           AND A.HORARIO = C.HORARIO
           AND C.TORRE = B.CODIGOTORRE
           AND D.CURSO = E.CURSO
           AND D.CARRERA = E.CARRERA
           AND D.SECCION = E.SECCION
           AND D.TIPOASIG = E.TIPOASIG
           AND D.TIPOASIG = 'ITC'
           AND A.HORARIO = E.HORARIO
           AND D.CARRERA= PCARRERA
           AND D.CURSO IN ( SELECT A.CURSO 
                             FROM DBAFISICC.CACATPENSATB A, 
                                  DBAFISICC.CACURSOSTB B, DBAFISICC.CAPENSATB C, 
                                  DBAFISICC.CAALUMCARRSTB D
                             WHERE A.CARRERA=D.CARRERA 
                             AND A.CARRERA=C.CARRERA 
                             AND A.CURSO=B.CURSO 
                             AND A.PENSUM=C.PENSUM 
                             AND A.PENSUM=D.PENSUM 
                             AND A.HISTORIAL = 1
                             AND D.CARRERA = PCARRERA
                             AND D.CARNET = PCARNET) 
        ORDER BY A.DESCRIPCION;
        
 END ENCABEZADO_ASIGITC;