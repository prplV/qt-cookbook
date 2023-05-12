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
alter table ingredient alter column nutval_ingred type numeric;
alter table ingredient alter column cost_unit_ingred type numeric;

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
	return query select ctemp.name_category 
		from category ctemp, meal mtemp, meal_category mctemp 
	where m_name = mtemp.meal_name and ctemp.id_category = mctemp.id_category_mc and mtemp.id_meal = mctemp.id_meal_mc;
end;
$$ language plpgsql;

create or replace function find_meal_ingredients(m_name varchar(15))
returns setof custom_ingredients as
$$
begin
	return query select itemp.name_ingred, itemp.cost_unit_ingred, itemp.nutval_ingred
		from meal mtemp, ingredient itemp, meal_ingredient mitemp
	where m_name = mtemp.meal_name and mtemp.id_meal = mitemp.id_meal_mi and itemp.id_ingred = mitemp.id_ingredient_mi;
end;
$$ language plpgsql;

create or replace function perform_ingredients(m_name varchar(15))
returns table (ingredient varchar(25), ingredient_count numeric, category_ingredient text) as
$$
begin
	return query
	select ingred, count, type from for_pi_func where m_name = meal;
end;
$$ language plpgsql;


create or replace function get_meal_cost(m_name varchar(12))
returns table(final_cost numeric) as
$$
begin
	return query 
	select sum(uni_on) from for_gmc_func where m_name = meal;
end;
$$ language plpgsql;

create or replace function get_meal_nutval(m_name varchar(12))
returns table(final_nutval numeric) as
$$
begin
	return query 
	select sum(uni_on) from for_gmn_func where m_name = meal;
end;
$$ language plpgsql;

/*stat functions*/
create or replace function stat_meal_ingred()
returns table(meal_name varchar(15), ingred_count bigint) as
$$
begin
	return query select * from multy_table_view_mi;
end;
$$ language plpgsql;

create or replace function stat_meal_cat()
returns table(meal_name varchar(15), cat_count bigint) as
$$
begin
	return query select * from multy_table_view_mc;
end;
$$ language plpgsql;

create or replace function stat_category_meal()
returns table(category varchar(15), count_meal bigint) as
$$
begin 
	return query select * from multy_table_view_cm;
end;
$$ language plpgsql;

create or replace function stat_ingred_meal()
returns table(name_ingredient varchar(25), count_meal bigint) as
$$
begin 
	return query select * from multy_table_view_im;
end; 
$$ language plpgsql;
/*end of sf block*/
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

create or replace procedure update_meal_name(old_m_name varchar(15), new_m_name varchar(15)) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from meal where meal_name =  old_m_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update meal set meal_name = new_m_name where meal_name = old_m_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$  language plpgsql;

create or replace procedure update_meal_desc(m_name varchar(15), m_desc text) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from meal where meal_name =  m_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update meal set desc_meal = m_desc where meal_name = m_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$  language plpgsql;

create or replace procedure update_meal_htc(m_name varchar(15), m_htc text) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from meal where meal_name = m_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update meal set htc_meal = m_htc where meal_name = m_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$  language plpgsql;

create or replace procedure update_ingred_name(i_name varchar(25), new_i_name varchar(25)) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from ingredient where name_ingred =  i_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update ingredient set name_ingred = new_i_name where name_ingred = i_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$  language plpgsql;

create or replace procedure update_ingred_cost_unit(i_name varchar(25), new_cu int) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from ingredient where name_ingred =  i_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update ingredient set cost_unit_ingred = new_cu where name_ingred = i_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$  language plpgsql;

create or replace procedure update_ingred_nutval(i_name varchar(25), new_nutval int) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from ingredient where name_ingred = i_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update ingredient set nutval_ingred = new_nutval where name_ingred = i_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$  language plpgsql;

create or replace procedure update_ingred_id_cat(i_name varchar(25), id_cat_i int) as
$$
declare 
	res integer;
begin
	if (exists(select 1 from ingredient where name_ingred = i_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update ingredient set id_cat_ingred = id_cat_i where name_ingred = i_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$  language plpgsql;

create or replace procedure update_category_name(cat_name varchar(12), new_cat_name varchar(12)) as
$$
declare
	res integer;
begin
	if (exists(select 1 from category where name_category = cat_name)) then
		res := 1;
	else 
		res := 0;
	end if;
	if (res = 1) then 
		update category set name_category = new_cat_name where name_category = cat_name;
		commit;
	elseif (res = 0) then
		rollback;
	end if;
end;
$$ language plpgsql;
------------------------/PROCEDURES-----------------------

------------------------TRIGGERS------------------------
create or replace trigger change_meal_log after delete or insert or update on meal
	for each row 
		execute procedure ot_log_meal();
		
create or replace trigger change_ingredient_log after delete or insert or update on ingredient
	for each row 
		execute procedure ot_log_ingredient();
		
create or replace trigger change_category_log after delete or insert or update on category
	for each row 
		execute procedure ot_log_category();
------------------------/TRIGGERS-----------------------

-----------------------TYPES------------------------
create type custom_categories as (
	_category_name varchar(12)
);
create type custom_ingredients as (
	_name_ingred varchar(25),
	_cost_unit_ingred numeric,
	_nutval_ingred numeric
);
-----------------------/TYPES-----------------------

------------------------INDEXES------------------------
create index idx_meal 
	on meal(meal_name);

create index idx_category 
	on category(name_category);

create index idx_ingredient 
	on ingredient(name_ingred, cost_unit_ingred, nutval_ingred, id_cat_ingred);
	
create index idx_meal_log 
	on meal_log(status_ml, time_ml);
	
create index idx_ingredient_log 
	on ingredient_log(status_il, time_il);
	
create index idx_category_log 
	on category_log(status_cl, time_cl);
------------------------/INDEXES-----------------------

------------------------CURSORS------------------------

------------------------/CURSORS-----------------------

------------------------ROLES------------------------
/*default user*/
create user default_user with password 'user';

create role user_group;
grant user_group to default_user;
grant execute on function perform_ingredients to user_group;
grant execute on function get_meal_cost to user_group;
grant execute on function get_meal_nutval to user_group;
grant select on meal_list to user_group;
grant select on for_pi_func to user_group;
grant select on for_gmc_func to user_group;
grant select on for_gmn_func to user_group;


select * from get_meal_cost('Луковый хлеб');
select * from get_meal_nutval('Луковый хлеб');
select * from perform_ingredients('Луковый хлеб');
select * from meal_list;
/*admin*/
create user moder with password 'admin';

create role admin_group;
grant admin_group to moder with admin option;
grant all on sequence cat_ingredient_id_ing_cat_seq to admin_group;
grant all on sequence category_id_category_seq to admin_group;
grant all on sequence category_log_id_cl_seq to admin_group;
grant all on sequence ingredient_id_ingred_seq to admin_group;
grant all on sequence ingredient_log_id_il_seq to admin_group;
grant all on sequence meal_category_id_adj_mc_seq to admin_group;
grant all on sequence meal_id_meal_seq to admin_group;
grant all on sequence meal_ingredient_id_adj_mi_seq to admin_group;
grant all on sequence meal_log_id_ml_seq to admin_group;
grant all on table cat_ingredient to admin_group;
grant all on table category to admin_group;
grant all on table category_log to admin_group;
grant all on table ingredient to admin_group;
grant all on table ingredient_log to admin_group;
grant all on table meal to admin_group;
grant all on table meal_category to admin_group;
grant all on table meal_ingredient to admin_group;
grant all on table meal_log to admin_group;
grant all privileges on all functions in schema public to admin_group;
grant all privileges on all procedures in schema public to admin_group;
grant all privileges on type custom_categories to admin_group;
grant all privileges on type custom_ingredients to admin_group;
grant all privileges on database cookbook to admin_group;
grant all privileges on category_list to admin_group;
grant all privileges on for_gmn_func to admin_group;
grant all privileges on for_gmc_func to admin_group;
grant all privileges on for_pi_func to admin_group;
grant all privileges on ingredients_cat_ingreds to admin_group;
grant all privileges on ingredients_list to admin_group;
grant all privileges on meal_list to admin_group;
grant all privileges on multy_table_view_cm to admin_group;
grant all privileges on multy_table_view_im to admin_group;
grant all privileges on multy_table_view_mc to admin_group;
grant all privileges on multy_table_view_mi to admin_group;

------------------------/ROLES-----------------------

------------------------VIEWS------------------------
create view meal_list as
	select meal_name as mname, desc_meal as description from meal order by meal_name asc;

create view category_list as
	select name_category as cname from category order by name_category;

create view ingredients_list as
	select name_ingred as iname from ingredient;

create view multy_table_view_mc as
	select mtemp.meal_name as meal, count(*) as count_categories
	from meal mtemp
	join meal_category mctemp on mtemp.id_meal = mctemp.id_meal_mc
	group by mtemp.meal_name
	order by count_categories asc;
	
create view multy_table_view_mi as
	select meal_name as meal, count(*) as count_ingredients
	from meal 
	join meal_ingredient on id_meal = id_meal_mi 
	group by meal_name having meal_name not like '%no meal name%'
	order by count_ingredients asc;

create view multy_table_view_cm as
	select name_category as category, count(*) as count_category
	from category
	join meal_category
	on id_category = id_category_mc
	group by name_category having name_category not like '%undefined category name%'
	order by count_category asc;

create view multy_table_view_im as
	select name_ingred as ingredient, count(*) as count_ingredient
	from ingredient
	join meal_ingredient on id_ingred = id_ingredient_mi
	group by name_ingred having name_ingred not like '%no ingredient name%'
	order by name_ingred asc;

create view ingredients_cat_ingreds as
	select name_ingred, type_unit from ingredient join cat_ingredient on id_ing_cat = id_cat_ingred 
	order by name_ingred asc;
	
create view for_gmc_func as
	select meal_name as meal, (count_ingred_mi * cost_unit_ingred) as uni_on from meal, meal_ingredient, ingredient
	where id_meal = id_meal_mi and id_ingred = id_ingredient_mi;
	
create view for_gmn_func as
	select meal_name as meal, (count_ingred_mi * nutval_ingred) as uni_on from meal, meal_ingredient, ingredient
	where id_meal = id_meal_mi and id_ingred = id_ingredient_mi;
	
create view for_pi_func as
	select meal_name as meal, name_ingred as ingred, count_ingred_mi as count, type_unit as type 
	from ingredient, meal, cat_ingredient, meal_ingredient
	where id_meal_mi = id_meal 
	and id_ingred = id_ingredient_mi and id_cat_ingred = id_ing_cat;
------------------------/VIEWS-----------------------

-----------------------QUERIES------------------------
select * from meal_list;
select * from meal_log;
select * from category_log;
select id_meal, meal_name, desc_meal, htc_meal from meal;
select * from category;

insert into meal(meal_name) values ('test-meal');
update meal set meal_name='borsh' where id_meal=2;
delete from meal where id_meal = '3';
delete from meal_log where id_ml < 100;
select * from find_current_meal('test-meal');
select * from find_meal_categories('dw');
select * from multy_table_view_mc;
select * from cat_ingredient order by id_ing_cat;
select * from find_current_meal('Луковый хлеб');
call delete_category('К чаю');
select * from stat_meal_cat();
select * from stat_category_meal();
select * from find_meal_categories('Голубцы');
select * from ingredient;
select * from ingredient_log;
select * from ingredients_cat_ingreds;

call insert_new_category('Мясное');
call insert_new_category('Постное');
call insert_new_category('Традиционное');
call insert_new_category('Семейное');
call insert_new_category('Праздничное');
call insert_new_category('Быстрое');
call insert_new_category('Первое');
call insert_new_category('Второе');
call insert_new_category('Десерт');
call insert_new_category('Холодное');
call insert_new_category('Горячее');
call insert_new_category('К чаю');

select id_meal, meal_name from meal;
select id_ingred, name_ingred, type_unit from ingredient join cat_ingredient on id_ing_cat = id_cat_ingred;
select * from ingredient;  

insert into cat_ingredient(type_unit) values 
('шт.'),
('гр.'),
('ст.л.'),
('ч.л.'),
('мл.'),
('веточка(и)'),
('кг'),
('л'),
('веточка(ек)'),
('щепотка');
update cat_ingredient set type_unit = 'зубчик(ов)' where id_ing_cat = 9;
insert into meal(meal_name, desc_meal, htc_meal) values
('Луковый хлеб','Луковый хлеб привлечет на кухню ваших домочадцев уже в процессе выпекания в духовке: дивный аромат никого не оставит равнодушным.',
 'Приготовить опару для хлеба. Смешать дрожжи и 1 ст. л. муки. Влить в большую миску теплое молоко, добавить соль и сахар, тщательно перемешать до полного растворения. Всыпать смесь муки и дрожжей, размешать. Миску накрыть и поставить в теплое место на 20 мин. 
 Лук для хлеба очистить, нарезать кубиками. Обжарить лук в разогретом растительном масле до золотистого цвета, 7 мин. Добавить по щепотке соли и сахара, перемешать и дать остыть.  
 Добавить в опару чуть теплый обжаренный лук, яйцо, сметану и половину подсолнечного масла. Тщательно перемешать кулинарной лопаткой или большим венчиком. Постепенно всыпая в опару просеянную муку, вымесить мягкое тесто. 
 В конце добавить 1 ст. л. оставшегося масла. Тесто накрыть и оставить подниматься. Через 30 мин. обмять и оставить еще на 15 мин. Еще раз обмять луковое тесто. Скатать его в шар и положить на противень, застеленный пергаментом. Накрыть полотенцем и дать постоять 15 мин. Придать тесту форму каравая. 
 Оставшееся подсолнечное масло подогреть и смазать им поверхность хлеба. Сделать сверху 3–4 надреза. Поставить в разогретую до 200 °С духовку на 30 мин. Вынуть хлеб из духовки, накрыть полотенцем и дать постоять 1 ч. '),
('Cалат Мимоза','Простой салат Мимоза вызывает приятные воспоминания из детства, когда мама или бабушка готовила этот кулинарный шедевр на праздничный, чаще всего, новогодний стол.',
 'Подготовьте ингредиенты для простого салата Мимоза. Картофель и морковь тщательно вымойте щеткой и отварите в мундире до готовности. Воду слейте. Корнеплодам дайте полностью остыть. 
 Яйца для салата Мимоза сварите вкрутую, затем охладите проточной водой. Очистите и разделите на белки и желтки. Белки разомните вилкой или мелко порубите.
 Лосось выложите из банки и разомните вилкой, удаляя крупные косточки. Зеленый лук вымойте, хорошо обсушите бумажным полотенцем, затем нарежьте маленькими колечками.
 Картофель и морковь очистите, натрите по отдельности на крупной терке. Выложите ингредиенты слоями в следующем порядке: картофель, морковь, лук, майонез, белок, рыба, желток, майонез, картофель, морковь, лук, майонез, белок, рыба, майонез. Посыпьте простой салат Мимозу раскрошенным желтком и зеленым луком.'),
('Голубцы','Голубцы из свежей капусты раньше готовили едва ли не в каждой семье, чаще всего по выходным.',
 'У капусты вырезать кочерыжку и снять два верхних поврежденных листа. В кастрюле вскипятить воду и опустить в нее кочан (вода должна покрывать его полностью). Варить свежую капусту 10–15 мин (листья должны сохранить целостность). Достать из воды, остудить.
 Тем временем мелко порубить по одной луковице для фарша голубцов и для соуса, а также зелень и зубчики чеснока. Морковь нарезать мелкими брусками и нашинковать кубиками (можно натереть ее на терке).
 Помидоры крест-накрест надрезать острым ножом кожицу, опустить на 30 сек. в крутой кипяток от капусты. Вынуть шумовкой, подставить под холодную воду. С помощью ножа снять шкурку. Помидоры разрезать, удалить плодоножку и семена, нарезать кубиками.
 Говядину и свинину для фарша голубцов нарезать кубиками. Затем пропустить через мясорубку. Некоторые хозяйки пропускают через мясорубку и лук. Но тогда получается более плотный фарш, который подходит для котлет. Для голубцов лук, наоборот, служит своеобразным разрыхлителем начинки. 
 Сварить рис для голубцов. Если он пропаренный, варить в кипящей воде около 10 мин. Затем остудить. Если непропаренный, сначала промыть и варить в большом количестве кипящей подсоленной воды (1:8) около 20 мин. Откинуть на дуршлаг, промыть холодной водой. Соединить готовый рис, мясной фарш, лук и зелень.
 Мясной фарш, рис, лук и зелень перемешать. Посолить, лучше использовать йодированную крупную соль. Поперчить по вкусу. Добавить чашку питьевой холодной воды, так как рис впитывает много влаги. Перемешать. Но не отбивать, как это делают для котлет, а то рис "разобьется". Фарш голубцов должен быть эластичным.
 Капусту разобрать на листья. Внутренние жесткие, маленькие можно использовать для щей. У остальных срезать утолщение. Его также можно разбить тупой стороной ножа. Или, если капуста была большая, крупные листы разрезать вдоль по этому утолщению.
 Положить порцию фарша на внутреннюю сторону в основание капустного листа. В этом случае будет проще сформировать голубец. Начинку на листе завернуть один раз, подвернуть края листа, снова завернуть. Так как все листья разные по размеру, после того как голубец сформирован, срезать излишки листа.
 Влить в разогретую сковороду оливковое масло. Обжаривать голубцы до появления золотистого цвета с двух сторон - по 3 мин. каждую. Для того чтобы жир не брызгал в разные стороны, а голубцы равномерно прогрелись, накрыть сковороду крышкой и готовить еще 2 мин. Голубцы из свежей капусты переложить в форму для запекания.
 На той же сковороде обжарить для соуса лук и морковь до золотистого цвета, добавить чеснок. На сковороду, помешивая, влить сливки. Когда они закипят, добавить помидоры и зелень. Посолить. Помешивая, выпарить часть жидкости, чтобы соус загустел. Голубцы в форме залить соусом, посыпать тертым сыром. Запекать до появления сырной корочки в течение 20 мин при 180°C.'),
('Говяжьи котлеты','Наши котлеты из говядины порадуют истинных гурманов, которые на первое место ставят вкусовые свойства.',
 'Приготовить фарш для котлет. С хлеба срезать корку. Половину батона разломать на несколько частей и замочить в молоке. Вторую половину отложить для панировки котлет.
 Когда хлеб размокнет, несильно отжать. Мясо вымыть и провернуть через мясорубку вместе с замоченным хлебом. Лук и чеснок очистить, измельчить. Зелень вымыть, обсушить и мелко нарезать. Бекон порезать кусочками.
 Обжарить бекон на разогретой сковороде со сливочным маслом до образования шкварок, 10 мин. Добавить лук, чеснок и зелень и обжаривать 2 мин. Смешать с говяжьим фаршем.
 Добавить в фарш из говядины яйца, соль и молотый перец по вкусу. Еще раз тщательно перемешать. Прикрыть фарш полотенцем и оставить на 15 минут при комнатной температуре.
 Сформовать котлеты. Их размер и форма могут быть любыми. Каждую вылепленную котлету взять в руки и месить несколько минут, сильно ударяя по фаршу ладонями. 
 Оставшийся хлеб размолоть в блендере или натереть на мелкой терке. Получится так называемая белая панировка. При обжаривании она не дает котлетам развалиться и вместе с тем не образует жесткой корочки. Обвалять каждую котлету в белой панировке. В сковороде разогреть растительное масло. Еще раз обвалять котлеты из говядины в панировке и обжаривать по 4 мин. с каждой стороны. Уменьшить огонь до минимума. Накрыть сковороду крышкой и готовить 10 мин.'),
('Болгарское лечо','Вкус этого болгарского лечо с морковью нам кажется наиболее гармоничным и сбалансированным.',
 'Помидоры для болгарского лечо вымыть, порезать произвольными кусками и пропустить через мясорубку. Переложить в кастрюлю, довести до кипения, затем уменьшить огонь и готовить, время от времени помешивая, 1 час.
 Лук и морковь для лечо очистить. Лук нарезать полукольцами, морковь – соломкой. Разогреть в сковороде 2 ст. л. растительного масла, быстро обжарить овощи. Уменьшить огонь и готовить, помешивая, 10 мин.
 Перец для болгарского лечо с морковью вымыть, разрезать вдоль на 4 части, удалить сердцевину. В широкой кастрюле вскипятить воду, опустить перцы на 2–3 мин. Воду слить.
 В кипящую томатную смесь добавить уксус, сахар, растительное масло и соль. Выложить лук с морковью и перцы, перемешать. Готовить болгарское лечо с морковью 15 мин. на среднем огне, периодически помешивая. 
 Горячее лечо снять с огня и сразу же разложить по сухим стерилизованным банкам. Герметично закрыть с помощью специальной машинки.
 Перевернуть банки с болгарским лечо вверх дном, укутать толстым пледом или поместить под теплое одеяло и оставить на 8–10 часов. Поставить на хранение в темное прохладное место.'),
('Салат Оливье','Оливье с курицей — одна из самых любимых разновидностей этого знаменитого советско-российского праздничного салата, обладающая, на наш взгляд, более нежным и деликатным вкусом.',
 'Подготовьте ингредиенты для салата Оливье. Куриное филе поместите в небольшую кастрюлю, залейте горячей водой, доведите до кипения и снимите пену. Посолите по вкусу и варите 45 минут. Дайте остыть.
 Яйца для Оливье вымойте, сложите в ковшик и залейте холодной водой. Поставьте на огонь и доведите до кипения. Варите 10 минут, затем охладите проточной водой и очистите. 
 Картофель тщательно вымойте щеткой, залейте горячей водой и доведите до кипения. Варите 30 минут (он должен стать мягким, но не разваливаться). Дайте остыть и очистите. 
 Остывшее куриное филе, лук, яйца, огурцы, ветчину и картофель для Оливье нарежьте кубиками одинакового размера. Так ингредиенты лучше пропитаются майонезом, и салат будет вкуснее. 
 Все подготовленные ингредиенты салата Оливье с курицей сложите в большую миску. Добавьте консервированный зеленый горошек и перемешайте большой ложкой. 
 Добавьте майонез, посолите и поперчите по вкусу. Снова перемешайте ложкой. Выложите в салатник и украсьте листочками петрушки, укропа или нарезанным колечками зеленым луком.'),
('Суп Харчо','Едва ли не у каждой грузинской хозяйки есть свой вариант харчо, у каждой испанской —  паэльи, а у итальянской — того же ризотто.',
 'Подготовьте мясо для харчо. Вымойте говяжью грудинку или рульку и поместите в кастрюлю. Залейте холодной водой и доведите до кипения. Снимите пену и варите 2 часа при слабом кипении.
 Получившийся бульон для супа процедите через мелкое сито в чистую кастрюлю. Мясо отделите от кости, крупно нарежьте. Добавьте в бульон, поставьте на огонь и доведите до кипения.
 Всыпьте в кипящий бульон рис. Варите 5 минут. Лук очистите и порубите. Помидоры вымойте и нарежьте маленькими кубиками. Добавьте в готовящийся суп и варите 5 минут.
 Положите в суп томатную пасту, молотый кориандр и хмели-сунели. Посолите и поперчите по вкусу. Перемешайте и варите на слабом огне без крышки около 10 минут.
 Кинзу и петрушку вымойте, обсушите и мелко нарежьте. Зубчики чеснока очистите и порубите. Добавьте в кастрюлю с харчо и варите 3 минуты. Оставьте на горячей выключенной плите. Через 10 минут разлейте по тарелкам.'
);
insert into meal_category(id_meal_mc, id_category_mc)
values (1, 3),(1, 5),(2, 4),(2, 5),(2, 6),
(2, 7),(2, 11),(3, 1),(3, 4),(3, 5),(3, 7),(3, 9),
(3, 12),(4, 1),(4, 5),(4, 9),(4, 12),(5, 4),(5, 5),
(6, 1),(6, 4),(6, 5),(6, 6),(6, 11),(7, 1),(7, 5),
(7, 8),(7, 12);

insert into ingredient(name_ingred, cost_unit_ingred, nutval_ingred, id_cat_ingred)
values ('Яйцо', 7, 157, 1),('Масло растительное', 0.1, 120, 3),
('Лук репчатый', 14.4, 41, 1),('Молоко', 0.1, 522, 5),
('Дрожжи сухие', 0.127, 325, 2),('Сметана', 5, 31, 3),
('Масло подсолнечное', 0.75, 539, 5),('Соль', 0.1, 0.1, 4),
('Мука', 37.5, 850, 2),('Сахар', 0.15, 0.1, 3),
('Картофель', 5, 82, 1),('Крупная морковь', 7, 35, 1),
('Лосось в собственном соку', 200, 383, 1),('Зеленый лук', 0.89, 1, 2),
('Легкий майонез', 0.25, 3, 2),('Морковь', 7, 35, 1),
('Болгарский перец', 45, 20, 1),('Лук репчатый', 72, 400, 7),
('Уксус 6%', 6, 18, 5),('Помидоры', 54, 200, 7),
('Зелень тимьяна', 0.28, 15, 3),('Говяжий фарш', 0.77, 3.32, 2),
('Белый хлеб', 49, 700, 1),('Большая луковица', 3, 40, 1),
('Чеснок', 0.2, 30, 9),('Бекон', 0.08, 270, 2),('Сливочное масло', 1.5, 108, 3),
('Зелень петрушки', 0.4, 5, 3),('Зелень укропа', 0.35, 6, 3),
('Куриное филе', 49, 113, 1),('Маринованные огурцы', 9, 11, 1),
('Вареная ветчина', 1, 2.05, 2),('Зеленый горошек', 0.2, 0.55, 2),
('Майонез', 0.12, 6.8, 2),('Черный перец', 0.1, 0.1, 10),
('Свиная шея', 0.45, 37.2, 2),('Масло оливковое', 0.24, 8.84, 5),
('Сливки 33%', 0.38, 1.96, 5),('Сыр', 1.6, 4.02, 2),
('Свежая говядина', 0.35, 2.5, 2),('Средняя морковь', 4, 82, 1),
('Крупный помидор', 5, 100, 1),
('Рис', 0.15, 1.3, 2),('Зеленая капуста', 14, 56, 1),
('Говяжья грудинка', 580, 3000, 7),('Питьевая вода', 30, 0.1, 8),
('Крупная репч. луковица', 10, 120, 1),('Помидор ср. размера', 6, 60, 1),
('Томатная паста', 0.1, 0.82, 2),('Молотый кориандр', 0.5, 15, 4),('Хмели-сунели', 0.75, 17, 4),
('Кинза', 1, 13, 6),('Петрушка', 0.7, 10, 6);
update ingredient set nutval_ingred = 5.22 where name_ingred = 'Молоко';
update ingredient set name_ingred='Луковица' where id_ingred = 54;
update ingredient set cost_unit_ingred=0.075 where name_ingred = 'Мука';
update ingredient set nutval_ingred=3.25 where name_ingred = 'Дрожжи сухие';
update ingredient set nutval_ingred=0.539 where name_ingred = 'Масло подсолнечное';
update ingredient set nutval_ingred=2.7 where name_ingred = 'Бекон';
update ingredient set nutval_ingred=1.08 where name_ingred = 'Сливочное масло';
update ingredient set nutval_ingred=0.85 where name_ingred = 'Мука';
update ingredient set nutval_ingred=0.522 where name_ingred = 'Молоко';
update ingredient set nutval_ingred=0.372 where name_ingred = 'Свиная шея';

insert into meal_ingredient(id_meal_mi, id_ingredient_mi, count_ingred_mi) values
(1, 52, 1),(1, 53, 3),(1, 54, 3),(1, 55, 250),(1, 56, 8),(1, 57, 2),
(1, 58, 60),(1, 59, 1),(1, 60, 750),(1, 61, 1),
(2, 62, 1),(2, 63, 1),(2, 52, 3),(2, 64, 1),(2, 65, 30),(2, 66, 200),
(3, 87, 200),(3, 54, 2),(3, 88, 100),(3, 89, 400),(3, 104, 1),
(3, 80, 1),(3, 76, 3),(3, 90, 100),(3, 59, 1),(3, 86, 1),(3, 91, 300),(3, 92, 1),
(3, 93, 2),(3, 95, 2),(3, 94, 200),
(4, 72, 1),(4, 73, 500),(4, 74, 1),(4, 55, 500),(4, 75, 1),
(4, 76, 2),(4, 52, 2),(4, 77, 50),(4, 78, 1),(4, 79, 1),
(4, 80, 1),(4, 59, 1),(4, 86, 1),(4, 53, 2),
(5, 59, 1.5),(5, 67, 7),(5, 53, 8),(5, 68, 11),
(5, 69, 1),(5, 61, 8),(5, 70, 125),(5, 71, 3),
(6, 81, 3),(6, 62, 6),(6, 52, 6),(6, 54, 2),(6, 82, 4),(6, 83, 100),
(6, 84, 400),(6, 85, 200),(6, 59, 1),(6, 86, 1),(6, 104, 1),
(7, 96, 1),(7, 97, 3),(7, 94, 150),(7, 98, 2),(7, 99, 4),(7, 100, 100),
(7, 101, 1),(7, 102, 1),(7, 103, 4),(7, 104, 4),(7, 76, 6),(7, 59, 1),(7, 86, 1);

select * from find_meal_ingredients('Луковый хлеб');
select * from perform_ingredients('Луковый хлеб');
select * from get_meal_cost('Cалат Мимоза');
select * from get_meal_nutval('Суп Харчо');

select name_ingred, nutval_ingred, count_ingred_mi,type_unit, count_ingred_mi*nutval_ingred from ingredient, cat_ingredient,meal_ingredient
where id_cat_ingred = id_ing_cat and id_meal_mi=3 and id_ingred = id_ingredient_mi;

select meal_name from meal where id_meal=7;

------------------------/QUERIES-----------------------


