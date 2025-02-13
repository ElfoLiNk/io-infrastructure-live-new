dependency "subnet" {
  config_path = "../subnet"
}

dependency "cosmosdb_account" {
  config_path = "../../cosmosdb/account"
}

dependency "cosmosdb_database" {
  config_path = "../../cosmosdb/database"
}

dependency "storage_account" {
  config_path = "../../storage/account"
}

dependency "storage_account_assets" {
  config_path = "../../../../common/cdn/storage_account_assets"
}

dependency "storage_account_logs" {
  config_path = "../../../../operations/storage_account_logs/account"
}

dependency "storage_container_message-content" {
  config_path = "../../storage/container_message-content"
}

dependency "storage_table_subscriptionsfeedbyday" {
  config_path = "../../storage/table_subscriptionsfeedbyday"
}

# Internal
dependency "resource_group" {
  config_path = "../../../resource_group"
}

dependency "storage_account_apievents" {
  config_path = "../../storage_apievents/account"
}

dependency "storage_account_apievents_queue_eucovidcert-profile-created" {
  config_path = "../../storage_apievents/queue_eucovidcert-profile-created"
}

# Linux
dependency "subnet_appbackend_l1" {
  config_path = "../../../../linux/appbackendl1/subnet"
}

dependency "subnet_appbackend_l2" {
  config_path = "../../../../linux/appbackendl2/subnet"
}

dependency "subnet_appbackend_li" {
  config_path = "../../../../linux/appbackendli/subnet"
}

# Common
dependency "virtual_network" {
  config_path = "../../../../common/virtual_network"
}

dependency "application_insights" {
  config_path = "../../../../common/application_insights"
}

dependency "key_vault" {
  config_path = "../../../../common/key_vault"
}

dependency "notification_hub" {
  config_path = "../../../../common/notification_hub"
}

dependency "notification_queue" {
  config_path = "../../storage_notifications/queue_push-notifications"
}

dependency "notification_storage_account" {
  config_path = "../../storage_notifications/account"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:pagopa/io-infrastructure-modules-new.git//azurerm_function_app?ref=v3.0.3"
}

locals {
  commonvars                   = read_terragrunt_config(find_in_parent_folders("commonvars.hcl"))
  service_api_url              = local.commonvars.locals.service_api_url
  app_insights_ips_west_europe = local.commonvars.locals.app_insights_ips_west_europe
}

inputs = {
  name                = "appasync"
  resource_group_name = dependency.resource_group.outputs.resource_name

  resources_prefix = {
    function_app     = "fn3"
    app_service_plan = "fn3"
    storage_account  = "fn3"
  }

  app_service_plan_info = {
    kind     = "elastic"
    sku_tier = "ElasticPremium"
    sku_size = "EP1"
  }

  runtime_version = "~3"

  application_insights_instrumentation_key = dependency.application_insights.outputs.instrumentation_key

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "10.14.1"
    WEBSITE_RUN_FROM_PACKAGE       = "1"
    FUNCTIONS_WORKER_PROCESS_COUNT = 4
    NODE_ENV                       = "production"

    COSMOSDB_URI  = dependency.cosmosdb_account.outputs.endpoint
    COSMOSDB_KEY  = dependency.cosmosdb_account.outputs.primary_master_key
    COSMOSDB_NAME = dependency.cosmosdb_database.outputs.name
    // TODO: Rename to STORAGE_CONNECTION_STRING
    QueueStorageConnection = dependency.storage_account.outputs.primary_connection_string
    MESSAGE_CONTAINER_NAME = dependency.storage_container_message-content.outputs.name

    LogsStorageConnection      = dependency.storage_account_logs.outputs.primary_connection_string
    AssetsStorageConnection    = dependency.storage_account_assets.outputs.primary_connection_string
    STATUS_ENDPOINT_URL        = "https://app-backend.io.italia.it/info"
    STATUS_REFRESH_INTERVAL_MS = "300000"

    // TODO: Rename to SUBSCRIPTIONSFEEDBYDAY_TABLE_NAME
    SUBSCRIPTIONS_FEED_TABLE = dependency.storage_table_subscriptionsfeedbyday.outputs.name
    MAIL_FROM                = "IO - l'app dei servizi pubblici <no-reply@io.italia.it>"
    DPO_EMAIL_ADDRESS        = "dpo@pagopa.it"
    PUBLIC_API_URL           = local.service_api_url
    FUNCTIONS_PUBLIC_URL     = "https://api.io.italia.it/public"

    // Keepalive fields are all optionals
    FETCH_KEEPALIVE_ENABLED             = "true"
    FETCH_KEEPALIVE_SOCKET_ACTIVE_TTL   = "110000"
    FETCH_KEEPALIVE_MAX_SOCKETS         = "40"
    FETCH_KEEPALIVE_MAX_FREE_SOCKETS    = "10"
    FETCH_KEEPALIVE_FREE_SOCKET_TIMEOUT = "30000"
    FETCH_KEEPALIVE_TIMEOUT             = "60000"

    // Push notifications
    AZURE_NH_HUB_NAME                       = dependency.notification_hub.outputs.name
    NOTIFICATIONS_QUEUE_NAME                = dependency.notification_queue.outputs.name
    NOTIFICATIONS_STORAGE_CONNECTION_STRING = dependency.notification_storage_account.outputs.primary_connection_string

    // Events configs
    EventsQueueStorageConnection = dependency.storage_account_apievents.outputs.primary_connection_string

    SLOT_TASK_HUBNAME = "ProductionTaskHub"

    // Disable functions
    #"AzureWebJobs.CreateProfile.Disabled"                          = "1"
    #"AzureWebJobs.CreateValidationTokenActivity.Disabled"          = "1"
    #"AzureWebJobs.EmailValidationProcessOrchestrator.Disabled"     = "1"
    #"AzureWebJobs.GetMessage.Disabled"                             = "1"
    #"AzureWebJobs.GetMessages.Disabled"                            = "1"
    #"AzureWebJobs.GetProfile.Disabled"                             = "1"
    #"AzureWebJobs.GetService.Disabled"                             = "1"
    #"AzureWebJobs.GetUserDataProcessing.Disabled"                  = "1"
    #"AzureWebJobs.GetVisibleServices.Disabled"                     = "1"
    #"AzureWebJobs.HandleNHNotificationCall.Disabled"               = "1"
    #"AzureWebJobs.HandleNHNotificationCallActivity.Disabled"       = "1"
    #"AzureWebJobs.HandleNHNotificationCallOrchestrator.Disabled"   = "1"
    #"AzureWebJobs.SendUserDataProcessingEmailActivity.Disabled"    = "1"
    #"AzureWebJobs.SendValidationEmailActivity.Disabled"            = "1"
    #"AzureWebJobs.SendWelcomeMessagesActivity.Disabled"            = "1"
    #"AzureWebJobs.StartEmailValidationProcess.Disabled"            = "1"
    #"AzureWebJobs.StoreSpidLogs.Disabled"                          = "1"
    #"AzureWebJobs.UpdateProfile.Disabled"                          = "1"
    #"AzureWebJobs.UpdateSubscriptionsFeedActivity.Disabled"        = "1"
    #"AzureWebJobs.UpsertUserDataProcessing.Disabled"               = "1"
    #"AzureWebJobs.UpsertedProfileOrchestrator.Disabled"            = "1"
    #"AzureWebJobs.UpsertedUserDataProcessingOrchestrator.Disabled" = "1"
    "AzureWebJobs.HandleNHNotificationCall.Disabled" = "1" // Messages are handled by io-p-fn3-pushnotif
    "AzureWebJobs.StoreSpidLogs.Disabled"            = "0"

    # Cashback
    IS_CASHBACK_ENABLED = "true"
    # Only national service
    FF_ONLY_NATIONAL_SERVICES = "true"
    # Limit the number of local services
    FF_LOCAL_SERVICES_LIMIT = "0"
    # eucovidcert configs
    FF_NEW_USERS_EUCOVIDCERT_ENABLED       = "false"
    EUCOVIDCERT_PROFILE_CREATED_QUEUE_NAME = dependency.storage_account_apievents_queue_eucovidcert-profile-created.outputs.name

    # this app settings is required to solve the issue:
    # https://github.com/terraform-providers/terraform-provider-azurerm/issues/10499
    WEBSITE_CONTENTSHARE = "io-p-fn3-appasync-content"
  }

  app_settings_secrets = {
    key_vault_id = dependency.key_vault.outputs.id
    map = {
      __DISABLED__SENDGRID_API_KEY = "common-SENDGRID-APIKEY"
      MAILUP_USERNAME              = "common-MAILUP2-USERNAME"
      MAILUP_SECRET                = "common-MAILUP2-SECRET"
      PUBLIC_API_KEY               = "apim-IO-SERVICE-KEY"
      SPID_LOGS_PUBLIC_KEY         = "funcapp-KEY-SPIDLOGS-PUB"
      AZURE_NH_ENDPOINT            = "common-AZURE-NH-ENDPOINT"
    }
  }

  allowed_subnets = [
    dependency.subnet.outputs.id,
    dependency.subnet_appbackend_l1.outputs.id,
    dependency.subnet_appbackend_l2.outputs.id,
    dependency.subnet_appbackend_li.outputs.id,
  ]

  allowed_ips = local.app_insights_ips_west_europe

  subnet_id = dependency.subnet.outputs.id
}
