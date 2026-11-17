packer {
  required_version = ">= 1.14.0, < 2.0.0"

  required_plugins {
    tart = {
      source  = "github.com/cirruslabs/tart"
      version = "= 1.21.0"
    }
  }
}

variable "vm_name" {
  type    = string
  default = "macos-agent"
}

variable "base_image" {
  type    = string
  default = "ghcr.io/cirruslabs/macos-tahoe-vanilla:latest"
}

variable "base_ssh_password" {
  type      = string
  sensitive = true
}

variable "agent_password" {
  type      = string
  sensitive = true
}

variable "dotfiles_profile" {
  type = string

  validation {
    condition     = contains(["work", "personal"], var.dotfiles_profile)
    error_message = "Choose dotfiles_profile work or personal."
  }
}

variable "dotfiles_category" {
  type = string

  validation {
    condition     = contains(["headless", "desktop"], var.dotfiles_category)
    error_message = "Choose dotfiles_category headless or desktop."
  }
}

variable "dotfiles_ref" {
  type    = string
  default = "main"
}

source "tart-cli" "macos" {
  vm_base_name = var.base_image
  vm_name      = var.vm_name
  cpu_count    = 4
  memory_gb    = 8
  headless     = true
  ssh_username = "admin"
  ssh_password = var.base_ssh_password
  ssh_timeout  = "5m"
}

build {
  sources = ["source.tart-cli.macos"]

  provisioner "shell" {
    script = "${path.root}/../../scripts/vm-bootstrap-homebrew.sh"
  }

  provisioner "shell" {
    script           = "${path.root}/../../scripts/vm-provision-dotfiles.sh"
    use_env_var_file = true
    environment_vars = [
      "DOTFILES_PROFILE=${var.dotfiles_profile}",
      "DOTFILES_CATEGORY=${var.dotfiles_category}",
      "DOTFILES_REF=${var.dotfiles_ref}",
    ]
  }

  provisioner "shell" {
    script            = "${path.root}/../../scripts/vm-configure-accounts.sh"
    use_env_var_file  = true
    expect_disconnect = true
    skip_clean        = true
    environment_vars = [
      "BASE_PASSWORD_BASE64=${base64encode(var.base_ssh_password)}",
      "AGENT_PASSWORD_BASE64=${base64encode(var.agent_password)}",
    ]
    execute_command = "chmod 600 '{{.EnvVarFile}}'; sudo -n /bin/bash -c '. \"$1\" && rm -f \"$1\" && exec /bin/bash \"$2\"' -- '{{.EnvVarFile}}' '{{.Path}}'"
  }
}
