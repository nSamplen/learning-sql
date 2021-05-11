
-- #1
/*
Создать таблицу поставка (supply), которая имеет ту же структуру, что и таблица book.

Поле	Тип, описание
supply_id	INT PRIMARY KEY AUTO_INCREMENT
title	VARCHAR(50)
author	VARCHAR(30)
price	DECIMAL(8, 2)
amount	INT
*/

create table supply (
        supply_id int primary key AUTO_INCREMENT,
        title varchar(50),
        author varchar(30),
        price decimal(8,2),
        amount int
);

-- #2
/*
Занесите в таблицу supply четыре записи, чтобы получилась следующая таблица:

supply_id	title	author	price	amount
1	Лирика	Пастернак Б.Л.	518.99	2
2	Черный человек 	Есенин С.А.	570.20	6
3	Белая гвардия	Булгаков М.А.	540.50	7
4	Идиот	Достоевский Ф.М.	360.80	3
*/

insert into supply(title, author, price, amount) VALUES
        ("Лирика","Пастернак Б.Л.", 518.99,2),
        ("Черный человек", "Есенин С.А.", 570.20, 6),
        ("Белая гвардия", "Булгаков М.А.", 540.50, 7),
        ("Идиот", "Достоевский Ф.М.", 360.80, 3)
        ;

-- #3
/*
Добавить из таблицы supply в таблицу book, все книги, кроме книг, 
написанных Булгаковым М.А. и Достоевским Ф.М.
*/

insert into book (title, author, price, amount)
        select title, author, price, amount
        from supply
        where author not in ('Булгаков М.А.', 'Достоевский Ф.М.')
;

-- #4
/*
Занести из таблицы supply в таблицу book только те книги, авторов которых нет в  book.
*/
insert into book (title, author, price, amount)
        select title, author, price, amount
        from supply
        where author not in 
                (select distinct author
                from book)
;

-- #5
/*
Уменьшить на 10% цену тех книг в таблице book, 
количество которых принадлежит интервалу от 5 до 10 включительно.
*/

update book
        set price = 0.9*price
where amount between 5 and 10
;

-- #6
/*
В таблице book необходимо скорректировать значение для покупателя в столбце buy 
таким образом, чтобы оно не превышало допустимый остаток в столбце amount. 
А цену тех книг, которые покупатель не заказывал, снизить на 10%.
*/

update book 
        set buy = if(buy>0 and buy>amount, amount, buy),
        price = if(buy=0, price*0.9, price)
;

-- #7
/*
Для тех книг в таблице book , которые есть в таблице supply, 
не только увеличить их количество в таблице book
( увеличить их количество на значение столбца amountтаблицы supply), 
но и пересчитать их цену (для каждой книги найти сумму цен из таблиц book и supply и разделить на 2)
*/

update book, supply
        set book.amount = book.amount + supply.amount,
        book.price = round((book.price + supply.price)/2,2)
where book.title = supply.title
        and book.author = supply.author
;

-- #8
/*
Удалить из таблицы supply книги тех авторов, 
общее количество экземпляров книг которых в таблице book превышает 10
*/

delete from supply
where author in
        (
                select author
                from book
                group by author
                having sum(amount)>10
        )
;

-- #9
/*
Создать таблицу заказ (ordering), куда включить авторов и названия тех книг, 
количество экземпляров которых в таблице book меньше среднего количества экземпляров книг 
в таблице book. В таблицу включить столбец   amount, 
в котором для всех книг указать одинаковое значение - 
среднее количество экземпляров книг в таблице book.
*/

create table ordering as
select author, title,
(
        select round(avg(book.amount))
        from book
) as amount
from book
where amount < (select avg(book.amount) from book)
;

