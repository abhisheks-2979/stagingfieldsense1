-- Fix infinite recursion in tenant_users RLS policy
-- Create a security definer function to check tenant admin status
CREATE OR REPLACE FUNCTION public.is_tenant_admin_or_owner(p_user_id uuid, p_tenant_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.tenant_users tu
    WHERE tu.user_id = p_user_id
      AND tu.tenant_id = p_tenant_id
      AND tu.role IN ('admin', 'owner')
  )
$$;

-- Drop the recursive policy
DROP POLICY IF EXISTS "Tenant admins can manage members" ON public.tenant_users;

-- Create a new policy using the security definer function
CREATE POLICY "Tenant admins can manage members"
ON public.tenant_users
FOR ALL
TO authenticated
USING (
  is_tenant_admin_or_owner(auth.uid(), tenant_id)
)
WITH CHECK (
  is_tenant_admin_or_owner(auth.uid(), tenant_id)
);