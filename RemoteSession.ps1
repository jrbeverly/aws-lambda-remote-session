#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.450.0'}

###############################################################
### Functions
###############################################################

Function Convert-ToHashTable( $Value ) {
    $htable = @{ }
    $Value.PSObject.Properties | foreach { $htable[$_.Name] = $_.Value }
    return $htable
}

Function Get-SnsMessageAttribute( $MessageAttributes, $Attribute ) {
    if ($MessageAttributes.ContainsKey($Attribute)) {
        return $MessageAttributes[$Attribute].Value
    }
    return $null
}

Function Get-Secret() {
    $secret = ( Get-SECSecretValue -SecretId $env:PSHELL_SECRET -VersionStage "AWSCURRENT" )
    return $secret.SecretString | ConvertFrom-Json
}

###############################################################
### Main
###############################################################

# Get the access credentials
$Secret = Get-Secret
$credential = New-Object System.Management.Automation.PSCredential (
    $Secret.Username, 
    ( ConvertTo-SecureString $Secret.Password -AsPlainText -Force )
)

# Create the new office365 powershell liveid session
$Session = New-PSSession `
    -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell-liveid `
    -Credential $credential `
    -Authentication Basic `
    -AllowRedirection

# Import the powershell session
Import-PSSession $Session -DisableNameChecking -AllowClobber

# Iterate over the SNS Records, performing some action
foreach ($snsRecord in $LambdaInput.Records) {
    $attributes = Convert-ToHashTable -Value $snsRecord.Sns.MessageAttributes

    $email = Get-SnsMessageAttribute -MessageAttributes $attributes -Attribute "email"

    $result = Get-DistributionGroup -Identity $email -ResultSize 1

    Write-Host (ConvertTo-Json -InputObject $result -Compress -Depth 5)
}

