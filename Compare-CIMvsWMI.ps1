function Compare-WMIvsCIM
{
    [CmdletBinding()]
    Param
    (
        # Allow invocation on a remote computer, default localhost
        [Parameter(Mandatory=$true,Position=0)]
        [string]$ComputerName = 'localhost',

        # Number of iterations to run against the class. Higher int == more time.
        [Parameter(Mandatory=$false,Position=1)]
        [int]$Count = 100,

        # Class to target for WMI and CIM queries.
        [Parameter(Mandatory=$true,Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetClass
    )

    Begin
    {
        Write-Verbose "Begin..."
        Write-Verbose "Target: $ComputerName - Class: $TargetClass - Count: $Count"
        
        # I am working under the assumption that when the script is run from localhost there will be zero cases
        # for any timeout.
        
        if(!$PSBoundParameters.ContainsValue('localhost')){
            if(Test-Connection -ComputerName $ComputerName -Quiet -Count 1){
                Write-Verbose "Connection Test successful."
                continue
            }
            else{
                throw "Unable to ping $ComputerName. Please validate the machine is online."
            }
        }
        # Initialize variables for each test type to hold the averaged runtime values.
        $CIMRuntimeAverage = 0
        $WMIRuntimeAverage = 0
    }
    Process
    {
        for ($i = 1; $i -lt $Count; $i++)
            { 
                $WMIRuntime = Measure-Command {
                    Get-WmiObject -Class $TargetClass -ComputerName $ComputerName
                    }
                $CIMRuntime = Measure-Command {
                    Get-CimInstance -ClassName $TargetClass -ComputerName $ComputerName
                    }

                $WMIRuntimeAverage += $WMIRuntime.TotalMilliseconds
                $CIMRuntimeAverage += $CIMRuntime.TotalMilliseconds
            }
    }
    End
    {

        $returnObject = New-Object -TypeName psobject -Property @{'WMI Average Milliseconds'=$WMIRuntimeAverage/$Count;'CIM Average Milliseconds'=$CIMRuntimeAverage/$Count}

        return $returnObject
    }
}