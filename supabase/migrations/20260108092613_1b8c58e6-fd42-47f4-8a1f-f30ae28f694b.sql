-- Fix: Assign PLG Distributors Ltd to Sanjana Textiles (Mehreen's tenant)
UPDATE public.distributors 
SET tenant_id = '13cc6518-6746-4a78-b31a-0893e8563330'
WHERE id = 'cd4fb087-3ee6-480b-9673-fe4d24e936f7';