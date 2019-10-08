-- 十四章. 视图
-- 程序一般都是在不断完善私有细节的同时公开一个公共接口, 
-- 这样未来在不影响终端客户的情况下, 可修改设计!


-- 14.1 什么是视图
-- 简单的数据'查询'机制, 视图不涉及数据存储! 
-- 可以通过select语句创建视图, 然后将这个查询保存起来供其他用户使用!
-- 而其他用户在使用这个视图时就像自己在直接查询数据!
-- 例: 读者想要部分掩盖customer表中的个人识别号码, 可先定义一个customer_vw的视图:
create view customer_vw
(cust_id, fed_id, cust_type_cd, address, city, state, zipcode)
as select
	cust_id, 
    concat('ends in ', substr(fed_id, 8, 4)) fed_id,
    cust_type_cd,
    address,
    city,
    state,
    postal_code
from customer;

-- 数据库服务器只是简单存储视图的定义为将来使用. 
-- 如果不执行查询, 就不会检索或者存储任何数据
-- 一旦视图被创建, 用户可以把它当做一个表来查询
-- 真正执行的是两者合并之后创建的新查询!
select cust_id, fed_id, cust_type_cd
from customer_vw;

select cust_id,
	concat('ends in ', substr(fed_id, 8, 4)) fed_id,
    cust_type_cd
from customer;

-- 查询视图中的可用列
describe customer_vw;


-- 可以使用select任何子句
select cust_type_cd, count(*)
from customer_vw
where state = 'MA'
group by cust_type_cd
order by 1;


-- 可以将视图连接到其他表或者视图
select cv.cust_id, cv.fed_id, b.name
from customer_vw cv inner join business b
	on cv.cust_id = b.cust_id;



-- 14.2 为什么使用视图
-- 14.2.1 数据安全
-- 表中可能包含敏感信息: 
-- 	保持表的私有权限(不向用户授予select), 同时创建多个视图, 
-- 也可以在视图添加where子句, 限制用户只能访问那些被允许的行!
create view business_customer_vw
(cust_id, fed_id, cust_type_cd, address, city, state, zipcode)
as 
select
	cust_id, 
    concat('ends in ', substr(fed_id, 8, 4)) fed_id,
    cust_type_cd,
    address,
    city,
    state,
    postal_code
from customer
where cust_type_cd = 'B';


-- 只能够访问企业客户
select cust_type_cd, count(*)
from business_customer_vw
where state = 'MA'
group by cust_type_cd
order by 1;


-- 14.2.2 数据聚合
-- 数据像已经被预聚合并存储在数据库
-- 例: 每月生成报表展示账户数目和每个客户的储蓄总额
create view customer_totals_vw
(
	cust_id,
    cust_type_cd,
    cust_name,
    num_accounts,
    tot_deposits
)
as 
select c.cust_id, c.cust_type_cd,
	case
		when c.cust_type_cd = 'B' 
			then (
				select b.name
                from business b
                where b.cust_id = c.cust_id
            )
		else (
			select concat(i.fname, ' ', i.lname)
            from individual i
            where i.cust_id = c.cust_id
        )
	end cust_name,
    sum(
		case 
			when a.status = 'ACTIVE' then 1 
            else 0 
		end
	) num_accounts,
    sum(
		case 
			when a.status = 'ACTIVE' then a.avail_balance
            else 0
		end
    ) tot_deposits
from customer c inner join account a
	on c.cust_id = a.cust_id
group by c.cust_id, c.cust_type_cd;


select * from customer_totals_vw;


-- 使用视图创建新表, 并最终更新视图定义
create table customer_totals
as 
select * from customer_totals_vw;

create or replace view customer_totals_vw
(
	cust_id,
    cust_type_cd,
    cust_name,
    num_accounts,
    tot_deposits
)
as
select 
	cust_id,
    cust_type_cd,
    cust_name,
    num_accounts,
    tot_deposits
from customer_totals;




-- 14.2.3 隐藏复杂性
-- 例: 每月创建一个报表展示雇员数目, 活跃账户数目和每个分行的交易总数
create view branch_activity_vw
(
	branch_name,
    city,
    state,
    num_employees,
    num_active_accounts,
    tot_transactions
)
as 
select b.name, b.city, b.state,
	(
		select count(*)
        from employee e
        where e.assigned_branch_id = b.branch_id
    ) num_emps,
    (
		select count(*)
        from account a
        where a.status = 'ACTIVE' and a.open_branch_id = b.branch_id
    ) num_active_accounts,
    (
		select count(*)
        from transaction t
        where t.execution_branch_id = b.branch_id
    ) tot_transactions
from branch b;

select * from branch_activity_vw;



-- 14.2.4 连接分区数据
-- 例: 当交易表过大而分表为: transaction_cur, transaction_his
create view transaction_vw
(
	txn_date,
    account_id,
    txn_type_cd,
    amount,
    teller_emp_id,
    execution_branch_id,
    funds_avail_date
)
as
select 
	txn_date,
    account_id,
    txn_type_cd,
    amount,
    teller_emp_id,
    execution_branch_id,
    funds_avail_date
from transaction_his
union all
select 
	txn_date,
    account_id,
    txn_type_cd,
    amount,
    teller_emp_id,
    execution_branch_id,
    funds_avail_date
from transaction_cur; 



-- 14.3 可更新的视图
-- 在用户遵守特定规则的前提下通过视图修改数据
-- 1. 没有使用聚合函数
-- 2. 视图没有使用group by或者having
-- 3. select或者from子句中不存在子查询, 并且where子句中的任何子查询都不引用from子句中的表
-- 4. 视图没有使用union, union all或者distinct
-- 5. from子句中包括不止一个表或可更新视图
-- 6. 如果有不止一个表或者视图, 那么from子句只使用内连接


-- 14.3.1 更新简单视图
update customer_vw
set city = 'Woooburn'
where city = 'Woburn';

select distinct city from customer;

-- 无法更改fed_id列, 因为是由表达式生成的!
update customer_vw
set city = 'Woburn', fed_id = '9999999999'
where city = 'Woooburn';


-- 包含导出列的视图不能用于插入数据
insert into customer_vw
(cust_id, cust_type_cd, city)
values
(9999, 'I', 'Worcester');



-- 14.3.2 更新复杂视图
-- 例: 通过商业客户视图更新
update business_customer_vw
set zipcode = '99999'
where cust_id = 10;

update business_customer_vw
set address = '99999'
where cust_id = 10;

-- 试图在单个语句中更新两个表的列, 可能会报错
-- 因为无法在一条语句修改两个基础表!
update business_customer_vw
set zipcode = '99999', address = '99999'
where cust_id = 10;


-- 插入数据也要求来自于同一个表才允许插入!



-- --------------------------------------------------
-- Homework
-- 1. 创建一个视图,查询employee表并生成下主管-雇员表, 要求不使用where
create view super_emp_vw
(supervisor_name, employee_name)
as
select 
	concat(s.fname, ' ', s.lname) sup_name,
    concat(e.fname, ' ', e.lname) emp_name
from employee e left outer join employee s
	on e.superior_emp_id = s.emp_id;

-- drop view super_emp_vw; 

select * from super_emp_vw;




-- 2. 除了查询各分行开立的所有账户的余额,银行总裁还想要一张显示各分行名字及城市的报表。
-- 	创建一个生成这些数据的视图。
create view branch_summary_vw
(branch_name, city, total_balance)
as
select 
	b.name, b.city, sum(a.avail_balance)
from branch b inner join account a
	on b.branch_id = a.open_branch_id
group by b.name, b.city;

select * from branch_summary_vw;



