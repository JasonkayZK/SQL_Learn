-- 第四章 过滤
-- 4.1.1 and or 运算符
-- 4.1.2 not 运算符

-- 4.3 条件类型
-- 4.3.1 相等条件
select pt.name product_type, p.name product
from product p inner join product_type pt 
	on p.product_type_cd = pt.product_type_cd
where pt.name = 'Customer Accounts';


-- 4.3.1 不等条件
select pt.name product_type, p.name product
from product p inner join product_type pt 
	on p.product_type_cd = pt.product_type_cd
where pt.name != 'Customer Accounts';



-- 4.3.2 范围条件
select emp_id, fname, lname, start_date
from employee
where start_date < '2007-01-01';

select emp_id, fname, lname, start_date
from employee
where start_date < '2007-01-01' and start_date >= '2005-01-01';


-- between 操作符: 
-- 1. 必须先指定下限 between low and high!
-- 2. 上下限是闭合的, 限值本身也被包含
select emp_id, fname, lname, start_date
from employee
where start_date between '2005-01-01' and '2007-01-01';

select account_id, product_cd, cust_id, avail_balance
from account
where avail_balance between 3000 and 5000;


-- 字符串范围
select cust_id, fed_id
from customer
where cust_type_cd = 'I' 
	and fed_id between '500-00-0000' and '999-99-9999';


-- 4.3.3 成员条件
-- In
select account_id, product_cd, cust_id, avail_balance
from account
where product_cd = 'CHK' 
	or product_cd = 'SAV' 
	or product_cd = 'CD' 
    or product_cd = 'MM';

select account_id, product_cd, cust_id, avail_balance
from account
where product_cd in ('CHK', 'SAV', 'CD', 'MM');


-- 使用子查询
select account_id, product_cd, cust_id, avail_balance
from account
where product_cd in (
		select product_cd from product
        where product_type_cd = 'ACCOUNT'
	);


-- 使用 not in
select account_id, product_cd, cust_id, avail_balance
from account
where product_cd not in ('CHK', 'SAV', 'CD', 'MM');


-- 4.3.4 匹配条件
-- 寻找所有以T开头的姓氏的雇员
select emp_id, fname, lname
from employee
where left(lname, 1) = 'T';


-- 使用通配符
select lname
from employee
where lname like '_a%e%';

-- 查找所有联邦个人识别号码与社会安全号码格式匹配的顾客
select cust_id, fed_id
from customer
where fed_id like '___-__-____';


-- 正则表达式: 查询F或者G开头的雇员
select emp_id, fname, lname
from employee
where lname regexp '^[FG]';



-- 4.4 null: 4个字母的关键字
-- 1. 使用is not 判断null值
select emp_id, fname, lname, superior_emp_id
from employee
where superior_emp_id is null;

-- 2. 不能使用 = 判断两个null相等!!!!!!
select emp_id, fname, lname, superior_emp_id
from employee
where superior_emp_id = null;


-- 3. 检查列中数据是否被赋值, 使用not null
select emp_id, fname, lname, superior_emp_id
from employee
where superior_emp_id is not null;


-- 4. 找出所有不为Helen工作的雇员
select emp_id, fname, lname, superior_emp_id
from employee
where superior_emp_id != 6;

/* 虽然null != 6 但是结果集不处理null列, 所以需显式比较!!!!!!!!! */
select emp_id, fname, lname, superior_emp_id
from employee
where superior_emp_id != 6 or superior_emp_id is null;




-----------------------------------------------------------------------------------
-- Homework
-- 1. 下面的过滤条件将返回哪些交易的ID?
-- txn_date < '2005-02-26' And (txn_type_cd = 'DBT' OR amount > 100)

-- answer: 1, 2, 3, 5, 6, 7
select txn_id
from chapter4_homework
where txn_date < '2005-02-26' And (txn_type_cd = 'DBT' OR amount > 100);


-- 2. 下面的过滤条件将返回哪些交易的ID?
-- account_id In (101, 103) AND NOT (txn_type_cd = 'DBT' OR amount > 100)

-- answer: 4, 9
select txn_id
from chapter4_homework
where account_id In (101, 103) AND NOT (txn_type_cd = 'DBT' OR amount > 100);


-- 3. 构造查询语句,获取在2002年开户的所有账户
select * from account;

select account_id, open_date
from account
where open_date between '2002-01-01' and '2002-12-31';


-- 4. 构造查询,查找姓氏中以a为第二个字符,并且e在a后面任意位置出现的非公司顾客
select * from individual;

select cust_id, lname, fname
from individual
where lname like '_a%e%';

