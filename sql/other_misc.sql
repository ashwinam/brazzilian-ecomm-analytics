-- mistakely payment_value data_type is integer but records have the numeric type thats why i changed the column here, but in create table ill fix it.
ALTER TABLE order_payments
ALTER COLUMN payment_value TYPE NUMERIC;