-- Нидзий Д.В. ИНБО-21-23, Вариант 10
-- множество S: AL, SE, BA

-- 1. Создать cte target_states из трёх значений своего варианта.
with target_states(state) as (
values ('AL'), ('SE'), ('BA')
)
select * from target_states;

-- 2. Реализовать условие "категория продавалась во всех штатах s" через двойной not exists.
with target_states(state) as (
values ('AL'), ('SE'), ('BA')
)
select p.product_category_name
from (select distinct product_category_name from olist.products where product_category_name is not null) p
where not exists (
select 1 from target_states ts
where not exists (
select 1 from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and c.customer_state = ts.state
and pr.product_category_name = p.product_category_name
)
)
order by p.product_category_name;

-- 3. Реализовать то же через group by / having count(distinct customer_state).
with target_states(state) as (
values ('AL'), ('SE'), ('BA')
)
select pr.product_category_name
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and pr.product_category_name is not null
and c.customer_state in (select state from target_states)
group by pr.product_category_name
having count(distinct c.customer_state) = (select count(*) from target_states)
order by pr.product_category_name;

-- 4. Реализовать то же через except и not exists.
with target_states(state) as (
values ('AL'), ('SE'), ('BA')
),
candidates as (
select distinct product_category_name from olist.products where product_category_name is not null
),
covered as (
select distinct pr.product_category_name, c.customer_state
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and pr.product_category_name is not null
and c.customer_state in (select state from target_states)
)
select product_category_name from candidates
where not exists (
select 1 from target_states ts
where not exists (
select 1 from covered cv
where cv.product_category_name = candidates.product_category_name
and cv.customer_state = ts.state
)
)
order by product_category_name;

-- 5. Сравнить множества результатов оператором except в обе стороны.
-- сравнение "двойной not exists" против group by/having.
with target_states(state) as (
values ('AL'), ('SE'), ('BA')
),
r1 as (
select p.product_category_name
from (select distinct product_category_name from olist.products where product_category_name is not null) p
where not exists (
select 1 from target_states ts
where not exists (
select 1 from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and c.customer_state = ts.state
and pr.product_category_name = p.product_category_name
)
)
),
r2 as (
select pr.product_category_name
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and pr.product_category_name is not null
and c.customer_state in (select state from target_states)
group by pr.product_category_name
having count(distinct c.customer_state) = (select count(*) from target_states)
)
select 'r1 minus r2' as direction, count(*) as rows_diff from (select * from r1 except select * from r2) d
union all
select 'r2 minus r1', count(*) from (select * from r2 except select * from r1) d;

-- 6. Для одной найденной категории вывести диагностическую таблицу: категория -> штат -> число заказов.
with target_states(state) as (
values ('AL'), ('SE'), ('BA')
),
cats as (
select pr.product_category_name
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and pr.product_category_name is not null
and c.customer_state in (select state from target_states)
group by pr.product_category_name
having count(distinct c.customer_state) = (select count(*) from target_states)
limit 1
)
select pr.product_category_name, c.customer_state, count(distinct o.order_id) as orders_cnt
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and pr.product_category_name = (select product_category_name from cats)
and c.customer_state in (select state from target_states)
group by pr.product_category_name, c.customer_state
order by c.customer_state;

-- 7. Проверить поведение решения при пустом target_states.
-- логика: "для всех штатов из S категория продавалась". если S пусто, условие выполнено вакуумно для всех категорий.
-- двойной not exists вернёт все категории. group by/having через count(distinct)=0 тоже вернёт все, только если выбрать все штаты.
-- у нас group by ограничен фильтром "c.customer_state in (select state from target_states)": пустое множество -> нет строк -> 0 категорий.
with target_states(state) as (
select null where false
)
select p.product_category_name
from (select distinct product_category_name from olist.products where product_category_name is not null) p
where not exists (
select 1 from target_states ts
where not exists (
select 1 from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
join olist.products pr on pr.product_id = oi.product_id
where o.order_status = 'delivered'
and c.customer_state = ts.state
and pr.product_category_name = p.product_category_name
)
)
order by p.product_category_name
limit 10;

-- 8. Дополнительно: найти продавцов, которые продавали товары покупателям каждого из трёх штатов.
with target_states(state) as (
values ('AL'), ('SE'), ('BA')
)
select s.seller_id
from olist.sellers s
where not exists (
select 1 from target_states ts
where not exists (
select 1 from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where o.order_status = 'delivered'
and c.customer_state = ts.state
and oi.seller_id = s.seller_id
)
)
order by s.seller_id
limit 20;
