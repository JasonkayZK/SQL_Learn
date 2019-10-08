-- 第十章 再谈连接
-- 10.1 外连接
-- 由于account中的cust_id在customer表中都出现
-- 所以每一个关联查询都可以被连接, 最后连接返回的行数 = count(*) from account
select account_id, cust_id from account;
select cust_id from customer;

select a.account_id, c.cust_id
from account a inner join customer c
	on a.cust_id = c.cust_id;


-- account表连接business表
-- account中仅有5行可以连接到business表!
select account_id, cust_id from account;
select cust_id, name from business;

select a.account_id, b.cust_id, b.name
from account a inner join business b
	on a.cust_id = b.cust_id;


-- 使用外链接: 查询所有账户, 对于客户名字只返回商业客户名字
select a.account_id, a.cust_id, b.name
from account a left outer join business b
	on a.cust_id = b.cust_id;


-- 使用外链接:查询所有账户, 对于客户名字只返回个人客户(非商业)名字
select a.account_id, a.cust_id, i.fname, i.lname
from account a left outer join individual i
	on a.cust_id = i.cust_id;



-- 10.1.1 左/右外链接
-- 对于left outer join: 
-- 	连接左边的表决定结果集行数, 而右边的表只负责提供与之匹配的列值
-- right outer join同理
-- 注:
-- 	两种查询都属于外链接, 关键字left和right只是通知服务器哪个表的数据可以不足!!!!
-- 左外连接
select c.cust_id, b.name
from customer c left outer join business b
	on c.cust_id = b.cust_id;

-- 右外连接
select c.cust_id, b.name
from customer c right outer join business b
	on c.cust_id = b.cust_id;



-- 10.1.2 三路外连接
-- 将一个表与其他两个表(或者更多)进行外连接
-- 例: 得到所有账户列表, 包括个人客户的姓名, 以及商业客户的企业名称
-- 	(注意到个人客户和商业客户为互斥关系!!!!)
select a.account_id, a.product_cd,
	concat(i.fname, ' ', i.lname),
    b.name business_name
from account a left outer join individual i
	on a.cust_id = i.cust_id
    left outer join business b
    on a.cust_id = b.cust_id;



-- 利用子查询限制查询中连接的数目
-- (有些数据库可能只支持两个表之间的外连接, 而使用子查询两两表之间实现外连接)
select a_i.account_id, a_i.product_cd, a_i.person_name,
	b.name business_name
from (
	select a.account_id, a.product_cd, a.cust_id,
		concat(i.fname, ' ', i.lname) person_name
    from account a left outer join individual i
		on a.cust_id = i.cust_id
	) a_i
    left outer join business b
	on a_i.cust_id = b.cust_id;



-- 10.1.3 自外连接
-- 例: 使用自连接生成雇员和对应主管的列表
select concat(e.fname, ' ', e.lname) emp, 
	concat(mgr.fname, ' ', mgr.lname) mgr
from employee e inner join employee mgr
	on e.superior_emp_id = mgr.emp_id;

-- 使用左外连接: 输出没有主管的雇员
select concat(e.fname, ' ', e.lname) emp, 
	concat(mgr.fname, ' ', mgr.lname) mgr
from employee e left outer join employee mgr
	on e.superior_emp_id = mgr.emp_id;


-- 使用右外连接: 输出每个主管管理雇员的集合
-- (一个主管可能会管理多个雇员, 所以结果可能大于雇员数!!!)
select concat(e.fname, ' ', e.lname) emp, 
	concat(mgr.fname, ' ', mgr.lname) mgr
from employee e right outer join employee mgr
	on e.superior_emp_id = mgr.emp_id;



-- 10.2 交叉连接(笛卡尔积)
select * from product;
select * from product_type;

select pt.name, p.product_cd, p.name
from product p cross join product_type pt;


-- 笛卡尔积的使用场景: 生成一整年的日期表
-- 1. 生成全排列
select ones.num + tens.num + hundreds.num num
from
(
	select 0 num union all
    select 1 num union all
    select 2 num union all
    select 3 num union all
    select 4 num union all
    select 5 num union all
    select 6 num union all
    select 7 num union all
    select 8 num union all
    select 9 num
) ones
cross join
(
	select 0 num union all
    select 10 num union all
    select 20 num union all
    select 30 num union all
    select 40 num union all
    select 50 num union all
    select 60 num union all
    select 70 num union all
    select 80 num union all
    select 90 num
) tens
cross join
(
	select 0 num union all
    select 100 num union all
    select 200 num union all
    select 300 num
) hundreds
order by num;

-- 2. 将数字集转为日期集
select date_add('2008-01-01', interval (ones.num + tens.num + hundreds.num) day) dt
from
(
	select 0 num union all
    select 1 num union all
    select 2 num union all
    select 3 num union all
    select 4 num union all
    select 5 num union all
    select 6 num union all
    select 7 num union all
    select 8 num union all
    select 9 num
) ones
cross join
(
	select 0 num union all
    select 10 num union all
    select 20 num union all
    select 30 num union all
    select 40 num union all
    select 50 num union all
    select 60 num union all
    select 70 num union all
    select 80 num union all
    select 90 num
) tens
cross join
(
	select 0 num union all
    select 100 num union all
    select 200 num union all
    select 300 num
) hundreds
where date_add('2008-01-01', interval (ones.num + tens.num + hundreds.num) day) < '2009-01-01'
order by dt;


-- 3. 生成一个查询来展示2008年每一日, 当天银行交易数量以及开户数量
select days.dt, count(t.txn_id)
from transaction t right outer join
	(
		select date_add('2008-01-01', interval (ones.num + tens.num + hundreds.num) day) dt
		from
		(
			select 0 num union all
			select 1 num union all
			select 2 num union all
			select 3 num union all
			select 4 num union all
			select 5 num union all
			select 6 num union all
			select 7 num union all
			select 8 num union all
			select 9 num
		) ones
		cross join
		(
			select 0 num union all
			select 10 num union all
			select 20 num union all
			select 30 num union all
			select 40 num union all
			select 50 num union all
			select 60 num union all
			select 70 num union all
			select 80 num union all
			select 90 num
		) tens
		cross join
		(
			select 0 num union all
			select 100 num union all
			select 200 num union all
			select 300 num
		) hundreds
		where date_add('2008-01-01', interval (ones.num + tens.num + hundreds.num) day) < '2009-01-01'
	) days
    on days.dt = t.txn_date
group by days.dt
order by 1;





-- 10.3 自然连接
-- 依赖多表交叉时的相同列明来推断正确的连接方式!
-- 例如account表与customer表均包括cust_id!
-- 服务器检查自动添加了连接条件: a.cust_id = c.cust_id
select a.account_id, a.cust_id, c.cust_type_cd, c.fed_id
from account a natural join customer c;


-- 但是如果交叉表没有相同的名称列
-- account表中有open_branch_id, 而不是branch_id
-- 将会采用笛卡尔积!!!
select a.account_id, a.cust_id, a.open_branch_id, b.name
from account a natural join branch b;




-- --------------------------------------------------
-- Homework
-- 1. 编写一个查询,它返回所有产品名称及基于该产品的账号(用account表里的product_cd列连接product表).
-- 	查询结果需要包括所有产品,即使这个产品并没有客户开户。
select p.name, p.product_cd, a.account_id, a.cust_id
from product p left outer join account a
	on p.product_cd = a.product_cd;





-- 2. 利用其他外连接类型重写练习1的查询(比如,若在练习1中使用了左外连接这次就使用右外连接),要求查询结果相同
select p.name, p.product_cd, a.account_id, a.cust_id
from account a right outer join product p
	on p.product_cd = a.product_cd;



-- 3. 编写一个查询,将account表与individua和business两个表外连接(通过account.cust_id列)
-- 	要求结果集中每个账户一行,查询的列有account.account_id, account.product_cd, 
-- 	individual.fname, individual.lname和business.name
select a.account_id, a.product_cd, i.fname, i.lname, b.name
from account a left outer join individual i
	on a.cust_id = i.cust_id
    left outer join business b
    on a.cust_id = b.cust_id;




-- 4. 设计一个查询,生成集合{1,2,3…,9,100}。(提示:应用交叉连接,至少有两个from子句的子查询。)
select ones.num + tens.num + 1
from
(
	(
		select 0 num union all
		select 1 num union all
		select 2 num union all
		select 3 num union all
		select 4 num union all
		select 5 num union all
		select 6 num union all
		select 7 num union all
		select 8 num union all
		select 9 num
	) ones
	cross join
	(
		select 0 num union all
		select 10 num union all
		select 20 num union all
		select 30 num union all
		select 40 num union all
		select 50 num union all
		select 60 num union all
		select 70 num union all
		select 80 num union all
		select 90 num
	) tens
);




