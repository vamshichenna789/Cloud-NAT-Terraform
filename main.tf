data "google_compute_network" "my-network" {
  name = "nat"
}

data "google_compute_subnetwork" "my-subnetwork" {
  name   = "private"
  region = "us-central1"
}


resource "google_compute_instance" "basic_vm" {
  name         = "terraform-private"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.my-network.self_link
    subnetwork = data.google_compute_subnetwork.my-subnetwork.self_link
  }
}
resource "google_compute_router" "foobar" {
  name    = "nat-terraform"
  network = data.google_compute_network.my-network.self_link
  region  = "us-central1"
}


resource "google_compute_router_nat" "nat" {
  name   = "nat-terraform"
  router = google_compute_router.foobar.name
  region = "us-central1"

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = data.google_compute_subnetwork.my-subnetwork.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
