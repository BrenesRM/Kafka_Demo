# Start execution of the Kafka Lab
Write-Host "Starting Kafka Lab Setup..." -ForegroundColor Green

# Phase 1 & 2: Infrastructure and Kafka
Write-Host "Phase 1 & 2: Applying Namespace and Kafka Resources..." -ForegroundColor Cyan
kubectl apply -f 01-prep/namespace.yaml
kubectl apply -f 02-kafka/kafka-kraft.yaml
kubectl apply -f 02-kafka/kafka-ui.yaml

Write-Host "Waiting for Kafka to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=kafka -n kafka-lab --timeout=120s

kubectl apply -f 02-kafka/topic-init.yaml

# Phase 3 & 4: Build and Deploy Apps
Write-Host "Phase 3 & 4: Building and Deploying Producer/Consumer..." -ForegroundColor Cyan
Write-Host "Building Producer Image..."
docker build -t kafka-producer:latest 03-producer
Write-Host "Building Consumer Image..."
docker build -t kafka-consumer:latest 04-consumer

Write-Host "Deploying Apps..."
kubectl apply -f 04-consumer/deployments.yaml

# Phase 5: Verification & UI Access
Write-Host "---------------------------------------------------" -ForegroundColor Gray
Write-Host "Setup commands completed successfully!" -ForegroundColor Green
Write-Host "Kafka UI Console: http://localhost:30080" -ForegroundColor Cyan

Write-Host "Verifying UI accessibility..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:30080" -Method Head -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "UI is accessible!" -ForegroundColor Green
    }
    else {
        Write-Host "UI is reachable but returned status: $($response.StatusCode)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "UI is not yet accessible (it might take a minute for the NodePort to be ready)." -ForegroundColor Red
}
Write-Host "---------------------------------------------------" -ForegroundColor Gray
Write-Host "To verify the full deployment, run: bash scripts/verify.sh" -ForegroundColor Yellow
