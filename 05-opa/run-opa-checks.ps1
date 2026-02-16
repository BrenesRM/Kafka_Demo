# Run OPA checks using Conftest via Docker
# This script mounts the current project directory and checks files against the policies in 05-opa/

$currentDir = Get-Location
$policyPathK8s = "05-opa/policy-k8s.rego"
$policyPathDocker = "05-opa/policy-docker.rego"

Write-Host "Running OPA checks on Kubernetes manifests..." -ForegroundColor Cyan
docker run --rm -v ${currentDir}:/project -w /project openpolicyagent/conftest test 02-kafka/*.yaml -p $policyPathK8s

Write-Host "`nRunning OPA checks on Producer Dockerfile..." -ForegroundColor Cyan
docker run --rm -v ${currentDir}:/project -w /project openpolicyagent/conftest test 03-producer/Dockerfile -p $policyPathDocker --parser dockerfile

Write-Host "`nRunning OPA checks on Consumer Dockerfile..." -ForegroundColor Cyan
docker run --rm -v ${currentDir}:/project -w /project openpolicyagent/conftest test 04-consumer/Dockerfile -p $policyPathDocker --parser dockerfile
