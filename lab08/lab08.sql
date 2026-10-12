-- Нидзий Д.В. ИНБО-21-23, Вариант 10
-- расширение: перемещения между складами.
-- таблицы: warehouses, inventory, transfers, transfer_items.

-- 2. создать таблицы.

create table lab.warehouses (
warehouse_id text not null,
warehouse_name text not null,
city text not null,
state text not null,
capacity int not null,
constraint pk_warehouses primary key (warehouse_id),
constraint ck_warehouses_capacity check (capacity > 0)
);

create table lab.inventory (
warehouse_id text not null,
product_id text not null,
qty int not null,
updated_at timestamp not null default now(),
constraint pk_inventory primary key (warehouse_id, product_id),
constraint fk_inventory_warehouse foreign key (warehouse_id) references lab.warehouses(warehouse_id),
constraint fk_inventory_product foreign key (product_id) references olist.products(product_id),
constraint ck_inventory_qty check (qty >= 0)
);

create table lab.transfers (
transfer_id text not null,
transfer_code text not null,
source_wh text not null,
dest_wh text not null,
created_at timestamp not null default now(),
constraint pk_transfers primary key (transfer_id),
constraint uq_transfers_code unique (transfer_code),
constraint fk_transfers_source foreign key (source_wh) references lab.warehouses(warehouse_id),
constraint fk_transfers_dest foreign key (dest_wh) references lab.warehouses(warehouse_id),
constraint ck_transfers_diff_wh check (source_wh <> dest_wh)
);

create table lab.transfer_items (
transfer_id text not null,
product_id text not null,
qty int not null,
constraint pk_transfer_items primary key (transfer_id, product_id),
constraint fk_transfer_items_transfer foreign key (transfer_id) references lab.transfers(transfer_id),
constraint fk_transfer_items_product foreign key (product_id) references olist.products(product_id),
constraint ck_transfer_items_qty check (qty > 0)
);

-- 5. тестовые данные.

insert into lab.warehouses (warehouse_id, warehouse_name, city, state, capacity) values
('W1','Склад Сан-Паулу','sao paulo','SP',10000),
('W2','Склад Рио','rio de janeiro','RJ',8000),
('W3','Склад Белу-Оризонти','belo horizonte','MG',5000),
('W4','Склад Порту-Алегри','porto alegre','RS',7000),
('W5','Склад Куритиба','curitiba','PR',6000);

insert into lab.inventory (warehouse_id, product_id, qty)
select 'W1', product_id, 50 from olist.products order by product_id limit 3;

insert into lab.inventory (warehouse_id, product_id, qty)
select 'W2', product_id, 30 from olist.products order by product_id offset 3 limit 2;

insert into lab.transfers (transfer_id, transfer_code, source_wh, dest_wh) values
('T001','TR-0001','W1','W2'),
('T002','TR-0002','W2','W3'),
('T003','TR-0003','W3','W4'),
('T004','TR-0004','W4','W5'),
('T005','TR-0005','W1','W5');

insert into lab.transfer_items (transfer_id, product_id, qty)
select 'T001', product_id, 10 from olist.products order by product_id limit 3;

insert into lab.transfer_items (transfer_id, product_id, qty)
select 'T002', product_id, 5 from olist.products order by product_id offset 3 limit 2;

-- 6. ошибочные insert/update — должны быть отклонены.

-- 6.1 отклонён по fk_inventory_product: несуществующий product_id.
-- insert into lab.inventory (warehouse_id, product_id, qty) values ('W1', 'no_such_product', 10);

-- 6.2 отклонён по ck_transfer_items_qty: qty <= 0.
-- insert into lab.transfer_items (transfer_id, product_id, qty) values ('T001', 'some_real_id', 0);

-- 6.3 отклонён по ck_transfers_diff_wh: источник и приёмник совпадают.
-- insert into lab.transfers (transfer_id, transfer_code, source_wh, dest_wh) values ('T999','TR-9999','W1','W1');

-- 6.4 отклонён по ck_warehouses_capacity: capacity <= 0.
-- update lab.warehouses set capacity = -100 where warehouse_id = 'W1';

-- 6.5 отклонён по uq_transfers_code: дубликат кода.
-- update lab.transfers set transfer_code = 'TR-0001' where transfer_id = 'T002';

-- 7. проверка через information_schema.

select tc.table_name, tc.constraint_name, tc.constraint_type
from information_schema.table_constraints tc
where tc.table_schema = 'lab'
and tc.table_name in ('warehouses','inventory','transfers','transfer_items')
order by tc.table_name, tc.constraint_type, tc.constraint_name;
