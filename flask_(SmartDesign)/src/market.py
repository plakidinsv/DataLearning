import os
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('SQLALCHEMY_DATABASE_URI')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy()
db.init_app(app)
migrate = Migrate(app, db)

class Product(db.Model):
    """
    Модель 'Product' - таблица 'product' в базе данных

    Содержит атрибуты: id, name, price для каждого товара    
    """
    __tablename__ = 'product'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(), nullable=False)
    price = db.Column(db.Float, nullable=False)

    def __init__(self, name, price):
        self.name = name
        self.price = price
    
    def __repr__(self):
        return f"<Product {self.name}>"


class Cart(db.Model):
    """
    Модель 'Cart' - таблица 'cart' в базе данных

    Содержит атрибуты: 
        id - идентификатор позиции в корзине
        product_id - id товара из таблицы 'product'
        quantity - количество товара
        price - общая стоимость приобретаемой единицы товара
    """
    __tablename__ = 'cart'

    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    product = db.relationship('Product', backref=db.backref('cart', lazy=True))
    quantity = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Float, nullable=False)

    def __init__(self, product_id, quantity, price):
        self.product_id = product_id
        self.quantity = quantity
        self.price = price

    def __repr__(self):
        return f"<Cart {self.id}>"


with app.app_context():
    db.create_all()

@app.route('/products', methods=['POST', 'GET'])
def products():
    """
    Функция для добвления товара в таблицу 'product' и получения данных о товаре.

    Добавление товара происходит при использовании метода 'POST'. 
    Для добавления товара необходимо указать наименование товара и его стоимость.

    Получение данных по товару из таблицы 'product' - использование метода 'GET'.
    Если запрос отправлен без параметров - возвращает список всех товаров из таблицы.
    Возможна фильтрация по имени, диапазону цен, сортировка по имени и цене в порядке убывания/возрастания
    """
    if request.method == 'POST':
        data = request.get_json()
        product = Product(name=data['name'], price=data['price'])
        db.session.add(product)
        db.session.commit()

        return jsonify({'id': product.id}), 201

    elif request.method == 'GET':
        data = request.get_json()
        name = data.get('name', None)
        price_min = data.get("price_min", None)
        price_max = data.get("price_max", None)
        order_by = data.get("order_by", None)
        order_by_dir = data.get("order_by_dir", None)

        query = db.select(Product)
        if name:
            query = query.filter(Product.name == name)
        if price_min:
            query = query.filter(Product.price >= price_min)
        if price_max:
            query = query.filter(Product.price <= price_max)
        if order_by:
            col1 = Product.name if order_by[0] == 'name' else Product.price
            if len(order_by) > 1:
                col2 = Product.price if order_by[1] == 'price' else Product.name 
                if order_by_dir:
                    if order_by_dir[0] == 'desc':
                        col1 = col1.desc()
                    if len(order_by) > 1 and order_by_dir[1] == 'desc':
                        col2 = col2.desc()          
                query = query.order_by(col1, col2)
            else:
                if order_by_dir:
                    if order_by_dir[0] == 'desc':
                        col1 = col1.desc()
                query = query.order_by(col1)
                    
        if not db.session.execute(query).scalar():
            return jsonify({'error': 'Product not found'}), 404

        products = db.session.execute(query).scalars()

        return jsonify([{'id': product.id, 'name': product.name, 'price': product.price} for product in products]), 200


@app.route('/cart/add', methods=['POST'])
def add_to_cart():
    """
    Функция для добавление товара в корзину

    Принимает на вход наименование товара и его количество.
    В таблицу 'cart' добваляется id товара, его количество и общая стоимость
    """
    data = request.get_json()
    product_name = data['name']
    quantity = data['quantity']

    product = db.session.execute(db.select(Product).where(Product.name == f'{product_name}')).scalar()
    if not product:
        return jsonify({'error': 'Product not found'}), 404

    cart = Cart(product_id=product.id, quantity=quantity, price=product.price * quantity)
    db.session.add(cart)
    db.session.commit()

    return jsonify({'id': cart.id}), 201


@app.route('/cart/update', methods=['PUT'])
def update_cart():
        """
        Функция для изменения данных (количества товара) в корзине

        Принимает на вход наименование товара и его новое количество для змаказа.
        Обновляет общую стоимость соответсвующего товара в корзине.
        """
        data = request.get_json()
        product_name = data['name']
        quantity = data['quantity']
    
        product = db.session.execute(db.select(Product).where(Product.name == f'{product_name}')).scalar()
        cart = db.session.execute(db.select(Cart).where(Cart.product_id == f'{product.id}')).scalar()
            
        if not cart:
            return jsonify({'error': 'Product not found in shopping cart'}), 404

        cart.quantity=quantity
        cart.price=product.price * quantity
        db.session.add(cart)
        db.session.commit()
    
        return jsonify({'id': cart.id}), 200

if __name__ == '__main__':
    app.run(debug=True)