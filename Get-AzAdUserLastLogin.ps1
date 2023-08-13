# Import-Module AzureADPreview
# Connect-AzureAD -TenantId poshlab.xyz

# Get all users (excluding Guest and disabled accounts)
$azureAdUsers = Get-AzureADUser -Filter "AccountEnabled eq true and userType eq 'Member'" -All:$true
"Found [$($azureAdUsers.Count)] users." | Out-Default

for ($i = 0 ; $i -lt $azureAdUsers.Count ; $i++) {
    "Processing $($i+1) of $($azureAdUsers.Count): [$($azureAdUsers[$i].UserPrincipalName)]" | Out-Default
    # Filter only the successful login attempts.
    $filter = "UserId eq '$($azureAdUsers[$i].ObjectId)' and Status/ErrorCode eq 0"
    if ($signInLogs = (Get-AzureADAuditSignInLogs -Filter $filter -Top 1)) {
        "     -> OK." | Out-Default
        # Return the last login time
        [PSCustomObject]$([ordered]@{
                Name          = $azureAdUsers[$i].DisplayName
                Username      = $azureAdUsers[$i].UserPrincipalName
                LastLogInDate = (Get-Date ($signInLogs.CreatedDateTime))
            })
    }
    else {
        "     -> No login within the last 30 days." | Out-Default
    }
}
