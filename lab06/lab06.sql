-- Нидзий Д.В. ИНБО-21-23, Вариант 10
-- задача 10: повторные покупатели, суммарные расходы которых выше среднего среди повторных покупателей.

-- 1. Решить задачу варианта с использованием хотя бы одного подзапроса.
-- 2. В решении должен присутствовать один скалярный подзапрос и один exists/not exists либо коррелированный подзапрос.
-- повторный покупатель — тот, у кого customer_unique_id встречается более одного раза.
-- exists здесь коррелированный: для каждой строки (c, o, p) проверяем, есть ли у того же покупателя другой заказ.
select c.customer_unique_id, sum(p.payment_value) as total_spent
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
join olist.order_payments p on p.order_id = o.order_id
where exists (
select 1
from olist.customers c2
join olist.orders o2 on o2.customer_id = c2.customer_id
where c2.customer_unique_id = c.customer_unique_id
and o2.order_id <> o.order_id
)
group by c.customer_unique_id
having sum(p.payment_value) > (
select avg(sub.total) from (
select c3.customer_unique_id, sum(p3.payment_value) as total
from olist.customers c3
join olist.orders o3 on o3.customer_id = c3.customer_id
join olist.order_payments p3 on p3.order_id = o3.order_id
where exists (
select 1
from olist.customers c4
join olist.orders o4 on o4.customer_id = c4.customer_id
where c4.customer_unique_id = c3.customer_unique_id
and o4.order_id <> o3.order_id
)
group by c3.customer_unique_id
) sub
)
order by total_spent desc
limit 20;

-- 3. Создать альтернативный вариант через cte с предварительной агрегацией.
with repeat_customers as (
select c.customer_unique_id
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
group by c.customer_unique_id
having count(distinct o.order_id) > 1
),
spent as (
select c.customer_unique_id, sum(p.payment_value) as total_spent
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
join olist.order_payments p on p.order_id = o.order_id
where c.customer_unique_id in (select customer_unique_id from repeat_customers)
group by c.customer_unique_id
)
select s.customer_unique_id, s.total_spent
from spent s
where s.total_spent > (select avg(total_spent) from spent)
order by s.total_spent desc
limit 20;

-- 4. Сравнить результаты оператором except в обе стороны.
with r1 as (
select c.customer_unique_id
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
join olist.order_payments p on p.order_id = o.order_id
where exists (
select 1
from olist.customers c2
join olist.orders o2 on o2.customer_id = c2.customer_id
where c2.customer_unique_id = c.customer_unique_id
and o2.order_id <> o.order_id
)
group by c.customer_unique_id
having sum(p.payment_value) > (
select avg(sub.total) from (
select c3.customer_unique_id, sum(p3.payment_value) as total
from olist.customers c3
join olist.orders o3 on o3.customer_id = c3.customer_id
join olist.order_payments p3 on p3.order_id = o3.order_id
where exists (
select 1
from olist.customers c4
join olist.orders o4 on o4.customer_id = c4.customer_id
where c4.customer_unique_id = c3.customer_unique_id
and o4.order_id <> o3.order_id
)
group by c3.customer_unique_id
) sub
)
),
repeat_customers as (
select c.customer_unique_id
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
group by c.customer_unique_id
having count(distinct o.order_id) > 1
),
spent as (
select c.customer_unique_id, sum(p.payment_value) as total_spent
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
join olist.order_payments p on p.order_id = o.order_id
where c.customer_unique_id in (select customer_unique_id from repeat_customers)
group by c.customer_unique_id
),
r2 as (
select s.customer_unique_id
from spent s
where s.total_spent > (select avg(total_spent) from spent)
)
select 'r1 minus r2' as direction, count(*) as rows_diff from (select * from r1 except select * from r2) d
union all
select 'r2 minus r1', count(*) from (select * from r2 except select * from r1) d;

-- 5. Показать пример any / all.
-- any: покупатели, у которых есть хотя бы один платёж больше 500 (any = >).
select c.customer_unique_id
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
join olist.order_payments p on p.order_id = o.order_id
where p.payment_value > any (select 500)
group by c.customer_unique_id
limit 20;

-- all: покупатели, у которых все платежи больше 100 (all = минимум 100).
select c.customer_unique_id
from olist.customers c
join olist.orders o on o.customer_id = c.customer_id
join olist.order_payments p on p.order_id = o.order_id
group by c.customer_unique_id
having min(p.payment_value) > all (select 100)
limit 20;
