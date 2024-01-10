create table c_customer(
	customer_id serial primary key,
	first_name VARCHAR(100),
	last_name VARCHAR(100)
);

create table c_salesperson(
	s_person_id serial primary key,
	first_name VARCHAR(100),
	last_name VARCHAR(100)
);

create table c_cars(
	car_serial serial primary key,
	make VARCHAR(100),
	model VARCHAR(100),
	year numeric(4),
	is_used bool
);

alter table c_cars
add price numeric (7,2);

alter table c_cars
rename column year to model_year;

alter table c_cars
alter column model_year type year;

create table c_mechanic(
	mechanic_id serial primary key,
	first_name VARCHAR(100),
	last_name VARCHAR(100)
);

create table c_parts(
	part_id serial primary key,
	part_name VARCHAR(200),
	manufacturer VARCHAR(100),
	cost NUMERIC(5,2)
);

create table c_invoice(
	invoice_num serial primary key,
	customer_id integer not null,
	s_person_id integer not null, 
	car_serial integer not null,
	price numeric (7,2),
	invoice_date date default current_date,
	foreign key (customer_id) references c_customer(customer_id),
	foreign key (s_person_id) references c_salesperson(s_person_id),
	foreign key (car_serial) references c_cars(car_serial)
);

create table c_service_ticket(
	service_ticket serial primary key,
	car_serial integer not null,
	mechanic_id integer not null,
	part_id integer not null,
	customer_id integer not null,
	services_performed VARCHAR (200),
	total_cost numeric (6,2),
	service_date date default current_date,
	foreign key (car_serial) references c_cars(car_serial),
	foreign key (customer_id) references c_customer(customer_id),
	foreign key (mechanic_id) references c_mechanic(mechanic_id),
	foreign key (part_id) references c_parts(part_id)
);

insert into c_cars (car_serial, make, model, model_year, is_used, price)
values
(1, 'Ford', 'F-150', 2020, true, 29549.99),
(2, 'Chevy', 'Traverse', 2021, false, 34549.99),
(3, 'Chevy', 'Equinox', 2013, true, 4536.50),
(4, 'Nissan', 'Altima', 2024, false, 55449.99);

insert into c_cars (car_serial, make, model, model_year, price)
values (5, 'Dodge', 'Neon', 2001, 3449.99);

CREATE OR REPLACE PROCEDURE usedcar(
	car INTEGER,
	used bool
)
LANGUAGE plpgsql
AS $$
BEGIN

	UPDATE c_cars
	SET is_used = used
	WHERE car_serial = car;
	
	COMMIT;
	
END;
$$

call usedcar(5,true);

insert into c_cars
values (6, 'Toyota', 'Rav-4', 2015, null, 42100.99);

call usedcar(6, true);

insert into c_customer
values
(1, 'Carl', 'Miller'),
(2, 'Joseph', 'Arimathea'),
(3, 'Bradley', 'Cooper'),
(4, 'Jeff', 'Goldblum');

insert into c_salesperson
values
(1, 'Leslie', 'Templeton'),
(2, 'Sarah', 'Campbell'), 
(3, 'Brandon', 'Trenta'),
(4, 'George', 'Sanders');

insert into c_mechanic
values
(1, 'Jeff', 'Bezos'),
(2, 'Mario', 'Andretti'),
(3, 'Fred', 'Rusteaze'),
(4, 'Lightning', 'McQueen');

insert into c_parts
values
(1, 'Carburetor', 'Autozone', 29.99),
(2, 'Oil Filter', 'O-Reilly', 14.99),
(3, 'Fuel pump', 'Amzoil', 209.95),
(4, 'Air Filter', 'Ford OEM', 143.90);

insert into c_invoice
values
(1, 1, 1, 1, 29549.99, default);

insert into c_invoice
values
(2, 3, 4, 6, 42100.99),
(3, 3, 4, 2, 34549.99),
(4, 4, 2, 5, 3449.99);

create or replace procedure sales_tax(
	invoice integer,
	sales_tax numeric (4,2)
)
language plpgsql
as $$
begin	
	update c_invoice
	set price = price + sales_tax
	where invoice_num = invoice;
	
	commit;
end;
$$

call sales_tax(1, 99.99);
call sales_tax(2, 49.99);
call sales_tax(3, 99.99);
call sales_tax(4, 109);

insert into c_service_ticket
values
(1, 1, 1, 2, 1, 'Oil Change', 54.99, default),
(2, 1, 1, 3, 1, 'Tune-up', 159.99, default),
(3, 5, 3, 1, 3, 'Service', 99.99, default);


create or replace function add_cars(_car_serial integer, _make VARCHAR, _model VARCHAR, _model_year year, _is_used bool, _price numeric(7,2))
returns void
as $main$
begin
	insert into c_cars(car_serial, make, model, model_year, is_used, price)
	values (_car_serial, _make, _model, _model_year, _is_used, _price);
end;
$main$
language plpgsql;


select add_cars(7, 'Ford', 'Mustang', 1967, true, 10993.95);

select add_cars(8, 'Kia', 'Sorento', 2015, true, 15339.95);

select add_cars(9, 'BMW', 'Z3', 2023, false, 79999.99);
