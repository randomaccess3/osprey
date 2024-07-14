﻿<#
.DESCRIPTION
    Tenant Azure Active Directory Administrator export. Reviewing administrator access is key to knowing who can make changes
    to the tenant and conduct other administrative actions to users and applications.
.OUTPUTS
    EntraIDAdministrators.csv
    EntraIDAdministrators.json
#> #conf 7/13
Function Get-OspreyTenantEntraAdmins {
    Out-LogFile "Gathering Entra ID Administrators"
    Send-AIEvent -Event "CmdRun"

    $roles = foreach ($role in Get-MgDirectoryRole) {
        $admins = (Get-MgDirectoryRoleMemberAsUser -DirectoryRoleId $role.Id).userprincipalname
        if ([string]::IsNullOrWhiteSpace($admins)) {
            [PSCustomObject]@{
                AdminGroupName = $role.DisplayName
                Members        = "No Members"
            }
        }
        foreach ($admin in $admins) {
            [PSCustomObject]@{
                AdminGroupName = $role.DisplayName
                Members        = $admin
            }
        }
    }
    $roles | Out-MultipleFileType -FilePrefix "EntraIDAdministrators" -csv -json

    Out-LogFile "Completed exporting Entra ID Admins"
}