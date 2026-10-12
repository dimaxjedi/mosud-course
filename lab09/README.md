lab09. Функциональные зависимости и нормализация. Нидзий Д.В. ИНБО-21-23, Вариант 10

Исходное отношение
transfer_flat(transfer_id, source_wh, source_city, dest_wh, dest_city, product_id, category_name, qty, created_at).

Бизнес-правила как функциональные зависимости
1. transfer_id -> source_wh, dest_wh, created_at.
2. source_wh -> source_city.
3. dest_wh -> dest_city.
4. product_id -> category_name.
5. (transfer_id, product_id) -> qty.

Потенциальный ключ
Замыкание (transfer_id, product_id):
- шаг 1: transfer_id даёт source_wh, dest_wh, created_at.
- шаг 2: source_wh даёт source_city, dest_wh даёт dest_city.
- шаг 3: product_id даёт category_name.
- шаг 4: (transfer_id, product_id) даёт qty.
Итого все атрибуты, значит (transfer_id, product_id) — потенциальный ключ.

Частичные зависимости
- transfer_id -> source_wh, dest_wh, created_at (зависит только от части ключа).
- product_id -> category_name (зависит только от части ключа).

Транзитивные зависимости
- source_wh -> source_city (source_wh не ключ, city зависит через него).
- dest_wh -> dest_city.
- product_id -> category_name (транзитивно от полного ключа через product_id).

Аномалии плоской таблицы
- INSERT: нельзя добавить новый склад, если по нему ещё не было перемещений — source_wh и source_city хранятся только в строках перемещений.
- UPDATE: город склада хранится в каждой строке; при смене города надо обновить все строки с этим складом.
- DELETE: удалив последнее перемещение склада, теряем информацию о самом складе и его городе.

Декомпозиция до 3НФ
- Шаг 1. Убираем частичные зависимости.
Причина: transfer_id -> source_wh, dest_wh, created_at и product_id -> category_name.

Результат:
- transfer(transfer_id, source_wh, dest_wh, created_at)
- product(product_id, category_name)
- transfer_item(transfer_id, product_id, qty)

- Шаг 2. Убираем транзитивные зависимости.
Причина: source_wh -> source_city и dest_wh -> dest_city.

Результат:
- warehouse(warehouse_id, city)
- transfer(transfer_id, source_wh, dest_wh, created_at), где source_wh, dest_wh — FK на warehouse.

Итоговые отношения (3НФ = НФБК)
- lab.nf10_warehouse(warehouse_id PK, city NOT NULL)
- lab.nf10_product(product_id PK, category_name NOT NULL)
- lab.nf10_transfer(transfer_id PK, source_wh FK, dest_wh FK, created_at, CHECK source_wh <> dest_wh)
- lab.nf10_transfer_item(transfer_id PK FK, product_id PK FK, qty, CHECK qty > 0)

НФБК
Все детерминанты в итоговых отношениях — суперключи. Разбиение без потерь: связь восстанавливается через FK и составной PK, все исходные ФЗ сохраняются, ни одна зависимость не потеряна.

Тестовые данные
- warehouses: 3 строки.
- products: 3 строки.
- transfers: 4 строки.
- transfer_items: 5 строк.
Города sao paulo, rio de janeiro, belo horizonte и категории brinquedos, moveis_decoracao, cama_mesa_banho теперь хранятся по одному разу, а не дублируются в каждой строке перемещения.

Ошибочные операции
- insert в nf10_transfer с source_wh = dest_wh — отклонит ck_nf10_transfer_diff_wh.
- insert в nf10_transfer_item с несуществующим product_id — отклонит fk_nf10_transfer_item_product.
- insert в nf10_transfer_item с qty = 0 — отклонит ck_nf10_transfer_item_qty.
