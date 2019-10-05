SELECT
  Now();

select now()
  from dual;

-- 2.4 表的创建
CREATE TABLE person
(
  person_id SMALLINT UNSIGNED,
  first_name VARCHAR(20),
  last_name VARCHAR(20),
  -- gender CHAR(1) check(gender IN ('M', 'F')),
  gender enum('M', 'F'),
  birth_date DATE,
  street VARCHAR(30),
  city VARCHAR(20),
  state VARCHAR(20),
  country VARCHAR(20),
  postal_code varchar(20),
  
  constraint pk_person primary key (person_id)
);
alter table person modify person_id smallint unsigned auto_increment;

desc person;

create table favorite_food
(
	person_id smallint unsigned,
    food varchar(20),
    constraint pk_favorite_foot primary key (person_id, food),
    constraint fk_fav_food_person_id foreign key (person_id) references person(person_id)
);

DESC favorite_food;

-- 2.5 操作与修改表person
-- 2.5.1 Insert
insert into person
(person_id, first_name, last_name, gender, birth_date)
values
(null, 'William', 'Turner', 'M', '1972-05-27');

SELECT person_id, first_name, last_name, birth_date from person;

SELECT person_id, first_name, last_name, birth_date
from person
where person_id = 1;

SELECT person_id, first_name, last_name, birth_date
from person
where last_name = 'Turner';

insert into favorite_food (person_id, food) values (1, 'pizza');
insert into favorite_food (person_id, food) values (1, 'cookie');
insert into favorite_food (person_id, food) values (1, 'nachos');

SELECT food FROM favorite_food
where person_id = 1
order by food;


INSERT INTO person
(person_id, first_name, last_name, gender, birth_date, street, city, state, country, postal_code)
values
(null, 'Susan', 'Smith', 'F', '1975-11-02', '23 Maple St.', 'Arlington', 'VA', 'USA', '20220');

select person_id, first_name, last_name, birth_date from person;


-- 更新数据
update person set
	street = '1225 Tremont St.',
	city  = 'Boston',
	state = 'MA',
	country = 'USA',
	postal_code = '02138'
where person_id = 1;


-- 删除数据
delete from person where person_id = 2;


-- 2.6 导致错误的语句
-- 2.6.1 主键不唯一
insert into person
(person_id, first_name, last_name, gender, birth_date)
values
(1, 'Charles', 'Fulton', 'M', '1968-01-15');

-- 2.6.2 不存在的外键
insert into favorite_food 
(person_id, food)
values 
(999, 'lasagna');


-- 2.6.3 列值不合法
update person set
	gender = 'Z'
where person_id = 1;


-- 2.6.4 无效的日期转换
update person set
	birth_date = 'DEC-21-1980'
where person_id = 1;

-- 使用str_to_date
update person set
	birth_date = str_to_date('DEC-21-1980', '%b-%d-%Y')
where person_id = 1;


-- 删除表
drop table favorite_food;
drop table person;

