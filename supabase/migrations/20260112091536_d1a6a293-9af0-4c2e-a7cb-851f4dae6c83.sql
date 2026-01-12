-- Insert default performance module config if not exists
INSERT INTO performance_module_config (active_module)
SELECT 'both'
WHERE NOT EXISTS (SELECT 1 FROM performance_module_config LIMIT 1);