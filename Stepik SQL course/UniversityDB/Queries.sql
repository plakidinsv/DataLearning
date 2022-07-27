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


/*Show up programs needed passed subjects «Информатика» and  «Математика» to enroll.
 *  
 * Вывести образовательные программы, на которые для поступления необходимы 
 * предмет «Информатика» и «Математика» в отсортированном по названию программ виде.
 */

select * from program_subject ps ;
select * from subject s ;


select name_program
from program_subject ps
join program p using (program_id)
where subject_id in (select subject_id from subject s where name_subject in ('Информатика','Математика'))
group by name_program
having count(*) = 2
order by name_program;

-- OR 

select name_program
from subject
join program_subject using (subject_id)
join program using (program_id)
where name_subject in ('Математика','Информатика')
group by name_program
having count(*) = 2
order by name_program;


/*Deduct total grade for each student on every program he's applied.
 * Fetch up program name, applicant name, total grade.
 * sort by program then grade desc
 * 
 * 
 * Посчитать количество баллов каждого абитуриента на каждую образовательную программу, 
 * на которую он подал заявление, по результатам ЕГЭ. В результат включить название 
 * образовательной программы, фамилию и имя абитуриента, а также столбец с суммой баллов, 
 * который назвать itog. 
 * Информацию вывести в отсортированном сначала по образовательной программе, 
 * а потом по убыванию суммы баллов виде.
 */

select name_program, name_enrollee , sum(result) 
from program_enrollee pe 
join program_subject ps using(program_id)
join enrollee_subject es using (enrollee_id, subject_id)
join program p using(program_id)
join enrollee e using(enrollee_id)
group by 1,2  
order by 1, 3 desc;


/* Вывести название образовательной программы и фамилию тех абитуриентов, которые подавали 
 * документы на эту образовательную программу, но не могут быть зачислены на нее. 
 * Эти абитуриенты имеют результат по одному или нескольким предметам ЕГЭ, необходимым 
 * для поступления на эту образовательную программу, меньше минимального балла. 
 * Информацию вывести в отсортированном сначала по программам, а потом по фамилиям абитуриентов виде.

Например, Баранов Павел по «Физике» набрал 41 балл, а  для образовательной программы 
«Прикладная механика» минимальный балл по этому предмету определен в 45 баллов. 
Следовательно, абитуриент на данную программу не может поступить.

Для этого задания в базу данных добавлена строка:

INSERT INTO enrollee_subject (enrollee_id, subject_id, result) VALUES (2, 3, 41);
Добавлен человек, который сдавал Физику, но не подал документы ни на одну образовательную программу, где этот предмет нужен.
 */


select name_program, name_enrollee
from program_enrollee pe 
join program_subject ps using(program_id)
join enrollee_subject es using (enrollee_id, subject_id)
join program p using(program_id)
join enrollee e using(enrollee_id)
where result < min_result
group by 1,2  
order by 1, 2;




