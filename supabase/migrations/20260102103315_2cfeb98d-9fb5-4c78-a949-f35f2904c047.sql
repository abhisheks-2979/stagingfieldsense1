-- Create function to check if user is a tenant owner
CREATE OR REPLACE FUNCTION public.is_tenant_owner(_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.tenant_users
    WHERE user_id = _user_id
      AND role = 'owner'
  )
$$;

-- Update beats policies - only tenant owner can see all, admins see their tenant only
DROP POLICY IF EXISTS "Admins can view all beats" ON public.beats;
DROP POLICY IF EXISTS "Users can view beats in their tenant" ON public.beats;

CREATE POLICY "Tenant owners can view all beats"
ON public.beats
FOR SELECT
TO authenticated
USING (public.is_tenant_owner(auth.uid()));

CREATE POLICY "Users can view beats in their tenant"
ON public.beats
FOR SELECT
TO authenticated
USING (tenant_id = public.get_user_tenant_id(auth.uid()));

-- Update attendance policies
DROP POLICY IF EXISTS "Admins can view all attendance" ON public.attendance;
DROP POLICY IF EXISTS "Users can view attendance in their tenant" ON public.attendance;

CREATE POLICY "Tenant owners can view all attendance"
ON public.attendance
FOR SELECT
TO authenticated
USING (public.is_tenant_owner(auth.uid()));

CREATE POLICY "Users can view attendance in their tenant"
ON public.attendance
FOR SELECT
TO authenticated
USING (tenant_id = public.get_user_tenant_id(auth.uid()));

-- Update additional_expenses policies
DROP POLICY IF EXISTS "Admins can view all expenses" ON public.additional_expenses;
DROP POLICY IF EXISTS "Users can view expenses in their tenant" ON public.additional_expenses;

CREATE POLICY "Tenant owners can view all expenses"
ON public.additional_expenses
FOR SELECT
TO authenticated
USING (public.is_tenant_owner(auth.uid()));

CREATE POLICY "Users can view expenses in their tenant"
ON public.additional_expenses
FOR SELECT
TO authenticated
USING (tenant_id = public.get_user_tenant_id(auth.uid()));