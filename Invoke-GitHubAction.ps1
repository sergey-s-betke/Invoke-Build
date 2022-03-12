# Copyright © 2022 Sergei S. Betke

<#
	.SYNOPSIS
		Install InvokeBuild and run Invoke-Build
#>

[CmdletBinding()]

Param(

	# Build tasks
	[Parameter( Mandatory = $False, Position = 0 )]
	[System.String[]]
	$Task = '.',

	# Build file path
	[Parameter( Mandatory = $False, Position = 1 )]
	[System.String]
	$File = '.build.ps1',

	# InvokeBuild required version
	[Parameter( Mandatory = $False )]
	[System.String]
	$InvokeBuildVersion = 'latest'

)

Import-Module $PSScriptRoot/lib/GitHubActionsCore -Verbose:$false;

try
{
	Enter-ActionOutputGroup -Name 'Prepare repositories';
	try
	{
		Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
	}
	finally
	{
		Exit-ActionOutputGroup;
	};

	$ModuleName = 'InvokeBuild';
	Enter-ActionOutputGroup -Name "Install $ModuleName";
	try
	{
		$installModuleParams = @{ Name = $ModuleName; Force = $true };
		if ( $InvokeBuildVersion -ne 'latest' )
		{
			$Version = $InvokeBuildVersion;
			$installModParams.Add( 'RequiredVersion', $Version );
		};

		Write-ActionInfo ( 'checking for {0} module...' -f $ModuleName );

		$modules = Get-Module -ListAvailable -Name $ModuleName;
		$requiredModule = $null;
		if ( $Version )
		{
			$requiredModule = $modules | Where-Object { $_.Version -eq $Version };
		}
		else
		{
			$requiredModule = $modules | Sort-Object Version | Select-Object -Last 1;
		};

		if ( $requiredModule )
		{
			Write-ActionInfo ('{0} module version {1} already installed.' -f $requiredModule.Name, $requiredModule.Version);
		}
		else
		{
			Write-ActionInfo ( 'installing {0} module...' -f $ModuleName );
			$ProgressPreference = 'SilentlyContinue';
			$requiredModule = Install-Module @installModuleParams -PassThru;
			Write-ActionInfo ('{0} module version {1} installed.' -f $requiredModule.Name, $requiredModule.Version);
		};

		Import-Module @installModuleParams;
	}
	finally
	{
		Exit-ActionOutputGroup;
	};

	Invoke-Build `
		-File $File `
		-Task $Task `
		-Verbose:( $PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true );
}
catch
{
	Set-ActionOutput 'error' $_.ToString();
	$ErrorView = 'NormalView';
	Set-ActionFailed ($_ | Out-String);
}
exit [System.Environment]::ExitCode;
