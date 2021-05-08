-- База данных платежной системы `billing_simple` состоит из одной таблицы `billing` следующей структуры:
/*
CREATE TABLE IF NOT EXISTS `billing_simple`.`billing` (
    `payer_email` VARCHAR(255) NULL,
    `recipient_email` VARCHAR(255) NULL,
    `sum` DECIMAL(18,2) NULL,
    `currency` VARCHAR(3) NULL,
    `billing_date` DATE NULL,
    `comment` TEXT NULL)
ENGINE = InnoDB;
*/
-- База данных магазина `store_simple` состоит из одной таблицы `store` следующей структуры:
/*
CREATE TABLE IF NOT EXISTS `store_simple`.`store` (
    `product_name` VARCHAR(255) NULL,
    `category` VARCHAR(255) NULL,
    `price` DECIMAL(18,2) NULL,
    `sold_num` INT NULL)
ENGINE = InnoDB;
*/
-- База данных учета проектов `project_simple` состоит из одной таблицы `project` следующей структуры:
/*
CREATE TABLE IF NOT EXISTS `project_simple`.`project` (
    `project_name` VARCHAR(255) NULL,
    `client_name` VARCHAR(255) NULL,
    `project_start` DATE NULL,
    `project_finish` DATE NULL,
    `budget` DECIMAL(18,2) NULL)
ENGINE = InnoDB;
*/


-- #1 Выведите поступления денег от пользователя с email 'vasya@mail.com'.
--    В результат включите все столбцы таблицы и не меняйте порядка их вывода. 
use billing_simple;
select *
from billing
where payer_email =  'vasya@mail.com'

-- #2 Добавьте в таблицу одну запись о платеже со следующими значениями:
--    ○  email плательщика: 'pasha@mail.com'
--    ○  email получателя: 'katya@mail.com'
--    ○  сумма: 300.00
--    ○  валюта: 'EUR'
--    ○  дата операции: 14.02.2016
--    ○  комментарий: 'Valentines day present)'
use billing_simple;
insert into billing values
    ('pasha@mail.com',
    'katya@mail.com',
    '300.00','EUR',
    '2016-02-14',
    'Valentines day present)');

-- #3 Измените адрес плательщика на 'igor@mail.com' для всех записей таблицы, где адрес плательщика 'alex@mail.com'.
use billing_simple;
update billing
    set payer_email = 'igor@mail.com' 
where payer_email ='alex@mail.com'

-- #4 Удалите из таблицы записи, где адрес плательщика или адрес получателя установлен в неопределенное значение или пустую строку.
use billing_simple;
delete from billing
where 
    payer_email is NULL
    or recipient_email is NULL
    or payer_email = ''
    or recipient_email = ''

-- #5 Выведите общее количество заказов компании.
use project_simple;
select count(*)
from project

-- #6 Выведите количество товаров в каждой категории. Результат должен содержать два столбца: 
--    ○  название категории, 
--    ○  количество товаров в данной категории.
use store_simple;
select
    category,
    count(*)
from store
group by category

-- #7 Выведите 5 категорий товаров, продажи которых принесли наибольшую выручку. 
--    Под выручкой понимается сумма произведений стоимости товара на количество проданных единиц. 
--    Результат должен содержать два столбца: 
--    ○  название категории,
--    ○  выручка от продажи товаров в данной категории.
use store_simple;
select
    category,
    sum(sold_num*price) as payoff
from store
group by category
order by payoff desc
limit 5

-- #8 Выведите в качестве результата одного запроса общее количество заказов, 
--    сумму стоимостей (бюджетов) всех проектов, средний срок исполнения заказа в днях.
use project_simple;
select
    count(*),
    sum(budget),
    avg(datediff(project_finish, project_start))
from project