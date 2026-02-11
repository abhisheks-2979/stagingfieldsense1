
-- Create helper function to check if email exists in auth.users
CREATE OR REPLACE FUNCTION public.admin_check_email_exists(p_email TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = auth, public
AS $$
DECLARE
  found_id UUID;
BEGIN
  SELECT id INTO found_id FROM auth.users WHERE email = p_email LIMIT 1;
  RETURN found_id;
END;
$$;
