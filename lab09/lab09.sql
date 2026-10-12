-- Нидзий Д.В. ИНБО-21-23, Вариант 10
-- нормализация transfer_flat до 3НФ и НФБК.

drop table if exists lab.nf10_transfer_item cascade;
drop table if exists lab.nf10_transfer cascade;
drop table if exists lab.nf10_product cascade;
drop table if exists lab.nf10_warehouse cascade;
drop table if exists lab.nf10_transfer_flat cascade;

-- исходное плоское отношение.
create table lab.nf10_transfer_flat (
transfer_id text not null,
source_wh text not null,
source_city text not null,
dest_wh text not null,
dest_city text not null,
product_id text not null,
category_name text not null,
qty int not null,
created_at timestamp not null
);

insert into lab.nf10_transfer_flat values
('T001','W1','sao paulo','W2','rio de janeiro','P1','brinquedos',10,'2024-01-01'),
('T001','W1','sao paulo','W2','rio de janeiro','P2','moveis_decoracao',5,'2024-01-01'),
('T002','W2','rio de janeiro','W3','belo horizonte','P1','brinquedos',3,'2024-01-02'),
('T003','W3','belo horizonte','W1','sao paulo','P3','cama_mesa_banho',7,'2024-01-03'),
('T004','W1','sao paulo','W3','belo horizonte','P2','moveis_decoracao',4,'2024-01-04');

-- декомпозиция до 3НФ.
-- шаг 1: устраняем частичные зависимости: transfer_id -> source_wh, dest_wh, created_at; product_id -> category_name.
-- шаг 2: устраняем транзитивные: source_wh -> source_city, dest_wh -> dest_city.

create table lab.nf10_warehouse (
warehouse_id text not null,
city text not null,
constraint pk_nf10_warehouse primary key (warehouse_id)
);

create table lab.nf10_product (
product_id text not null,
category_name text not null,
constraint pk_nf10_product primary key (product_id)
);

create table lab.nf10_transfer (
transfer_id text not null,
source_wh text not null,
dest_wh text not null,
created_at timestamp not null,
constraint pk_nf10_transfer primary key (transfer_id),
constraint fk_nf10_transfer_source foreign key (source_wh) references lab.nf10_warehouse(warehouse_id),
constraint fk_nf10_transfer_dest foreign key (dest_wh) references lab.nf10_warehouse(warehouse_id),
constraint ck_nf10_transfer_diff_wh check (source_wh <> dest_wh)
);

create table lab.nf10_transfer_item (
transfer_id text not null,
product_id text not null,
qty int not null,
constraint pk_nf10_transfer_item primary key (transfer_id, product_id),
constraint fk_nf10_transfer_item_transfer foreign key (transfer_id) references lab.nf10_transfer(transfer_id),
constraint fk_nf10_transfer_item_product foreign key (product_id) references lab.nf10_product(product_id),
constraint ck_nf10_transfer_item_qty check (qty > 0)
);

-- тестовые данные: справочные значения хранятся один раз.
insert into lab.nf10_warehouse values
('W1','sao paulo'),
('W2','rio de janeiro'),
('W3','belo horizonte');

insert into lab.nf10_product values
('P1','brinquedos'),
('P2','moveis_decoracao'),
('P3','cama_mesa_banho');

insert into lab.nf10_transfer values
('T001','W1','W2','2024-01-01'),
('T002','W2','W3','2024-01-02'),
('T003','W3','W1','2024-01-03'),
('T004','W1','W3','2024-01-04');

insert into lab.nf10_transfer_item values
('T001','P1',10),
('T001','P2',5),
('T002','P1',3),
('T003','P3',7),
('T004','P2',4);

-- проверка: одинаковые города и категории теперь хранятся один раз.
select 'warehouses' as t, count(*) from lab.nf10_warehouse
union all select 'products', count(*) from lab.nf10_product
union all select 'transfers', count(*) from lab.nf10_transfer
union all select 'transfer_items', count(*) from lab.nf10_transfer_item;

-- проверка ограничений.
-- insert into lab.nf10_transfer values ('T999','W1','W1','2024-02-01'); -- ck_nf10_transfer_diff_wh
-- insert into lab.nf10_transfer_item values ('T001','P9',5); -- fk_nf10_transfer_item_product
-- insert into lab.nf10_transfer_item values ('T001','P1',0); -- ck_nf10_transfer_item_qty
