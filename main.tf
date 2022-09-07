resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name                = "Tf_vnet_g4"
  address_space       = ["10.0.0.0/21"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "myterraformnetworkBastion" {
  name                = "${var.prefix}bastion"
  address_space       = ["10.0.4.0/24"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# create subnet 1
resource "azurerm_subnet" "myterraformbastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetworkBastion.name
  address_prefixes     = ["10.0.4.0/24"]
}

# create subnet 2
resource "azurerm_subnet" "myterraformsubnepterodactil" {
  name                 = "${var.prefix}_subnet_wings"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  address_prefixes     = ["10.0.6.0/24"]
}
# create public ip 1
resource "azurerm_public_ip" "mypublicip" {
  name                 = "${var.prefix}_public_ip1"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  allocation_method    = "Static"
}
# create public ip 2
resource "azurerm_public_ip" "mypublicip2" {
  name                 = "${var.prefix}_public_ip2"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  allocation_method    = "Static"
  sku                  = "Standard"
}
# create public ip 3
resource "azurerm_public_ip" "mypublicip3" {
  name                 = "${var.prefix}_public_ip3"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  allocation_method    = "Static"
  sku                  = "Standard"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformsecuritygroup" {
  name                = "${var.prefix}_security_group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface public
resource "azurerm_network_interface" "myterraformnetworkinterface" {
  name                = "${var.prefix}_network_interface1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config1"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublicip.id
  }
}

#privé
resource "azurerm_network_interface" "myterraformnetworkinterfaceWingsP1" {
  name                = "${var.prefix}_network_interface2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config2"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
  }
}
#privé
resource "azurerm_network_interface" "myterraformnetworkinterfaceWingsP2" {
  name                = "${var.prefix}_network_interface3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config3"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
  }
}
#privé
resource "azurerm_network_interface" "myterraformnetworkinterfaceWingsP3" {
  name                = "${var.prefix}_network_interface4"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}_ip_config4"
    subnet_id                     = azurerm_subnet.myterraformsubnepterodactil.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "terraformconnect" {
  network_interface_id      = azurerm_network_interface.myterraformnetworkinterface.id
  network_security_group_id = azurerm_network_security_group.myterraformsecuritygroup.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvmpanel" {
  name                  = "${var.prefix}_vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnetworkinterface.id, azurerm_network_interface.myterraformnetworkinterfaceWingsP1.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk2"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = "123456Azerty$."
}

resource "azurerm_linux_virtual_machine" "myterraformwings" {
  name                  = "${var.prefix}_wings"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnetworkinterfaceWingsP2.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "wingsuser"
  disable_password_authentication = false
  admin_password                  = "123456ytreza$."
}

# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "redis_azure" {
  name                = "${var.prefix}redis"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}
#mariadb
resource "azurerm_mariadb_server" "mariadbterraform" {
  name                = "${var.prefix}mariadb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  administrator_login          = "mariadbadmin"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "10.2"

  auto_grow_enabled             = true
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true
  ssl_enforcement_enabled       = true
}

resource "azurerm_lb" "load-balance" {
  name                = "${var.prefix}_load-blance"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.prefix}ip_public2"
    public_ip_address_id = azurerm_public_ip.mypublicip2.id
  }
}


resource "azurerm_lb_backend_address_pool" "backendpoolpanel" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.load-balance.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_backend_address_pool_address" "backendpollAdresse" {
  name                    = "example"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpoolpanel.id
  virtual_network_id      = azurerm_virtual_network.myterraformnetwork.id
  ip_address              = azurerm_network_interface.myterraformnetworkinterfaceWingsP3.private_ip_address
}

resource "azurerm_lb_outbound_rule" "outbound_rule_panel" {
  name                    = "${var.prefix}OutboundRule"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id         = azurerm_lb.load-balance.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backendpoolpanel.id

  frontend_ip_configuration {
    name = "${var.prefix}ip_public2"
  }
}


resource "azurerm_recovery_services_vault" "myvault" {
  name                = "${var.prefix}vault"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
}

# resource "azurerm_backup_policy_vm" "vault_policy" {
#   name                = "${var.prefix}vaultpolicy"
#   resource_group_name = azurerm_resource_group.rg.name
#   recovery_vault_name = azurerm_recovery_services_vault.myvault.name

#   timezone = "UTC"

#   backup {
#     frequency = "Daily"
#     time      = "23:00"
#   }

#   retention_daily {
#     count = 1
#   }

#   retention_weekly {
#     count    = 1
#     weekdays = ["Sunday"]
#   }

#   retention_monthly {
#     count    = 4
#     weekdays = ["Sunday", "Wednesday"]
#     weeks    = ["First", "Last"]
#   }

#   retention_yearly {
#     count    = 1
#     weekdays = ["Sunday"]
#     weeks    = ["Last"]
#     months   = ["January"]
#   }
# }


# resource "azurerm_bastion_host" "mybastion" {
#   name                = "${var.prefix}_bastion"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = azurerm_subnet.myterraformbastionsubnet.id
#     public_ip_address_id = azurerm_public_ip.mypublicip3.id
#   }
# }