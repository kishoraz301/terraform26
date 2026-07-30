# Azure Terraform Deployment

This project contains Terraform configuration to deploy a basic Azure infrastructure including a Linux Virtual Machine with networking components.

## Resources Deployed

| Resource | Description |
|---|---|
| Resource Group | Container for all Azure resources |
| Virtual Network | Isolated network (10.0.0.0/16 by default) |
| Subnet | Sub-network within the VNet (10.0.1.0/24 by default) |
| Network Security Group | Firewall rules allowing SSH (22), HTTP (80), and HTTPS (443) |
| Public IP | Static public IP assigned to the VM |
| Network Interface | NIC connecting the VM to the subnet |
| Linux Virtual Machine | Ubuntu 22.04 LTS Gen2 VM |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.3.0
- An active [Azure subscription](https://azure.microsoft.com/free/)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated

## Authentication

Log in to Azure using the Azure CLI before running Terraform:

```bash
az login
az account set --subscription "<your-subscription-id>"
```

## Usage

### 1. Clone and configure variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Preview the changes

```bash
terraform plan
```

### 4. Apply the configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 5. Access the VM

After deployment, use the output `vm_public_ip` to SSH into the VM:

```bash
ssh azureuser@<vm_public_ip>
```

### 6. Destroy resources

To tear down all resources and avoid ongoing costs:

```bash
terraform destroy
```

## Variables

| Variable | Description | Default |
|---|---|---|
| `resource_group_name` | Name of the Azure Resource Group | `rg-terraform-demo` |
| `location` | Azure region | `East US` |
| `environment` | Environment tag (dev/staging/prod) | `dev` |
| `vnet_address_space` | VNet address space | `["10.0.0.0/16"]` |
| `subnet_address_prefix` | Subnet address prefix | `10.0.1.0/24` |
| `vm_size` | Azure VM SKU | `Standard_B1s` |
| `admin_username` | VM admin username | `azureuser` |
| `admin_password` | VM admin password (12-72 chars, complexity required) | — |
| `ssh_public_key` | SSH public key (recommended; disables password auth when set) | `null` |
| `allowed_ssh_cidr` | Source CIDR allowed to SSH (restrict for security) | `*` |
| `os_disk_size_gb` | OS disk size in GB | `30` |
| `tags` | Additional resource tags | `{}` |

## Outputs

| Output | Description |
|---|---|
| `resource_group_name` | Name of the created resource group |
| `resource_group_location` | Location of the resource group |
| `virtual_network_name` | Name of the virtual network |
| `subnet_id` | ID of the subnet |
| `vm_name` | Name of the virtual machine |
| `vm_public_ip` | Public IP address of the VM |
| `vm_private_ip` | Private IP address of the VM |
