#!/usr/bin/env pwsh
Import-Module $PSScriptRoot/lib/GitHubActionsCore;

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
		$VersionParam = ( Get-ActionInput 'version' );
		if ( $VersionParam -and ( $VersionParam -ne 'latest' ) )
		{
			$Version = $VersionParam;
		};

		if ( $Version )
		{
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

	$params = @{ };

	$fileParam = ( Get-ActionInput -Name 'file' );
	if ( $fileParam )
	{
		$params.Add( 'File', $fileParam );
	};
	$taskParam = ( Get-ActionInput -Name 'task' );
	if ( $taskParam )
	{
		$params.Add( 'Task', $taskParam );
	};

	$verboseParam = ( Get-ActionInput -Name 'verbose' );
	if ( -not ( $verboseParam -and ( $verboseParam -ne 'true' ) ) )
	{
		$params.Add( 'Verbose', $true );
	};

	Invoke-Build @$params;
}
catch
{
	Set-ActionOutput 'error' $_.ToString();
	$ErrorView = 'NormalView';
	Set-ActionFailed ($_ | Out-String);
}
exit [System.Environment]::ExitCode;
