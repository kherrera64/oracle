

CURSOR NOMINA_CURSOR IS   
    SELECT DISTINCT ca.horario, ca.descripcion,trunc(ca.fechaini) fechaini_curso,   
           trunc(ca.fechafin) fechafin_curso, rh.codpers,    
           trunc(rh.fechaini) fechaini_doc, trunc(rh.fechafin) fechafin_doc,   
           rh.codpuesto,nopers.tipopago || ' '|| nopers.no_prove pago,rh.status,    
           rh.solicitud hora, d.despuesto, cacu.carrera, e.nombre nombre_Carrera,
           
           CASE WHEN nombrados.fechanomb is null    
                    and (rh.status <> 'B' or rh.status <>'I')    
                    and rh.solicitud is null    
                then ' NO SOLICITADOS'    
                else    
                   case when nombrados.fechanomb is null    
                             and (rh.status <> 'B' or rh.status <>'I')    
                             and rh.solicitud is not null    
                        then ' SOLICITADOS'    
                        else    
                           case when (rh.status = 'B' or rh.status = 'I')    
                                     and rh.solicitud is null    
                                then 'BAJAS NO SOLICITADAS'    
                                else    
                                   case when (rh.status = 'B' or rh.status = 'I')    
                                              and rh.solicitud is not null    
                                              and nombrados.fechanomb is null    
                                        then 'BAJAS SOLICITADAS'    
                                        else    
                                           case when (rh.status = 'B' or rh.status = 'I')    
                                                      and nombrados.fechanomb is not null    
                                                then 'BAJA APROBADA'    
                                                else    
                                                   case when nombrados.fechanomb is not null    
                                                             and (rh.status <> 'B' or rh.status <>'I')    
                                                             and rh.solicitud is not null    
                                                        then 'APROBADOS'     
                                                  end    
                                           end    
                                  end    
                           end    
                   end    
            end tipo    
       FROM dbafisicc.camainhorariostb ca, dbafisicc.rhdocentestb rh,    
            dbafisicc.nopersonaltb nopers, dbafisicc.cacurshoratb cacu,   
            dbafisicc.nodocxhorariotb nombrados,dbafisicc.nopuestostb d,
            dbafisicc.cacarrerastb e
       WHERE ca.horario                = rh.horario    
       AND   rh.codpers                = nopers.codpers   
       AND   ca.horario                = cacu.horario   
       AND   rh.horario                = nombrados.horario(+)    
       AND   rh.codpuesto              = nombrados.codpuesto(+)   
       AND   rh.codpers                = nombrados.codpers(+)   
       AND   nvl(nombrados.status,'P') = 'P'   
       AND   cacu.tipoasig             = 'AS'    
       AND   (RH.STATUS = :PSTATUS OR :PSTATUS  IS NULL)   
       AND   (RH.SOLICITUD = :PSOLICITUD OR :PSOLICITUD IS NULL)
       and   rh.codpuesto              = d.codpuesto
       and   cacu.carrera              = e.carrera
       ORDER BY ca.horario;   
           
  --Cursor para recorrer el horario de los cursos envio horario.    
  CURSOR HORARIO_CURSOR(PHORARIO DBAFISICC.CAMAINHORARIOSTB.HORARIO%TYPE) IS   
      select horario dhhorario, correlativo dhcor, dia dhdia,   
             to_char(horaini,'hh24:mi')||'-'||to_char(horafin,'hh24:mi') dhhora,   
             salon dhsalon, torre dhtorre, codpers dhcodpers,horaini dhini,    
             horafin dhfin   
        from  dbafisicc.cahorariostb   
        WHERE HORARIO=PHORARIO   
        order by dia,horaini;   
--Los registros que se utilizan en el procedimiento.   
   NOMINA_FILA   NOMINA_CURSOR%ROWTYPE;   
   NOMINA_TEMPORAL DBAFISICC.RHNOMINATB%ROWTYPE;   
   HORARIO_FILA  HORARIO_CURSOR%ROWTYPE;   
      
   --variables que obtienen valores de horas en numeros para enviarlos a difhora   
  Vchoraini         number;   
  Vchorafin         number;   
  --Guarda el conteo de las horas por semana   
  Vhoras            number;   
  --Guarda el valor del salario por curso que devuelve el procedimiento.   
  vsalario      number(13,2);   
  --Guarda el tiempo del curso   
  vtiempo       number := 0;   
  --determina que tipo de nomina regresa   
  VNOMINA       NUMBER(1);   
  --Guarda una secuencia de nomina que utiliza para identificar el reporte   
   VSOLICITUD    NUMBER(10);   
   --Guarda las fechas de inicio de pago e inicio de poliza en varchar que es    
   -- como regresa el procedimiento   
   vinicio_pago  varchar(10);   
   vinicio_poliza varchar(10);   
BEGIN    
-- Genera el correlativo para identificar la solicitud   
    SELECT SEQREPNOMINA.NEXTVAL    
      INTO VSOLICITUD   
      FROM DUAL;   
--Abre el cursor para recorrer la nomina y hacer los calculos correspondientes   
   OPEN NOMINA_CURSOR;    
   LOOP    
   FETCH  NOMINA_CURSOR INTO NOMINA_FILA;   
     EXIT WHEN NOMINA_CURSOR%NOTFOUND;   
     --Guarda los datos en el registro que se guardan al final.    
          NOMINA_TEMPORAL.HORARIO := NOMINA_FILA.HORARIO;   
          NOMINA_TEMPORAL.DESCRIPCION := NOMINA_FILA.DESCRIPCION;   
          NOMINA_TEMPORAL.FECHAINI_CURSO := NOMINA_FILA.FECHAINI_CURSO;   
          NOMINA_TEMPORAL.FECHAFIN_CURSO := NOMINA_FILA.FECHAFIN_CURSO;   
          NOMINA_TEMPORAL.CODPERS := NOMINA_FILA.CODPERS;   
          NOMINA_TEMPORAL.FECHAINI_DOC := NOMINA_FILA.FECHAINI_DOC;   
          NOMINA_TEMPORAL.FECHAFIN_DOC := NOMINA_FILA.FECHAFIN_DOC;   
          NOMINA_TEMPORAL.CODPUESTO := NOMINA_FILA.CODPUESTO;   
          NOMINA_TEMPORAL.PAGO := NOMINA_FILA.PAGO;   
          NOMINA_TEMPORAL.USUARIO := PUSUARIO;   
          NOMINA_TEMPORAL.STATUS := NOMINA_FILA.STATUS;   
          NOMINA_TEMPORAL.TIPO := NOMINA_FILA.TIPO;   
          NOMINA_TEMPORAL.SOLICITUD := NOMINA_FILA.HORA;   
          VNOMINA := '1'; --POR QUE ES Produccion   
             
          --Hace los calculos correspondientes para ir guardando los valores que   
          --hacen falta para llenar el registro de la nomina.   
          SP_NominaDocente (NOMINA_TEMPORAL.horario,   
                      NOMINA_TEMPORAL.codpers,NOMINA_TEMPORAL.codpuesto,vnomina,
                      /* AALVARADO - 24/04/2013 - AGREGADO POR COMPATIBILIDAD */
                      null,
                      /* AALVARADO - 24/04/2013 - AGREGADO POR COMPATIBILIDAD */
                      NOMINA_TEMPORAL.numeropagos,vinicio_pago,   
                      NOMINA_TEMPORAL.periodicidad,vinicio_poliza,   
                      NOMINA_TEMPORAL.pagospoliza,NOMINA_TEMPORAL.TIEMPOCURSO,   
                      vsalario,vtiempo,NOMINA_TEMPORAL.nominapagos);       
          --Convierte los datos de caracter a fecha   
          NOMINA_TEMPORAL.inicio_pago := to_date(vinicio_pago,'dd/mm/yyyy');   
          NOMINA_TEMPORAL.inicio_poliza  := to_date(vinicio_poliza,'dd/mm/yyyy');   
             
          --Valida los campos de inicio_pago, inicio_poliza   
          IF NOMINA_TEMPORAL.INICIO_PAGO IS NULL   
          THEN    
              NOMINA_TEMPORAL.INICIO_PAGO := to_date('01/01/1000','dd/mm/yyyy');   
          END IF;   
          IF NOMINA_TEMPORAL.INICIO_POLIZA  IS NULL   
          THEN    
              NOMINA_TEMPORAL.INICIO_POLIZA := to_date('01/01/1000','dd/mm/yyyy');   
          END IF;   
          --Verifica que el salario sea positivo para nombramiento y negativo para   
          --bajas o inactivacion de catedraticos.   
          if ((NOMINA_TEMPORAL.status = 'B')OR(NOMINA_TEMPORAL.status = 'I'))   
          THEN    
              Vsalario :=VSALARIO * -1;   
              NOMINA_TEMPORAL.salariocurso := VSALARIO;   
          ELSE    
              NOMINA_TEMPORAL.salariocurso := VSALARIO;   
         END IF;   
         --Se calcula el salario mensual en base al numero de pagos y el salario   
        -- por cursosi el numero de pagos es    
        -- si el numero de pagos es null simplemente el salario mensual es 0   
         IF NVL(NOMINA_TEMPORAL.NUMEROPAGOS,0)=0    
         THEN    
              NOMINA_TEMPORAL.SALARIOMENSUAL := 0;   
         ELSE   
              NOMINA_TEMPORAL.SALARIOMENSUAL := NOMINA_TEMPORAL.SALARIOCURSO/NOMINA_TEMPORAL.NUMEROPAGOS;   
         END IF;   
         --Reset el numero de horas para conteo.   
         Vhoras := 0;   
          OPEN HORARIO_CURSOR(NOMINA_TEMPORAL.HORARIO);   
          LOOP   
          FETCH  HORARIO_CURSOR INTO HORARIO_FILA;   
          EXIT WHEN HORARIO_CURSOR%NOTFOUND;   
                 Vchoraini  := to_number(to_char(HORARIO_FILA.dhini ,'hh24mi'));   
                 Vchorafin  := to_number(to_char(HORARIO_FILA.dhfin,'hh24mi'));   
                   Vhoras := Vhoras + NominaDocente.DifHoras(Vchoraini,Vchorafin);   
          END LOOP;   
          CLOSE HORARIO_CURSOR;   
          --Graba el numero de horas por semana   
          NOMINA_TEMPORAL.DIFHORA := Vhoras;   
          --inserta en nomina el registro completo ya con los calculos.    
         INSERT INTO DBAFISICC.RHNOMINATB (CODIGO,HORARIO,DESCRIPCION,FECHAINI_CURSO,   
                      FECHAFIN_CURSO,CODPERS,FECHAINI_DOC,FECHAFIN_DOC,CODPUESTO,   
                      PAGO,USUARIO,STATUS,NUMEROPAGOS,INICIO_PAGO,PERIODICIDAD,   
                      INICIO_POLIZA,PAGOSPOLIZA,SALARIOCURSO,SALARIOMENSUAL,   
                      TIEMPOCURSO,NOMINAPAGOS,DIFHORA,SOLICITUD,TIPO)   
              VALUES (VSOLICITUD,NOMINA_TEMPORAL.HORARIO,NOMINA_TEMPORAL.DESCRIPCION,   
                      NOMINA_TEMPORAL.FECHAINI_CURSO,NOMINA_TEMPORAL.FECHAFIN_CURSO,   
                      NOMINA_TEMPORAL.CODPERS,NOMINA_TEMPORAL.FECHAINI_DOC,   
                      NOMINA_TEMPORAL.FECHAFIN_DOC,NOMINA_TEMPORAL.CODPUESTO,   
                      NOMINA_TEMPORAL.PAGO,NOMINA_TEMPORAL.USUARIO,   
                      NOMINA_TEMPORAL.STATUS,NOMINA_TEMPORAL.NUMEROPAGOS,   
                      NOMINA_TEMPORAL.INICIO_PAGO,NOMINA_TEMPORAL.PERIODICIDAD,   
                      NOMINA_TEMPORAL.INICIO_POLIZA,NOMINA_TEMPORAL.PAGOSPOLIZA,   
                      NOMINA_TEMPORAL.SALARIOCURSO,NOMINA_TEMPORAL.SALARIOMENSUAL,   
                      NOMINA_TEMPORAL.TIEMPOCURSO,NOMINA_TEMPORAL.NOMINAPAGOS,   
                      NOMINA_TEMPORAL.DIFHORA,NOMINA_TEMPORAL.SOLICITUD,   
                      NOMINA_TEMPORAL.TIPO);   
   END LOOP;   
   CLOSE NOMINA_CURSOR;   
   OPEN CurTabla for    
   --Devuelve la tabla de nomina con anexos de nopersonaltb y de puesto.    
        select A.*,B.gracad||' '||B.NOMBRE1||' '||B.NOMBRE2||' '||B.APELLIDO1||   
              ' '||B.APELLIDO2 NOM_CATEDRATICO, B.orden||' '||B.cedula NoCedula,    
              C.DESPUESTO PUESTO   
        from DBAFISICC.RHnominaTB A, DBAFISICC.NOPERSONALTB B, DBAFISICC.NOPUESTOSTB C   
        where A.codigo = VSOLICITUD   
        AND   A.CODPERS = B.CODPERS   
        AND   A.CODPUESTO = C.CODPUESTO;   