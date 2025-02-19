-- ví dụ với innodb (hỗ trợ Transaction và Foreign Key)

create table students (
    student_id int primary key auto_increment,
    student_name varchar(50) not null
) engine=innodb;

create table enrollments (
    enrollment_id int primary key auto_increment,
    student_id int,
    course_name varchar(100),
    foreign key (student_id) references students(student_id) on delete cascade
) engine=innodb;

start transaction;

insert into students (student_name) values ('Nguyễn Văn An');
set @student_id = last_insert_id(); 

insert into enrollments (student_id, course_name) values (@student_id, 'Lập trình C');

-- Xảy ra lỗi do khóa học không tồn tại
rollback;  -- Hủy toàn bộ giao dịch

select * from students; -- Không có dữ liệu, do rollback đã hủy thao tác trước đó.

/*
	Nếu xóa sinh viên khỏi bảng students, dữ liệu trong enrollments cũng bị xóa theo
    Nếu xảy ra lỗi trong quá trình đăng ký, dữ liệu sẽ không bị mất đồng bộ nhờ rollback
*/


-- ví dụ với myisam (k hỗ trợ Transaction & Foreign Key)
create table posts (
    post_id int primary key auto_increment,
    title varchar(255),
    content text
) engine=myisam;

create table comments (
    comment_id int primary key auto_increment,
    post_id int,
    comment_text text
) engine=myisam;

delete from posts where post_id = 1;
select * from comments where post_id = 1;

/*
	k có FOREIGN KEY, nếu bài viết bị xóa, các bình luận vẫn tồn tại mà không có bài viết cha
    Bình luận vẫn còn trong database dù bài viết đã bị xóa
*/


/*
	tuy vậy Tốc độ đọc ghi của innodb chậm hơn do hỗ trợ giao dịch, nhưng tốt hơn khi cập nhật nhiều và k hỗ trợ Full-text Search và kích thước dữ liệu chiếm nhiều hơn myisam
*/