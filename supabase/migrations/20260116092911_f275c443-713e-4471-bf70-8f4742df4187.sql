
-- Insert dummy data for Abhishek and Vinay Pratap (Jan 1-8, 2026)

-- Insert visits
INSERT INTO visits (user_id, retailer_id, planned_date, status, check_in_time, check_out_time)
SELECT 
  u.id,
  r.id,
  d::date,
  CASE WHEN random() > 0.2 THEN 'productive' ELSE 'unproductive' END,
  (d + interval '9 hours' + (random() * interval '2 hours'))::timestamptz,
  (d + interval '10 hours' + (random() * interval '3 hours'))::timestamptz
FROM (SELECT id, full_name FROM profiles WHERE full_name ILIKE '%Abhishek%' OR full_name ILIKE '%Vinay Pratap%') u
CROSS JOIN (SELECT id, name FROM retailers LIMIT 1) r
CROSS JOIN generate_series('2026-01-01'::date, '2026-01-08'::date, '1 day') d;

-- Insert orders
INSERT INTO orders (user_id, retailer_id, retailer_name, order_date, status, total_amount, subtotal)
SELECT 
  u.id,
  r.id,
  r.name,
  d::date,
  'confirmed',
  (1000 + random() * 9000)::numeric(10,2),
  (1000 + random() * 9000)::numeric(10,2)
FROM (SELECT id, full_name FROM profiles WHERE full_name ILIKE '%Abhishek%' OR full_name ILIKE '%Vinay Pratap%') u
CROSS JOIN (SELECT id, name FROM retailers LIMIT 1) r
CROSS JOIN generate_series('2026-01-01'::date, '2026-01-08'::date, '1 day') d;

-- Insert order items with hardcoded category
INSERT INTO order_items (order_id, product_id, product_name, category, quantity, rate, total)
SELECT 
  o.id,
  p.id,
  p.name,
  'Tea',
  (5 + random() * 20)::numeric(10,2),
  (100 + random() * 200)::numeric(10,2),
  (500 + random() * 2000)::numeric(10,2)
FROM orders o
CROSS JOIN (SELECT id, name FROM products LIMIT 2) p
WHERE o.order_date BETWEEN '2026-01-01' AND '2026-01-08'
  AND o.user_id IN (SELECT id FROM profiles WHERE full_name ILIKE '%Abhishek%' OR full_name ILIKE '%Vinay Pratap%');
