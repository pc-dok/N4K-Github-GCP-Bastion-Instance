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

  metadata_startup_script = <<-SCRIPT
     #!/bin/bash
     if [ ! -f /var/tmp/startup-script-executed ]; then

        # Install required packages
        sudo add-apt-repository ppa:remmina-ppa-team/remmina-next -y
        sudo apt-get update -y
        sudo apt-get install freerdp2-dev freerdp2-x11 gnupg2 wget curl htop -y
        
        # Get the Guacamole Server Install Script
        sudo wget https://raw.githubusercontent.com/itiligent/Guacamole-Setup/main/1-setup.sh
        sudo chmod +x 1-setup.sh

        # Modify the script parameters
        sudo sed -i 's/SERVER_NAME=""/SERVER_NAME="bastion.n4k.at"/g' 1-setup.sh
        sudo sed -i 's/LOCAL_DOMAIN=""/LOCAL_DOMAIN="n4k.at"/g' 1-setup.sh
        sudo sed -i 's/INSTALL_MYSQL=""/INSTALL_MYSQL="true"/g' 1-setup.sh
        sudo sed -i 's/SECURE_MYSQL=""/SECURE_MYSQL="true"/g' 1-setup.sh
        sudo sed -i 's/MYSQL_HOST=""/MYSQL_HOST=""/g' 1-setup.sh
        sudo sed -i 's/MYSQL_PORT=""/MYSQL_PORT=""/g' 1-setup.sh
        sudo sed -i 's/GUAC_DB=""/GUAC_DB=""/g' 1-setup.sh
        sudo sed -i 's/GUAC_USER=""/GUAC_USER=""/g' 1-setup.sh
        sudo sed -i "s/GUAC_PWD=\"\"/GUAC_PWD=\"${var.GCP_Bastion_PW}\"/g" 1-setup.sh
        sudo sed -i 's/MYSQL_ROOT_PWD=\"\"/MYSQL_ROOT_PWD=\"${var.GCP_Bastion_PW}\"/g" 1-setup.sh
        sudo sed -i 's/INSTALL_TOTP=""/INSTALL_TOTP="true"/g' 1-setup.sh
        sudo sed -i 's/INSTALL_DUO=""/INSTALL_DUO="false"/g' 1-setup.sh
        sudo sed -i 's/INSTALL_LDAP=""/INSTALL_LDAP="false"/g' 1-setup.sh
        sudo sed -i 's/INSTALL_NGINX=""/INSTALL_NGINX="true"/g' 1-setup.sh
        sudo sed -i 's/PROXY_SITE=""/PROXY_SITE="bastion.n4k.at"/g' 1-setup.sh
        sudo sed -i 's/SELF_SIGN=""/SELF_SIGN="false"/g' 1-setup.sh
        sudo sed -i 's/CERT_COUNTRY="AU"/CERT_COUNTRY="LI"/g' 1-setup.sh
        sudo sed -i 's/CERT_STATE="Victoria"/CERT_STATE="LI"/g' 1-setup.sh
        sudo sed -i 's/CERT_LOCATION="Melbourne"/CERT_LOCATION="Triesen"/g' 1-setup.sh
        sudo sed -i 's/CERT_ORG="Itiligent"/CERT_ORG="N4K"/g' 1-setup.sh
        sudo sed -i 's/CERT_OU="I.T."/CERT_OU="IT"/g' 1-setup.sh
        sudo sed -i 's/CERT_DAYS="3650"/CERT_DAYS="3650"/g' 1-setup.sh
        sudo sed -i 's/LETS_ENCRYPT=""/LETS_ENCRYPT="true"/g' 1-setup.sh
        sudo sed -i 's/LE_DNS_NAME=""/LE_DNS_NAME="bastion.n4k.at"/g' 1-setup.sh
        sudo sed -i 's/LE_EMAIL=""/LE_EMAIL="info@n4k.at"/g' 1-setup.sh
        sudo sed -i 's/BACKUP_EMAIL=""/BACKUP_EMAIL="info@n4k.at"/g' 1-setup.sh
        sudo sed -i 's/EMAIL_DOMAIN=""/EMAIL_DOMAIN="n4k.at"/g' 1-setup.sh
        sudo sed -i 's/BACKUP_RETENTION="30"/BACKUP_RETENTION="30"/g' 1-setup.sh

        # Run the script now
        sudo ./1-setup.sh
  
        # create the file to indicate that the script has been executed
        touch /var/tmp/startup-script-executed
    fi

  SCRIPT

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
