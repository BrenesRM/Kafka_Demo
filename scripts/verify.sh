#!/bin/bash
# Lab Verification Script

echo "--- Phase 1: Checking Namespace ---"
kubectl get ns kafka-lab

echo "--- Phase 2: Checking Kafka Cluster ---"
kubectl get pods -n kafka-lab -l app=kafka
kubectl rollout status deployment/kafka -n kafka-lab --timeout=60s

echo "--- Phase 3 & 4: Checking Producer & Consumer ---"
kubectl get pods -n kafka-lab -l app=kafka-producer
kubectl get pods -n kafka-lab -l app=kafka-consumer

echo "--- Phase 5: Log Validation ---"
echo "Producer Logs (last 5 lines):"
kubectl logs -l app=kafka-producer -n kafka-lab --tail=5
echo "Consumer Logs (last 5 lines):"
kubectl logs -l app=kafka-consumer -n kafka-lab --tail=5

echo "--- Phase 6: Service Check ---"
kubectl get svc -n kafka-lab
