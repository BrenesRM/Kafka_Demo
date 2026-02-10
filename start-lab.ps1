# Start execution of the Kafka Lab
Write-Host "Starting Kafka Lab Setup..." -ForegroundColor Green

# Phase 1 & 2: Infrastructure and Kafka
Write-Host "Phase 1 & 2: Applying Namespace and Kafka Resources..." -ForegroundColor Cyan
kubectl apply -f 01-prep/namespace.yaml
kubectl apply -f 02-kafka/kafka-kraft.yaml
kubectl apply -f 02-kafka/topic-init.yaml

# Phase 3 & 4: Build and Deploy Apps
Write-Host "Phase 3 & 4: Building and Deploying Producer/Consumer..." -ForegroundColor Cyan
Write-Host "Building Producer Image..."
docker build -t kafka-producer:latest 03-producer
Write-Host "Building Consumer Image..."
docker build -t kafka-consumer:latest 04-consumer

Write-Host "Deploying Apps..."
kubectl apply -f 04-consumer/deployments.yaml

# Phase 5: Verification Hint
Write-Host "Setup commands completed." -ForegroundColor Green
Write-Host "To verify the deployment, run: bash scripts/verify.sh" -ForegroundColor Yellow
