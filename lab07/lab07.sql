-- Нидзий Д.В. ИНБО-21-23, Вариант 10

-- 1. Для orders, products и order_reviews подсчитать число null по всем потенциально необязательным столбцам.
select 'orders.order_status' as col, count(*) filter (where order_status is null) as nulls from olist.orders
union all select 'orders.order_approved_at', count(*) filter (where order_approved_at is null) from olist.orders
union all select 'orders.order_delivered_carrier_date', count(*) filter (where order_delivered_carrier_date is null) from olist.orders
union all select 'orders.order_delivered_customer_date', count(*) filter (where order_delivered_customer_date is null) from olist.orders
union all select 'orders.order_estimated_delivery_date', count(*) filter (where order_estimated_delivery_date is null) from olist.orders
union all select 'products.product_category_name', count(*) filter (where product_category_name is null) from olist.products
union all select 'products.product_name_lenght', count(*) filter (where product_name_lenght is null) from olist.products
union all select 'products.product_description_lenght', count(*) filter (where product_description_lenght is null) from olist.products
union all select 'products.product_photos_qty', count(*) filter (where product_photos_qty is null) from olist.products
union all select 'products.product_weight_g', count(*) filter (where product_weight_g is null) from olist.products
union all select 'products.product_length_cm', count(*) filter (where product_length_cm is null) from olist.products
union all select 'products.product_height_cm', count(*) filter (where product_height_cm is null) from olist.products
union all select 'products.product_width_cm', count(*) filter (where product_width_cm is null) from olist.products
union all select 'order_reviews.review_score', count(*) filter (where review_score is null) from olist.order_reviews
union all select 'order_reviews.review_comment_title', count(*) filter (where review_comment_title is null) from olist.order_reviews
union all select 'order_reviews.review_comment_message', count(*) filter (where review_comment_message is null) from olist.order_reviews
union all select 'order_reviews.review_creation_date', count(*) filter (where review_creation_date is null) from olist.order_reviews
union all select 'order_reviews.review_answer_timestamp', count(*) filter (where review_answer_timestamp is null) from olist.order_reviews
order by col;

-- 2. Сравнить count(*) и count(order_delivered_customer_date) и объяснить разницу.
select count(*) as total_rows, count(order_delivered_customer_date) as non_null_delivered
from olist.orders;

-- 3. Показать, что = null и <> null не возвращают ожидаемых строк; исправить через is null / is not null.
-- неправильно: сравнение с null даёт unknown, где фильтр не проходит.
select order_id from olist.orders where order_delivered_customer_date = null;
select order_id from olist.orders where order_delivered_customer_date <> null;

-- правильно: через is null / is not null.
select count(*) as with_null from olist.orders where order_delivered_customer_date is null;
select count(*) as without_null from olist.orders where order_delivered_customer_date is not null;

-- 4. Продемонстрировать is distinct from на двух значениях, одно из которых может быть null.
select 1 is distinct from null as a,
       1 is distinct from 1 as b,
       null is distinct from null as c,
       null is not distinct from null as d;

-- 5. Создать временную таблицу temp_ids(id text), добавить существующий order_id и null. Сравнить not in и not exists.
create temporary table temp_ids(id text);
insert into temp_ids values ('e481f51cbdc54678b7cc49136f2d6af7');
insert into temp_ids values (null);

-- not in с null: результат пустой, потому что = unknown, фильтр не срабатывает.
select count(*) as not_in_count
from olist.orders
where order_id not in (select id from temp_ids);

-- not exists: корректно работает с null в подзапросе.
select count(*) as not_exists_count
from olist.orders o
where not exists (select 1 from temp_ids t where t.id = o.order_id);

drop table temp_ids;

-- 6. Составить два запроса с left join reviews: в первом фильтр review_score >= 4 разместить в on, во втором — в where.
-- фильтр в on: строки без отзыва сохраняются, отзывы <4 отбрасываются, но left join остаётся left.
select count(*) as filter_in_on
from olist.orders o
left join olist.order_reviews r on r.order_id = o.order_id and r.review_score >= 4;

-- фильтр в where: предикат на правую таблицу превращает left join в фактический inner join,
-- потому что для null-строк условие r.review_score >= 4 даёт unknown и фильтр их отбрасывает.
select count(*) as filter_in_where
from olist.orders o
left join olist.order_reviews r on r.order_id = o.order_id
where r.review_score >= 4;

-- 7. Использовать coalesce для текстового комментария и nullif для безопасного деления.
select review_id,
       coalesce(review_comment_message, 'без комментария') as comment_text
from olist.order_reviews
limit 10;

select o.order_id,
       sum(oi.price) as items_sum,
       sum(op.payment_value) as payments_sum,
       sum(op.payment_value) / nullif(sum(oi.price), 0) as ratio
from olist.orders o
join olist.order_items oi on oi.order_id = o.order_id
join olist.order_payments op on op.order_id = o.order_id
group by o.order_id
limit 10;

-- 8. Мини-профиль качества: доля заказов без фактической даты доставки, доля товаров без категории, доля отзывов без текста.
select
    (select count(*) filter (where order_delivered_customer_date is null)::numeric / count(*)
     from olist.orders) as orders_no_delivered_share,
    (select count(*) filter (where product_category_name is null)::numeric / count(*)
     from olist.products) as products_no_category_share,
    (select count(*) filter (where review_comment_message is null)::numeric / count(*)
     from olist.order_reviews) as reviews_no_text_share;

-- 9. Найти столбец, где null — естественное состояние, и столбец, где null скорее указывает на проблему качества данных. Обосновать.
-- естественный null: order_reviews.review_comment_message. комментарий необязателен, покупатель вправе оставить только оценку.
-- проблема качества: products.product_category_name. товар обязан иметь категорию, null означает, что карточка заполнена неполно.
select count(*) filter (where review_comment_message is null) as natural_nulls,
       (select count(*) filter (where product_category_name is null) from olist.products) as suspicious_nulls
from olist.order_reviews;
