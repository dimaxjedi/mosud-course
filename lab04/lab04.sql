-- Нидзий Д.В. ИНБО-21-23, Вариант 10

-- 1. Построить основной запрос варианта минимум из трёх таблиц.
-- вариант 10: паспорт заказа: orders + customers + агрегированные items + payments + reviews + sellers.
select o.order_id, o.order_status, o.order_purchase_timestamp, c.customer_city, c.customer_state, i.items_count, i.items_sum, p.payments_sum, r.review_score
from olist.orders o
join olist.customers c on c.customer_id = o.customer_id
left join (
select order_id, count(*) as items_count, sum(price) as items_sum
from olist.order_items
group by order_id
) i on i.order_id = o.order_id
left join (
select order_id, sum(payment_value) as payments_sum
from olist.order_payments
group by order_id
) p on p.order_id = o.order_id
left join olist.order_reviews r on r.order_id = o.order_id
where o.order_status = 'delivered'
limit 20;

-- 2. Для каждого join письменно определить предполагаемую кратность связи: 1:1, 1:n или m:n через промежуточную таблицу.
-- orders -> customers: n:1 (много заказов у одного customer_id).
-- orders -> (агрегированные items): 1:1 (после group by order_id одна строка на заказ).
-- orders -> (агрегированные payments): 1:1 (после group by order_id одна строка на заказ).
-- orders -> order_reviews: 1:n (у заказа может быть несколько отзывов).
-- order_items -> products: n:1.
-- order_items -> sellers: n:1.
-- orders и products связаны через промежуточную таблицу order_items (m:n).

-- 3. Добавить один left join так, чтобы в результате сохранялись объекты без связанных строк.
-- заказы без отзывов: left join order_reviews, условие r.review_id is null.
select o.order_id, o.order_status, r.review_score
from olist.orders o
left join olist.order_reviews r on r.order_id = o.order_id
where o.order_status = 'delivered'
and r.review_id is null
limit 20;

-- 4. Построить антисоединение: найти объекты, для которых связанной строки нет.
-- заказы, у которых вообще нет позиций order_items.
select o.order_id
from olist.orders o
left join olist.order_items oi on oi.order_id = o.order_id
where oi.order_id is null;

-- 5. Намеренно создать ошибочный join, приводящий к размножению строк; показать, по какой причине изменилась сумма или count.
-- соединяем orders + order_items + order_payments напрямую по order_id.
-- у одного заказа несколько позиций и несколько платежей, поэтому получается декартово произведение.
-- sum(price) завышается в число раз, равное числу платежей у заказа.
select o.order_id, count(*) as rows_after_bad_join, sum(oi.price) as wrong_sum
from olist.orders o
join olist.order_items oi on oi.order_id = o.order_id
join olist.order_payments op on op.order_id = o.order_id
group by o.order_id
order by rows_after_bad_join desc
limit 10;

-- 6. Исправить ошибку предварительной агрегацией или изменением условия соединения.
-- агрегируем items и payments до одной строки на заказ, потом соединяем.
select o.order_id, i.items_sum, p.payments_sum
from olist.orders o
join (
select order_id, sum(price) as items_sum
from olist.order_items
group by order_id
) i on i.order_id = o.order_id
join (
select order_id, sum(payment_value) as payments_sum
from olist.order_payments
group by order_id
) p on p.order_id = o.order_id
where o.order_status = 'delivered'
limit 20;

-- 7. Для основного запроса указать соответствующую композицию операций реляционной алгебры.
-- pi order_id, order_status, order_purchase_timestamp, customer_city, customer_state, items_count, items_sum, payments_sum, review_score (
--   sigma order_status = 'delivered' (
--     (orders join customers)
--     left join (gamma order_id; count(*), sum(price) (order_items))
--     left join (gamma order_id; sum(payment_value) (order_payments))
--     left join order_reviews
--   )
-- )
