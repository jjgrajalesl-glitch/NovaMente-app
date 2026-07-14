BEGIN;

INSERT INTO configuration.languages
(code, name, native_name, direction)

VALUES

('es','Spanish','Español','ltr'),

('en','English','English','ltr'),

('pt','Portuguese','Português','ltr'),

('fr','French','Français','ltr'),

('de','German','Deutsch','ltr'),

('it','Italian','Italiano','ltr')

ON CONFLICT (code) DO NOTHING;

COMMIT;
