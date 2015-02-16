/*
	Autor: Miguel Barillas
	Fecha:15/11/2013
	Descripcion: Devuelve un cursor que contiene la informacion de los alumnos
  que se hacen el examen de ubicacion, para su asistencia
  Utilizado: /AptitudGalileo/ListAsistencia.aspx
  Modificaciones:
  Autor: Miguel Barillas
  Fecha: 16/12/2013
  Descripcion: Se agregaron los parametros generales de filtro,
  PDIRECTOR, PGRADO, PSEDE, el parametro de usuario PUSUARIO y el parametro
  utilizado para devolver solo los alumnos que tienen notas PTIENENOTAS
  Modificaciones:
      22/01/2014 - Javier Garcia: Se cambio la forma de filtrado de los
                                  resultados cambiando de filtrar en base al
                                  grupo con la instruccion HAVING a filtrar
                                  sobre cada tupla individual con una
                                  condicion en el where de la subconsulta
                                  de carnet.
      24/01/2014 - Javier Garcia: Se quitaron las condiciones de carrera y
                                  periodo de la subconsulta de carnet y se
                                  colocaron en la subconsulta principal.
      07/02/2014 - Javier Garcia:  Se modifico la subconsulta que trae los
                                   carnet para que devuelva los solicitantes
                                   que tengan nota mayores a 0
      24/11/2014 - Kevin Herrera:  Se utiliza CACARRERASVW en lugar de 
                                   CACARRERASTB para usar centro.
*/
PROCEDURE EXAMENUBI_ASISTENCIA
(
  PENTIDAD  DBAFISICC.GNENTIDADESTB.ENTIDAD%TYPE DEFAULT NULL,
  PDIRECTOR DBAFISICC.CACARRERASTB.ENCARGADO%TYPE DEFAULT NULL,
  PGRADO    DBAFISICC.CACARRERASTB.GRADO%TYPE DEFAULT NULL,
  PSEDE     DBAFISICC.CACARRERASTB.COMENTARIOS%TYPE DEFAULT NULL,
  PCARRERA  DBAFISICC.CACARRERASTB.CARRERA%TYPE DEFAULT NULL,
  PFECHAINI DBAFISICC.CAALUMEXAUBITB.FECHA%TYPE DEFAULT NULL,
  PFECHAFIN DBAFISICC.CAALUMEXAUBITB.FECHA%TYPE DEFAULT NULL,
  PPERIODO  DBAFISICC.CAALUMEXAUBITB.PERIODO%TYPE DEFAULT NULL,
  PINSTITUCION DBAFISICC.CADATOSALUMEXAUBITB.INSTITUCION%TYPE DEFAULT NULL,
  PUSUARIO     DBAFISICC.GNUSUARIOSTB.USUARIO%TYPE DEFAULT NULL,
  PTIENENOTAS IN NUMBER DEFAULT 0,
  RETVAL    OUT SYS_REFCURSOR
)
AS BEGIN 
  OPEN RETVAL FOR 
    
      SELECT ROWNUM NO, FECHA, NOMBRE_CORTO, NOMFACULTAD, CARRERA, NOMCARRERA, 
             CARNET, ALUMNO, FIRMA, EXAMEN,INSTITUCION
         FROM (
                SELECT TO_CHAR(B.FECHA,'dd/mm/yyyy') FECHA, D.NOMBRE_CORTO,
                       D.NOMBRE NOMFACULTAD, C.CARRERA, C.NOMBRE NOMCARRERA, 
                       A.CARNET, A.APE1ALUMNO||' '||A.APE2ALUMNO||' '||
                       A.APE3ALUMNO||', '||A.NOM1ALUMNO ||' '||
                       A.NOM2ALUMNO ALUMNO, '______________________' FIRMA, 
                       A.CARNET EXAMEN, F.NOMBRE INSTITUCION
                    FROM DBAFISICC.CADATOSALUMEXAUBITB A, 
                         DBAFISICC.CAALUMEXAUBITB B, 
                         DBAFISICC.CACARRERASVW C, DBAFISICC.GNENTIDADESTB D,
                         DBAFISICC.GNINSTITUSTB F
                    WHERE B.CARRERA=C.CARRERA
                    AND A.CARNET=B.CARNET 
                    AND D.ENTIDAD=C.ENTIDAD 
                    AND F.INSTITUC=A.INSTITUCION
                    AND D.FACULTAD='002'
                    AND (D.ENTIDAD =   PENTIDAD    OR PENTIDAD IS NULL)
                    AND (C.ENCARGADO = PDIRECTOR OR PDIRECTOR IS NULL)
                    AND (C.GRADO =     PGRADO    OR PGRADO IS NULL)
                    AND (C.CENTRO =    PSEDE    OR PSEDE IS NULL)
                    AND (B.PERIODO =   PPERIODO  OR PPERIODO IS NULL)
                    AND (B.CARRERA =   PCARRERA OR PCARRERA IS NULL)
                    AND (F.INSTITUC =  PINSTITUCION OR PINSTITUCION IS NULL)
                    AND ((TRUNC(B.FECHA) BETWEEN TRUNC(PFECHAINI) 
                    AND TRUNC(PFECHAFIN)) OR (PFECHAINI IS NULL 
                        AND PFECHAFIN IS NULL))
                    AND (B.CARNET IN (SELECT DISTINCT E.CARNET 
                                       FROM DBAFISICC.CAEXAUBINOTASTB E
                                       WHERE E.CARRERA = B.CARRERA
                                       AND E.PERIODO = B.PERIODO
                                       AND E.NOTA > 0)
                         OR PTIENENOTAS = 0)
        ORDER BY D.NOMBRE_CORTO, C.CARRERA, A.APE1ALUMNO, A.APE2ALUMNO,
                 A.APE3ALUMNO, A.NOM1ALUMNO, A.NOM2ALUMNO);
                 
END EXAMENUBI_ASISTENCIA;