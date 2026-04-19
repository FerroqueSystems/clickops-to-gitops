terraform {
  required_providers {
    citrix = {
      source = "citrix/citrix"
    }
  }
}

locals {
  catalog_name             = format("%s-%s-%s", var.environment_name, var.logical_name, var.generation)
  machine_name_prefix      = substr(lower(var.logical_name), 0, 12)
  session_support          = var.session_type == "single_session" ? "SingleSession" : "MultiSession"
  service_account_username = split("@", reverse(split("\\", var.domain_join_username))[0])[0]
}

resource "citrix_machine_catalog" "this" {
  name              = local.catalog_name
  description       = format("Machine catalog for %s generation %s", var.logical_name, var.generation)
  zone              = var.zone_id
  allocation_type   = "Random"
  session_support   = local.session_support
  provisioning_type = "MCS"

  provisioning_scheme = {
    hypervisor               = var.hypervisor_id
    hypervisor_resource_pool = var.hypervisor_resource_pool_id
    identity_type            = "ActiveDirectory"

    machine_domain_identity = {
      domain                   = var.domain_name
      domain_ou                = var.domain_join_ou_path
      service_account          = local.service_account_username
      service_account_password = var.domain_join_password
    }

    azure_machine_config = {
      storage_type      = "Standard_LRS"
      use_managed_disks = true
      service_offering  = var.vm_size

      azure_master_image = {
        resource_group = var.resource_group_name
        gallery_image = {
          gallery    = var.gallery_name
          definition = var.image_definition_name
          version    = var.image_version
        }
      }
    }

    number_of_total_machines = var.machine_count

    machine_account_creation_rules = {
      naming_scheme      = format("%s-##", local.machine_name_prefix)
      naming_scheme_type = "Numeric"
    }
  }

  lifecycle {
    precondition {
      condition     = trimspace(var.domain_join_password) != ""
      error_message = "domain_join_password must be set to create Active Directory-backed Citrix machine catalogs."
    }
  }
}

locals {
  plan = {
    logical_name                = var.logical_name
    catalog_name                = local.catalog_name
    catalog_id                  = citrix_machine_catalog.this.id
    delivery_group_name         = var.delivery_group_name
    generation                  = var.generation
    session_type                = var.session_type
    session_support             = local.session_support
    zone_id                     = var.zone_id
    hypervisor_id               = var.hypervisor_id
    hypervisor_resource_pool_id = var.hypervisor_resource_pool_id
    gallery_name                = var.gallery_name
    image_definition_name       = var.image_definition_name
    image_version               = var.image_version
    machine_count               = var.machine_count
    vm_size                     = var.vm_size
    domain_name                 = var.domain_name
    domain_join_username        = var.domain_join_username
    service_account_username    = local.service_account_username
    location                    = var.location
    resource_group_name         = var.resource_group_name
    subnet_role                 = var.subnet_role
    subnet_name                 = var.subnet_name
    subnet_id                   = var.subnet_id
    tags                        = var.tags
    lifecycle                   = "rotating-managed"
  }
}
