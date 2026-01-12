-- Create user_business_plans table for FY Plan management
CREATE TABLE public.user_business_plans (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  fiscal_year TEXT NOT NULL,
  year_start INTEGER NOT NULL,
  year_end INTEGER NOT NULL,
  revenue_target NUMERIC DEFAULT 0,
  quantity_target NUMERIC DEFAULT 0,
  quantity_unit TEXT DEFAULT 'units',
  notes TEXT,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  tenant_id UUID REFERENCES public.tenants(id),
  UNIQUE(user_id, fiscal_year)
);

-- Create user_business_plan_products table for product-wise targets
CREATE TABLE public.user_business_plan_products (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  business_plan_id UUID NOT NULL REFERENCES public.user_business_plans(id) ON DELETE CASCADE,
  product_id UUID NOT NULL,
  product_name TEXT NOT NULL,
  revenue_target NUMERIC DEFAULT 0,
  quantity_target NUMERIC DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create user_business_plan_retailers table for retailer-wise targets
CREATE TABLE public.user_business_plan_retailers (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  business_plan_id UUID NOT NULL REFERENCES public.user_business_plans(id) ON DELETE CASCADE,
  retailer_id UUID NOT NULL,
  retailer_name TEXT NOT NULL,
  last_year_revenue NUMERIC DEFAULT 0,
  target_revenue NUMERIC DEFAULT 0,
  growth_percent NUMERIC DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create user_business_plan_months table for monthly targets (April to March)
CREATE TABLE public.user_business_plan_months (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  business_plan_id UUID NOT NULL REFERENCES public.user_business_plans(id) ON DELETE CASCADE,
  month_number INTEGER NOT NULL CHECK (month_number >= 1 AND month_number <= 12),
  month_name TEXT NOT NULL,
  target_revenue NUMERIC DEFAULT 0,
  quantity_target NUMERIC DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.user_business_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_business_plan_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_business_plan_retailers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_business_plan_months ENABLE ROW LEVEL SECURITY;

-- RLS policies for user_business_plans
CREATE POLICY "Users can view their own business plans"
  ON public.user_business_plans FOR SELECT
  USING (auth.uid() = user_id OR public.has_role(auth.uid(), 'admin'::public.app_role));

CREATE POLICY "Users can create their own business plans"
  ON public.user_business_plans FOR INSERT
  WITH CHECK (auth.uid() = user_id OR public.has_role(auth.uid(), 'admin'::public.app_role));

CREATE POLICY "Users can update their own business plans"
  ON public.user_business_plans FOR UPDATE
  USING (auth.uid() = user_id OR public.has_role(auth.uid(), 'admin'::public.app_role));

CREATE POLICY "Users can delete their own business plans"
  ON public.user_business_plans FOR DELETE
  USING (auth.uid() = user_id OR public.has_role(auth.uid(), 'admin'::public.app_role));

-- RLS policies for user_business_plan_products
CREATE POLICY "Users can view their plan products"
  ON public.user_business_plan_products FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.user_business_plans bp 
    WHERE bp.id = business_plan_id 
    AND (bp.user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::public.app_role))
  ));

CREATE POLICY "Users can manage their plan products"
  ON public.user_business_plan_products FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.user_business_plans bp 
    WHERE bp.id = business_plan_id 
    AND (bp.user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::public.app_role))
  ));

-- RLS policies for user_business_plan_retailers
CREATE POLICY "Users can view their plan retailers"
  ON public.user_business_plan_retailers FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.user_business_plans bp 
    WHERE bp.id = business_plan_id 
    AND (bp.user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::public.app_role))
  ));

CREATE POLICY "Users can manage their plan retailers"
  ON public.user_business_plan_retailers FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.user_business_plans bp 
    WHERE bp.id = business_plan_id 
    AND (bp.user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::public.app_role))
  ));

-- RLS policies for user_business_plan_months
CREATE POLICY "Users can view their plan months"
  ON public.user_business_plan_months FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.user_business_plans bp 
    WHERE bp.id = business_plan_id 
    AND (bp.user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::public.app_role))
  ));

CREATE POLICY "Users can manage their plan months"
  ON public.user_business_plan_months FOR ALL
  USING (EXISTS (
    SELECT 1 FROM public.user_business_plans bp 
    WHERE bp.id = business_plan_id 
    AND (bp.user_id = auth.uid() OR public.has_role(auth.uid(), 'admin'::public.app_role))
  ));

-- Create indexes for better performance
CREATE INDEX idx_user_business_plans_user_id ON public.user_business_plans(user_id);
CREATE INDEX idx_user_business_plans_fiscal_year ON public.user_business_plans(fiscal_year);
CREATE INDEX idx_user_business_plan_products_plan_id ON public.user_business_plan_products(business_plan_id);
CREATE INDEX idx_user_business_plan_retailers_plan_id ON public.user_business_plan_retailers(business_plan_id);
CREATE INDEX idx_user_business_plan_months_plan_id ON public.user_business_plan_months(business_plan_id);

-- Trigger for updated_at
CREATE TRIGGER update_user_business_plans_updated_at
  BEFORE UPDATE ON public.user_business_plans
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();