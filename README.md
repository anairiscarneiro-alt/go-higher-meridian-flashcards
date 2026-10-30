# Go Higher English Flashcards — instalação

## 1. Criar Supabase
Crie um projeto em https://supabase.com. No **SQL Editor**, execute `schema.sql` inteiro, uma vez.

## 2. Criar a conta de administrador
No Supabase: Authentication > Users > Add user (crie usuário com email e senha).
Copie o UUID do usuário e execute no SQL Editor (substituindo o UUID):

```sql
insert into public.admins(user_id) values ('COLE_UUID_DO_USUARIO');
```

**Não habilite cadastro público no aplicativo.** O painel não oferece registro; apenas usuários autorizados em `admins` editam. A segurança é aplicada pelas políticas RLS no Supabase.

## 3. Configurar
No Supabase, Project Settings > API (ou Connect), copie **Project URL** e **publishable/anon key** para `config.js`.
NUNCA use a chave `service_role` ou `secret` no HTML.

## 4. Publicar
Coloque `index.html`, `config.js` e `seed.json` no repositório GitHub e ative GitHub Pages em Settings > Pages. O endereço público pode ser incorporado no Notion com `/embed`.
Para testar localmente, use `python -m http.server 8000` na pasta e abra `http://localhost:8000`.

## 5. Importar aulas
Abra o site publicado, clique **Entrar como admin** e faça login. Se o banco estiver vazio, clique **Importar seed.json**. A importação pode levar alguns minutos. Não execute novamente se já existirem aulas. O conteúdo vem da database expandida enviada, ainda sujeito à revisão pedagógica.

## 6. Editar
No painel: crie pastas (com subpastas), aulas e cartões; edite emojis e exemplos; envie imagens de até 5 MB. Cartões sem imagem mostram emoji. Os alunos veem somente aulas publicadas.

## Observações
- As imagens ficam públicas no bucket `flashcard-images`, adequado a conteúdo didático público; não envie imagens privadas.
- Excluir uma pasta apaga as subpastas, aulas e cartões associados. Faça backups pelo Supabase.
- A versão inicial não inclui drag-and-drop nem um fluxo de recuperação de importação parcial. A ordenação é pelo campo Ordem.
- A importação não é transacional: se falhar no meio, não reexecute cegamente, pois duplicará parte dos dados.
- A função de voz usa o mecanismo do navegador e pode variar entre dispositivos.
- `seed.json` é conteúdo público da aplicação. Não inclua dados pessoais nele.
