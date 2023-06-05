#!/bin/bash
echo "***** Welcome to the Local Mail Server Setup Script! *****"


# Prompt for server IP
read -p "Enter the server IP address: " server_ip

# Prompt for server ansible_user
read -p "Enter the server user: " server_user

# Prompt for server ansible_become_pass
read -s -p "Enter the user's password: " server_become_pass
echo

# Prompt for client IP
read -p "Enter the client IP address: " client_ip

# Prompt for client ansible_user
read -p "Enter the client user: " client_user

# Prompt for client ansible_become_pass
read -s -p "Enter the user's password: " client_become_pass
echo

# Add server/client IPs to /etc/hosts
sudo sed -i "/server_ip/ d" /etc/hosts
sudo sed -i "/client_ip/ d" /etc/hosts
echo "$server_ip    server" | sudo tee -a /etc/hosts > /dev/null
echo "$client_ip    client" | sudo tee -a /etc/hosts > /dev/null

# Create Ansible inventory file
echo "[servers]" > inventory.ini
echo "server ansible_host=$server_ip ansible_user=$server_user ansible_become_pass=$server_become_pass" >> inventory.ini
echo "" >> inventory.ini
echo "[clients]" >> inventory.ini
echo "client ansible_host=$client_ip ansible_user=$client_user ansible_become_pass=$client_become_pass" >> inventory.ini

# Print updated /etc/hosts file
echo -e "\nUpdated /etc/hosts file:"
cat /etc/hosts

# Print Ansible inventory file
echo -e "\nAnsible inventory file:"
cat inventory.ini
echo "****************************"

# Replace server IP address in the client_config playbook
client_playbook="client_config.yml"
temp_playbook="temp_client_config.yml"

sed "s|replace_with_server_IP|$server_ip|g" "$client_playbook" > "$temp_playbook"

# Check if Ansible is already installed
if ! command -v ansible &> /dev/null; then
    echo "Ansible is not installed. Installing Ansible..."

    # Update package manager
    sudo apt-get update

    # Install Ansible
    sudo apt-get install -y ansible

    echo "Ansible installed successfully!"
else
    echo "Ansible is already installed."
fi


# Generate SSH keys
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# Copy SSH keys to server
ssh-copy-id -i ~/.ssh/id_rsa.pub $server_user@$server_ip

# Copy SSH keys to client
ssh-copy-id -i ~/.ssh/id_rsa.pub $client_user@$client_ip

# Print success message
echo "SSH keys successfully copied to server and client."

echo "**** Running ansible ****"
echo "**** Configuring server ****"
# Run server configuration ansible playbook
ansible-playbook -i inventory.ini server_config.yml

echo "**** Configuring client ****"
# Run client configuration ansible playbook
ansible-playbook -i inventory.ini "$temp_playbook"

rm "$temp_playbook"
