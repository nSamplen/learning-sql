-- В таблице fine  представлена информация о начисленных водителям штрафах 
-- за нарушения правил дорожного движения (ПДД) (фамилия водителя, номер машины, 
-- описание нарушения, сумма штрафа, дата совершения нарушения и дата оплаты штрафа)

-- В таблицу  traffic_violation занесены нарушения ПДД и соответствующие штрафы (в рублях)

-- #1
/*
Создать таблицу fine следующей структуры:

Поле	        Описание
fine_id	        ключевой столбец целого типа с автоматическим увеличением значения ключа на 1
name	        строка длиной 30
number_plate	строка длиной 6
violation	строка длиной 50
sum_fine	вещественное число, максимальная длина 8, количество знаков после запятой 2
date_violation	дата
date_payment	дата
*/

create table fine (
        fine_id int PRIMARY KEY auto_increment,
        name varchar(30),
        number_plate varchar(6),
        violation varchar(50),
        sum_fine DECIMAL(8,2),
        date_violation date,
        date_payment date    
);

-- #2
/*
Добавить в таблицу записи с ключевыми значениями 6, 7, 8.
6	Баранов П.Е.	Р523ВТ	Превышение скорости(от 40 до 60)	2020-02-14	 
7	Абрамова К.А.	О111АВ	Проезд на запрещающий сигнал	 	2020-02-23	 
8	Яковлев Г.Р.	Т330ТТ	Проезд на запрещающий сигнал	 	2020-03-03	 
*/

insert into fine(name, number_plate, violation, sum_fine, date_violation, date_payment) values
        ("Баранов П.Е.","Р523ВТ","Превышение скорости(от 40 до 60)",null,"2020-02-14", null),	 
        ("Абрамова К.А.","О111АВ","Проезд на запрещающий сигнал",null,"2020-02-23",null),	 
        ("Яковлев Г.Р.","Т330ТТ","Проезд на запрещающий сигнал",null,"2020-03-03", null)	
;


-- #3
/*
Занести в таблицу fine суммы штрафов, которые должен оплатить водитель, 
в соответствии с данными из таблицы traffic_violation. 
При этом суммы заносить только в пустые поля столбца  sum_fine.
*/

update fine as f, traffic_violation as tv
        t f.sum_fine = tv.sum_fine
where
        f.sum_fine is null
        and f.violation = tv.violation
;


-- #4
/*
Вывести фамилию, номер машины и нарушение только для тех водителей, 
которые на одной машине нарушили одно и то же правило два и более раз. 
При этом учитывать все нарушения, независимо от того оплачены они или нет. 
Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, 
потом по номеру машины и, наконец, по нарушению.
*/
select
        name, number_plate, violation
from fine
group by name, number_plate, violation
having count(*)>1
order by name, number_plate, violation
;

-- #5
/*
В таблице fine увеличить в два раза сумму неоплаченных штрафов 
для отобранных на предыдущем шаге записей. 
*/
update fine, 
        (
                select
                name, number_plate, violation
                from fine
                group by name, number_plate, violation
                having count(*)>1
                order by name, number_plate, violation
        ) as T2
        set fine.sum_fine = fine.sum_fine*2
where
        fine.date_payment is null
        and T2.name = fine.name 
        and T2.number_plate = fine.number_plate
        and T2.violation = fine.violation
;


-- #6
/*
Водители оплачивают свои штрафы. В таблице payment занесены даты их оплаты:
payment_id name	        number_plate violation	                        date_violation	date_payment
1	   Яковлев Г.Р.	М701АА	     Превышение скорости(от 20 до 40)	2020-01-12	2020-01-22

Необходимо:
- в таблицу fine занести дату оплаты соответствующего штрафа из таблицы payment; 
- уменьшить начисленный штраф в таблице fine в два раза (только для новых штрафов, 
дата оплаты которых занесена в payment) , 
если оплата произведена не позднее 20 дней со дня нарушения.
*/

update fine, payment
        set fine.date_payment = payment.date_payment,
        fine.sum_fine = if(datediff(payment.date_payment, payment.date_violation) <=20,round(fine.sum_fine/2,2),fine.sum_fine)
where
        fine.date_payment is null
        and fine.name = payment.name
        and fine.number_plate = payment.number_plate
        and fine.violation = payment.violation
;

-- #7
/*
Создать новую таблицу back_payment, куда внести информацию о неоплаченных штрафах 
(Фамилию и инициалы водителя, номер машины, нарушение, сумму штрафа  и  дату нарушения) 
из таблицы fine.
*/

create table back_payment as
        select name,number_plate, violation, sum_fine, date_violation
        from fine
        where date_payment is null
;

-- #8
/*
Удалить из таблицы fine информацию о нарушениях, совершенных раньше 1 февраля 2020 года. 
*/

delete from fine
where date_violation < "2020-02-01"
