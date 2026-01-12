-- Add year column to user_business_plans table
ALTER TABLE public.user_business_plans 
ADD COLUMN year integer;

-- Update existing rows to set year from year_start (fiscal year typically uses year_start as the primary year identifier)
UPDATE public.user_business_plans 
SET year = year_start 
WHERE year IS NULL;