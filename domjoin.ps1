# Description: This script is used to provision a computer account and create an output file for offline domain join

# First Parameter: Server or Client
$choice = %1

# Process based on user input
switch ($choice.ToLower())
{
    {@('server','s')-contains $_}
    {
        # Get Domain DNS
        $domain = $env:USERDNSDOMAIN
        $defaultHome = "$HOME\Desktop"

        # Get the client's machine name Paramerter 2
        $machineName = %2

        $outputFile = "$defaultHome\$machineName"

        # Provision computer account and create output file
        & djoin.exe /provision /domain $domain /machine $machineName /savefile $outputFile
    }

    {@('client','c')-contains $_}
    {
        $machineName = $env:COMPUTERNAME+".txt"
        $inputFile = "$HOME\Desktop\$machineName"

        # Insert computer to domain
        & djoin.exe /requestODJ /loadfile "$inputFile" /windowspath C:\Windows /localos
    }

    default
    {
        Write-Host "Invalid choice, please enter either 'Server' or 'Client'"
    }
}

