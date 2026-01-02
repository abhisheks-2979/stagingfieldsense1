-- Create tenants table
CREATE TABLE public.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS on tenants
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

-- Create tenant role enum
CREATE TYPE public.tenant_role AS ENUM ('owner', 'admin', 'member');

-- Create tenant_users junction table (one tenant per user for now)
CREATE TABLE public.tenant_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role tenant_role NOT NULL DEFAULT 'member',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id) -- One tenant per user
);

-- Enable RLS on tenant_users
ALTER TABLE public.tenant_users ENABLE ROW LEVEL SECURITY;

-- Create security definer function to get user's tenant_id
CREATE OR REPLACE FUNCTION public.get_user_tenant_id(_user_id UUID DEFAULT auth.uid())
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT tenant_id FROM public.tenant_users WHERE user_id = _user_id LIMIT 1
$$;

-- Create security definer function to check tenant role
CREATE OR REPLACE FUNCTION public.has_tenant_role(_user_id UUID, _role tenant_role)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.tenant_users
    WHERE user_id = _user_id AND role = _role
  )
$$;

-- Create function to check if user is tenant admin or owner
CREATE OR REPLACE FUNCTION public.is_tenant_admin(_user_id UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.tenant_users
    WHERE user_id = _user_id AND role IN ('admin', 'owner')
  )
$$;

-- RLS Policies for tenants table
CREATE POLICY "Users can view their own tenant"
ON public.tenants FOR SELECT
USING (id = public.get_user_tenant_id(auth.uid()));

CREATE POLICY "Tenant admins can update their tenant"
ON public.tenants FOR UPDATE
USING (id = public.get_user_tenant_id(auth.uid()) AND public.is_tenant_admin(auth.uid()));

-- RLS Policies for tenant_users table
CREATE POLICY "Users can view their tenant members"
ON public.tenant_users FOR SELECT
USING (tenant_id = public.get_user_tenant_id(auth.uid()));

CREATE POLICY "Tenant admins can manage members"
ON public.tenant_users FOR ALL
USING (tenant_id = public.get_user_tenant_id(auth.uid()) AND public.is_tenant_admin(auth.uid()));

-- Add tenant_id to main tables
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.retailers ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.visits ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.beats ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.territories ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.distributors ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.attendance ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);
ALTER TABLE public.additional_expenses ADD COLUMN IF NOT EXISTS tenant_id UUID REFERENCES public.tenants(id);

-- Create indexes for tenant_id on main tables
CREATE INDEX IF NOT EXISTS idx_profiles_tenant_id ON public.profiles(tenant_id);
CREATE INDEX IF NOT EXISTS idx_retailers_tenant_id ON public.retailers(tenant_id);
CREATE INDEX IF NOT EXISTS idx_orders_tenant_id ON public.orders(tenant_id);
CREATE INDEX IF NOT EXISTS idx_products_tenant_id ON public.products(tenant_id);
CREATE INDEX IF NOT EXISTS idx_visits_tenant_id ON public.visits(tenant_id);
CREATE INDEX IF NOT EXISTS idx_beats_tenant_id ON public.beats(tenant_id);
CREATE INDEX IF NOT EXISTS idx_territories_tenant_id ON public.territories(tenant_id);
CREATE INDEX IF NOT EXISTS idx_distributors_tenant_id ON public.distributors(tenant_id);
CREATE INDEX IF NOT EXISTS idx_attendance_tenant_id ON public.attendance(tenant_id);
CREATE INDEX IF NOT EXISTS idx_additional_expenses_tenant_id ON public.additional_expenses(tenant_id);

-- Drop existing RLS policies that don't include tenant filtering (we'll recreate them)
-- For profiles
DROP POLICY IF EXISTS "Users can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;

-- Recreate RLS policies with tenant filtering for profiles
CREATE POLICY "Users can view profiles in their tenant"
ON public.profiles FOR SELECT
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can update their own profile"
ON public.profiles FOR UPDATE
USING (id = auth.uid());

CREATE POLICY "Users can insert their own profile"
ON public.profiles FOR INSERT
WITH CHECK (id = auth.uid());

-- For retailers - add tenant-based policies
DROP POLICY IF EXISTS "Users can view all retailers" ON public.retailers;
DROP POLICY IF EXISTS "Users can insert retailers" ON public.retailers;
DROP POLICY IF EXISTS "Users can update retailers" ON public.retailers;

CREATE POLICY "Users can view retailers in their tenant"
ON public.retailers FOR SELECT
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can insert retailers in their tenant"
ON public.retailers FOR INSERT
WITH CHECK (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can update retailers in their tenant"
ON public.retailers FOR UPDATE
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

-- For orders - add tenant-based policies
DROP POLICY IF EXISTS "Users can view their own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can insert their own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can update their own orders" ON public.orders;

CREATE POLICY "Users can view orders in their tenant"
ON public.orders FOR SELECT
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can insert orders in their tenant"
ON public.orders FOR INSERT
WITH CHECK (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can update orders in their tenant"
ON public.orders FOR UPDATE
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

-- For products - add tenant-based policies
DROP POLICY IF EXISTS "Anyone can view products" ON public.products;
DROP POLICY IF EXISTS "Authenticated users can insert products" ON public.products;
DROP POLICY IF EXISTS "Authenticated users can update products" ON public.products;

CREATE POLICY "Users can view products in their tenant"
ON public.products FOR SELECT
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can insert products in their tenant"
ON public.products FOR INSERT
WITH CHECK (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Tenant admins can update products"
ON public.products FOR UPDATE
USING ((tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL) AND public.is_tenant_admin(auth.uid()));

-- For visits - add tenant-based policies  
DROP POLICY IF EXISTS "Users can view their own visits" ON public.visits;
DROP POLICY IF EXISTS "Users can insert their own visits" ON public.visits;
DROP POLICY IF EXISTS "Users can update their own visits" ON public.visits;

CREATE POLICY "Users can view visits in their tenant"
ON public.visits FOR SELECT
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can insert visits in their tenant"
ON public.visits FOR INSERT
WITH CHECK (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

CREATE POLICY "Users can update visits in their tenant"
ON public.visits FOR UPDATE
USING (tenant_id = public.get_user_tenant_id(auth.uid()) OR tenant_id IS NULL);

-- Trigger to auto-set tenant_id on insert for main tables
CREATE OR REPLACE FUNCTION public.set_tenant_id()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.tenant_id IS NULL THEN
    NEW.tenant_id := public.get_user_tenant_id(auth.uid());
  END IF;
  RETURN NEW;
END;
$$;

-- Apply trigger to main tables
DROP TRIGGER IF EXISTS set_tenant_id_profiles ON public.profiles;
CREATE TRIGGER set_tenant_id_profiles
  BEFORE INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_retailers ON public.retailers;
CREATE TRIGGER set_tenant_id_retailers
  BEFORE INSERT ON public.retailers
  FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_orders ON public.orders;
CREATE TRIGGER set_tenant_id_orders
  BEFORE INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_products ON public.products;
CREATE TRIGGER set_tenant_id_products
  BEFORE INSERT ON public.products
  FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_visits ON public.visits;
CREATE TRIGGER set_tenant_id_visits
  BEFORE INSERT ON public.visits
  FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_beats ON public.beats;
CREATE TRIGGER set_tenant_id_beats
  BEFORE INSERT ON public.beats
  FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();

DROP TRIGGER IF EXISTS set_tenant_id_attendance ON public.attendance;
CREATE TRIGGER set_tenant_id_attendance
  BEFORE INSERT ON public.attendance
  FOR EACH ROW EXECUTE FUNCTION public.set_tenant_id();