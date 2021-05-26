-- Предметная область

-- Университет состоит из совокупности факультетов (школ). 
-- Поступление абитуриентов осуществляется на образовательные программы по результатам 
-- Единого государственного экзамена (ЕГЭ). 
-- Каждая образовательная программа относится к определенному факультету, 
-- для нее определены необходимые для поступления предметы ЕГЭ, 
-- минимальный балл по этим предметам, а также план набора (количество мест) 
-- на образовательную программу.

-- В приемную комиссию абитуриенты подают заявления на образовательную программу, 
-- каждый абитуриент может выбрать несколько образовательных программ (но не более трех). 
-- В заявлении указывается фамилия, имя, отчество абитуриента, а также его достижения: 
-- получил ли он медаль за обучение в школе, имеет ли значок ГТО и пр. 
-- При этом за каждое достижение определен дополнительный балл. 
-- Абитуриент предоставляет сертификат с результатами сдачи  ЕГЭ. 
-- Если абитуриент выбирает образовательную программу, 
-- то у него обязательно должны быть сданы предметы, определенные на эту программу, 
-- причем балл должен быть не меньше минимального по данному предмету.

-- Зачисление абитуриентов осуществляется так: сначала вычисляется сумма баллов 
-- по предметам на каждую образовательную программу, добавляются баллы достижения, 
-- затем абитуриенты сортируются в порядке убывания суммы баллов и отбираются 
-- первые по количеству мест, определенному планом набора.

/*
Таблица department:

department_id	name_department
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(30)
*/

/*
Таблица subject:

subject_id	name_subject
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(30)
*/

/*
Таблица program (в последнем столбце указан план набора абитуриентов на образовательную программу):

program_id	name_program	department_id	plan
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(50)	INT	INT
*/

/*
Таблица enrollee:

enrollee_id	name_enrollee
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(50)
*/

/*
Таблица achievement(таблица включает все достижения, которые 
учитываются при поступлении в университет, в последнем столбце указывается количество баллов, 
которое добавляется к сумме баллов по предметам ЕГЭ при расчете общего балла абитуриента):

achievement_id	name_achievement	bonus
INT PRIMARY KEY
AUTO_INCREMENT	VARCHAR(30)	INT
*/

/*
Таблица enrollee_achievement(в таблице содержится информация о том, 
какие достижения имеют абитуриенты):

enrollee_achiev_id	enrollee_id	achievement_id
INT PRIMARY KEY
AUTO_INCREMENT	INT	INT
*/

/*Таблица program_subject(в таблице указано, какие предметы ЕГЭ необходимы для поступления на каждую программу, в последнем столбце – минимальный балл по каждому предмету для образовательной программы):

program_subject_id	program_id	subject_id	min_result
INT PRIMARY KEY
AUTO_INCREMENT	INT	INT	INT*/

/*Таблица program_enrollee(таблица включает информацию, 
на какую образовательную программу хочет поступить абитуриент):

program_enrollee_id	program_id	enrollee_id
INT PRIMARY KEY
AUTO_INCREMENT	INT	INT*/

/*Таблица enrollee_subject(баллы ЕГЭ каждого абитуриента):

enrollee_subject_id	enrollee_id	subject_id	result
INT PRIMARY KEY
AUTO_INCREMENT	INT	INT	INT*/

-- #1
/*
Вывести абитуриентов, которые хотят поступать на образовательную программу 
«Мехатроника и робототехника» в отсортированном по фамилиям виде.
*/

select name_enrollee
from    enrollee
        inner join program_enrollee using(enrollee_id)
        inner join program using(program_id)
where name_program = 'Мехатроника и робототехника'
order by name_enrollee
;

-- #2
/*
Вывести образовательные программы, на которые для поступления необходим предмет «Информатика». 
Программы отсортировать в обратном алфавитном порядке.
*/

select name_program
from    program
        inner join program_subject using(program_id)
        inner join subject 
        on subject.subject_id = program_subject.subject_id and name_subject = 'Информатика'
order by name_program desc
;

-- #3
/*
Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, 
минимальное и среднее значение баллов по предмету ЕГЭ. 
Информацию отсортировать по названию предмета в алфавитном порядке, 
среднее значение округлить до одного знака после запятой.
*/

select  name_subject,
        count(enrollee_id) as Количество,
        max(result) as Максимум,
        min(result) as Минимум,
        round(avg(result),1) as Среднее
from    subject
        inner join enrollee_subject using(subject_id)
group by name_subject
order by name_subject
;
-- #4
/*
Вывести образовательные программы, для которых минимальный балл ЕГЭ 
по каждому предмету больше или равен 40 баллам. Программы вывести 
в отсортированном по алфавиту виде. 
*/
select distinct name_program
from    program
        inner join program_subject using(program_id)
group by name_program
having min(min_result) >= 40
order by name_program
;

-- #5
/*
Вывести образовательные программы, которые имеют самый большой план набора,  
вместе с этой величиной.
*/
select  name_program,
        plan
from program
where plan = (select max(plan) from program)
;

-- #6
/*
Посчитать, сколько дополнительных баллов получит каждый абитуриент. 
Информацию вывести в отсортированном по фамилиям виде.
*/

select  name_enrollee,
        ifnull(sum(bonus),0) as Бонус
from    enrollee
        left join enrollee_achievement using(enrollee_id)
        left join achievement using(achievement_id)
group by name_enrollee
order by name_enrollee
;

-- #7
/*
Выведите сколько человек подало заявление на каждую образовательную программу 
и конкурс на нее (число поданных заявлений деленное на количество мест по плану), 
округленный до 2-х знаков после запятой. 
В запросе вывести название факультета, к которому относится образовательная программа, 
название образовательной программы, план набора абитуриентов на образовательную программу (plan), 
количество поданных заявлений (Количество) и Конкурс. 
Информацию отсортировать в порядке убывания конкурса.
*/
select  name_department,
        name_program,
        plan,
        count(enrollee_id) as Количество,
        round(count(enrollee_id)/plan,2) as Конкурс
from    department
        inner join program using(department_id)
        left join program_enrollee using(program_id)
group by name_department,
        name_program,
        plan
order by Конкурс desc
;

-- #8
/*
Вывести образовательные программы, на которые для поступления необходимы предмет 
«Информатика» и «Математика» в отсортированном по названию программ виде.
*/

select name_program
from    program
        inner join program_subject using(program_id)
        inner join subject on
        subject.subject_id = program_subject.subject_id
        and
        (name_subject = 'Математика'
        or name_subject = 'Информатика')
group by name_program
having  count(*) = 2
order by name_program
;

-- #9
/*
Посчитать количество баллов каждого абитуриента на каждую образовательную программу, 
на которую он подал заявление, по результатам ЕГЭ. 
В отсортированном сначала по образовательной программе, а потом по убыванию суммы баллов виде.
*/

select  name_program,
        name_enrollee,
        sum(result) as itog
from    enrollee
        inner join program_enrollee on enrollee.enrollee_id = program_enrollee.enrollee_id
        inner join program using(program_id)
        inner join program_subject using(program_id)
        inner join subject using(subject_id)
        inner join enrollee_subject on 
        subject.subject_id = enrollee_subject.subject_id
        and enrollee.enrollee_id = enrollee_subject.enrollee_id
group by name_program,
        name_enrollee 
order by name_program, itog desc
;

-- #10
/*
Вывести название образовательной программы и фамилию тех абитуриентов, 
которые подавали документы на эту образовательную программу, но не могут быть зачислены на нее. 
Эти абитуриенты имеют результат по одному или нескольким предметам ЕГЭ, 
необходимым для поступления на эту образовательную программу, меньше минимального балла. 
Информацию вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.

Например, Баранов Павел по «Физике» набрал 41 балл, а  для образовательной программы 
«Прикладная механика» минимальный балл по этому предмету определен в 45 баллов. 
Следовательно, абитуриент на данную программу не может поступить.
*/

select  name_program,
        name_enrollee
from    enrollee
        inner join program_enrollee on enrollee.enrollee_id = program_enrollee.enrollee_id
        inner join program using(program_id)
        inner join program_subject using(program_id)
        inner join subject using(subject_id)
        inner join enrollee_subject on 
        subject.subject_id = enrollee_subject.subject_id
        and enrollee.enrollee_id = enrollee_subject.enrollee_id
where result < min_result
group by name_program,
        name_enrollee 
order by name_program, name_enrollee
;

