-- Fix: Admins should only manage distributors in their own tenant, not all distributors
-- Drop the overly permissive admin policy
DROP POLICY IF EXISTS "Admins can manage distributors" ON public.distributors;

-- Create a tenant-scoped admin policy
CREATE POLICY "Admins can manage distributors in their tenant"
ON public.distributors
FOR ALL
TO authenticated
USING (
  has_role(auth.uid(), 'admin'::app_role) 
  AND tenant_id = get_user_tenant_id(auth.uid())
)
WITH CHECK (
  has_role(auth.uid(), 'admin'::app_role) 
  AND tenant_id = get_user_tenant_id(auth.uid())
);