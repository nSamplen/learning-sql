-- Предметная область

-- В университете реализуется on-line тестирование по нескольким дисциплинам. 
-- Каждая дисциплина включает некоторое количество вопросов. 
-- Ответы на вопрос представлены в виде вариантов ответов, один из этих вариантов правильный.

-- Студент регистрируется в системе, указав свое имя, фамилию и отчество. 
-- После этого он может проходить тестирование по одной или нескольким дисциплинам. 
-- Студент имеет несколько попыток для прохождения тестирования  (необходимо сохранять дату попытки). 
-- Каждому студенту случайным образом выбирается набор вопросов по дисциплине и 
-- формируется индивидуальный тест. 
-- Студент отвечает на вопросы, выбирая один из предложенных вариантов ответа.

-- После окончания тестирования  вычисляется и сохраняется результат (в процентах) попытки.

/*
Таблица  student :

student_id	name_student
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(50)
*/

/*
Таблица attempt(в таблице хранится информация о каждой попытке сдачи теста : 
        id студента, id дисциплины,  дата попытки и результат в процентах):

attempt_id	student_id	subject_id	date_attempt	result
INT PRIMARY KEY
AUTO_INCREMENT	   INT	        INT	        DATE	        INT
*/

/*
Таблица question(таблица содержит вопросы по каждой дисциплине):

question_id	name_question	subject_id
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(100)	INT
*/

/*
Таблица answer(в таблице содержатся варианты ответов на каждый вопрос, 
        для правильного варианта столбец is_correct имеет значение true):

answer_id	name_answer	question_id	is_correct
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(100)	INT	BOOL
*/

/*
Таблица testing (в таблице хранится информация о каждой попытке студента: какие вопросы были заданы и какой ответ дал студент)

testing_id	attempt_id	question_id	answer_id
INT PRIMARY KEY
AUTO_INCREMENT	INT	INT	INT
*/

-- #1
/*
В таблицу attempt включить новую попытку для студента Баранова Павла 
по дисциплине «Основы баз данных». 
Установить текущую дату в качестве даты выполнения попытки.
*/
insert into attempt (student_id, subject_id, date_attempt, result)
        select (select student_id from student where name_student = 'Баранов Павел'),
                (select subject_id from subject where name_subject = 'Основы баз данных'), 
                NOW(), null
;

-- #2
/*
Случайным образом выбрать три вопроса (запрос) по дисциплине, 
тестирование по которой собирается проходить студент, 
занесенный в таблицу attempt последним, и добавить их в таблицу testing. 
id последней попытки получить как максимальное значение id из таблицы attempt.
*/

insert into testing (attempt_id, question_id, answer_id)
        select maxAt.attempt_id, question.question_id, null
        from    question
                inner join 
                (select attempt_id, subject_id 
                from attempt 
                where attempt_id = (select max(attempt_id) from attempt)
                ) as maxAt
                using(subject_id)
        order by rand()
        limit 3
;

-- #3
/*
Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), 
далее необходимо вычислить результат(запрос) и занести его в таблицу attempt 
для соответствующей попытки.  
Результат попытки вычислить как количество правильных ответов, деленное на 3 
(количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до целого.

Будем считать, что мы знаем id попытки,  для которой вычисляется результат, 
в нашем случае это 8.
*/

update attempt
        set result = 
        (select resTab.result
        from
        (select attempt_id, 
        round(100*sum(is_correct)/count(testing.question_id),2) as result
        from    testing
                inner join answer using(answer_id)
        group by attempt_id
        ) as resTab
        where attempt_id = 8)
where attempt_id = 8
;

-- #4
/*
Удалить из таблицы attempt все попытки, выполненные раньше 1 мая 2020 года. 
Также удалить и все соответствующие этим попыткам вопросы из таблицы testing, 
которая создавалась следующим запросом:

CREATE TABLE testing (
    testing_id INT PRIMARY KEY AUTO_INCREMENT, 
    attempt_id INT, 
    question_id INT, 
    answer_id INT,
    FOREIGN KEY (attempt_id)  REFERENCES attempt (attempt_id) ON DELETE CASCADE
); 
*/
delete from attempt
where date_attempt < '2020-05-01'
;