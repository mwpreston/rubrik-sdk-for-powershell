Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Get-RubrikEvent' -Tag 'Public', 'Get-RubrikEvent' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.5'
    }
    #endregion

    Context -Name 'Results Filtering' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'name'                   = 'VirtualMachine01'
                'id'                     = 'VirtualMachine:::11111'
                'eventType'              = 'Replication'
            },
            @{ 
                'name'                   = 'VirtualMachine02'
                'id'                     = 'VirtualMachine:::22222'
                'eventType'              = 'Backup'
            },
            @{ 
                'name'                   = 'VirtualMachine03'
                'id'                     = 'VirtualMachine:::33333'
                'eventType'              = 'CloudNativeSource'
            },
            @{ 
                'name'                   = 'VirtualMachine04'
                'id'                     = 'VirtualMachine:::44444'
                'eventType'              = 'Replication'
            },
            @{ 
                'name'                   = 'VirtualMachine05'
                'id'                     = 'VirtualMachine:::55555'
                'eventType'              = 'Replication'
            }
        }
        It -Name 'Should Return count of 5' -Test {
            (Get-RubrikEvent).Count |
                Should -BeExactly 5
        }
        It -Name 'Should not run with Name parameter' -Test {
            {Get-RubrikEvent -Name doesnotexist -ErrorAction Stop} |
                Should -Throw
        }

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
}