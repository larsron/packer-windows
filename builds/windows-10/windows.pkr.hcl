/*
    DESCRIPTION:
    Windows 10 template using the Packer Builder.
*/

//  BLOCK: packer
//  The Packer configuration.

packer {
  required_version = ">= 1.7.4"
  required_plugins {
    parallels = {
      version = ">= v1.0.0"
      source  = "github.com/hashicorp/parallels"
    }
    qemu = {
      version = ">= v1.0.1"
      source  = "github.com/hashicorp/qemu"
    }
    windows-update = {
      version = ">= 0.14.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "VAGRANT_BOX_PATH" {
  type = string
}

variable "VAGRANT_PROVIDER" {
  type = string
}

//  BLOCK: locals
//  Defines the local variables.

locals {
  buildtime        = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  manifest_date    = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  manifest_path    = "${path.cwd}/manifests/"
}

//  BLOCK: source
//  Defines the builder configuration blocks.

source "parallels-iso" "windows-10-enterprise" {

  // Virtual Machine Settings
  guest_os_type        = var.prl_guest_os_type
  vm_name              = "${var.vm_guest_os_name}-${var.vm_guest_os_version}"
  cpus                 = var.vm_cpus
  memory               = var.vm_mem_size
  disk_size            = var.vm_disk_size
  skip_compaction      = var.prl_skip_compaction
  parallels_tools_mode = var.prl_parallels_tools_mode

  // Media Settings
  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum
  http_content = var.common_data_source == "http" ? local.data_source_content : null

  // Boot and Provisioning Settings
  http_port_min = var.common_data_source == "http" ? var.common_http_port_min : null
  http_port_max = var.common_data_source == "http" ? var.common_http_port_max : null
  boot_wait     = var.vm_boot_wait
  boot_command = [
    "<up><wait><tab> inst.text ",
    "${local.data_source_command}",
    "<enter>"
  ]
  shutdown_command = "echo '${var.build_password}' | sudo -S -E shutdown -P now"
  shutdown_timeout = var.common_shutdown_timeout

  // Communicator Settings and Credentials
  ssh_username       = var.build_username
  ssh_password       = var.build_password
  ssh_timeout        = var.communicator_timeout
}

source "qemu" "windows-10-enterprise" {

  // Virtual Machine Settings
  vm_name              = "${var.vm_guest_os_name}-${var.vm_guest_os_version}"
  cpus                 = var.vm_cpus
  memory               = var.vm_mem_size
  disk_size            = var.vm_disk_size
  machine_type         = var.qemu_machine_type
  format               = var.qemu_format
  accelerator          = var.qemu_accelerator
  disk_interface       = var.qemu_disk_interface
  disk_cache           = var.qemu_disk_cache
  disk_discard         = var.qemu_disk_discard
  net_device           = var.qemu_net_device
  headless             = var.qemu_headless

  qemuargs = [
    ["-cpu", "host"],
    ["-device", "ich9-intel-hda"],
    ["-device", "hda-duplex"],
    ["-device", "qemu-xhci"],
    ["-device", "usb-tablet"],
    ["-vga", "qxl"],
    ["-device", "virtio-serial-pci"],
    ["-chardev", "socket,path=/tmp/{{ .Name }}-qga.sock,server=on,wait=off,id=qga0"],
    ["-device", "virtserialport,chardev=qga0,name=org.qemu.guest_agent.0"],
    ["-chardev", "spicevmc,id=spicechannel0,name=vdagent"],
    ["-device", "virtserialport,chardev=spicechannel0,name=com.redhat.spice.0"],
    ["-spice", "unix=on,addr=/tmp/{{ .Name }}-spice.socket,disable-ticketing=on"],
  ]

  // Media Settings
  floppy_files = [
    "drivers/vioserial/w10/amd64/*.cat",
    "drivers/vioserial/w10/amd64/*.inf",
    "drivers/vioserial/w10/amd64/*.sys",
    "drivers/viostor/w10/amd64/*.cat",
    "drivers/viostor/w10/amd64/*.inf",
    "drivers/viostor/w10/amd64/*.sys",
    "drivers/vioscsi/w10/amd64/*.cat",
    "drivers/vioscsi/w10/amd64/*.inf",
    "drivers/vioscsi/w10/amd64/*.sys",
    "drivers/NetKVM/w10/amd64/*.cat",
    "drivers/NetKVM/w10/amd64/*.inf",
    "drivers/NetKVM/w10/amd64/*.sys",
    "drivers/qxldod/w10/amd64/*.cat",
    "drivers/qxldod/w10/amd64/*.inf",
    "drivers/qxldod/w10/amd64/*.sys",
    "drivers/Balloon/w10/amd64/*.cat",
    "drivers/Balloon/w10/amd64/*.inf",
    "drivers/Balloon/w10/amd64/*.sys",
  ]

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum
  cd_files = [
    "${path.cwd}/scripts/"
  ]
  cd_content = {
    "autounattend.xml" = templatefile("${abspath(path.root)}/data/autounattend.pkrtpl.hcl", {
      os_image             = "Windows 10 Enterprise Evaluation"
      build_username       = var.build_username
      build_password       = var.build_password
      vm_inst_os_language  = var.vm_inst_os_language
      vm_inst_os_keyboard  = var.vm_inst_os_keyboard
      vm_guest_os_language = var.vm_guest_os_language
      vm_guest_os_keyboard = var.vm_guest_os_keyboard
      vm_guest_os_timezone = var.vm_guest_os_timezone
    })
  }

  // Boot and Provisioning Settings
  http_port_min    = var.common_http_port_min
  http_port_max    = var.common_http_port_max
  boot_wait        = var.vm_boot_wait
  boot_command     = var.vm_boot_command

  // Communicator Settings and Credentials
  communicator   = "winrm"
  winrm_username = var.build_username
  winrm_password = var.build_password
  winrm_port     = var.communicator_port
  winrm_timeout  = var.communicator_timeout
}

//  BLOCK: build
//  Defines the builders to run, provisioners, and post-processors.

build {
  sources = [
    "source.parallels-iso.windows-10-enterprise",
    "source.qemu.windows-10-enterprise",
  ]

  provisioner "powershell" {
    environment_vars = [
      "BUILD_USERNAME=${var.build_username}"
    ]
    elevated_user     = var.build_username
    elevated_password = var.build_password
    scripts           = formatlist("${path.cwd}/%s", var.scripts)
  }

  provisioner "powershell" {
    elevated_user     = var.build_username
    elevated_password = var.build_password
    inline            = var.inline
  }

  provisioner "windows-update" {
    pause_before    = "30s"
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "exclude:$_.Title -like '*Defender*'",
      "exclude:$_.InstallationBehavior.CanRequestUserInput",
      "include:$true"
    ]
    restart_timeout = "120m"
  }

  provisioner "powershell" {
    script = "${path.cwd}/scripts/windows-cleanup.ps1"
  }

  post-processor "vagrant" {
    output = "${var.VAGRANT_BOX_PATH}/${source.name}.box"
  }

  post-processor "shell-local" {
    inline = [
      "./mkmetadata.sh \"${var.VAGRANT_BOX_PATH}\" \"${source.name}\" \"${var.vagrant_description}\" \"${var.vagrant_version}\" \"${var.VAGRANT_PROVIDER}\"",
      "vagrant box add ${var.VAGRANT_BOX_PATH}/${source.name}.metadata.json",
      "rm -rf output-${source.name}"
    ]
  }
}