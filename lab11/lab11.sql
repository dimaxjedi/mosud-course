-- Нидзий Д.В. ИНБО-21-23, Вариант 10
-- корневой штат для рекурсии: GO.

-- 1. обычное представление v_order_summary: одна строка на заказ с customer_state, числом позиций и суммой price+freight.

drop view if exists lab.v_order_summary;
create view lab.v_order_summary as
select o.order_id, c.customer_state,
       count(oi.order_item_id) as items_count,
       coalesce(sum(oi.price + oi.freight_value), 0) as total_sum
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
left join olist.order_items oi on oi.order_id = o.order_id
group by o.order_id, c.customer_state;

select * from lab.v_order_summary limit 10;

-- 2. материализованное представление mv_monthly_state_sales: месяц, штат, число заказов, сумма.

drop materialized view if exists lab.mv_monthly_state_sales;
create materialized view lab.mv_monthly_state_sales as
select date_trunc('month', o.order_purchase_timestamp)::date as month,
       c.customer_state,
       count(distinct o.order_id) as orders_count,
       sum(oi.price + oi.freight_value) as total_sum
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by 1, 2;

create index if not exists idx_mv_monthly_state_sales on lab.mv_monthly_state_sales(month, customer_state);

select * from lab.mv_monthly_state_sales order by month, customer_state limit 10;

-- refresh-команда для материализованного представления:
-- refresh materialized view lab.mv_monthly_state_sales;

-- 3. сложный аналитический запрос, разбитый минимум на три именованных cte.
-- задача: по каждому штату за последние 12 месяцев показать долю заказов с отзывом 5 звёзд
-- и среднюю сумму заказа; оставить только штаты, где доля 5 звёзд выше средней по всем штатам.

with last_month as (
select max(order_purchase_timestamp) as m from olist.orders
),
sales as (
select c.customer_state, o.order_id, sum(oi.price + oi.freight_value) as total
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
join olist.order_items oi on oi.order_id = o.order_id, last_month lm
where o.order_status = 'delivered'
and o.order_purchase_timestamp >= lm.m - interval '12 months'
group by c.customer_state, o.order_id
),
reviews as (
select c.customer_state, o.order_id,
       max(case when r.review_score = 5 then 1 else 0 end) as is_5
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
left join olist.order_reviews r on r.order_id = o.order_id
group by c.customer_state, o.order_id
),
agg as (
select s.customer_state,
       count(distinct s.order_id) as orders_cnt,
       avg(s.total) as avg_total,
       avg(rv.is_5::numeric) as share_5
from sales s
join reviews rv on rv.order_id = s.order_id
group by s.customer_state
)
select a.customer_state, a.orders_cnt, a.avg_total, a.share_5
from agg a
where a.share_5 > (select avg(share_5) from agg)
order by a.share_5 desc;

-- 4. создать lab.geo_tree по указанному правилу: BR -> state -> city, до 20 городов на штат.

drop table if exists lab.geo_tree cascade;

create table lab.geo_tree (
node_id text primary key,
parent_id text references lab.geo_tree(node_id),
node_type text not null check (node_type in ('country','state','city')),
node_name text not null
);

insert into lab.geo_tree values ('BR', null, 'country', 'Brazil');

insert into lab.geo_tree (node_id, parent_id, node_type, node_name)
select 'ST:' || customer_state, 'BR', 'state', customer_state
from olist.customers
group by customer_state;

insert into lab.geo_tree (node_id, parent_id, node_type, node_name)
select 'CT:' || customer_state || ':' || customer_city,
       'ST:' || customer_state,
       'city',
       customer_city
from (
select customer_state, customer_city,
       row_number() over (partition by customer_state order by count(*) desc) as rn
from olist.customers
group by customer_state, customer_city
) t
where rn <= 20;

select count(*) as total_nodes from lab.geo_tree;
select node_type, count(*) from lab.geo_tree group by node_type;

-- 5. рекурсивный запрос: от узла ST:GO вывести всё поддерево с depth, node_id, path, node_name.

with recursive subtree as (
select node_id, parent_id, node_type, node_name,
       0 as depth,
       node_id as path
from lab.geo_tree
where node_id = 'ST:GO'

union all

select g.node_id, g.parent_id, g.node_type, g.node_name,
       s.depth + 1,
       s.path || ' > ' || g.node_id
from lab.geo_tree g
join subtree s on g.parent_id = s.node_id
)
select depth, node_id, path, node_name
from subtree
order by path;

-- 6. обратный рекурсивный запрос: для выбранного city-node вывести цепочку предков до BR.
-- возьмём city-node 'CT:GO:goiania'.

with recursive ancestors as (
select node_id, parent_id, node_type, node_name,
       0 as level,
       node_id as path
from lab.geo_tree
where node_id = 'CT:GO:goiania'

union all

select g.node_id, g.parent_id, g.node_type, g.node_name,
       a.level + 1,
       a.path || ' > ' || g.node_id
from lab.geo_tree g
join ancestors a on a.parent_id = g.node_id
)
select level, node_id, node_name, path
from ancestors
order by level desc;

-- 7. количество потомков каждого state-node.

with recursive sub as (
select node_id, parent_id, node_id as root
from lab.geo_tree
where node_type = 'state'

union all

select g.node_id, g.parent_id, s.root
from lab.geo_tree g
join sub s on g.parent_id = s.node_id
)
select root as state_node, count(*) - 1 as descendants
from sub
group by root
order by descendants desc
limit 10;

-- 8. защита рекурсии от цикла: пример с ограничением глубины.
-- если в таблице появится цикл (a -> b -> a), рекурсия без защиты уйдёт в бесконечность.
-- способ: добавить условие depth < N или использовать cycle-обнаружение postgres 14+.

with recursive safe_subtree as (
select node_id, parent_id, node_type, node_name, 0 as depth
from lab.geo_tree
where node_id = 'ST:GO'

union all

select g.node_id, g.parent_id, g.node_type, g.node_name, s.depth + 1
from lab.geo_tree g
join safe_subtree s on g.parent_id = s.node_id
where s.depth < 5
)
select count(*) as safe_nodes from safe_subtree;

-- второй способ — встроенный cycle в postgres 14+:
-- with recursive safe2 as (
--   select node_id, parent_id, 0 as depth from lab.geo_tree where node_id = 'ST:GO'
--   union all
--   select g.node_id, g.parent_id, s.depth + 1
--   from lab.geo_tree g join safe2 s on g.parent_id = s.node_id
-- ) cycle node_id set is_cycle using path
-- select * from safe2;
