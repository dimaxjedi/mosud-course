-- Нидзий Д.В. ИНБО-21-23, Вариант 10

-- 1. Построить запрос A и запрос B. Для каждого определить count(*) и count(distinct product_id).
select count(*) as a_rows, count(distinct oi.product_id) as a_distinct
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered';

select count(*) as b_rows, count(distinct oi.product_id) as b_distinct
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered';

-- 2. Получить A ∪ B с помощью union и union all. Объяснить разницу в количестве строк.
select count(*) as union_count
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
union
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
) u;

select count(*) as union_all_count
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
union all
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
) u;

-- 3. Получить A ∩ B с помощью intersect.
select count(*) as intersect_count
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
intersect
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
) i;

-- 4. Получить A − B и B − A с помощью except.
select count(*) as a_minus_b
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
except
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
) d;

select count(*) as b_minus_a
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
except
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
) d;

-- 5. Проверить коммутативность объединения и пересечения на данных.
select count(*) as a_union_b
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
union
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
) u;

select count(*) as b_union_a
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
union
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
) u;

select count(*) as a_int_b
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
intersect
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
) i;

select count(*) as b_int_a
from (
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
intersect
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
) i;

-- 6. Показать, что разность некоммутативна.
select count(*) as symmetric_diff
from (
(select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
except
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered')
union
(select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'PI' and o.order_status = 'delivered'
except
select oi.product_id
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered')
) d;

-- 7. Переписать пересечение без intersect, используя exists.
select count(*) as intersect_via_exists
from (
select distinct oi1.product_id
from olist.orders o1
join olist.customers c1 on c1.customer_id = o1.customer_id
join olist.order_items oi1 on oi1.order_id = o1.order_id
where c1.customer_state = 'MA' and o1.order_status = 'delivered'
and exists (
select 1
from olist.orders o2
join olist.customers c2 on c2.customer_id = o2.customer_id
join olist.order_items oi2 on oi2.order_id = o2.order_id
where c2.customer_state = 'PI' and o2.order_status = 'delivered'
and oi2.product_id = oi1.product_id
)
) x;

-- 8. Для одного результата намеренно убрать distinct/union и продемонстрировать появление дубликатов.
select oi.product_id, count(*) as how_many
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where c.customer_state = 'MA' and o.order_status = 'delivered'
group by oi.product_id
having count(*) > 1
order by how_many desc
limit 5;

-- 9. union, intersect, except без all возвращают множество (дубликаты убираются).
-- union all, intersect all, except all и обычный select без distinct возвращают мультимножество (дубликаты остаются).
