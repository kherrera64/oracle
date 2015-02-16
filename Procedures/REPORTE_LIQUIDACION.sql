/*
autor: Pablo Gonzalez
Fecha: 01/04/2014
Descripcion: El Procedimiento devuelve los datos necesarios para la impresion 
			 del reporte de Liquidacion por Centros Externos, recibe los parametros:
             Usuario, Entidad, Director, Sede, Grado, Carrera, Concepto, Fecha 
             Inicio, Fecha Fin.
      Modificacion: AALVARADO - 29/04/2014 - Se agrego el parametro
      para mandar listas de parametros. 
      Modificacion: KHERRERA - 08/05/2014 - Se utiliza la funcion 
      RINGRESOSTIPOPAGO2 para obtener el total de los tipos de monto. 
      Modificacion: KHERRERA - 12/05/2014 - Se utilizar la funcion 
      RINGRESOSTIPOPAGO2 para obtener el total de los tipos de monto. 
      Modificacion: KHERRERA - 14/05/2014 - Se utilizan las funciones  
      RINGXCQBI, RINGXCQOT, RINGXMQIN  para obtener tipos de pago.
      Modificacion: KHERRERA - 26/05/2014 - Se utilizan la funcion
      RINGRESOSTIPOPAGO  para obtener tipos de pago.
*/
PROCEDURE REPORTE_LIQUIDACION 
(
  PSEDE       DBAFISICC.CACARRERASTB.COMENTARIOS%type default null,
  PENCARGADO  DBAFISICC.cacarrerastb.encargado%TYPE default null,
  PFECHAINI   DBAFISICC.CCTRANSACCTB.FECHA%type,
  PFECHAFIN   DBAFISICC.cctransacctb.fecha%TYPE,
  PCONCEPTO   DBAFISICC.ccdetranstb.codmovto%TYPE default null,
  PCARRERA    DBAFISICC.CACARRERASTB.CARRERA%type default null,
  PENTIDAD    DBAFISICC.CACARRERASTB.ENTIDAD%type default null,  
  PUSUARIO    DBAFISICC.GNUSUARIOSTB.USUARIO%type default null,
  PGRADO      DBAFISICC.CACARRERASTB.GRADO%type default null
) IS
BEGIN 
    
    delete from DBAFISICC.TEMP_RINGRESOSTIPOPAGO
           where usuario = pusuario;
    
     insert into TEMP_RINGRESOSTIPOPAGO(CARRERA, ENCARGADO, NOMBRE, COMENTARIOS, 
              CODMOVTO, FACULTAD, FACNAME, PCT, CARNAME, DESMOVTO, R, NDT, NCT, 
              REFECTIVO, RCHEQUESBI, RCHEQUESOT, RTARJETAS, RMQSERIESAG, 
              RMQSeriesIN, USUARIO)            
         select a.CARRERA,D.ENCARGADO, 
               dbafisicc.pkg_personal.nombre(d.encargado,1) nombre,
               D.COMENTARIOS, B.CODMOVTO, C.ENTIDAD FACULTAD, 
               C.NOMBRE_CORTO FACNAME,nvl((select p.pct 
                                            from DBAFISICC.CCCARRERALIQTB P 
                                            where a.CARRERA = P.CARRERA
                                            and B.CODMOVTO = P.CODMOVTO),0) PCT,
               D.NOMBRE_CORTO CARNAME, E.MOVIMIENTO DESMOVTO,
               (select NVL(SUM(DECODE(AB.TIPO,'NDA',
                                      BB.MONTO*-1,BB.MONTO)),0) MONTO
                    from DBAFISICC.CCTRANSACCTB AB,DBAFISICC.CCDETRANSTB BB
                    where AB.CARRERA = a.CARRERA
                    and   AB.FECHA = BB.FECHA
                    and   AB.TIPO = BB.TIPO
                    and   AB.NUMERO = BB.NUMERO
                    and   AB.TIPO in ('R','NDA')
                    and   nvl(ab.flagoperado,'O') != 'A'
                    and   BB.CODMOVTO             = B.CODMOVTO
                    and   AB.FECHA between (PFECHAINI) and (PFECHAFIN)) R ,
           
               (select NVL(SUM(BC.MONTO)*-1,0)  
                    from DBAFISICC.CCTRANSACCTB AC,DBAFISICC.CCDETRANSTB BC
                    where AC.CARRERA = a.CARRERA
                    and   AC.FECHA = BC.FECHA
                    and   AC.TIPO = BC.TIPO
                    and   AC.NUMERO = BC.NUMERO
                    and   AC.TIPO in ('NDT','DI','NDR')
                    and   NVL(AC.FLAGOPERADO,'O') != 'A'
                    and   BC.CODMOVTO = B.CODMOVTO
                    and   AC.FECHA between (PFECHAINI) and (PFECHAFIN)) NDT,
           
           --obtengo los ingresos desglosados que corresponden a los creditos
               (select NVL(SUM(BD.MONTO),0)
                   from DBAFISICC.CCTRANSACCTB AD,DBAFISICC.CCDETRANSTB BD
                   where AD.CARRERA = a.CARRERA
                   and AD.FECHA = BD.FECHA
                   and AD.TIPO = BD.TIPO
                   and AD.NUMERO = BD.NUMERO
                   and AD.TIPO in ('NCT','NCR')
                   and NVL(AD.FLAGOPERADO,'O') != 'A'
                   and BD.CODMOVTO = B.CODMOVTO
                   and AD.FECHA between (PFECHAINI) and (PFECHAFIN)) NCT,
                   
               NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PFECHAINI,PFECHAFIN,'R', 
                                                'EFECTIVO', null, a.CARRERA),0) 
                                                REFECTIVO,  
               NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PFECHAINI,PFECHAFIN,'R', 
                                                'CHEQUES', 'BI', a.CARRERA),0)
                                                RCHEQUESBI,
               NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PFECHAINI,PFECHAFIN,'R', 
                                               'CHEQUES', 'OTROS', a.CARRERA),0)
                                                RCHEQUESOT,
               NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PFECHAINI,PFECHAFIN,'R', 
                                                'TARJETA', null, a.CARRERA),0) 
                                                RTARJETAS, 
               NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PFECHAINI,PFECHAFIN,'R', 
                                                'BIENLINEA', 712, a.CARRERA),0) 
                                                RMQSERIESAG,
               NVL(DBAFISICC.EDOCTA.RINGRESOSTIPOPAGO(PFECHAINI,PFECHAFIN,'R', 
                                                'BIENLINEA', 718, a.CARRERA),0) 
                                                RMQSERIESIN,
               PUSUARIO as USUARIO                                 

      
                     from DBAFISICC.CCTRANSACCTB a,DBAFISICC.CCDETRANSTB B,
                          DBAFISICC.GNENTIDADESTB C,DBAFISICC.CACARRERASTB D,
                          DBAFISICC.CCTIPOMOVTOTB E
                     where E.CODMOVTO = B.CODMOVTO
                     and C.ENTIDAD = D.ENTIDAD
                     and NVL(D.LIQUIDACION,0) = 1
                     and D.CARRERA = a.CARRERA
                 --obtengo la carrera segun el Usuario, Entidad, Director,
                 --Sede, Grado, Carrera, Concepto, Fecha Inicio, Fecha Fin
                     and  exists (select 1 
                                     from DBAFISICC.CAUSUARIOSCARRERASTB E
                                     where E.USUARIO = PUSUARIO
                                     and E.CARRERA = D.CARRERA)
                     and (D.ENTIDAD in (select * 
                                          from table(SPLIT_VARCHAR(
                                                            PENTIDAD,',')))or 
                                                            PENTIDAD is null)
                     and(D.CARRERA in (select * 
                                          from table(SPLIT_VARCHAR(
                                                             PCARRERA,','))) or 
                                                             PCARRERA is null)
                     and a.FECHA = B.FECHA
                     and a.TIPO = B.TIPO
                     and NVL(a.FLAGOPERADO,'O') != 'A'
                     and D.FACULTAD = '002'
                     and C.FACULTAD = '002'
                     and a.NUMERO = B.NUMERO
                     and a.TIPO in ('NDT','R','NCT','NDA','DI','NDR','NCR')
                     and (B.CODMOVTO = PCONCEPTO or PCONCEPTO is null)
                     and TRUNC(a.FECHA) between (PFECHAINI) and (PFECHAFIN)
                     and (D.ENCARGADO in (select *
                                            from table(SPLIT_VARCHAR(
                                                         PENCARGADO,','))) or 
                                                         PENCARGADO is null)
                     and (D.COMENTARIOS in (select * from table(SPLIT_VARCHAR(
                                                               PSEDE,','))) or 
                                                               PSEDE is null) 
                     and (D.GRADO in (select * from table(SPLIT_VARCHAR(
                                                          PGRADO,','))) or 
                                                          PGRADO is null)   
          
        group by a.CARRERA, D.ENCARGADO, D.COMENTARIOS, B.CODMOVTO, C.ENTIDAD, 
                 C.NOMBRE_CORTO, D.NOMBRE_CORTO, E.MOVIMIENTO;  

END REPORTE_LIQUIDACION;