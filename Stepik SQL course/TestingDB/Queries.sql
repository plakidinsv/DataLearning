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

/*Student might have a test in a few subjects.
 * Show subject and number of unique students (call mesure as Quantity),
 * Sort by descending of quantity then subject name.
 * Result must include subjects not been chosen by any student.
 * 
 *  
 * Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). 
 * Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), 
 * которые по ней проходили тестирование . Информацию отсортировать сначала по убыванию количества, 
 * а потом по названию дисциплины. В результат включить и дисциплины, тестирование по которым студенты 
 * еще не проходили, в этом случае указать количество студентов 0.
 */

select s.name_subject, count(distinct a.student_id) as Quantity
from attempt a 
right outer join subject s using(subject_id)
group by 1
order by 2 desc, 1;


/*Select 3 random question on subject «Основы баз данных».
 * REsult must include columns question_id и name_question
 * 
 * Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». 
 *В результат включите столбцы question_id и name_question.*/

select question_id, name_question 
from question q
join subject s using(subject_id)
where s.name_subject = 'Основы баз данных'
order by rand()
limit 3;

/*Show questions included in 'Семенов Иван''s test on «Основы SQL» subject with attemot_id = 7.
 * show answer given by student and show is it correct or not.
 * Result must include question, answer and calculated column Result
 * 
 * Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  
 * (значение attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет 
 * (вывести Верно или Неверно). В результат включить вопрос, ответ и вычисляемый столбец  Результат.
 */

select q.name_question, a.name_answer, if(is_correct, 'Верно', 'Неверно') as Результат
from question q 
join (select * from testing where attempt_id = 7) as t using(question_id)
join answer a using(answer_id);


/*Calculate testing results.
 * REsulat = number of correct answers divided on 3 (number of qustions in every attempt). ronud (.2)
 * Show up student name, subject name, date of attempt and calculated result.
 * order by sudent name, then date attemp descending
 * 
 * Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов, 
 * деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до двух 
 * знаков после запятой. Вывести фамилию студента, название предмета, дату и результат. Последний столбец 
 * назвать Результат. Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.
 */


select a.student_id , a.subject_id , a.date_attempt , round(sum(result)*100/3, 2) as Результат
from attempt a 
group by a.student_id , a.subject_id , a.date_attempt
order by a.student_id, a.date_attempt desc;


