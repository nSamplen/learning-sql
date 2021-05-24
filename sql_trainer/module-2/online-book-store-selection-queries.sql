-- В интернет-магазине продаются книги. Каждая книга имеет название, 
-- написана одним автором, относится к одному жанру, имеет определенную цену. 
-- В магазине в наличии есть несколько экземпляров каждой книги. 

-- Покупатель регистрируется на сайте интернет-магазина, 
-- задает свое имя и фамилию, электронную почту и город проживания. 
-- Он может сформировать один или несколько заказов, 
-- для каждого заказа написать какие-то пожелания.
--  Каждый заказ включает одну или несколько книг, 
-- каждую книгу можно заказать в нескольких экземплярах. 
-- Затем заказ проходит ряд последовательных этапов (операций): 
-- оплачивается, упаковывается, передается курьеру или транспортной компании 
-- для транспортировки и, наконец, доставляется покупателю. 
-- Фиксируется дата каждой операции. Для каждого города известно среднее время доставки книг.

-- При этом в магазине ведется учет книг, при покупке их количество уменьшается, 
-- при поступлении товара увеличивается, при исчерпании количества – оформляется заказ и пр.



-- #1
/*
Вывести все заказы Баранова Павла (какие книги, по какой цене 
и в каком количестве он заказал) в отсортированном по номеру заказа и названиям книг виде.
*/

select buy.buy_id, title, price, buy_book.amount
from client inner join buy
        on client.client_id = buy.client_id
        inner join buy_book
        on buy.buy_id = buy_book.buy_id
        inner join book 
        on book.book_id = buy_book.book_id
where name_client = 'Баранов Павел'
order by buy_id, title
;

-- #2
/*
Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора 
(нужно посчитать, в каком количестве заказов фигурирует каждая книга).  
Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг. 
Последний столбец назвать Количество.	 
*/

select  name_author, 
        title,
        count(buy_book.amount) as Количество
from
        author inner join book
        on author.author_id = book.author_id
        left join buy_book
        on buy_book.book_id = book.book_id
group by name_author, title
order by name_author, title
;

-- #3
/*
Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. 
Указать количество заказов в каждый город. 
Информацию вывести по убыванию количества заказов, 
а затем в алфавитном порядке по названию городов.
*/

select 
        name_city,
        count(*) as Количество
from city inner join client
        on city.city_id = client.city_id
        inner join buy
        on client.client_id = buy.client_id
group by name_city
order by Количество desc, name_city
;

-- #4
/*
Вывести номера всех оплаченных заказов и даты, когда они были оплачены.
*/
select  buy_id,
        date_step_end
from step inner join buy_step
        on step.step_id = buy_step.step_id
where name_step = 'Оплата'
        and date_step_end is not null
;

-- #5
/*
Вывести информацию о каждом заказе: его номер, 
кто его сформировал (фамилия пользователя) и его стоимость 
(сумма произведений количества заказанных книг и их цены), 
в отсортированном по номеру заказа виде.
*/
select 
        buy.buy_id,
        name_client,
        sum(book.price * buy_book.amount) as Стоимость
from client inner join buy
        on client.client_id = buy.client_id
        inner join buy_book
        on buy_book.buy_id = buy.buy_id
        inner join book
        on book.book_id = buy_book.book_id
group by buy.buy_id, name_client
order by buy.buy_id
;

-- #6
/*
Вывести все заказы и названия этапов, на которых они в данный момент находятся. 
Если заказ доставлен –  информацию о нем не выводить. 
Информацию отсортировать по возрастанию buy_id.
*/

-- Текущим  считается тот этап, для которого заполнена дата начала 
-- этапа и не заполнена дата его окончания.
select  buy_step.buy_id,
        name_step
from buy_step inner join step
        on buy_step.step_id = step.step_id
where date_step_end is null
        and date_step_beg is not null
;

-- #7
/*
В таблице city для каждого города указано количество дней, 
за которые заказ может быть доставлен в этот город 
(рассматривается только этап "Транспортировка"). 
Для тех заказов, которые прошли этап транспортировки, 
вывести количество дней за которое заказ реально доставлен в город. 
А также, если заказ доставлен с опозданием, указать количество дней задержки, 
в противном случае вывести 0. 
Информацию вывести в отсортированном по номеру заказа виде.
*/



select  buy.buy_id,
        datediff(date_step_end,date_step_beg) as Количество_дней,
        if(datediff(date_step_end,date_step_beg) > days_delivery,
                datediff(date_step_end,date_step_beg) - city.days_delivery,
                0) as Опоздание
from city 
        inner join client using (city_id)
        inner join buy using (client_id) 
        inner join buy_step using (buy_id)
where buy_step.step_id = 
        (select step_id from step where name_step = 'Транспортировка')
        and buy_step.date_step_beg is not null
        and buy_step.date_step_end is not null

-- #8
/*
Выбрать всех клиентов, которые заказывали книги Достоевского, 
информацию вывести в отсортированном по алфавиту виде.
*/

select name_client
from 
        (select book_id
        from book inner join author using (author_id)
        where name_author = 'Достоевский Ф.М.') as dostoevdky
        inner join buy_book using(book_id)
        inner join buy using(buy_id)
        inner join client using(client_id)
order by name_client

-- #9
/*
Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, 
указать это количество .
*/

select  name_genre, 
        sum(buy_book.amount) as Количество
from genre inner join book using (genre_id)
        inner join buy_book using(book_id)
group by genre_id
having sum(buy_book.amount) = 
        (
                select maxGenre.maxAmount
                from 
                (select genre_id, sum(buy_book.amount) as maxAmount
                from genre inner join book using (genre_id)
                        inner join buy_book using(book_id)
                group by genre_id
                order by maxAmount desc
                limit 1) as maxGenre
        )


-- #10
/*
Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. 
Для этого вывести год, месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, 
затем по возрастанию лет виде. Название столбцов: Год, Месяц, Сумма.

Информация о продажах предыдущего года хранится в архивной таблице buy_archive, 
которая создается в конце года на основе информации из таблиц базы данных и 
имеет следующую структуру:

Название столбца	Описание
buy_archive_id	        ключевой столбец
buy_id	                id заказов, выбирается из таблицы buy
client_id	        id клиентов, выбирается из из таблицы client
book_id	                id книги, выбирается из таблицы book
date_payment	        дата оплаты заказа, выбирается из столбца date_step_end
                        таблицы buy_step этапа «Оплата» соответствующего заказа
price	                цена книги в текущем заказе из таблицы book
                        (хранится, так как цена может измениться )
amount	                количество купленных книг в текущем заказе, из таблицы buy_book
*/
SELECT  year(date_payment) as Год,
        monthname(date_payment) as Месяц,
        sum(amount*price) as Сумма
FROM 
        buy_archive
group by Год, Месяц
union
select  year(date_step_end) as Год,
        monthname(date_step_end) as Месяц,
        sum(buy_book.amount*book.price) as Сумма
from    book 
        inner join buy_book using(book_id)
        inner join buy using(buy_id)
        inner join buy_step using(buy_id)
        inner join step using(step_id)
where   buy_step.date_step_end is not null
        and step.name_step = 'Оплата'
group by Год, Месяц
order by Месяц, Год


-- #11
/*
Для каждой отдельной книги необходимо вывести информацию о количестве проданных 
экземпляров и их стоимости за текущий и предыдущий год . 
Столбцы назвать Количество и Сумма. 
Информацию отсортировать по убыванию стоимости.
*/
select  all_books.title,
        sum(all_books.Количество) as Количество,
        sum(all_books.Сумма) as Сумма
from
(
        select  book.title,
                sum(buy_book.amount) as Количество,
                sum(price*buy_book.amount) as Сумма
        from    book
                inner join buy_book using(book_id)
                inner join buy using(buy_id)
                inner join buy_step using(buy_id)
                inner join step using(step_id)
        where   buy_step.date_step_end is not null
                and step.name_step = 'Оплата'
        group by book.title
        union
        select  book.title,
                sum(buy_archive.amount) as Количество,
                sum(buy_archive.amount*buy_archive.price) as Сумма
        from    book
                inner join buy_archive using(book_id)
        group by title
) as all_books
group by title
order by Сумма desc
;
