--create database cookbook;

------------------------TABLES------------------------
create table meal(
	id_meal serial not null primary key,
	desc_meal text not null default 'no description',
	htc_meal text not null default 'no how to  eat expression'
);
alter table meal add column meal_name varchar(15) not null default 'no meal name';

create table category(
	id_category serial not null primary key,
	name_category varchar(12) not null default 'undefined category name'
);

create table cat_ingredient(
	id_ing_cat serial not null primary key,
	type_unit text not null default 'undefined ingredient type name'
);

create table ingredient(
	id_ingred serial not null primary key,
	name_ingred varchar(25) not null default 'no ingredient name',
	cost_unit_ingred int not null check(cost_unit_ingred > 0),
	nutval_ingred int not null check(nutval_ingred > 0),
	id_cat_ingred int not null default -1,
	constraint fk_ingred_catingred foreign key(id_cat_ingred) references cat_ingredient(id_ing_cat)
		on delete set default
);

create table meal_category(
	id_adj_mc serial not null primary key,
	id_meal_mc int not null default -1,
	id_category_mc int not null default -1,
	constraint fk_mc_meal foreign key(id_meal_mc) references meal(id_meal)
		on delete  set default,
	constraint fk_mc_category foreign key(id_category_mc) references category(id_category)
		on delete set default
);

create table meal_ingredient(
	id_adj_mi serial not null primary key,
	id_meal_mi int not null default -1,
	id_ingredient_mi int not null default -1,
	count_ingred_mi numeric not null check(count_ingred_mi > 0),
	constraint fk_mi_meal foreign key(id_meal_mi) references meal(id_meal)
		on delete set default,
	constraint fk_mi_ingred foreign key(id_ingredient_mi) references ingredient(id_ingred)
		on delete set default
);

create table meal_log(
	id_ml serial not null primary key,
	status_ml varchar(1) not null check (status_ml in ('i', 'u', 'd')),
	time_ml timestamp not null,
	id_changed_meal int not null default -1
);

create table category_log(
	id_cl serial not null primary key,
	status_cl varchar(1) not null check (status_cl in ('i', 'u', 'd')),
	time_cl timestamp not null,
	id_changed_category int not null default -1
);

create table ingredient_log(
	id_il serial not null primary key,
	status_il varchar(1) not null check (status_il in ('i', 'u', 'd')),
	time_il timestamp not null,
	id_changed_ingredient int not null default -1
);
------------------------/TABLES-----------------------

------------------------FUNCTIONES------------------------

/* on trigger functiones */ 
create or replace function ot_log_meal()
returns trigger as $$
begin
	if TG_OP = 'INSERT' then
		insert into meal_log(status_ml, time_ml, id_changed_meal) values ('i', now(), new.id_meal);
	elseif TG_OP = 'UPDATE' then
		insert into meal_log(status_ml, time_ml, id_changed_meal) values ('u', now(), new.id_meal);
	elseif TG_OP = 'DELETE' then
		insert into meal_log(status_ml, time_ml, id_changed_meal) values ('d', now(), old.id_meal);
	end if;
	return null;
end; 
$$ language plpgsql;

create or replace function ot_log_ingredient()
returns trigger as $$
begin
	if TG_OP = 'INSERT' then
		insert into ingredient_log(status_il, time_il, id_changed_ingredient) values ('i', now(), new.id_ingred);
	elseif TG_OP = 'UPDATE' then
		insert into ingredient_log(status_il, time_il, id_changed_ingredient) values ('u', now(), new.id_ingred);
	elseif TG_OP = 'DELETE' then
		insert into ingredient_log(status_il, time_il, id_changed_ingredient) values ('d', now(), old.id_ingred);
	end if;
	return null;
end; 
$$ language plpgsql;

create or replace function ot_log_category()
returns trigger as $$
begin
	if TG_OP = 'INSERT' then
		insert into category_log(status_cl, time_cl, id_changed_category) values ('i', now(), new.id_category);
	elseif TG_OP = 'UPDATE' then
		insert into category_log(status_cl, time_cl, id_changed_category) values ('u', now(), new.id_category);
	elseif TG_OP = 'DELETE' then
		insert into category_log(status_cl, time_cl, id_changed_category) values ('d', now(), old.id_category);
	end if;
	return null;
end; 
$$ language plpgsql;
/* end of ott block*/ 

create or replace function find_current_meal(m_name varchar(15))
returns table(_meal_name varchar(15), _desc_meal text, _htc_meal text) as
$$
begin 
	return query select meal_name, desc_meal, htc_meal from meal where meal_name = m_name;
end;
$$ language plpgsql;

create or replace function find_meal_categories(m_name varchar(15))
returns setof custom_categories as 
$$
begin
	select ctemp.name_category 
		from category ctemp, meal mtemp 
	join meal_category mctemp 
		on ctemp.id_category = mctemp.id_category_mc and mtemp.id_meal = mctemp.id_meal_mc
	where m_name = mtemp.meal_name;
end;
$$ language plpgsql;

create or replace function find_meal_ingredients(m_name varchar(15))
returns setof custom_ingredients as
$$
begin
	select itemp.name_ingred, itemp.cost_unit_ingred, itemp.nutval_ingred
		from meal mtemp, ingredients itemp
	join meal_ingredient mitemp
		on mtemp.id_meal = mitemp.id_meal_mi and itemp.id_ingred = mitemp.id_ingredient_mi
	where m_name = mtemp.meal_name;
end;
$$ language plpgsql;
------------------------/FUNCTIONES-----------------------

------------------------PROCEDURES------------------------
create or replace procedure insert_new_meal(m_name varchar(15), m_desc text, m_htc text) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from meal where m_name = meal_name)) then 
		res := 1;
	else 
		res := -1;
	end if;
	if (res = 1) then
		rollback;
	else
		insert into meal(meal_name, desc_meal, htc_meal) values (m_name, m_desc, m_htc);
		commit;
	end if;
end;
$$ language plpgsql;

create or replace procedure insert_new_ingredient(i_name varchar(25), i_cost_unit int, i_nutval int, i_cat int) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from ingredient where i_name = name_ingred)) then 
		res := 1;
	else 
		res := -1;
	end if;
	if (res = 1) then
		rollback;
	else
		insert into ingredient(name_ingred, cost_unit_ingred, nutval_ingred, id_cat_ingred) 
		values (i_name, i_cost_unit, i_nutval, i_cat);
		commit;
	end if;
end;
$$ language plpgsql;

create or replace procedure insert_new_category(c_name varchar(12)) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from category where c_name = name_category)) then 
		res := 1;
	else 
		res := -1;
	end if;
	if (res = 1) then
		rollback;
	else
		insert into category(name_category) values (c_name);
		commit;
	end if;
end;
$$ language plpgsql;

create or replace procedure delete_meal(m_name varchar(15)) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from meal where m_name = meal_name)) then 
		res := 1;
	else 
		res := -1;
	end if;
	if (res = 1) then
		delete from meal where meal_name = m_name;
		commit;
	else
		rollback;
	end if;
end;
$$ language plpgsql;

create or replace procedure delete_ingredient(i_name varchar(25)) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from ingredient where i_name = name_ingred)) then 
		res := 1;
	else 
		res := -1;
	end if;
	if (res = 1) then
		delete from ingredient where name_ingred = i_name;
		commit;
	else
		rollback;
	end if;
end;
$$ language plpgsql;

create or replace procedure delete_category(c_name varchar(12)) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from category where c_name = name_category)) then 
		res := 1;
	else 
		res := -1;
	end if;
	if (res = 1) then
		delete from category where name_category = c_name;
		commit;
	else
		rollback;
	end if;
end;
$$ language plpgsql;

------------------------/PROCEDURES-----------------------

------------------------TRIGGERS------------------------
create trigger change_meal_log after delete or insert or update on meal
	for each row 
		execute procedure ot_log_meal();
		
create trigger change_ingredient_log after delete or insert or update on ingredient
	for each row 
		execute procedure ot_log_ingredient();
		
create trigger change_category_log after delete or insert or update on category
	for each row 
		execute procedure ot_log_category();
------------------------/TRIGGERS-----------------------

-----------------------TYPES------------------------
create type custom_categories as (
	_category_name varchar(12)
);
create type custom_ingredients as (
	_name_ingred varchar(25),
	_cost_unit_ingred integer,
	_nutval_ingred integer
);
-----------------------/TYPES-----------------------

------------------------INDEXES------------------------

------------------------/INDEXES-----------------------

------------------------VIEWS------------------------
create view meal_list as
	select meal_name as name, desc_meal as description from meal;

create view category_list as
	select name_category as name from category;

create view ingredients_list as
	select name_ingred as name from ingredient;
------------------------/VIEWS-----------------------

-----------------------QUERIES------------------------
select * from meal_list;
select * from meal_log;
select * from meal;
select * from category;

insert into meal(meal_name) values ('test-meal');
update meal set meal_name='borsh' where id_meal=2;
delete from meal where id_meal = '3';
delete from meal_log where id_ml < 100;
select * from find_current_meal('test-meal');
select * from find_meal_categories('dw');

call insert_new_category('Мясное');
------------------------/QUERIES-----------------------
