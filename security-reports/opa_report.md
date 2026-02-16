# OPA Compliance Report

**Date:** 2026-02-16
**Scope:** Kubernetes Manifests and Dockerfiles

## Executive Summary
A compliance scan was performed using Open Policy Agent (OPA) and `conftest`. The scan evaluated Kubernetes deployment manifests and Dockerfiles against a set of security and best-practice policies.

**Results Overview:**
- **Total Checks Run:** ~10
- **Failures (Blocking):** 3
- **Warnings (Non-blocking):** 3

## Detailed Findings

### Kubernetes Manifests (`02-kafka/kafka-kraft.yaml`)

| Status | Resource | Message | Recommendation |
| :--- | :--- | :--- | :--- |
| 🔴 **FAIL** | Deployment `kafka` | `Deployment kafka must provide a 'cost-center' label` | Add `cost-center: <value>` to `metadata.labels`. |
| 🔴 **FAIL** | Service `kafka-svc` | `Service kafka-svc must provide a 'cost-center' label` | Add `cost-center: <value>` to `metadata.labels`. |
| 🟡 **WARN** | Deployment `kafka` | `Container kafka in Deployment kafka should set CPU limits` | Define `resources.limits.cpu`. |
| 🟡 **WARN** | Deployment `kafka` | `Container kafka in Deployment kafka should set Memory limits` | Define `resources.limits.memory`. |

### Dockerfiles

#### Producer (`03-producer/Dockerfile`)
| Status | Message | Recommendation |
| :--- | :--- | :--- |
| 🔴 **FAIL** | `Dockerfile should specify a USER instruction to avoid running as root` | Add `USER nonroot` (or UID) before the entrypoint. |
| 🟡 **WARN** | `Base image 'python:3.9-slim' uses 'latest' tag (implied)` | Pin to a specific digest or version. |

#### Consumer (`04-consumer/Dockerfile`)
| Status | Message | Recommendation |
| :--- | :--- | :--- |
| 🔴 **FAIL** | `Dockerfile should specify a USER instruction to avoid running as root` | Add `USER nonroot` (or UID) before the entrypoint. |
| 🟡 **WARN** | `Base image 'python:3.9-slim' uses 'latest' tag (implied)` | Pin to a specific digest or version. |

## Remediation Plan

To achieve 100% compliance, the following actions are recommended:

1.  **Tagging**: Apply `cost-center` labels to all Kubernetes resources.
2.  **Security**: Update Dockerfiles to create a non-root user and switch to it.
3.  **Reliability**: Ensure all Kubernetes containers have CPU and Memory limits defined.
4.  **Stability**: Use specific image digests in Dockerfiles to ensure reproducibility.
