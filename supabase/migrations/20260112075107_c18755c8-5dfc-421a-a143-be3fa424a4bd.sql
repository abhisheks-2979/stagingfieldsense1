
-- First create schemes table (required for scheme_applicability and scheme_policy_config)
CREATE TABLE public.schemes (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  scheme_name TEXT NOT NULL,
  scheme_code TEXT UNIQUE,
  scheme_type TEXT NOT NULL, -- 'discount', 'cashback', 'gift', 'quantity', 'loyalty'
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  min_order_value NUMERIC DEFAULT 0,
  max_discount_value NUMERIC,
  discount_percent NUMERIC,
  flat_discount NUMERIC,
  terms_conditions TEXT,
  budget_amount NUMERIC DEFAULT 0,
  utilized_amount NUMERIC DEFAULT 0,
  created_by UUID REFERENCES auth.users(id),
  tenant_id UUID REFERENCES public.tenants(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.schemes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view schemes" ON public.schemes
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage schemes" ON public.schemes
  FOR ALL USING (public.has_role(auth.uid(), 'admin'::public.app_role));

CREATE INDEX idx_schemes_active ON public.schemes(is_active);
CREATE INDEX idx_schemes_dates ON public.schemes(start_date, end_date);

-- Now create Scheme Applicability
CREATE TABLE public.scheme_applicability (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  scheme_id UUID NOT NULL REFERENCES public.schemes(id) ON DELETE CASCADE,
  applicability_type TEXT NOT NULL,
  entity_id UUID,
  entity_name TEXT,
  include_children BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.scheme_applicability ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view scheme applicability" ON public.scheme_applicability
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage scheme applicability" ON public.scheme_applicability
  FOR ALL USING (public.has_role(auth.uid(), 'admin'::public.app_role));

CREATE INDEX idx_scheme_applicability_scheme ON public.scheme_applicability(scheme_id);

-- Scheme Policy Config
CREATE TABLE public.scheme_policy_config (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  scheme_id UUID NOT NULL REFERENCES public.schemes(id) ON DELETE CASCADE,
  policy_type TEXT NOT NULL,
  policy_key TEXT NOT NULL,
  policy_value JSONB NOT NULL DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(scheme_id, policy_type, policy_key)
);

ALTER TABLE public.scheme_policy_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view scheme policies" ON public.scheme_policy_config
  FOR SELECT USING (auth.uid() IS NOT NULL);

CREATE POLICY "Admins can manage scheme policies" ON public.scheme_policy_config
  FOR ALL USING (public.has_role(auth.uid(), 'admin'::public.app_role));

CREATE INDEX idx_scheme_policy_config_scheme ON public.scheme_policy_config(scheme_id);

-- User Business Plan Distributors
CREATE TABLE public.user_business_plan_distributors (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  business_plan_id UUID NOT NULL REFERENCES public.user_business_plans(id) ON DELETE CASCADE,
  distributor_id UUID NOT NULL REFERENCES public.distributors(id) ON DELETE CASCADE,
  distributor_name TEXT NOT NULL,
  revenue_target NUMERIC DEFAULT 0,
  quantity_target NUMERIC DEFAULT 0,
  last_year_revenue NUMERIC DEFAULT 0,
  growth_percent NUMERIC DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(business_plan_id, distributor_id)
);

ALTER TABLE public.user_business_plan_distributors ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their distributor plans" ON public.user_business_plan_distributors
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.user_business_plans bp WHERE bp.id = business_plan_id AND bp.user_id = auth.uid())
    OR public.has_role(auth.uid(), 'admin'::public.app_role)
  );

CREATE POLICY "Users can manage their distributor plans" ON public.user_business_plan_distributors
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_business_plans bp WHERE bp.id = business_plan_id AND bp.user_id = auth.uid())
  );

CREATE INDEX idx_user_bp_distributors_plan ON public.user_business_plan_distributors(business_plan_id);
CREATE INDEX idx_user_bp_distributors_dist ON public.user_business_plan_distributors(distributor_id);

-- User Business Plan Month Products
CREATE TABLE public.user_business_plan_month_products (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  business_plan_id UUID NOT NULL REFERENCES public.user_business_plans(id) ON DELETE CASCADE,
  month_id UUID REFERENCES public.user_business_plan_months(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  product_name TEXT NOT NULL,
  month_number INTEGER NOT NULL CHECK (month_number >= 1 AND month_number <= 12),
  revenue_target NUMERIC DEFAULT 0,
  quantity_target NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(business_plan_id, product_id, month_number)
);

ALTER TABLE public.user_business_plan_month_products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their month product plans" ON public.user_business_plan_month_products
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.user_business_plans bp WHERE bp.id = business_plan_id AND bp.user_id = auth.uid())
    OR public.has_role(auth.uid(), 'admin'::public.app_role)
  );

CREATE POLICY "Users can manage their month product plans" ON public.user_business_plan_month_products
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_business_plans bp WHERE bp.id = business_plan_id AND bp.user_id = auth.uid())
  );

CREATE INDEX idx_user_bp_month_products_plan ON public.user_business_plan_month_products(business_plan_id);
CREATE INDEX idx_user_bp_month_products_month ON public.user_business_plan_month_products(month_number);

-- User Business Plan Territory Beats
CREATE TABLE public.user_business_plan_territory_beats (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  business_plan_id UUID NOT NULL REFERENCES public.user_business_plans(id) ON DELETE CASCADE,
  territory_id UUID REFERENCES public.territories(id) ON DELETE SET NULL,
  territory_name TEXT,
  beat_id UUID REFERENCES public.beats(id) ON DELETE SET NULL,
  beat_name TEXT,
  revenue_target NUMERIC DEFAULT 0,
  quantity_target NUMERIC DEFAULT 0,
  retailer_count_target INTEGER DEFAULT 0,
  visit_target INTEGER DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.user_business_plan_territory_beats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their territory beat plans" ON public.user_business_plan_territory_beats
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.user_business_plans bp WHERE bp.id = business_plan_id AND bp.user_id = auth.uid())
    OR public.has_role(auth.uid(), 'admin'::public.app_role)
  );

CREATE POLICY "Users can manage their territory beat plans" ON public.user_business_plan_territory_beats
  FOR ALL USING (
    EXISTS (SELECT 1 FROM public.user_business_plans bp WHERE bp.id = business_plan_id AND bp.user_id = auth.uid())
  );

CREATE INDEX idx_user_bp_territory_beats_plan ON public.user_business_plan_territory_beats(business_plan_id);
CREATE INDEX idx_user_bp_territory_beats_territory ON public.user_business_plan_territory_beats(territory_id);
CREATE INDEX idx_user_bp_territory_beats_beat ON public.user_business_plan_territory_beats(beat_id);

-- Add triggers
CREATE TRIGGER update_schemes_updated_at BEFORE UPDATE ON public.schemes
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_scheme_applicability_updated_at BEFORE UPDATE ON public.scheme_applicability
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_scheme_policy_config_updated_at BEFORE UPDATE ON public.scheme_policy_config
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_bp_distributors_updated_at BEFORE UPDATE ON public.user_business_plan_distributors
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_bp_month_products_updated_at BEFORE UPDATE ON public.user_business_plan_month_products
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_bp_territory_beats_updated_at BEFORE UPDATE ON public.user_business_plan_territory_beats
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
