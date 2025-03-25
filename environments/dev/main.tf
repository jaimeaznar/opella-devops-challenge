provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "opellaterraformstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(var.tags, {
    Environment = "Development"
  })
}

module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "${var.prefix}-vnet"
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags = merge(var.tags, {
    Environment = "Development"
  })
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.prefix}-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["app"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key_content
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = merge(var.tags, {
    Environment = "Development"
  })
}

resource "azurerm_storage_account" "storage" {
  name                     = "devopella${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Allow"
    virtual_network_subnet_ids = [module.vnet.subnet_ids["app"]]
    bypass                     = ["AzureServices"]
  }

  tags = merge(var.tags, {
    Environment = "Development"
  })
}

resource "azurerm_storage_container" "container" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}


################
###Monitoring###
################

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.prefix}-log-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"  
  retention_in_days   = 30
  
  tags = merge(var.tags, {
    Environment = "Development"
  })
}

resource "azurerm_monitor_diagnostic_setting" "vnet_diagnostics" {
  name                       = "${var.prefix}-vnet-diagnostics"
  target_resource_id         = module.vnet.vnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_virtual_machine_extension" "vm_monitoring" {
  name                       = "MMAExtension"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.12"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.workspace.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.workspace.primary_shared_key}"
    }
  PROTECTED_SETTINGS

  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]
}

# Add Azure Monitor Action Group for alerts
resource "azurerm_monitor_action_group" "critical" {
  name                = "${var.prefix}-critical-alerts"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "critical"

  email_receiver {
    name                    = "admins"
    email_address           = "admin@example.com"
    use_common_alert_schema = true
  }
}


resource "azurerm_monitor_metric_alert" "vm_cpu" {
  name                = "${var.prefix}-vm-high-cpu"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine.vm.id]
  description         = "Alert when CPU exceeds 80% for 5 minutes"
  severity            = 2  
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  window_size        = "PT5M"  
  frequency          = "PT1M" 
  
  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
  
  tags = merge(var.tags, {
    Environment = "Development"
  })
}