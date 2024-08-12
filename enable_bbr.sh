#!/bin/bash

# Update and upgrade the server
sudo apt update -y && sudo apt upgrade -y

# Install necessary tools
sudo apt install -y curl iptables ufw expect

# Create an expect script to handle the interactive installation
cat << 'EOF' > /tmp/install_with_expect.exp
#!/usr/bin/expect -f

set timeout -1
spawn bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

# Handle prompts that may appear during installation
expect {
    "Command may disrupt existing ssh connections. Proceed with operation (y|n)?" {
        send "y\r"
        exp_continue
    }
    "Are you sure you want to continue?" {
        send "y\r"
        exp_continue
    }
    "Do you want to continue?" {
        send "y\r"
        exp_continue
    }
    "Do you want to proceed?" {
        send "y\r"
        exp_continue
    }
    "Enter your choice:" {
        send "\r"
        exp_continue
    }
    eof
}
EOF

# Make the expect script executable
chmod +x /tmp/install_with_expect.exp

# Run the expect script
/tmp/install_with_expect.exp

# Clean up
rm /tmp/install_with_expect.exp

# Enable BBR
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2087/tcp
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp
sudo ufw allow 7845/tcp
sudo ufw allow 2024/tcp
sudo ufw deny out from any to 10.0.0.0/8
sudo ufw deny out from any to 172.16.0.0/12
sudo ufw deny out from any to 192.168.0.0/16
sudo ufw deny out from any to 100.64.0.0/10
sudo ufw deny out from any to 198.18.0.0/15
sudo ufw deny out from any to 169.254.0.0/16
sudo ufw deny out from any to 102.236.0.0/16
sudo ufw deny out from any to 2.60.0.0/16
sudo ufw deny out from any to 5.1.41.0/12
sudo ufw enable

# Set iptables rules
sudo iptables -A FORWARD -s 200.0.0.0/8 -j DROP
sudo iptables -A FORWARD -s 102.0.0.0/8 -j DROP
sudo iptables -A FORWARD -s 10.0.0.0/8 -j DROP
sudo iptables -A FORWARD -s 100.64.0.0/10 -j DROP
sudo iptables -A FORWARD -s 169.254.0.0/16 -j DROP
sudo iptables -A FORWARD -s 198.18.0.0/15 -j DROP
sudo iptables -A FORWARD -s 198.51.100.0/24 -j DROP
sudo iptables -A FORWARD -s 203.0.113.0/24 -j DROP
sudo iptables -A FORWARD -s 224.0.0.0/4 -j DROP
sudo iptables -A FORWARD -s 240.0.0.0/4 -j DROP
sudo iptables -A FORWARD -s 255.255.255.255/32 -j DROP
sudo iptables -A FORWARD -s 192.0.0.0/24 -j DROP
sudo iptables -A FORWARD -s 192.0.2.0/24 -j DROP
sudo iptables -A FORWARD -s 127.0.0.0/8 -j DROP
sudo iptables -A FORWARD -s 127.0.53.53/32 -j DROP
sudo iptables -A FORWARD -s 192.168.0.0/16 -j DROP
sudo iptables -A FORWARD -s 0.0.0.0/8 -j DROP
sudo iptables -A FORWARD -s 172.16.0.0/12 -j DROP
sudo iptables -A FORWARD -s 224.0.0.0/3 -j DROP
sudo iptables -A FORWARD -s 192.88.99.0/24 -j DROP
sudo iptables -A FORWARD -s 169.254.0.0/16 -j DROP
sudo iptables -A FORWARD -s 198.18.140.0/24 -j DROP
sudo iptables -A FORWARD -s 102.230.9.0/24 -j DROP
sudo iptables -A FORWARD -s 102.233.71.0/24 -j DROP
sudo iptables-save

# Reboot the server to apply changes
sudo reboot
