-- =====================================================================
-- NOVAMENTE · RETO DIARIO
-- Pegar COMPLETO en Supabase > SQL Editor > New query > Run
-- Solo CREA cosas nuevas. No toca ni borra nada de lo que ya existe.
-- =====================================================================

-- 1) Tabla de eventos: cada jugada, cada "compartir" y cada clic de fundador
create table if not exists public.eventos (
  id        uuid primary key default gen_random_uuid(),
  anon_id   text not null check (length(anon_id) between 4 and 64),
  tipo      text not null check (tipo in ('jugada','compartir','vip')),
  fecha     date not null,
  reto      int,
  aciertos  int check (aciertos between 0 and 20),
  total     int check (total between 1 and 20),
  segundos  numeric check (segundos >= 0 and segundos < 3600),
  ref       text check (ref is null or length(ref) <= 64),
  creado    timestamptz not null default now()
);

-- Una sola jugada por persona por día, y un solo clic de fundador por persona
create unique index if not exists eventos_una_jugada_por_dia on public.eventos (anon_id, fecha) where tipo = 'jugada';
create unique index if not exists eventos_un_vip_por_persona on public.eventos (anon_id) where tipo = 'vip';

-- 2) Tabla de suscriptores al correo diario
create table if not exists public.suscriptores (
  email    text primary key check (email = lower(email) and length(email) <= 254 and email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
  anon_id  text check (anon_id is null or length(anon_id) <= 64),
  creado   timestamptz not null default now()
);

-- 3) Seguridad: el público SOLO puede escribir, nunca leer
alter table public.eventos      enable row level security;
alter table public.suscriptores enable row level security;

drop policy if exists "nm_publico_inserta_eventos" on public.eventos;
create policy "nm_publico_inserta_eventos" on public.eventos
  for insert to anon, authenticated with check (true);

drop policy if exists "nm_publico_inserta_suscriptores" on public.suscriptores;
create policy "nm_publico_inserta_suscriptores" on public.suscriptores
  for insert to anon, authenticated with check (true);

grant usage on schema public to anon, authenticated, service_role;
grant insert on public.eventos, public.suscriptores to anon, authenticated;
grant all    on public.eventos, public.suscriptores to service_role;

-- 4) Tablero de la meta (lo lee Make cada mañana y te lo manda por correo)
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
     and fecha = (now() at time zone 'America/Bogota')::date - 1)            as jugadas_ayer;

revoke all on public.metricas from anon, authenticated;
grant select on public.metricas to service_role;

-- 5) Prueba: debe mostrar una fila con ceros
select * from public.metricas;
