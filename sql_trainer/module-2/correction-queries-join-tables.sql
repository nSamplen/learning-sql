
-- #1
/*
Для книг, которые уже есть на складе (в таблице book), но по другой цене, 
чем в поставке (supply),  необходимо в таблице book увеличить количество на значение, 
указанное в поставке,  и пересчитать цену. 
А в таблице  supply обнулить количество этих книг. 
Формула для пересчета цены:
price={(p_1*k_1+p_2*k_2)/(k_1+k_2}
где  p1, p2 - цена книги в таблицах book и supply;
k1, k2 - количество книг в таблицах book и supply.
*/

update book inner join author
        on book.author_id = author.author_id
        inner join supply 
        on book.title = supply.title
        and author.name_author = supply.author
set     book.price = (book.price * book.amount + supply.price * supply.amount)/(book.amount + supply.amount),
        book.amount = book.amount + supply.amount,
        supply.amount = 0
where book.price != supply.price
;

-- #2
/*
Включить новых авторов в таблицу author с помощью запроса на добавление, 
а затем вывести все данные из таблицы author.  Новыми считаются авторы, 
которые есть в таблице supply, но нет в таблице author.
*/

insert into author (name_author)
        select supply.author
        from author right join supply
                on author.name_author = supply.author
        where name_author is null;

select * from author;


-- #3
/*
Добавить новые книги из таблицы supply в таблицу book
*/

insert into book (title, author_id, price, amount)
        select title, author.author_id, price, amount
        from author inner join supply
                on author.name_author = supply.author
        where amount <> 0
;
select * from book;

-- #4
/*
Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», 
а для книги «Остров сокровищ» Стивенсона - «Приключения». 
(Использовать два запроса).
*/
update book
        set genre_id = 
                (
                select genre_id
                from genre
                where name_genre = 'Поэзия'
                )
        where title = 'Стихотворения и поэмы'
        and author_id =
        (
                select author_id 
                from author
                where name_author = 'Лермонтов М.Ю.'
        )
;

update book
        set genre_id = 
                (
                select genre_id
                from genre
                where name_genre = 'Приключения'
                )
        where title = 'Остров сокровищ'
        and author_id =
        (
                select author_id 
                from author
                where name_author = 'Стивенсон Р.Л.'
        )
;
-- #5
/*
Удалить всех авторов и все их книги, общее количество книг которых меньше 20.
*/

-- стоит ON DELETE CASCADE, поэтому достаточно удалить только в таблице author
delete from author
where author_id in
        (
                select author_id
                from book
                group by author_id
                having sum(amount) < 20
        )
;

select * from author;

-- #6
/*
Удалить все жанры, к которым относится меньше 4-х книг. 
В таблице book для этих жанров установить значение Null
*/

-- стоит ON DELETE SET NULL, поэтому достаточно удалить только в таблице genre

delete from genre
where genre_id in
        (
                select genre_id
                from book
                group by genre_id
                having count(*)<4
        )
;
select * from genre;

-- #7
/*
Удалить всех авторов, которые пишут в жанре "Поэзия". 
Из таблицы book удалить все книги этих авторов. 
В запросе для отбора авторов использовать полное название жанра, а не его id
*/

delete from author
using
        author inner join book
        on author.author_id = book.author_id
        inner join genre
        on genre.genre_id = book.genre_id
where genre.name_genre = 'Поэзия'
;

select * from author;




