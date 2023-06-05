# Local Mail Server Project

This project provides a setup script and Ansible playbooks to create and configure a server and client machine for email services using [Postfix](https://www.postfix.org/), [Dovecot](https://www.dovecot.org/) and [Mutt](http://www.mutt.org/). The mail server allows you to send and receive emails within your local network. The following scenario is implemented: 

![scenario](https://github.com/vslemon/local_mail_server/assets/72547793/07de2ce8-4cfc-4e25-88b0-0ee7312fd011)

## Prerequisites

Before starting the setup, ensure that you have the following:

- Three machines running Ubuntu, one will be used as the ansible controller, one as the server and one as the client.
- The user running the setup script and Ansible playbooks has access to a user with sudo privileges on both the server and the client.

## Setup Script

The **setup.sh** script automates the initial setup process. It performs the following tasks:
- Prompts for server and client IP address, user, and password (existing user with sudo privileges).
- Updates the **`/etc/hosts`** file with the server and client IP addresses.
- Creates an Ansible inventory file **`inventory.ini`** with the server and client configuration.
- Replaces the placeholder server IP address in the **`client_config.yml`** playbook.
- Checks if Ansible is installed and installs it if necessary.
- Generates SSH keys and copies them to the server and client machines.
- Runs the **`server_config.yml`** playbook to configure the server.
- Runs the **`temp_client_config.yml`** playbook (generated from **`client_config.yml`**) to configure the client.
- Cleans up the temporary playbook.

## Ansible Playbooks
The repository includes two Ansible playbooks:
### Server Configuration Playbook
The **`server_config.yml`** playbook configures the server machine for email services. It performs the following tasks:

- Creates two new test users (user1 & user2) and sets their passwords.
- Creates the Maildir structure for each user.
- Configures the Postfix mailer type and domain name.
- Installs Postfix (SMTP) and Dovecot (IMAP/POP3) packages.
- Integrates Dovecot with Postfix.
- Configures Dovecot settings.
- Restarts the Postfix and Dovecot services.

### Client Configuration Playbook
The **`client_config.yml`** playbook configures the client machine for email services. It performs the following tasks:

- Creates two new test users (user1 & user2) and sets their passwords.
- Installs the Mutt email client.
- Creates and configures the **`.muttrc`** files for each user

## Usage

1. Clone the repository to your ansible controller:

   ```bash
   git clone https://github.com/vslemon/local_mail_server.git
   cd local_mail_server
   ```
2. Make the script executable and run it:

   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```
    If you don't have the right permissions:
   ```bash
   sudo chown yourUser:yourGroup setup.sh
   ```
   The setup script will prompt you to enter the server and client details, such as IP address, username, and password. 
  
3. Wait for the setup script and Ansible playbooks to complete the configuration process.
4. Log in as user1 in the client machine and run Mutt email client
   ```bash
   mutt
   ```
5. Press `a` to accept the certificate and `m` to compose a new mail to `user2@localhost.com`
6. Log in as user2 and run Mutt to open the message.

## Troubleshooting

If you encounter any issues during the setup or configuration process, please check the following:
- Verify that the server and client IP addresses, users, and passwords are entered correctly.
- Ensure that SSH access is properly set up between the local machine and the server/client machines.
- Check the Ansible playbooks for any errors or missing dependencies.
If the issue persists, please open an issue in this repository, providing details about the problem you encountered.

## IMPORTANT NOTE
This project setup creates two users, `user1` and `user2` on both server and client machines with passwords `1` and `2` respectively.
Keep in mind that this project is provided for demonstration purposes only. It may include some not-so-good security practices, such as password prompts in the script and storing passwords in plain text variables. In a production environment, it is recommended to implement more secure practices, such as using encrypted files or a password vault.
