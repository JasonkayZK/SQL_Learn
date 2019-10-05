-- 3.3 select语句
select * from department;

select dept_id, name from department;

select emp_id, 'ACTIVE', emp_id * 3.14159, UPPER(lname)
FROM employee;

-- 省略from
select version(), user(), database();

-- 列的别名
select emp_id, 'ACTIVE' status, emp_id * 3.14159 empid_x_pi, upper(lname) last_name_upper
from employee;

-- 去除重复的行
select cust_id from account;

select distinct cust_id from account;

select distinct cust_id, product_cd from account;



-- 3.4 from子句
-- 子查询中产生的表
select e.emp_id, e.fname, e.lname
from (
	select emp_id, fname, lname, start_date, title from employee) e;


-- 视图
create view employee_vw as 
	select emp_id, fname, lname, year(start_date) start_year from employee;

select emp_id, start_year from employee_vw;


-- 3.4.2 表连接
select employee.emp_id, employee.fname, employee.lname, department.name dept_name
from employee inner join department on employee.dept_id = department.dept_id;


-- 3.4.3 定义表别名
select e.emp_id, e.fname, e.lname, d.name dept_name
from employee e inner join department d on e.dept_id = d.dept_id;



-- 3.5 where子句
select emp_id, fname, lname, start_date, title
from employee
where title = 'Head Teller';

select emp_id, fname, lname, start_date, title
from employee
where title = 'Head Teller' and start_date > '2006-01-01';

select emp_id, fname, lname, start_date, title
from employee
where title = 'Head Teller' or start_date > '2006-01-01';

select emp_id, fname, lname, start_date, title
from employee
where (title = 'Head Teller' and start_date > '2006-01-01') 
	or (title = 'Teller' and start_date > '2007-01-01');



-- 3.6 group by 和 having
select d.name, count(e.emp_id) num_employees
from department d inner join employee e on d.dept_id = e.dept_id
group by d.name
having count(e.emp_id) > 2;


-- 3.7 order by子句
select open_emp_id, product_cd
from account
order by open_emp_id;

select open_emp_id, product_cd
from account
order by open_emp_id, product_cd;


-- 3.7.1 升降序排列
select account_id, product_cd, open_date, avail_balance
from account
order by avail_balance desc;

-- mysql 独有关键字 limit
select account_id, product_cd, open_date, avail_balance
from account
order by avail_balance desc
limit 5;


-- 3.7.2 根据表达式排序: 最后3个数字
select cust_id, cust_type_cd, city, state, fed_id
from customer
order by right(fed_id, 3);


-- 3.7.3 根据数字占位符排序
select emp_id, title, start_date, fname, lname
from employee
order by 2, 5;



-----------------------------------------------------------------
-- Homework
-- 1. 获取所有银行雇员的 employee ID、名字( first name)和姓氏( last name),并先后根据姓氏和名字进行排序。
select emp_id, fname, lname
from employee e
order by e.lname, e.fname;


-- 2. 获取所有状态为'ACTIVE'以及可用余额大于$2500的账户的 account ID、 customer ID和可用余额(available balance)
select a.account_id, a.cust_id, a.avail_balance
from account a
where a.status = 'ACTIVE' and a.avail_balance > 2500;


-- 3. 针对 account表编写查询,以返回开设过账户的雇员ID(使用 account open emp id列)并且结果集中每个独立的雇员只包含一行数据
select distinct a.open_emp_id
from account a;



-- 4. 为下面的多数据集査询语句填空(用<#>标记的地方),以获取所显示的结果。
-- 
-- SELECT p.product_cd, a.cust_id, a.avail_balance
-- 	FROM product p INNER JOIN account <1>
-- 		ON p.product_cd = <2>
-- WHERE p.<3> = 'ACCOUNT'
-- ORDER BY <4>, <5>;

SELECT p.product_cd, a.cust_id, a.avail_balance
	FROM product p INNER JOIN account a
		ON p.product_cd = a.product_cd
WHERE p.product_type_cd = 'ACCOUNT'
ORDER BY a.product_cd, a.cust_id;


