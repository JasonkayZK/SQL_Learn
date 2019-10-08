-- 附录B MySQL对SQL语言的扩展
-- B.1 扩展select
-- B.1.1 limit: 限制查询返回的行数
-- limit子句应用在所有过滤, 分组, 排序动作之后!!
-- 例: 
select open_emp_id, count(*) how_many
from account
group by open_emp_id;

select open_emp_id, count(*) how_many
from account
group by open_emp_id
limit 3;


-- 组合limit和order by子句
-- 例: 先排序再limit
select open_emp_id, count(*) how_many
from account
group by open_emp_id
order by how_many desc
limit 3;


-- limit子句中可选的第二个参数
-- 第一个参数指定结果集的起始记录, 第二个参数指定结果集包含的记录数!
-- MySQL中指定第一个记录序号为0!!!!!!
-- 例: 查找第三个表现好的人
select open_emp_id, count(*) how_many
from account
group by open_emp_id
order by how_many desc
limit 2, 1;


-- 查找前两个以外的所有柜员
select open_emp_id, count(*) how_many
from account
group by open_emp_id
order by how_many desc
limit 2, 9999999999;


-- 排名查询: order by + limit
-- 例: 前两个最差柜员
select open_emp_id, count(*) how_many
from account
group by open_emp_id
order by how_many asc
limit 2;


-- B.1.2 into outfile子句
-- 将查询语句的结果写到一个文件中
select emp_id, fname, lname, start_date
into outfile '/home/zk/workspace/SQL_Learn/appendix/emp_list.txt'
from employee;


-- 使用fields子句要求每列之间使用字符'|'隔开
select emp_id, fname, lname, start_date
into outfile '/home/zk/workspace/SQL_Learn/appendix/emp_list.txt'
	fields terminated by '|'
from employee;




-- B.2 组合insert/update语句
-- 例: 创建一个表, 获取哪些客户访问了哪些分行这个信息
create table branch_usage
(
	branch_id smallint unsigned not null,
    cust_id integer unsigned not null,
    last_visited_on datetime,
    constraint pk_branch_usage primary key (branch_id, cust_id)
);

-- 上表定义了主键, 此时在第一次插入(1, 5)时会成功
-- 但是由于声明了主键约束, 所以第二次插入时会报无法插入的错误, 因为主键重复!
INSERT into branch_usage (branch_id, cust_id, last_visited_on)
values (1, 5, current_timestamp());

-- 此时可通过insert ... on duplicate key update完成insert-update
-- 首次为插入, 后面为更新!
-- 在MySQL4.1之前, 有replace, 但是replace会执行删除操作, 如果设置了级联约束on delete cascade, 则会删除很多表!
-- 而使用insert ... on duplicate key update更为安全!
insert into branch_usage (branch_id, cust_id, last_visited_on)
values (1, 5, current_timestamp())
on duplicate key update last_visited_on = current_timestamp();



-- B.3 按排序更新和删除
-- MySQL还允许在update和delete语句中使用limit和order by
-- 因此可以实现在表中根据次序删除或者修改特定行!

-- 例: 仅保留顾客最近50条记录的表
create table login_history
(
	cust_id integer unsigned not null,
    login_date datetime,
    constraint pk_login_history primary key (cust_id, login_date)
);

-- 添加一些数据: 
-- 来源于account表和customer表交叉连接, 并使用account的open_date作为产生登录日期
insert into login_history (cust_id, login_date)
select c.cust_id,
	adddate(a.open_date, interval a.account_id * c.cust_id hour)
from customer c cross join account a;


-- 查询最近的第50条记录
select login_date
from login_history
order by login_date desc
limit 49, 1;


-- 删除多余信息
delete from login_history
where login_date < '2004-07-02 21:00:00';


-- 使用扩展语法
-- 262必须提前计算出, 因为limit在delete与update中不允许提供第二个参数!
delete from login_history
order by login_date asc
limit 262;


-- 例二. 为开户最久的十个账号增加100源奖励
update account
set avail_balance = avail_balance + 100
where product_cd in ('CHK', 'SAV', 'MM')
order by open_date asc
limit 10;



-- 多表更新与删除
-- 将select 替换为delete, update 可以实现多表删除与更新!
-- 但是如果使用了InnoDB引擎, 将不能使用多表delete和update!
-- 因为引擎无法保证数据修改能够按照不破坏约束的次序执行!





