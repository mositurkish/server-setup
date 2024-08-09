#!/bin/bash

# بررسی نسخه کرنل
kernel_version=$(uname -r)
echo "Kernel version: $kernel_version"

# اضافه کردن تنظیمات BBR به sysctl.conf
echo "Configuring BBR..."
echo "net.core.default_qdisc = fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = bbr" | sudo tee -a /etc/sysctl.conf

# اعمال تنظیمات
echo "Applying sysctl settings..."
sudo sysctl -p

# بررسی فعال شدن BBR
echo "Checking if BBR is enabled..."
tcp_congestion_control=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')

if [ "$tcp_congestion_control" = "bbr" ]; then
    echo "BBR has been successfully enabled."
else
    echo "BBR activation failed."
fi

# بررسی ماژول BBR
echo "Checking BBR module..."
lsmod | grep bbr && echo "BBR module is loaded." || echo "BBR module is not loaded."

echo "Done."
