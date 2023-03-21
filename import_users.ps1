param (
    [Parameter(Mandatory=$true)]
    [string]$CsvFilePath,
    [Parameter(Mandatory=$true)]
    [string]$OrganizationalUnit
)

Import-Module ActiveDirectory

# Read the CSV file
$csvUsers = Import-Csv -Path $CsvFilePath

# Get the "FE" Organizational Unit
$ou = Get-ADOrganizationalUnit -Filter {Name -eq $OrganizationalUnit}

if ($ou -eq $null) {
    Write-Host "Organizational Unit '$OrganizationalUnit' not found."
    exit
}

# Get all users from the "FE" Organizational Unit
$adUsers = Get-ADUser -Filter * -SearchBase $ou.DistinguishedName -Properties Enabled

# Create a hashtable to store the AD users for faster lookup
$adUsersLookup = @{}
foreach ($adUser in $adUsers) {
    $adUsersLookup[$adUser.SamAccountName] = $adUser
}

foreach ($csvUser in $csvUsers) {
    $username = $csvUser.sAMAccountName
    $firstName = $csvUser.givenName
    $lastName = $csvUser.surname
    $password = $csvUser.passwordProfile
    $displayName = $csvUser.displayName
    $upn = $csvUser.userPrincipalName
    $jobTitle = $csvUser.jobTitle
    $department = $csvUser.department

    if ($adUsersLookup.ContainsKey($username)) {
        Write-Host "User $username exists in Active Directory."
    }
    else {
        Write-Host "Creating user $username in Active Directory & assigning licenses..."
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        New-ADUser -Name $displayName -DisplayName $displayName -SamAccountName $username -UserPrincipalName $upn -GivenName $firstName -Surname $lastName -Title $jobTitle -Department $department -Enabled $True -AccountPassword $(ConvertTo-SecureString $password -AsPlainText -Force) -Path "OU=FE,OU=Pretendco Users,DC=corp,DC=pretendco,DC=com"
        Add-ADGroupMember -Identity "GL-SEC-Azure-Lic" -Members $username
        Add-ADGroupMember -Identity "GL-SEC-Users-FE" -Members $username
    }
    # Remove the user from the hashtable
    $adUsersLookup.Remove($username)
}

# Disable remaining users in the hashtable
foreach ($remainingAdUser in $adUsersLookup.Values) {
    if ($remainingAdUser.Enabled -eq $true) {
        Write-Host "Disabling user $($remainingAdUser.SamAccountName) & removing active licenses..."
        Set-ADUser -Identity $remainingAdUser -Enabled $false
        Remove-ADGroupMember -Identity "GL-SEC-Azure-Lic" -Members $username
        Remove-ADGroupMember -Identity "GL-SEC-Users-FE" -Members $username
    }
}

