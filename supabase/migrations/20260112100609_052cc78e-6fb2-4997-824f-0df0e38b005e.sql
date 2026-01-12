-- Insert all 8 leave types for the Apply Leave dropdown
INSERT INTO public.leave_types (name, description) VALUES
  ('Annual Leave', 'Paid time off for vacation and personal use'),
  ('Casual Leave', 'Short-term leave for personal matters'),
  ('Emergency Leave', 'Leave for urgent or unforeseen circumstances'),
  ('Loss of Pay', 'Unpaid leave when other leave balances are exhausted'),
  ('Maternity Leave', 'Leave for expecting or new mothers'),
  ('Paternity Leave', 'Leave for new fathers'),
  ('Personal Leave', 'Leave for personal reasons'),
  ('Sick Leave', 'Leave due to illness or medical appointments')
ON CONFLICT (name) DO NOTHING;