-- Create onboarding_tasks table
CREATE TABLE public.onboarding_tasks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  task_name text NOT NULL,
  description text NULL,
  category text NULL,
  requires_attachment boolean NULL DEFAULT false,
  sort_order integer NULL DEFAULT 0,
  is_active boolean NULL DEFAULT true,
  created_at timestamp with time zone NULL DEFAULT now(),
  CONSTRAINT onboarding_tasks_pkey PRIMARY KEY (id)
);

-- Create user onboarding progress table
CREATE TABLE public.user_onboarding_progress (
  id uuid NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL,
  task_id uuid NOT NULL REFERENCES public.onboarding_tasks(id) ON DELETE CASCADE,
  is_completed boolean DEFAULT false,
  completed_at timestamp with time zone,
  attachment_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  UNIQUE(user_id, task_id)
);

-- Enable RLS on both tables
ALTER TABLE public.onboarding_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_onboarding_progress ENABLE ROW LEVEL SECURITY;

-- RLS policies for onboarding_tasks
CREATE POLICY "Anyone can view active tasks"
  ON public.onboarding_tasks FOR SELECT
  USING (is_active = true);

-- RLS policies for user_onboarding_progress
CREATE POLICY "Users can view their own progress"
  ON public.user_onboarding_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress"
  ON public.user_onboarding_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress"
  ON public.user_onboarding_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- Insert default onboarding tasks
INSERT INTO public.onboarding_tasks (task_name, description, category, requires_attachment, sort_order) VALUES
  ('Complete Profile Information', 'Fill in all your personal and professional details', 'Profile Setup', false, 1),
  ('Upload Profile Photo', 'Add a professional photo to your profile', 'Profile Setup', true, 2),
  ('Read Company Policies', 'Review and acknowledge company policies and guidelines', 'Documentation', false, 3),
  ('Submit ID Proof', 'Upload a valid government-issued ID for verification', 'Documentation', true, 4),
  ('Complete Bank Details', 'Add your bank account information for salary processing', 'Documentation', true, 5),
  ('Emergency Contact Info', 'Provide emergency contact details', 'Profile Setup', false, 6),
  ('Complete Product Training', 'Finish the introductory product training module', 'Training', false, 7),
  ('Meet Your Manager', 'Schedule and complete an introduction meeting with your manager', 'Onboarding', false, 8);