-- Allow authenticated users to create new tenants
CREATE POLICY "Authenticated users can create tenants"
ON public.tenants
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow tenant owners to update their own tenant
CREATE POLICY "Tenant owners can update their tenant"
ON public.tenants
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.tenant_users tu
    WHERE tu.tenant_id = id
    AND tu.user_id = auth.uid()
    AND tu.role = 'owner'
  )
);