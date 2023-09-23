#!/usr/bin/env python
import pika, sys, os
from time import time

def main():
    host = os.environ.get('RMQ_SERVICE_HOST')
    port = os.environ.get('RMQ_PORT_5672_TCP_PORT')
    user = os.environ.get('RMQ_USER')
    password = os.environ.get('RMQ_PASSWORD')
    workerNode = os.environ.get('NODE_NAME')
    queue=os.environ.get('QUEUE_NAME', 'demo_service_workitems')
    connection = None

    try:

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
        channel.basic_qos(prefetch_count=1)

        def callback(ch, method, properties, bodyBytes):
            # simulate some work being performed
            connection.sleep(10)
            # record time processing completed
            secondsFromEpochNow = time()
            # acknowledge the message
            ch.basic_ack(delivery_tag = method.delivery_tag)
            # report how long since message was submitted
            body = bodyBytes.decode("utf-8") 
            parts = body.split(' ')
            workItemNumber = parts[0]
            secondsFromEpochMessageSent = float(parts[1]) if parts[1].replace('.','',1).isdigit() else 0;
            secondsPassed = int(secondsFromEpochNow - secondsFromEpochMessageSent)
            print(f"Work item #{workItemNumber} processed on node {workerNode}"
                f" in {secondsPassed}s since it was submitted", flush=True)
        
        channel.basic_consume(
            queue=queue, 
            on_message_callback=callback, 
            auto_ack=False)
        channel.start_consuming()
        
    except pika.exceptions.AMQPConnectionError as amqp_error:
        # Handle connection errors
        print(f"AMQP Connection Error: {amqp_error}", flush=True)
        
    except Exception as e:
        # Handle other exceptions
        print(f"An error occurred: {e}", flush=True)

    finally:
        # Close the connection (if it was established)
        if connection and connection.is_open:
            connection.close()

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print('Interrupted')
        try:
            sys.exit(0)
        except SystemExit:
            os._exit(0)