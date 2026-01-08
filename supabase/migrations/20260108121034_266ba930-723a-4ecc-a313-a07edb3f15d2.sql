-- =====================================================
-- USER-ONLY VISIBILITY FOR RETAILERS, DISTRIBUTORS, BEATS
-- Step 1: Add created_by column to distributors table
-- Step 2: Update RLS policies for user-only visibility
-- =====================================================

-- Add created_by column to distributors (nullable to not break existing data)
ALTER TABLE public.distributors ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users(id);

-- RETAILERS: Drop existing SELECT policies and create user-only
DROP POLICY IF EXISTS "Users can view their own retailers" ON public.retailers;
DROP POLICY IF EXISTS "Users can view retailers in their tenant" ON public.retailers;
DROP POLICY IF EXISTS "Users can view retailers they have visits for" ON public.retailers;
DROP POLICY IF EXISTS "Admins can view all retailers" ON public.retailers;

-- Users can only see retailers they created
CREATE POLICY "Users can view their own retailers"
ON public.retailers
FOR SELECT
USING (auth.uid() = user_id);

-- Admins can view all retailers (for management)
CREATE POLICY "Admins can view all retailers"
ON public.retailers
FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role));

-- DISTRIBUTORS: Drop existing SELECT policy and create user-only
DROP POLICY IF EXISTS "Users can view distributors in their tenant" ON public.distributors;

-- Users can only see distributors they created
CREATE POLICY "Users can view their own distributors"
ON public.distributors
FOR SELECT
USING (auth.uid() = created_by);

-- Admins can view all distributors (for management)
CREATE POLICY "Admins can view all distributors"
ON public.distributors
FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role));

-- BEATS: Drop existing SELECT policies and create user-only
DROP POLICY IF EXISTS "Users can view beats in their tenant" ON public.beats;
DROP POLICY IF EXISTS "Tenant owners can view all beats" ON public.beats;

-- Users can only see beats they created
CREATE POLICY "Users can view their own beats"
ON public.beats
FOR SELECT
USING (auth.uid() = created_by);

-- Admins can view all beats (for management)
CREATE POLICY "Admins can view all beats"
ON public.beats
FOR SELECT
USING (has_role(auth.uid(), 'admin'::app_role));