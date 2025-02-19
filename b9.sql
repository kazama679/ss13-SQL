use ss13;

-- 2
create table account (
    acc_id int primary key auto_increment,
    emp_id int,
    bank_id int,
    amount_added decimal(15,2) default 0.00,
    total_amount decimal(15,2) default 0.00,
    foreign key (emp_id) references employees(emp_id),
    foreign key (bank_id) references banks(bank_id)
);

-- 3
INSERT INTO account (emp_id, bank_id, amount_added, total_amount) VALUES

(1, 1, 0.00, 12500.00),  

(2, 1, 0.00, 8900.00),   

(3, 1, 0.00, 10200.00),  

(4, 1, 0.00, 15000.00),  

(5, 1, 0.00, 7600.00);

-- 4
delimiter &&
create procedure transfer_salary_all()
begin
    declare done int default 0;
    declare v_emp_id int;
    declare v_salary decimal(15,2);
    declare v_bank_id int;
    declare v_balance decimal(15,2);
    declare cur cursor for 
        select emp_id, salary from employees;
    declare exit handler for sqlexception
    begin
        insert into transaction_log(log_message) values ('lỗi');
        rollback;
    end;
    start transaction;
    select balance, bank_id into v_balance, v_bank_id 
    from company_funds 
    where bank_id = (select bank_id from company_funds limit 1);
    if v_balance < (select sum(salary) from employees) then
        insert into transaction_log(log_message) values ('số dư công ty không đủ');
        rollback;
    else
        open cur;
        read_loop: loop
            fetch cur into v_emp_id, v_salary;
            if done then leave read_loop; end if;

            insert into payroll (emp_id, salary, pay_date) 
            values (v_emp_id, v_salary, curdate());

            update employees 
            set last_pay_date = curdate()
            where emp_id = v_emp_id;

            update company_funds 
            set balance = balance - v_salary
            where bank_id = v_bank_id;

            update account 
            set amount_added = v_salary, 
                total_amount = total_amount + v_salary
            where emp_id = v_emp_id;

        end loop;
        close cur;
        commit;
    end if;
end &&
delimiter ;

-- 4
call transfer_salary_all();

-- 5
select * from company_funds;
select * from payroll;
select * from account;
select * from transaction_log;