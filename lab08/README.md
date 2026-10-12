lab08. ER-модель и расширение предметной области. Нидзий Д.В. ИНБО-21-23, Вариант 10

Расширение
Перемещения между складами: warehouses, inventory, transfers, transfer_items.

Бизнес-правила и ограничения

1. Склад имеет уникальный идентификатор.
pk_warehouses PRIMARY KEY (warehouse_id).

2. Ёмкость склада положительная.
ck_warehouses_capacity CHECK (capacity > 0).

3. Остаток товара на складе не отрицательный.
ck_inventory_qty CHECK (qty >= 0).

4. Остаток привязан к существующему складу и существующему товару.
fk_inventory_warehouse, fk_inventory_product.

5. Код перемещения уникален.
uq_transfers_code UNIQUE (transfer_code).

6. Источник и приёмник перемещения — разные склады.
ck_transfers_diff_wh CHECK (source_wh <> dest_wh).

7. Источник и приёмник привязаны к существующим складам.
fk_transfers_source, fk_transfers_dest.

8. Количество в позиции перемещения строго положительное.
ck_transfer_items_qty CHECK (qty > 0).

9. Позиция привязана к существующему перемещению и товару.
fk_transfer_items_transfer, fk_transfer_items_product.

Кратности и обязательность

- warehouses 1:N inventory (обязательно).
- warehouses 1:N transfers.source_wh (обязательно).
- warehouses 1:N transfers.dest_wh (обязательно).
- transfers 1:N transfer_items (обязательно).
- olist.products 1:N inventory (обязательно).
- olist.products 1:N transfer_items (обязательно).

Ошибочные операции

- INSERT в inventory с несуществующим product_id — отклонит fk_inventory_product.
- INSERT в transfer_items с qty = 0 — отклонит ck_transfer_items_qty.
- INSERT в transfers с source_wh = dest_wh — отклонит ck_transfers_diff_wh.
- UPDATE warehouses SET capacity = -100 — отклонит ck_warehouses_capacity.
- UPDATE transfers SET transfer_code = существующий — отклонит uq_transfers_code.

Проверка
Запрос к information_schema.table_constraints по таблицам схемы lab подтверждает все ограничения.
