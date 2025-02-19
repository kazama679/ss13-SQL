create database ss13;
use ss13;

CREATE TABLE company_funds (
    fund_id INT PRIMARY KEY AUTO_INCREMENT,
    balance DECIMAL(15,2) NOT NULL -- Số dư quỹ công ty
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50) NOT NULL,   -- Tên nhân viên
    salary DECIMAL(10,2) NOT NULL    -- Lương nhân viên
);

CREATE TABLE payroll (
    payroll_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,                      -- ID nhân viên (FK)
    salary DECIMAL(10,2) NOT NULL,   -- Lương được nhận
    pay_date DATE NOT NULL,          -- Ngày nhận lương
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

create table transaction_log(
	log_id int primary key auto_increment, 
    log_message text not null,
    log_time timestamp default current_timestamp
);

-- 2
create table banks(
	bank_id int primary key auto_increment,
    bank_name varchar(100) not null,
    status enum('active', 'error') default 'active'
);

INSERT INTO company_funds (balance) VALUES (50000.00);

INSERT INTO employees (emp_name, salary) VALUES
('Nguyễn Văn An', 5000.00),
('Trần Thị Bốn', 4000.00),
('Lê Văn Cường', 3500.00),
('Hoàng Thị Dung', 4500.00),
('Phạm Văn Em', 3800.00);

-- 3
INSERT INTO banks (bank_id, bank_name, status) VALUES 

(1,'VietinBank', 'ACTIVE'),   

(2,'Sacombank', 'ERROR'),    

(3, 'Agribank', 'ACTIVE');   

-- 4
alter table company_funds add column bank_id int;
alter table company_funds 
add constraint fk_company_funds_bank 
foreign key (bank_id) references banks(bank_id);

-- 5
UPDATE company_funds SET bank_id = 1 WHERE balance = 50000.00;

INSERT INTO company_funds (balance, bank_id) VALUES (45000.00,2);

-- 6
delimiter &&
	create trigger CheckBankStatus
    before insert on payroll
	for each row
begin
    if (select b.status from banks b join company_funds c on b.bank_id = c.bank_id) = 'error' then 
		signal sqlstate '45000' set message_text = 'Ngân hàng đang lỗi';
    end if;
end &&
delimiter ;

-- 7
set autocommit = 0; 
delimiter &&
create procedure transfer_salary(p_emp_id int, fund_id_in int)
begin
    declare c_balance decimal(10,2);
    declare e_salary decimal(10,2);

    declare exit handler for sqlexception
    begin
        insert into transaction_log(log_message) values ('ngân hàng lỗi');
        rollback;
    end;

    start transaction;

    if (select count(emp_id) from employees where emp_id = p_emp_id) = 0 
    or (select count(fund_id) from company_funds where fund_id = fund_id_in) = 0 then
        insert into transaction_log(log_message) values ('nhân viên hoặc công ty không tồn tại');
        rollback;
    else
        select balance into c_balance from company_funds where fund_id = fund_id_in;
        select salary into e_salary from employees where emp_id = p_emp_id;

        if c_balance < e_salary then
            insert into transaction_log(log_message) values ('số dư tài khoản công ty không đủ');
            rollback;
        else
            update company_funds
            set balance = balance - e_salary
            where fund_id = fund_id_in;

            insert into transaction_log(log_message) values ('thanh toán lương thành công');

            insert into payroll(emp_id, salary, pay_date)
            values (p_emp_id, e_salary, curdate());

            update employees
            set last_pay_date = curdate()
            where emp_id = p_emp_id;

            commit;
        end if;
    end if;
end &&
delimiter ;

--  8
call TransferSalary(3,2);