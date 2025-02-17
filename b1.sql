create database ss13;
use ss13;

create table accounts(
	account_id int primary key auto_increment,
    account_name varchar(50) not null,
    balance decimal(10,2)
);

-- 2
INSERT INTO accounts (account_name, balance) VALUES 

('Nguyễn Văn An', 1000.00),

('Trần Thị Bảy', 500.00);
select * from accounts;
-- 3
set autocommit = 0;
delimiter &&
create procedure procedure_bai1(
	from_account int,
    to_account int,
    amount DECIMAL(10,2)
)
begin 
	start transaction;
    if(select balance from accounts where account_id = from_account) = 0
		or (select balance from accounts where account_id = from_account) < amount
			then rollback;
	else 
		update accounts
        set balance = balance - amount
        where account_id = from_account;
        
        update accounts
        set balance = balance + amount
        where account_id = to_account;
        commit;
	end if;
end &&
delimiter ;

call procedure_bai1(2, 1, 300.00);

drop procedure if exists procedure_bai1;