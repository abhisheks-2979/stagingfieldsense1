-- Insert default category
INSERT INTO public.product_categories (id, name, description) 
VALUES ('a1b2c3d4-e5f6-7890-abcd-ef1234567890', 'Tea Products', 'Tea and beverage products')
ON CONFLICT DO NOTHING;

-- Insert products based on the existing PRODUCTS_DATA in productMigration.ts
INSERT INTO public.products (name, sku, category_id, rate, unit, closing_stock, is_active) VALUES
('ADUKU 20G', 'ADUKU-20G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 342, 'grams', 100, true),
('ADUKU 100G', 'ADUKU-100G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 342, 'grams', 100, true),
('ADUKU 250G', 'ADUKU-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 342, 'grams', 100, true),
('ADUKU 500G', 'ADUKU-500G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 342, 'grams', 100, true),
('DAKSHIN 30G', 'DAKSHIN-30G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 209, 'grams', 100, true),
('DAKSHIN 250G', 'DAKSHIN-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 209, 'grams', 100, true),
('KADAK GOLD 1KG', 'KADAK-GOLD-1KG', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 350, 'kg', 50, true),
('KADAK GOLD 250G', 'KADAK-GOLD-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 350, 'grams', 100, true),
('KADAK GOLD 40G', 'KADAK-GOLD-40G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 350, 'grams', 200, true),
('KADAK GOLD 500G', 'KADAK-GOLD-500G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 350, 'grams', 100, true),
('KADAK PYALI ADARAK 250G', 'KADAK-PYALI-ADARAK-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 380, 'grams', 100, true),
('KADAK PYALI ADARAK 40G', 'KADAK-PYALI-ADARAK-40G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 380, 'grams', 200, true),
('KADAK PYALI BLUE 100G', 'KADAK-PYALI-BLUE-100G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 320, 'grams', 150, true),
('KADAK PYALI BLUE 1KG', 'KADAK-PYALI-BLUE-1KG', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 320, 'kg', 50, true),
('KADAK PYALI BLUE 20G', 'KADAK-PYALI-BLUE-20G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 320, 'grams', 300, true),
('KADAK PYALI BLUE 250G', 'KADAK-PYALI-BLUE-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 320, 'grams', 100, true),
('KADAK PYALI BLUE 40G', 'KADAK-PYALI-BLUE-40G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 320, 'grams', 200, true),
('KADAK PYALI BLUE 500G', 'KADAK-PYALI-BLUE-500G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 320, 'grams', 100, true),
('KADAK PYALI ELACHI 250G', 'KADAK-PYALI-ELACHI-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 400, 'grams', 100, true),
('KADAK PYALI ELACHI 40G', 'KADAK-PYALI-ELACHI-40G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 400, 'grams', 200, true),
('KADAK PYALI RL JAR 1KG', 'KADAK-PYALI-RL-JAR-1KG', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 360, 'kg', 50, true),
('KADAK PYALI RL JAR 250G', 'KADAK-PYALI-RL-JAR-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 360, 'grams', 100, true),
('KADAK PYALI RL JAR 500G', 'KADAK-PYALI-RL-JAR-500G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 360, 'grams', 100, true),
('KADAK PYALI RL POUCH 250G', 'KADAK-PYALI-RL-POUCH-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 340, 'grams', 100, true),
('KADAK PYALI YELLOW 100G', 'KADAK-PYALI-YELLOW-100G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 310, 'grams', 150, true),
('KADAK PYALI YELLOW 1KG', 'KADAK-PYALI-YELLOW-1KG', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 310, 'kg', 50, true),
('KADAK PYALI YELLOW 20G', 'KADAK-PYALI-YELLOW-20G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 310, 'grams', 300, true),
('KADAK PYALI YELLOW 250G', 'KADAK-PYALI-YELLOW-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 310, 'grams', 100, true),
('KADAK PYALI YELLOW 40G', 'KADAK-PYALI-YELLOW-40G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 310, 'grams', 200, true),
('KADAK PYALI YELLOW 500G', 'KADAK-PYALI-YELLOW-500G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 310, 'grams', 100, true),
('VAYU 250G', 'VAYU-250G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 280, 'grams', 100, true),
('VAYU 30G', 'VAYU-30G', 'a1b2c3d4-e5f6-7890-abcd-ef1234567890', 280, 'grams', 200, true);