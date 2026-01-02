-- Add current user to the default tenant as owner
INSERT INTO public.tenant_users (tenant_id, user_id, role)
VALUES (
  (SELECT id FROM public.tenants WHERE slug = 'bharath-bev' LIMIT 1),
  '6be7e2ff-0447-44a0-a3b5-64993b9db54d',
  'owner'
)
ON CONFLICT (user_id) DO UPDATE SET role = 'owner';

-- Update the user's profile to have the tenant_id
UPDATE public.profiles 
SET tenant_id = (SELECT id FROM public.tenants WHERE slug = 'bharath-bev' LIMIT 1)
WHERE id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d';

-- Allow admins to view all tenants for management purposes
DROP POLICY IF EXISTS "Admins can view all tenants" ON public.tenants;
CREATE POLICY "Admins can view all tenants" 
ON public.tenants 
FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  )
);