show tables;
/*Show applicants wanted to enroll to «Мехатроника и робототехника» program
 * 
 *Вывести абитуриентов, которые хотят поступать на образовательную программу 
 *«Мехатроника и робототехника» в отсортированном по фамилиям виде. 
 */

select name_enrollee
from program_enrollee pe 
join program p using(program_id)
join enrollee e using(enrollee_id)
where name_program = 'Мехатроника и робототехника'
order by name_enrollee;


/*select programs needs subject «Информатика» get tested.
 * 
 *  * Вывести образовательные программы, на которые для поступления необходим 
 * предмет «Информатика». Программы отсортировать в обратном алфавитном порядке.
 */

select * from program_subject ps ;

select p.name_program 
from program_subject ps 
join subject s using (subject_id)
join program p using (program_id)
where s.name_subject = 'Информатика'
order by 1 desc;


/*Deduct number of applicants has passed tests on every subject, maximum, minimum and aveger grade.
 * 
 * 
 * Выведите количество абитуриентов, сдавших ЕГЭ по каждому предмету, максимальное, 
 * минимальное и среднее значение баллов по предмету ЕГЭ. 
 * Вычисляемые столбцы назвать Количество, Максимум, Минимум, Среднее. 
 * Информацию отсортировать по названию предмета в алфавитном порядке, 
 * среднее значение округлить до одного знака после запятой.
 */

select * from enrollee_subject es ;

select	s.name_subject, 
		count(es.enrollee_id) as Количество, 
		max(es.`result`) as Максимум, 
		min(es.`result`) as Минимум, 
		round(avg(es.`result`), 1) as Среднее
from 	enrollee_subject es
join subject s using(subject_id)
group by es.subject_id 
order by s.name_subject ;

/*Show programs with min_result in every subject <=40 to pass.
 * 
 * Вывести образовательные программы, для которых минимальный балл ЕГЭ по каждому предмету 
 * больше или равен 40 баллам. Программы вывести в отсортированном по алфавиту виде.
 */
select * from program_subject ps ;

select p.name_program 
from program_subject ps 
join program p using (program_id)
group by ps.program_id 
having min(ps.min_result) >= 40
order by p.name_program ;






