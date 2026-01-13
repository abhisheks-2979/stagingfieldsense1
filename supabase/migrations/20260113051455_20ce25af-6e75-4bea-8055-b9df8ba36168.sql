-- Create user_competency_monthly_scores table
CREATE TABLE public.user_competency_monthly_scores (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  competency_template_id uuid NOT NULL,
  month_year date NOT NULL,
  score numeric(5, 2) NOT NULL,
  raw_metrics jsonb NULL DEFAULT '{}'::jsonb,
  previous_month_score numeric(5, 2) NULL,
  trend text NULL,
  calculated_at timestamp with time zone NULL DEFAULT now(),
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT user_competency_monthly_scores_pkey PRIMARY KEY (id),
  CONSTRAINT user_competency_monthly_score_user_id_competency_template_i_key UNIQUE (user_id, competency_template_id, month_year),
  CONSTRAINT user_competency_monthly_scores_competency_template_id_fkey FOREIGN KEY (competency_template_id) REFERENCES competency_templates (id) ON DELETE CASCADE,
  CONSTRAINT user_competency_monthly_scores_score_check CHECK (score >= 0 AND score <= 100),
  CONSTRAINT user_competency_monthly_scores_trend_check CHECK (trend = ANY (ARRAY['improving', 'declining', 'stable', 'new']))
);

-- Create user_monthly_scorecards table
CREATE TABLE public.user_monthly_scorecards (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  month_year date NOT NULL,
  role_type text NOT NULL,
  overall_score numeric(5, 2) NOT NULL,
  weighted_score numeric(5, 2) NULL,
  performance_band text NULL,
  rank_in_team integer NULL,
  total_team_members integer NULL,
  ai_summary text NULL,
  ai_strengths jsonb NULL DEFAULT '[]'::jsonb,
  ai_improvement_areas jsonb NULL DEFAULT '[]'::jsonb,
  ai_action_plan jsonb NULL DEFAULT '{}'::jsonb,
  manager_id uuid NULL,
  is_published boolean NULL DEFAULT false,
  published_at timestamp with time zone NULL,
  created_at timestamp with time zone NULL DEFAULT now(),
  updated_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT user_monthly_scorecards_pkey PRIMARY KEY (id),
  CONSTRAINT user_monthly_scorecards_user_id_month_year_key UNIQUE (user_id, month_year),
  CONSTRAINT user_monthly_scorecards_overall_score_check CHECK (overall_score >= 0 AND overall_score <= 100),
  CONSTRAINT user_monthly_scorecards_performance_band_check CHECK (performance_band = ANY (ARRAY['exceptional', 'strong', 'developing', 'needs_improvement'])),
  CONSTRAINT user_monthly_scorecards_role_type_check CHECK (role_type = ANY (ARRAY['field_executive', 'field_manager']))
);

-- Create indexes
CREATE INDEX idx_user_competency_monthly_scores_user_month ON public.user_competency_monthly_scores (user_id, month_year);
CREATE INDEX idx_user_competency_monthly_scores_competency ON public.user_competency_monthly_scores (competency_template_id);
CREATE INDEX idx_user_monthly_scorecards_user_month ON public.user_monthly_scorecards (user_id, month_year);
CREATE INDEX idx_user_monthly_scorecards_manager ON public.user_monthly_scorecards (manager_id);

-- Enable RLS
ALTER TABLE public.user_competency_monthly_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_monthly_scorecards ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_competency_monthly_scores
CREATE POLICY "Users can view own scores" ON public.user_competency_monthly_scores FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own scores" ON public.user_competency_monthly_scores FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own scores" ON public.user_competency_monthly_scores FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Service role full access scores" ON public.user_competency_monthly_scores FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- RLS Policies for user_monthly_scorecards
CREATE POLICY "Users can view own scorecards" ON public.user_monthly_scorecards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own scorecards" ON public.user_monthly_scorecards FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own scorecards" ON public.user_monthly_scorecards FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Service role full access scorecards" ON public.user_monthly_scorecards FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- Trigger for updated_at
CREATE TRIGGER update_user_monthly_scorecards_updated_at 
  BEFORE UPDATE ON user_monthly_scorecards 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();