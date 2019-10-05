create table chapter4_homework
(
	txn_id smallint(10) unsigned auto_increment,
    txn_date date,
    account_id smallint(10) unsigned,
    txn_type_cd char(3),
    amount double(6,2),
    
    constraint pk_txn_id primary key(txn_id)
);

insert into chapter4_homework
(txn_date, account_id, txn_type_cd, amount)
values
('2005-02-22', 101, 'CDT', 1000.00),
('2005-02-23', 102, 'CDT', 525.75),
('2005-02-24', 101, 'DBT', 100.00),
('2005-02-24', 103, 'CDT', 55),
('2005-02-25', 101, 'DBT', 50),
('2005-02-25', 103, 'DBT', 25),
('2005-02-25', 102, 'CDT', 125.37),
('2005-02-26', 103, 'DBT', 10),
('2005-02-27', 101, 'CDT', 75);

select * from chapter4_homework;
