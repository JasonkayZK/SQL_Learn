-- 十五章 元数据
-- 数据库服务器也存储创建的表, 视图, 索引等对象
-- 在创建一个包含多列的表而言, 数据库将保存:
-- 表名, 表存储信息, 存储引擎, 列名, 索引, 主键.....
-- 这些数据被称为数据字典或者系统目录.

-- 每个数据库用不同的机制提供元数据:
-- Oracle: 视图, 系统存储过程: SQL Server, Mysql: 特殊数据库- information_schema

-- 15.2 信息模式
-- information_schema数据库所有可用对象都是视图
-- 例: 检索bank数据库所有表的名字
select table_name, table_type
from information_schema.TABLES
where TABLE_SCHEMA = 'bank'
order by 1;

-- 排除视图
select table_name, table_type
from information_schema.TABLES
where TABLE_SCHEMA = 'bank' and TABLE_TYPE = 'BASE TABLE'
order by 1;

-- 只对视图感兴趣
select table_name, is_updatable
from information_schema.VIEWS
where TABLE_SCHEMA = 'bank'
order by 1;


-- 查询表的列信息
-- ORDINAL_POSITION按照列添加的顺序检索列
select *
from information_schema.COLUMNS
where TABLE_SCHEMA = 'bank' and TABLE_NAME = 'account'
order by ORDINAL_POSITION;


-- 查询表的列的索引信息
select *
from information_schema.STATISTICS
where TABLE_SCHEMA = 'bank' and TABLE_NAME = 'account';


-- 查询约束
select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_SCHEMA = 'bank';




-- 15.3 使用元数据
-- 15.3.1 模式生成脚本
-- 生成数据库脚本
-- 例: 重新构建创建bank.customer的脚本
-- 1. 查询information_schema.columns检索表中列信息
select 'CREATE TABLE customer (' create_table_statement
union all
select cols.txt
from 
	(
		select concat('  ', column_name, ' ', column_type,
			case
				when is_nullable = 'NO' THEN ' not null'
                else ''
			end,
            case 
				when extra is not null then concat(' ', extra)
                else ''
			end,
            ','
        ) txt
        from information_schema.COLUMNS
        where TABLE_SCHEMA = 'bank' and TABLE_NAME = 'customer'
        order by ORDINAL_POSITION
    ) cols
union all
select ')';
    
-- 2. 添加约束内容
select 'CREATE TABLE customer (' create_table_statement
union all
select cols.txt
from 
	(
		select concat('  ', column_name, ' ', column_type,
			case
				when is_nullable = 'NO' THEN ' not null'
                else ''
			end,
            case 
				when extra is not null then concat(' ', extra)
                else ''
			end,
            ','
        ) txt
        from information_schema.COLUMNS
        where TABLE_SCHEMA = 'bank' and TABLE_NAME = 'customer'
        order by ORDINAL_POSITION
    ) cols
union all
select concat(' constraint primary key (')
from information_schema.TABLE_CONSTRAINTS
where TABLE_SCHEMA = 'bank' and TABLE_NAME = 'customer'
	and CONSTRAINT_TYPE = 'PRIMARY KEY'
union all
select cols.txt
from (
	select concat(
		case when ORDINAL_POSITION > 1 then ' ,'
		else '  ' end,
        COLUMN_NAME
    ) txt
    from information_schema.KEY_COLUMN_USAGE
    where TABLE_SCHEMA = 'bank' and TABLE_NAME = 'customer'
		and CONSTRAINT_NAME = 'PRIMARY'
	order by ORDINAL_POSITION
) cols
union all
select ' )'
union all
select ')';



-- 15.3.2 部署验证
-- 部署脚本运行之后, 可以推荐运行验证脚本来确保构建是正确的!
select tb1.table_name,
	(
		select count(*)
        from information_schema.COLUMNS clm
        where clm.table_schema = tb1.table_schema
			and clm.table_name = tb1.table_name
    ) num_columns,
    (
		select count(*)
        from information_schema.STATISTICS sta
        where sta.table_schema = tb1.table_schema
			and sta.table_name = tb1.table_name
    ) num_indexes,
    (
		select count(*)
        from information_schema.TABLE_CONSTRAINTS tc
        where tc.table_schema = tb1.table_schema
			and tc.table_name = tb1.table_name
            and tc.constraint_type = 'PRIMARY KEY'
    ) num_primary_keys
from information_schema.tables tb1
where tb1.table_schema = 'bank' and tb1.table_type = 'BASE TABLE'
order by 1;



-- 15.3.3 生成动态SQL
-- prepare, execute, deallocate
-- 例如: 
-- 1. set 语句简单将字符串赋予变量qry;
-- 2. qry被prepare语句提交给数据库引擎(为了解析, 安全检查和优化)
-- 3. 调用execute执行语句
-- 4. 在调用execute执行完语句之后, 必须deallocate prepare关闭语句, 释放所有资源!
set @qry = 'SELECT cust_id, cust_type_cd, fed_id FROM customer';
prepare dynsql1 from @qry;
execute dynsql1;
deallocate prepare dynsql1;


-- 在查询中包含占位符, 也可以在运行时动态指定条件
set @qry = 'SELECT product_cd, name, product_type_cd, date_offered, 
	date_retired FROM product where product_cd = ?';
prepare dynsql2 from @qry;
set @prodcd = 'CHK';
execute dynsql2 using @prodcd;

set @prodcd = 'SAV';
execute dynsql2 using @prodcd;

deallocate prepare dynsql2;




-- ---------------------------------------------------------
-- Homework
-- 1. 编写一个查询, 列出bank列中的所有索引,要求结果包括表名
select distinct table_name, index_name
from information_schema.STATISTICS
where TABLE_SCHEMA = 'bank';




-- 2. 编写一个查询,生成的结果可以用于创建bank.employee表的所有索引。要求结果形式如下:
-- 	'ALTER TABLE <table_name> Add INDEX <index_name > (<column list>)'
....






