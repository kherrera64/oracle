/*
Nombre:       DOCENTE
Autor:        Andrea Alvarado
Fecha:        13/12/2012
Descripcion:  Selecciona el Codpers del docente titular asignado al curso
lleva la logica de la jerarquia de docentes. 

Nombre: Miguel Barillas
Fecha:  16/07/2013
Modificacion: Se cambiaron la forma en que se busca al docente, 
primero se busca al CATEDRATICO PRINCIPAL (000010), luego al
CATEDRATICO DE LABORATORIO (000081) y por ultimo al
CATEDRATICO SUPERVISOR (000080)

Modificacion: KHERRERA - 26/06/2014 - Se agrega al procedimiento el puesto 
                                      000085.
*/

FUNCTION DOCENTE
(
  PHORARIO DBAFISICC.RHHDOCENTESTB.HORARIO%TYPE,
  PFECHAIMP DBAFISICC.RHHDOCENTESTB.FECHAIMP%TYPE DEFAULT NULL
) RETURN VARCHAR2
AS
  VCODPERS VARCHAR2(6);
BEGIN
--CATEDRATICO PRINCIPAL
--TUTOR (000085)
    SELECT CODPERS
      INTO VCODPERS
      FROM (select codpers CODPERS
              from dbafisicc.rhhdocentestb
              WHERE  STATUS = 'A'
              AND CODPUESTO in ('000010', '000085')
              and horario   = Phorario
              and fechaimp  = Pfechaimp
            UNION 
            SELECT codpers CODPERS
               from dbafisicc.rhdocentestb
               WHERE  STATUS IN ('A','P')
               AND CODPUESTO in ('000010', '000085')
               and horario   = Phorario
                and Pfechaimp IS NULL);
    RETURN VCODPERS;
EXCEPTION 
  WHEN NO_DATA_FOUND THEN 
      BEGIN
--CATEDRATICO DE LABORATORIO (000081)
        SELECT CODPERS
          INTO VCODPERS
          FROM (select codpers CODPERS
                  from dbafisicc.rhhdocentestb
                  where  status = 'A'
                  AND CODPUESTO  ='000081'
                  and horario=Phorario
                  and fechaimp=Pfechaimp
                UNION 
                SELECT codpers CODPERS
                  from dbafisicc.rhdocentestb
                  where  status in ('A','P')
                  AND CODPUESTO  ='000081'
                  and horario   = Phorario
                  and Pfechaimp IS NULL);
          RETURN VCODPERS;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            BEGIN 
--CATEDRATICO SUPERVISOR (000080)
              SELECT CODPERS
                INTO VCODPERS
                FROM (select codpers CODPERS
                        from dbafisicc.rhhdocentestb
                        WHERE  STATUS = 'A'
                        AND CODPUESTO = '000010'
                        and horario=Phorario
                        and fechaimp=Pfechaimp
                      UNION 
                      SELECT codpers CODPERS
                        from dbafisicc.rhdocentestb
                        WHERE  STATUS IN ('A','P')
                        AND CODPUESTO = '000010'
                        and horario   = Phorario
                        and Pfechaimp IS NULL);
                RETURN VCODPERS;
            EXCEPTION 
              WHEN OTHERS THEN 
                RETURN NULL;
            END;
        WHEN OTHERS THEN 
          RETURN NULL;
      END;
  WHEN OTHERS THEN 
    RETURN NULL;
END DOCENTE;