-- =====================================================================
-- NOVAMENTE · IDIOMAS (ES / PT / EN)
-- Pegar COMPLETO en Supabase > SQL Editor > New query > Run
-- Requisito: haber corrido antes novamente_reto.sql
-- Solo AGREGA. No borra datos ni cambia lo que ya funciona.
-- =====================================================================

-- 1) Guardar el idioma de cada jugada y de cada suscriptor
alter table public.eventos      add column if not exists idioma text check (idioma is null or idioma in ('es','pt','en'));
alter table public.suscriptores add column if not exists idioma text check (idioma is null or idioma in ('es','pt','en'));

-- 2) Tablero de la meta + jugadores por idioma (mismas columnas de antes, 3 nuevas al final)
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
  (select count(distinct anon_id) from public.eventos where tipo = 'jugada' and idioma = 'en') as jugadores_en;

revoke all on public.metricas from anon, authenticated;
grant select on public.metricas to service_role;

-- 3) Prueba: debe mostrar una fila con las 10 columnas
select * from public.metricas;
