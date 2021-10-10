resource "mongodbatlas_project" "twizar_project" {
  name   = "twizar"
  org_id = var.mongodbatlas_org_id
}

resource "mongodbatlas_cluster" "twizar_cluster" {
  project_id   = mongodbatlas_project.twizar_project.id
  name         = "twizar"

  mongo_db_major_version = "4.4"
  provider_name = "TENANT"
  backing_provider_name = "AWS"
  provider_region_name = var.mongodbatlas_region
  provider_instance_size_name = "M0"
}
