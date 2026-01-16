-- Fix Vinay Pratap's profile tenant_id
UPDATE profiles 
SET tenant_id = '24f9138a-6390-44e6-901d-701d0d75702e'
WHERE full_name = 'Vinay Pratap' AND tenant_id IS NULL;

-- Update Vinay Pratap's orders to have the correct tenant_id
UPDATE orders 
SET tenant_id = '24f9138a-6390-44e6-901d-701d0d75702e'
WHERE user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' AND tenant_id IS NULL;

-- Update Vinay Pratap's visits to have the correct tenant_id
UPDATE visits 
SET tenant_id = '24f9138a-6390-44e6-901d-701d0d75702e'
WHERE user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' AND tenant_id IS NULL;

-- Now fix the order dates - distribute orders between Jan 1-8, 2026
-- Get Abhishek's orders from 2026-01-16 and spread them across Jan 1-8
UPDATE orders 
SET order_date = '2026-01-01'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-02'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-03'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-04'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-05'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-06'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-07'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-08'
WHERE order_date = '2026-01-16' 
  AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '6be7e2ff-0447-44a0-a3b5-64993b9db54d' LIMIT 1 OFFSET 0);

-- Same for Vinay Pratap
UPDATE orders 
SET order_date = '2026-01-01'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-02'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-03'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-04'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-05'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-06'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-07'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);

UPDATE orders 
SET order_date = '2026-01-08'
WHERE order_date = '2026-01-16' 
  AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b'
  AND id IN (SELECT id FROM orders WHERE order_date = '2026-01-16' AND user_id = '33acad2e-14cf-4aa0-ae6c-5239590fa65b' LIMIT 1 OFFSET 0);