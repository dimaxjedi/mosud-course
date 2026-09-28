-- Нидзий Д.В. ИНБО-21-23, Вариант 10

-- 1. Для задания варианта записать исходное отношение и используемые атрибуты.
-- отношение: products.
-- атрибуты: product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm.
-- предикат: category is not null и объём > 20000 см³.

-- 2. Выражение реляционной алгебры:
-- pi product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm (
--   sigma product_category_name is not null and product_length_cm*product_height_cm*product_width_cm > 20000 (products)
-- )

-- 3. Реализация в sql (считаем количество, чтобы не гнать 7607 строк).
select count(*) as base_count
from olist.products
where product_category_name is not null
and product_length_cm * product_height_cm * product_width_cm > 20000;

-- 4. Разбить предикат на две выборки и показать эквивалентность.
select count(*) as split_count
from (
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
where product_category_name is not null
) s1
where product_length_cm * product_height_cm * product_width_cm > 20000;

-- проверка эквивалентности через except в обе стороны.
select count(*) as except_1
from (
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
where product_category_name is not null
and product_length_cm * product_height_cm * product_width_cm > 20000
except
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from (
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
where product_category_name is not null
) s1
where product_length_cm * product_height_cm * product_width_cm > 20000
) d;

select count(*) as except_2
from (
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from (
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
where product_category_name is not null
) s1
where product_length_cm * product_height_cm * product_width_cm > 20000
except
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
where product_category_name is not null
and product_length_cm * product_height_cm * product_width_cm > 20000
) d;

-- 5. Второй вариант: ненужные столбцы исключаются раньше.
select count(*) as early_projection_count
from (
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
) s2
where product_category_name is not null
and product_length_cm * product_height_cm * product_width_cm > 20000;

-- 6. Проверить дубликаты в проекции.
select count(*) as all_rows, count(distinct product_id) as distinct_ids
from olist.products
where product_category_name is not null
and product_length_cm * product_height_cm * product_width_cm > 20000;

select count(*) as select_rows
from (
select product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
where product_category_name is not null
and product_length_cm * product_height_cm * product_width_cm > 20000
) q;

select count(*) as select_distinct_rows
from (
select distinct product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm
from olist.products
where product_category_name is not null
and product_length_cm * product_height_cm * product_width_cm > 20000
) q;
