-- =====================================================================
-- NOVAMENTE · NIVELES (Básico / Intermedio / Experto)
-- Pegar COMPLETO en Supabase > SQL Editor > New query > Run
-- Requisito: haber corrido antes 01_reto.sql y 02_idiomas.sql
-- Solo AGREGA. No borra datos ni cambia lo que ya funciona.
-- =====================================================================

-- 1) Guardar el nivel de cada jugada
alter table public.eventos add column if not exists nivel text check (nivel is null or nivel in ('basico','intermedio','experto'));

-- 2) Tablero: mismas columnas de antes + 3 nuevas al final (jugadores por nivel)
create or replace view public.metricas with (security_invoker = true) as
select
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada') as jugadores,
  (select count(*) from (
      select anon_id from public.eventos where tipo = 'jugada'
      group by anon_id having count(distinct fecha) >= 2) r)                as regresan,
  (select count(*) from public.suscriptores)                                 as suscriptores,
  (select count(*) from public.eventos where tipo = 'vip')                   as quieren_vip,
  (select count(distinct anon_id) from public.eventos
     where tipo = 'jugada' and ref is not null)                              as llegaron_por_amigo,
  (select count(*) from public.eventos where tipo = 'compartir')             as compartidos,
  (select count(*) from public.eventos where tipo = 'jugada'
     and fecha = (now() at time zone 'America/Bogota')::date - 1)            as jugadas_ayer,
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada' and idioma = 'es') as jugadores_es,
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada' and idioma = 'pt') as jugadores_pt,
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada' and idioma = 'en') as jugadores_en,
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada' and nivel = 'basico')     as jugadores_basico,
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada' and nivel = 'intermedio') as jugadores_intermedio,
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada' and nivel = 'experto')    as jugadores_experto;

revoke all on public.metricas from anon, authenticated;
grant select on public.metricas to service_role;

-- 3) Prueba: debe mostrar una fila con 13 columnas
select * from public.metricas;
