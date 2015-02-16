/*
Autor: Kevin Herrera.
Fecha: 25/06/2014
Descripcion: Procedimiento creado para obtener las carreras en el 
             modulo de asistencia.
*/

 PROCEDURE CARRERASASISTENCIA
  (
    PDIA       IN DBAFISICC.CAHORARIOSTB.DIA%TYPE DEFAULT NULL,
    PFECHA     IN DBAFISICC.CAMAINHORARIOSTB.FECHAINI%TYPE DEFAULT NULL,
    PHORAINI   IN DBAFISICC.CAHORARIOSTB.HORAINI%TYPE DEFAULT NULL,
    PHORAFIN   IN DBAFISICC.CAHORARIOSTB.HORAFIN%TYPE DEFAULT NULL,
    PENTIDAD   IN DBAFISICC.CACARRERASTB.ENTIDAD%TYPE DEFAULT NULL,
    retval     out sys_refcursor
  )
  IS  BEGIN
  OPEN RETVAL FOR   

      select '0' Carrera, ' TODAS' Nombre
          FROM DUAL 
              
      UNION SELECT F.CARRERA, F.CARRERA || ' - ' || F.NOMBRE 
      
          FROM DBAFISICC.CAMAINHORARIOSTB A, DBAFISICC.CACURSHORATB B, 
          DBAFISICC.CAHORARIOSTB C, DBAFISICC.RHDOCENTESTB D, 
          DBAFISICC.NoPersonalTB e, DBAFISICC.CACarrerasTB f 
          where a.horario=b.horario 
          AND A.HORARIO=C.HORARIO 
          AND D.HORARIO=A.HORARIO 
          and CodPuesto IN ('000010', '000081') 
          AND D.CODPERS=E.CODPERS 
          AND (C.DIA=PDIA OR PDIA IS NULL) 
          AND TRUNC(PFECHA) BETWEEN TRUNC(A.FECHAINI) AND TRUNC(A.FECHAFIN)
          AND TO_CHAR(C.HORAINI, 'HH24:MI') BETWEEN TO_CHAR(PHORAINI, 'HH24:MI') 
                                                AND TO_CHAR(PHORAFIN, 'HH24:MI')
          AND B.CARRERA=F.CARRERA 
          AND (F.ENTIDAD = PENTIDAD OR PENTIDAD IS NULL) 
      
      ORDER BY NOMBRE;
 
 END CARRERASASISTENCIA;     