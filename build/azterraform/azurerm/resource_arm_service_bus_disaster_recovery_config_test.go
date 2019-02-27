// ----------------------------------------------------------------------------
//
//     ***     AUTO GENERATED CODE    ***    AUTO GENERATED CODE     ***
//
// ----------------------------------------------------------------------------
//
//     This file is automatically generated by Magic Modules and manual
//     changes will be clobbered when the file is regenerated.
//
//     Please read more about how to change this file in
//     .github/CONTRIBUTING.md.
//
// ----------------------------------------------------------------------------

package azurerm

import (
    "fmt"
    "testing"

    "github.com/hashicorp/terraform/helper/resource"
    "github.com/hashicorp/terraform/terraform"
    "github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/tf"
    "github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
)


func testCheckAzureRMServiceBusDisasterRecoveryConfigExists(resourceName string) resource.TestCheckFunc {
    return func(s *terraform.State) error {
        rs, ok := s.RootModule().Resources[resourceName]
        if !ok {
            return fmt.Errorf("Service Bus Disaster Recovery Config not found: %s", resourceName)
        }

        name := rs.Primary.Attributes["name"]
        resourceGroup, hasResourceGroup := rs.Primary.Attributes["resource_group_name"]
        if !hasResourceGroup {
            return fmt.Errorf("Bad: no resource group name found in state for Service Bus Disaster Recovery Config: %q", name)
        }
        servicebusName, hasServicebusName := rs.Primary.Attributes["namespace_name"]
        if !hasServicebusName {
            return fmt.Errorf("Bad: no namespace name found in state for Service Bus Disaster Recovery Config: %q", name)
        }

        client := testAccProvider.Meta().(*ArmClient).serviceBusRecoveryClient
        ctx := testAccProvider.Meta().(*ArmClient).StopContext

        if resp, err := client.Get(ctx, resourceGroup, servicebusName, name); err != nil {
            if utils.ResponseWasNotFound(resp.Response) {
                return fmt.Errorf("Bad: Service Bus Disaster Recovery Config %q (Resource Group %q, Namespace Name %q) does not exist", name, resourceGroup, servicebusName)
            }
            return fmt.Errorf("Bad: Get on serviceBusRecoveryClient: %+v", err)
        }

        return nil
    }
}

func testCheckAzureRMServiceBusDisasterRecoveryConfigDestroy(s *terraform.State) error {
    client := testAccProvider.Meta().(*ArmClient).serviceBusRecoveryClient
    ctx := testAccProvider.Meta().(*ArmClient).StopContext

    for _, rs := range s.RootModule().Resources {
        if rs.Type != "azurerm_service_bus_disaster_recovery_config" {
            continue
        }

        name := rs.Primary.Attributes["name"]
        resourceGroup := rs.Primary.Attributes["resource_group_name"]
        servicebusName := rs.Primary.Attributes["namespace_name"]

        if resp, err := client.Get(ctx, resourceGroup, servicebusName, name); err != nil {
            if !utils.ResponseWasNotFound(resp.Response) {
                return fmt.Errorf("Bad: Get on serviceBusRecoveryClient: %+v", err)
            }
        }

        return nil
    }

    return nil
}
