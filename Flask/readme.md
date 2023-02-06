настройка виртуального окружения с использованием стандартного venv модуля python 3.9.13

'''shell
python -m venv flask-venv
'''

Установка неоходимых пакетов

'''shell
pip install -r requirements.txt
'''

Запуск Flask сервиса 

'''shell
flask . /flask-venv/Source/activate
'''

Запрос к таблице products на поиск товара с наименованием 'Samsung' не дороже 13000 с упорядочиванием по наименованию и цене в порядке убывания

```shell
curl -H 'Content-Type: application/json' -X GET http://127.0.0.1:5000/products -d '{"name": "Samsung", "price_max": 15000, "order_by": ["name", "price"], "order_by_dir": ["desc", "desc"]}'
```

Запрос к таблице products на добавление товара с наименованием 'Samsung' стоимостью 12500

'''shell
curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5000/products -d '{"name": "Xaomi", "price": 10000}'
'''

Деактивация venv

'''shell
deactivate
'''


