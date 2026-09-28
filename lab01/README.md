Нидзий Д.В. ИНБО-21-23

lab01 — развёртывание PostgreSQL и загрузка Olist

- PostgreSQL: 17 (Docker image postgres:17).
- Способ импорта: docker exec + psql \copy FROM STDIN.
- Числа строк после загрузки:
 table_name             |  count  
-----------------------------------+---------
 customers                         |   99441
 geolocation                       | 1000163
 order_items                       |  112650
 order_payments                    |  103886
 order_reviews                     |   99224
 orders                            |   99441
 product_category_name_translation |      71
 products                          |   32951
 sellers                           |    3095
