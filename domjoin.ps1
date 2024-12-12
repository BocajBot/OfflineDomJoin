# Description: This script is used to provision a computer account and create an output file for offline domain join.

function Get-MachineName {
    # Prompt user for machine name
    $machineName = Read-Host -Prompt 'Enter the client machine"s name'

    while ([string]::IsNullOrEmpty($machineName)) {
        Write-Host "Machine name cannot be empty. Please try again."
        $machineName = Read-Host -Prompt "Enter the client machine's name"
    }

    # Confirm machine name is spelt correctly
    do {
        $confirmMachineName = Read-Host -Prompt "Confirm machine name is $machineName (y/N)"
        if ([string]::IsNullOrEmpty($confirmMachineName)) {
            Write-Host "Please respond with either 'Y' or 'N'."
        } elseif ($confirmMachineName.ToLower() -ne 'y') {
            throw "Invalid response. Please try again."
        }
    } until ($confirmMachineName.ToLower() -eq 'y')

    return $machineName
}

# Prompt user for choice (Server or Client)
do {
    $choice = Read-Host -Prompt 'Please enter your choice ([S]erver or [C]lient)'
} until (@('server', 's', 'client', 'c') -contains $choice.ToLower())

switch ($choice.ToLower()) {
    {'server', 's'}.Contains($_) {
        # Get Domain DNS
        $domain = $env:USERDNSDOMAIN
        $defaultHome = "$HOME\Desktop"

        try {
            # Get the client's machine name
            $machineName = Get-MachineName

            # Prompt user for output file path
            $providedPath = Read-Host -Prompt "Enter the output file path (e.g., C:\path\to\<Enter Name>.txt) [$defaultHome\$machineName.txt]"
            if ([string]::IsNullOrEmpty($providedPath)) {
                $outputFile = "$defaultHome\$machineName.txt"
            } else {
                $outputFile = $providedPath
            }

            # Provision computer account and create output file
            & djoin.exe /provision /domain $domain /machine $machineName /savefile $outputFile

            Write-Host "Output file created successfully."
        } catch {
            Write-Host "An error occurred: $($Error[0].Message)"
        }
    }

    {'client', 'c'}.Contains($_) {
        # Get the client's machine name
        $machineName = $env:COMPUTERNAME

        try {
            # Prompt user for input file path
            $providedPath = Read-Host -Prompt "Enter the input file path (e.g., C:\path\to\<Enter Name>.txt) [$HOME\Desktop\$($machineName).txt]"
            if ([string]::IsNullOrEmpty($providedPath)) {
                $inputFile = "$HOME\Desktop\$($machineName).txt"
            } else {
                $inputFile = $providedPath
            }

            # Insert computer to domain
            & djoin.exe /requestODJ /loadfile "$inputFile" /windowspath C:\Windows /localos

            Write-Host "Computer joined successfully."
        } catch {
            Write-Host "An error occurred: $($Error[0].Message)"
        }
    }

    default {
        Write-Host "Invalid choice. Please enter either 'Server' or 'Client'."
    }
}
