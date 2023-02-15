provider "azurerm" {
  subscription_id = "4098b2f4-823e-448e-b467-aa36d4d9ca14"
  tenant_id       = "05d05b1-7db3-4dfe-8822-8e71c1898bf6"
  features {}
}

resource "azurerm_resource_group" "infosecrg" {
  name     = "rg-uks-it-sser-infosec-01"
  location = "UK South"
  tags = {
    Account         = "IT & Change"
    Application     = "QualysInfoSec-Common"
    BillingApprover = "Gareth.Sumpter@tpr.gov.uk"
    BusinessSegment = "IT"
    pipeline_name    = "Manual"
    repository_name  = "Manual"
    Terraformed     = "true"
    Department      = "Corporate Services" 
    CostCentre      = "BAU"
    Environment     = "Production"
    Creator         = "Infrastructure Team"
    Project         = "infosec"
    SupportGroup    = "Infrastructure Team"
  }
}

resource "azurerm_windows_virtual_machine" "vm1" {
  name                = "vmsserinfosec01"
  resource_group_name = azurerm_resource_group.infosecrg.name
  location            = "UK South"          #var.azlocation
  size                = "Standard_D2s_v3"   #D2as_v4
  admin_username      = "vmadmin"           #var.azvmadmin
  admin_password      = "SummerFlower0023!" #var.azvmpass 
  network_interface_ids = [
    azurerm_network_interface.vmnic-win.id,
  ]

  os_disk {
    name                 = "vmsserinfosec01-OSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    #sku     = "2022-datacenter-smalldisk-g2"
    version = "latest"
  }

  tags = {
    Account         = "IT & Change"
    Application     = "QualysInfoSec-Common"
    BillingApprover = "Gareth.Sumpter@tpr.gov.uk"
    BusinessSegment = "IT"
    pipeline_name   = "Manual"
    repository_name = "Manual"
    Terraformed     = "true"
    Department      = "Corporate Services" 
    CostCentre      = "BAU"
    Environment     = "Shared Services"
    Creator         = "Infrastructure Team"
    Project         = "infosec"
    SupportGroup    = "Infrastructure Team"          
  }
} 
resource "azurerm_network_interface" "vmnic-win" {
  name                = "vmsserinfosec01-vmnic"
  location            = "UK South" #var.azlocation
  resource_group_name = azurerm_resource_group.infosecrg.name
 
  ip_configuration {
    name                          = "vmsserinfosec01-IP"
    subnet_id                     = "/subscriptions/4098b2f4-823e-448e-b467-aa36d4d9ca14/resourceGroups/rg-uks-it-sser-net-01/providers/Microsoft.Network/virtualNetworks/vnet-uks-it-sser-01/subnets/snet-uks-it-sser-sha-01"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine_extension" "domain" {
  virtual_machine_id           = azurerm_windows_virtual_machine.vm1.id
  name                         = "join-domain"
  publisher                    = "Microsoft.Compute"
  type                         = "JsonADDomainExtension"
  type_handler_version         = "1.3"
  auto_upgrade_minor_version   = true
  settings                     = <<SETTINGS
{
"Name": "btn.opra.gov.uk",
"OUPath": "",
"User": "opra\\adminyr",
"Restart": "true",
"Options": "3"
}
    SETTINGS
  protected_settings           = <<PROTECTED_SETTINGS
{
"Password": "*****************"
}
    PROTECTED_SETTINGS
    depends_on = [azurerm_windows_virtual_machine.vm1]
    tags = {
    Account         = "IT & Change"
    Application     = "QualysInfoSec-Common"
    BillingApprover = "Gareth.Sumpter@tpr.gov.uk"
    BusinessSegment = "IT"
    pipeline_name   = "Manual"
    repository_name = "Manual"
    Terraformed     = "true"
    Department      = "Corporate Services"
    CostCentre      = "BAU"
    Environment     = "Shared Services"
    Creator         = "Infrastructure Team"
    Project         = "infosec"
    SupportGroup    = "Infrastructure Team"
	
	#"OUPath": "CN=Windows 2019,OU=Azure Members Servers,DC=btn,DC=opra,DC=gov,DC=uk"
  }
 }
