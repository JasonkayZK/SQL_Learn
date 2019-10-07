-- 第六章 使用集合
-- 6.2 集合理论实践
-- 两个集合执行集合操作时的规范
-- 1. 两个数据集香必须具有同样数目的列
-- 2. 两个数据集中对应列的数据类型必须是一样的, 或者服务器能够将其中一种转换为另外一种
-- 例如: 在两个select语句中使用集合操作
select 1 num, 'abc' str union select 9 num, 'xyz' str;


-- 6.3.1 union操作符
-- 例: 从两个子类型客户表中产生完整的客户数据集合
select 'IND' type_cd, cust_id, lname name
from individual
union all
select 'BUS' type_cd, cust_id, name
from business;

-- 例: 使用union all连接两次表
select 'IND' type_cd, cust_id, lname name
from individual
union all
select 'BUS' type_cd, cust_id, name
from business
union all
select 'BUS' type_cd, cust_id, name
from business;

-- 例: 另一个返回重复数据的复合查询- 
-- 第一个查询获取分配到Woburn支行的所有柜员, 第二个查询返回所有在Woburn支行开户的雇员(并使用distinct去重)
select emp_id
from employee
where assigned_branch_id = 2
	and (title = 'Teller' or title = 'Head Teller')
union all
select distinct open_emp_id
from account
where open_branch_id = 2;



-- 6.3.2 intersect
-- mysql 未实现!
-- select emp_id, fname, lname
-- from employee
-- intersect
-- select cust_id, fname, lname
-- from individual;


-- 6.3.3 except操作符 mysql未实现



-- 6.4 集合操作规则
-- 6.4.1 对复合查询结果排序
select emp_id, assigned_branch_id
from employee
where title = 'Teller'
union
select open_emp_id, open_branch_id
from account
where product_cd = 'SAV'
order by emp_id;

-- 如果两个查询指定的列名不相同, 若在order by子句中指定的是第二个查询的列名, 将发生错误
select emp_id, assigned_branch_id
from employee
where title = 'Teller'
union
select open_emp_id, open_branch_id
from account
where product_cd = 'SAV'
order by open_emp_id;


-- 6.4.2 集合操作符优先级
-- 如果复合查询包含两个以上使用不同集合操作符的查询, 那么需要在复合语句中确定
-- 查询执行的次序,以获取想要的结果。
-- 考虑下面包含3个查询的复合语句:
select cust_id
from account
where product_cd in ('SAV', 'MM')
union ALL
SELECT a.cust_id
from account a inner join branch b
	on a.open_branch_id = b.branch_id
where b.name = 'Woburn Branch'
union
select cust_id
from account
where avail_balance between 500 and 2500;

-- 下面是类似的复合查询, 只不过这两个操作符出现的次序被调换!
select cust_id
from account
where product_cd in ('SAV', 'MM')
union 
SELECT a.cust_id
from account a inner join branch b
	on a.open_branch_id = b.branch_id
where b.name = 'Woburn Branch'
union ALL
select cust_id
from account
where avail_balance between 500 and 2500;



-----------------------------------

-- Homework
-- 1. 如果集合A={L M N O P},集合B={P Q R S T},那么下面的操作产生的结果集是什么?
-- A union B
-- A union all B
-- A intersect B
-- A except B

-- answer:
-- L M N O P Q R S T
-- L M N O P P Q R S T
-- P
-- L M N O


-- 2. 编写一个复合查询,以查找所有个人客户以及雇员的姓氏和名字
select 'IND' type, i.fname, i.lname
from individual i
union all
select 'EMP' type, e.fname, e.lname
from employee e;



-- 3. 根据lname列对练习6-2的结果进行排序
select 'IND' type, i.fname, i.lname lname
from individual i
union all
select 'EMP' type, e.fname, e.lname
from employee e
order by lname;


