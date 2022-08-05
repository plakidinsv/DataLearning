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
















