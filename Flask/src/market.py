import os
import psycopg2
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql://postgres:1@localhost:5432/postgres"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy()
db.init_app(app)
migrate = Migrate(app, db)

class Product(db.Model):
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
    __tablename__ = 'cart'

    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)
    product = db.relationship('Product', backref=db.backref('cart', lazy=True))
    quantity = db.Column(db.Integer, nullable=False)

    def __init__(self, product_id, quantity):
        self.product_id = product_id
        self.quantity = quantity

    def __repr__(self):
        return f"<Cart {self.id}>"

with app.app_context():
    db.create_all()

@app.route('/products', methods=['POST', 'GET'])
def products():
    if request.method == 'POST':
        data = request.get_json()
        product = Product(name=data['name'], price=data['price'])
        db.session.add(product)
        db.session.commit()

        return jsonify({'id': product.id}), 201
        
    elif request.method == 'GET':
        name = request.args.get('name')
        sort_by = request.args.get('sort_by', 'name')
        sort_order = request.args.get('sort_order', 'asc')

        query = Product.query

        if name:
            query = query.filter(Product.name.like('%' + name + '%'))

        if sort_by == 'price':
            query = query.order_by(Product.price if sort_order == 'asc' else desc(Product.price))
        else:
            query = query.order_by(Product.name if sort_order == 'asc' else desc(Product.name))

        products = query.all()

        return jsonify([{'id': product.id, 'name': product.name, 'price': product.price} for product in products]), 200

@app.route('/shopping_cart', methods=['POST'])
def add_to_cart():
    data = request.get_json()
    product_id = data['product_id']
    quantity = data['quantity']

    product = Product.query.get(product_id)

    if not product:
        return jsonify({'error': 'Product not found'}), 404

    cart = Cart(product_id=product_id, quantity=quantity)
    db.session.add(cart)
    db.session.commit()

    return jsonify({'id': cart.id}), 201

@app.route('/cart/<int:product_id>', methods=['PUT'])
def update_cart(product_id):
        data = request.get_json()
        quantity = data['quantity']
    
        cart = Cart.query.filter_by(product_id=product_id).first()
    
        if not cart:
            return jsonify({'error': 'Product not found in shopping cart'}), 404
    
        cart.quantity = quantity
        db.session.commit()
    
        return jsonify({'id': cart.id}), 200

if __name__ == '__main__':
    db.create_all()
    app.run(debug=True)

