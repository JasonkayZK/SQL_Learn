set sql_safe_updates = 0;

-- 7.1 使用字符串数据
create table string_tb1
(
	char_fld char(30),
    vchar_fld varchar(30),
    text_fld text
);


-- 7.1.1 生成字符串
-- 使用单引号包括
insert into string_tb1
(char_fld, vchar_fld, text_fld)
values
('This is char data', 'This is varchar data', 'This is text data');



-- 向30长度字段插入46长度字符串(默认为 'strict'模式, 报错)
update string_tb1
set vchar_fld = 'This is a piece of extremely long varchar data';

-- 查看并修改为ansi模式
select @@session.sql_mode;
set sql_mode='ansi';

-- 重新执行, 并查看警告!
show warnings;
select vchar_fld from string_tb1;


-- 包含单引号
-- 可以使用两个''转义单个', mysql还可以使用\'转义
update string_tb1
set text_fld = 'This string didn''t work, but it does now!';

update string_tb1
set text_fld = 'This string didn\'t work, but it does now!';

select text_fld from string_tb1;

-- quote()函数
-- 如果使用 MySQL,可以使用内建的函数 quote
-- 它用单引号将整个字符串包含起来,并为字符串本身的单引号撤号增加转义符
select quote(text_fld) from string_tb1;


-- char()函数
-- 包含特殊字符
-- Mysql可用于从ASCII字符集中255个字符中任意构建字符串
select 'abcdefg', char(97, 98, 99, 100, 101, 102, 103);


-- concat()函数
-- 连接若干字符串, 也可以使用 ||连接
select concat('danke sch', 'n');
select 'danke sch' || 'n';


-- ascii()函数
-- 接收一个字符, 并返回序号
select ascii('4');



delete from string_tb1;
insert into string_tb1
(char_fld, vchar_fld, text_fld)
values
('This string is 28 characters', 'This string is 28 characters', 'This string is 28 characters');
-- 7.1.2 操作字符串
-- 返回数字的字符串函数
-- 1. length()
-- 注意char类型删除尾端空格返回长度!
select length(char_fld), length(vchar_fld), length(text_fld)
from string_tb1; 


-- 2. position()
-- 序号从1开始, 找不到返回0!
select position('characters' in vchar_fld)
from string_tb1;


-- 3. locate()
-- 与position相似, 支持第三个参数指定搜索开始的index
select locate('is', vchar_fld, 5)
from string_tb1;


-- 4. strcmp()
-- 比较字符串, 返回-1, 0, 1;
-- 大小写不敏感
select strcmp('abcd', 'ABCD');



-- 5. 在select中使用like和regexp比较字符串
-- 结果返回1-true, 0-false
select name, name like '%ns' ends_in_ns
from department;

-- 使用regexp
select cust_id, cust_type_cd, fed_id, fed_id regexp '.{3}-.{2}-.{4}' is_ss_no_format
from customer;



delete from string_tb1;
insert into string_tb1
(text_fld)
values
('This string was 29 characters');
-- 返回字符串的字符串函数
-- 1. concat()
-- 连接字符串
update string_tb1
set text_fld = concat(text_fld, ', but now it is longer');

select text_fld from string_tb1;

-- 为每个银行柜员产生简介
select fname || ' ' || lname || ' has been a ' || title || ' since ' || start_date emp_narrative
from employee
where title = 'Teller' or title = 'Head Teller';


-- 2. insert()函数
-- My SQL包含了insert()函数,它接受4个参数: 原始字符串、字符串操作的开始位置, 需要替换的字符数以及替换字符串。
-- 根据第三个参数值,函数可以选择插入或替换原始字符串中的字符。
-- 如果该参数值为0,那么替换字符串将会被插入其中,并且剩余的字符串会向右排放
select insert ('goodbye world', 9, 0, 'cruel') string;
select insert('goodbye world', 1, 7, 'hello') string;


-- 3. substring()函数
-- 从指定的位置开始提取指定数目的字符
select substring('goodbye cruel world', 9 ,5);



-- 7.2 使用数值数据
-- 如果数值型数据的精度大于所在列的指定长度,那么在其被存储时可能会发生取整操作。
-- 例如,数字9.96在被存放到定义为float(3,1)列时将会被取整为10.0
select (37 * 59) / (78 - (8 * 6));


-- 7.2.1 执行算数函数
-- Acos, Asin, sin
-- mod(): 求模运算
select mod(10, 4);
select mod(22.75, 5);

-- pow(): 幂计算
select pow(2, 8);



-- 7.2.2 控制数字精度
-- ceil, floor, round, truncate
select round(72.0909, 1), round(72.0909, 2), round(72.0909, 3);
select truncate(72.0909, 1), truncate(72.0909, 2), truncate(72.0909, 3);



-- 7.2.3 处理有符号数
-- sign, abs
-- sign: 负数返回-1, 0为0, 正数为1
select account_id, sign(avail_balance), abs(avail_balance)
from account;



-- 7.3 使用时间格式
-- 7.3.1 处理时区

-- 1. 返回当前UTC时间戳
select utc_timestamp() from dual;


-- 2. 时区设置: 全局时区和会话时区(每个登录用户不同)
-- 查看两种设置: system 表面服务器根据所在地使用相应的时区设置
select @@global.time_zone, @@session.time_zone;


-- 3. 设置当前会话市区
set time_zone = 'Europe/Zurich';


-- 7.3.2 生成时间数据
-- 可以使用下面任意一种方法产生时间数据:
-- 从已有的date、 datetime或time列中复制数据
-- 执行返回date、 datetime或tme型数据的内建函数;
-- 构建可以被服务器识别的代表日期的字符串


-- 日期格式
-- YYYY 年份 1000-9999
-- MM 月份 01-12
-- DD 日 1-31
-- HH 小时 00-23
-- HHH 小时(过去) -838-838
-- MI 分钟 00-59
-- SS 秒 00-69

-- 日期组件
-- Date YYYY-MM-DD
-- Datetime YYYY-MM-DD HH:MI:SS
-- Timestamp YYYY-MM-DD HH:MI:SS
-- Time HHH:MI:SS

-- 提供必须的正确格式的字符串
update transaction
set txn_date = '2008-09-17 15:30:00'
where txn_id = 99999;


-- 字符串到日期的转换
-- cast()函数
select cast('2008-09-17 15:30:00' as datetime);
select cast('2008-09-17' as date) date_field;
select cast('108:17:57' as time) time_field;


-- 产生日期的函数
-- str_to_date()
-- 需要根据字符串产生时间, 但是所提供的不是cast()函数所接受的格式,
-- 可以使用str_to_date()
-- 例如:
select str_to_date('September 17, 2008', '%M %d, %Y');

-- str_to_date()根据格式字符串的内容返回datetime, date或者time类型
-- 如: 格式字符串只包含%H, %i, %s将返回time值


-- 产生当前日期/时间
select current_date(), current_time(), current_timestamp();



-- 7.3.3 操作时间数据

-- 返回日期的时间函数
-- 1. date_add() 为指定日期增加时间间隔
select date_add(current_date(), interval 5 day);

select date_add(current_date(), interval -5 day);

select date_add(current_timestamp(), interval '3:27:11' hour_second);

select date_add(current_date(), interval '9-11' year_month);


-- 2. last_day() 求月最后一天
-- 不论所提供的参数为date还是datetime, 最终都返回date
select last_day('2008-02-17'), last_day('2007-02-17');


-- 3. convert_tz() 将某个时区的datetime转换为另一个时区
-- 例: 将本地时间转为UTC时间
select current_timestamp() current_est, convert_tz(current_timestamp(), '+00:00', '+08:00') current_utc;

-- 将UTC转为北京时间
select CONVERT_TZ("2018-12-25 12:25:00","+00:00","+08:00") as 北京时间;



-- 返回字符串的时间函数
-- 1. dayname() 确定某日期是星期几
select dayname('2008-09-18');

-- 2. extract() 提取日期中信息[推荐]
select extract(year from '2008-09-18 22:19:05');


-- 返回数字的时间函数
-- 1. datediff() 返回两个日期的间隔天数
-- datediff() 忽略参数中的时钟值!
-- 返回结果为arg1 - arg2, 交换两个参数将返回负值!
select datediff('2009-09-03', '2009-06-24');

select datediff('2009-09-03 23:59:59', '2009-06-24 00:00:01');

select datediff('2009-06-24', '2009-09-03');



-- 7.4 转换函数 cast()
-- 使用cast()时, 必须提供一个关键字的值或表达式, 以及所需要转换的类型
-- 当cast()将字符串转为数字时, 会从左向右试着对整个字符串进行转换, 在期间遇到非数字的字符, 会立即停止!
select cast('1456328' as signed integer);

select cast('999ABC111' as unsigned integer);

select cast('a999ABC111' as unsigned integer);

-- 如果需要将字符串转换为date, time或datetime类型的值就必须严格遵守每种类型的默认格式。
-- 如果待转换的日期字符串不是默认格式(比如 datetime类型为YYYY-MM-DD HH: MI:SS)
-- 那么首先需要使用其他函数将之重新排列,比如本章前面介绍的 MySQL的 str to date()函数!



-- ----------------------------
-- Homework
-- 1. 编写查询,返回字符串 'Please find the substring in this string' 的第17个和第25个字符
select substring('Please find the substring in this string', 17, 1), substring('Please find the substring in this string', 25, 1);



-- 2. 编写查询,返回数字-25.76823的绝对值与符号(-1、0或1),并将返回值四舍五入至百分位
select abs(-25.76823), sign(-25.76823), round(-25.76823, 2);



-- 3. 编写查询返回当前月期所在的月份
select extract(month from current_date());




