Write-Host

Connect-PowerBIServiceAccount | Out-Null

# loop through the pipelines file to get parameters
Import-Csv "$PSScriptRoot/deployment/reports_to_copy.csv" | ForEach-Object {

    $sourceWorkspaceName = $_.SourceWorkspaceName
    $targetWorkspaceName = $_.TargetWorkspaceName
    $reportName = $_.ReportName

    $sourceWorkspace = Get-PowerBIWorkspace -Name $sourceWorkspaceName
    $targetWorkspace = Get-PowerBIWorkspace -Name $targetWorkspaceName

    Write-Host "Getting metadata for report $reportName..."
    $report = Get-PowerBIReport -WorkspaceId $sourceWorkspace.Id -Name $reportName
    $reportId = $report.Id

    Write-Host "Exporting report from source workspace to temp PBIX file..."
    New-Item -ItemType Directory -Force -Path "$PSScriptRoot/temp" | Out-Null
    $reportTempFilePath = "$PSScriptRoot/temp/$reportName.pbix"
    Export-PowerBIReport -WorkspaceId $sourceWorkspace.Id -Id $reportId -OutFile $reportTempFilePath

    Write-Host "Importing report from PBIX file into target workspace..."
    New-PowerBIReport -Path $reportTempFilePath -WorkspaceId $targetWorkspace.Id -Name $reportName -ConflictAction CreateOrOverwrite | Out-Null

    Write-Host "Deleting temp file...."
    Remove-Item -Path $reportTempFilePath

    Write-Host 
    Write-Host "Report copy operation complete"

}
