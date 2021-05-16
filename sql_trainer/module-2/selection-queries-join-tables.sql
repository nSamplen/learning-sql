
-- #1
/*
Вывести название, жанр и цену тех книг, количество которых больше 8, 
в отсортированном по убыванию цены виде.
*/

select  book.title, 
        genre.name_genre, 
        book.price
from book inner join genre
        on book.genre_id = genre.genre_id
where book.amount > 8
order by book.price desc
;

-- #2
/*
Вывести все жанры, которые не представлены в книгах на складе.
*/

select genre.name_genre
from book right join genre
        on book.genre_id = genre.genre_id
where book.book_id is null
;

-- #3
/*
Есть список городов, хранящийся в таблице city:

city_id	name_city
1	Москва
2	Санкт-Петербург
3	Владивосток
Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года. 
Дату проведения выставки выбрать случайным образом. Создать запрос, 
который выведет город, автора и дату проведения выставки. 
Последний столбец назвать Дата. Информацию вывести, отсортировав сначала 
в алфавитном порядке по названиям городов, а потом по убыванию дат проведения выставок.
*/

select  city.name_city, 
        name_author, 
        DATE_ADD('2020-02-02', INTERVAL FLOOR(RAND() * 365) day) as Дата
from author, city
order by city.name_city, Дата desc
;

-- #4
/*
Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, 
включающему слово «роман» в отсортированном по названиям книг виде.
*/
select  genre.name_genre,
        book.title,
        author.name_author
from 
        genre inner join book
        on genre.genre_id = book.genre_id 
        and genre.name_genre like '%роман%'
                inner join author
                on author.author_id = book.author_id
order by book.title
;
-- #5
/*
Посчитать количество экземпляров  книг каждого автора из таблицы author.  
Вывести тех авторов,  количество книг которых меньше 10, 
в отсортированном по возрастанию количества виде. 
Последний столбец назвать Количество.
*/

select  author.name_author,
        sum(amount) as Количество
from author left join book
        on author.author_id = book.author_id
group by author.name_author
having Количество < 10 or Количество is null
order by Количество 
;


-- #6
/*
Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре. 
Поскольку у нас в таблицах так занесены данные, 
что у каждого автора книги только в одном жанре,  
для этого запроса внесем изменения в таблицу book. 
Пусть у нас  книга Есенина «Черный человек» относится к жанру «Роман», 
а книга Булгакова «Белая гвардия» к «Приключениям» (эти изменения в таблицы уже внесены).
*/

select author.name_author
from
        author inner join 
        (
                select distinct author_id, genre_id
                from book
        ) as query2
        on author.author_id = query2.author_id
group by author.name_author
having count(query2.genre_id) = 1
;

--      OR      --

select author.name_author
from
        author inner join book
        on author.author_id = book.author_id
group by author.name_author
having count(distinct book.genre_id) = 1
;


-- #7
/*
Вывести информацию о книгах, написанных в самых популярных жанрах, 
в отсортированном в алфавитном порядке по названию книг виде.
*/


select book.title,
       author.name_author, genre.name_genre,
       book.price, book.amount
from book inner join
        (select most_popular1.genre_id
        from
            (select genre.genre_id, sum(book.amount) as sum_amount
             from 
                genre inner join book
                on genre.genre_id = book.genre_id
             group by genre_id
            ) as most_popular1
            inner join
            (select genre.genre_id, sum(book.amount) as sum_amount
             from 
                genre inner join book
                on genre.genre_id = book.genre_id
             group by genre_id
             limit 1
            ) as most_popular2
            on most_popular1.sum_amount = most_popular2.sum_amount
         ) as resQ
         on book.genre_id = resQ.genre_id
        inner join author
                on book.author_id = author.author_id
        inner join genre
                on book.genre_id = genre.genre_id
order by book.title
;


-- #8
/*
Если в таблицах supply  и book есть одинаковые книги, которые имеют равную цену,  
вывести их название и автора используя USING(), а также посчитать общее 
количество экземпляров книг в таблицах supply и book, 
столбцы назвать Название, Автор  и Количество
*/

select  book.title as Название, 
        author.name_author as Автор,
        (supply.amount+book.amount) as Количество
from book inner join author using(author_id)
        inner join supply
        on supply.title = book.title
                and supply.author = author.name_author
                and supply.price = book.price
;



