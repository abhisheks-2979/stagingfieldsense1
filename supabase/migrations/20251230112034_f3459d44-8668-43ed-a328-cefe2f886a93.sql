-- After creating a test user in the Auth dashboard, run this to set up their profile and admin role
-- Replace 'YOUR_TEST_USER_UUID' with the actual UUID from the auth.users table after creating the user

-- Example: Create a test admin profile (you'll need to replace the UUID after creating the user)
-- INSERT INTO public.profiles (id, username, full_name, hint_question, hint_answer)
-- VALUES ('YOUR_TEST_USER_UUID', 'testadmin', 'Test Admin', 'What is your test question?', 'test');

-- INSERT INTO public.user_roles (user_id, role)
-- VALUES ('YOUR_TEST_USER_UUID', 'admin');

-- For now, let's verify the trigger exists to auto-create profiles on signup
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname = 'handle_new_user' 
LIMIT 1;