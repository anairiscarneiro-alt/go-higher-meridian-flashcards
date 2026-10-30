-- Execute no SQL Editor do Supabase antes de usar o aplicativo.
create extension if not exists pgcrypto;
create table if not exists public.admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.folders (
 id uuid primary key default gen_random_uuid(),
 parent_id uuid references public.folders(id) on delete cascade,
 name text not null, sort_order integer not null default 0,
 created_at timestamptz not null default now()
);
create table if not exists public.lessons (
 id uuid primary key default gen_random_uuid(),
 folder_id uuid not null references public.folders(id) on delete cascade,
 title text not null, objective text default '', grammar text default '', themes text default '',
 sort_order integer not null default 0, published boolean not null default true
);
create table if not exists public.cards (
 id uuid primary key default gen_random_uuid(),
 lesson_id uuid not null references public.lessons(id) on delete cascade,
 term text not null, emoji text default '📚', example text default '',
 image_path text, category text not null default 'essential'
 check (category in ('essential','extended','review')),
 sort_order integer not null default 0
);
create index if not exists lessons_folder_idx on public.lessons(folder_id,sort_order);
create index if not exists cards_lesson_idx on public.cards(lesson_id,sort_order);
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.admins where user_id = (select auth.uid()));
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;
alter table public.admins enable row level security;
alter table public.folders enable row level security;
alter table public.lessons enable row level security;
alter table public.cards enable row level security;
create policy "admin can see own status" on public.admins for select to authenticated using (user_id=(select auth.uid()));
create policy "folders public read" on public.folders for select to anon,authenticated using (true);
create policy "folders admin insert" on public.folders for insert to authenticated with check (public.is_admin());
create policy "folders admin update" on public.folders for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "folders admin delete" on public.folders for delete to authenticated using (public.is_admin());
create policy "lessons public read" on public.lessons for select to anon,authenticated using (published or public.is_admin());
create policy "lessons admin insert" on public.lessons for insert to authenticated with check (public.is_admin());
create policy "lessons admin update" on public.lessons for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "lessons admin delete" on public.lessons for delete to authenticated using (public.is_admin());
create policy "cards public read" on public.cards for select to anon,authenticated using (
 exists(select 1 from public.lessons l where l.id=lesson_id and (l.published or public.is_admin()))
);
create policy "cards admin insert" on public.cards for insert to authenticated with check (public.is_admin());
create policy "cards admin update" on public.cards for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "cards admin delete" on public.cards for delete to authenticated using (public.is_admin());
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
 values ('flashcard-images','flashcard-images',true,5242880,array['image/jpeg','image/png','image/webp','image/gif'])
 on conflict (id) do nothing;
create policy "public image read" on storage.objects for select to anon,authenticated using (bucket_id='flashcard-images');
create policy "admin image upload" on storage.objects for insert to authenticated with check (bucket_id='flashcard-images' and public.is_admin());
create policy "admin image update" on storage.objects for update to authenticated using (bucket_id='flashcard-images' and public.is_admin()) with check (bucket_id='flashcard-images' and public.is_admin());
create policy "admin image delete" on storage.objects for delete to authenticated using (bucket_id='flashcard-images' and public.is_admin());
