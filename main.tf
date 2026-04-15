# Phase 16: VM Cloning via Snapshots
# Clone 5 NGINX proxy VMs from existing to new DMZ subnets
# Process: Source VM → Snapshot → Managed Disk → New VM

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.primary_subscription_id
}

# ============================================================================
# DATA SOURCES - Existing Infrastructure
# ============================================================================

data "azurerm_resource_group" "ne_new" {
  name = var.source_vms[0].new_rg
}

data "azurerm_resource_group" "we_new" {
  name = var.source_vms[2].new_rg
}

data "azurerm_virtual_network" "ne_cidmz_vnet" {
  name                = var.source_vms[0].new_vnet
  resource_group_name = data.azurerm_resource_group.ne_new.name
}

data "azurerm_virtual_network" "we_cidmz_vnet" {
  name                = var.source_vms[2].new_vnet
  resource_group_name = data.azurerm_resource_group.we_new.name
}

data "azurerm_subnet" "ne_proxy_snet" {
  name                 = var.source_vms[0].new_subnet
  virtual_network_name = data.azurerm_virtual_network.ne_cidmz_vnet.name
  resource_group_name  = data.azurerm_resource_group.ne_new.name
}

data "azurerm_subnet" "we_proxy_snet" {
  name                 = var.source_vms[2].new_subnet
  virtual_network_name = data.azurerm_virtual_network.we_cidmz_vnet.name
  resource_group_name  = data.azurerm_resource_group.we_new.name
}

data "azurerm_managed_disk" "source_ne_54_os_disk" {
  name                = "SI-RPRXY-VM-54_OsDisk_1_aacc69b095984334fbfb62fccbc93d53f"
  resource_group_name = var.source_vms[0].old_rg
}

data "azurerm_managed_disk" "source_ne_55_os_disk" {
  name                = "SI-RPRXY-VM-55_OsDisk_1_1d5ffd117f2b47038171e6ae9aaef313"
  resource_group_name = var.source_vms[1].old_rg
}

data "azurerm_managed_disk" "source_we_05_os_disk" {
  name                = "SI-RPRXY-VM-05_OsDisk_1_d3e582c88e0c4f84a46d8f3cb4b90491"
  resource_group_name = var.source_vms[2].old_rg
}

data "azurerm_managed_disk" "source_we_06_os_disk" {
  name                = "SI-RPRXY-VM-06_OsDisk_1_99f2dee505ad431db2a7a5e2c7323dc6"
  resource_group_name = var.source_vms[3].old_rg
}

data "azurerm_managed_disk" "source_we_04_os_disk" {
  name                = "SI-RPRXY-VM-04_OsDisk_1_dd8d967711b642edb7eac923093afb85"
  resource_group_name = var.source_vms[4].old_rg
}

# ============================================================================
# AVAILABILITY SETS
# ============================================================================

resource "azurerm_availability_set" "ne_avset" {
  name                = "si-rprxy-dmz-ne-52-as"
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name
  
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags = {
    Region  = "North Europe"
    Purpose = "NGINX Proxy DMZ HA"
  }
}

resource "azurerm_availability_set" "we_avset" {
  name                = "si-rprxy-dmz-we-02-as"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags = {
    Region  = "West Europe"
    Purpose = "NGINX Proxy DMZ HA"
  }
}

# ============================================================================
# SNAPSHOTS - OS Disk Snapshots
# ============================================================================

resource "azurerm_snapshot" "source_ne_54_os_snapshot" {
  name                = "${var.source_vms[0].existing_name}-OS-SNAP"
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name
  source_resource_id  = data.azurerm_managed_disk.source_ne_54_os_disk.id
  create_option       = "Copy"

  tags = {
    Source  = var.source_vms[0].existing_name
    Purpose = "VM Clone"
  }
}

resource "azurerm_snapshot" "source_ne_55_os_snapshot" {
  name                = "${var.source_vms[1].existing_name}-OS-SNAP"
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name
  source_resource_id  = data.azurerm_managed_disk.source_ne_55_os_disk.id
  create_option       = "Copy"

  tags = {
    Source  = var.source_vms[1].existing_name
    Purpose = "VM Clone"
  }
}

resource "azurerm_snapshot" "source_we_05_os_snapshot" {
  name                = "${var.source_vms[2].existing_name}-OS-SNAP"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  source_resource_id  = data.azurerm_managed_disk.source_we_05_os_disk.id
  create_option       = "Copy"

  tags = {
    Source  = var.source_vms[2].existing_name
    Purpose = "VM Clone"
  }
}

resource "azurerm_snapshot" "source_we_06_os_snapshot" {
  name                = "${var.source_vms[3].existing_name}-OS-SNAP"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  source_resource_id  = data.azurerm_managed_disk.source_we_06_os_disk.id
  create_option       = "Copy"

  tags = {
    Source  = var.source_vms[3].existing_name
    Purpose = "VM Clone"
  }
}

resource "azurerm_snapshot" "source_we_04_os_snapshot" {
  name                = "${var.source_vms[4].existing_name}-OS-SNAP"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  source_resource_id  = data.azurerm_managed_disk.source_we_04_os_disk.id
  create_option       = "Copy"

  tags = {
    Source  = var.source_vms[4].existing_name
    Purpose = "VM Clone"
  }
}

# ============================================================================
# MANAGED DISKS - Created from Snapshots
# ============================================================================

resource "azurerm_managed_disk" "clone_ne_54_os_disk" {
  name                = "${var.source_vms[0].new_name}-OsDisk"
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name
  
  storage_account_type = var.source_vms[0].os_disk_type
  create_option        = "Copy"
  source_resource_id   = azurerm_snapshot.source_ne_54_os_snapshot.id

  tags = {
    VM      = var.source_vms[0].new_name
    Purpose = "OS Disk Clone"
  }
}

resource "azurerm_managed_disk" "clone_ne_55_os_disk" {
  name                = "${var.source_vms[1].new_name}-OsDisk"
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name
  
  storage_account_type = var.source_vms[1].os_disk_type
  create_option        = "Copy"
  source_resource_id   = azurerm_snapshot.source_ne_55_os_snapshot.id

  tags = {
    VM      = var.source_vms[1].new_name
    Purpose = "OS Disk Clone"
  }
}

resource "azurerm_managed_disk" "clone_we_05_os_disk" {
  name                = "${var.source_vms[2].new_name}-OsDisk"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  
  storage_account_type = var.source_vms[2].os_disk_type
  create_option        = "Copy"
  source_resource_id   = azurerm_snapshot.source_we_05_os_snapshot.id

  tags = {
    VM      = var.source_vms[2].new_name
    Purpose = "OS Disk Clone"
  }
}

resource "azurerm_managed_disk" "clone_we_06_os_disk" {
  name                = "${var.source_vms[3].new_name}-OsDisk"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  
  storage_account_type = var.source_vms[3].os_disk_type
  create_option        = "Copy"
  source_resource_id   = azurerm_snapshot.source_we_06_os_snapshot.id

  tags = {
    VM      = var.source_vms[3].new_name
    Purpose = "OS Disk Clone"
  }
}

resource "azurerm_managed_disk" "clone_we_04_os_disk" {
  name                = "${var.source_vms[4].new_name}-OsDisk"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  
  storage_account_type = var.source_vms[4].os_disk_type
  create_option        = "Copy"
  source_resource_id   = azurerm_snapshot.source_we_04_os_snapshot.id

  tags = {
    VM      = var.source_vms[4].new_name
    Purpose = "OS Disk Clone"
  }
}

# ============================================================================
# NETWORK INTERFACES
# ============================================================================

resource "azurerm_network_interface" "clone_ne_54_nic" {
  name                = "${var.source_vms[0].new_name}-nic"
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.ne_proxy_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.source_vms[0].new_private_ip
  }
}

resource "azurerm_network_interface" "clone_ne_55_nic" {
  name                = "${var.source_vms[1].new_name}-nic"
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.ne_proxy_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.source_vms[1].new_private_ip
  }
}

resource "azurerm_network_interface" "clone_we_05_nic" {
  name                = "${var.source_vms[2].new_name}-nic"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.we_proxy_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.source_vms[2].new_private_ip
  }
}

resource "azurerm_network_interface" "clone_we_06_nic" {
  name                = "${var.source_vms[3].new_name}-nic"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.we_proxy_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.source_vms[3].new_private_ip
  }
}

resource "azurerm_network_interface" "clone_we_04_nic" {
  name                = "${var.source_vms[4].new_name}-nic"
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.we_proxy_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.source_vms[4].new_private_ip
  }
}

# ============================================================================
# VIRTUAL MACHINES
# ============================================================================

resource "azurerm_virtual_machine" "clone_ne_54" {
  name                = var.source_vms[0].new_name
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name
  vm_size             = var.source_vms[0].vm_size
  availability_set_id = azurerm_availability_set.ne_avset.id

  network_interface_ids = [
    azurerm_network_interface.clone_ne_54_nic.id,
  ]

  os_profile {
    computer_name  = var.source_vms[0].new_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name                = "${var.source_vms[0].new_name}-OsDisk"
    managed_disk_id     = azurerm_managed_disk.clone_ne_54_os_disk.id
    caching             = "ReadWrite"
    create_option       = "Attach"
    os_type             = "Linux"
  }

  tags = {
    Environment = var.source_vms[0].is_prod ? "Production" : "Non-Production"
  }
}

resource "azurerm_virtual_machine" "clone_ne_55" {
  name                = var.source_vms[1].new_name
  location            = data.azurerm_resource_group.ne_new.location
  resource_group_name = data.azurerm_resource_group.ne_new.name
  vm_size             = var.source_vms[1].vm_size
  availability_set_id = azurerm_availability_set.ne_avset.id

  network_interface_ids = [
    azurerm_network_interface.clone_ne_55_nic.id,
  ]

  os_profile {
    computer_name  = var.source_vms[1].new_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name                = "${var.source_vms[1].new_name}-OsDisk"
    managed_disk_id     = azurerm_managed_disk.clone_ne_55_os_disk.id
    caching             = "ReadWrite"
    create_option       = "Attach"
    os_type             = "Linux"
  }

  tags = {
    Environment = var.source_vms[1].is_prod ? "Production" : "Non-Production"
  }
}

resource "azurerm_virtual_machine" "clone_we_05" {
  name                = var.source_vms[2].new_name
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  vm_size             = var.source_vms[2].vm_size
  availability_set_id = azurerm_availability_set.we_avset.id

  network_interface_ids = [
    azurerm_network_interface.clone_we_05_nic.id,
  ]

  os_profile {
    computer_name  = var.source_vms[2].new_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name                = "${var.source_vms[2].new_name}-OsDisk"
    managed_disk_id     = azurerm_managed_disk.clone_we_05_os_disk.id
    caching             = "ReadWrite"
    create_option       = "Attach"
    os_type             = "Linux"
  }

  tags = {
    Environment = var.source_vms[2].is_prod ? "Production" : "Non-Production"
  }
}

resource "azurerm_virtual_machine" "clone_we_06" {
  name                = var.source_vms[3].new_name
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  vm_size             = var.source_vms[3].vm_size
  availability_set_id = azurerm_availability_set.we_avset.id

  network_interface_ids = [
    azurerm_network_interface.clone_we_06_nic.id,
  ]

  os_profile {
    computer_name  = var.source_vms[3].new_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name                = "${var.source_vms[3].new_name}-OsDisk"
    managed_disk_id     = azurerm_managed_disk.clone_we_06_os_disk.id
    caching             = "ReadWrite"
    create_option       = "Attach"
    os_type             = "Linux"
  }

  tags = {
    Environment = var.source_vms[3].is_prod ? "Production" : "Non-Production"
  }
}

resource "azurerm_virtual_machine" "clone_we_04" {
  name                = var.source_vms[4].new_name
  location            = data.azurerm_resource_group.we_new.location
  resource_group_name = data.azurerm_resource_group.we_new.name
  vm_size             = var.source_vms[4].vm_size

  network_interface_ids = [
    azurerm_network_interface.clone_we_04_nic.id,
  ]

  os_profile {
    computer_name  = var.source_vms[4].new_name
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_os_disk {
    name                = "${var.source_vms[4].new_name}-OsDisk"
    managed_disk_id     = azurerm_managed_disk.clone_we_04_os_disk.id
    caching             = "ReadWrite"
    create_option       = "Attach"
    os_type             = "Linux"
  }

  tags = {
    Environment = var.source_vms[4].is_prod ? "Production" : "Non-Production"
  }
}
