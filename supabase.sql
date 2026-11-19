-- Roleta Hakura · base de dados (Supabase)
-- Tudo numa só tabela: leads (nome, email, prémio e nota da equipa).
-- Já aplicado no projeto Hakura-Roleta. Para um projeto novo: SQL Editor > New query > colar tudo > Run.

create table if not exists public.leads (
  id            uuid primary key,
  nome          text not null check (char_length(nome) between 2 and 120),
  email         text not null check (char_length(email) between 5 and 200),
  consentimento boolean not null default false,
  evento        text,
  criado_em     timestamptz not null default now(),
  premio        text check (char_length(premio) <= 200),
  premio_em     timestamptz,
  notas         text check (char_length(notas) <= 1000)
);
-- cada email só joga uma vez por evento
create unique index if not exists leads_email_evento_unico
  on public.leads (lower(email), coalesce(evento, ''));

-- Segurança: com a chave pública só se pode INSERIR leads (com consentimento).
-- Ninguém consegue ler, alterar ou apagar dados a partir do site.
alter table public.leads enable row level security;
create policy "roleta insere leads" on public.leads
  for insert to anon with check (consentimento = true);
grant insert on public.leads to anon;

-- O tablet grava o prémio (uma única vez) e a nota da equipa através destas funções.
create or replace function public.registar_premio(p_lead uuid, p_premio text)
returns void language sql security definer set search_path = '' as $f$
  update public.leads set premio = left(p_premio, 200), premio_em = now()
  where id = p_lead and premio is null;
$f$;

create or replace function public.registar_nota(p_lead uuid, p_nota text)
returns void language sql security definer set search_path = '' as $f$
  update public.leads set notas = nullif(left(trim(p_nota), 1000), '')
  where id = p_lead and criado_em > now() - interval '2 days';
$f$;

revoke all on function public.registar_premio(uuid, text) from public;
revoke all on function public.registar_nota(uuid, text)   from public;
grant execute on function public.registar_premio(uuid, text) to anon;
grant execute on function public.registar_nota(uuid, text)   to anon;

-- Ver os leads:
-- select criado_em, nome, email, premio, notas, evento from public.leads order by criado_em desc;
