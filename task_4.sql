-- Задание 4. Пиццерия с самым большим количеством пицц в меню.
-- Если таких пиццерий несколько — выводятся все.
--
-- menu -> 'Пицца' достаёт из меню вложенный объект с пиццами,
-- jsonb_each_text разворачивает его в строки «ключ — значение»,
-- по одной на каждую пиццу. Колонка menu имеет тип jsonb,
-- поэтому применяется jsonb_each_text, а не json_each_text.
-- Запятая между таблицей и функцией — неявный LATERAL JOIN:
-- функция вызывается для каждой строки таблицы и видит её колонки.
--
-- DENSE_RANK, а не ROW_NUMBER: условие требует вывести все пиццерии
-- с максимальным количеством пицц, а одинаковым значениям
-- DENSE_RANK присваивает одинаковый ранг.
WITH pizza_counts AS (
    SELECT r.cafe_name,
           COUNT(*) AS pizza_count
    FROM cafe.restaurants r,
         jsonb_each_text(r.menu -> 'Пицца') AS pizza
    WHERE r.restaurant_type = 'pizzeria'
    GROUP BY r.cafe_name
),
ranked AS (
    SELECT cafe_name,
           pizza_count,
           DENSE_RANK() OVER (ORDER BY pizza_count DESC) AS pizza_rank
    FROM pizza_counts
)
SELECT cafe_name,
       pizza_count
FROM ranked
WHERE pizza_rank = 1
ORDER BY cafe_name;
