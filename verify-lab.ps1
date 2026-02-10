# Lab Verification Script
Write-Host "--- Phase 1: Checking Namespace ---" -ForegroundColor Cyan
kubectl get ns kafka-lab

Write-Host "`n--- Phase 2: Checking Kafka Cluster ---" -ForegroundColor Cyan
kubectl get pods -n kafka-lab -l app=kafka
kubectl rollout status deployment/kafka -n kafka-lab --timeout=60s

Write-Host "`n--- Phase 3 & 4: Checking Producer & Consumer ---" -ForegroundColor Cyan
kubectl get pods -n kafka-lab -l app=kafka-producer
kubectl get pods -n kafka-lab -l app=kafka-consumer

Write-Host "`n--- Phase 5: Log Validation ---" -ForegroundColor Cyan
Write-Host "Producer Logs (last 5 lines):" -ForegroundColor Yellow
kubectl logs -l app=kafka-producer -n kafka-lab --tail=5
Write-Host "`nConsumer Logs (last 5 lines):" -ForegroundColor Yellow
kubectl logs -l app=kafka-consumer -n kafka-lab --tail=5

Write-Host "`n--- Phase 6: Service Check ---" -ForegroundColor Cyan
kubectl get svc -n kafka-lab
