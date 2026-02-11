-- Fix the corrupted user record: GoTrue expects email_change to be '' not NULL
UPDATE auth.users 
SET email_change = ''
WHERE email_change IS NULL;

-- Also update the admin_create_auth_user function to include email_change and other missing columns
CREATE OR REPLACE FUNCTION public.admin_create_auth_user(
  p_email TEXT,
  p_password TEXT,
  p_user_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = auth, extensions, public
AS $$
DECLARE
  new_user_id UUID;
  encrypted_pw TEXT;
BEGIN
  new_user_id := gen_random_uuid();
  
  encrypted_pw := extensions.crypt(p_password, extensions.gen_salt('bf'));
  
  INSERT INTO auth.users (
    id, instance_id, aud, role, email, encrypted_password,
    email_confirmed_at, confirmed_at, raw_app_meta_data, raw_user_meta_data,
    is_sso_user, is_anonymous, created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new,
    email_change_token_current, reauthentication_token, phone_change_token,
    phone, phone_change, email_change, email_change_confirm_status
  ) VALUES (
    new_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated', p_email, encrypted_pw,
    NOW(), NOW(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    p_user_metadata,
    false, false, NOW(), NOW(),
    '', '', '', '', '', '',
    NULL, '', '', 0
  );
  
  INSERT INTO auth.identities (
    id, user_id, provider_id, provider, identity_data,
    last_sign_in_at, created_at, updated_at
  ) VALUES (
    gen_random_uuid(),
    new_user_id,
    p_email,
    'email',
    jsonb_build_object('sub', new_user_id::text, 'email', p_email, 'email_verified', true, 'phone_verified', false),
    NOW(), NOW(), NOW()
  );
  
  RETURN new_user_id;
END;
$$;