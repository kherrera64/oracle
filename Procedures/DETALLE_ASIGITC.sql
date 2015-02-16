  /* 
   Autor: Kevin Herrera
   Fecha: 15/11/2014
   Descripcion: Devuelve el detalle de los portales ITC
 */

 PROCEDURE DETALLE_ASIGITC
 (
    PCARNET       DBAFISICC.CAALUMCARRSTB.CARNET%TYPE DEFAULT NULL,
    PCARRERA      DBAFISICC.CAALUMCARRSTB.CARRERA%TYPE DEFAULT NULL,
    PCORRELATIVO  DBAFISICC.CAITCCURSOSIMPTB.CORRELATIVO%TYPE DEFAULT NULL,
    RETVAL    OUT SYS_REFCURSOR
 )  
  AS BEGIN
   OPEN RETVAL FOR 
 
        SELECT D.CORRELATIVO, E.CARRERA, E.CURSO, C.NOMBRE NCURSO, E.SECCION, 
               E.PENSUM, D.DIRECCION, 
               DECODE (D.DIRECCION, '1','En adelante','-1','Hacia atras','0',
                       'Unicamente') NDIRECCION,
               TO_CHAR(E.PRECIO,'99999999.99') PRECIO, A.HORARIO, E.PERIODO
 
           FROM DBAFISICC.CAITCCURSOSIMPTB A, DBAFISICC.CAITCCURSOSDETALLETB D, 
                DBAFISICC.CACURSOSTB C, DBAFISICC.CACURSOSIMPTB E 
           WHERE A.STATUS = 'A' AND E.STATUS = 'A' 
           AND E.CARRERA = D.CARRERA 
           AND E.CURSO = D.CURSO 
           AND E.TIPOASIG = 'ITC' 
           AND A.CORRELATIVO = D.CORRELATIVO 
           AND D.CURSO = C.CURSO
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
           AND D.CARRERA = PCARRERA 
           AND A.CORRELATIVO = PCORRELATIVO;

 END DETALLE_ASIGITC; 