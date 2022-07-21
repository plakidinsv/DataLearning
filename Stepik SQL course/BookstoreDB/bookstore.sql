/* Part 1. Inserting values to BOOKSTORE mini project DB.
DB designed and build by using MySQL Workbench tool 

Part 2. Solving some assignments*/


show tables;

select * from genre;

SELECT * FROM author;

select * from book;

insert into book (title, author_id, genre_id, price, amount)
VALUES  ('Мастер и Маргарита', 1, 1,	670.99,	3), 
        ('Белая гвардия', 1, 1, 540.50,	5),
        ('Идиот', 2, 1, 460.00, 10),
        ('Братья Карамазовы', 2, 1,	799.01,	2),
        ('Игрок', 2, 1,	480.50,	10),
        ('Стихотворения и поэмы',	3,	2,	650.00,	15),
        ('Черный человек',	3,	2,	570.20,	6),
        ('Лирика',	4,	2,	518.99,	2);

INSERT INTO city (name_city, days_delivery)
VALUES  ('Москва',	5),
        ('Санкт-Петербург',	3),
        ('Владивосток',	12);

SELECT * FROM city;

INSERT INTO client (name, city_id, email)
VALUES 
        ('Баранов Павел',	3,	'baranov@test'),
        ('Абрамова Катя',	1,	'abramova@test'),
        ('Семенонов Иван',	2,	'semenov@test'),
        ('Яковлева Галина',	1,	'yakovleva@test');

SELECT * FROM client;

/*-- Primary key had VALUES started not from 1 
- could be the problems with assigments from course

next 2 queries deleting values with 'wrong' PK and resetting auto increment for table*/

/*DELETE FROM client
WHERE client_id IN (13,14,15,16);
ALTER TABLE buy AUTO_INCREMENT = 1;*/

DELETE FROM buy
WHERE buy_id IN (13, 14, 15);

INSERT INTO buy (buy_description, client_id)
VALUES  ('Доставка только вечером', 1),
        (NULL, 3),
        ('Упаковать каждую книгу по отдельности', 2),
        (NULL, 1);
        
SELECT * FROM buy;

INSERT INTO buy_book (buy_id, book_id, amount)
VALUES  (1,	1,	1),
        (1,	7,	2),
        (1,	3,	1),
        (2,	8,	2),
        (3,	3,	2),
        (3,	2,	1),
        (3,	1,	1),
        (4,	5,	1);

SELECT * FROM buy_book;

INSERT INTO step (name_step)
VALUES  ('Оплата'),
        ('Упаковка'),
        ('Транспортировка'),
        ('Доставка');

SELECT * FROM step;

INSERT INTO buy_step  (buy_id, step_id, date_step_beg, date_step_end)
VALUES  (1, 1, '2020-02-20', '2020-02-20'),
        (1, 2, '2020-02-20', '2020-02-21'),
        (1, 3, '2020-02-22', '2020-03-07'),
        (1, 4, '2020-03-08', '2020-03-08'),
        (2, 1, '2020-02-28', '2020-02-28'),
        (2, 2, '2020-02-29', '2020-03-01'),
        (2, 3, '2020-03-02', NULL),
        (2, 4, NULL, NULL),
        (3, 1, '2020-03-05', '2020-03-05'),
        (3, 2, '2020-03-05', '2020-03-06'),
        (3, 3, '2020-03-06', '2020-03-10'),
        (3, 4, '2020-03-11', NULL), 
        (4, 1, '2020-03-20', NULL), 
        (4, 2, NULL, NULL), 
        (4, 3, NULL, NULL), 
        (4, 4, NULL, NULL); 

SELECT * FROM buy_step;


/*Fetch all (Баранов Павел)'s orders (order id, book title, 
book price and amount of ordered books) in order by order id and book title*/

SELECT  buy.buy_id, book.title, book.price, buy_book.amount
FROM 
        buy 
        INNER JOIN buy_book USING(buy_id)
        INNER JOIN book USING(book_id)
        INNER JOIN client USING(client_id)
WHERE   client.name = 'Баранов Павел'
ORDER BY 
        buy_id, 
        book.title;

/* Fetch how many times each book was ordered.
Show it's author, book title, amount of orders. 
Last column call as 'Количество'.
reslult must be ordered by author name, then book title*/

SELECT  author.name_author,
        book.title,
        IFNULL(COUNT(buy_book.amount), 0) AS 'Количество'
FROM    author
        INNER JOIN book USING(author_id)
        LEFT OUTER JOIN buy_book USING(book_id)
GROUP BY book.title
ORDER BY author.name_author,
        book.title;

/*Fetch cities where lives the clients who ordered books.
Show up amount of orders per city (call it as 'Количество').
Information must be descending ordered by mount of orders 
then by names*/


SELECT  city.name_city,
        COUNT(buy.buy_id) AS 'Количество'
FROM    city
        INNER JOIN client USING(city_id)
        INNER JOIN buy USING(client_id)
GROUP BY city.name_city
ORDER BY COUNT(buy.buy_id) DESC, city.name_city;

/*Fetch ids of paid orders and payment date
ps. it can be solved without join, buy in this case join uses
for practice*/

SELECT * FROM step;

SELECT  buy.buy_id, buy_step.date_step_end
FROM    buy
        INNER JOIN buy_step USING(buy_id)
        INNER JOIN step USING(step_id)
WHERE   step.name_step = 'Оплата' 
        AND buy_step.date_step_end IS NOT NULL;

/*Fetch information about orders: id, client, cost (amount*price).
Order by ids*/

SELECT buy.buy_id, client.name, round(SUM(buy_book.amount * book.price), 2) AS 'Стоимость'
FROM client
        INNER JOIN buy USING(client_id)
        INNER JOIN buy_book USING(buy_id)
        INNER JOIN book USING(book_id)
GROUP BY client.name, buy.buy_id
ORDER BY buy.buy_id;

/* Fetch ids and current step name for order. 
Exeption: if order delivered - do not show information.
order by asc ids
*/

SELECT buy_step.buy_id, step.name_step
FROM buy_step
INNER JOIN step USING(step_id)
WHERE buy_step.date_step_beg AND buy_step.date_step_end is NULL
ORDER BY buy_step.buy_id;

/*Fetch information about delivery step:
- actual delivery period per ids;
-  delay per ids
*/

SELECT  bs.buy_id,
        DATEDIFF(bs.date_step_end, bs.date_step_beg) AS 'Delivery_period',
        IF(DATEDIFF(bs.date_step_end, bs.date_step_beg) > city.days_delivery, 
                DATEDIFF(bs.date_step_end, bs.date_step_beg) - city.days_delivery, 0) AS 'Delay'
FROM    buy_step AS bs
INNER JOIN step USING(step_id)
INNER JOIN buy USING(buy_id)
INNER JOIN client USING(client_id)
INNER JOIN city USING(city_id)
WHERE   step.name_step = 'Транспортировка' -- only step Transportation (delivery step)
        AND
        bs.date_step_end IS NOT NULL;

/* Find all clients ordered Dostoevki's books. 
Result must be ordered by ASC name.
Must be used author name but not author id.*/

SELECT DISTINCT client.name
FROM    client
        INNER JOIN buy USING(client_id)
        INNER JOIN buy_book USING(buy_id)
        INNER JOIN book USING(book_id)
        INNER JOIN author USING(author_id)
WHERE   author.name_author LIKE 'Достоевский%'
ORDER BY client.name ASC;

/* Find best sellers genre/genres, show number of sells*/

SELECT genre.name_genre,
        SUM(buy_book.amount) AS 'Количество'
FROM genre
    JOIN book USING(genre_id)
    JOIN buy_book USING(book_id)
GROUP BY genre.name_genre
HAVING SUM(buy_book.amount) =  
       (select max(sum_amount) as max_sum_amount
       from
           (select genre_id, sum(buy_book.amount) as sum_amount
            from book 
                JOIN buy_book USING(book_id)
             group by genre_id) as tmp)
    

/* Compare monthly revenue for current and previous years.
Show year, month, total proceed sorted by month, than year ASC.
Names of columns: Year, Month, Summ.

Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. 
Для этого вывести год, месяц, сумму выручки в отсортированном сначала по 
возрастанию месяцев, затем по возрастанию лет виде.
 Название столбцов: Год, Месяц, Сумма
*/

/* Information about orders in previous years stored in buy_archive layer
*/

DROP TABLE IF EXISTS buy_archive;
CREATE TABLE buy_archive
(
    buy_archive_id INT PRIMARY KEY AUTO_INCREMENT,
    buy_id         INT,
    client_id      INT,
    book_id        INT,
    date_payment   DATE,
    price          DECIMAL(8, 2),
    amount         INT
);

INSERT INTO buy_archive (buy_id, client_id, book_id, date_payment, amount, price)
VALUES (2, 1, 1, '2019-02-21', 2, 670.60),
       (2, 1, 3, '2019-02-21', 1, 450.90),
       (1, 2, 2, '2019-02-10', 2, 520.30),
       (1, 2, 4, '2019-02-10', 3, 780.90),
       (1, 2, 3, '2019-02-10', 1, 450.90),
       (3, 4, 4, '2019-03-05', 4, 780.90),
       (3, 4, 5, '2019-03-05', 2, 480.90),
       (4, 1, 6, '2019-03-12', 1, 650.00),
       (5, 2, 1, '2019-03-18', 2, 670.60),
       (5, 2, 4, '2019-03-18', 1, 780.90);


-- select revenue per month for previous year

SELECT YEAR(ba.date_payment) AS 'Year',
       MONTHNAME(ba.date_payment) AS 'Month',
       SUM(ba.price * ba.amount) AS 'Revenue'
FROM buy_archive AS ba
GROUP BY 1, 2;

-- select revenue per month for current year

select YEAR(date_step_end) AS 'Year',
        MONTHNAME(date_step_end) AS 'Month',
        SUM(price * buy_book.amount) AS 'Стоимость'
from step
INNER JOIN buy_step USING(step_id)
INNER JOIN buy USING(buy_id)
INNER JOIN buy_book USING(buy_id)
INNER JOIN book USING(book_id)
WHERE name_step = 'Оплата' AND date_step_end IS NOT NULL
GROUP BY 1, 2;

-- union two results

SELECT YEAR(ba.date_payment) AS 'Year',
       MONTHNAME(ba.date_payment) AS 'Month',
       SUM(ba.price * ba.amount) AS 'Revenue'
FROM buy_archive AS ba
GROUP BY 1, 2
UNION 
select YEAR(date_step_end) AS 'Year',
        MONTHNAME(date_step_end) AS 'Month',
        SUM(price * buy_book.amount) AS 'Стоимость'
from step
INNER JOIN buy_step USING(step_id)
INNER JOIN buy USING(buy_id)
INNER JOIN buy_book USING(buy_id)
INNER JOIN book USING(book_id)
WHERE name_step = 'Оплата' AND date_step_end IS NOT NULL
GROUP BY 1, 2
ORDER BY 2, 1;

/* Show information about quantity and revenue per book in 
past and current year.
Aggregated columns must be named as Quantity as Revenue.
Information must be sorted by revenue from higher to lower.

Для каждой отдельной книги необходимо вывести информацию 
о количестве проданных экземпляров и их стоимости за текущий 
и предыдущий год . 
Вычисляемые столбцы назвать Количество и Сумма. 
Информацию отсортировать по убыванию стоимости.
*/

SELECT title, 
    SUM(united.amount) as quantity, 
    SUM(united.revenue) as revenue
FROM book
JOIN 
    (SELECT book_id, 
            amount, 
            price* amount as revenue
    FROM buy_archive

    union all

    SELECT book_id,
            buy_book.amount,
            price * buy_book.amount AS revenue
    FROM book
    INNER JOIN buy_book USING(book_id)
    INNER join buy USING(buy_id)
    INNER join buy_step USING(buy_id)
    INNER join step using(step_id)
    WHERE step.name_step = 'Оплата'
        AND date_step_end is not null
    ) AS united
    USING(book_id)
GROUP BY title
ORDER BY Сумма DESC; 