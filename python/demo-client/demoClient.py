from flask import Flask, request, redirect, url_for, session, send_file, render_template
from os import environ
from time import time
from datetime import datetime
from werkzeug.middleware.proxy_fix import ProxyFix
import pika

app = Flask(__name__)
app.wsgi_app = ProxyFix(
    app.wsgi_app, x_for=1, x_proto=1, x_port=1, 
    x_host=0, x_prefix=0
)
app.secret_key = environ.get('SECRET_KEY')


@app.route("/", methods=['GET', 'POST'])
def index():
    # require authenticated users
    if not 'username' in session:
        return redirect(url_for('login'))
    amount = request.form.get('amount')
    publish_time = None
    if amount is not None:
        publish_time = publish(amount)
    return render_template('publish.html', amount=amount, publish_time=publish_time)


@app.route("/login", methods=['GET', 'POST'])
def login():
    if request.method == 'POST' and \
            'username' in request.form and 'password' in request.form and \
            request.form['username'] == environ.get('DEMO_USER') and \
            request.form['password'] == environ.get('DEMO_PASSWORD'):
        session['username'] = request.form['username']
        return redirect(url_for('index'))
    return send_file('login.html')


@app.route('/logout', methods=['GET', 'POST'])
def logout():
    session.pop('username', None)
    return redirect(url_for('index'))


def publish(amount):
    """Publish workitems to the workitems queue in RabbitMQ and return the publish time

    Args:
        amount (int): amount of workitems to publish 

    Returns:
        str: publish time string in UTC in form %Y-%m-%dT%H:%M:%SZ for example 2023-09-04T11:21:43Z
    """
    host = environ.get('RMQ_SERVICE_HOST')
    port = environ.get('RMQ_PORT_5672_TCP_PORT')
    user = environ.get('RMQ_USER')
    password = environ.get('RMQ_PASSWORD')
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(
            host=host,
            port=port,
            credentials=pika.PlainCredentials(
                user, password
            )
        )
    )
    channel = connection.channel()

    amount_number = int(amount) if amount.isnumeric() else 0
    publish_start_time = time()
    for i in range(amount_number):
        publish_time = time()
        message = f"{i} {publish_time}"
        channel.basic_publish(exchange='workitems', routing_key='', body=message)
        # print how long passed in seconds since the publish start time
        print(f"Published work item #{i} in {int(publish_time - publish_start_time)}s since publish start.", flush=True)

    connection.close()
    return datetime.utcfromtimestamp(publish_start_time).strftime('%Y-%m-%dT%H:%M:%SZ')