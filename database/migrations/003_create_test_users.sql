-- Test Users Setup Script
-- This script creates test users for each role in the RBAC system
-- 
-- IMPORTANT: Run this script AFTER creating the auth users in Nhost Dashboard
-- or use the auth.users insert statements below (if you have admin privileges)

-- ============================================================================
-- OPTION 1: Manual Auth User Creation (Recommended for Production)
-- ============================================================================
-- Go to Nhost Dashboard → Users → Add User
-- Create users with these credentials, then run the UPDATE statements below

-- ============================================================================
-- OPTION 2: Direct Auth User Creation (Development/Testing Only)
-- ============================================================================
-- NOTE: This requires superuser access and may not work in all Nhost setups
-- The password 'Test123!' will be hashed automatically

-- First, we need to get the business_id for test users
-- Replace this with your actual business_id or create a test business
DO $$
DECLARE
  v_business_id uuid;
  v_admin_id uuid := 'a0000000-0000-0000-0000-000000000001'::uuid;
  v_manager_id uuid := 'a0000000-0000-0000-0000-000000000002'::uuid;
  v_accountant_id uuid := 'a0000000-0000-0000-0000-000000000003'::uuid;
  v_sales_id uuid := 'a0000000-0000-0000-0000-000000000004'::uuid;
  v_inventory_id uuid := 'a0000000-0000-0000-0000-000000000005'::uuid;
  v_viewer_id uuid := 'a0000000-0000-0000-0000-000000000006'::uuid;
BEGIN
  -- Create a test business if it doesn't exist
  INSERT INTO public.businesses (name, industry_type, onboarding_completed)
  VALUES ('Test Company', 'retail', true)
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_business_id;

  -- If business already exists, get its ID
  IF v_business_id IS NULL THEN
    SELECT id INTO v_business_id FROM public.businesses LIMIT 1;
  END IF;

  -- Create test users in the public.users table
  -- These will be linked to auth.users created manually or via API
  
  -- Admin User
  INSERT INTO public.users (id, email, business_id, role)
  VALUES (
    v_admin_id,
    'admin@test.com',
    v_business_id,
    'admin'
  ) ON CONFLICT (id) DO UPDATE SET
    role = 'admin',
    business_id = v_business_id;

  -- Manager User
  INSERT INTO public.users (id, email, business_id, role)
  VALUES (
    v_manager_id,
    'manager@test.com',
    v_business_id,
    'manager'
  ) ON CONFLICT (id) DO UPDATE SET
    role = 'manager',
    business_id = v_business_id;

  -- Accountant User
  INSERT INTO public.users (id, email, business_id, role)
  VALUES (
    v_accountant_id,
    'accountant@test.com',
    v_business_id,
    'accountant'
  ) ON CONFLICT (id) DO UPDATE SET
    role = 'accountant',
    business_id = v_business_id;

  -- Sales User
  INSERT INTO public.users (id, email, business_id, role)
  VALUES (
    v_sales_id,
    'sales@test.com',
    v_business_id,
    'sales'
  ) ON CONFLICT (id) DO UPDATE SET
    role = 'sales',
    business_id = v_business_id;

  -- Inventory Manager User
  INSERT INTO public.users (id, email, business_id, role)
  VALUES (
    v_inventory_id,
    'inventory@test.com',
    v_business_id,
    'inventory_manager'
  ) ON CONFLICT (id) DO UPDATE SET
    role = 'inventory_manager',
    business_id = v_business_id;

  -- Viewer User
  INSERT INTO public.users (id, email, business_id, role)
  VALUES (
    v_viewer_id,
    'viewer@test.com',
    v_business_id,
    'viewer'
  ) ON CONFLICT (id) DO UPDATE SET
    role = 'viewer',
    business_id = v_business_id;

  RAISE NOTICE 'Test users setup complete for business: %', v_business_id;
END $$;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- View all test users
SELECT 
  u.email,
  u.role,
  r.display_name as role_display_name,
  b.name as business_name
FROM public.users u
LEFT JOIN public.roles r ON r.name = u.role
LEFT JOIN public.businesses b ON b.id = u.business_id
WHERE u.email LIKE '%@test.com'
ORDER BY u.role;

-- Check permissions for each role
SELECT 
  r.name as role,
  r.display_name,
  COUNT(rp.permission_id) as permission_count
FROM public.roles r
LEFT JOIN public.role_permissions rp ON rp.role_id = r.id
WHERE r.is_system_role = true
GROUP BY r.name, r.display_name
ORDER BY r.name;
