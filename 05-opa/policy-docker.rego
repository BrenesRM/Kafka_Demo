package main

import rego.v1

# Dockerfile Policies

# Deny if USER instruction is missing (running as root)
deny contains msg if {
  input[i].Cmd == "from"
  not has_user_instruction
  msg := "Dockerfile should specify a USER instruction to avoid running as root"
}

has_user_instruction if {
  input[_].Cmd == "user"
}

# Warn if base image is 'latest'
warn contains msg if {
  input[i].Cmd == "from"
  val := input[i].Value
  image := val[0]
  endswith(image, ":latest")
  msg := sprintf("Base image '%s' uses 'latest' tag", [image])
}

warn contains msg if {
  input[i].Cmd == "from"
  val := input[i].Value
  image := val[0]
  not contains(image, ":")
  msg := sprintf("Base image '%s' uses 'latest' tag (implied)", [image])
}
