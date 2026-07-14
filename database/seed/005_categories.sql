BEGIN;

INSERT INTO configuration.categories

(code,name)

VALUES

('memory','Memoria'),

('attention','Atención'),

('logic','Lógica'),

('decision','Toma de Decisiones'),

('bias','Sesgos Cognitivos'),

('neurofinance','NeuroFinanzas'),

('mathematics','Matemáticas'),

('productivity','Productividad')

ON CONFLICT (code) DO NOTHING;

COMMIT;
