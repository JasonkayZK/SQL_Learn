-- 十二章. 事务
-- 12.1.1 锁: 读锁和写锁
-- 12.1.2 锁的粒度: 表锁/页锁/行锁


-- 12.2 什么是事务

-- 12.2.1 启动事务
-- MySQL中默认为自动提交模式, 单个语句会被服务器自动提交!
-- 允许为单个会话关闭自动提交!
set autocommit = 0;

-- 显式启动事务
start transaction;

-- 结束事务
commit;

-- 回滚事务
rollback;


-- 除了commit和rollback, 其他结束事务:
-- 1. 服务器宕机, 重启后会自动回滚事务
-- 2. 提交一个DML, 如: alter table, 会提交当前事务, 并开启一个新事物
-- 3. 提交另一个start transaction, 会引起当前事务提交
-- 4. 服务器检测到死锁, 并确定由当前事务引起



-- 12.2.3 事务保存点
-- 可以在事务内创建一个或者多个保存点, 可以利用他们回滚到事务的特定位置而不必一路回滚到事务启动状态
-- 可以为单个表选择存储引擎:
-- MyISAM, MEMORY, BDB, InnoDB, Merge, Maria, Falcon, Archive

-- 查看表的存储引擎
-- show table;
show table status like 'transaction';

-- 指定存储引擎
alter table transaction ENGINE = InnoDB;

-- 创建保存点
savepoint my_savepoint;

-- 回滚到特定保存点
rollback to savepoint my_savepoint;


-- 例:
start transaction;

update product
set date_retired = current_timestamp()
where product_cd = 'XYZ';

savepoint before_close_accounts;

update account
set status = 'CLOSED', close_date = current_timestamp(),
	last_activity_date = current_timestamp()
where product_cd = 'XYZ';

rollback to savepoint before_close_accounts;
commit;


-- 注:
-- 1. 创建保存点时, 除了名字什么都没有保存. 
-- 2. 为保证事务的持久化, 必须最终发出一个commit命令
-- 3. 如果读者发出一个没有保存点的rollback命令, 所以保存点被忽略, 并撤销整个事务!



-- -----------------------------------------------
-- 1. 生成一个事务,它从 Frank Tucker的货币市场账户存款转账$50到他的支票账户。要求
-- 	插入两行到 transaction并更新account表中相应的两行内容。






















