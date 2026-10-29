-- ==========================================================
-- 1️⃣ Tablas
-- ==========================================================
-- Tabla de perfiles (rol y email)
create table profiles (
  id uuid primary key default uuid_generate_v4(),
  email text unique not null,
  role text not null,            -- 'central' o nombre de compañía
  created_at timestamp default now()
);

-- Tabla de bomberos
create table firefighters (
  id uuid primary key default uuid_generate_v4(),
  nombre text,
  apellido text,
  rut text,
  clave_bombero text,
  cargo text,
  company text,                -- 'Primera' … 'Quinta'
  en_servicio boolean,
  created_at timestamp default now()
);

-- ==========================================================
-- 2️⃣ Seguridad (Row Level Security)
-- ==========================================================
alter table profiles enable row level security;
alter table firefighters enable row level security;

-- Políticas de seguridad
-- Solo el propietario del perfil puede leer/escribir su registro
create policy "profile owner"
  on profiles for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Central puede leer todos los bomberos
create policy "central read all"
  on firefighters for select
  using ((select role from profiles where id = auth.uid()) = 'central');

-- Cada compañía solo puede leer los bomberos de su propia compañía
create policy "company read own"
  on firefighters for select
  using ((select role from profiles where id = auth.uid()) = company);

-- Central puede crear/actualizar/eliminar cualquier registro
create policy "central write any"
  on firefighters for insert, update, delete
  using ((select role from profiles where id = auth.uid()) = 'central');

-- Cada compañía puede crear/actualizar/eliminar sólo sus propios registros
create policy "company write own"
  on firefighters for insert, update, delete
  using ((select role from profiles where id = auth.uid()) = company);
