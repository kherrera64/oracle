select * from
(
SELECT sum(nvl(a.cargo,0))-sum(nvl(a.abono,0))saldo, a.codmovto, a.movimiento,a.curso,a.nombre,
       a.periodo, a.centro 
FROM
(
SELECT DECODE(A.CARGO_ABONO,'C',MONTO) CARGO,DECODE(A.CARGO_ABONO,'A',MONTO) ABONO,
       A.CODMOVTO, B.MOVIMIENTO ,A.CURSO, C.NOMBRE,A.NUMCTA PERIODO,
       A.CENTRO 
       FROM DBAFISICC.CCEDOCTATB A,  DBAFISICC.CCTIPOMOVTOTB B, 
            DBAFISICC.CACURSOSTB C
          WHERE A.CARNET = :PCARNET
          AND A.CARRERA = :PCARRERA
          AND A.CODMOVTO NOT IN ('AS','VI','EC','BC','RT','CT','CTE','DT','APF')
          AND B.CODMOVTO = A.CODMOVTO 
          AND C.CURSO(+) = A.CURSO
ORDER BY A.CODMOVTO, A.PERIODO) a
group by a.codmovto, a.movimiento,a.curso,a.nombre,a.periodo, a.centro)b
where b.saldo >0;


-- CCEDOCTATB


      select B.CENTRO, B.CODMOVTO, B.MOVIMIENTO, B.CURSO, B.NOMBRE, B.SALDO 
         
         from (SELECT sum(nvl(a.cargo,0))-sum(nvl(a.abono,0))saldo, a.codmovto, 
                      a.movimiento,a.curso,a.nombre, a.centro 
                     
                  FROM (SELECT DECODE(A.CARGO_ABONO,'C',MONTO) CARGO,
                               DECODE(A.CARGO_ABONO,'A',MONTO) ABONO,
                               A.CODMOVTO, B.MOVIMIENTO, 
                               DECODE(A.CODMOVTO, 'MU', '' ,A.CURSO) CURSO, 
                               DECODE(A.CODMOVTO, 'MU', '' ,C.NOMBRE) NOMBRE,
                               nvl(A.CENTRO, :PCARRERA) CENTRO
       
                         FROM DBAFISICC.CCEDOCTATB A, DBAFISICC.CCTIPOMOVTOTB B, 
                              DBAFISICC.CACURSOSTB C
                         WHERE A.CARNET = :PCARNET
                         AND A.CARRERA = :PCARRERA
                         AND A.CODMOVTO NOT IN ('AS','VI','EC','BC','RT','CT',
                                                'CTE','DT','APF')
                         AND B.CODMOVTO = A.CODMOVTO 
                         AND C.CURSO(+) = A.CURSO
                        ORDER BY A.CODMOVTO) a
                        
               group by a.codmovto, a.movimiento,a.curso,a.nombre, a.centro)b
         where b.saldo >0
      order by B.CODMOVTO;


-- CCHEDOCTATVB

              
         select c.carnet, c.carrera, c.centro, c.codmovto, c.movimiento, 
                c.curso, c.nombre, c.trimestre, c.saldo  
                 
              from (select b.carnet, b.carrera, b.centro, b.concepto codmovto, 
                           b.codmovto movimiento, b.codcurso curso, b.curso 
                           nombre, b.trimestre, to_char(SUM(b.CARGOS)- 
                           SUM(b.PAGOS)- SUM(b.ABONOS), '999,999.00') as saldo
                  
                        from (SELECT A.carnet, a.carrera, a.centro, a.concepto, 
                                     a.codmovto, DECODE(A.concepto, 'MU', '' , 
                                     A.codcurso) codcurso, DECODE(A.concepto, 
                                     'MU', '' , A.curso) curso, nvl(a.cargos,0) 
                                     cargos, nvl(a.pagos, 0) pagos, 
                                     nvl(a.abonos, 0) abonos, a.trimestre
                                   
                                 FROM DBAFISICC.cchedoctadetalletb A
                                 WHERE A.CARNET = '0411046'
                                 AND A.CARRERA = 'LITA'
                                 AND A.CONCEPTO NOT IN ('AS','VI','EC','BC',
                                                        'RT', 'CT','CTE','DT',
                                                        'APF')
                              ) b
                              
                     group by b.carnet, b.carrera, b.centro, b.CONCEPTO, 
                              b.codmovto, b.codcurso, b.curso, b.trimestre) c
              where c.saldo > 0
            order by c.codmovto;
