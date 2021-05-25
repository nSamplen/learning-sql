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

/*Таблица attempt(в таблице хранится информация о каждой попытке сдачи теста : 
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
Вывести студентов, которые сдавали дисциплину «Основы баз данных», 
указать дату попытки и результат. Информацию вывести по убыванию результатов тестирования.
*/

select  name_student,
        date_attempt,
        result
from    student
        inner join attempt using(student_id)
        inner join subject using(subject_id)
where name_subject = 'Основы баз данных'
order by result desc
;

-- #2
/*
Вывести, сколько попыток сделали студенты по каждой дисциплине, 
а также средний результат попыток, который округлить до 2 знаков после запятой. 
Под результатом попытки понимается процент правильных ответов на вопросы теста, 
который занесен в столбец result.  Информацию вывести по убыванию средних результатов.
*/

select  name_subject,
        count(date_attempt) as Количество,
        round(avg(result),2) as Среднее
from    subject
        left join attempt using(subject_id)
group by name_subject
order by Среднее desc
;

-- #3
/*
Вывести студента (различных студентов), имеющих максимальные результаты попыток. 
Информацию отсортировать в алфавитном порядке по фамилии студента.

Максимальный результат не обязательно будет 100%, поэтому явно это значение в запросе не задавать.
*/

select  name_student,
        result
from    student
        inner join attempt using(student_id)
where result = 
        (
            select max(result) from attempt
        )
order by name_student
;

-- #4
/*
Если студент совершал несколько попыток по одной и той же дисциплине, 
то вывести разницу в днях между первой и последней попыткой. 
Информацию вывести по возрастанию разницы. 
Студентов, сделавших одну попытку по дисциплине, не учитывать. 
*/
select  name_student,
        name_subject,
        datediff(max(date_attempt),min(date_attempt)) as Интервал
from    student
        inner join attempt using(student_id)
        inner join subject using(subject_id)
group by name_student, name_subject
having count(date_attempt) > 1
order by Интервал
;

-- #5
/*
Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). 
Вывести дисциплину и количество уникальных студентов, которые по ней проходили тестирование. 
Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. 
В результат включить и дисциплины, тестирование по которым студенты еще не проходили, 
в этом случае указать количество студентов 0.
*/
select  name_subject,
        count(student_id) as Количество
from    subject
        left join
        (select distinct student_id, subject_id from attempt) as stud_attempt
        using(subject_id)
group by name_subject
order by Количество desc, name_subject
;

-- #6
/*
Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных».
*/

select  question_id,
        name_question
from    (select subject_id from subject where name_subject = 'Основы баз данных') as base_bd
        inner join question using(subject_id)
order by RAND()
limit 3
;

-- #7
/*
Вывести вопросы, которые были включены в тест для Семенова Ивана 
по дисциплине «Основы SQL» 2020-05-17  (значение attempt_id для этой попытки равно 7). 
Указать, какой ответ дал студент и правильный он или нет. 
*/

select  name_question,
        name_answer,
        if(is_correct=0,'Неверно','Верно') as Результат
from    (select student_id from student where name_student='Семенов Иван') as getStud 
        inner join (select attempt_id, subject_id, student_id from attempt where date_attempt='2020-05-17') as atDate using(student_id)
        inner join (select subject_id from subject where name_subject='Основы SQL') as getSubj
                using(subject_id)
        inner join testing using(attempt_id)
        inner join question using(question_id)
        inner join answer using(answer_id)
;

-- #8
/*
Посчитать результаты тестирования. 
Результат попытки вычислить как количество правильных ответов, деленное на 3 
(количество вопросов в каждой попытке) и умноженное на 100. 
Результат округлить до двух знаков после запятой. 
Вывести фамилию студента, название предмета, дату и результат. 
Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.
*/

select  name_student,
        name_subject,
        date_attempt,
        round(100*sum(is_correct)/count(testing.question_id),2) as Результат
from    student
        inner join attempt using(student_id)
        inner join subject using(subject_id)
        inner join testing using(attempt_id)
        inner join answer using(answer_id)
group by name_student, name_subject, date_attempt
order by name_student, date_attempt desc
;

-- #9
/*
Для каждого вопроса вывести процент успешных решений, 
то есть отношение количества верных ответов к общему количеству ответов, 
значение округлить до 2-х знаков после запятой. 
Также вывести название предмета, к которому относится вопрос, 
и общее количество ответов на этот вопрос. 
Информацию отсортировать сначала по названию дисциплины, 
потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.

Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".
*/

select  name_subject,
        concat(LEFT(name_question, 30),'...') as Вопрос,
        count(*) as Всего_ответов,
        round(100*sum(is_correct)/count(answer_id),2) as Успешность
from    question
        inner join testing using(question_id)
        inner join answer using(answer_id)
        inner join subject using(subject_id)
group by Вопрос, name_subject
order by name_subject, Успешность desc, Вопрос
;