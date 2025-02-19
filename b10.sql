use ss13;

-- 2
CREATE TABLE course_fees (

    course_id INT PRIMARY KEY,

    fee DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE

);

CREATE TABLE student_wallets (

    student_id INT PRIMARY KEY,

    balance DECIMAL(10,2) NOT NULL DEFAULT 0,

    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE

);

-- 3
INSERT INTO course_fees (course_id, fee) VALUES

(1, 100.00), -- Lập trình C: 100$

(2, 150.00); -- Cơ sở dữ liệu: 150$

 

INSERT INTO student_wallets (student_id, balance) VALUES

(1, 200.00), -- Nguyễn Văn An có 200$

(2, 50.00);  -- Trần Thị Ba chỉ có 50$

-- 4
delimiter &&
create procedure enroll_student(
    in p_student_name varchar(50), 
    in p_course_name varchar(100)
)
begin
    declare v_student_id int;
    declare v_course_id int;
    declare v_balance decimal(10,2);
    declare v_fee decimal(10,2);
    declare v_available_seats int;
    declare v_student_status enum('ACTIVE','GRADUATED','SUSPENDED');
    start transaction;

    select student_id into v_student_id from students where student_name = p_student_name;
    if v_student_id is null then
        insert into enrollments_history (student_id, course_id, action) 
        values (null, null, 'FAILED: Student does not exist');
        rollback;
        signal sqlstate '45000' set message_text = 'Lỗi: Sinh viên không tồn tại.';
    end if;

    select status into v_student_status from student_status where student_id = v_student_id;
    if v_student_status <> 'ACTIVE' then
        insert into enrollments_history (student_id, course_id, action) 
        values (v_student_id, null, 'FAILED: Student is not active');
        rollback;
        signal sqlstate '45000' set message_text = 'Lỗi: Sinh viên không ở trạng thái ACTIVE.';
    end if;

    select course_id, available_seats into v_course_id, v_available_seats 
    from courses where course_name = p_course_name;
    if v_course_id is null then
        insert into enrollments_history (student_id, course_id, action) 
        values (v_student_id, null, 'FAILED: Course does not exist');
        rollback;
        signal sqlstate '45000' set message_text = 'Lỗi: Môn học không tồn tại.';
    end if;

    if exists (select 1 from enrollments where student_id = v_student_id and course_id = v_course_id) then
        insert into enrollments_history (student_id, course_id, action) 
        values (v_student_id, v_course_id, 'FAILED: Already enrolled');
        rollback;
        signal sqlstate '45000' set message_text = 'Lỗi: Sinh viên đã đăng ký môn này.';
    end if;

    if v_available_seats <= 0 then
        insert into enrollments_history (student_id, course_id, action) 
        values (v_student_id, v_course_id, 'FAILED: No available seats');
        rollback;
        signal sqlstate '45000' set message_text = 'Lỗi: Môn học đã hết chỗ.';
    end if;

    select balance into v_balance from student_wallets where student_id = v_student_id;
    select fee into v_fee from course_fees where course_id = v_course_id;

    if v_balance < v_fee then
        insert into enrollments_history (student_id, course_id, action) 
        values (v_student_id, v_course_id, 'FAILED: Insufficient balance');
        rollback;
        signal sqlstate '45000' set message_text = 'Lỗi: Sinh viên không đủ tiền để thanh toán học phí.';
    end if;
    
    insert into enrollments (student_id, course_id) values (v_student_id, v_course_id);
    update student_wallets set balance = balance - v_fee where student_id = v_student_id;
    update courses set available_seats = available_seats - 1 where course_id = v_course_id;
    insert into enrollments_history (student_id, course_id, action) 
    values (v_student_id, v_course_id, 'REGISTERED');
    commit;
end &&
delimiter ;

-- 5
call enroll_student('Nguyễn Văn An', 'Lập trình C');
call enroll_student('Trần Thị Ba', 'Cơ sở dữ liệu');

-- 6
select * from student_wallets;