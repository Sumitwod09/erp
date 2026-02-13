-- Migration 006: Sales, Invoices, and Accounting Schema

-- 1. Create Sales table
create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  customer_name text,
  total_amount decimal(15, 2) not null default 0,
  payment_status text not null default 'pending' check (payment_status in ('pending', 'paid', 'partially_paid', 'cancelled')),
  payment_method text check (payment_method in ('cash', 'card', 'bank_transfer', 'other')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. Create Sale Items table
create table if not exists public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null references public.sales(id) on delete cascade,
  inventory_item_id uuid references public.inventory_items(id) on delete set null,
  quantity decimal(15, 2) not null,
  unit_price decimal(15, 2) not null,
  total_price decimal(15, 2) not null,
  created_at timestamptz default now()
);

-- 3. Create Invoices table
create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  sale_id uuid references public.sales(id) on delete set null,
  invoice_number text not null,
  due_date timestamptz,
  status text not null default 'draft' check (status in ('draft', 'sent', 'paid', 'overdue', 'cancelled')),
  notes text,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(business_id, invoice_number)
);

-- 4. Create Accounting Ledger table
create table if not exists public.accounting_ledger (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  date timestamptz not null default now(),
  description text not null,
  amount decimal(15, 2) not null,
  type text not null check (type in ('debit', 'credit')),
  category text not null, -- 'sales', 'expense', 'payroll', etc.
  reference_id uuid, -- Link to sale_id, invoice_id, etc.
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.invoices enable row level security;
alter table public.accounting_ledger enable row level security;

-- RLS Policies

-- Sales
create policy "Users can view their business sales"
  on public.sales for select
  using (business_id in (
    select business_id from public.users where id = (auth.uid())
  ));

create policy "Users can insert their business sales"
  on public.sales for insert
  with check (business_id in (
    select business_id from public.users where id = (auth.uid())
  ));

-- Sale Items (Linked through sales)
create policy "Users can view their business sale items"
  on public.sale_items for select
  using (sale_id in (
    select id from public.sales s
    join public.users u on s.business_id = u.business_id
    where u.id = (auth.uid())
  ));

create policy "Users can insert their business sale items"
  on public.sale_items for insert
  with check (sale_id in (
    select id from public.sales s
    join public.users u on s.business_id = u.business_id
    where u.id = (auth.uid())
  ));

-- Invoices
create policy "Users can view their business invoices"
  on public.invoices for select
  using (business_id in (
    select business_id from public.users where id = (auth.uid())
  ));

create policy "Users can manage their business invoices"
  on public.invoices for all
  using (business_id in (
    select business_id from public.users where id = (auth.uid())
  ));

-- Accounting Ledger
create policy "Users can view their business ledger"
  on public.accounting_ledger for select
  using (business_id in (
    select business_id from public.users where id = (auth.uid())
  ));

create policy "Users can manage their business ledger"
  on public.accounting_ledger for all
  using (business_id in (
    select business_id from public.users where id = (auth.uid())
  ));
