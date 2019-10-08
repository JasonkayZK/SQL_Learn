-- 十三章 索引与约束
-- 13.1 索引
-- 索引是一种以特定的顺序保存的专用表
-- 1. 不包含实体中所有数据
-- 2. 用于定位表中的列, 并描述这些行的物理位置信息


-- 13.1.1 创建索引
-- 例: 在department表添加索引, 加速任何指定全部或者部分部门名字的查询, update和delete
-- MySQL将索引看作表的可选部件, 必须使用alter table命令添加或者删除索引
alter table department
add index dept_name_idx (name);

-- 查看索引
-- mysql自动为主键生成索引(索引名primary)
show index from department;


-- 删除索引
alter table department
drop index dept_name_idx;



-- 唯一索引
-- 1. 提供常规索引的所有好处;
-- 2. 限制索引列出现重复值!
-- 创建唯一索引
alter table department
add unique dept_name_idx (name);


-- 试图添加Operations部门将报错!
insert into department (dept_id, name)
values(999, 'Operations');



-- 多列索引
-- 例: 为雇员的姓, 名添加索引
-- 此时指定姓名, 指定姓氏(lname)都可以加速
-- 但是指定名不可以!(fname)
-- 必须先经过第一索引!!!
alter table employee
add index emp_names_idx (lname, fname);



-- 13.1.2 索引类型
-- B树索引(平衡树索引)[默认索引类型]: 处理包含许多不同值的列 - 客户姓名

-- 位图索引: 少量的值占据了大量的行 - 客户喜欢的产品(一共8种产品)
-- 列中存储的值的数目相对的行数太高时, 索引失败
-- 永远不要为主键创建位图索引!!!(太多不同的行)


-- 文本索引
-- 允许用户在文档中查找单词或者短语
-- 1. 全文索引: MySQL中仅MyISAM可以使用全文索引



-- 13.1.3 如何使用索引
-- 1. 利用索引快速定位特定表中的行, 之后在访问相关表提取用户请求的补充信息
select emp_id, fname, lname
from employee
where emp_id in (1,3,9,15);


-- 2. 如果索引包含满足查询的所有内容, 则服务器不必访问相关表了!
-- 	查询优化器使用不同的索引处理相同的查询
select cust_id, sum(avail_balance) tot_bal
from account
where cust_id in (1,5,9,11)
group by cust_id;


-- 使用explain请求服务器显示查询的执行计划而不执行查询!
explain select cust_id, sum(avail_balance) tot_bal
from account
where cust_id in (1,5,9,11)
group by cust_id;


-- 给cust_id和avail_balance添加新的索引acc_bal_idx;
alter table account
add index acc_bal_idx (cust_id, avail_balance);

-- 再次查询
-- 此时优化器预期只需要8行, 而非24行, 因为用到了新的索引!
-- 且不再需要account表, 而直接使用附加列的索引即可
-- 只要索引包含查询需要的所有列, 服务器就可以把索引当做表一样使用!!!
explain select cust_id, sum(avail_balance) tot_bal
from account
where cust_id in (1,5,9,11)
group by cust_id;



-- 13.1.4 索引的不足
-- 每个索引实际上是一个特殊类型的表, 每次添加或者删除行时
-- 表中所有索引必须被修改!
-- 而更新行时, 受影响的列的索引也必须被修改!
-- 1. 所以, 索引越多, 服务器就要做更多的工作来保证所有索引树最新!
-- 2. 索引需要磁盘空间, 
-- 3. 索引需要管理员消耗更多精力去管理
-- 所以
-- 1. 仅当出现清晰需求时添加索引;
-- 2. 有特殊目的需要索引, 可以先添加, 然后运行, 最后删除索引;

-- 默认策略:
-- 1. 所有主键被索引;
-- 2. 所有外键被索引;
-- 3. 索引那些被频繁检索的列;




-- 13.2 约束
-- 1. 主键约束: 标志一列或者多列, 并保证其值在表内的唯一性;

-- 2. 外键约束: 限制一列或者多列中的值必须被包含在另一个表的外键列中, 
-- 	并且在级联更新或者级联删除规则建立后, 也可以限制其他表中的可用值!

-- 3. 唯一约束: 保证表内的唯一性

-- 4. 检查约束: 限制一列的可用值范围

-- 有了合适的主键和外键, 服务器在试图修改或者删除被其他表引用的数据时, 要么抛出错误, 要么将改变传播到其他表!
-- MySQL中必须使用InnoDB


-- 13.2.1 创建约束
-- 通过create table语句同时创建
create table product
 (product_cd varchar(10) not null,
  name varchar(50) not null,
  product_type_cd varchar(10) not null,
  date_offered date,
  date_retired date,
  constraint fk_product_type_cd foreign key (product_type_cd) 
    references product_type (product_type_cd),
  constraint pk_product primary key (product_cd)
 );


-- 通过alter table指定主键和外键约束
alter table product
add constraint pk_product primary key (product_cd);

alter table product
add constraint fk_product_type_cd foreign key (product_type_cd) 
    references product_type (product_type_cd);


-- 删除主键和外键约束: add -> drop
alter table product
drop primary key;

alter table product
drop foreign key fk_product_type_cd;



-- 13.2.2 约束与索引
-- 创建约束有时可能导致自动创建索引!
-- MySQL中:
-- 主键约束: 生成唯一索引
-- 外键约束: 生成索引
-- 唯一约束:	生成唯一索引


-- 13.2.3 级联索引
-- 有了外键约束之后, 试图插入的新行或者修改行而导致父表中的外键列无可匹配值, 则会抛出一个错误!
select product_type_cd, name
from product_type;

select product_type_cd, product_cd, name
from product
order by product_type_cd;


-- 试图将product表中的product_type_cd更改为product_type表中不存在的值
update product
set product_type_cd = 'XYZ'
where product_type_cd = 'LOAN';


-- 试图更改product_type表中的父行为XYZ
-- 此时仍然报错, 因为product表中存在子行的product_type_cd列值为LOAN
-- 这是默认外键做法, 也可以设定服务器将变化修改到所有子行!
update product_type
set product_type_cd = 'XYZ'
where product_type_cd = 'LOAN';


-- 级联更新: on update cascade
alter table product
drop foreign key fk_product_type_cd;

alter table product
add constraint fk_product_type_cd foreign key (product_type_cd)
	references product_type (product_type_cd)
	on update cascade;

-- 执行成功!
update product_type
set product_type_cd = 'LOAN'
where product_type_cd = 'XYZ';

-- 变化已经传播!
select product_type_cd, name
from product_type;

select product_type_cd, product_cd, name
from product
order by product_type_cd;


-- 指定级联删除
alter table product
add constraint fk_product_type_cd foreign key (product_type_cd)
	references product_type (product_type_cd)
	on update cascade
    on delete cascade;




-- --------------------------------------------
-- Homework
-- 1. 修改 account表,使客户不能在任何产品中拥有多个账户(最多一个)
alter table account
add unique account_unq (cust_id, product_cd);





-- 2. 为transaction表生成多列索引,该索引可用于如下两个查询。
SELECT txn_date, account_id, txn_type_cd, amount
FROM transaction
WHERE txn_date > cast('2008-12-31 23: 59: 59' as datetime);

SELECT txn_date, account_id, txn_type_cd, amount
FROM transaction
WHERE txn_date > cast('2008-12-31 23: 59: 59' as datetime)
	AND amount < 1000;

create index txn_idx
on transaction (txn_date, txn_type_cd);

alter table transaction
drop index txn_idx;

explain SELECT txn_date, account_id, txn_type_cd, amount
FROM transaction
WHERE txn_date > cast('2008-12-31 23: 59: 59' as datetime);


explain SELECT txn_date, account_id, txn_type_cd, amount
FROM transaction
WHERE txn_date > cast('2008-12-31 23: 59: 59' as datetime)
	AND amount < 1000;

