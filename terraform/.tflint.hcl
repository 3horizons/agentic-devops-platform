# TFLint configuration for Three Horizons Accelerator

config {
  force = false
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Disable unused declarations check - variables are for future use
rule "terraform_unused_declarations" {
  enabled = false
}
