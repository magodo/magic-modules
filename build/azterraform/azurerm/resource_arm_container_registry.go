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



func resourceArmContainerRegistry() *schema.Resource {
    return &schema.Resource{
        Create: resourceArmContainerRegistryCreate,
        Read: resourceArmContainerRegistryRead,
        Update: resourceArmContainerRegistryUpdate,
        Delete: resourceArmContainerRegistryDelete,

        Importer: &schema.ResourceImporter{
            State: schema.ImportStatePassthrough,
        },


        Schema: map[string]*schema.Schema{
            "location": locationSchema(),
            "name": {
                Type: schema.TypeString,
                Required: true,
              ForceNew: true,
            },
            "resource_group_name": resourceGroupNameSchema(),
            "admin_enabled": {
                Type: schema.TypeBool,
                Optional: true,
                Default: false,
            },
            "sku": {
                Type: schema.TypeString,
                Optional: true,
            	ValidateFunc: validation.StringInSlice([]string{"Classic","Basic","Standard","Premium",""}, false),
                Default: "Classic",
            },
            "storage_account_id": {
                Type: schema.TypeString,
                Optional: true,
            },
            "tags": tagsSchema(),
            "login_server": {
                Type: schema.TypeString,
                Computed: true,
            },
        },
    }
}

func resourceArmContainerRegistryCreate(d *schema.ResourceData, meta interface{}) error {
    client := meta.(*ArmClient).containerRegistryClient
    ctx := meta.(*ArmClient).StopContext

    name := d.Get("name").(string)
    resourceGroup := d.Get("resource_group_name").(string)
    location := azureRMNormalizeLocation(d.Get("location").(string))
    sku := d.Get("sku").(string)
    adminEnabled := d.Get("admin_enabled").(bool)
    storageAccountId := d.Get("storage_account_id").(string)
    tags := d.Get("tags").(map[string]interface{})

    parameters := containerregistry.Registry{
        Location: utils.String(location),
        Sku: &containerregistry.Sku{
            Name: containerregistry.SkuName(sku),
        },
        RegistryProperties: &containerregistry.RegistryProperties{
            AdminUserEnabled: utils.Bool(adminEnabled),
            StorageAccount: &containerregistry.StorageAccountProperties{
                ID: utils.String(storageAccountId),
            },
        },
        Tags: expandTags(tags),
    }


    future, err := client.Create(ctx, resourceGroup, name, parameters)
    if err != nil {
        return fmt.Errorf("Error creating ContainerRegistry %q (Resource Group %q): %+v", name, resourceGroup, err)
    }
    if err = future.WaitForCompletionRef(ctx, client.Client); err != nil {
        return fmt.Errorf("Error waiting for creation of ContainerRegistry %q (Resource Group %q): %+v", name, resourceGroup, err)
    }


    resp, err := client.Get(ctx, resourceGroup, name)
    if err != nil {
        return err
    }
    if resp.ID == nil {
        return fmt.Errorf("Cannot read ContainerRegistry %q", name)
    }
    d.SetId(*resp.ID)

    return resourceArmContainerRegistryRead(d, meta)
}

func resourceArmContainerRegistryRead(d *schema.ResourceData, meta interface{}) error {
    client := meta.(*ArmClient).containerRegistryClient
    ctx := meta.(*ArmClient).StopContext

    id, err := parseAzureResourceID(d.Id())
    if err != nil {
        return fmt.Errorf("Error parsing ContainerRegistry ID %q: %+v", d.Id(), err)
    }
    resourceGroup := id.ResourceGroup
    name := id.Path["registries"]

    resp, err := client.Get(ctx, resourceGroup, name)
    if err != nil {
        if utils.ResponseWasNotFound(resp.Response) {
            log.Printf("[INFO] ContainerRegistry %q does not exist - removing from state", d.Id())
            d.SetId("")
            return nil
        }
        return fmt.Errorf("Error reading ContainerRegistry: %+v", err)
    }



    d.Set("name", resp.Name)
    d.Set("resource_group_name", resourceGroup)
    if location := resp.Location; location != nil {
        d.Set("location", azureRMNormalizeLocation(*location))
    }
    if sku := resp.Sku; sku != nil {
        d.Set("sku", string(sku.Name))
    }
    if registryProperties := resp.RegistryProperties; registryProperties != nil {
        d.Set("admin_enabled", registryProperties.AdminUserEnabled)
        if storageAccount := registryProperties.StorageAccount; storageAccount != nil {
            d.Set("storage_account_id", storageAccount.ID)
        }
    }
    d.Set("login_server", resp.LoginServer)
    flattenAndSetTags(d, resp.Tags)

    return nil
}

func resourceArmContainerRegistryUpdate(d *schema.ResourceData, meta interface{}) error {
    client := meta.(*ArmClient).containerRegistryClient
    ctx := meta.(*ArmClient).StopContext

    id, err := parseAzureResourceID(d.Id())
    if err != nil {
        return fmt.Errorf("Error parsing ContainerRegistry ID %q: %+v", d.Id(), err)
    }
    resourceGroup := id.ResourceGroup
    name := id.Path["registries"]

    sku := d.Get("sku").(string)
    adminEnabled := d.Get("admin_enabled").(bool)
    storageAccountId := d.Get("storage_account_id").(string)
    tags := d.Get("tags").(map[string]interface{})

    parameters := containerregistry.RegistryUpdateParameters{
        Sku: &containerregistry.Sku{
            Name: containerregistry.SkuName(sku),
        },
        RegistryPropertiesUpdateParameters: &containerregistry.RegistryPropertiesUpdateParameters{
            AdminUserEnabled: utils.Bool(adminEnabled),
            StorageAccount: &containerregistry.StorageAccountProperties{
                ID: utils.String(storageAccountId),
            },
        },
        Tags: expandTags(tags),
    }

    future, err := client.Update(ctx, resourceGroup, name, parameters)
    if err != nil {
        return fmt.Errorf("Error updating ContainerRegistry %q (Resource Group %q): %+v", name, resourceGroup, err)
    }
    if err = future.WaitForCompletionRef(ctx, client.Client); err != nil {
        return fmt.Errorf("Error waiting for update of ContainerRegistry %q (Resource Group %q): %+v", name, resourceGroup, err)
    }

    return resourceArmContainerRegistryRead(d, meta)
}

func resourceArmContainerRegistryDelete(d *schema.ResourceData, meta interface{}) error {
    client := meta.(*ArmClient).containerRegistryClient
    ctx := meta.(*ArmClient).StopContext


    id, err := parseAzureResourceID(d.Id())
    if err != nil {
        return fmt.Errorf("Error parsing ContainerRegistry ID %q: %+v", d.Id(), err)
    }
    resourceGroup := id.ResourceGroup
    name := id.Path["registries"]

    future, err := client.Delete(ctx, resourceGroup, name)
    if err != nil {
        if response.WasNotFound(future.Response()) {
            return nil
        }
        return fmt.Errorf("Error deleting ContainerRegistry %q: %+v", name, err)
    }

    if err = future.WaitForCompletionRef(ctx, client.Client); err != nil {
        if !response.WasNotFound(future.Response()) {
            return fmt.Errorf("Error waiting for deleting ContainerRegistry %q: %+v", name, err)
        }
    }

    return nil
}
