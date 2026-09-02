-- Схема проекта Gastro Hub
CREATE SCHEMA cafe;


-- Тип заведения.
-- ENUM ограничивает список допустимых значений на уровне базы:
-- записать что-то кроме этих четырёх вариантов не получится.
CREATE TYPE cafe.restaurant_type AS ENUM (
    'coffee_shop',
    'restaurant',
    'bar',
    'pizzeria'
);


-- Рестораны.
-- restaurant_uuid — случайно генерируемый UUID и первичный ключ.
-- gen_random_uuid() встроена в ядро PostgreSQL начиная с версии 13.
CREATE TABLE cafe.restaurants (
    restaurant_uuid uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    cafe_name varchar NOT NULL,
    restaurant_type cafe.restaurant_type NOT NULL,
    menu jsonb
);


-- Менеджеры.
CREATE TABLE cafe.managers (
    manager_uuid uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    manager_name varchar NOT NULL,
    manager_phone varchar NOT NULL
);


-- Периоды работы менеджеров в ресторанах.
-- Связь «многие ко многим»: составной первичный ключ из двух UUID.
-- Работа менеджера в ресторане — единый период без перерывов,
-- поэтому для одной пары «ресторан — менеджер» строка ровно одна.
CREATE TABLE cafe.restaurant_manager_work_dates (
    restaurant_uuid uuid NOT NULL REFERENCES cafe.restaurants (restaurant_uuid),
    manager_uuid uuid NOT NULL REFERENCES cafe.managers (manager_uuid),
    work_start_date date NOT NULL,
    work_end_date date NOT NULL,
    PRIMARY KEY (restaurant_uuid, manager_uuid)
);


-- Продажи.
-- Составной первичный ключ: у одного заведения за один день
-- ровно один средний чек.
CREATE TABLE cafe.sales (
    date date NOT NULL,
    restaurant_uuid uuid NOT NULL REFERENCES cafe.restaurants (restaurant_uuid),
    avg_check numeric(6,2),
    PRIMARY KEY (date, restaurant_uuid)
);
