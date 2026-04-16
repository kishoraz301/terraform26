<#
.SYNOPSIS
    Deploy 4 fresh Windows Server 2022 VMs in existing RGs, VNets, and subnets
    
.DESCRIPTION
    This script deploys 4 Windows RDS/Web VMs from marketplace image
    - 2 West Europe VMs (SI-RDSWEB-VM-07, 08)
    - 2 North Europe VMs (SI-rdsweb-vm-55, 56)
    All with static private IPs and Premium SSD disks
    
.PARAMETER SubscriptionId
    Azure subscription ID
    
.EXAMPLE
    .\Deploy-4-Windows-RDS-VMs.ps1 -SubscriptionId "b3179146-e675-480d-aa38-23ec90529400"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId
)

Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

# VM Configuration - 4 Windows Server 2022 VMs (2 WE + 2 NE)
$vmDeployConfig = @(
    # West Europe - 2 VMs
    @{
        VMName = "SI-RDSWEB-VM-07"
        ResourceGroup = "si-dmz-rdsweb-we-01-rg"
        VNetName = "MIP-SI-WE-ciDMZ-vnet"
        SubnetName = "MIP-SI-WE-ciDMZ-RDS-snet"
        PrivateIP = "10.200.11.68"
        Location = "West Europe"
        VMSize = "Standard_DS2_v2"
        DiskSizeGB = 128
        DiskType = "Premium_LRS"
    },
    @{
        VMName = "SI-RDSWEB-VM-08"
        ResourceGroup = "si-dmz-rdsweb-we-01-rg"
        VNetName = "MIP-SI-WE-ciDMZ-vnet"
        SubnetName = "MIP-SI-WE-ciDMZ-RDS-snet"
        PrivateIP = "10.200.11.69"
        Location = "West Europe"
        VMSize = "Standard_DS2_v2"
        DiskSizeGB = 128
        DiskType = "Premium_LRS"
    },
    # North Europe - 2 VMs
    @{
        VMName = "SI-rdsweb-vm-55"
        ResourceGroup = "si-dmz-rdsweb-ne-01-rg"
        VNetName = "MIP-SI-NE-ciDMZ-vnet"
        SubnetName = "MIP-SI-NE-ciDMZ-RDS-snet"
        PrivateIP = "10.200.12.68"
        Location = "North Europe"
        VMSize = "Standard_DS2_v2"
        DiskSizeGB = 128
        DiskType = "Premium_LRS"
    },
    @{
        VMName = "SI-rdsweb-vm-56"
        ResourceGroup = "si-dmz-rdsweb-ne-01-rg"
        VNetName = "MIP-SI-NE-ciDMZ-vnet"
        SubnetName = "MIP-SI-NE-ciDMZ-RDS-snet"
        PrivateIP = "10.200.12.69"
        Location = "North Europe"
        VMSize = "Standard_DS2_v2"
        DiskSizeGB = 128
        DiskType = "Premium_LRS"
    }
)

# Admin credentials
$adminUsername = "azureadmin"
$adminPassword = ConvertTo-SecureString -String "P@ssw0rd123!Azure" -AsPlainText -Force
$adminCred = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $output = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "SUCCESS" { Write-Host $output -ForegroundColor Green }
        "ERROR" { Write-Host $output -ForegroundColor Red }
        "WARNING" { Write-Host $output -ForegroundColor Yellow }
        default { Write-Host $output -ForegroundColor Cyan }
    }
}

function New-WindowsNetworkInterface {
    param([string]$NicName, [string]$ResourceGroup, [string]$VNetName, [string]$SubnetName, [string]$PrivateIP, [string]$Location)
    
    try {
        Write-Log "Creating network interface: $NicName"
        $vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroup
        $subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $vnet
        $nicConfig = New-AzNetworkInterfaceIpConfig -Name "ipconfig1" -PrivateIpAddress $PrivateIP -Subnet $subnet
        $nic = New-AzNetworkInterface -Name $NicName -ResourceGroupName $ResourceGroup -Location $Location -IpConfiguration $nicConfig
        Write-Log "Network interface created: $($nic.Id)" SUCCESS
        return $nic.Id
    }
    catch {
        Write-Log "Error creating network interface: $_" ERROR
        throw
    }
}

function Deploy-WindowsVM {
    param(
        [string]$VMName,
        [string]$ResourceGroup,
        [string]$Location,
        [string]$VMSize,
        [string]$NicId,
        [PSCredential]$AdminCred,
        [int]$DiskSizeGB,
        [string]$DiskType
    )
    
    try {
        Write-Log "Creating VM: $VMName (Size: $VMSize, Disk: ${DiskSizeGB}GB, Type: $DiskType)"
        
        # Create VM config
        $vm = New-AzVMConfig -VMName $VMName -VMSize $VMSize
        
        # Add network interface
        $vm = Add-AzVMNetworkInterface -VM $vm -Id $NicId -Primary
        
        # Set OS disk
        $vm = Set-AzVMOSDisk -VM $vm -CreateOption FromImage -DiskSizeInGB $DiskSizeGB -StorageAccountType $DiskType -Windows
        
        # Set Windows image (Windows Server 2022 Datacenter)
        $vm = Set-AzVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2022-datacenter-azure-edition" -Version "latest"
        
        # Set admin credentials
        $vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $VMName -Credential $AdminCred -ProvisionVMAgent -EnableAutoUpdate
        
        # Deploy VM
        New-AzVM -ResourceGroupName $ResourceGroup -Location $Location -VM $vm
        Write-Log "VM deployed successfully: $VMName" SUCCESS
        return $true
    }
    catch {
        Write-Log "Error deploying VM: $_" ERROR
        throw
    }
}

# Main execution
Write-Log "========================================" INFO
Write-Log "WINDOWS RDS VM DEPLOYMENT - 4 VMs" INFO
Write-Log "========================================" INFO

$successCount = 0
$failCount = 0

foreach ($config in $vmDeployConfig) {
    Write-Log "" INFO
    Write-Log "Deploying: $($config.VMName)" INFO
    Write-Log "Resource Group: $($config.ResourceGroup) | Location: $($config.Location)" INFO
    Write-Log "VNet: $($config.VNetName) | Subnet: $($config.SubnetName) | IP: $($config.PrivateIP)" INFO
    
    try {
        # Create network interface
        $nicName = "$($config.VMName)-nic"
        $nicId = New-WindowsNetworkInterface -NicName $nicName -ResourceGroup $config.ResourceGroup -VNetName $config.VNetName -SubnetName $config.SubnetName -PrivateIP $config.PrivateIP -Location $config.Location
        
        # Deploy Windows VM
        Deploy-WindowsVM -VMName $config.VMName -ResourceGroup $config.ResourceGroup -Location $config.Location -VMSize $config.VMSize -NicId $nicId -AdminCred $adminCred -DiskSizeGB $config.DiskSizeGB -DiskType $config.DiskType
        
        Write-Log "SUCCESS: $($config.VMName) deployed successfully" SUCCESS
        $successCount++
    }
    catch {
        Write-Log "FAILED: $($config.VMName) - $_" ERROR
        $failCount++
    }
}

Write-Log "" INFO
Write-Log "========================================" INFO
Write-Log "DEPLOYMENT COMPLETE" INFO
Write-Log "Successfully deployed: $successCount" SUCCESS
Write-Log "Failed: $failCount" ERROR
Write-Log "========================================" INFO
