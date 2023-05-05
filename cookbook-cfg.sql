--create database cookbook;

------------------------TABLES------------------------
create table meal(
	id_meal serial not null primary key,
	desc_meal text not null default 'no description',
	htc_meal text not null default 'no how to  eat expression'
);

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
	id_changed_meal int not null default -1,
	constraint fk_ml_meal foreign key(id_changed_meal) references meal(id_meal)
		on delete set default
);

create table category_log(
	id_cl serial not null primary key,
	status_cl varchar(1) not null check (status_cl in ('i', 'u', 'd')),
	time_cl timestamp not null,
	id_changed_category int not null default -1,
	constraint fk_ml_category foreign key(id_changed_category) references category(id_category)
		on delete set default
);

create table ingredient_log(
	id_il serial not null primary key,
	status_il varchar(1) not null check (status_il in ('i', 'u', 'd')),
	time_il timestamp not null,
	id_changed_ingredient int not null default -1,
	constraint fk_ml_ingredient foreign key(id_changed_ingredient) references ingredient(id_ingred)
		on delete set default
);
------------------------/TABLES-----------------------

------------------------FUNCTIONES------------------------

------------------------/FUNCTIONES-----------------------

------------------------PROCEDURES------------------------

------------------------/PROCEDURES-----------------------

------------------------TRIGGERS------------------------

------------------------/TRIGGERS-----------------------

------------------------TYPES------------------------

------------------------/TYPES-----------------------

------------------------INDEXES------------------------

------------------------/INDEXES-----------------------

------------------------VIEWS------------------------

------------------------/VIEWS-----------------------

-----------------------QUERIES------------------------

------------------------/QUERIES-----------------------