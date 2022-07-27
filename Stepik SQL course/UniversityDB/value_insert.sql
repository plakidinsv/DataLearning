insert into department (name_department)
values 	('Инженерная школа'),
		('Школа естественных наук');
		
	select * from department d ;

insert into subject (name_subject)
values 	('Русский язык'),
		('Математика'),
		('Физика'),
		('Информатика');

select * from subject s ;

INSERT INTO program (name_program, department_id, plan)
VALUES 	('Прикладная математика и информатика', 2, 2),
		('Математика и компьютерные науки', 2, 1),
		('Прикладная механика', 1, 2),
		('Мехатроника и робототехника', 1, 3);
	select * from program;


INSERT INTO enrollee (name_enrollee)
VALUES 	('Баранов Павел'), ('Абрамова Катя'), ('Семенов Иван'),
		('Яковлева Галина'), ('Попов Илья'), ('Степанова Дарья');
	select * from enrollee e ;


INSERT INTO achievement (name_achievement, bonus)
VALUES 	('Золотая медаль', 5), ('Серебряная медаль', 3),
    	('Золотой значок ГТО', 3), ('Серебряный значок ГТО', 1);
    select * from achievement a ;


INSERT INTO enrollee_achievement (enrollee_id, achievement_id)
VALUES 	(1, 2), (1, 3), (3, 1), (4, 4), (5, 1),(5, 3);


INSERT INTO program_subject (program_id, subject_id, min_result)
VALUES 	(1, 1, 40),(1, 2, 50), (1, 4, 60), ( 2, 1, 30),
       	(2, 2, 50),(2, 4, 60), (3, 1, 30),(3, 2, 45),
       	(3, 3, 45),(4, 1, 40), (4, 2, 45), (4, 3, 45);


INSERT INTO program_enrollee (program_id, enrollee_id)
VALUES 	(3, 1), (4, 1), (1, 1), (2, 2), (1, 2),
       	(1, 3), (2, 3), (4, 3), (3, 4), (3, 5),
       	(4, 5), (2, 6), (3, 6), (4, 6);


INSERT INTO enrollee_subject (enrollee_id, subject_id, result)
VALUES 	(1, 1, 68), (1, 2, 70), (1, 3, 41), (1, 4, 75), (2, 1, 75), (2, 2, 70),
      	(2, 4, 81), (3, 1, 85), (3, 2, 67), (3, 3, 90), (3, 4, 78), (4, 1, 82),
       	(4, 2, 86), (4, 3, 70), (5, 1, 65), (5, 2, 67), (5, 3, 60),
       	(6, 1, 90), (6, 2, 92), (6, 3, 88), (6, 4, 94);
