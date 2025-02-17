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

set autocommit = 0;
delimiter &&
create procedure procedure_bai3(
    p_emp_id INT
)
begin 
    declare v_balance decimal(15,2);
    declare v_salary decimal(10,2);
    declare v_bank_error int default 0; -- mac dinh la k loi
    select balance into v_balance from company_funds;
    select salary into v_salary from employees where emp_id = p_emp_id;
    if v_balance < v_salary then
        rollback;
    else
        start transaction;

        update company_funds
        set balance = balance - v_salary;

        insert into payroll(emp_id, salary, pay_date)
        values (p_emp_id, v_salary, CURDATE());

        if v_bank_error = 1 then
            rollback; 
        else
            commit; 
        end if;
    end if;
end &&
delimiter ;

call procedure_bai3(1);

select * from company_funds;
select * from employees;
select * from payroll;