@{
	# Script module or binary module file associated with this manifest
	RootModule         = 'Osprey.psm1'
	
	# Version number of this module.
	ModuleVersion      = '1.0.0'
	
	# ID used to uniquely identify this module
	GUID               = '4fe88c1a-f34f-4146-b566-259a7aa73558'
	
	# Author of this module
	Author             = 'Damien Miller-McAndrews'
	
	# Company or vendor of this module
	CompanyName        = 'Leverage Cyber Solutions'
	
	# Copyright statement for this module
	Copyright          = 'Copyright (c) 2024 Damien Miller-McAndrews'
	
	# Description of the functionality provided by this module
	Description        = 'Microsoft 365 Incident Response and Threat Hunting PowerShell tool.
    Osprey is designed to ease the burden on M365 administrators who are performing Cloud forensic tasks for their organization.
    It accelerates the gathering of data from multiple sources in the service that be used to quickly identify malicious presence and activity.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion  = '5.0'
	
	# Modules that must be imported into the global environment prior to importing this module
	RequiredModules    = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.9.310' },
		@{ModuleName = 'PSAppInsights'; ModuleVersion = '0.9.6' },
		@{ModuleName = 'ExchangeOnlineManagement'; ModuleVersion = '3.4.0' },
		@{ModuleName = 'Microsoft.Graph.Authentication'; ModuleVersion = '2.19.0' },
		@{ModuleName = 'Microsoft.Graph.Identity.DirectoryManagement'; ModuleVersion = '2.19.0' },
		@{ModuleName = 'Microsoft.Graph.Applications'; ModuleVersion = '2.19.0' },
		@{ModuleName = 'Microsoft.Graph.Users'; ModuleVersion = '2.19.0' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('bin\System.Net.IPNetwork.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# Expensive for import time, no more than one should be used.
	# TypesToProcess = @('xml\Osprey.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module.
	# Expensive for import time, no more than one should be used.
	# FormatsToProcess = @('xml\Osprey.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport  = 'Show-OspreyHelp',
	'Start-Osprey',
	'Update-OspreyModule',
	'Get-OspreyMessageHeader',
	'Get-OspreyTenantConfiguration',
	'Get-OspreyTenantDomainActivity',
	'Get-OspreyTenantEDiscoveryConfiguration',
	'Get-OspreyTenantEDiscoveryLogs',
	'Get-OspreyTenantEntraAdmins',
	'Get-OspreyTenantEntraUsers',
	'Get-OspreyTenantExchangeAdmins',
	'Get-OspreyTenantExchangeLogs',
	'Start-OspreyTenantInvestigation',
	'Get-OspreyTenantAppAndSPNCredentialDetails',
	'Get-OspreyTenantAuthHistory',
	'Get-OspreyTenantInboxRules',
	'Get-OspreyTenantMailItemsAccessed',
	'Search-OspreyTenantActivityByIP',
	'Get-OspreyUserAuthHistory',
	'Get-OspreyUserAutoReply',
	'Get-OspreyUserConfiguration',
	'Get-OspreyUserDevices',
	'Get-OspreyUserEmailActivity',
	'Get-OspreyUserEmailForwarding',
	'Get-OspreyUserInboxRule',
	'Get-OspreyUserMessageTrace',
	'Get-OspreyUserPWNCheck',
	'Start-OspreyUserInvestigation'
	
	# Cmdlets to export from this module
	CmdletsToExport    = ''

	
	# Variables to export from this module
	VariablesToExport  = ''
	
	# Aliases to export from this module
	AliasesToExport    = ''
	
	# List of all files packaged with this module
	FileList           = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData        = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @("O365","Security","Audit","Breach","Investigation","Exchange","EXO","Compliance","Logon","M365","Incident-Response","Solarigate","HAWK")
    
            # A URL to the license for this module.
            LicenseUri = 'https://github.com/syne0/Osprey/LICENSE'
    
            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/syne0/Osprey'
    
            # A URL to an icon representing this module.
            IconUri = 'https://cybercorner.tech/osprey.png'
    
            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/syne0/Osprey/Osprey/changelog.md'
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}