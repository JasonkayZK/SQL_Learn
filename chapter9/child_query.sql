-- 第九章. 子查询
-- 9.1 什么是子查询
-- 包含在另一个sql语句内部的查询
-- 子查询由括号包围, 并且通常先执行!
-- 子查询返回类型:
--   	单列单行
-- 		单列多行
-- 		多列多行

-- 例: 
select account_id, product_cd, cust_id, avail_balance
from account
where account_id = (select max(account_id) from account);


-- 9.2 子查询类型
-- 按照子查询结果集: 单行单列, 单行多列, 多行多列
-- 按照独立性: 子查询完全独立(非关联子查询), 引用包含语句中的列(关联查询)


-- 9.3 非关联子查询
-- 在不等条件下使用标量子查询(子查询非关联, 并且返回结果单行单列)
-- 例: 返回不是由Woburn分行的总柜台员开户的账号的信息
select account_id, product_cd, cust_id, avail_balance
from account
where open_emp_id != (
	select e.emp_id
    from employee e inner join branch b
		on e.assigned_branch_id = b.branch_id
	where e.title = 'Head Teller' and b.city = 'Woburn'
);


-- 等式条件下查询结果有多行将报错!
select account_id, product_cd, cust_id, avail_balance
from account
where open_emp_id != (
	select e.emp_id
    from employee e inner join branch b
		on e.assigned_branch_id = b.branch_id
	where e.title = 'Teller' and b.city = 'Woburn'
);


-- 9.3.1 多行单列子查询
-- 由于返回多行的子查询不能在等式条件使用, 所以可以使用其他4个运算符
-- in, not in, all, any

-- 1. in和not in
-- 检查一个值是否包含在结果集中
select branch_id, name, city
from branch
where name in ('Headquarters', 'Quincy Branch');


-- 那些雇员是主管
select emp_id, fname, lname, title
from employee
where emp_id in (
	select superior_emp_id from employee
);

-- 检索不管理别人的雇员
select emp_id, fname, lname, title
from employee
where emp_id not in (
	select superior_emp_id 
    from employee
    where superior_emp_id is not null
);



-- all运算符
-- 查询雇员id与任何主管id不同的所有雇员
select emp_id, fname, lname, title
from employee
where emp_id != all (
	select superior_emp_id
    from employee
    where superior_emp_id is not null
);


-- 注: 当使用not in 或者 != 比较一个值和一个集时, 必须注意结果值不包括null!!!
-- 任何一个值与null比较可能产生未知结果!
select emp_id, fname, lname, title
from employee
where emp_id not in (1, 2, null);


-- 查找可用余额小于Frank Tucker所有账号的账号
select account_id, cust_id, product_cd, avail_balance
from account
where avail_balance < all (
	select a.avail_balance
    from account a inner join individual i
		on a.cust_id = i.cust_id
	where i.fname = 'Frank' and i.lname = 'Tucker'
);



-- any 
-- 查找余额大于Frank Tucker任意账号的账号
select account_id, cust_id, product_cd, avail_balance
from account
where avail_balance > any (
	select a.avail_balance
    from account a inner join individual i
		on a.cust_id = i.cust_id
	where i.fname = 'Frank' and i.lname = 'Tucker'
);



-- 9.3.2 多列子查询
-- 使用两个单列子查询, 检索Woburn分行的ID, 以及所有银行柜台员的ID
select account_id, product_cd, cust_id
from account
where open_branch_id = (
	select branch_id
    from branch
    where name = 'Woburn Branch'
) and open_emp_id in (
	select emp_id
    from employee
    where title = 'Teller' or title = 'Head Teller'
);

-- 使用一个多列子查询代替两个单列子查询
select account_id, product_cd, cust_id
from account
where (open_branch_id, open_emp_id) in (
	select b.branch_id, e.emp_id
    from employee e inner join branch b
		on e.assigned_branch_id = b.branch_id
	where b.name = 'Woburn Branch'
		and (e.title = 'Teller' or e.title = 'Head Teller')
);

-- 使用三表联查代替子查询
select a.account_id, a.product_cd, a.cust_id
from account a inner join branch b
	on b.branch_id = a.open_branch_id
    inner join employee e 
    on e.emp_id = a.open_emp_id
where b.name = 'Woburn Branch'
	and (e.title = 'Teller' or e.title = 'Head Teller');



-- 9.4 关联子查询
-- 查询包含两个账号的客户
select c.cust_id, c.cust_type_cd, c.city
from customer c
where 2 = (
	select count(*)
    from account a
    where a.cust_id = c.cust_id
);


-- 查询所有账户余额在5000-10000之间的所以客户
select c.cust_id, c.cust_type_cd, c.city
from customer c
where (
	select sum(a.avail_balance)
    from account a
    where a.cust_id = c.cust_id
) between 5000 and 10000;



-- exists 运算符
-- 只关心存在关系而不关心数量: 检查子查询能否返回至少一行!
-- 例: 检索在特定日期进行过交易的所以账号
select a.account_id, a.product_cd, a.cust_id, a.avail_balance
from account a
where exists (
	select 1
    from transaction t
    where t.account_id = a.account_id
		and t.txn_date = '2008-09-22'
);


-- 使用not exists检查子查询返回行数是否为0
-- 查询客户id没有出现在business表中的所以客户
select a.account_id, a.product_cd, a.cust_id
from account a
where not exists (
	select 1
    from business b
    where b.cust_id = a.cust_id
);



-- 9.4.2 关联子查询操作数据
-- 子查询也可以应用于update, delete或insert
-- 修改account表中的last_activity_date: 查询每个账户的最新交易日期, 并修改每一行
update account a
set a.last_activity_date = (
	select max(t.txn_date)
    from transaction t
    where t.account_id = a.account_id
);

-- 修改之前, 检查account是否发生过交易, 否则可能被修改为null!
update account a
set a.last_activity_date = (
	select max(t.txn_date)
    from transaction t
    where t.account_id = a.account_id
)
where exists (
	select 1
    from transaction t
    where t.account_id = a.account_id
);


-- 在delete中使用关联子查询
-- 在delete语句中使用关联子查询无论如何不能使用表别名!!!
delete from department
where not exists (
	select 1
    from employee
    where employee.dept_id = department.dept_id
);



-- 9.5 何时使用子查询
-- 9.5.1 子查询作为数据源
select d.dept_id, d.name, e_cnt.how_many
from department d inner join (
	select dept_id, count(*) how_many
    from employee
    group by dept_id
) e_cnt
on d.dept_id = e_cnt.dept_id;


-- 数据加工
-- 按照储蓄账户的余额对客户分组
-- (1). 分组要求
select 'Small Fry' name, 0 low_limit, 4999.99 high_limit
union all
select 'Average Joes' name, 5000 low_limit, 9999.99 high_limit
union all
select 'Heavy Hitters' name, 10000 low_limit, 9999999.99 high_limit;

-- (2). 子查询生成分组
select groups.name, count(*) num_customers
from (
	select sum(a.avail_balance) cust_balance
	from account a inner join product p
		on a.product_cd = p.product_cd
	where p.product_type_cd = 'ACCOUNT'
	group by a.cust_id
) cust_rollup
inner join (
	select 'Small Fry' name, 0 low_limit, 4999.99 high_limit
	union all
	select 'Average Joes' name, 5000 low_limit, 9999.99 high_limit
	union all
	select 'Heavy Hitters' name, 10000 low_limit, 9999999.99 high_limit
) groups
on cust_rollup.cust_balance between groups.low_limit and groups.high_limit
group by groups.name;



-- 面向任务的子查询: 依据账户类型, 开户雇员以及开户行对所有储蓄账户余额求和
select p.name product, b.name branch, concat(e.fname, ' ', e.lname) name, sum(a.avail_balance) tot_deposits
from account a inner join employee e
	on a.open_emp_id = e.emp_id
    inner join branch b
    on a.open_branch_id = b.branch_id
    inner join product p
    on a.product_cd = p.product_cd
where p.product_type_cd = 'ACCOUNT'
group by p.name, b.name, e.fname, e.lname
order by product, branch;


-- 其实account表已经有了分组所需的一切, 所以可以使用三个子查询代表三个任务!
select p.name product, b.name branch, 
	concat(e.fname, ' ', e.lname) name, 
    account_groups.tot_deposits
from (
	select product_cd, open_branch_id branch_id, open_emp_id emp_id, 
		sum(avail_balance) tot_deposits
    from account
    group by product_cd, open_branch_id, open_emp_id
) account_groups
inner join employee e on e.emp_id = account_groups.emp_id
inner join branch b on b.branch_id = account_groups.branch_id
inner join product p on p.product_cd = account_groups.product_cd
where p.product_type_cd = 'ACCOUNT';


-- 9.5.2 过滤条件中的子查询
-- 大多数都是将子查询用作过滤条件中的表达式
-- 在having中使用子查询: 查找开户最多的雇员
select open_emp_id, count(*) how_many
from account
group by open_emp_id
having count(*) = (
	select max(emp_cnt.how_many)
    from (
		select count(*) how_many
        from account
        group by open_emp_id
    ) emp_cnt
);



-- 9.5.3 子查询作为表达式生成器
-- 对于标量子查询来说, 还可用在表达式的任何位置!
-- 在select中的子查询: 依据账户类型, 开户雇员以及开户行对所有储蓄账户余额求和
-- 结果出现了product列出现null!!! 因为: 
-- 主查询没有连接到product表, 所以没办法在主查询中添加过滤条件!
select 
	(
		select p.name
        from product p
        where p.product_cd = a.product_cd
			and p.product_type_cd = 'ACCOUNT'
    ) product,
    (
		select b.name
        from branch b
        where b.branch_id = a.open_branch_id
    ) branch,
    (
		select concat(e.fname, ' ', e.lname)
        from employee e
        where e.emp_id = a.open_emp_id
    ) name,
    sum(a.avail_balance) tot_deposits
from account a
group by a.product_cd, a.open_branch_id, a.open_emp_id
order by product, branch;


-- 通过在主查询添加having判断
select 
	(
		select p.name
        from product p
        where p.product_cd = a.product_cd
			and p.product_type_cd = 'ACCOUNT'
    ) product,
    (
		select b.name
        from branch b
        where b.branch_id = a.open_branch_id
    ) branch,
    (
		select concat(e.fname, ' ', e.lname)
        from employee e
        where e.emp_id = a.open_emp_id
    ) name,
    sum(a.avail_balance) tot_deposits
from account a
group by a.product_cd, a.open_branch_id, a.open_emp_id
having product is not null
order by product, branch;


-- 或者将前面的查询作为子查询包装到all_prods中, 然后使用where判断
select all_prods.product, all_prods.branch, 
	all_prods.name, all_prods.tot_deposits
from (
	select 
	(
		select p.name
        from product p
        where p.product_cd = a.product_cd
			and p.product_type_cd = 'ACCOUNT'
    ) product,
    (
		select b.name
        from branch b
        where b.branch_id = a.open_branch_id
    ) branch,
    (
		select concat(e.fname, ' ', e.lname)
        from employee e
        where e.emp_id = a.open_emp_id
    ) name,
    sum(a.avail_balance) tot_deposits
	from account a
	group by a.product_cd, a.open_branch_id, a.open_emp_id
) all_prods
where all_prods.product is not null
order by 1, 2;



-- 子查询在order by子句中: 检索雇员数据, 结果按照第一雇员老板排序, 第二雇员姓氏排序
select e.emp_id, 
	concat(e.fname, ' ', e.lname) emp_name, 
    (
		select concat(boss.fname, ' ', boss.lname)
		from employee boss
		where boss.emp_id = e.superior_emp_id
    ) boss_name
from employee e
where e.superior_emp_id is not null
order by (
	select boss.lname
    from employee boss
    where boss.emp_id = e.superior_emp_id
), e.lname;



-- 在insert中使用标量子查询生成插入值
-- 产品名称(“ savings account”);
-- 客户联邦个人识别号码(“555-55-5555"
-- 开户行名称(“ Quincy branch”)
-- 开户柜员的姓名
--
-- 需要注意的是: 如果插入的列允许为null值时, 即使子查询不能返回值, insert也会成功!!!
-- 例如把: Frank Portman拼写错误, 也可以创建新行, 但是open_emp_id为null!!!!
INSERT INTO account
(account_id, product_cd, cust_id, open_date, last_activity_date,
	status, open_branch_id, open_emp_id, avail_balance, pending_balance)
values
(
	null,
    (select product_cd from product where name = 'savings account'),
    (select cust_id from customer where fed_id = '555-55-5555'),
    '2008-09-25',
    '2008-09-25',
    'ACTIVE',
    (select branch_id from branch where name = 'Quincy Branch'),
    (select emp_id from employee where lname = 'Portman' and fname = 'Frank'),
    0,
    0
);




-- -------------------------------------------
-- Homework
-- 1. 对 account表编写一个查询: 
-- 过滤条件使用的非关联子查询实现对product表查找所有贷款账户(product.product_type_cd='LOAN')
-- 结果包括账号ID、产品代码、客户ID和可用余额
select a.account_id, a.product_cd, a.cust_id, a.avail_balance
from account a
where a.product_cd in (
	select p.product_cd
    from product p
    where p.product_type_cd = 'LOAN'
);



-- 2. 重做练习9-1,对 product表使用关联子查询获得同样的结果。
select a.account_id, a.product_cd, a.cust_id, a.avail_balance
from account a
where exists (
	select 1
    from product p
    where a.product_cd = p.product_cd
		and p.product_type_cd = 'LOAN'
);


-- 3. 将下面的查询与employee表连接,以展示每个雇员的经验
SELECT 'trainee' name, '2008-01-01' start_dt, '2009-12-31' end_dt
UNION ALL
SELECT 'worker' name, '2006-01-01' start_dt, '2007-12-31' end_dt
UNION ALL
SELECT 'mentor' name, '2004-01-01' start_dt, '2005-12-31' end_dt;
-- 子查询别名定义为 levels,它包含雇员ID、名字、姓氏以及经验等级(levels.name)。
-- (提示: 利用不等条件构建连接条件,确定 employee.start_date列位于哪个等级)
select concat(e.fname, ' ', e.lname) name, l.name e_level
from employee e inner join
	(
		SELECT 'trainee' name, '2008-01-01' start_dt, '2009-12-31' end_dt
		UNION ALL
		SELECT 'worker' name, '2006-01-01' start_dt, '2007-12-31' end_dt
		UNION ALL
		SELECT 'mentor' name, '2004-01-01' start_dt, '2005-12-31' end_dt
    ) l
	on e.start_date between l.start_dt and l.end_dt;

-- 4. 对employee构建一个查询,检索雇员ID、名字、姓氏及其所属部门和分行的名字。请不要连接任何表。
select e.emp_id, concat(e.fname, ' ', e.lname) name, 
	e.lname last_name, 
    (
		select d.name
        from department d
        where d.dept_id = e.dept_id
    ) dept,
    (
		select b.name
        from branch b
        where b.branch_id = e.assigned_branch_id
    ) branch
from employee e;


