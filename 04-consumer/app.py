from confluent_kafka import Consumer, KafkaError
import os
import json
import time

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

    print(f"Consumer starting. Connecting to {bootstrap_servers}, topic: {topic}", flush=True)

    try:
        while True:
            try:
                msg = consumer.poll(1.0)

                if msg is None:
                    continue
                if msg.error():
                    if msg.error().code() == KafkaError._PARTITION_EOF:
                        print(f"Reached end of partition: {msg.error()}", flush=True)
                        continue
                    else:
                        print(f"Consumer error: {msg.error()}", flush=True)
                        # Don't break on transient errors, let it retry
                        continue

                print(f"Received message: {msg.value().decode('utf-8')}", flush=True)
            except Exception as e:
                print(f"Unexpected error in poll loop: {e}", flush=True)
                time.sleep(1) # Brief pause before retrying
    except KeyboardInterrupt:
        print("Consumer stopping via KeyboardInterrupt", flush=True)
    finally:
        consumer.close()
        print("Consumer closed.", flush=True)

if __name__ == "__main__":
    main()
