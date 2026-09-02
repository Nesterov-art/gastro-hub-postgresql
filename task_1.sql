-- Задание 1. Представление: топ-3 заведения внутри каждого типа
-- по среднему чеку за все даты. Средний чек округлён до двух знаков.
--
-- ROW_NUMBER() с разбиением по типу заведения нумерует заведения
-- заново внутри каждого типа, в порядке убывания среднего чека.
-- Фильтр по номеру вынесен в отдельный запрос: оконные функции
-- вычисляются после WHERE, поэтому обратиться к ним в том же
-- SELECT нельзя.
CREATE VIEW cafe.top_3_restaurants_by_avg_check AS
WITH restaurant_avg AS (
    SELECT restaurant_uuid,
           ROUND(AVG(avg_check), 2) AS avg_check
    FROM cafe.sales
    GROUP BY restaurant_uuid
),
ranked AS (
    SELECT r.cafe_name,
           r.restaurant_type,
           a.avg_check,
           ROW_NUMBER() OVER (
               PARTITION BY r.restaurant_type
               ORDER BY a.avg_check DESC
           ) AS rank_in_type
    FROM restaurant_avg a
    JOIN cafe.restaurants r USING (restaurant_uuid)
)
SELECT cafe_name,
       restaurant_type,
       avg_check
FROM ranked
WHERE rank_in_type <= 3
ORDER BY restaurant_type, avg_check DESC;


-- Просмотр результата
SELECT *
FROM cafe.top_3_restaurants_by_avg_check;
