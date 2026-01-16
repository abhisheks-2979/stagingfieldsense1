
-- Update tenant_id for orders that have null tenant_id
UPDATE orders 
SET tenant_id = (SELECT tenant_id FROM profiles WHERE profiles.id = orders.user_id AND profiles.tenant_id IS NOT NULL)
WHERE tenant_id IS NULL
  AND user_id IN (
    SELECT id FROM profiles WHERE tenant_id IS NOT NULL
  );

-- Also update visits and order_items similarly
UPDATE visits 
SET tenant_id = (SELECT tenant_id FROM profiles WHERE profiles.id = visits.user_id AND profiles.tenant_id IS NOT NULL)
WHERE tenant_id IS NULL
  AND user_id IN (
    SELECT id FROM profiles WHERE tenant_id IS NOT NULL
  );
