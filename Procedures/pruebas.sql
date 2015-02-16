    select distinct pensum.carnet, notas.carrera,pensum.curso,
			       pensum.nomcursoe,pensum.nomcursoi,pensum.ciclo,
                   pensum.umas CA_pensum, notas.umas CA_CURSO, notas.nota,
                   notas.fechaimp, notas.codstatus, notas.tipoasig,
                   decode(notas.tipoasig,'EQ',notas.umas,0) CA_EQ,
                   decode(notas.tipoasig, null,0,pensum.umas) cas               
                   
                   
      from (select a.carnet, a.pensum, c.ciclo,c.curso,
                 pkg_curso.nombre(c.curso,c.carrera,c.pensum,1) nomCursoE,
                 pkg_curso.nombre(c.curso,c.carrera,c.pensum,2) nomCursoI,
                            c.historial, min(c.umas) umas
						from dbafisicc.caalumcarrstb a, dbafisicc.cacatpensatb c
            where a.carrera          = c.carrera
						and   a.pensum           = c.pensum
						and   a.carnet           = :pcarnet
						and   (a.statalum <> '4' or a.carrera = :pcarrera)
            and   nvl(c.historial,0) = 1
            and   a.carrera in (select carrera
                                  from dbafisicc.cacarrerasvw 
                                  where maincar = :pcarrera
                                  and statuc = 'A')
						group by a.carnet,a.pensum, c.ciclo,c.curso,c.historial,
								 pkg_curso.nombre(c.curso,c.carrera,c.pensum,1),
                                 pkg_curso.nombre(c.curso,c.carrera,c.pensum,2)
                        order by ciclo) pensum,
                        
    (select sustituto.eqcurso curso, n.nota, n.fechaimp, n.codstatus,
               n.tipoasig, n.umas, n.carrera
                 
        from (select carrera, curso, eqcarrera, eqcurso
                   from DBAFISICC.CACURSOSEQTB
                   where carrera = :pcarrera
                   and eqcarrera = :pcarrera) sustituto,  
                 
             (select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                        and (CODSTATUS='S6' OR (f.TIPOASIG='TE'
						                        and codstatus != 'S0'))) n
              where sustituto.curso = n.curso
              
              union select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                        and (CODSTATUS='S6' 
                            OR (f.TIPOASIG='TE' and codstatus != 'S0'))
                        and not exists(select 1
                                         from DBAFISICC.CACURSOSEQTB
                                         where carrera = :pcarrera
                                         and curso = f.curso)) notas
              where pensum.curso=notas.curso(+)
              order by pensum.ciclo asc;
              
              
              
-------------------------------------------------------------------------------   
              
              
      select distinct to_number(trunc(decode(sum(decode(notas.nota,null,0,
             pensum.umas)),0,0,sum(decode(notas.nota,null,0,
             pensum.umas*notas.nota))/sum(decode(notas.nota,null,0,pensum.umas)
             )),0))
        as promedio
        from (select distinct a.carnet, c.ciclo,
                     c.curso,c.historial,
                     min(c.umas) umas
                 from dbafisicc.caalumcarrstb a,
                      dbafisicc.cacatpensatb c
                 where a.carrera = c.carrera
                 and a.pensum    = c.pensum
                 and a.carnet    = :pcarnet
                 and a.pensum    = c.pensum
                 and nvl(c.historial,0)= 1
                 and a.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                 group by a.carnet, a.carrera,
                          a.pensum,c.ciclo,c.curso,
                          c.historial
                 order by ciclo) pensum,
             (select sustituto.eqcurso curso, n.nota, n.fechaimp, n.codstatus,
               n.tipoasig, n.umas, n.carrera
                 
        from (select carrera, curso, eqcarrera, eqcurso
                   from DBAFISICC.CACURSOSEQTB
                   where carrera = :pcarrera
                   and eqcarrera = :pcarrera) sustituto,  
                 
             (select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                        and (CODSTATUS='S6' OR (f.TIPOASIG='TE'
						                        and codstatus != 'S0'))) n
              where sustituto.curso = n.curso
              
              union select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                        and (CODSTATUS='S6' 
                            OR (f.TIPOASIG='TE' and codstatus != 'S0'))
                        and not exists(select 1
                                         from DBAFISICC.CACURSOSEQTB
                                         where carrera = :pcarrera
                                         and curso = f.curso)) notas
        where pensum.curso = notas.curso(+);
        
        
        delete cacursoseqtb
        commit;
        
        
        INSERT INTO DBAFISICC.CACURSOSEQTB(CARRERA, CURSO, EQCARRERA, 
                                           EQCURSO, OBSERVACIONES)
             SELECT 'LITA', IDACTIVO, 'LITA', PTEAPROBAR, 
                    'MIDEA.CURSOSEQUIVALENTES'
                 FROM MIDEA.CURSOSEQUIVALENTES;
        
        
        select * from cacursoseqtb
        
        
        
        
        
        select carrera, curso, eqcarrera, eqcurso
                   from DBAFISICC.CACURSOSEQTB
                   where carrera = :pcarrera
                   and eqcarrera = :pcarrera
                   and curso not in( select a.curso
                                           from caalumnosnotastb a, cacatpensatb b
                                           where a.carnet = :pcarnet
                                           and a.carrera in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                           and (a.CODSTATUS='S6' OR (a.TIPOASIG='TE'
						                                    and a.codstatus != 'S0'))
                                           and b.carrera in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                           and b.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera)
                                           and b.curso = a.curso)
                                                
                                                
                                                
                                                
                                                
                                                
                                                
       
    
    
    
    
    
    
    
    
  select sustituto.eqcurso curso, n.nota, n.fechaimp, n.codstatus,
               n.tipoasig, n.umas, n.carrera
                 
        from ( select carrera, curso, eqcarrera, eqcurso
                   from DBAFISICC.CACURSOSEQTB
                   where carrera = :pcarrera
                   and eqcarrera = :pcarrera
                   and curso not in( select a.curso
                                           from caalumnosnotastb a, cacatpensatb b
                                           where a.carnet = :pcarnet
                                           and a.carrera in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                           and (a.CODSTATUS='S6' OR (a.TIPOASIG='TE'
						                                    and a.codstatus != 'S0'))
                                           and b.carrera in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                           and b.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera)
                                           and b.curso = a.curso)
                   and eqcurso in( select a.curso
                                    from cacatpensatb a
                                    where a.carrera  in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                    and a.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera))) sustituto,  
                 
             (select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                        and (CODSTATUS='S6' OR (f.TIPOASIG='TE'
						                        and codstatus != 'S0'))) n
              where sustituto.curso = n.curso
              
              
                union select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                        and (CODSTATUS='S6' 
                            OR (f.TIPOASIG='TE' and codstatus != 'S0')) 
                        and f.curso not in(  select sustituto.curso 
                 
        from ( select carrera, curso, eqcarrera, eqcurso
                   from DBAFISICC.CACURSOSEQTB
                   where carrera = :pcarrera
                   and eqcarrera = :pcarrera
                   and curso not in( select a.curso
                                           from caalumnosnotastb a, cacatpensatb b
                                           where a.carnet = :pcarnet
                                           and a.carrera in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                           and (a.CODSTATUS='S6' OR (a.TIPOASIG='TE'
						                                    and a.codstatus != 'S0'))
                                           and b.carrera in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                           and b.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera)
                                           and b.curso = a.curso)
                   and eqcurso in( select a.curso
                                    from cacatpensatb a
                                    where a.carrera  in(select carrera
                                                           from cacarrerasvw
                                                           where maincar = :pcarrera)
                                    and a.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera))) sustituto,  
                 
             (select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in (select carrera
                                              from dbafisicc.cacarrerasvw 
                                              where maincar = :pcarrera)

                        and (CODSTATUS='S6' OR (f.TIPOASIG='TE'
						                        and codstatus != 'S0'))) n
              where sustituto.curso = n.curso)
              
              
              
              select * from cacarrerasvw;
              
              select * from casubcarrerastb
              
              
              
              
              
              
              
              select codigo
                  from dbafisicc.casubcarrerastb 
                  where carrera = :pcarrera
                  and status='A'
              union select :pcarrera
                  from dual
                  
                  
                  
                  
                  
  INSERT INTO "DBAFISICC"."CASUBCARRERASTB" (CARRERA, CODIGO, STATUS, VALIDA_PENSUM, FECHA) 
  VALUES ('LITA', 'LITA071', 'A', 'S', TO_DATE('2015-01-09 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
  
  
  
  
              select a.pensum 
              
              from ( select to_number(SUBSTR(TO_CHAR(PENSUM),6,4)) year2, pensum  
              from CAPENSATB
              where carrera = 'LITA') a
              where a.year2 >= 2011 
              order by a.year2 asc
              
              
              
              
              
              
              
              
              
              
                 select promedio.ciclo, trunc(sum(promedio.nota * promedio.ca_pensum) / sum(promedio.ca_pensum), 2) promedio    
        
    from(select distinct pensum.carnet, notas.carrera,pensum.curso,
			       pensum.nomcursoe,pensum.nomcursoi,pensum.ciclo,
                   pensum.umas CA_pensum, notas.umas CA_CURSO, 
                   (case when TO_CHAR(pensum.ciclo) = '16'
                           and :pcarrera = 'LITA'
                           and :vpensum2 = 1
                           then (case when notas.nota is not null then 'A' end) else TO_CHAR(notas.nota) end) nota,
                   notas.fechaimp, notas.codstatus, notas.tipoasig,
                   decode(notas.tipoasig,'EQ',notas.umas,0) CA_EQ,
                   decode(notas.tipoasig, null,0,pensum.umas) cas               
                   
                   
      from (select a.carnet, a.pensum, c.ciclo,c.curso,
                 pkg_curso.nombre(c.curso,c.carrera,c.pensum,1) nomCursoE,
                 pkg_curso.nombre(c.curso,c.carrera,c.pensum,2) nomCursoI,
                            c.historial, min(c.umas) umas
						from dbafisicc.caalumcarrstb a, dbafisicc.cacatpensatb c
            where a.carrera          = c.carrera
						and   a.pensum           = c.pensum
						and   a.carnet           = :pcarnet
						and   (a.statalum <> '4' or a.carrera = :pcarrera)
            and   nvl(c.historial,0) = 1
            and   a.carrera in ( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)
						group by a.carnet,a.pensum, c.ciclo,c.curso,c.historial,
								 pkg_curso.nombre(c.curso,c.carrera,c.pensum,1),
                                 pkg_curso.nombre(c.curso,c.carrera,c.pensum,2)
                        order by ciclo) pensum,
                        
        ( select sustituto.eqcurso curso, n.nota, n.fechaimp, n.codstatus,
               n.tipoasig, n.umas, n.carrera
                 
        from ( select carrera, curso, eqcarrera, eqcurso
                   from DBAFISICC.CACURSOSEQTB
                   where carrera = :pcarrera
                   and eqcarrera = :pcarrera
                   and curso not in( select a.curso
                                           from caalumnosnotastb a, cacatpensatb b
                                           where a.carnet = :pcarnet
                                           and a.carrera in( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)
                                           and (a.CODSTATUS='S6' OR (a.TIPOASIG='TE'
						                                    and a.codstatus != 'S0'))
                                           and b.carrera in( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)
                                           and b.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera)
                                           and b.curso = a.curso)
                   and eqcurso in( select a.curso
                                    from cacatpensatb a
                                    where a.carrera  in( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)
                                    and a.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera))) sustituto,  
                 
             (select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in ( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)

                        and (CODSTATUS='S6' OR (f.TIPOASIG='TE'
						                        and codstatus != 'S0'))) n
              where sustituto.curso = n.curso
              
              
                union select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in ( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)

                        and (CODSTATUS='S6' 
                            OR (f.TIPOASIG='TE' and codstatus != 'S0')) 
                        and f.curso not in(  select sustituto.curso 
                 
        from ( select carrera, curso, eqcarrera, eqcurso
                   from DBAFISICC.CACURSOSEQTB
                   where carrera = :pcarrera
                   and eqcarrera = :pcarrera
                   and curso not in( select a.curso
                                           from caalumnosnotastb a, cacatpensatb b
                                           where a.carnet = :pcarnet
                                           and a.carrera in( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)
                                           and (a.CODSTATUS='S6' OR (a.TIPOASIG='TE'
						                                    and a.codstatus != 'S0'))
                                           and b.carrera in( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)
                                           and b.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera)
                                           and b.curso = a.curso)
                   and eqcurso in( select a.curso
                                    from cacatpensatb a
                                    where a.carrera  in( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)
                                    and a.pensum = (select pensum 
                                                            from caalumcarrstb
                                                            where carnet = :pcarnet
                                                            and carrera = :pcarrera))) sustituto,  
                 
             (select f.curso, f.nota, f.fechaimp,f.codstatus,f.tipoasig,
                             NVL(f.umas,g.umas) umas, f.carrera
                        from dbafisicc.caalumnosnotastb f,
                             dbafisicc.cahcursosimptb g
                        where f.carnet = :pcarnet
                        and f.carrera = g.carrera
                        and f.curso = g.curso
                        and f.tipoasig = g.tipoasig
                        and f.fechaimp = g.fechaimp
                        and f.seccion = g.seccion
                        and   f.carrera in ( select codigo
                                        from dbafisicc.casubcarrerastb 
                                        where carrera = :pcarrera
                                        and status='A'
                                    union select :pcarrera
                                        from dual)

                        and (CODSTATUS='S6' OR (f.TIPOASIG='TE'
						                        and codstatus != 'S0'))) n
              where sustituto.curso = n.curso)) notas
              where pensum.curso=notas.curso
              order by pensum.ciclo asc) promedio
              where to_char(promedio.nota) != 'A'
              
              group by promedio.ciclo
              order by promedio.ciclo;
              
              
              
              
              
                   select a.carnet,c.carrera,
                   pkg_carrera.nombre(c.carrera,c.pensum,1) nomCarrera, a.CURSO,
                   pkg_curso.nombre(a.curso,c.carrera,c.pensum,1) nomcursoe,
                   pkg_curso.nombre(a.curso,c.carrera,c.pensum,2) nomcursoi,
                   nvl(a.ciclo,d.ciclo) ciclo, nvl(a.umas,d.UMAS) ca_curso,
                   decode(a.tipoasig,'EQ',null,'PRY',null,'SEM',null,nota) nota,
                    a.fechaimp, codstatus, a.tipoasig,
                   decode(a.tipoasig,'EQ',a.umas,0) CA_EQ,
                   (select min(umas)
                      from dbafisicc.cacatpensatb d
                      where d.carrera = a.carrera
                      and d.pensum = c.pensum
                      and d.curso = a.curso) ca_pensum
              from dbafisicc.CAALUMNOSNOTASTB a, DBAFISICC.caalumcarrstb c,
                   dbafisicc.cahcursosimptb d
              WHERE A.CARNET = :PCARNET
                and a.carrera in (select codigo
                                    from DBAFISICC.casubcarrerastb
                                    where carrera = :PCARRERA
                                    union
                                    select :PCARRERA
                                      from DUAL)
               and a.carrera = c.carrera
               and a.carnet=c.carnet
               and a.carrera = d.carrera
               and a.curso = d.curso
               and a.tipoasig = d.tipoasig
               and a.fechaimp = d.fechaimp
               and a.seccion = d.seccion
               and c.universidad=(select universidad
                                    from caalumcarrstb where carnet=a.carnet
									and carrera=:PCARRERA)
               AND A.CURSO NOT IN (SELECT CURSO
                                    FROM CACATPENSATB
                                    WHERE CARRERA = c.carrera
                                      AND PENSUM  = c.pensum
                                      AND HISTORIAL=0)
/* AALVARADO - 22/07/2013 - SE AGREGO LA VALIDACION SI ES TIPOASIG = TE
                                    QUE TAMBIEN VALIDE QUE NO SEA ANULADO.*/
                AND (CODSTATUS='S6' OR (a.TIPOASIG='TE' and a.codstatus != 'S0'))
                order by nvl(a.ciclo,d.ciclo),a.fechaimp,A.curso;
                
                
    
    
    
    
              SELECT F.CURSO,  F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = :PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND   F.CARRERA IN ( SELECT CARRERA
                                                  FROM DBAFISICC.CACARRERASVW 
                                                  WHERE MAINCAR = :PCARRERA
                                              )

                        AND (CODSTATUS='S6' OR (F.TIPOASIG='TE'
						                        AND CODSTATUS != 'S0'));            
                
                
                
                
                
                SELECT F.CURSO,  pkg_curso.nombre(f.curso,f.carrera, :ppensum,1) nomcursoe,
                   pkg_curso.nombre(f.curso,f.carrera, :ppensum,2) nomcursoi,  nvl(f.ciclo, g.ciclo) ciclo, F.NOTA, F.FECHAIMP,F.CODSTATUS,F.TIPOASIG,
                             NVL(F.UMAS,G.UMAS) UMAS, F.CARRERA
                        FROM DBAFISICC.CAALUMNOSNOTASTB F,
                             DBAFISICC.CAHCURSOSIMPTB G
                        WHERE F.CARNET = :PCARNET
                        AND F.CARRERA = G.CARRERA
                        AND F.CURSO = G.CURSO
                        AND F.TIPOASIG = G.TIPOASIG
                        AND F.FECHAIMP = G.FECHAIMP
                        AND F.SECCION = G.SECCION
                        AND   F.CARRERA IN ( SELECT CARRERA
                                                  FROM DBAFISICC.CACARRERASVW 
                                                  WHERE MAINCAR = :PCARRERA
                                              )

                        AND (CODSTATUS='S6' OR (F.TIPOASIG='TE'
						                        AND CODSTATUS != 'S0'));
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
  select TRUNC(FECHANAC) from dbafisicc.CAALUMNOSTB
  where carnet = '12002587'
                                    
                          
                          
  
update new_table
       set new_table.ciclo = old_table.ciclo2,
           new_table.umas = old_table.umas2
        
        from dbafisicc.CAALUMNOSNOTASTB as new_table,     
             (SELECT a.curso, C.CURSO curso2 ,a.CICLO, c.ciclo ciclo2, 
                          a.umas, c.umas umas2, a.carrera, A.CARNET, A.SECCION, 
                          A.TIPOASIG, a.codstatus, a.fechaimp
                    FROM DBAFISICC.CAALUMNOSNOTASTB a,
                         DBAFISICC.CAALUMCARRSTB B, 
                         DBAFISICC.CACATPENSATB C
                    WHERE  a.carnet = :pcarnet
                    and    a.carrera in( select carrera
                                            from dbafisicc.cacarrerasvw
                                            where maincar = :pcarrera)
                    and   B.CARRERA          = C.CARRERA
                    AND   B.PENSUM           = C.PENSUM
                    AND   B.CARNET           = a.carnet
                    AND   (B.STATALUM <> '4' OR B.CARRERA = :pcarrera)
                    AND   NVL(C.HISTORIAL,0) = 1
                    AND   B.CARRERA = :pcarrera
                    and   c.curso = a.curso) as old_table
          
          where new_table.carnet = old_table.carnet
          and new_table.carrera = old_table.carrera
          and new_table.curso = old_table.curso
          and new_table.seccion = old_table.seccion
          and new_table.tipoasig = old_table.tipoasig
          and new_table.codstatus = old_table.codstatus
          and new_table.fechaimp = old_table.fechaimp;
                                    
      
      
      
     UPDATE DBAFISICC.CAALUMNOSNOTASTB A 
     SET (A.CICLO, A.UMAS) =   
         (SELECT C.CICLO, C.UMAS
              FROM DBAFISICC.CAALUMNOSNOTASTB B,
                   DBAFISICC.CACATPENSATB C
              WHERE B.CARNET = A.CARNET
              AND B.CARRERA = A.CARRERA
              AND B.CURSO = A.CURSO
              AND B.SECCION = A.SECCION
              AND B.TIPOASIG = A.TIPOASIG
              AND B.CODSTATUS = A.CODSTATUS
              AND B.FECHAIMP = A.FECHAIMP
              AND C.PENSUM = (SELECT PENSUM 
                                 FROM DBAFISICC.CAALUMCARRSTB
                                 WHERE CARNET = A.CARNET
                                 AND CARRERA = 'LITA')
              AND C.CURSO = B.CURSO)
                 
    WHERE A.CARRERA IN (SELECT CARRERA
                          FROM DBAFISICC.CACARRERASVW
                          WHERE MAINCAR = 'LITA');   
                                    
                                    
                                    
                                    
