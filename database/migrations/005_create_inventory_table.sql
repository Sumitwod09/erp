-- Create inventory_items table
create table if not exists public.inventory_items (
  id uuid primary key default gen_random_uuid(),
  business_id uuid references public.businesses(id) on delete cascade not null,
  name text not null,
  sku text,
  description text,
  quantity numeric default 0,
  unit_price numeric default 0,
  reorder_level numeric default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.inventory_items enable row level security;

-- RLS Policies
create policy "Users can view inventory items"
  on public.inventory_items for select
  using (business_id in (
    select business_id from public.users where id = auth.uid()
  ));

create policy "Users can insert inventory items"
  on public.inventory_items for insert
  with check (business_id in (
    select business_id from public.users where id = auth.uid()
  ));

create policy "Users can update inventory items"
  on public.inventory_items for update
  using (business_id in (
    select business_id from public.users where id = auth.uid()
  ));

create policy "Users can delete inventory items"
  on public.inventory_items for delete
  using (business_id in (
    select business_id from public.users where id = auth.uid()
  ));

-- Add updated_at trigger
create trigger inventory_items_updated_at before update on public.inventory_items
  for each row execute function public.handle_updated_at();
