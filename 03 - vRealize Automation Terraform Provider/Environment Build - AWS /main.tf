provider "vra" {
  url           = var.url
  refresh_token = var.refresh_token
}

resource "vra_cloud_account_aws" "AWS-Cloud-Account" {
  name        = "Amazon Web Services"
  description = "AWS Account"
  access_key  = var.access_key
  secret_key  = var.secret_key
  regions     = ["us-east-1", "us-west-1"]
}

data "vra_region" "us-east-1-region" {
  cloud_account_id = vra_cloud_account_aws.AWS-Cloud-Account.id
  region           = "us-east-1"
}

data "vra_region" "us-west-1-region" {
  cloud_account_id = vra_cloud_account_aws.AWS-Cloud-Account.id
  region           = "us-west-1"
}

resource "vra_zone" "us-east-zone" {
  name        = "AWS Cloud Zone - US East 1"
  description = "Cloud Zone for AWS Resources (East)"
  tags {
			key = "env"
			value = "aws-east"
		}
  region_id   = data.vra_region.us-east-1-region.id
}

resource "vra_zone" "us-west-zone" {
  name        = "AWS Cloud Zone - US West 1"
  description = "Cloud Zone for AWS Resources (West)"
    tags {
			key = "env"
			value = "aws-west"
		}
  region_id   = data.vra_region.us-west-1-region.id
}

resource "vra_project" "my-project" {
  name        = "Terraform Project"
  description = "Terraform Deployed Project"
  zone_assignments {
    zone_id       = vra_zone.us-east-zone.id
    priority      = 1
    max_instances = 2
  }
  zone_assignments {
    zone_id       = vra_zone.us-west-zone.id
    priority      = 1
    max_instances = 2
  }
}

resource "vra_flavor_profile" "aws-east" {
  name = "small"
  flavor_mapping {
    name = "small"
    instance_type = "t2.micro"
  }

  flavor_mapping {
    name = "medium"
    instance_type = "t2.medium"
  }

  flavor_mapping {
    name = "large"
    instance_type = "t2.large"
  }

  region_id = data.vra_region.us-east-1-region.id
}

resource "vra_flavor_profile" "aws-west" {
  name = "small"
  flavor_mapping {
    name = "small"
    instance_type = "t2.micro"
  }

  flavor_mapping {
    name = "medium"
    instance_type = "t2.medium"
  }

  flavor_mapping {
    name = "large"
    instance_type = "t2.large"
  }

  region_id = data.vra_region.us-west-1-region.id
}

resource "vra_image_profile" "image_profile_east" {
  name = "ubuntu"
  image_mapping {
    name = "ubuntu"
    image_name = "ami-07d0cf3af28718ef8"
  }
  region_id = data.vra_region.us-east-1-region.id
}

resource "vra_image_profile" "image_profile_west" {
  name = "ubuntu"
  image_mapping {
    name = "ubuntu"
    image_name = "ami-08fd8ae3806f09a08"
  }
  region_id = data.vra_region.us-west-1-region.id
}

data "vra_fabric_network" "my-fabric-network-east" {
			filter = "name eq 'subnet-681b9b34'"
      depends_on = [vra_cloud_account_aws.AWS-Cloud-Account, null_resource.delay]
		}

data "vra_fabric_network" "my-fabric-network-west" {
			filter = "name eq 'subnet-f817069f'"
      depends_on = [vra_cloud_account_aws.AWS-Cloud-Account, null_resource.delay]
		}

resource "vra_network_profile" "aws_network_profile-east" {
  name = "Default AWS East"
  description = "Default Network Profile for AWS"
  region_id = data.vra_region.us-east-1-region.id
  fabric_network_ids = [data.vra_fabric_network.my-fabric-network-east.id]
}

resource "vra_network_profile" "aws_network_profile-west" {
  name = "Default AWS West"
  description = "Default Network Profile for AWS"
  region_id = data.vra_region.us-west-1-region.id
  fabric_network_ids = [data.vra_fabric_network.my-fabric-network-west.id]
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }
  triggers = {
    "my_zone" = "${vra_cloud_account_aws.AWS-Cloud-Account.id}"
  }
}

resource "vra_machine" "aws-machine" {
  name = "HashiConf2019"
  description = "Deployed with vRA Cloud and Terraform!"
  project_id = vra_project.my-project.id
  constraints {
    mandatory = true
    expression = "env:aws-east"
  }
  image = "ubuntu"
  flavor =  "small"
  depends_on = [vra_network_profile.aws_network_profile-east]
}