[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true, Position=0, HelpMessage="This is the url for the web you wish to delegate workflow task")]
    [string]$siteUrl,

    [Parameter(Mandatory=$true, Position=1, HelpMessage="This is the number of the workflow task ID")]
    [int]$itemId,
    
    [Parameter(Mandatory=$true, Position=2, HelpMessage="This is the title of the workflow tasks list")]
    [string]$tasksList,

    [Parameter(Mandatory=$true, Position=3, HelpMessage="This is the login of the user to delegate")]
    [string]$userLogin,

    [Parameter(Mandatory=$true, Position=4, HelpMessage="This is the comment for the delegation")]
    [string]$comment
)

# This script must be run from the SharePoint server because it uses the local DLLs referenced below
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[System.Reflection.Assembly]::LoadWithPartialName("Nintex.Workflow")


$site = New-Object Microsoft.SharePoint.SPSite($siteUrl)
$web = $site.OpenWeb()
Write-Host `n`nConnected to $($web.url)
$list = $web.Lists[$tasksList]

#    Try {
        Write-Host `nDelegating workflow task $item.name
        $nintexTask = [Nintex.Workflow.HumanApproval.NintexTask]::RetrieveTask($itemId, $web, $list)
        $approver = $nintexTask.Approvers.GetBySPId($itemId)
        $success = [Nintex.Workflow.HumanApproval.Delegation]::DelegateApprovalTask($true, $approver, $userLogin, $false, $false, $comment, $true)
        Write-Host `nDelegation status: $success
#    }
#    Catch [System.Exception] {
#        Write-Host `nCaught error trying to delegate workflow: $($_.Message) -ForegroundColor Red
#    }

$web.Dispose()
$site.Dispose()