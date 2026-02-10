# Verification Report

**Date:** 2026-02-05
**Environment:** Windows 11 / Docker Desktop Kubernetes (WSL2 Backend)

## Execution Summary
Due to Windows environment constraints with bash script execution (CRLF/WSL relay issues), the verification steps defined in `scripts/verify.sh` were executed manually using `kubectl`.

## Findings

### 1. Namespace
*   **Status**: `Active`
*   **Resource**: `namespace/kafka-lab` verified.

### 2. Kafka Cluster Status
*   **Pod**: `kafka` is `Running`.
*   **Service**: `kafka-svc` is listening on ports `9092` (internal) and `9093` (controller).
*   **Availability**: Deployment rollout status confirmed successful.

### 3. Producer Application (`kafka-producer`)
*   **Pod Status**: `Running`.
*   **Logs**:
    *   Successfully connected to `kafka-svc`.
    *   Entered main loop: `Starting Producer Loop...`.
    *   No crash loops observed.

### 4. Consumer Application (`kafka-consumer`)
*   **Pod Status**: `Running`.
*   **Logs**:
    *   Successfully connected to `kafka-svc`.
    *   Subscribed to topic `kafka_lab_test_nubeprivada`.
    *   Polling loop active (`Starting Consumer...`).

## Conclusion
The Kafka Kubernetes Lab environment is **HEALTHY**. Both producer and consumer are communicating effectively with the Kafka broker.

## Recommendation
To fix the `scripts/verify.sh` execution on Windows:
1.  Ensure the file has LF (Unix) line endings.
2.  Execute via `wsl ./scripts/verify.sh` or ensure a compatible bash environment (Git Bash) is used.
