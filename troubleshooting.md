# Lab Troubleshooting Guide

## K8s Connection Issues
If `kubectl` fails with "Unable to connect to the server", ensure that:
1. Docker Desktop is running.
2. Kubernetes is enabled in Docker Desktop settings.
3. Your context is set correctly: `kubectl config use-context docker-desktop`.

## Docker Build Failures
If `docker build` fails, ensure the Docker daemon is responding (`docker info`).

## Kafka Pod Issues
If the Kafka pod doesn't start, check its logs:
`kubectl logs -n kafka-lab -l app=kafka`
Common issues:
- Insufficient memory (needs at least 1GB for Docker Desktop).
- Image pull errors (check internet connection).

## Registry Mirror 500 Error
If you see events like `Failed to pull image ... registry-mirror:1273 ... 500 Internal Server Error`, your Kind node is configured with a broken registry mirror.
**Fix**: Use a privileged "Rescue Pod" to patch the node config.
```bash
# Apply scripts/rescue.yaml
kubectl apply -f scripts/rescue.yaml
# Wait for pod ready
kubectl exec -n kube-system rescue-pod -- nsenter -t 1 -m -u -n -i sed -i 's/http:\/\/registry-mirror:1273//g' /etc/containerd/config.toml
kubectl exec -n kube-system rescue-pod -- nsenter -t 1 -m -u -n -i systemctl restart containerd
```

## Bash Script Failures on Windows
**Symptom:** Scripts fail with "No such file or directory" or "command not found".
**Cause:** Windows (CRLF) line endings in `.sh` files.
**Fix:** Convert to LF using `dos2unix` or a text editor.

## PowerShell Command Chaining
**Symptom:** `InvalidEndOfLine` errors.
**Cause:** using `&&` in older PowerShell versions.
**Fix:** Use `;` to separate commands.
