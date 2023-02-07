# **Задание**

## Микросервис для электронного магазина

### ***Модель/cущности:***

Товар - отвечает за товар на складе, например - телефон такой-то марки от такого-то производителя. У товара есть назавание и цена.

Корзина – список товаров. У элемента корзины есть цена и количество.

 
Сущности хранятся в Postgres на localhost:5432  (можно запускать командой docker run -d --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 -d postgres)

### ***REST API методы:***

1. Создать новый товар
2. Получить список названий товаров, с возможностью фильтрации и сортировки по:
    
    a) названию

    b) цене

3. Добавить товар в корзину, поменять количество товара в корзине

Методы принимают JSON на входе и отдают JSON на выходе.

### ***Настройка окружения***

Настройка виртуального окружения с использованием стандартного venv модуля python 3.9.13

```shell
python -m venv flask-venv
```

Установка неоходимых пакетов

```shell
pip install -r requirements.txt
```


Запуск Flask сервиса 

```shell
flask . /flask-venv/Source/activate
```

Запрос к таблице products на поиск товара с наименованием 'Samsung' не дороже 13000 с упорядочиванием по наименованию и цене в порядке убывания

```shell
curl -H 'Content-Type: application/json' -X GET http://127.0.0.1:5000/products -d '{"name": "Samsung", "price_max": 15000, "order_by": ["name", "price"], "order_by_dir": ["desc", "desc"]}'
```

Запрос к таблице products на добавление товара с наименованием 'Samsung' стоимостью 12500

```shell
curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5000/products -d '{"name": "Samsung", "price": 10000}'
```

Деактивация venv

```shell
deactivate
```

