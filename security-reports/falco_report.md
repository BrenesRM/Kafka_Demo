# Falco Implementation Report

**Status:** Manifests Created / Deployment Blocked
**Reason:** Environment Limitation (Missing eBPF/Kernel Headers)

## Overview
Falco was configured to monitor the Kubernetes cluster for runtime security events, specifically looking for:
- Shell execution inside containers.
- Unexpected system calls.

## Deployment Attempts
We attempted the following driver configurations:
1.  **`modern_bpf`**: The modern eBPF probe. Failed because the underlying VM kernel likely does not support BTF or is too old.
2.  **`init` (Kernel Module)**: Failed because kernel headers matching the running kernel were not found in the VM.
3.  **`none` (No Driver)**: Falco started but crashed because the default ruleset depends on system call events, which are unavailable without a driver.

## Conclusion
The current environment (Docker Desktop/Windows WSL2 backend) often lacks the necessary kernel features for runtime syscall instrumentation. 

## Next Steps
To enable Falco:
1.  **Use a Full VM**: Run the cluster in a standard Linux VM.
2.  **Cloud K8s**: Deploy the provided manifests (`06-falco/`) to a cloud provider's Kubernetes engine.
3.  **K8s Audit Only**: Reconfigure Falco to *only* listen to Kubernetes Audit Logs (requires API server reconfiguration), bypassing the need for kernel drivers.
