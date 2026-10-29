# Central de Bomberos – App Web Gratuita

## Qué es
Una aplicación web que permite:
- **Panel central** que muestra en tiempo real el estado (En Servicio / Fuera de Servicio) de todos los bomberos de 5 compañías.
- **Portal de cada compañía** donde sus bomberos pueden registrarse (nombre, apellido, RUT, clave, cargo) y cambiar su estado.
- **Autenticación** por email/contraseña.
- **Actualización instantánea** mediante Supabase Realtime.
- **Sin costo** mientras el uso esté dentro de los límites del plan gratuito de Supabase y GitHub Pages.

## Tecnologías
- **Frontend**: HTML + Bootstrap 5 + **supabase‑js** (CDN)
- **Backend (BaaS)**: **Supabase** (PostgreSQL + Realtime + Auth) – plan *Free (Spark)*
- **Hosting estático**: **GitHub Pages** (u otro host estático gratuito como Vercel/Cloudflare Pages)

## Estructura del proyecto
```
firefighter-central/
├─ public/                 # archivos servidos por GitHub Pages
│   ├─ index.html          # login
│   ├─ central.html        # vista central
│   ├─ company.html        # registro y estado por compañía
│   ├─ supabase.js         # inicializa el cliente Supabase (rellenar valores)
│   ├─ app.js              # utilidades comunes (por ahora vacío)
│   └─ style.css (opcional)
├─ README.md               # este archivo
└─ .gitignore              # ignora node_modules y .env (si usas)
```

## Paso a paso para ponerla en línea (todo gratuito)
1. **Crear proyecto Supabase**
   - Visita https://app.supabase.com y pulsa *New project*.
   - Escoge el plan **Free (Spark)** (no requiere tarjeta).
   - Copia **Project URL** y **anon public key** (Settings → API).
2. **Configurar la base de datos**
   - Ejecuta las siguientes sentencias SQL en el editor de Supabase:
```sql
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

-- Habilitar Row Level Security
alter table profiles enable row level security;
alter table firefighters enable row level security;

-- Políticas de seguridad
create policy "profile owner" on profiles for all using (auth.uid() = id) with check (auth.uid() = id);

create policy "central read all" on firefighters for select using ((select role from profiles where id = auth.uid()) = 'central');
create policy "company read own" on firefighters for select using ((select role from profiles where id = auth.uid()) = company);
create policy "central write any" on firefighters for insert, update, delete using ((select role from profiles where id = auth.uid()) = 'central');
create policy "company write own" on firefighters for insert, update, delete using ((select role from profiles where id = auth.uid()) = company);
```
3. **Crear usuarios de prueba**
   - En *Auth → Settings* habilita **Email login**.
   - Registra una cuenta para la *central* (ej. `central@bomberos.cl`).
   - Registra cinco cuentas para cada compañía (`primera@bomberos.cl`, …).  
   - En la tabla `profiles` inserta manualmente el rol correspondiente:
```sql
insert into profiles (id, email, role) values ('<uid‑central>', 'central@bomberos.cl', 'central');
insert into profiles (id, email, role) values ('<uid‑primera>', 'primera@bomberos.cl', 'Primera');
-- repetir para Segunda, Tercera, Cuarta, Quinta
```
   (`<uid‑…>` lo obtienes en la tabla `auth.users` o al crear la cuenta).
4. **Actualizar `public/supabase.js`**
   - Reemplaza `YOUR-PROJECT` y `YOUR-ANON-KEY` con los valores del paso 1.
5. **Crear repositorio GitHub**
   ```powershell
   cd C:\Users\PC\Desktop\poyectito\firefighter-central
   git init
   git add .
   git commit -m "Initial commit – central de bomberos"
   git remote add origin https://github.com/<TU_USUARIO>/<REPO>.git
   git push -u origin master
   ```
6. **Activar GitHub Pages**
   - En la página del repositorio → *Settings → Pages*.
   - Fuente: *main* (o *master*) → carpeta */ (raíz) o */public* según prefieras.  
   - Guarda; obtendrás una URL tipo `https://<usuario>.github.io/<repo>/`.
7. **Usar la app**
   - Abre la URL, ingresa con la cuenta `central@bomberos.cl` → serás redirigido a `central.html`.
   - Con una cuenta de compañía, serás enviado a `company.html` para registrar bomberos y cambiar su estado.
   - Gracias a Supabase Realtime, cualquier cambio se refleja en el panel central al instante.

## Mantenimiento y límites gratuitos
- **Supabase Free**: 500 MB de almacenamiento, 2 GB de salida mensual, 50 k auth y 2 M mensajes realtime – suficiente para ≤ 500 registros y cambios esporádicos.
- **GitHub Pages**: 100 GB de transferencia/mes – más que suficiente.
- Si el proyecto crece (más usuarios o más compañías) puedes migrar a un plan pago en Supabase o cambiar a otro BaaS gratuito (p.ej., Firebase Spark) con cambios mínimos.

---
### ¿Listo para probar?
1️⃣ Abre `public/supabase.js` y pon tus credenciales.
2️⃣ Sube todo a GitHub y habilita Pages.
3️⃣ Accede a la URL y prueba con las cuentas creadas.

Si necesitas ayuda para crear los usuarios en Supabase o configurar las políticas, avísame y lo hacemos paso a paso.
