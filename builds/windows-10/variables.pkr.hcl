/*
    DESCRIPTION:
    Fedora 35 variables using the Packer Builder.
*/

//  BLOCK: variable
//  Defines the input variables.

// Installer Settings

variable "vm_inst_os_language" {
  type        = string
  description = "The installation operating system lanugage."
  default     = "en-GB"
}

variable "vm_inst_os_keyboard" {
  type        = string
  description = "The installation operating system keyboard input."
  default     = "en-GB"
}

// Virtual Machine Settings

variable "vm_guest_os_language" {
  type        = string
  description = "The guest operating system lanugage."
  default     = "en_US"
}

variable "vm_guest_os_keyboard" {
  type        = string
  description = "The guest operating system keyboard input."
  default     = "us"
}

variable "vm_guest_os_timezone" {
  type        = string
  description = "The guest operating system timezone."
  default     = "UTC"
}

variable "vm_guest_os_family" {
  type        = string
  description = "The guest operating system family. Used for naming and VMware tools. (e.g.'windows')"
}

variable "vm_guest_os_name" {
  type        = string
  description = "The guest operating system family. Used for naming. (e.g.'fedora')"
}

variable "vm_guest_os_version" {
  type        = string
  description = "The guest operating system version. Used for naming. (e.g. '35')"
}

variable "vm_cpus" {
  type        = number
  description = "The number of virtual CPUs. (e.g. '1')"
}

variable "vm_mem_size" {
  type        = number
  description = "The size for the virtual memory in MB. (e.g. '2048')"
}

variable "vm_disk_size" {
  type        = number
  description = "The size for the virtual disk in MB. (e.g. '40960')"
}

// Parallels Settings

variable "prl_guest_os_type" {
  type        = string
  description = "The guest operating system type, also know as guestid. (e.g. 'fedora-core')"
}

variable "prl_skip_compaction" {
  type        = bool
  description = "Set to skip compacting the virtual disk image."
  default     = false
}

variable "prl_parallels_tools_mode" {
  type        = string
  description = "The method by which Parallels Tools are made available to the guest for installation."
  default     = "disable"
}

variable "prl_parallels_prlctl" {
  type        = list(list(string))
  description = "Parallels extra customization of the virtual machine."
  default     = [[]]
}

// QEMU Settings

variable "qemu_machine_type" {
  type        = string
  description = "The type of machine emulation to use."
}

variable "qemu_format" {
  type        = string
  description = "The output format of the virtual machine image."
}

variable "qemu_accelerator" {
  type        = string
  description = "The accelerator type to use when running the VM."
}

variable "qemu_net_device" {
  type        = string
  description = "The driver to use for the network interface."
}

variable "qemu_disk_interface" {
  type        = string
  description = "The interface to use for the disk."
}

variable "qemu_disk_cache" {
  type        = string
  description = "The cache mode to use for disk."
}

variable "qemu_disk_discard" {
  type        = string
  description = "The discard mode to use for disk."
}

variable "qemu_headless" {
  type        = bool
  description = "If the GUI of the guest will show during the build."
  default     = false
}

variable "virtio_win_iso" {
  type        = string
  description = "The location of the VirtIO iso image."
}

// Media Settings

variable "iso_url" {
  type        = string
  description = "A URL to the ISO containing the installation image."
}

variable "iso_checksum" {
  type        = string
  description = "The checksum for the ISO file or virtual hard drive file."
}

// Boot Settings

variable "common_data_source" {
  type        = string
  description = "The provisioning data source ('http' or 'disk')."
}

variable "common_http_ip" {
  type        = string
  description = "Define an IP address on the host to use for the HTTP server."
  default     = null
}

variable "common_http_port_min" {
  type        = number
  description = "The start of the HTTP port range."
}

variable "common_http_port_max" {
  type        = number
  description = "The end of the HTTP port range."
}

variable "vm_boot_wait" {
  type        = string
  description = "The time to wait before boot."
}

variable "vm_boot_command" {
  type        = list(string)
  description = "The virtual machine boot command."
  default     = []
}

variable "vm_shutdown_command" {
  type        = string
  description = "Command(s) for guest operating system shutdown."
}

variable "common_ip_wait_timeout" {
  type        = string
  description = "Time to wait for guest operating system IP address response."
}

variable "common_shutdown_timeout" {
  type        = string
  description = "Time to wait for guest operating system shutdown."
}

// Communicator Settings and Credentials

variable "build_username" {
  type        = string
  description = "The username to login to the guest operating system. (e.g. vagrant)"
  sensitive   = true
}

variable "build_password" {
  type        = string
  description = "The password to login to the guest operating system."
  sensitive   = true
}

variable "build_password_encrypted" {
  type        = string
  description = "The encrypted password to login to the guest operating system."
  sensitive   = true
}

variable "build_key" {
  type        = string
  description = "The public key to login to the guest operating system."
  sensitive   = true
}

// Communicator Credentials

variable "communicator_port" {
  type        = string
  description = "The port for the communicator protocol."
}

variable "communicator_timeout" {
  type        = string
  description = "The timeout for the communicator protocol."
}

// Vagrant Settings

variable "vagrant_version" {
  type        = string
  description = "The version of the Vagrant box."
  default     = "0.0.1"
}

variable "vagrant_description" {
  type        = string
  description = "The description of the Vagrant box."
}

// Provisioner Settings

variable "scripts" {
  type        = list(string)
  description = "A list of scripts and their relative paths to transfer and execute."
  default     = []
}

variable "inline" {
  type        = list(string)
  description = "A list of commands to execute."
  default     = []
}
