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


/*Show programs has the maximum plan.
 *  
 * Вывести образовательные программы, которые имеют самый большой план набора,  вместе с этой величиной. */

select * from program;

select name_program, plan
from program p 
where plan = (select max(plan) from program p2);


/*Deduct bouns points for every applicant.
 * Sort by names. 
 * 
 * Посчитать, сколько дополнительных баллов получит каждый абитуриент. 
 * Столбец с дополнительными баллами назвать Бонус. 
 * Информацию вывести в отсортированном по фамилиям виде.
 */
select * from enrollee_achievement ea ;
select * from achievement a ;

-- explain
select e.name_enrollee , if(sum(bonus) is null, 0, sum(bonus)) as total_bonus -- IFNULL(SUM(add_ball), 0) or sum(coalesce(add_ball, 0))
from achievement a 
join enrollee_achievement ea using (achievement_id)
right outer join enrollee e using(enrollee_id)
group by enrollee_id
order by 1;


/*deduct number of applicants per program and it's competition for a place
 * (namber of applies/plan) rounded by 2 digits.
 * Fetch up department name, program, plan, number of applicants, competition for a place.
 * sort by competititon desc.
 * 
 * 
 * 
 * Выведите сколько человек подало заявление на каждую образовательную программу 
 * и конкурс на нее (число поданных заявлений деленное на количество мест по плану), 
 * округленный до 2-х знаков после запятой. В запросе вывести название факультета, 
 * к которому относится образовательная программа, название образовательной программы, 
 * план набора абитуриентов на образовательную программу (plan), количество поданных 
 * заявлений (Количество) и Конкурс. Информацию отсортировать в порядке убывания конкурса.
 */
select * from department d ;
select * from program p ;
select * from program_enrollee pe ;

select d.name_department ,
		p.name_program ,
		p.plan ,
		count(enrollee_id) as Количество,
		round(count(enrollee_id)/plan, 2) as Конкурс
from department d 
join program p using(department_id)
right outer join program_enrollee pe using(program_id)
group by d.name_department ,
		p.name_program ,
		p.plan 
order by 5 desc	;




