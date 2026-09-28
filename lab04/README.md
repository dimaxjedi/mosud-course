# lab04  Нидзий Д.В. ИНБО-21-23, Вариант 10

1. Построить основной запрос варианта минимум из трёх таблиц.
основной запрос: orders + customers + агрегированные order_items + агрегированные order_payments + order_reviews. соединение customers по customer_id, order_items и order_payments предварительно агрегированы до одной строки на заказ. в выводе: order_id, order_status, order_purchase_timestamp, customer_city, customer_state, items_count, items_sum, payments_sum, review_score. фильтр: order_status = 'delivered'.

2. Для каждого join письменно определить предполагаемую кратность связи: 1:1, 1:n или m:n через промежуточную таблицу.
orders -> customers: n:1 (много заказов у одного customer_id).
orders -> (агрегированные items): 1:1 (после group by order_id одна строка на заказ).
orders -> (агрегированные payments): 1:1 (после group by order_id одна строка на заказ).
orders -> order_reviews: 1:n (у заказа может быть несколько отзывов).
order_items -> products: n:1.
order_items -> sellers: n:1.
orders и products связаны через промежуточную таблицу order_items (m:n).

3. Добавить один left join так, чтобы в результате сохранялись объекты без связанных строк.
left join order_reviews. фильтр r.review_id is null. в выводе оказались заказы со статусом delivered, у которых review_score пустой, то есть отзыва нет. такие заказы в результат попали именно благодаря left join: inner join их бы выкинул.

4. Построить антисоединение: найти объекты, для которых связанной строки нет.
заказы без позиций order_items: left join order_items, условие oi.order_id is null. найдено 775 таких заказов. это заказы, у которых статус не delivered или позиции не были созданы.

5. Намеренно создать ошибочный join, приводящий к размножению строк; показать, по какой причине изменилась сумма или count.
соединили orders + order_items + order_payments напрямую по order_id. у одного заказа несколько позиций и несколько платежей, поэтому получается декартово произведение: число строк = items × payments. в примере заказ 895ab968e7bb0d5659d16cd74cd1650c размножился до 63 строк, а sum(price) завысилась до 2305.38. то же самое произошло с остальными заказами: чем больше позиций и платежей, тем сильнее завышение.

6. Исправить ошибку предварительной агрегацией или изменением условия соединения.
исправили предварительной агрегацией: order_items группируем по order_id и берём sum(price), order_payments тоже группируем по order_id и берём sum(payment_value). после этого каждая сторона даёт одну строку на заказ, join 1:1, сумма и count корректные. в выводе items_sum и payments_sum стоят в одной строке на заказ.

7. Для основного запроса указать соответствующую композицию операций реляционной алгебры.
pi order_id, order_status, order_purchase_timestamp, customer_city, customer_state, items_count, items_sum, payments_sum, review_score (
  sigma order_status = 'delivered' (
    (orders join customers)
    left join (gamma order_id; count(*), sum(price) (order_items))
    left join (gamma order_id; sum(payment_value) (order_payments))
    left join order_reviews
  )
)
