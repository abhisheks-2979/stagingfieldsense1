-- Make hint_question and hint_answer nullable
ALTER TABLE public.profiles ALTER COLUMN hint_question DROP NOT NULL;
ALTER TABLE public.profiles ALTER COLUMN hint_answer DROP NOT NULL;

-- Create missing profiles for users
INSERT INTO public.profiles (id, username, full_name, user_status)
VALUES 
  ('0f30e6cf-66bf-4277-b821-d3e3967b5d78', 'KBG', 'Girish', 'active'),
  ('8ddd3473-8bd6-4668-b151-02364ffc6dbb', 'ajay.prabhu2', 'Ajay Prabhu', 'active'),
  ('7d96ad72-6617-40a4-8f9b-e491b526278d', 'Shravya', 'Shravya Amin', 'active'),
  ('d63ecc6f-4ef4-468b-a237-7a6617bb7cdd', 'Pra', 'Prajwal', 'active'),
  ('921a76fc-2f69-4aed-8586-cf254caeb420', 'Fuzail', 'Fuzail', 'active'),
  ('427ce7c2-b26e-43c8-9470-fc57a73e8606', 'Harshith', 'Harshith', 'active'),
  ('d8a82c5b-0c24-489d-afbb-74a29aed2bf8', 'Manvith', 'Manvith', 'active'),
  ('d6d364d5-6f19-4da9-bb48-67b04a8065fa', 'manvithbb', 'MANVITH', 'active'),
  ('a59f958b-d6d6-404d-b7a3-6616587eacc0', 'User_Prerana', 'Prerana', 'active'),
  ('6d7227ff-c408-4b33-92c4-6227807e539b', 'ajay.prabhu', 'Ajay Prabhu', 'active'),
  ('73e06f47-e9dc-4e19-a120-6e16157567dd', 'Sanjay_s', 'Sanjay s', 'active'),
  ('279fa782-ba4c-456e-b560-e61387a1bb0a', 'Shravyaamin', 'Shravyaamin', 'active'),
  ('4ec01968-6f21-4d68-8fad-f06a04207d26', 'testuser', 'Testuser', 'active'),
  ('01afedfd-f870-436f-b6e7-5c35ae1746fd', 'Suyog', 'Suyog', 'active'),
  ('6be7e2ff-0447-44a0-a3b5-64993b9db54d', 'abhishek', 'Abhishek', 'active')
ON CONFLICT (id) DO NOTHING;