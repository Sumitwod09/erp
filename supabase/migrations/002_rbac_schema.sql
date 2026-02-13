-- RBAC (Role-Based Access Control) Schema Migration
-- Creates roles, permissions, and related tables with RLS policies

-- ============================================================================
-- TABLES
-- ============================================================================

-- Roles table (system and custom roles)
create table if not exists public.roles (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  display_name text not null,
  description text,
  is_system_role boolean default false,
  business_id uuid references public.businesses(id) on delete cascade,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  -- System roles are shared across all businesses, custom roles are business-specific
  unique(name, business_id),
  -- Ensure system roles don't have a business_id
  check ((is_system_role = true and business_id is null) or (is_system_role = false and business_id is not null))
);

-- Permissions table (granular access control)
create table if not exists public.permissions (
  id uuid primary key default gen_random_uuid(),
  name text unique not null, -- e.g., 'accounting.read', 'sales.write'
  resource text not null,    -- e.g., 'accounting', 'inventory', 'sales'
  action text not null,      -- e.g., 'read', 'write', 'delete', 'manage'
  description text,
  created_at timestamptz default now(),
  check (action in ('read', 'write', 'delete', 'manage'))
);

-- Role-Permission junction table
create table if not exists public.role_permissions (
  id uuid primary key default gen_random_uuid(),
  role_id uuid references public.roles(id) on delete cascade,
  permission_id uuid references public.permissions(id) on delete cascade,
  created_at timestamptz default now(),
  unique(role_id, permission_id)
);

-- User custom permissions (overrides)
create table if not exists public.user_custom_permissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  permission_id uuid references public.permissions(id) on delete cascade,
  granted boolean not null, -- true = grant, false = revoke
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id, permission_id)
);

-- ============================================================================
-- ROW LEVEL SECURITY
-- ============================================================================

alter table public.roles enable row level security;
alter table public.permissions enable row level security;
alter table public.role_permissions enable row level security;
alter table public.user_custom_permissions enable row level security;

-- RLS Policies for roles
create policy "Users can view system roles and their business roles"
  on public.roles for select
  using (
    is_system_role = true 
    or business_id in (select business_id from public.users where id = auth.uid())
  );

create policy "Admins can insert custom roles for their business"
  on public.roles for insert
  with check (
    business_id in (
      select business_id from public.users 
      where id = auth.uid() and role = 'admin'
    )
  );

create policy "Admins can update roles in their business"
  on public.roles for update
  using (
    business_id in (
      select business_id from public.users 
      where id = auth.uid() and role = 'admin'
    )
  );

create policy "Admins can delete custom roles in their business"
  on public.roles for delete
  using (
    is_system_role = false
    and business_id in (
      select business_id from public.users 
      where id = auth.uid() and role = 'admin'
    )
  );

-- RLS Policies for permissions (read-only for all authenticated users)
create policy "Authenticated users can view all permissions"
  on public.permissions for select
  using (auth.uid() is not null);

-- RLS Policies for role_permissions
create policy "Users can view role permissions"
  on public.role_permissions for select
  using (
    role_id in (
      select id from public.roles 
      where is_system_role = true 
      or business_id in (select business_id from public.users where id = auth.uid())
    )
  );

create policy "Admins can manage role permissions"
  on public.role_permissions for all
  using (
    role_id in (
      select id from public.roles 
      where business_id in (
        select business_id from public.users 
        where id = auth.uid() and role = 'admin'
      )
    )
  );

-- RLS Policies for user_custom_permissions
create policy "Users can view custom permissions in their business"
  on public.user_custom_permissions for select
  using (
    user_id in (
      select id from public.users 
      where business_id in (select business_id from public.users where id = auth.uid())
    )
  );

create policy "Admins can manage user custom permissions"
  on public.user_custom_permissions for all
  using (
    user_id in (
      select id from public.users 
      where business_id in (
        select business_id from public.users 
        where id = auth.uid() and role = 'admin'
      )
    )
  );

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to check if a user has a specific permission
create or replace function public.has_permission(
  p_user_id uuid,
  p_permission_name text
)
returns boolean as $$
declare
  v_has_permission boolean;
  v_custom_override boolean;
begin
  -- Check for custom permission override first
  select granted into v_custom_override
  from public.user_custom_permissions ucp
  join public.permissions p on p.id = ucp.permission_id
  where ucp.user_id = p_user_id and p.name = p_permission_name;
  
  -- If custom override exists, return it
  if found then
    return v_custom_override;
  end if;
  
  -- Otherwise, check role permissions
  select exists (
    select 1
    from public.users u
    join public.roles r on r.name = u.role
    join public.role_permissions rp on rp.role_id = r.id
    join public.permissions p on p.id = rp.permission_id
    where u.id = p_user_id and p.name = p_permission_name
  ) into v_has_permission;
  
  return coalesce(v_has_permission, false);
end;
$$ language plpgsql security definer;

-- Function to get all permissions for a user
create or replace function public.get_user_permissions(p_user_id uuid)
returns table(permission_name text, resource text, action text) as $$
begin
  return query
  with role_perms as (
    select p.name, p.resource, p.action
    from public.users u
    join public.roles r on r.name = u.role
    join public.role_permissions rp on rp.role_id = r.id
    join public.permissions p on p.id = rp.permission_id
    where u.id = p_user_id
  ),
  custom_perms as (
    select p.name, p.resource, p.action, ucp.granted
    from public.user_custom_permissions ucp
    join public.permissions p on p.id = ucp.permission_id
    where ucp.user_id = p_user_id
  )
  -- Combine role permissions with custom overrides
  select rp.name, rp.resource, rp.action
  from role_perms rp
  where not exists (
    select 1 from custom_perms cp 
    where cp.name = rp.name and cp.granted = false
  )
  union
  select cp.name, cp.resource, cp.action
  from custom_perms cp
  where cp.granted = true;
end;
$$ language plpgsql security definer;

-- Function to get user's role information
create or replace function public.get_user_role(p_user_id uuid)
returns table(role_name text, display_name text, description text) as $$
begin
  return query
  select r.name, r.display_name, r.description
  from public.users u
  join public.roles r on r.name = u.role
  where u.id = p_user_id;
end;
$$ language plpgsql security definer;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

create trigger roles_updated_at before update on public.roles
  for each row execute function public.handle_updated_at();

create trigger user_custom_permissions_updated_at before update on public.user_custom_permissions
  for each row execute function public.handle_updated_at();

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert system roles
insert into public.roles (name, display_name, description, is_system_role) values
  ('admin', 'Administrator', 'Full access to all features and settings', true),
  ('manager', 'Manager', 'Access to most features with limited settings access', true),
  ('accountant', 'Accountant', 'Full access to accounting, read-only access to other modules', true),
  ('sales', 'Sales Representative', 'Full access to sales, read access to customers and inventory', true),
  ('inventory_manager', 'Inventory Manager', 'Full access to inventory, read access to sales', true),
  ('viewer', 'Viewer', 'Read-only access to most modules', true)
on conflict (name, business_id) do nothing;

-- Insert permissions
insert into public.permissions (name, resource, action, description) values
  -- Accounting permissions
  ('accounting.read', 'accounting', 'read', 'View accounting records'),
  ('accounting.write', 'accounting', 'write', 'Create and edit accounting records'),
  ('accounting.delete', 'accounting', 'delete', 'Delete accounting records'),
  ('accounting.manage', 'accounting', 'manage', 'Manage accounting settings and configurations'),
  
  -- Inventory permissions
  ('inventory.read', 'inventory', 'read', 'View inventory records'),
  ('inventory.write', 'inventory', 'write', 'Create and edit inventory records'),
  ('inventory.delete', 'inventory', 'delete', 'Delete inventory records'),
  ('inventory.manage', 'inventory', 'manage', 'Manage inventory settings'),
  
  -- Sales permissions
  ('sales.read', 'sales', 'read', 'View sales records'),
  ('sales.write', 'sales', 'write', 'Create and edit sales records'),
  ('sales.delete', 'sales', 'delete', 'Delete sales records'),
  ('sales.manage', 'sales', 'manage', 'Manage sales settings'),
  
  -- Payroll permissions
  ('payroll.read', 'payroll', 'read', 'View payroll records'),
  ('payroll.write', 'payroll', 'write', 'Create and edit payroll records'),
  ('payroll.delete', 'payroll', 'delete', 'Delete payroll records'),
  ('payroll.manage', 'payroll', 'manage', 'Manage payroll settings'),
  
  -- Customers permissions
  ('customers.read', 'customers', 'read', 'View customer records'),
  ('customers.write', 'customers', 'write', 'Create and edit customer records'),
  ('customers.delete', 'customers', 'delete', 'Delete customer records'),
  ('customers.manage', 'customers', 'manage', 'Manage customer settings'),
  
  -- Reports permissions
  ('reports.read', 'reports', 'read', 'View reports'),
  ('reports.write', 'reports', 'write', 'Create and edit custom reports'),
  ('reports.delete', 'reports', 'delete', 'Delete custom reports'),
  ('reports.manage', 'reports', 'manage', 'Manage report settings'),
  
  -- Settings permissions
  ('settings.read', 'settings', 'read', 'View application settings'),
  ('settings.manage', 'settings', 'manage', 'Manage application settings'),
  
  -- User management permissions
  ('users.read', 'users', 'read', 'View user list'),
  ('users.write', 'users', 'write', 'Create and edit users'),
  ('users.delete', 'users', 'delete', 'Delete users'),
  ('users.manage', 'users', 'manage', 'Manage user roles and permissions')
on conflict (name) do nothing;

-- Assign permissions to roles
do $$
declare
  v_admin_id uuid;
  v_manager_id uuid;
  v_accountant_id uuid;
  v_sales_id uuid;
  v_inventory_id uuid;
  v_viewer_id uuid;
begin
  -- Get role IDs
  select id into v_admin_id from public.roles where name = 'admin';
  select id into v_manager_id from public.roles where name = 'manager';
  select id into v_accountant_id from public.roles where name = 'accountant';
  select id into v_sales_id from public.roles where name = 'sales';
  select id into v_inventory_id from public.roles where name = 'inventory_manager';
  select id into v_viewer_id from public.roles where name = 'viewer';
  
  -- Admin: Full access to everything
  insert into public.role_permissions (role_id, permission_id)
  select v_admin_id, id from public.permissions
  on conflict (role_id, permission_id) do nothing;
  
  -- Manager: All read/write, limited manage permissions
  insert into public.role_permissions (role_id, permission_id)
  select v_manager_id, id from public.permissions 
  where action in ('read', 'write', 'delete') 
    or (action = 'manage' and resource in ('inventory', 'sales', 'customers'))
  on conflict (role_id, permission_id) do nothing;
  
  -- Accountant: Full accounting, read-only others
  insert into public.role_permissions (role_id, permission_id)
  select v_accountant_id, id from public.permissions 
  where resource = 'accounting'
    or (action = 'read' and resource in ('inventory', 'sales', 'customers', 'reports', 'payroll'))
  on conflict (role_id, permission_id) do nothing;
  
  -- Sales: Full sales and customers, read inventory
  insert into public.role_permissions (role_id, permission_id)
  select v_sales_id, id from public.permissions 
  where resource in ('sales', 'customers')
    or (action = 'read' and resource in ('inventory', 'reports'))
  on conflict (role_id, permission_id) do nothing;
  
  -- Inventory Manager: Full inventory, read sales
  insert into public.role_permissions (role_id, permission_id)
  select v_inventory_id, id from public.permissions 
  where resource = 'inventory'
    or (action = 'read' and resource in ('sales', 'customers', 'reports'))
  on conflict (role_id, permission_id) do nothing;
  
  -- Viewer: Read-only access to most modules
  insert into public.role_permissions (role_id, permission_id)
  select v_viewer_id, id from public.permissions 
  where action = 'read' and resource in ('inventory', 'sales', 'customers', 'reports', 'accounting')
  on conflict (role_id, permission_id) do nothing;
end $$;

-- ============================================================================
-- DATA MIGRATION
-- ============================================================================

-- Update existing users with default role 'user' to 'viewer'
update public.users 
set role = 'viewer' 
where role = 'user';

-- Existing admin users retain their admin role (no change needed)
