-- 第五章 多表查询
-- 5.1.1 笛卡尔积
select e.fname, e.lname, d.name
from employee e join department d;


-- 5.1.2 内连接
select e.fname, e.lname, d.name
from employee e inner join department d on e.dept_id = d.dept_id;

-- 连接两个表的列名相同, 可使用using(不推荐!!!!)
select e.fname, e.lname, d.name
from employee e inner join department d using(dept_id);


-- 5.1.3 ANSI连接语法
-- 旧式(不推荐)
select e.fname, e.lname, d.name
from employee e, department d
where e.dept_id = d.dept_id;

-- 由于旧式连接没有使用on, 会使连接逻辑和过滤逻辑混合在一起, 复杂化!
-- 同时, 对于使用了何种连接类型也不是显而易见!
-- 查询: Woburn支行中所有熟练柜员(在2007年以前入职的柜员)开设的账户
-- 旧式查询
select a.account_id, a.cust_id, a.open_date, a.product_cd
from account a, branch b, employee e
where a.open_emp_id = e.emp_id -- 连接条件1
	and e.start_date < '2007-01-01'
    and e.assigned_branch_id = b.branch_id -- 连接条件2
    and (e.title = 'Teller' or e.title = 'Head Teller')
    and b.name = 'Woburn Branch';

-- 新式查询
select a.account_id, a.cust_id, a.open_date, a.product_cd
from account a inner join employee e
	on a.open_emp_id = e.emp_id
	inner join branch b
    on e.assigned_branch_id = b.branch_id
where e.start_date < '2007-01-01'
    and (e.title = 'Teller' or e.title = 'Head Teller')
    and b.name = 'Woburn Branch';

-- 注意: 不同的连接顺序会产生相同的结果!!!
select a.account_id, a.cust_id, a.open_date, a.product_cd
from employee e inner join account a
	on a.open_emp_id = e.emp_id
	inner join branch b
    on e.assigned_branch_id = b.branch_id
where e.start_date < '2007-01-01'
    and (e.title = 'Teller' or e.title = 'Head Teller')
    and b.name = 'Woburn Branch';



-- 5.2 连接3个或更多的表
-- 查询所有商务账户(type = 'B')的账户ID和税务代码(2表联合查询)
select a.account_id, c.fed_id
from account a inner join customer c
	on a.cust_id = c.cust_id
where c.cust_type_cd = 'B';

-- 两个表联合查询相当简洁
-- 添加一个查询employee表中此账户柜员姓名
select a.account_id, c.fed_id, e.fname, e.lname
from account a inner join customer c
	on a.cust_id = c.cust_id
    inner join employee e
    on a.open_emp_id = e.emp_id
where c.cust_type_cd = 'B';    

-- 交换顺序
select a.account_id, c.fed_id, e.fname, e.lname
from customer c inner join account a
	on a.cust_id = c.cust_id
	inner join employee e
    on a.open_emp_id = e.emp_id
where c.cust_type_cd = 'B';

-- 再次交换
select a.account_id, c.fed_id, e.fname, e.lname
from employee e inner join account a
	on e.emp_id = a.open_emp_id
    inner join customer c
    on c.cust_id = a.cust_id
where c.cust_type_cd = 'B';


-- 强制指定连接顺序: 以customer作为驱动表, 先连接account, 后连接employee
select straight_join a.account_id, c.fed_id, e.fname, e.lname
from customer c inner join account a
	on a.cust_id = c.cust_id
    inner join employee e
    on a.open_emp_id = e.emp_id
where c.cust_type_cd = 'B';



-- 5.2.1 蒋子查询作为查询表: Woburn支行中所有熟练柜员(在2007年以前入职的柜员)开设的账户
-- 其中 account表与子查询的结果相连接, 而不是与 branch表及 employe表连接
select a.account_id, a.cust_id, a.open_date, a.product_cd
from account a inner join (
		select emp_id, assigned_branch_id
		from employee
		where start_date < '2007-01-01'
			and (title = 'Teller' or title = 'Head Teller')
	) e
    on a.open_emp_id = e.emp_id
    inner join (
		select branch_id
        from branch
        where name = 'Woburn Branch'
    ) b
	on b.branch_id = e.assigned_branch_id;

-- 第一个子查询
select emp_id, assigned_branch_id
from employee
where start_date < '2007-01-01'
	and (title = 'Teller' or title = 'Head Teller');

-- 第二个子查询
select branch_id
from branch
where name = 'Woburn Branch';


-- 5.2.2 连续两次连接同一个表: 给同一张表起别名
select a.account_id, e.emp_id, b_a.name open_branch, b_e.name emp_branch
from account a inner join branch b_a
	on b_a.branch_id = a.open_branch_id
    inner join employee e
    on a.open_emp_id = e.emp_id
    inner join branch b_e
    on e.assigned_branch_id = b_e.branch_id
where a.product_cd = 'CHK';


-- 5.3 自连接
-- employee表中, 列出自己的同时列出主管
select e.fname, e.lname, e_mgr.fname mgr_fname, e_mgr.lname mgr_lname
from employee e inner join employee e_mgr
	on e.superior_emp_id = e_mgr.emp_id;



-- 5.4 相等连接和不等连接
-- 不等连接: 找出所有在no-fee checking产品续存期间入职的雇员
-- select * from product where name = 'checking account';
-- select * from employee;
select e.emp_id, e.fname, e.lname, e.start_date
from employee e inner join product p
	on e.start_date >= p.date_offered 
		and e.start_date <= p.date_retired
where p.name = 'no-fee checking';


-- 不等的自连接: 举办面向银行柜员的象棋锦标赛, 要求创建所有对弈者的列表(返回emp_id不同的行)
select e1.fname, e1.lname, 'VS' vs, e2.fname, e2.lname
from employee e1 inner join employee e2
	on e1.emp_id != e2.emp_id
where e1.title = 'Teller' and e2.title = 'Teller';

-- 但是有一个错误! 每一对比赛选手都会有一个相反的选手对! (Frank Portman - Beth Fowler与 Beth Fowler - Frank Portman)!
-- 可以使用 e1.emp_id < e2.emp_id 而非 e1.emp_id != e2.emp_id
select e1.fname, e1.lname, 'VS' vs, e2.fname, e2.lname
from employee e1 inner join employee e2
	on e1.emp_id < e2.emp_id
where e1.title = 'Teller' and e2.title = 'Teller';



-- 5.5 连接条件与过滤条件
-- 查询用户的产品以及对应的联邦编号, 且客户的类型为'B'
select a.account_id, a.product_cd, c.fed_id
from account a inner join customer c
	on a.cust_id = c.cust_id
where c.cust_type_cd = 'B';

-- 将过滤条件放在了on中!!!
select a.account_id, a.product_cd, c.fed_id
from account a inner join customer c
	on a.cust_id = c.cust_id
		and c.cust_type_cd = 'B';

-- 省略on
select a.account_id, a.product_cd, c.fed_id
from account a inner join customer c
	where a.cust_id = c.cust_id
		and c.cust_type_cd = 'B';


-----------------------------------------------------------
-- Homework
-- 1. 查询雇员与所在分行信息
select e.emp_id, e.fname, e.lname, b.name
from employee e inner join branch b
	on e.assigned_branch_id = b.branch_id;


-- 2. 编写查询,返回所有非商务顾客的账户ID(customer.cust_type_cd = 'I')顾客的
-- 	联邦个人识别号码(customer.fed_id)以及账户所依赖的产品名称(product.name)
select c.fed_id, p.name
from customer c inner join account a
	on a.cust_id = c.cust_id
    inner join product p
    on p.product_cd = a.product_cd
where c.cust_type_cd = 'I';


-- 3. 构建查询,查找所有主管位于另一个部门的雇员,需要获取该雇员的ID、姓氏和名字
select e.emp_id, e.fname, e.lname
from employee e inner join employee e_mgr
	on e.superior_emp_id = e_mgr.emp_id
where e.dept_id != e_mgr.dept_id;



