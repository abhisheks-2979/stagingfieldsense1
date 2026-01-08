-- Drop existing policy
DROP POLICY IF EXISTS "Users can view their tenant members" ON public.tenant_users;

-- Create new policy that allows system admins to see all tenant users
CREATE POLICY "Users can view their tenant members"
ON public.tenant_users
FOR SELECT
USING (
  tenant_id = get_user_tenant_id(auth.uid()) 
  OR is_tenant_admin_or_owner(auth.uid(), tenant_id)
  OR EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);