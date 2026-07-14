BEGIN;

INSERT INTO configuration.countries

(iso2, iso3, name, language_code, currency_code)

VALUES

('CO','COL','Colombia','es','COP'),

('MX','MEX','México','es','MXN'),

('US','USA','United States','en','USD'),

('BR','BRA','Brasil','pt','BRL'),

('ES','ESP','España','es','EUR'),

('AR','ARG','Argentina','es','ARS'),

('CL','CHL','Chile','es','CLP'),

('PE','PER','Perú','es','PEN')

ON CONFLICT (iso2) DO NOTHING;

COMMIT;
