-- Create a function to check if user is a tenant owner (of any tenant)
CREATE OR REPLACE FUNCTION public.is_any_tenant_owner(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.tenant_users
    WHERE user_id = _user_id AND role = 'owner'
  )
$$;

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Tenant admins can manage members" ON public.tenant_users;

-- Create new policy: Tenant owners can manage members across all tenants
CREATE POLICY "Tenant owners can manage all members"
ON public.tenant_users FOR ALL
USING (public.is_any_tenant_owner(auth.uid()));

-- Create policy: Tenant admins can manage members within their own tenant only
CREATE POLICY "Tenant admins can manage their tenant members"
ON public.tenant_users FOR ALL
USING (
  tenant_id = public.get_user_tenant_id(auth.uid()) 
  AND public.is_tenant_admin(auth.uid())
);