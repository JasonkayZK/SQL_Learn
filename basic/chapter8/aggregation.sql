-- 第八章 分组与聚合
-- 8.1 分组概念
-- 查询每个柜员创建了多少个用户
select open_emp_id from account;

select open_emp_id 
from account
group by open_emp_id;

select open_emp_id, count(*) how_many
from account
group by open_emp_id;

-- 想要在结果集中对分组数据进行过滤而不是原始数据
-- 由于group by 在where子句被评估之后运行, 所以无法对where增加过滤条件!!!
-- 例如: 过滤掉账户小于5个的职员
select open_emp_id, count(*) how_many
from account
where count(*) > 4
group by open_emp_id;

-- 不应当在where中使用聚合函数, 而在having中!!!
select open_emp_id, count(*) how_many
from account
group by open_emp_id
having count(*) > 4;



-- 聚合函数
-- 对某个分组的所有行执行特定的操作!
-- max
-- min
-- avg
-- sum
-- count

-- 例如: 分析所有核算账号(checking account)的可用余额
select max(avail_balance) max_balance,
	min(avail_balance) min_b,
    avg(avail_balance) avg_b,
    sum(avail_balance) tot_b,
	count(*) num_accounts
from account
where product_cd = 'CHK';



-- 8.2.1 隐式与显式分组
-- 在没有使用GROUP by时, 默认是一个隐式分组(包含查询返回的所有行!)
-- 例: 为每种产品类型执行5种聚合函数
-- 报错未显式指定分组
select product_cd,
	max(avail_balance) max_balance,
	min(avail_balance) min_b,
    avg(avail_balance) avg_b,
    sum(avail_balance) tot_b,
	count(*) num_accounts
from account;

select product_cd,
	max(avail_balance) max_balance,
	min(avail_balance) min_b,
    avg(avail_balance) avg_b,
    sum(avail_balance) tot_b,
	count(*) num_accounts
from account
group by product_cd;


-- 8.2.2 对独立值计数
-- count() 当使用count()确定每个分组成员数目时, 可以选择是对分组中所有成员计数还是只计数某个列的不同值!
-- 例: 为每个账户开户的雇员信息
select account_id, open_emp_id
from account
order by open_emp_id;

-- 不计算独立值相当于count(*)
select count(open_emp_id) from account;

-- 使用distinct count() 去除发生重复的行
select count(distinct open_emp_id) from account;


-- 8.2.3 使用表达式
-- 表达式可以任意复杂度, 只要保证最后返回一个数字, 字符串, 日期即可!
-- 例: 找到账户中pending deposit(pending balance - available balance)的最大值
select max(pending_balance - avail_balance) max_uncleared
from account;



-- 8.2.4 如何处理null值
-- 当执行聚合或者其他数值计算时, 应当首先考虑null值是否会影响到计算结果!
create table number_tb1(
	val smallint
);
insert into number_tb1 values(1);
insert into number_tb1 values(3);
insert into number_tb1 values(5);


-- 表中无null做一次查询
select count(*) num_rows,
	count(val) num_vals,
    sum(val) total,
    max(val) max_val,
    avg(val) avg_val
from number_tb1;


insert into number_tb1 values(null);
-- 表中有null做一次聚合查询
-- 此时指定val的聚合函数将会忽略null值! 而count(*)不会忽略null值(对内部id计数, 一定不为null!)
select count(*) num_rows,
	count(val) num_vals,
    sum(val) total,
    max(val) max_val,
    avg(val) avg_val
from number_tb1;



-- 8.3 产生分组
-- 8.3.1 对单列分组
-- 例: 对每种产品的余额总计
select product_cd, sum(avail_balance) prod_balance
from account
group by product_cd;


-- 8.3.2 对多列的分组
-- 例: 在各个支行对每种产品的余额总计
select product_cd, open_branch_id, sum(avail_balance) tot_balace
from account
group by product_cd, open_branch_id;



-- 8.3.3 利用表达式分组
-- 例: 根据职员入职年份对职员分组
select extract(year from start_date) year,
	count(*) how_many
from employee
group by extract(year from start_date);



-- 8.3.4 产生合计数
-- 例: 为每种产品-支行组计算合计余额的同时, 还需要为每种产品单独计算合计数(与支行无关)
-- 可以
-- 1. 增加一个附件查询将结果合并
-- 2. 使用Java等取出数据在执行
-- 3. 使用with rollup请求数据库服务器完成
select product_cd, open_branch_id, sum(avail_balance) tot_balance
from account
group by product_cd, open_branch_id with rollup;


-- 还有为每个支行计算合计使用with cube(mysql还不支持!!)
select product_cd, open_branch_id, sum(avail_balance) tot_balance
from account
group by product_cd, open_branch_id with cube;



-- 8.4 分组过滤条件 having
-- 在产生分组后对数据应用过滤条件
select product_cd, sum(avail_balance) prod_balance
from account
where status = 'ACTIVE'
group by product_cd
having sum(avail_balance) >= 10000;


-- 还可以在having中包含未在select中出现的聚合函数
-- 例: 为每种活动的产品产生余额总计, 并过滤所有最小余额低于1000或大于10000的产品
select product_cd, sum(avail_balance) prod_balance
from account
where status = 'ACTIVE'
group by product_cd
having min(avail_balance) >= 1000
	and max(avail_balance) <= 10000;




-- -----------------------------------------
-- Homework
-- 1. 构建查询, 对account表的数据行计数
select count(*)
from account;



-- 2. 修改练习8-1中的查询,使之对每个客户所持有的账户计数,并且显示每个客户的ID及其账户数。
select cust_id, count(*)
from account
group by cust_id;



-- 3. 修改练习8-2的查询,使之只包含至少持有两个账户的客户。
select cust_id, count(*)
from account
group by cust_id
having count(*) >= 2;



-- 4. 查找至少包含一个账户的产品和支行组合的可用余额合计数,并根据余额合计数对结果进行排序(从最高到最低)
select product_cd, open_branch_id, sum(avail_balance)
from account
group by product_cd, open_branch_id
having count(*) > 1
order by sum(avail_balance) desc;


