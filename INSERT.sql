-- Порядок заполнения важен: сначала справочники (restaurants, managers),
-- затем таблицы со ссылками на них — иначе внешние ключи не дадут
-- вставить ни одной строки.


-- Рестораны.
-- DISTINCT сворачивает 204 480 строк продаж до 80 уникальных заведений.
-- Тип заведения приводится из varchar к созданному ENUM.
-- Меню подтягивается LEFT JOIN: заведение без меню не потеряется,
-- у него просто останется menu = NULL.
-- restaurant_uuid не указан — сработает DEFAULT gen_random_uuid().
INSERT INTO cafe.restaurants (cafe_name, restaurant_type, menu)
SELECT s.cafe_name,
       s.type::cafe.restaurant_type,
       m.menu
FROM (SELECT DISTINCT cafe_name, type FROM raw_data.sales) s
LEFT JOIN raw_data.menu m ON m.cafe_name = s.cafe_name;


-- Менеджеры: уникальные пары «имя + телефон».
INSERT INTO cafe.managers (manager_name, manager_phone)
SELECT DISTINCT manager, manager_phone
FROM raw_data.sales;


-- Периоды работы менеджеров.
-- Текстовые значения из сырых данных заменяются на UUID справочников:
-- название заведения — через join с cafe.restaurants,
-- менеджер — через join с cafe.managers по полному ключу справочника
-- (имя и телефон), чтобы однофамильцы не склеились.
-- Границы периода — минимальная и максимальная дата отчёта
-- в разрезе пары «ресторан — менеджер».
INSERT INTO cafe.restaurant_manager_work_dates (restaurant_uuid, manager_uuid, work_start_date, work_end_date)
SELECT r.restaurant_uuid,
       m.manager_uuid,
       MIN(s.report_date) AS work_start_date,
       MAX(s.report_date) AS work_end_date
FROM raw_data.sales s
JOIN cafe.restaurants r ON r.cafe_name = s.cafe_name
JOIN cafe.managers m ON m.manager_name = s.manager
                    AND m.manager_phone = s.manager_phone
GROUP BY r.restaurant_uuid, m.manager_uuid;


-- Продажи: строки переносятся один в один,
-- название заведения заменяется на его UUID.
INSERT INTO cafe.sales (date, restaurant_uuid, avg_check)
SELECT s.report_date,
       r.restaurant_uuid,
       s.avg_check
FROM raw_data.sales s
JOIN cafe.restaurants r ON r.cafe_name = s.cafe_name;
