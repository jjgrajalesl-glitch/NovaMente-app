BEGIN;

INSERT INTO configuration.roles

(code,name,description)

VALUES

('system','System','Internal System'),

('admin','Administrator','Platform Administrator'),

('support','Support','Customer Support'),

('premium','Premium','Premium Subscriber'),

('free','Free','Free User')

ON CONFLICT (code) DO NOTHING;

COMMIT;
