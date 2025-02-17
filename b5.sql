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

INSERT INTO company_funds (balance) VALUES (50000.00);

INSERT INTO employees (emp_name, salary) VALUES
('Nguyễn Văn An', 5000.00),
('Trần Thị Bốn', 4000.00),
('Lê Văn Cường', 3500.00),
('Hoàng Thị Dung', 4500.00),
('Phạm Văn Em', 3800.00);
-- 2
create table transaction_log (
    log_id int primary key auto_increment,
    log_message text not null,
    log_time timestamp default current_timestamp
);

-- 3
alter table employees add column last_pay_date date null;

set autocommit = 0;
delimiter &&
create procedure procedure_bai5(p_emp_id int)
begin
    declare v_salary decimal(10,2);
    declare v_balance decimal(15,2);
    declare v_exists int;
    declare v_today date;
    set v_today = curdate();
    select count(*) into v_exists from employees where emp_id = p_emp_id;
    
    if v_exists = 0 then
        insert into transaction_log (log_message) values (concat('nhân viên không tồn tại: ', p_emp_id));
        signal sqlstate '45000' set message_text = 'nhân viên không tồn tại';
    end if;
    select salary into v_salary from employees where emp_id = p_emp_id;
    select balance into v_balance from company_funds;
    if v_balance < v_salary then
        insert into transaction_log (log_message) values ('quỹ không đủ tiền.');
        signal sqlstate '45000' set message_text = 'quỹ không đủ tiền';
    end if;

    start transaction;
    update company_funds
    set balance = balance - v_salary;

    insert into payroll (emp_id, salary, pay_date)
    values (p_emp_id, v_salary, v_today);

    update employees
    set last_pay_date = v_today
    where emp_id = p_emp_id;

    insert into transaction_log (log_message) values (concat('chuyển lương thành công cho nhân viên ', p_emp_id));
    commit;
end &&
delimiter ;

call procedure_bai5(1); 