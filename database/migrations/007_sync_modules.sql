-- Migration 007: Sync modules table with supported application modules

-- 1. Ensure all system modules are present
INSERT INTO public.modules (name, category, icon, route) VALUES
  ('Inventory', 'Operations', 'inventory', '/inventory'),
  ('Sales', 'Operations', 'sales', '/sales'),
  ('Accounting', 'Finance', 'accounting', '/accounting'),
  ('CRM', 'Sales', 'crm', '/crm'),
  ('HRM', 'Human Resources', 'hrm', '/hrm'),
  ('Manufacturing', 'Operations', 'manufacturing', '/manufacturing'),
  ('Invoice', 'Finance', 'receipt_long', '/invoices')
ON CONFLICT (name) DO UPDATE SET
  category = EXCLUDED.category,
  icon = EXCLUDED.icon,
  route = EXCLUDED.route;

-- 2. Clean up old naming if necessary (optional, but good for consistency)
-- If we had 'Customers', we might want to map existing subscriptions to 'CRM'
-- But let's keep it simple and just ensure 'CRM' and 'HRM' are there.

-- 3. Ensure the unique constraint on business_subscriptions is consistent
-- (Already exists in 001_initial_schema.sql as unique(business_id, module_name))
