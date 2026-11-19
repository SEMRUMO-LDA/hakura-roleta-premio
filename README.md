# Roleta de Prémios Hakura

Roleta para tablet (landscape). Versão atual: **evento**, com recolha de leads (nome + email) no Supabase antes de jogar.

## Configurar
1. No Supabase, abrir o SQL Editor e correr `supabase.sql` (uma vez).
2. Em `config.js`, preencher `supabaseUrl`, `supabaseKey` (chave publishable/anon) e `evento`.
3. `git push` → o Vercel publica.

## Área da equipa (ícone ⚙, canto inferior direito)
- **Novo participante**: volta ao formulário.
- Leads no tablet / enviados / pendentes, **Enviar agora**, **Exportar leads (CSV)**.
- **Limite de massagens** (por defeito 1) e probabilidades de cada prémio.

Se não houver internet, os leads ficam guardados no tablet e são enviados quando a ligação voltar.

A versão do aniversário (receção) está guardada na tag `aniversario-2-anos`.
