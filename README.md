# Kafka Kubernetes POC Lab

## Overview
This lab demonstrates a local Kafka deployment on Kubernetes using Docker Desktop.

## The Shared Responsibility Model
In a healthy Kafka ecosystem, responsibilities should be split based on Infrastructure (The Pipeline) vs. Data (The Water).

| Feature | Ops / SysAdmin (Platform) | Dev (Application) |
| :--- | :--- | :--- |
| Infrastructure | Provisioning (Terraform), Broker tuning, Disk I/O | N/A |
| Cluster Health | Monitoring (Prometheus/Grafana), Alerting | N/A |
| Topic Management | Setting "Guardrails" (Max partition limits) | Creating Topics (via GitOps or API) |
| Security | TLS Encryption, SASL/IAM Authentication | Defining ACLs (who can read/write) |
| Data Logic | N/A | Schema Evolution, Consumer Group logic |
| Performance | OS-level tuning, Zookeeper/KRaft health | Producer batching, Consumer lag fixing |

### Why you should NOT "Delegate All" to Dev
Kafka is a stateful distributed system. Unlike a stateless container that you can just "restart," Kafka depends heavily on:

- **Disk Performance**: Devs might not realize how a specific compression codec or a high `min.insync.replicas` count affects I/O.
- **Partition Management**: If Devs create 10,000 partitions for a tiny service, they can kill the controller's performance.
- **Stability**: You, as the SysAdmin, are the one who gets paged at 3:00 AM when the disk is full. You must own the retention policies and resource quotas.

### Why you should NOT "Separate Everything"
If a Developer has to open a Jira ticket and wait three days just to create a topic or update a schema, they will find ways to bypass your "best practices."

### The Hybrid Approach (The Sweet Spot)
- **You (Ops/IaC)**: Build the "vending machine." Use Terraform or a Kubernetes Operator (like Strimzi) to define how a cluster looks.
- **Them (Dev)**: Use the "vending machine." They provide a YAML file or a Pull Request that defines their topic name and partition count. Your CI/CD pipeline checks if their request follows your rules before applying it.

### The Verdict
Do not delegate all. **Delegate the Configuration, but retain the Governance.**

You provide the stable, secure, and monitored "playing field" (The Kafka Cluster). The developers are responsible for the "game" (The Producers, Consumers, and Topics) played within the boundaries you set.

## Project Structure
The project is organized into the following directories:

*   **01-prep**: Contains namespace creation resources (`namespace.yaml`).
*   **02-kafka**: Contains Kafka resources including KRaft configurations (`kafka-kraft.yaml`), UI console (`kafka-ui.yaml`), and topic initialization (`topic-init.yaml`).
*   **03-producer**: Python-based Kafka producer application.
    *   `app.py`: Logic to send JSON messages with timestamps to the Kafka topic.
    *   `Dockerfile`: Build instructions for the producer image.
*   **04-consumer**: Python-based Kafka consumer application.
    *   `app.py`: Logic to subscribe to the topic and print received messages.
    *   `Dockerfile`: Build instructions for the consumer image.
*   `deployments.yaml`: Kubernetes deployment and service definitions for producer and consumer.
*   **scripts**: Helper scripts for verification (`verify.sh`) and cleanup (`cleanup.sh`).
*   **start-lab.ps1**: PowerShell script to deploy the entire lab (Windows).
*   **verify-lab.ps1**: PowerShell script to verify the deployment (Windows).

## Code Review
### Producer (`03-producer/app.py`)
-   Uses `confluent_kafka` library.
-   Connects to Kafka using `KAFKA_BOOTSTRAP_SERVERS` environment variable.
-   Sends a JSON payload containing `id`, `message`, and `timestamp` every 5 seconds.
-   Implements a delivery report callback to confirm message receipt.

### Consumer (`04-consumer/app.py`)
-   Uses `confluent_kafka` library.
-   configured with `auto.offset.reset='earliest'` to read from the beginning.
-   Continuously polls for messages and prints the decoded value to stdout.
-   Handles `_PARTITION_EOF` gracefully.

## Test Results
Verification was performed on the existing deployment.

**Namespace Status:**
`kafka-lab` is Active.

**Pod Status:**
*   Kafka Broker: Running
*   Producer: Running
*   Consumer: Running

**Service Status:**
`kafka-svc` is available on ports 9092/9093. `kafka-ui-svc` is available on port 8080 (30080 NodePort).

**Metrics Status:**
JMX Metrics are enabled on port 9997 and integrated with the UI.

**Log Verification:**
-   **Producer**: Successfully connecting to bootstrap servers and entering the production loop. Logs are visible thanks to `PYTHONUNBUFFERED=1` and `flush=True`.
-   **Consumer**: Successfully polling and receiving JSON messages. Verified end-to-end message flow from producer to consumer.

## Phases
1. **Preparation**: Creating namespace.
2. **Kafka**: Deploying KRaft-mode Kafka.
3. **Producer**: Sending JSON messages.
4. **Consumer**: Receiving and logging messages.
5. **Validation**: kubectl inspection.
6. **Cleanup**: Resource removal.

## Quick Start

### Windows (PowerShell)
```powershell
# Phase 1-4: Start the Lab
.\start-lab.ps1

# Phase 5: Verify
.\verify-lab.ps1
```

### 🌐 Accessing the UI
- **Kafka UI Console**: [http://localhost:30080](http://localhost:30080)

> [!TIP]
> **Troubleshooting UI Access**: If the link above does not work in your browser, it may be due to local Docker Desktop networking constraints. You can use the following command to create a direct tunnel:
> ```powershell
> kubectl port-forward svc/kafka-ui-svc 8080:8080 -n kafka-lab
> ```
> Then access it at [http://localhost:8080](http://localhost:8080).

> [!NOTE]
> **Log Visibility**: To ensure logs are visible in real-time, the Python applications are configured with unbuffered output.

### Linux/Mac (Bash)
```bash
# Phase 1 & 2
kubectl apply -f 01-prep/namespace.yaml
kubectl apply -f 02-kafka/kafka-kraft.yaml
kubectl apply -f 02-kafka/topic-init.yaml

# Phase 3 & 4 (After building images)
docker build -t kafka-producer:latest 03-producer
docker build -t kafka-consumer:latest 04-consumer
kubectl apply -f 04-consumer/deployments.yaml

# Phase 5
bash scripts/verify.sh
```
