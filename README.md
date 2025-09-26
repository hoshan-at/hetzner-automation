# Infrastructure Project

This project uses Terraform and Ansible, managed via Docker Compose, to provision and configure cloud infrastructure.

## Prerequisites

*   Docker
*   Docker Compose

## Configuration

1.  **Add SSH Key to Hetzner Cloud:**
    For Ansible to connect to the server, its public key must be pre-installed by Terraform. 
    - Go to your **Hetzner Cloud Console** -> **Security** -> **SSH Keys**.
    - Add your public SSH key and give it a memorable name (e.g., `your-key-name-in-hetzner`).
    - Open `project/main.tf` and update the `data.hcloud_ssh_key.default.name` to match the name you just created.

2.  **Set up Environment Variables:**
    Copy the example environment file and add your Hetzner Cloud API token.
    ```bash
    cp .env.example .env
    # Now, edit .env and add your token
    ```

3.  **Add Local SSH Private Key:**
    Place the corresponding SSH **private** key into the `./ssh/` directory. The `docker-compose.yml` file mounts this directory to `/root/.ssh` inside the Ansible container.

## How Terraform and Ansible Interact

The interaction between Terraform and Ansible is designed to be simple and explicit. Terraform creates the infrastructure and then generates a file that Ansible uses to configure that same infrastructure.

Here is a step-by-step breakdown of the flow:

1.  **Terraform Provisions the Server:** When you run `terraform apply`, Terraform communicates with the Hetzner Cloud API to create a new server. During this process, it injects the public SSH key you specified.

2.  **Terraform Generates an Inventory:** After the server is successfully created, the `local_file` resource in `main.tf` is triggered. It uses a template (`inventory.tpl`) to create a static Ansible inventory file at `project/inventory/hosts`. This file contains the new server's name and IP address.

3.  **Ansible Reads the Inventory:** When you run the `ansible-playbook` command, the `-i inventory/hosts` flag tells Ansible exactly which servers to target. It reads the IP address from this file.

4.  **Ansible Connects and Configures:** Ansible uses its SSH client to connect to the server's IP. The connection is successful because:
    *   The server has the public key (installed by Terraform).
    *   The Ansible container has the private key (mounted from your local `./ssh` directory).

This one-way data flow (`Terraform -> Inventory File -> Ansible`) creates a clean separation of concerns. Terraform handles the "what" and "where" of the infrastructure, while Ansible handles the "how" of its configuration.

## Workflow

This project uses `docker compose run` to execute commands in temporary containers, ensuring a clean and stateless workflow. The `--rm` flag automatically removes the container after each command.

*   **Initialize Terraform (run once):**
    ```bash
    docker compose run --rm terraform init
    ```

*   **Apply Infrastructure:**
    ```bash
    docker compose run --rm terraform apply -auto-approve
    ```

*   **Provision Server:**
    ```bash
    docker compose run --rm ansible ansible-playbook -i inventory/hosts playbooks/provision.yml
    ```

*   **Destroy Infrastructure:**
    ```bash
    docker compose run --rm terraform destroy -auto-approve
    ```

### Interactive Shells

If you need to run other commands or debug, you can open an interactive shell directly within a new container:

*   **Terraform Shell:**
    ```bash
    docker compose run --rm terraform sh
    ```

*   **Ansible Shell:**
    ```bash
    docker compose run --rm ansible sh
    ```