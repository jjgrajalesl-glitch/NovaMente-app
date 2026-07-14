BEGIN;

INSERT INTO configuration.currencies

(code,symbol,name)

VALUES

('USD','$','US Dollar'),

('EUR','€','Euro'),

('COP','$','Peso Colombiano'),

('MXN','$','Peso Mexicano'),

('BRL','R$','Real Brasileño'),

('ARS','$','Peso Argentino'),

('CLP','$','Peso Chileno'),

('PEN','S/','Sol Peruano')

ON CONFLICT (code) DO NOTHING;

COMMIT;
