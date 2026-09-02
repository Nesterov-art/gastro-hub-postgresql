-- Задание 5. Самая дорогая пицца для каждой пиццерии.
--
-- jsonb_each_text возвращает пары «ключ — значение», где ключ —
-- название пиццы, значение — её цена. Значения приходят текстом,
-- поэтому цена приводится к int: без приведения сортировка была бы
-- лексикографической и '99' оказалось бы «больше», чем '504'.
--
-- ROW_NUMBER с разбиением по заведению и сортировкой по цене
-- по убыванию даёт ранг 1 самой дорогой пицце каждой пиццерии.
WITH menu_cte AS (
    SELECT r.cafe_name,
           'Пицца' AS dish_type,
           pizza.key AS dish_name,
           pizza.value::int AS dish_price
    FROM cafe.restaurants r,
         jsonb_each_text(r.menu -> 'Пицца') AS pizza
    WHERE r.restaurant_type = 'pizzeria'
),
menu_with_rank AS (
    SELECT cafe_name,
           dish_type,
           dish_name,
           dish_price,
           ROW_NUMBER() OVER (
               PARTITION BY cafe_name
               ORDER BY dish_price DESC
           ) AS price_rank
    FROM menu_cte
)
SELECT cafe_name,
       dish_type,
       dish_name,
       dish_price
FROM menu_with_rank
WHERE price_rank = 1
ORDER BY cafe_name;
