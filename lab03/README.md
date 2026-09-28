# lab03. Нидзий Д.В. ИНБО-21-23, Вариант 10

1. Для задания варианта записать исходное отношение и используемые атрибуты.
исходное отношение: products. используемые атрибуты: product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm. предикат: category is not null и объём > 20000 см³. проекция: product_id, category, length, height, width.

2. Сформулировать выражение реляционной алгебры с σ, π и при необходимости ρ.
pi product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm (
  sigma product_category_name is not null and product_length_cm*product_height_cm*product_width_cm > 20000 (products)
)

3. Реализовать выражение в sql.
запрос вернул 7607 строк.

4. Разбить сложный предикат на две последовательные выборки и показать эквивалентность результата.
сначала отсеиваем по category is not null, потом по объёму > 20000. результат 7607 строк, совпадает с исходным. проверка эквивалентности через except в обе стороны дала 0 строк, значит оба варианта возвращают одно и то же множество.

5. Создать второй sql-вариант, в котором ненужные столбцы исключаются раньше.
во втором варианте сначала оставляем только product_id, product_category_name, product_length_cm, product_height_cm, product_width_cm, потом применяем предикат. результат снова 7607 строк.

6. Проверить, могут ли в проекции возникнуть дубликаты. При необходимости сравнить select и select distinct.
дубликатов нет: count(*) = 7607 и count(distinct product_id) = 7607. это ожидаемо, потому что product_id — первичный ключ products. select и select distinct возвращают одинаковое число строк: 7607 и 7607. distinct не нужен, но и не мешает.
