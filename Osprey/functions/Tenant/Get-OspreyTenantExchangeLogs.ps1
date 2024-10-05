<#
.DESCRIPTION
    Searches the Exchange admin audit logs for a number of possible bad actor activities.
    * New/modified/deleted inbox rules
    * Changes to user forwarding configurations
    * Changes to user mailbox permissions
    * Granting of impersonation rights
    * RBAC changes
.OUTPUTS
    New_Inboxrule.csv
    _Investigate_New_Inboxrule
    Set_InboxRule.csv
    Remove_InboxRules.csv
    Forwarding_Changes.csv
    Impersonation_Roles.csv / Impersonation_Roles.json / Impersonation_Roles.xml
    Impersonation_Rights.csv / Impersonation_Rights.json / Impersonation_Rights.xml
    RBAC_Changes.csv / RBAC_Changes.json / RBAC_Changes.xml
#> 
Function Get-OspreyTenantExchangeLogs {

    Test-EXOConnection
    Test-GraphConnection
    $InformationPreference = "Continue"

    Out-Logfile "Searching Unified Audit Log for Exchange-related activities."

    # Make sure our values are null
    $TenantNewInboxRules = $Null
    $TenantSetInboxRules = $Null
    $TenantRemoveInboxRules = $Null

    Out-LogFile "Searching for ALL Inbox Rules Created, Modified, or Deleted during the investigation period." -action

    ##Search for the creation of ANY inbox rules##

    $TenantNewInboxRules = Get-AllUnifiedAuditLogEntry -UnifiedSearch ("Search-UnifiedAuditLog -Operations New-InboxRule")

    # If null we found no rules
    if ($null -eq $TenantNewInboxRules) {
        Out-LogFile "No Inbox Rules created during the investigation period found."
    }
    # If not null then we must have found some events so flag them
    else {
        Out-LogFile "New inbox rules have been found"
        # Go thru each rule and prepare it to output to CSV

        $NewRuleReport = foreach ($rule in $TenantNewInboxRules) {
            #throwing all new inbox rules created into custom object
            $rule1 = $rule.auditdata | ConvertFrom-Json
            [PSCustomObject]@{
                CreationTime               = $rule1.CreationTime
                Id                         = $rule1.id
                Operation                  = $rule1.Operation
                UserID                     = $rule1.UserID
                ClientIP                   = $rule1.ClientIP
                RuleName                   = $rule1.Parameters | Where-Object name -eq name | Select-Object -expandproperty value
                SentTo                     = $rule1.Parameters | Where-Object name -eq SentTo | Select-Object -expandproperty value
                ReceivedFrom               = $rule1.Parameters | Where-Object name -eq From | Select-Object -expandproperty value
                FromAddressContains        = $rule1.Parameters | Where-Object name -eq FromAddressContains | Select-Object -expandproperty value
                MoveToFolder               = $rule1.Parameters | Where-Object name -eq MoveToFolder | Select-Object -expandproperty value
                MarkAsRead                 = $rule1.Parameters | Where-Object name -eq MarkAsRead | Select-Object -expandproperty value
                DeleteMessage              = $rule1.Parameters | Where-Object name -eq DeleteMessage | Select-Object -expandproperty value
                SubjectContainsWords       = $rule1.Parameters | Where-Object name -eq SubjectContainsWords | Select-Object -expandproperty value
                SubjectOrBodyContainsWords = $rule1.Parameters | Where-Object name -eq SubjectOrBodyContainsWords | Select-Object -expandproperty value
                ForwardTo                  = $rule1.Parameters | Where-Object name -eq ForwardTo | Select-Object -expandproperty value
            }
        }
        $NewRuleReport | Out-MultipleFileType -fileprefix "New_InboxRule" -csv

        #sus rule investigation
        $InvestigateLog = @()
        Foreach ($rule in $NewRuleReport) {

            #comparison, call function
            $investigate = Compare-SusInboxRule -InboxRule $rule
            #if the function call returns true
            #doing it this exact way probably isnt best practice but it works sooooo idc
            if ($Investigate -eq $true) {
                $InvestigateLog += $rule
                Out-LogFile ("Possible Investigate inbox rule found! ID:" + $rule.Id) -notice
            }
        }

        #if investigation-worthy rules were found, output those to csv.
        if ($InvestigateLog.count -gt 0) {
            $InvestigateLog | Out-MultipleFileType -fileprefix "_Investigate_New_InboxRule" -csv -notice
        }
    }


    ##Search for the Modification of ANY inbox rules##

    $TenantSetInboxRules = Get-AllUnifiedAuditLogEntry -UnifiedSearch ("Search-UnifiedAuditLog -Operations Set-InboxRule")

    # If null we found no rules modified
    if ($null -eq $TenantSetinboxRules) {
        Out-LogFile "No Inbox Rules modified during the investigation period found."
    }
    # If not null then we must have found some events so flag them
    else {
        Out-LogFile "Modified inbox rules have been found"
        # Go thru each rule and prepare it to output to CSV

        $SetRuleReport = foreach ($rule in $TenantSetInboxRules) {
            #throwing all edited inbox rules created into custom object
            $rule1 = $rule.auditdata | ConvertFrom-Json
            [PSCustomObject]@{
                CreationTime               = $rule1.CreationTime
                Id                         = $rule1.id
                Operation                  = $rule1.Operation
                UserID                     = $rule1.UserID
                ClientIP                   = $rule1.ClientIP
                RuleName                   = $rule1.Parameters | Where-Object name -eq name | Select-Object -expandproperty value
                SentTo                     = $rule1.Parameters | Where-Object name -eq SentTo | Select-Object -expandproperty value
                ReceivedFrom               = $rule1.Parameters | Where-Object name -eq From | Select-Object -expandproperty value
                FromAddressContains        = $rule1.Parameters | Where-Object name -eq FromAddressContains | Select-Object -expandproperty value
                MoveToFolder               = $rule1.Parameters | Where-Object name -eq MoveToFolder | Select-Object -expandproperty value
                MarkAsRead                 = $rule1.Parameters | Where-Object name -eq MarkAsRead | Select-Object -expandproperty value
                DeleteMessage              = $rule1.Parameters | Where-Object name -eq DeleteMessage | Select-Object -expandproperty value
                SubjectContainsWords       = $rule1.Parameters | Where-Object name -eq SubjectContainsWords | Select-Object -expandproperty value
                SubjectOrBodyContainsWords = $rule1.Parameters | Where-Object name -eq SubjectOrBodyContainsWords | Select-Object -expandproperty value
                ForwardTo                  = $rule1.Parameters | Where-Object name -eq ForwardTo | Select-Object -expandproperty value
            }
        }
        $SetRuleReport | Out-MultipleFileType -fileprefix "Set_InboxRule" -csv
    }

    ##Search for the deletion of ALL Inbox Rules##

    #This kinda sucks as the remove-inboxrule record doesn't have a lot of information :c
    $TenantRemoveInboxRules = Get-AllUnifiedAuditLogEntry -UnifiedSearch ("Search-UnifiedAuditLog -Operations Remove-InboxRule")

    if ($null -eq $TenantRemoveinboxRules) {
        Out-LogFile "No Inbox Rules deleted during the investigation period found."
    }
    # If not null then we must have found some events so flag them
    else {
        Out-LogFile "Deleted inbox rules have been found"
        # Go thru each rule and prepare it to output to CSV

        $RemoveRuleReport = foreach ($rule in $TenantRemoveInboxRules) {
            #throwing all new inbox rules created into custom object
            $rule1 = $rule.auditdata | ConvertFrom-Json
            [PSCustomObject]@{
                CreationTime = $rule1.CreationTime
                Id           = $rule1.id
                Operation    = $rule1.Operation
                UserID       = $rule1.UserID
                ClientIP     = $rule1.ClientIP
                Identity     = $rule1.Parameters | Where-Object name -eq Identity | Select-Object -expandproperty value
            }
        }
        $RemoveRuleReport | Out-MultipleFileType -fileprefix "Remove_InboxRule" -csv
    }


    ##Look for changes to user forwarding##

    Out-LogFile "Searching for changes to user forwarding" -action
    # Getting records from UAL where user forwarding was changed, either enabled or disabled

    $TenantForwardingChanges = Get-AllUnifiedAuditLogEntry -UnifiedSearch ("Search-UnifiedAuditLog -Operations Set-Mailbox -FreeText ForwardingSmtpAddress")
    # If null we found forwarding changes
    if ($null -eq $TenantForwardingChanges) {
        Out-LogFile "No forwarding changes during the investigation period found."
    }
    # If not null then we must have found some events so flag them
    else {
        Out-LogFile "Forwarding changes have been found"
        # Go thru each log and prepare it to output to CSV
        $ForwardingChangeReport = Foreach ($log in $TenantForwardingChanges) {
            $log1 = $log.auditdata | ConvertFrom-Json
            [PSCustomObject]@{
                CreationTime      = $log1.CreationTime
                Id                = $log1.id
                Operation         = $log1.Operation
                UserID            = $log1.UserID
                ClientIP          = $log1.ClientIP
                ForwardingStatus  = $log1.Parameters | Where-Object name -eq DeliverToMailboxAndForward | Select-Object -expandproperty value
                ForwardingAddress = $log1.Parameters | Where-Object name -eq ForwardingSmtpAddress | Select-Object -expandproperty value
            }
        }
        $ForwardingChangeReport | Out-MultipleFileType -fileprefix "Forwarding_Changes" -csv
    }
    

    ##Look for changes to mailbox permissions##

    Out-LogFile "Searching for changes to mailbox permissions" -Action
    $TenantMailboxPermissionChanges = Get-AllUnifiedAuditLogEntry -UnifiedSearch ("Search-UnifiedAuditLog -Operations Add-MailboxPermission")

    #Expanding changes and exporting raw
    $MailboxChangesExpanded = $TenantMailboxPermissionChanges | Select-object -ExpandProperty AuditData | ConvertFrom-Json
    $MailboxChangesExpanded | Out-MultipleFileType -fileprefix "Unfiltered_Mailbox_Permission_Changes" -csv -json

    #Filtering out system changes
    $MailboxChangesFiltered = $MailboxChangesExpanded | Where-Object { $_.UserId -notlike "NT AUTHORITY\SYSTEM*" }

    if ($null -eq $MailboxChangesFiltered) {
        Out-LogFile "No permission changes during the investigation period found."
    }
    # If not null then we must have found some events so flag them
    else {
        Out-LogFile "Mailbox permission changes have been found."
        # Go thru each log and prepare it to output to CSV
        $PermissionChangesReport = foreach ($change in $MailboxChangesFiltered) {
            $TargetID = $change.Parameters | Where-Object Name -eq Identity | Select-Object -expandproperty Value
            $AccessID = $change.Parameters | Where-Object Name -eq User | Select-Object -expandproperty Value
            $TargetName = Get-MgUser -userid $TargetID -erroraction SilentlyContinue | Select-Object -ExpandProperty DisplayName
            $TargetUPN = Get-MgUser -userid $TargetID -erroraction SilentlyContinue | Select-Object -ExpandProperty UserPrincipalName
            $UserWithAccessName = Get-MgUser -userid $AccessID  -erroraction SilentlyContinue | Select-Object -ExpandProperty DisplayName
            $UserWithAccessUPN = Get-MgUser -userid $AccessID -erroraction SilentlyContinue | Select-Object -ExpandProperty UserPrincipalName
            [PSCustomObject]@{
                CreationTime       = $change.CreationTime
                ID                 = $change.Id
                Operation          = $change.Operation
                UserMakingChange   = $change.UserId
                ClientIP           = $change.ClientIP
                TargetName         = $TargetName
                TargetUPN          = $TargetUPN
                UserWithAccessName = $UserWithAccessName
                UserWithAccessUPN  = $UserWithAccessUPN
                AccessRights       = $change.Parameters | Where-Object Name -eq AccessRights | Select-Object -expandproperty Value
            }
            if ($null -in $TargetName, $TargetUPN, $UserWithAccessName, $UserWithAccessUPN) { 
                Out-Logfile ("Warning, failed to extract target or user information from record ID: " + $change.Id)
            }
        }
        $PermissionChangesReport | Out-MultipleFileType -fileprefix "Mailbox_Permission_Changes" -csv 
    }


    ##Looking for changes to impersonation access##

    Out-LogFile "Searching Impersonation Access" -action
    [array]$TenantImpersonatingRoles = Get-ManagementRoleEntry "*\Impersonate-ExchangeUser"
    $TenantImpersonatingRoles | Out-MultipleFileType -fileprefix "Impersonation_Roles" -csv -json -xml
    if ($TenantImpersonatingRoles.count -gt 1) {
        Out-LogFile ("Found " + $TenantImpersonatingRoles.count + " Impersonation Roles.  Default is 1") -notice
    }

    $Output = $null
    # Search all impersonation roles for users that have access
    foreach ($Role in $TenantImpersonatingRoles) {
        [array]$Output += Get-ManagementRoleAssignment -Role $Role.role -GetEffectiveUsers -Delegating:$false
    }
    $Output | Out-MultipleFileType -fileprefix "Impersonation_Rights" -csv -json -xml
    if ($Output.count -gt 1) {
        Out-LogFile ("Found " + $Output.count + " Users/Groups with Impersonation rights.  Default is 1") -notice
    }
    elseif ($Output.count -eq 1) {
        Out-LogFile ("Found default number of Impersonation users")
    }


    ##Look for any changes to RBAC##

    Out-LogFile "Gathering any changes to RBAC configuration" -action
    $RBACOps = ('Add-ManagementRoleEntry,Add-RoleGroupMember,New-ManagementRole,New-ManagementRoleAssignment,New-ManagementScope,New-RoleAssignmentPolicy,New-RoleGroup,Remove-ManagementRole,Remove-ManagementRoleAssignment,Remove-ManagementRoleEntry,Remove-ManagementScope,Remove-RoleAssignmentPolicy,Remove-RoleGroup,Remove-RoleGroupMember,Set-ManagementRoleAssignment,Set-ManagementRoleEntry,Set-ManagementScope,Set-RoleAssignmentPolicy,Set-RoleGroup,Update-RoleGroupMember')
    [array]$RBACChanges = Get-AllUnifiedAuditLogEntry -UnifiedSearch ("Search-UnifiedAuditLog -operations $RBACOps")

    # If there are any results push them to an output file
    if ($RBACChanges.Count -gt 0) {
        Out-LogFile ("Found " + $RBACChanges.Count + " Changes made to Roles Based Access Control") -notice
        $RBACChanges | Out-MultipleFileType -FilePrefix "RBAC_Changes" -csv -xml -json
    }
    # Otherwise report no results found
    else {
        Out-Logfile "No RBAC Changes found."
    }
}