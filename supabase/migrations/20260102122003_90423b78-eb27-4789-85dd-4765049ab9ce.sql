-- Drop the permissive policies
DROP POLICY IF EXISTS "Tenant owners can manage all members" ON public.tenant_users;
DROP POLICY IF EXISTS "Tenant admins can manage their tenant members" ON public.tenant_users;

-- Drop the helper function
DROP FUNCTION IF EXISTS public.is_any_tenant_owner(uuid);

-- Restore the original restrictive policy - admins can only manage their own tenant
CREATE POLICY "Tenant admins can manage members"
ON public.tenant_users
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.tenant_users tu
    WHERE tu.user_id = auth.uid()
    AND tu.tenant_id = tenant_users.tenant_id
    AND tu.role IN ('admin', 'owner')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.tenant_users tu
    WHERE tu.user_id = auth.uid()
    AND tu.tenant_id = tenant_users.tenant_id
    AND tu.role IN ('admin', 'owner')
  )
);