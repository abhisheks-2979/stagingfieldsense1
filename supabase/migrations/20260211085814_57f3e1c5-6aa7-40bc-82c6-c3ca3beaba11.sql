
-- Create helper function to delete auth user directly
CREATE OR REPLACE FUNCTION public.admin_delete_auth_user(p_user_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = auth, public
AS $$
BEGIN
  DELETE FROM auth.identities WHERE user_id = p_user_id;
  DELETE FROM auth.users WHERE id = p_user_id;
END;
$$;
