-- Roleta Hakura · tabelas para o evento
-- Correr uma vez no Supabase: SQL Editor > New query > colar tudo > Run.

-- 1. Leads (nome + email), um por email em cada evento
create table if not exists public.leads (
  id            uuid primary key,
  nome          text not null check (char_length(nome) between 2 and 120),
  email         text not null check (char_length(email) between 5 and 200),
  consentimento boolean not null default false,
  evento        text,
  criado_em     timestamptz not null default now()
);
create unique index if not exists leads_email_evento_unico
  on public.leads (lower(email), coalesce(evento, ''));

-- 2. Jogadas: o prémio que saiu a cada lead
create table if not exists public.jogadas (
  id        bigint generated always as identity primary key,
  lead_id   uuid not null references public.leads(id) on delete cascade,
  premio    text not null check (char_length(premio) <= 200),
  criado_em timestamptz not null default now()
);

-- 3. Segurança: o tablet só pode INSERIR. Ninguém consegue ler os dados com a chave pública.
alter table public.leads   enable row level security;
alter table public.jogadas enable row level security;

drop policy if exists "roleta insere leads" on public.leads;
create policy "roleta insere leads" on public.leads
  for insert to anon with check (consentimento = true);

drop policy if exists "roleta insere jogadas" on public.jogadas;
create policy "roleta insere jogadas" on public.jogadas
  for insert to anon with check (true);

grant insert on public.leads, public.jogadas to anon;

-- 4. Vista para consultar no painel do Supabase (Table Editor), só para a equipa
create or replace view public.leads_com_premio
with (security_invoker = on) as
select l.criado_em, l.evento, l.nome, l.email, j.premio
from public.leads l
left join public.jogadas j on j.lead_id = l.id
order by l.criado_em desc;
