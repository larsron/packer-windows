/*
    DESCRIPTION:
    Windows 10 variables used by Packer.
*/

// Installation Operating System Metadata
vm_inst_os_language = "en-US"
vm_inst_os_keyboard = "en-US"

// Guest Operating System Metadata
vm_guest_os_language = "en-US"
vm_guest_os_keyboard = "en-US"
vm_guest_os_timezone = "UTC"
vm_guest_os_family   = "windows"
vm_guest_os_name     = "windows"
vm_guest_os_version  = "10"

// Parallels Settings
prl_guest_os_type     = "win-10"

// Virtual Machine Hardware Settings
vm_cpus                  = 2
vm_mem_size              = 2048
vm_disk_size             = 20480

// Media Settings
iso_url       = "https://software-download.microsoft.com/download/sg/444969d5-f34g-4e03-ac9d-1f9786c69161/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
iso_checksum  = "69EFAC1DF9EC8066341D8C9B62297DDECE0E6B805533FDB6DD66BC8034FBA27A"

// Boot Settings
vm_boot_wait  = "2s"
vm_boot_command     = ["<spacebar>"]
vm_shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Shutdown by Packer\""

// Communicator Settings
communicator_port    = 5985
communicator_timeout = "30m"

// Vagrant Settings
vagrant_version = "0.0.1"
vagrant_description = "Windows 10 Enterprise"

// Provisioner Settings
scripts = ["scripts/windows-prepare.ps1"]
inline = [
  "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))",
  "choco feature enable -n allowGlobalConfirmation",
  "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }"
]