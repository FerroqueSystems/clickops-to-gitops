terraform {
  required_providers {
    citrix = {
      source = "citrix/citrix"
    }
  }
}

locals {
  prepared_image_definition_name = format("%s-%s", var.catalog_name_prefix, var.image_definition_name)
  catalog_name                   = format("%s-%s-%s-%s", var.catalog_name_prefix, var.environment_name, var.logical_name, var.generation)
  machine_name_prefix            = substr(lower(var.logical_name), 0, 12)
  session_support                = var.session_type == "single_session" ? "SingleSession" : "MultiSession"
  service_account_username       = split("@", reverse(split("\\", var.domain_join_username))[0])[0]
}

resource "citrix_image_definition" "this" {
  name                     = local.prepared_image_definition_name
  description              = format("Prepared image definition for %s", var.image_definition_name)
  os_type                  = "Windows"
  session_support          = local.session_support
  hypervisor               = var.hypervisor_id
  hypervisor_resource_pool = var.hypervisor_resource_pool_id

  azure_image_definition = {
    resource_group = var.image_resource_group_name
    gallery_image = {
      gallery    = var.gallery_name
      definition = var.image_definition_name
    }
  }
}

resource "citrix_image_version" "this" {
  image_definition         = citrix_image_definition.this.id
  hypervisor               = var.hypervisor_id
  hypervisor_resource_pool = var.hypervisor_resource_pool_id
  description              = format("Prepared image version %s for %s", var.image_version, local.prepared_image_definition_name)

  azure_image_specs = {
    service_offering = var.vm_size
    storage_type     = "Standard_LRS"
    resource_group   = var.image_resource_group_name
    gallery_image = {
      gallery    = var.gallery_name
      definition = var.image_definition_name
      version    = var.image_version
    }
  }
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
    network_mapping = [
      {
        network        = var.subnet_name
        network_device = "0"
      }
    ]

    machine_domain_identity = {
      domain                   = var.domain_name
      domain_ou                = var.domain_join_ou_path
      service_account_id       = var.domain_service_account_id
      service_account          = var.domain_service_account_id == null ? local.service_account_username : null
      service_account_password = var.domain_service_account_id == null ? var.domain_join_password : null
    }

    azure_machine_config = {
      storage_type       = "Standard_LRS"
      use_managed_disks  = true
      service_offering   = var.vm_size
      vda_resource_group = var.vda_resource_group_name

      prepared_image = {
        image_definition = citrix_image_definition.this.id
        image_version    = citrix_image_version.this.id
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
      condition     = var.domain_service_account_id != null || trimspace(var.domain_join_password) != ""
      error_message = "Set either domain_service_account_id or domain_join_password to create Active Directory-backed Citrix machine catalogs."
    }
  }
}

locals {
  plan = {
    logical_name                   = var.logical_name
    prepared_image_definition_name = local.prepared_image_definition_name
    prepared_image_definition_id   = citrix_image_definition.this.id
    prepared_image_version_id      = citrix_image_version.this.id
    catalog_name                   = local.catalog_name
    catalog_id                     = citrix_machine_catalog.this.id
    delivery_group_name            = var.delivery_group_name
    generation                     = var.generation
    session_type                   = var.session_type
    session_support                = local.session_support
    zone_id                        = var.zone_id
    hypervisor_id                  = var.hypervisor_id
    hypervisor_resource_pool_id    = var.hypervisor_resource_pool_id
    gallery_name                   = var.gallery_name
    image_definition_name          = var.image_definition_name
    image_version                  = var.image_version
    machine_count                  = var.machine_count
    vm_size                        = var.vm_size
    domain_name                    = var.domain_name
    domain_join_username           = var.domain_join_username
    domain_service_account_id      = var.domain_service_account_id
    service_account_username       = local.service_account_username
    location                       = var.location
    image_resource_group_name      = var.image_resource_group_name
    vda_resource_group_name        = var.vda_resource_group_name
    subnet_role                    = var.subnet_role
    subnet_name                    = var.subnet_name
    subnet_id                      = var.subnet_id
    tags                           = var.tags
    lifecycle                      = "rotating-managed"
  }
}
