-- Update the handle_new_user function to also assign users to the default tenant
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  default_tenant_id uuid;
BEGIN
  -- Get the default tenant (first active tenant)
  SELECT id INTO default_tenant_id FROM public.tenants WHERE is_active = true ORDER BY created_at ASC LIMIT 1;
  
  -- Insert profile
  INSERT INTO public.profiles (id, username, full_name, phone_number, recovery_email, hint_question, hint_answer, tenant_id)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    COALESCE(new.raw_user_meta_data->>'full_name', 'User'),
    new.raw_user_meta_data->>'phone_number',
    new.raw_user_meta_data->>'recovery_email',
    COALESCE(new.raw_user_meta_data->>'hint_question', 'What is your favorite color?'),
    COALESCE(new.raw_user_meta_data->>'hint_answer', 'default'),
    default_tenant_id
  )
  ON CONFLICT (id) DO UPDATE SET tenant_id = COALESCE(profiles.tenant_id, default_tenant_id);
  
  -- Assign user to default tenant if one exists
  IF default_tenant_id IS NOT NULL THEN
    INSERT INTO public.tenant_users (tenant_id, user_id, role)
    VALUES (default_tenant_id, new.id, 'member')
    ON CONFLICT (tenant_id, user_id) DO NOTHING;
  END IF;
  
  RETURN new;
END;
$function$;