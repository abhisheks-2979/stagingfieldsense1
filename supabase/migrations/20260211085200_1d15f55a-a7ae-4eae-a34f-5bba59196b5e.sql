
-- Create a secure function to create auth users directly, bypassing GoTrue
-- This works around "Database error checking email" GoTrue issues
CREATE OR REPLACE FUNCTION public.admin_create_auth_user(
  p_email TEXT,
  p_password TEXT,
  p_user_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = auth, public
AS $$
DECLARE
  new_user_id UUID;
  encrypted_pw TEXT;
BEGIN
  -- Generate UUID
  new_user_id := gen_random_uuid();
  
  -- Hash the password using Supabase's crypt function
  encrypted_pw := crypt(p_password, gen_salt('bf'));
  
  -- Insert directly into auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    is_sso_user,
    is_anonymous,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change_token_current,
    reauthentication_token,
    phone_change_token
  ) VALUES (
    new_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    p_email,
    encrypted_pw,
    NOW(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    p_user_metadata,
    false,
    false,
    NOW(),
    NOW(),
    '',
    '',
    '',
    '',
    '',
    ''
  );
  
  -- Create identity record
  INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    provider,
    identity_data,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    gen_random_uuid(),
    new_user_id,
    p_email,
    'email',
    jsonb_build_object('sub', new_user_id::text, 'email', p_email, 'email_verified', true, 'phone_verified', false),
    NOW(),
    NOW(),
    NOW()
  );
  
  RETURN new_user_id;
END;
$$;
