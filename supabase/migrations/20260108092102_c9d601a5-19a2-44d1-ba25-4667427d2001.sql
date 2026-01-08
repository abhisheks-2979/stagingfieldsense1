-- Phase 1: Drop existing open policies on distributors
DROP POLICY IF EXISTS "Authenticated users can view all distributors" ON public.distributors;
DROP POLICY IF EXISTS "Authenticated users can insert distributors" ON public.distributors;
DROP POLICY IF EXISTS "Authenticated users can update distributors" ON public.distributors;
DROP POLICY IF EXISTS "Authenticated users can delete distributors" ON public.distributors;

-- Phase 2: Create tenant-scoped RLS policies

-- SELECT: Users can only view distributors in their tenant
CREATE POLICY "Users can view distributors in their tenant"
ON public.distributors FOR SELECT
TO authenticated
USING (
  tenant_id = get_user_tenant_id(auth.uid()) 
  OR is_tenant_owner(auth.uid())
);

-- INSERT: Users can only create distributors in their tenant
CREATE POLICY "Users can insert distributors in their tenant"
ON public.distributors FOR INSERT
TO authenticated
WITH CHECK (
  tenant_id = get_user_tenant_id(auth.uid())
  OR tenant_id IS NULL
);

-- UPDATE: Users can update distributors in their tenant
CREATE POLICY "Users can update distributors in their tenant"
ON public.distributors FOR UPDATE
TO authenticated
USING (
  tenant_id = get_user_tenant_id(auth.uid())
  OR is_tenant_owner(auth.uid())
);

-- DELETE: Users can delete distributors in their tenant
CREATE POLICY "Users can delete distributors in their tenant"
ON public.distributors FOR DELETE
TO authenticated
USING (
  tenant_id = get_user_tenant_id(auth.uid())
  OR is_tenant_owner(auth.uid())
);

-- Phase 3: Create trigger to auto-set tenant_id on insert
DROP TRIGGER IF EXISTS set_distributor_tenant_id ON public.distributors;
CREATE TRIGGER set_distributor_tenant_id
  BEFORE INSERT ON public.distributors
  FOR EACH ROW
  EXECUTE FUNCTION public.set_tenant_id();

-- Phase 4: Backfill existing distributors with NULL tenant_id
-- Assign to the first active tenant for safety
UPDATE public.distributors 
SET tenant_id = (
  SELECT id FROM tenants 
  WHERE is_active = true 
  ORDER BY created_at ASC 
  LIMIT 1
)
WHERE tenant_id IS NULL;