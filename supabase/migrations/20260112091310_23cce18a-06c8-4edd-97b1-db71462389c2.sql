-- Create ai_autonomous_actions table
CREATE TABLE public.ai_autonomous_actions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  action_type text NOT NULL,
  action_data jsonb DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'pending'::text,
  executed_at timestamp with time zone,
  can_undo boolean DEFAULT false,
  undo_until timestamp with time zone,
  undone_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ai_autonomous_actions_pkey PRIMARY KEY (id)
);

-- Create ai_insights table
CREATE TABLE public.ai_insights (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  insight_type text NOT NULL,
  category text NOT NULL,
  priority text NOT NULL DEFAULT 'medium'::text,
  title text NOT NULL,
  description text NOT NULL,
  action_type text,
  action_data jsonb,
  reference_id uuid,
  reference_type text,
  is_read boolean DEFAULT false,
  is_dismissed boolean DEFAULT false,
  is_actioned boolean DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  expires_at timestamp with time zone,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ai_insights_pkey PRIMARY KEY (id)
);

-- Create aspirations_and_preferences table
CREATE TABLE public.aspirations_and_preferences (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE,
  career_goal text,
  dream_role text,
  preferred_work_style text,
  motivation_driver text,
  five_year_vision text,
  favorite_activity text,
  preferred_reward text,
  team_preference text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT aspirations_and_preferences_pkey PRIMARY KEY (id)
);

-- Create competency_templates table
CREATE TABLE public.competency_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  role_type text NOT NULL,
  competency_name text NOT NULL,
  competency_code text NOT NULL UNIQUE,
  description text,
  category text NOT NULL,
  weightage numeric NOT NULL DEFAULT 0,
  calculation_formula jsonb NOT NULL DEFAULT '{}'::jsonb,
  icon text,
  max_score numeric DEFAULT 100,
  is_active boolean DEFAULT true,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT competency_templates_pkey PRIMARY KEY (id)
);

-- Create distributor_company_returns table
CREATE TABLE public.distributor_company_returns (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  distributor_id uuid NOT NULL REFERENCES public.distributors(id),
  return_number text NOT NULL UNIQUE,
  return_date date NOT NULL DEFAULT CURRENT_DATE,
  total_quantity integer DEFAULT 0,
  total_value numeric DEFAULT 0,
  status text NOT NULL DEFAULT 'draft'::text,
  notes text,
  submitted_at timestamp with time zone,
  approved_by uuid,
  approved_at timestamp with time zone,
  picked_up_at timestamp with time zone,
  credit_note_number text,
  credit_note_amount numeric,
  credit_note_date date,
  created_by uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT distributor_company_returns_pkey PRIMARY KEY (id)
);

-- Create distributor_company_return_items table
CREATE TABLE public.distributor_company_return_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  company_return_id uuid NOT NULL REFERENCES public.distributor_company_returns(id),
  product_id uuid NOT NULL REFERENCES public.products(id),
  variant_id uuid,
  product_name text NOT NULL,
  quantity integer NOT NULL,
  unit text,
  unit_cost numeric DEFAULT 0,
  total numeric DEFAULT 0,
  reason text NOT NULL,
  source text DEFAULT 'own_stock'::text,
  source_return_id uuid,
  batch_number text,
  expiry_date date,
  notes text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT distributor_company_return_items_pkey PRIMARY KEY (id)
);

-- Create distributor_business_plan_month_products table
CREATE TABLE public.distributor_business_plan_month_products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  business_plan_id uuid NOT NULL REFERENCES public.distributor_business_plans(id),
  month_number integer NOT NULL,
  month_name text NOT NULL,
  product_id uuid NOT NULL REFERENCES public.products(id),
  product_name text NOT NULL,
  percentage numeric NOT NULL DEFAULT 0,
  quantity_target numeric DEFAULT 0,
  revenue_target numeric DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT distributor_business_plan_month_products_pkey PRIMARY KEY (id)
);

-- Enable RLS on all new tables
ALTER TABLE public.ai_autonomous_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.aspirations_and_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.competency_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.distributor_company_returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.distributor_company_return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.distributor_business_plan_month_products ENABLE ROW LEVEL SECURITY;

-- RLS Policies for ai_autonomous_actions
CREATE POLICY "Users can view their own actions" ON public.ai_autonomous_actions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own actions" ON public.ai_autonomous_actions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own actions" ON public.ai_autonomous_actions FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for ai_insights
CREATE POLICY "Users can view their own insights" ON public.ai_insights FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own insights" ON public.ai_insights FOR ALL USING (auth.uid() = user_id);

-- RLS Policies for aspirations_and_preferences
CREATE POLICY "Users can view their own aspirations" ON public.aspirations_and_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage their own aspirations" ON public.aspirations_and_preferences FOR ALL USING (auth.uid() = user_id);

-- RLS Policies for competency_templates (readable by all authenticated)
CREATE POLICY "Authenticated users can view templates" ON public.competency_templates FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage templates" ON public.competency_templates FOR ALL USING (public.has_role(auth.uid(), 'admin'::public.app_role));

-- RLS Policies for distributor_company_returns
CREATE POLICY "Authenticated users can view returns" ON public.distributor_company_returns FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can manage returns" ON public.distributor_company_returns FOR ALL TO authenticated USING (true);

-- RLS Policies for distributor_company_return_items
CREATE POLICY "Authenticated users can view return items" ON public.distributor_company_return_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can manage return items" ON public.distributor_company_return_items FOR ALL TO authenticated USING (true);

-- RLS Policies for distributor_business_plan_month_products
CREATE POLICY "Authenticated users can view plan products" ON public.distributor_business_plan_month_products FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can manage plan products" ON public.distributor_business_plan_month_products FOR ALL TO authenticated USING (true);