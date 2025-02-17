CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(50)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100),
    available_seats INT NOT NULL
);

CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
INSERT INTO students (student_name) VALUES ('Nguyễn Văn An'), ('Trần Thị Ba');

INSERT INTO courses (course_name, available_seats) VALUES 
('Lập trình C', 25), 
('Cơ sở dữ liệu', 22); 

-- 2
CREATE TABLE enrollments_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    action VARCHAR(50) NOT NULL CHECK (action IN ('REGISTERED', 'FAILED')),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- 3
set autocommit = 0;
delimiter &&
create procedure procedure_bai6(
    in p_student_name varchar(50),
    in p_course_name varchar(100)
)
begin
    declare v_student_id int;
    declare v_course_id int;
    declare v_available_seats int;
    declare v_enrollment_exists int default 0;
    start transaction;
    select student_id into v_student_id from students where student_name = p_student_name limit 1;
    select course_id, available_seats into v_course_id, v_available_seats 
    from courses where course_name = p_course_name limit 1;
    select count(*) into v_enrollment_exists 
    from enrollments 
    where student_id = v_student_id and course_id = v_course_id;

    if v_enrollment_exists > 0 then
        rollback;
        select 'sinh viên đã đăng ký môn học này!' as message;
    else
        if v_available_seats > 0 then
            insert into enrollments (student_id, course_id) values (v_student_id, v_course_id);

            update courses set available_seats = available_seats - 1 where course_id = v_course_id;

            insert into enrollments_history (student_id, course_id, action) 
            values (v_student_id, v_course_id, 'registered');

            commit;
            select 'đăng ký thành công!' as message;
        else
            insert into enrollments_history (student_id, course_id, action) 
            values (v_student_id, v_course_id, 'failed');

            rollback;
            select 'đăng ký thất bại do hết chỗ!' as message;
        end if;
    end if;
end &&
delimiter ;

call procedure_bai6('nguyễn văn an', 'lập trình c');
call procedure_bai6('trần thị ba', 'cơ sở dữ liệu');

select * from enrollments;
select * from courses;
select * from enrollments_history;