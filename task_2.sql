-- Задание 2. Материализованное представление: изменение среднего чека
-- по каждому заведению от года к году, за все годы кроме 2023.
-- Все столбцы со средним чеком округлены до двух знаков.
--
-- 2023 год отсекается до агрегации, в WHERE внутреннего CTE.
-- LAG берёт средний чек предыдущего года внутри каждого заведения.
-- Для самого раннего года предыдущей строки нет: LAG вернёт NULL,
-- и процент изменения тоже станет NULL — арифметика с NULL даёт NULL,
-- отдельно этот случай обрабатывать не нужно.
CREATE MATERIALIZED VIEW cafe.avg_check_by_year AS
WITH yearly AS (
    SELECT EXTRACT(YEAR FROM s.date)::int AS year,
           s.restaurant_uuid,
           ROUND(AVG(s.avg_check), 2) AS avg_check
    FROM cafe.sales s
    WHERE EXTRACT(YEAR FROM s.date) <> 2023
    GROUP BY EXTRACT(YEAR FROM s.date), s.restaurant_uuid
),
with_previous AS (
    SELECT y.year,
           r.cafe_name,
           r.restaurant_type,
           y.avg_check,
           LAG(y.avg_check) OVER (
               PARTITION BY r.cafe_name
               ORDER BY y.year
           ) AS previous_year_avg_check
    FROM yearly y
    JOIN cafe.restaurants r USING (restaurant_uuid)
)
SELECT year,
       cafe_name,
       restaurant_type,
       avg_check,
       previous_year_avg_check,
       ROUND(
           (avg_check - previous_year_avg_check) / previous_year_avg_check * 100,
           2
       ) AS avg_check_change_percent
FROM with_previous
ORDER BY cafe_name, year;


-- Просмотр результата
SELECT *
FROM cafe.avg_check_by_year;


-- Данные материализованного представления не обновляются сами.
-- Пересчёт выполняется командой:
-- REFRESH MATERIALIZED VIEW cafe.avg_check_by_year;
