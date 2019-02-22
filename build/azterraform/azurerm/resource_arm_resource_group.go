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



func resourceArmResourceGroup() *schema.Resource {
    return &schema.Resource{
        Create: resourceArmResourceGroupCreateUpdate,
        Read: resourceArmResourceGroupRead,
        Update: resourceArmResourceGroupCreateUpdate,
        Delete: resourceArmResourceGroupDelete,

        Importer: &schema.ResourceImporter{
            State: schema.ImportStatePassthrough,
        },


        Schema: map[string]*schema.Schema{
            "name": resourceGroupNameSchema(),

            "location": locationSchema(),

            "tags": tagsSchema(),
        },
    }
}

func resourceArmResourceGroupCreateUpdate(d *schema.ResourceData, meta interface{}) error {
    client := meta.(*ArmClient).resourceGroupsClient
    ctx := meta.(*ArmClient).StopContext

    name := d.Get("name").(string)
    location := azureRMNormalizeLocation(d.Get("location").(string))
    tags := d.Get("tags").(map[string]interface{})

    parameters := resources.Group{
        Location: utils.String(location),
        Tags: expandTags(tags),
    }


    if _, err := client.CreateOrUpdate(ctx, name, parameters); err != nil {
        return fmt.Errorf("Error creating Resource Group %q: %+v", name, err)
    }


    resp, err := client.Get(ctx, name)
    if err != nil {
        return fmt.Errorf("Error retrieving Resource Group %q: %+v", name, err)
    }
    if resp.ID == nil {
        return fmt.Errorf("Cannot read Resource Group %q ID", name)
    }
    d.SetId(*resp.ID)

    return resourceArmResourceGroupRead(d, meta)
}

func resourceArmResourceGroupRead(d *schema.ResourceData, meta interface{}) error {
    client := meta.(*ArmClient).resourceGroupsClient
    ctx := meta.(*ArmClient).StopContext

    id, err := parseAzureResourceID(d.Id())
    if err != nil {
        return fmt.Errorf("Error parsing Resource Group ID %q: %+v", d.Id(), err)
    }
    name := id.ResourceGroup

    resp, err := client.Get(ctx, name)
    if err != nil {
        if utils.ResponseWasNotFound(resp.Response) {
            log.Printf("[INFO] Resource Group %q does not exist - removing from state", d.Id())
            d.SetId("")
            return nil
        }
        return fmt.Errorf("Error reading Resource Group %q: %+v", name, err)
    }



    d.Set("name", resp.Name)
    if location := resp.Location; location != nil {
        d.Set("location", azureRMNormalizeLocation(*location))
    }
    flattenAndSetTags(d, resp.Tags)

    return nil
}


func resourceArmResourceGroupDelete(d *schema.ResourceData, meta interface{}) error {
    client := meta.(*ArmClient).resourceGroupsClient
    ctx := meta.(*ArmClient).StopContext


    id, err := parseAzureResourceID(d.Id())
    if err != nil {
        return fmt.Errorf("Error parsing Resource Group ID %q: %+v", d.Id(), err)
    }
    name := id.ResourceGroup

    future, err := client.Delete(ctx, name)
    if err != nil {
        if response.WasNotFound(future.Response()) {
            return nil
        }
        return fmt.Errorf("Error deleting Resource Group %q: %+v", name, err)
    }

    if err = future.WaitForCompletionRef(ctx, client.Client); err != nil {
        if !response.WasNotFound(future.Response()) {
            return fmt.Errorf("Error waiting for deleting Resource Group %q: %+v", name, err)
        }
    }

    return nil
}
