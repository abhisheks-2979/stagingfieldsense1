-- Drop existing insert policy
DROP POLICY IF EXISTS "Tenant admins can add users to their tenant" ON public.tenant_users;

-- Create new policy that allows system admins to add users to any tenant
CREATE POLICY "Tenant admins can add users to their tenant"
ON public.tenant_users
FOR INSERT
WITH CHECK (
  is_tenant_admin_or_owner(auth.uid(), tenant_id)
  OR EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);