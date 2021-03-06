#requires -Version 3
function Set-RubrikVolumeFilterDriver
{
  <#  
      .SYNOPSIS
      Used to Install or Uninstall the Rubrik Volume Filter Driver on a registered Windows host.

      .DESCRIPTION
      The Set-RubrikVolumeFilterDriver either installs or uninstalls the Rubrik Volume Filter Driver on a host registered to a Rubrik cluster

      .NOTES
      Written by Mike Preston for community usage
      Twitter: @mwpreston
      GitHub: mwpreston

      .LINK
      http://rubrikinc.github.io/rubrik-sdk-for-powershell/reference/Set-RubrikVolumeFilterDriver.html

      .EXAMPLE
      Set-RubrikVolumeFilterDriver -Id 'Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443' -Install
      This will install the Volume Filter Driver on the host with an id of Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443
      
      .EXAMPLE
      Get-RubrikHost -Name server01 -DetailedObject | Set-RubrikVolumeFilterDriver -Remove
      This will remove the Volume Filter Driver on the host named server01
      
      .EXAMPLE
      Set-RubrikVolumeFilterDriver -hostId Host:::a1e1004c-f460-4ac1-a25a-e07b5eb15443, Host:::a1e1043c-f460-4ac1-a25a-e07b5eh45583 -Install
      This will install the Volume Filter Driver on the specifed array of host ids

      .EXAMPLE
      Get-RubrikHost -DetailedObject | Where hostVfdDriverState -ne Installed | Set-RubrikVolumeFilterDriver -Install
      Install Volume Filter Drivers for all hosts where the driver currently is not installed

      .EXAMPLE
      Get-RubrikHost -DetailedObject | Where hostVfdDriverState -eq Installed | Set-RubrikVolumeFilterDriver -Remove
      Uninstall Volume Filter Drivers for all hosts where the driver currently is not installed

  #>

   [CmdletBinding(SupportsShouldProcess = $true,ConfirmImpact = 'High')]
  Param(
    # Rubrik's host id value
    [Parameter(
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
    [Alias('hostids','id')]
    [String[]]$hostid,
    # Installs the volume filter driver
    [Parameter(ParameterSetName='Install')]
    [switch]$Install,
    # Removes the volume filter driver if installed
    [Parameter(ParameterSetName='Remove')]
    [switch]$Remove,
    # Rubrik server IP or FQDN
    [String]$Server = $global:RubrikConnection.server,
    # API version
    [ValidateNotNullorEmpty()]
    [String]$api = $global:RubrikConnection.api
  )
    Begin {

    # The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
    # If a command needs to be run with each iteration or pipeline input, place it in the Process section
    
    # Check to ensure that a session to the Rubrik cluster exists and load the needed header data for authentication
    Test-RubrikConnection
    
    # API data references the name of the function
    # For convenience, that name is saved here to $function
    $function = $MyInvocation.MyCommand.Name
        
    # Retrieve all of the URI, method, body, query, result, filter, and success details for the API endpoint
    Write-Verbose -Message "Gather API Data for $function"
    $resources = Get-RubrikAPIData -endpoint $function
    Write-Verbose -Message "Load API data for $($resources.Function)"
    Write-Verbose -Message "Description: $($resources.Description)"
    
    # Update PSBoundParameters for correct processing for New-BodyString
    if ($Install) {
      $PSBoundParameters.Remove('Install') | Out-Null
      $PSBoundParameters.Add('install',$true)
    } elseif ($Remove) {
      $PSBoundParameters.Remove('Remove') | Out-Null
      $PSBoundParameters.Add('install',$false)
    }
  }

  Process {

    #region One-off
    #endregion

    $uri = New-URIString -server $Server -endpoint ($resources.URI) -id $id
    $body = New-BodyString -bodykeys ($resources.Body.Keys) -parameters ((Get-Command $function).Parameters.Values)
    $result = Submit-Request -uri $uri -header $Header -method $($resources.Method) -body $body
    $result = Test-ReturnFormat -api $api -result $result -location $resources.Result
    $result = Test-FilterObject -filter ($resources.Filter) -result $result

    return $result

  } # End of process
} # End of function
