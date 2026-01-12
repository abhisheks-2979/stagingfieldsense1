-- Delete existing default tasks
DELETE FROM public.onboarding_tasks;

-- Insert user's specific tasks
INSERT INTO public.onboarding_tasks (id, task_name, description, category, requires_attachment, sort_order, is_active) VALUES 
  ('0a922743-c576-4ae4-a8b6-ce86bc57d6f1', 'Territory Familiarization', 'Complete field visit with senior colleague', 'Orientation', false, 8, true),
  ('79176b8e-ed5d-4cfc-81b0-1cdfed3c5ba5', 'Upload Profile Photo', 'Add a professional profile picture', 'Profile Setup', true, 2, true),
  ('79e5d042-4116-49ac-adf4-438f3bef6bb7', 'Submit ID Proof', 'Upload a valid government ID proof (Aadhar/PAN)', 'Documentation', true, 4, true),
  ('8514e1d9-e61b-44a5-a698-ae3a5f65a6fd', 'Product Knowledge Training', 'Complete product training and quiz', 'Training', false, 6, true),
  ('c8fca858-abb1-46f3-97cd-2e13633a9494', 'Complete Safety Training', 'Complete the mandatory safety training module', 'Training', false, 5, true),
  ('d484ef64-b6c5-41e5-83bc-a35eb0ab4388', 'Complete Profile Information', 'Fill in all personal and contact details', 'Profile Setup', false, 1, true),
  ('efed60a4-b3ba-4713-a8ed-d21bf1fda64f', 'Meet Your Manager', 'Schedule and complete introductory meeting with manager', 'Orientation', false, 7, true),
  ('f77725f3-99e2-4bec-8707-693afcaa2f46', 'Read Company Policies', 'Review and acknowledge company policies and guidelines', 'Documentation', false, 3, true);