package main

import rego.v1

# Kubernetes Policies

# Deny if resources don't have a 'cost-center' label
deny contains msg if {
  input.kind == "Deployment"
  not input.metadata.labels["cost-center"]
  msg := sprintf("Deployment %s must provide a 'cost-center' label", [input.metadata.name])
}

deny contains msg if {
  input.kind == "Service"
  not input.metadata.labels["cost-center"]
  msg := sprintf("Service %s must provide a 'cost-center' label", [input.metadata.name])
}

# Warn if image tag is 'latest'
warn contains msg if {
  input.kind == "Deployment"
  image := input.spec.template.spec.containers[_].image
  endswith(image, ":latest")
  msg := sprintf("Container %s uses 'latest' tag, which is not recommended for production", [input.metadata.name])
}

# Warn if CPU limits are missing
warn contains msg if {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits.cpu
  msg := sprintf("Container %s in Deployment %s should set CPU limits", [container.name, input.metadata.name])
}

# Warn if Memory limits are missing
warn contains msg if {
  input.kind == "Deployment"
  container := input.spec.template.spec.containers[_]
  not container.resources.limits.memory
  msg := sprintf("Container %s in Deployment %s should set Memory limits", [container.name, input.metadata.name])
}
