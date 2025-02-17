CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50),
    price DECIMAL(10,2),
    stock INT NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products (product_name, price, stock) VALUES
('Laptop Dell', 1500.00, 10),
('iPhone 13', 1200.00, 8),
('Samsung TV', 800.00, 5),
('AirPods Pro', 250.00, 20),
('MacBook Air', 1300.00, 7);

select * from products;

-- 2
set autocommit = 0;
delimiter &&
create procedure procedure_bai2(
    p_product_id int,
    p_quantity int
)
begin 
    declare v_stock int;
    declare v_price decimal(10,2);
    select stock into v_stock from products where product_id = p_product_id;
    if v_stock < p_quantity then 
        rollback;
    else 
        select price into v_price from products where product_id = p_product_id;

        insert into orders(product_id, quantity, total_price)
        values (p_product_id, p_quantity, v_price * p_quantity);

        update products
        set stock = stock - p_quantity
        where product_id = p_product_id;

        commit;
    end if;
end &&
delimiter ;

call procedure_bai2(1, 5);
select * from products;
select * from orders;

drop procedure if exists procedure_bai2;