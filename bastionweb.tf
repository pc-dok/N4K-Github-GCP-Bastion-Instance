# Create a Guacamole server

# Creates the Firewall Rule for the SSH Login and also https
resource "google_compute_firewall" "external" {
  name              = "external"
  project           = var.project_name
  priority          = 1010
  network           = google_compute_network.vpc.self_link
  direction         = "INGRESS"
 
  allow {
    protocol = "tcp"
    ports    = ["22","80","443","3389"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion","windows"]
}

# Create a public IP address for the Guacamole Bastion server
resource "google_compute_address" "bastion_server_public_ip" {
  name          = "bastion-server-public-ip"
  project       = var.project_name
  region        = var.region
  depends_on    = [google_compute_firewall.external]
}

# Create the Guacamole Bastion server on Ubuntu
resource "google_compute_instance" "bastion_server" {
  name         = "bastion"
  project      = var.project_name
  machine_type = "n1-standard-2"
  zone         = var.zone
  tags         = ["bastion"]
  depends_on   = [
                    google_compute_address.bastion_server_public_ip,
                    google_compute_router_nat.nat,]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  metadata = {
    startup-script = file("${path.module}/guacamole.sh")
  }
  
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
    access_config {
      nat_ip = google_compute_address.bastion_server_public_ip.address
    }
  }
}

# Create the Windows server on Google Cloud
resource "google_compute_instance" "windows_server" {
  count        = 1
  name         = "windows-server-${count.index + 1}"
  project      = var.project_name
  machine_type = "n1-standard-2"
  zone         = var.zone
  tags         = ["windows"]
  depends_on   = [google_compute_firewall.external]

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2022"
    }
  }

  metadata = {
    windows-startup-script-ps1 = <<-EOT
    #Setup FlagFile for only Run Once
    $flagFile = "C:\startupscriptexecuted.txt"
        if (Test-Path $flagFile) {
    Write-Output "Startup script already executed. Skipping..."
    exit 0
    }

    # Install Chocolatey package manager
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # Install Google Chrome and Notepad++ using Chocolatey
    choco install -y googlechrome notepadplusplus

    # Disable IE Security
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" -Name "IEHarden" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" -Name "IEHardenAdmin" -Value 0

    # Disable Server Manager Auto Startup
    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask

    # Install RSAT Tools with GPM, AD and DNS
    Install-WindowsFeature -Name RSAT-AD-PowerShell, RSAT-AD-AdminCenter, RSAT-ADDS, RSAT-DNS-Server, GPMC

    # Create flag file
    New-Item $flagFile -ItemType File
    Write-Output "Startup script executed successfully."
    
    EOT
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.self_link
  }
}
