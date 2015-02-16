/*
Autor:  Kevin Herrera.
Fecha:  11/03/2014
Descripcion: Devuelve todos los alumnos con saldo en el concepto
            correspondiente.
Modificaciones:
    21/03/2014 - Javier Garcia: Se agregaron los parametros PCICLO y PSECCION
                                y el campo SECCION de la tabla CAALUMCARRSTB.
                                
Modificaciones:
    24/03/2014 - Javier Garcia: Antes de ejecutar y devolver la consulta se
                                carga la informacion de las tablas
                                CCHEDOCTADETALLETB y multas MULTASTMP.
    08/04/2014 - AALVARADO - Se arreglaron las validaciones para mejorar la 
    respuesta del Query.
    
    22/05/2014 - Javier Garcia: Se agregaron los campos MORA y CODMOVTO a la
                                consulta y se elimino el union que hacia
                                select a MULTASTMP en la tabla A pues provocaba
                                duplicidad de datos.
    11/06/2014 - Javier Garcia: Se agrego el campo MOVIMIENTO a la consulta.
    
    25/06/2014 - Kevin Herrera: Se valida que el usuario que genera el reporte 
                                tenga agregada la carrera.
*/
 procedure SALDOSXCONCEPTO  
  (    
    PUSUARIO DBAFISICC.CAUSUARIOSCARRERASTB.USUARIO%type default null,
    PCARNET DBAFISICC.CAALUMCARRSTB.CARNET%type default null,
    PCARRERA DBAFISICC.CAALUMCARRSTB.CARRERA%type default null,
    PINSCRITO DBAFISICC.CAALUMCARRSTB.INSCRITO%type default null,
    PCONCEPTO DBAFISICC.CCHEDOCTADETALLETB.CONCEPTO%TYPE DEFAULT NULL,
    PCICLO    DBAFISICC.CAALUMCARRSTB.CICLO%TYPE DEFAULT NULL,
    PSECCION  DBAFISICC.CAALUMCARRSTB.SECCION%TYPE DEFAULT NULL,
    RETVAL  OUT SYS_REFCURSOR  
  )    
  as
    cursor carnets (pcarrera cacarrerastb.carrera%type) is
       select a.carnet,a.carrera
          from dbafisicc.caalumcarrstb a
          where (a.carrera = PCARRERA or PCARRERA is null)
          and   (CARNET = PCARNET or PCARNET is null)
          and   (NVL(a.inscrito,0) = pinscrito or pinscrito is null);
    CARNETS_REC CARNETS%ROWTYPE;
    monto number;
  begin  
     FOR carnets_rec IN carnets(PCARRERA)
       LOOP
         MONTO := DBAFISICC.EDOCTA.LLENAEDOCTA(CARNETS_REC.CARNET,
                                               CARNETS_REC.CARRERA);
         if nvl(PCONCEPTO,'MU') = 'MU' then   
           DBAFISICC.MULTASEDOCTA(CARNETS_REC.CARNET, CARNETS_REC.CARRERA, '0');
        end if; 
       END LOOP;
  
  open RETVAL for 
  
     SELECT a.CARRERA,a.CARNET, DBAFISICC.PKG_ALUMNO.NOMBRE(a.CARNET, 2) NOMBRE,
           B.INSCRITO, a.CONCEPTO,  sum(ABONOS) abonos, B.SECCION,
           sum(SALDO) saldo, sum(MORA) MORA,
           dbafisicc.pkg_alumno.telefonos(a.carnet) telefono, 
           dbafisicc.pkg_alumno.email(a.carnet) EMAIL, B.CICLO, B.STATALUM, 
           C.CEDULA, C.DPI, C.PASAPORTE, A.CODMOVTO,
           DECODE(D.CODMQ,1,UPPER(D.DESCRIPCIONMQ),4,UPPER(D.DESCRIPCIONMQ),
           D.MOVIMIENTO) MOVIMIENTO
           
       from (select CARRERA,CARNET, concepto, PAGOS+ABONOS ABONOS, 
                    CARGOS-PAGOS-ABONOS saldo, MORA, CODMOVTO
              from DBAFISICC.CCHEDOCTADETALLETB 
              where (carrera = PCARRERA or PCARRERA is null)
              and (CARNET = PCARNET or PCARNET is null)
              and (CONCEPTO = PCONCEPTO or PCONCEPTO is null)) a,
            DBAFISICC.CAALUMCARRSTB B, DBAFISICC.CAALUMNOSTB C,
            DBAFISICC.cctipomovtotb D, dbafisicc.causuarioscarrerastb e
            
        where a.carnet=b.carnet
        and b.carnet = c.carnet
        and a.carrera=b.carrera
        and a.carrera = e.carrera
        and (E.usuario=PUSUARIO OR PUSUARIO IS NULL)
        and B.CARNET = a.CARNET
        and d.codmovto = a.CONCEPTO
        and (NVL(b.inscrito,0) = PINSCRITO or PINSCRITO is null)
        and (b.ciclo = PCICLO OR PCICLO IS NULL)
        and (b.seccion = PSECCION OR PSECCION IS NULL)
        
        group by a.CARRERA,a.CARNET, B.INSCRITO, a.CONCEPTO,B.SECCION,
                 B.CICLO, B.STATALUM,C.CEDULA, C.DPI, C.PASAPORTE, A.CODMOVTO,
                 DECODE(D.CODMQ,1,UPPER(D.DESCRIPCIONMQ),4,
                 UPPER(D.DESCRIPCIONMQ), D.MOVIMIENTO)
        order by a.carrera;
    
    END SALDOSXCONCEPTO;