-- Drop existing read policy that restricts visibility
DROP POLICY IF EXISTS "Users can view their tenant members" ON public.tenant_users;

-- Create new policy that allows users to see members of tenants where they are admin/owner
CREATE POLICY "Users can view their tenant members"
ON public.tenant_users
FOR SELECT
USING (
  tenant_id = get_user_tenant_id(auth.uid()) 
  OR is_tenant_admin_or_owner(auth.uid(), tenant_id)
);