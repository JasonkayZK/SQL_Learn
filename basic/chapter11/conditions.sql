-- 十一章. 条件逻辑
-- 11.1 什么是条件逻辑
-- 例如: 检查用户信息时, 希望通过客户类型决定:
-- 	从individual表检索fname和lname, 还是business表检索name
select c.cust_id, c.fed_id, c.cust_type_cd,
	concat(i.fname, ' ', i.lname) indiv_name,
    b.name business_name
from customer c left outer join individual i
	on c.cust_id = i.cust_id
    left outer join business b
    on c.cust_id = b.cust_id;


-- 通过case表达式使用条件逻辑决定客户类型, 进而返回适当的表达式
select c.cust_id, c.fed_id,
	case
		when c.cust_type_cd = 'I'
			then concat(i.fname, ' ', i.lname)
		when c.cust_type_cd = 'B'
			then b.name
		else 'Unknown'
	end name
from customer c left outer join individual i
	on c.cust_id = i.cust_id
    left outer join business b
    on c.cust_id = b.cust_id;



-- 11.2 case表达式
-- 11.2.1 查找型case表达式
-- 语法
-- CASE
-- 	WHEN C1 THEN E1
--     WHEN C2 THEN E2
--     ... 
--     WHEN CN THEN EN
--     [ELSE ED]
-- END
-- 1. when子句所有表达式返回的计算结果必须类型相同!
-- 2. 只要有一个when子句为真, 就会返回相应的表达式, 同时忽略其他表达式!!
-- 3. 如果没有when子句条件为真, 返回else子句的表达式!

-- 例: when中返回子查询
-- 没有在主查询使用连接, 只在必要时进行连接!!
select c.cust_id, c.fed_id,
	case
		when c.cust_type_cd = 'I' then (
			select concat(i.fname, ' ', i.lname)
            from individual i
            where i.cust_id = c.cust_id
		)
        when c.cust_type_cd = 'B' then (
			select b.name
            from business b
            where b.cust_id = c.cust_id
        )
		else 'Unknown'
	end name
from customer c;



-- 11.2.2 简单case表达式[不推荐]
-- 语法
-- CASE V0
-- 	WHEN V1 THEN E1
--     WHEN V2 THEN E2
--     ...
--     WHEN VN THEN EN
--     [ELSE ED]
-- END
-- V1-VN代表要与V0比较的值!
-- 此时when是提供要与V0比较的值, 而不是自己构建条件!!!
-- 简单case表达式灵活性很差!!!
select c.cust_id, c.fed_id,
	case c.cust_type_cd
		when 'I' then (
			select concat(i.fname, ' ', i.lname)
            from individual i
            where i.cust_id = c.cust_id        
        )
        when 'B' then (
        	select b.name
            from business b
            where b.cust_id = c.cust_id
        )
        else 'Unknown Customer Type'
	end name
from customer c;




-- 11.3 CASE表达式范例
-- 11.3.1 结果集变换
-- 对有限集进行聚合时(一周中的天数等), 希望结果集每个值一个列而不是每个值一行
-- 例: 从2000-2005年开户数目
select year(open_date) year, count(*) how_many
from account
where open_date > '1999-12-31'
	and open_date < '2006-01-01'
group by year(open_date);



-- 返回单行6列
select 
	sum (
		case 
			when extract(year from open_date) = 2000 then 1
			else 0
		end
    ) year_2000,
	sum (
		case 
			when extract(year from open_date) = 2001 then 1
			else 0
		end
    ) year_2001,
	sum (
		case 
			when extract(year from open_date) = 2002 then 1
			else 0
		end
    ) year_2002,
	sum (
		case 
			when extract(year from open_date) = 2003 then 1
			else 0
		end
    ) year_2003,
	sum (
		case 
			when extract(year from open_date) = 2004 then 1
			else 0
		end
    ) year_2004,    
	sum (
		case 
			when extract(year from open_date) = 2005 then 1
			else 0
		end
    ) year_2005
from account
where open_date > '1999-12-31' and open_date < '2006-01-01';



-- 11.3.2 选择性聚合
-- 查找账户余额与transaction表中的原始数据不相符的账户
select concat('ALERT! Account #', a.account_id, ' has INCORRECT balance!')
from account a
where (a.avail_balance, a.pending_balance) != (
	select sum(
		case 
			when t.funds_avail_date > current_timestamp()
				then 0
			when t.txn_type_cd = 'DBT'
				then t.amount * -1
			else t.amount
		end
    ), 
    sum(
		case 
			when t.txn_type_cd = 'DBT'
				then t.amount * -1
			else t.amount
		end
    )
    from transaction t
    where t.account_id = a.account_id
);



-- 11.3.3 存在性检查
-- 确定两个实体之间是否存在某种关系而并不关心数量
-- 例: 显示客户是否有支票账户, 是否有储蓄账户
select c.cust_id, c.fed_id, c.cust_type_cd,
	case 
		when exists (
			select 1
            from account a
            where a.cust_id = c.cust_id
				and a.product_cd = 'CHK'
        ) then 'Y'
        else 'N'
	end has_checking,
    case
		when exists (
			select 1
            from account a
            where a.cust_id = c.cust_id
				and a.product_cd = 'SAV'
		) then 'Y'
		else 'N'
	end has_savings
from customer c;


-- 简单为客户计算账户数目
select c.cust_id, c.fed_id, c.cust_type_cd,
	case (
		select count(*)
        from account a
        where a.cust_id = c.cust_id
    )
		when 0 then 'None'
        when 1 then '1'
        when 2 then '2'
        else '3+'
	end num_accounts
from customer c;



-- 11.3.4 除零错误
-- 除法运算时, 分母永远不得为0!
-- 对于Oracle来说分母为0抛出错误, 而MySQL则是简单将结果置为null!
select 100 / 0 from dual;


-- 为了保证计算不遇到错误或者其他更糟糕的情况,也不会被莫名其妙地置为null值
-- 应该将所有分母包装在条件逻辑里! 如下所示!
-- 这个查询计算同一产品类型的所有账户的每个账户余额与总余额的比率
select a.cust_id, a.product_cd, a.avail_balance / 
	case
		when prod_tots.tot_balance = 0 then 1
        else prod_tots.tot_balance
	end percent_of_total
from account a inner join (
	select a.product_cd, sum(a.avail_balance) tot_balance
    from account a
    group by a.product_cd
) prod_tots
on a.product_cd = prod_tots.product_cd;




-- 11.3.5 有条件更新
-- 决定指定的列应该置什么值
-- 某个用户插入一个新的交易之后, 需要修改
-- account表中的avail_balance, pending_balance, last_activity_date列
-- 此时: 必须通过检查transaction表中的funds_avail_date判断交易资金是否立即可用!
update account 
set last_activity_date = current_timestamp(),
	pending_balance = pending_balance + (
			select t.amount *
				case t.txn_type_cd
					when 'DBT' then -1
                    else 1
				end
            from transaction t
            where t.txn_id = 999
	),
	avail_balance = avail_balance + (
		select 
			case 
				when t.funds_avail_date > current_timestamp() then 0
                else  t.amount *
					case t.txn_type_cd
						when 'DBT' then -1
                        else 1
					end
			end				
		from transaction t
        where t.txn_id = 999
    )
where account.account_id = (
	select t.account_id
    from transaction t
    where t.txn_id = 999
);




-- 11.3.6 null值处理
select emp_id, fname, lname,
	case
		when title is null then 'Unknown'
        else title
	end e_title
from employee;


-- 计算中null将会导致一个null错误!
select (7 * 5) / ((3 + 14) * null);



-- ------------------------------------------
-- Homework
-- 1. 重写下面的查询,要求使用查找型case表达式替换简单case表达式,并且查询结果相同。
-- 	请读者尽可能少使用when子句
SELECT emp_id,
	CASE title
		WHEN 'President' THEN 'Management'
		WHEN 'Vice President' THEN 'Management'
		WHEN 'Treasurer' THEN 'Management'
		WHEN 'Loan Manager' THEN 'Management'
		When 'Operations Manager' then 'Operations'
		WHEN 'Head Teller' THEN 'Operations'
		When 'Teller' then 'Operations'
		ELSE 'Unknown'
	END
FROM employee;


select emp_id,
	case
		WHEN title in ('President', 'Vice President', 'Treasurer', 'Loan Manager') THEN 'Management'
        WHEN title in ('Operations Manager', 'Head Teller', 'Teller') THEN 'Operations'
        ELSE 'Unknown'
	end
from employee;




-- 2. 重写下面的查询,要求结果集为单行4列(每个分行1列)的
-- 	其中4列分别以branch_1~branch_4命名。
SELECT open_branch_id, COUNT(*)
FROM account
GROUP BY open_branch_id;


select
	sum(
		case
			when open_branch_id = 1 then 1
            else 0
		end
    ) branch_1,
	sum(
		case
			when open_branch_id = 2 then 1
            else 0
		end
    ) branch_2,
	sum(
		case
			when open_branch_id = 3 then 1
            else 0
		end
    ) branch_3,
	sum(
		case
			when open_branch_id = 4 then 1
            else 0
		end
    ) branch_4    
from account




