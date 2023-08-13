# Import-Module Microsoft.Graph.Authentication
# Connect-MgGraph -Scopes "User.Read.All"


# Import the required module
Import-Module Microsoft.Graph.Users

# Get all users (excluding Guest and disabled accounts)
Get-MgUser -Filter "AccountEnabled eq true and UserType eq 'Member'" -ErrorAction Stop -Property `
    'DisplayName', 'UserPrincipalName', 'SignInActivity' -Top 3 |
Select-Object `
@{n = 'Name' ; e = { $_.DisplayName } },
@{n = 'Username' ; e = { $_.UserPrincipalName } },
@{n = 'LastLoginDate'; e = {
        $(
            if (!$_.SignInActivity.LastSignInDateTime) {
                # If no LastSignInDateTime value, set to $null
                $null
            }
            else {
                $_.SignInActivity.LastSignInDateTime
            }
        )
    }
}
