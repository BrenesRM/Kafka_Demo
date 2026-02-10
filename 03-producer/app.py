from confluent_kafka import Producer
import time
import os
import json
import socket

def delivery_report(err, msg):
    if err is not None:
        print(f'Message delivery failed: {err}')
    else:
        print(f'Message delivered to {msg.topic()} [{msg.partition()}]')

def main():
    bootstrap_servers = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka-svc.kafka-lab.svc.cluster.local:9092')
    topic = os.getenv('KAFKA_TOPIC', 'kafka_lab_test_nubeprivada')
    
    conf = {
        'bootstrap.servers': bootstrap_servers,
        'client.id': socket.gethostname()
    }

    producer = Producer(conf)

    print(f"Producer starting. Connecting to {bootstrap_servers}, topic: {topic}")
    
    count = 0
    while True:
        count += 1
        data = {
            'id': count,
            'message': f'Test message {count} from producer',
            'timestamp': time.time()
        }
        
        producer.produce(topic, key=str(count), value=json.dumps(data), callback=delivery_report)
        producer.flush()
        
        time.sleep(5)

if __name__ == "__main__":
    main()
