from confluent_kafka import Consumer, KafkaError
import os
import json

def main():
    bootstrap_servers = os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'kafka-svc.kafka-lab.svc.cluster.local:9092')
    topic = os.getenv('KAFKA_TOPIC', 'kafka_lab_test_nubeprivada')
    group_id = os.getenv('KAFKA_GROUP_ID', 'kafka-lab-group')

    conf = {
        'bootstrap.servers': bootstrap_servers,
        'group.id': group_id,
        'auto.offset.reset': 'earliest'
    }

    consumer = Consumer(conf)
    consumer.subscribe([topic])

    print(f"Consumer starting. Connecting to {bootstrap_servers}, topic: {topic}")

    try:
        while True:
            msg = consumer.poll(1.0)

            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    continue
                else:
                    print(f"Consumer error: {msg.error()}")
                    break

            print(f"Received message: {msg.value().decode('utf-8')}")
    except KeyboardInterrupt:
        pass
    finally:
        consumer.close()

if __name__ == "__main__":
    main()
