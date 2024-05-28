locals {
  resourceGroupName  = "${var.prefix}-${var.resourceFunction}-${var.environment}-${var.region}"
  storageAccountName = "${var.prefix}${var.resourceFunction}sa${var.environment}${var.region}"
  apimName          = "${var.prefix}-${var.resourceFunction}-${var.environment}-${var.region}"
  appInsightsName   = "${var.prefix}-${var.resourceFunction}-appinsights-${var.environment}-${var.region}"
}

# create resource group
resource "azurerm_resource_group" "rg" {
  name     = local.resourceGroupName
  location = var.location
}


#Create storage account container for apim
resource "azurerm_storage_container" "saContainerApim" {
  name                  = var.apim-files
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = var.container_access_type
}



# Create Azure API management resource

resource "azurerm_api_management" "apim" {
  name                = local.apimName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.apimPublisherName
  publisher_email     = var.apimPublisherEmail
  sku_name            = var.apimSku

}
# Create Logger
resource "azurerm_api_management_logger" "apimLogger" {
  name                = "${local.apimName}-logger"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name  = azurerm_resource_group.rg.name

  application_insights {
    instrumentation_key = azurerm_application_insights.ai.instrumentation_key
  }
}

# Create API
resource "azurerm_api_management_api" "api" {
  name                = var.apiname
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = var.apidisplayname
  path                = var.apipath
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
}
