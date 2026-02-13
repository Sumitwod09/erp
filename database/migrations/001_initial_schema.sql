-- Create businesses table
create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  industry_type text,
  onboarding_completed boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Create users table (extends Nhost Auth users)
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  business_id uuid references public.businesses(id) on delete cascade,
  role text default 'user',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Create modules table (catalog of available modules)
create table if not exists public.modules (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  category text not null,
  icon text not null,
  route text not null,
  requires_modules text[] default '{}',
  created_at timestamptz default now()
);

-- Create business_subscriptions table (module activation state)
create table if not exists public.business_subscriptions (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses(id) on delete cascade,
  module_name text not null,
  is_active boolean default true,
  activated_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(business_id, module_name)
);

-- Create industry_presets table (onboarding configurations)
create table if not exists public.industry_presets (
  id uuid primary key default gen_random_uuid(),
  industry_name text unique not null,
  display_name text not null,
  description text,
  default_modules text[] not null,
  config_json jsonb default '{}'::jsonb,
  created_at timestamptz default now()
);

-- Enable Row Level Security
alter table public.businesses enable row level security;
alter table public.users enable row level security;
alter table public.modules enable row level security;
alter table public.business_subscriptions enable row level security;
alter table public.industry_presets enable row level security;

-- RLS Policies for businesses
create policy "Users can view their own business"
  on public.businesses for select
  using (id in (
    select business_id from public.users where id = auth.uid()
  ));

create policy "Users can update their own business"
  on public.businesses for update
  using (id in (
    select business_id from public.users where id = auth.uid()
  ));

-- RLS Policies for users
create policy "Users can view users in their business"
  on public.users for select
  using (business_id in (
    select business_id from public.users where id = auth.uid()
  ));

-- RLS Policies for modules (public read)
create policy "Anyone can view modules"
  on public.modules for select
  using (true);

-- RLS Policies for business_subscriptions
create policy "Users can view their business subscriptions"
  on public.business_subscriptions for select
  using (business_id in (
    select business_id from public.users where id = auth.uid()
  ));

create policy "Users can manage their business subscriptions"
  on public.business_subscriptions for all
  using (business_id in (
    select business_id from public.users where id = auth.uid()
  ));

-- RLS Policies for industry_presets (public read)
create policy "Anyone can view industry presets"
  on public.industry_presets for select
  using (true);

-- Insert default modules
insert into public.modules (name, category, icon, route) values
  ('Inventory', 'Operations', 'inventory', '/inventory'),
  ('Accounting', 'Finance', 'accounting', '/accounting'),
  ('Sales', 'Operations', 'sales', '/sales'),
  ('Payroll', 'Finance', 'payroll', '/payroll'),
  ('Customers', 'CRM', 'customers', '/customers'),
  ('Reports', 'Analytics', 'reports', '/reports')
on conflict (name) do nothing;

-- Insert industry presets
insert into public.industry_presets (industry_name, display_name, description, default_modules) values
  ('retail', 'Retail', 'Point of sale and retail operations', ARRAY['Inventory', 'Sales', 'Accounting', 'Customers']),
  ('pharma', 'Pharmaceutical', 'Pharmacy with batch tracking and expiry management', ARRAY['Inventory', 'Sales', 'Accounting']),
  ('warehouse', 'Warehouse & Logistics', 'Warehouse management and dispatch', ARRAY['Inventory']),
  ('manufacturing', 'Manufacturing', 'Production and materials management', ARRAY['Inventory', 'Accounting'])
on conflict (industry_name) do nothing;

-- Create updated_at trigger function
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Add updated_at triggers
create trigger businesses_updated_at before update on public.businesses
  for each row execute function public.handle_updated_at();

create trigger users_updated_at before update on public.users
  for each row execute function public.handle_updated_at();

create trigger business_subscriptions_updated_at before update on public.business_subscriptions
  for each row execute function public.handle_updated_at();
