/*Отобрать все шаги, в которых рассматриваются вложенные запросы (то есть в названии шага упоминаются 
 * /вложенные запросы). Указать к какому уроку и модулю они относятся. Для этого вывести 3 поля:
 * в поле Модуль указать номер модуля и его название через пробел;
 * в поле Урок указать номер модуля, порядковый номер урока (lesson_position) через точку и название
 * урока через пробел;
 * в поле Шаг указать номер модуля, порядковый номер урока (lesson_position) через точку, порядковый 
 * номер шага (step_position) через точку и название шага через пробел. 
 * Длину полей Модуль и Урок ограничить 19 символами, при этом слишком длинные надписи обозначить 
 * многоточием в конце (16 символов - это номер модуля или урока, пробел и  название Урока или Модуля,
 * к ним присоединить "..."). 
 * Информацию отсортировать по возрастанию номеров модулей, порядковых номеров уроков и порядковых
 *  номеров шагов.*/

select	concat(left(concat(module_id, ' ', module_name), 16), '...') as Модуль,
		concat(left((concat(module_id, '.', lesson_position, ' ', lesson_name)), 16), '...') as Урок,
		concat(module_id, '.', lesson_position, '.', step_position, ' ', step_name) as Шаг
from step s 
join lesson l using (lesson_id)
join module m using (module_id)
where step_name like ('%вложенн%запрос%');

/*Заполнить таблицу step_keyword следующим образом: если ключевое слово есть в названии шага, то включить
 * в step_keyword строку с id шага и id ключевого слова.*/

insert into step_keyword  (step_id, keyword_id)
select step_id, keyword_id 
from step
cross join keyword
where regexp_like (step_name, CONCAT('\\b', keyword.keyword_name, '\\b'))
order by 2;


/*Реализовать поиск по ключевым словам. Вывести шаги, с которыми связаны ключевые слова MAX и AVG одновременно. 
 * Для шагов указать id модуля, позицию урока в модуле, позицию шага в уроке через точку, после позиции шага 
 * перед заголовком - пробел. Позицию шага в уроке вывести в виде двух цифр (если позиция шага меньше 10, то 
 * перед цифрой поставить 0). Столбец назвать Шаг. Информацию отсортировать по первому столбцу в алфавитном порядке.
 * Пояснение
 * В таблице step_keyword хранится информация о том, какие ключевые слова в каких шагах используются. При этом 
 * ключевое слово может быть связано с шагом, в названии которого этого ключевого слова нет. */

select concat(module_id, '.', lesson_position, '.', 
              if(step_position < 10, concat('0', step_position), step_position),
              ' ', step_name) as Шаг
from step
join lesson using(lesson_id)
join module using(module_id)
join step_keyword using(step_id)
join keyword using(keyword_id)
where keyword_name = 'MAX' or keyword_name = 'AVG'
group by step_id
having count(keyword_name) = 2
order by 1;

-- OR with using LPAD

select concat(module_id, '.', lesson_position, '.', 
              LPAD(step_position, 2, '0'),
              ' ', step_name) as Шаг
from step
join lesson using(lesson_id)
join module using(module_id)
join step_keyword using(step_id)
join keyword using(keyword_id)
where keyword_name = 'MAX' or keyword_name = 'AVG'
group by step_id
having count(keyword_name) = 2
order by 1;

/*Посчитать, сколько студентов относится к каждой группе. Столбцы назвать Группа, Интервал, Количество. 
 *Указать границы интервала.*/

SELECT  
    CASE
        WHEN rate <= 10 THEN "I"
        WHEN rate <= 15 THEN "II"
        WHEN rate <= 27 THEN "III"
        ELSE "IV"
    END AS Группа, 
    CASE
        WHEN rate <= 10 THEN "от 0 до 10"
        WHEN rate <= 15 THEN "от 11 до 15"
        WHEN rate <= 27 THEN "от 16 до 27"
        ELSE "больше 27"
    END AS Интервал, 
    COUNT(student_id) AS Количество
FROM      
    (SELECT student_id, COUNT(*) AS rate
     FROM (SELECT student_id, step_id
          FROM step_student
          WHERE result = "correct"
          GROUP BY student_id, step_id
         ) query_in
     GROUP BY student_id
     ORDER BY 2
    ) query_in_1
GROUP BY Группа, Интервал;

/*Исправить запрос примера так: для шагов, которые  не имеют неверных ответов,  указать 100 как процент 
 * успешных попыток, если же шаг не имеет верных ответов, указать 0. Информацию отсортировать сначала 
 * по возрастанию успешности, а затем по названию шага в алфавитном порядке.*/

WITH get_count_correct (st_n_c, count_correct) 
  AS (
    SELECT step_name, count(*)
    FROM 
        step 
        INNER JOIN step_student USING (step_id)
    WHERE result = "correct"
    GROUP BY step_name
   ),
  get_count_wrong (st_n_w, count_wrong) 
  AS (
    SELECT step_name, count(*)
    FROM 
        step 
        INNER JOIN step_student USING (step_id)
    WHERE result = "wrong"
    GROUP BY step_name
   )  
SELECT st_n_c AS Шаг,
    coalesce(ROUND(count_correct / (count_correct + count_wrong) * 100), 100) AS Успешность
FROM  
    get_count_correct 
    LEFT JOIN get_count_wrong ON st_n_c = st_n_w
UNION
SELECT st_n_w AS Шаг,
    coalesce(ROUND(count_correct / (count_correct + count_wrong) * 100), 0) AS Успешность
FROM  
    get_count_correct 
    RIGHT JOIN get_count_wrong ON st_n_c = st_n_w
ORDER BY 2, 1 ;


/*Вычислить прогресс пользователей по курсу. Прогресс вычисляется как отношение верно пройденных 
 * шагов к общему количеству шагов в процентах, округленное до целого. В нашей базе данные о 
 * решениях занесены не для всех шагов, поэтому общее количество шагов определить как количество 
 * различных шагов в таблице step_student.
 * Тем пользователям, которые прошли все шаги (прогресс = 100%) выдать "Сертификат с отличием". 
 * Тем, у кого прогресс больше или равен 80% - "Сертификат". Для остальных записей в столбце 
 * Результат задать пустую строку ("").
 * Информацию отсортировать по убыванию прогресса, затем по имени пользователя в алфавитном порядке.*/


-- quantuty of steps
set @total_q = (select count(distinct step_id) from step_student ss);

with student_progress (student_id, progress)
	as (select student_id, round(count(distinct step_id)/@total_q*100)
	from step_student ss 
	where result = 'correct'
	group by student_id
	)
select student_name as Студент, progress as Прогресс,
     case
         when progress < 80 then ''
         when progress between 80 and 99 then 'Сертификат'
         else 'Сертификат с отличием'
     end as Результат
from student_progress
join student using (student_id)
order by 2 desc, 1;

/*Для студента с именем student_61 вывести все его попытки: название шага, результат и дату 
 *отправки попытки (submission_time). Информацию отсортировать по дате отправки попытки и 
 *указать, сколько минут прошло между отправкой соседних попыток. Название шага ограничить 
 *20 символами и добавить "...". Столбцы назвать Студент, Шаг, Результат, Дата_отправки, Разница.*/

select  student_name as Студент, 
        concat(left(step_name, 20), '...') as Шаг, 
        result as Результат, 
        from_unixtime(submission_time) as Дата_отправки,
        sec_to_time(submission_time - lag(submission_time, 1, submission_time) over (order by submission_time)) as Разница
from step_student
join student using (student_id)
join step using (step_id)
where student_name = 'student_61';


/*Посчитать среднее время, за которое пользователи проходят урок по следующему алгоритму:
для каждого пользователя вычислить время прохождения шага как сумму времени, потраченного 
на каждую попытку (время попытки - это разница между временем отправки задания и временем 
начала попытки), при этом попытки, которые длились больше 4 часов не учитывать, так как 
пользователь мог просто оставить задание открытым в браузере, а вернуться к нему на следующий день;
для каждого студента посчитать общее время, которое он затратил на каждый урок;
вычислить среднее время выполнения урока в часах, результат округлить до 2-х знаков после запятой;
вывести информацию по возрастанию времени, пронумеровав строки, для каждого урока указать номер 
модуля и его позицию в нем.
Столбцы результата назвать Номер, Урок, Среднее_время.*/

with 
    tmp as
    (select student_id, lesson_id, sum(submission_time-attempt_time)/3600 as lesson_time
    from step_student
    join step using (step_id)
    where submission_time-attempt_time < 4*3600
    group by 1, 2
    order by 1, 2),

    tmp2 as
    (select lesson_name, round(avg(lesson_time), 2) as Среднее_время
    from tmp
    join lesson using(lesson_id)
    group by 1)

select  row_number() over (order by Среднее_время) as Номер,
        concat(module_id, '.', lesson_position, ' ', lesson_name) as Урок, 
        Среднее_время
from tmp2
join lesson using(lesson_name);


/*Вычислить рейтинг каждого студента относительно студента, прошедшего наибольшее количество 
 *шагов в модуле (вычисляется как отношение количества пройденных студентом шагов к максимальному 
 *количеству пройденных шагов, умноженное на 100). Вывести номер модуля, имя студента, количество 
 *пройденных им шагов и относительный рейтинг. Относительный рейтинг округлить до одного знака 
 *после запятой. Столбцы назвать Модуль, Студент, Пройдено_шагов и Относительный_рейтинг  
 *соответственно. Информацию отсортировать сначала по возрастанию номера модуля, потом по убыванию 
 *относительного рейтинга и, наконец, по имени студента в алфавитном порядке.*/

select module_id as Модуль, student_name as Студент, count(distinct step_id) as Пройдено_шагов,
       round(count(distinct step_id)/max(count(distinct step_id)) over (partition by module_id)*100, 1)  as Относительный_рейтинг
from step_student join student using(student_id)
                  join step using(step_id)
                  join lesson using(lesson_id)
where result = 'correct'
group by 1, 2
order by 1, 4 desc, 2;


/*Проанализировать, в каком порядке и с каким интервалом пользователь отправлял последнее верно 
 *выполненное задание каждого урока. Учитывать только студентов, прошедших хотя бы один шаг из 
 *всех трех уроков. В базе занесены попытки студентов  для трех уроков курса, поэтому анализ 
 *проводить только для этих уроков.
 *Для студентов прошедших как минимум по одному шагу в каждом уроке, найти последний пройденный 
 *шаг каждого урока - крайний шаг, и указать:
 *имя студента;
 *номер урока, состоящий из номера модуля и через точку позиции каждого урока в модуле;
 *время отправки  - время подачи решения на проверку;
 *разницу во времени отправки между текущим и предыдущим крайним шагом в днях, при этом для первого
 *шага поставить прочерк ("-"), а количество дней округлить до целого в большую сторону.
 *Столбцы назвать  Студент, Урок,  Макс_время_отправки и Интервал  соответственно. 
 *Отсортировать результаты по имени студента в алфавитном порядке, а потом по возрастанию времени отправки.*/

with cte (student, module, sub_time) as
    (
    select  student_name,
            concat(module_id, '.', lesson_position),
            max(submission_time)
    from    step_student
    join    step using (step_id)
    join    lesson using (lesson_id)
    join    student using (student_id)
    where   student_name in 
                        (-- students passed 3 lessons
                        select student_name
                        from step_student
                        join step using (step_id)
                        join lesson using (lesson_id)
                        join student using (student_id)
                        where result = 'correct'
                        group by student_name
                        having count(distinct lesson_id) = 3)
            and result = 'correct'
    group by 1,2  
    order by 1,2
    )

select student as Студент,
       module as Урок,
       from_unixtime(sub_time) as Макс_время_отправки,
       ifnull(ceil((sub_time - lag(sub_time) over (partition by student order by from_unixtime(sub_time)))/86400), '-') as Интервал  
from cte
order by 1, 3;


/*Для студента с именем student_59 вывести следующую информацию по всем его попыткам:
информация о шаге: номер модуля, символ '.', позиция урока в модуле, символ '.', позиция шага в модуле;
порядковый номер попытки для каждого шага - определяется по возрастанию времени отправки попытки;
результат попытки;
время попытки (преобразованное к формату времени) - определяется как разность между временем отправки 
попытки и времени ее начала, в случае если попытка длилась более 1 часа, то время попытки заменить на 
среднее время всех попыток пользователя по всем шагам без учета тех, которые длились больше 1 часа;
относительное время попытки  - определяется как отношение времени попытки (с учетом замены времени попытки) 
к суммарному времени всех попыток  шага, округленное до двух знаков после запятой.
Столбцы назвать  Студент,  Шаг, Номер_попытки, Результат, Время_попытки и Относительное_время. 
Информацию отсортировать сначала по возрастанию id шага, а затем по возрастанию номера попытки 
(определяется по времени отправки попытки).*/

set @avg_time = (select round(avg(submission_time - attempt_time))
                from student
                join step_student using (student_id)
                where student_name = 'student_59'
                        and (submission_time - attempt_time)<=3600);

select student_name as Студент,
                concat(module_id, '.', lesson_position, '.', step_position) as Шаг,
                rank() over (partition by step_id order by submission_time) as Номер_попытки,
                result as Результат,
                sec_to_time(if((submission_time - attempt_time)<=3600, (submission_time - attempt_time), @avg_time)) 
                as Время_попытки,
                round(if((submission_time - attempt_time)<=3600, (submission_time - attempt_time), @avg_time)*100/
                sum(if((submission_time - attempt_time)<=3600, (submission_time - attempt_time), @avg_time)) over 
                (partition by step_id),2) as Относительное_время
        from student
        join step_student using (student_id)
        join step using (step_id)
        join lesson using (lesson_id)
        where student_name = 'student_59' 
        order by step_id, 3;
       

/*Выделить группы обучающихся по способу прохождения шагов:

I группа - это те пользователи, которые после верной попытки решения шага делают неверную (скорее всего для того, 
чтобы поэкспериментировать или проверить, как работают примеры);
II группа - это те пользователи, которые делают больше одной верной попытки для одного шага (возможно, улучшают 
свое решение или пробуют другой вариант);
III группа - это те пользователи, которые не смогли решить задание какого-то шага (у них все попытки по этому 
шагу - неверные).
Вывести группу (I, II, III), имя пользователя, количество шагов, которые пользователь выполнил по соответствующему 
способу. Столбцы назвать Группа, Студент, Количество_шагов. Отсортировать информацию по возрастанию номеров групп, 
потом по убыванию количества шагов и, наконец, по имени студента в алфавитном порядке.*/
       
-- Group # 2
select student_name, step_id
from step_student
join student using (student_id)
group by 1,2
having count(result = 'correct') >= 2
order by 1,2;

       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       