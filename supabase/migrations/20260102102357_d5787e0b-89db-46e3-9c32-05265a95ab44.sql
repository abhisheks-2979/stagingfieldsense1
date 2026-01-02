-- Create helper function for tenant access (does not require dropping existing)
CREATE OR REPLACE FUNCTION public.user_belongs_to_tenant(_user_id uuid, _tenant_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.tenant_users 
    WHERE user_id = _user_id AND tenant_id = _tenant_id
  )
$$;

-- Update RLS policies for BEATS table (add tenant isolation)
DROP POLICY IF EXISTS "Users can view their own beats" ON public.beats;
DROP POLICY IF EXISTS "Users can view beats in their tenant" ON public.beats;
DROP POLICY IF EXISTS "Users can create beats in their tenant" ON public.beats;
DROP POLICY IF EXISTS "Users can update beats in their tenant" ON public.beats;
DROP POLICY IF EXISTS "Admins can manage all beats" ON public.beats;
DROP POLICY IF EXISTS "Admins can view all beats" ON public.beats;
DROP POLICY IF EXISTS "Users can create beats with themselves as creator" ON public.beats;
DROP POLICY IF EXISTS "Users can delete beats" ON public.beats;
DROP POLICY IF EXISTS "Users can update their own beats" ON public.beats;
DROP POLICY IF EXISTS "Users can delete beats in their tenant" ON public.beats;

CREATE POLICY "Users can view beats in their tenant" 
ON public.beats FOR SELECT 
USING (
  tenant_id = get_user_tenant_id(auth.uid()) 
  OR tenant_id IS NULL 
  OR created_by = auth.uid()
  OR has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Users can create beats in their tenant" 
ON public.beats FOR INSERT 
WITH CHECK (
  (tenant_id = get_user_tenant_id(auth.uid()) OR tenant_id IS NULL)
  AND (created_by = auth.uid() OR created_by IS NULL)
);

CREATE POLICY "Users can update beats in their tenant" 
ON public.beats FOR UPDATE 
USING (
  tenant_id = get_user_tenant_id(auth.uid()) 
  OR created_by = auth.uid()
  OR has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Users can delete beats in their tenant" 
ON public.beats FOR DELETE 
USING (
  created_by = auth.uid() 
  OR has_role(auth.uid(), 'admin'::app_role)
);

-- Update RLS policies for ATTENDANCE table (add tenant isolation)
DROP POLICY IF EXISTS "Users can view their own attendance" ON public.attendance;
DROP POLICY IF EXISTS "Users can view attendance in their tenant" ON public.attendance;
DROP POLICY IF EXISTS "Users can create attendance in their tenant" ON public.attendance;
DROP POLICY IF EXISTS "Users can update attendance in their tenant" ON public.attendance;
DROP POLICY IF EXISTS "Admins can view all attendance" ON public.attendance;
DROP POLICY IF EXISTS "Users can create their own attendance" ON public.attendance;
DROP POLICY IF EXISTS "Users can update their own attendance" ON public.attendance;

CREATE POLICY "Users can view attendance in their tenant" 
ON public.attendance FOR SELECT 
USING (
  user_id = auth.uid() 
  OR tenant_id = get_user_tenant_id(auth.uid()) 
  OR has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Users can create attendance in their tenant" 
ON public.attendance FOR INSERT 
WITH CHECK (
  user_id = auth.uid() 
  AND (tenant_id = get_user_tenant_id(auth.uid()) OR tenant_id IS NULL)
);

CREATE POLICY "Users can update attendance in their tenant" 
ON public.attendance FOR UPDATE 
USING (
  user_id = auth.uid() 
  OR tenant_id = get_user_tenant_id(auth.uid()) 
  OR has_role(auth.uid(), 'admin'::app_role)
);

-- Update RLS for ADDITIONAL_EXPENSES table (add tenant isolation)
DROP POLICY IF EXISTS "Users can view their own expenses" ON public.additional_expenses;
DROP POLICY IF EXISTS "Users can view expenses in their tenant" ON public.additional_expenses;
DROP POLICY IF EXISTS "Users can create expenses in their tenant" ON public.additional_expenses;
DROP POLICY IF EXISTS "Users can update expenses in their tenant" ON public.additional_expenses;
DROP POLICY IF EXISTS "Users can delete expenses in their tenant" ON public.additional_expenses;

CREATE POLICY "Users can view expenses in their tenant" 
ON public.additional_expenses FOR SELECT 
USING (
  user_id = auth.uid() 
  OR tenant_id = get_user_tenant_id(auth.uid()) 
  OR has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Users can create expenses in their tenant" 
ON public.additional_expenses FOR INSERT 
WITH CHECK (
  user_id = auth.uid() 
  AND (tenant_id = get_user_tenant_id(auth.uid()) OR tenant_id IS NULL)
);

CREATE POLICY "Users can update expenses in their tenant" 
ON public.additional_expenses FOR UPDATE 
USING (
  user_id = auth.uid() 
  OR has_role(auth.uid(), 'admin'::app_role)
);

CREATE POLICY "Users can delete expenses in their tenant" 
ON public.additional_expenses FOR DELETE 
USING (
  user_id = auth.uid() 
  OR has_role(auth.uid(), 'admin'::app_role)
);