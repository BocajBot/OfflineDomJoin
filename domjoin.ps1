# Description: This script is used to provision a computer account and create an output file for offline domain join

# Function for getting machine name
function Get-MachineName
{
    $machineName = Read-Host -Prompt 'Enter the client machine"s name'

    # If machineName is empty, reprompt for input until it is not empty
    while ([string]::IsNullOrEmpty($machineName))
    {
        $machineName = Read-Host -Prompt "Enter the client machine\'s name"
    }

    # Confirm machine name is spelt correctly. Default to 'N' if user input is empty
    $confirmMachineName = Read-Host -Prompt "Confirm machine name is $machineName (y/N)"

    # If confirmMachineName is empty, default to 'N'
    if ($confirmMachineName)
    {
        $confirmMachineName = 'N'
    }
    # If machine name is incorrect, rerun function Function
    elseif ($confirmMachineName.ToLower() -ne 'y')
    {
        Get-MachineName
    }

    return $machineName
}

# Prompt for user input
$choice = Read-Host -Prompt 'Please enter your choice ([S]erver or [C]lient)'

# Process based on user input
switch ($choice.ToLower())
{
    {@('server','s')-contains $_}
    {
        # Get Domain DNS
        $domain = $env:USERDNSDOMAIN
        $defaultHome = "$HOME\Desktop"

        # Get the client's machine name
        $machineName = Get-MachineName

        $outputFile = Read-Host -Prompt "Enter the output file path (e.g., C:\path\to\<Enter Name>.txt)[$defaultHome\$machineName.txt]"

        # If output file is empty, use default path
        if ([string]::IsNullOrEmpty($outputFile))
        {
            $outputFile = "$defaultHome\$machineName"
        }

        # Provision computer account and create output file
        & djoin.exe /provision /domain $domain /machine $machineName /savefile $outputFile
    }

    {@('client','c')-contains $_}
    {
        $machineName = $env:COMPUTERNAME+".txt"
        $inputFile = Read-Host -Prompt "Enter the input file path (e.g., C:\path\to\<Enter Name>.txt)[$HOME\Desktop\$machineName]"

        # If input file is empty, default to $HOME\Desktop\$machineName.txt
        if (-not $inputFile)
        {
            $inputFile = "$HOME\Desktop\$machineName"
        }

        # Insert computer to domain
        & djoin.exe /requestODJ /loadfile "$inputFile" /windowspath C:\Windows /localos
    }

    default
    {
        Write-Host "Invalid choice, please enter either 'Server' or 'Client'"
    }
}

