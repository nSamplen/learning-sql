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
Создать вспомогательную таблицу applicant,  куда включить id образовательной программы, 
id абитуриента, сумму баллов абитуриентов в отсортированном сначала по id образовательной программы, 
а потом по убыванию суммы баллов виде (использовать запрос из предыдущего урока).
*/
create table applicant
        select  program_id,
                enrollee.enrollee_id,
                sum(result) as itog
        from    enrollee
                inner join program_enrollee on enrollee.enrollee_id = program_enrollee.enrollee_id
                inner join program using(program_id)
                inner join program_subject using(program_id)
                inner join subject using(subject_id)
                inner join enrollee_subject on 
                subject.subject_id = enrollee_subject.subject_id
                and enrollee.enrollee_id = enrollee_subject.enrollee_id
        group by program_id, enrollee.enrollee_id 
        order by program_id, itog desc
;

select * from applicant;

-- #2
/*
Из таблицы applicant, созданной на предыдущем шаге, удалить записи, 
если абитуриент на выбранную образовательную программу не набрал минимального балла 
хотя бы по одному предмету (использовать запрос из предыдущего урока).
*/

delete from applicant
where (applicant.program_id, applicant.enrollee_id) in
        (select  program_id,
                enrollee.enrollee_id
        from    enrollee
                inner join program_enrollee on enrollee.enrollee_id = program_enrollee.enrollee_id
                inner join program using(program_id)
                inner join program_subject using(program_id)
                inner join subject using(subject_id)
                inner join enrollee_subject on 
                        subject.subject_id = enrollee_subject.subject_id
                        and enrollee.enrollee_id = enrollee_subject.enrollee_id
        where result < min_result
        group by program_id,
                enrollee.enrollee_id 
        order by program_id,
                enrollee.enrollee_id
        )
;

-- #3
/*
Повысить итоговые баллы абитуриентов в таблице applicant на значения дополнительных баллов 
(использовать запрос из предыдущего урока).
*/
update applicant 
        inner join 
        (select  enrollee_id,
                ifnull(sum(bonus),0) as bonus
        from    enrollee
                left join enrollee_achievement using(enrollee_id)
                left join achievement using(achievement_id)
        group by enrollee_id
        ) as Tab2
        on applicant.enrollee_id = Tab2.enrollee_id
set itog = itog + Tab2.bonus
;

-- #4
/*
Поскольку при добавлении дополнительных баллов, абитуриенты по 
каждой образовательной программе могут следовать не в порядке убывания суммарных баллов, 
необходимо создать новую таблицу applicant_order на основе таблицы applicant. 
При создании таблицы данные нужно отсортировать сначала по id образовательной программы, 
потом по убыванию итогового балла. А таблицу applicant, которая была создана как вспомогательная, 
необходимо удалить.
*/
create table applicant_order
        select program_id, enrollee_id, itog
        from applicant
        order by program_id, itog desc
;
drop table applicant;

-- #5
/*
Включить в таблицу applicant_order новый столбец str_id целого типа , расположить его перед первым.
*/
alter table applicant_order
        add str_id int first
;

-- #6
/*
Занести в столбец str_id таблицы applicant_order нумерацию абитуриентов, 
которая начинается с 1 для каждой образовательной программы.
*/

SET @num_pr := 0;
SET @row_num := 1;
        update applicant_order
        inner join
        (SELECT *, 
        if(program_id = @num_pr, @row_num := @row_num + 1, @row_num := 1) AS str_num,
        @num_pr := program_id AS add_var 
        from applicant_order
        ) as Tab2
        on applicant_order.program_id = Tab2.program_id
        and applicant_order.enrollee_id = Tab2.enrollee_id
set applicant_order.str_id = str_num
;

select * from applicant_order;

-- #7
/*
Создать таблицу student,  в которую включить абитуриентов, 
которые могут быть рекомендованы к зачислению  в соответствии с планом набора. 
Информацию отсортировать сначала в алфавитном порядке по названию программ, 
а потом по убыванию итогового балла.
*/
create table student
        select  name_program,
                name_enrollee,
                itog
        from    enrollee
                inner join applicant_order using(enrollee_id)
                inner join program using(program_id)
        where str_id <= plan
        order by name_program, itog desc
;     

select * from student;

