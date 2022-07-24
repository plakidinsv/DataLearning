-- Assignments

/* Show students who has passed «Основы баз данных» subjecct,
 * show attempt date and result.
 * order by descending
 *
 * Вывести студентов, которые сдавали дисциплину «Основы баз данных», 
 * указать дату попытки и результат. 
 * Информацию вывести по убыванию результатов тестирования*/

select s.name_student, a.date_attempt, a.result
from student s
join attempt a using(student_id)
join subject s2 using(subject_id)
where s2.name_subject = 'Основы баз данных'
order by a.result desc;


/*Show number of attempts per subject, aveneger result rounded 2 symbols after dot.
 * result is percentage of correct answers.
 * show name of subject, number of attempts and avg result.
 * 
 * Вывести, сколько попыток сделали студенты по каждой дисциплине, 
 * а также средний результат попыток, который округлить до 2 знаков 
 * после запятой. 
 * Под результатом попытки понимается процент правильных ответов на 
 * вопросы теста, который занесен в столбец result.  
 * В результат включить название дисциплины, а также вычисляемые столбцы 
 * Количество и Среднее. Информацию вывести по убыванию средних результатов.
 */

select name_subject,
		count(result) as 'Количество',
		round(avg(result), 2) as 'Среднее'
from subject s 
left outer join attempt a using(subject_id)
group by name_subject ;


/*Show students who has a max results of attempts.
 * 
 * Вывести студентов (различных студентов), имеющих максимальные результаты 
 * попыток. Информацию отсортировать в алфавитном порядке по фамилии студента.
 * Максимальный результат не обязательно будет 100%, поэтому явно это значение
 * в запросе не задавать.
 */

select s.name_student, a.result
from student s 
join attempt a using(student_id)
where a.result = (select max(result) from attempt a)
order by s.name_student;

/*If student made a few attempts on the same subject show dafference between dates 
 * of rirst and last attempt.
 * Query result must include name of student, subject and calculated column Interval.
 * 
 * Если студент совершал несколько попыток по одной и той же дисциплине, 
 * то вывести разницу в днях между первой и последней попыткой. 
 * В результат включить фамилию и имя студента, название дисциплины и 
 * вычисляемый столбец Интервал. Информацию вывести по возрастанию разницы. 
 * Студентов, сделавших одну попытку по дисциплине, не учитывать.
 */

select  s.name_student, s2.name_subject, datediff(max(a.date_attempt), min(a.date_attempt)) as Интервал
from student s 
join attempt a using(student_id)
join subject s2 using(subject_id)
group by 1, 2
having count(date_attempt) > 1
order by 3 ;

