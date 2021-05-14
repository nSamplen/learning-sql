
-- #1
/*
Создать таблицу author следующей структуры:

Поле	        Тип, описание
author_id	INT PRIMARY KEY AUTO_INCREMENT
name_author	VARCHAR(50)
*/

create table author (
        author_id	INT PRIMARY KEY AUTO_INCREMENT,
        name_author	VARCHAR(50)
);

-- #2
/*
Заполнить таблицу author. В нее включить следующих авторов:

Булгаков М.А.
Достоевский Ф.М.
Есенин С.А.
Пастернак Б.Л.
*/

insert into author (name_author) values 
        ('Булгаков М.А.'),
        ('Достоевский Ф.М.'),
        ('Есенин С.А.'),
        ('Пастернак Б.Л.')
;

-- #3
/*
Перепишите запрос на создание таблицы book, 
чтобы ее структура соответствовала структуре, 
показанной на логической схеме (таблица genre уже создана, 
порядок следования столбцов - как на логической схеме в таблице book, genre_id  - внешний ключ). 
Для genre_id ограничение о недопустимости пустых значений не задавать. 
В качестве главной таблицы для описания поля  genre_id
использовать таблицу genre следующей структуры:

Поле	Тип, описание
genre_id	INT PRIMARY KEY AUTO_INCREMENT
name_genre	VARCHAR(30)
*/

create table book (
        book_id INT PRIMARY KEY AUTO_INCREMENT,
        title VARCHAR(50),
        author_id int not null,
        genre_id int,
        price DECIMAL(8,2),
        amount int,
        foreign key (author_id) references author(author_id),
        foreign key (genre_id) references genre(genre_id)
)
;

-- #4
/*
Создать таблицу book той же структуры, что и на предыдущем шаге. 
Будем считать, что при удалении автора из таблицы author, 
должны удаляться все записи о книгах из таблицы book, 
написанные этим автором. А при удалении жанра из таблицы genre для соответствующей 
записи book установить значение Null в столбце genre_id. 
*/
create table book (
        book_id int primary key auto_increment,
        title varchar(50),
        author_id int not null,
        genre_id int,
        price decimal(8,2),
        amount int,
        foreign key(author_id) references author(author_id) on delete cascade,
        foreign key(genre_id) references genre(genre_id) on delete set null
);
-- #5
/*
Добавьте три последние записи (с ключевыми значениями 6, 7, 8) в таблицу book, 
первые 5 записей уже добавлены:

book_id	title	                author_id	genre_id	price	amount
1	Мастер и Маргарита	1	1	670.99	3
2	Белая гвардия	        1	1	540.50	5
3	Идиот	                2	1	460.00	10
4	Братья Карамазовы	2	1	799.01	3
5	Игрок	                2	1	480.50	10
6	Стихотворения и поэмы	3	2	650.00	15
7	Черный человек	        3	2	570.20	6
8	Лирика	                4	2	518.99	2
*/

insert into book(title,author_id,genre_id,price,amount) values
("Стихотворения и поэмы",	3,	2,	650.00,	15),
("Черный человек",	3,	2,	570.20,	6),
("Лирика",	4,	2,	518.99,	2)
;

