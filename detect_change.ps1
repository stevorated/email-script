
$drop = $args[0]

function DetectChanges () {
    Write-Output "[INFO]: Change detect script started on $drop folder..." | Green

    try {
        ScanDrop
    
        # Send-Email -To "garbers8@gmail.com" -Subject "Testing" -Body "bla bla bla..."
        Send-Gmail -To "garbers8@gmail.com"
    }
    catch {
        Write-Error $Error[0]
    }
    
    Write-Output "[INFO]: Change detect script done!" | Green      
}

function ScanDrop() {
    Write-Output "[INFO]: Getting drop..."

    # copy new to old
    Get-Content .\temp\drop.txt | Out-File .\temp\old_drop.txt

    # create new drop file
    Get-ChildItem -Recurse "$drop" | Select-Object -ExpandProperty FullName | Out-File .\temp\drop.txt
    
    # fetch drop files
    $old_drop_file = Get-Content .\temp\old_drop.txt
    $drop_file = Get-Content .\temp\drop.txt
    
    # compare diff
    Write-Output "[INFO]: Comparing diffs..."
    $diff = Compare-Object $old_drop_file $drop_file

    # if there's a difference create a diff file for email attachment list
    if ($diff) {
        Write-Output "Differences detected" | Green

        # loop ever diffrences send an email on each new file 
        # TODO handle deletes and renames
        ForEach ($grp in $diff) {
            if ($grp.SideIndicator -eq "<=") {     
                # Do Something here
                Write-Output "- $($grp.InputObject)" | Red
            }
            else {
                Write-Output "+ $($grp.InputObject)" | Green
                # send email with file attachment
                Add-Content .\temp\diff.txt "$($grp.InputObject)`n"
                # Send-Email -To "garbers8@gmail.com" -Subject "Testing..." -Body "did this work?!"
            }
        }
    }
    else {
        Write-Output "[INFO]: Differences NOT detected" | Blue
    }
}

function Send-Gmail() {
    param(
        [Parameter(mandatory = $true)][string]$To
    )

    try {
        $diff_file = Get-Content .\temp\diff.txt -ErrorAction stop
        # run python script with $diff_files as attached files
        foreach ($file in $diff_file) {
            Write-Output $file
            if($file.Length) {
                python send_email.py $To $file $drop   
            }
        }
    
        Remove-Item -Path .\temp\diff.txt -ErrorAction stop

    } catch {
        # Write-Error $Error[0]
    }

}

function Green {
    process { Write-Host $_ -ForegroundColor Green }
}

function Blue {
    process { Write-Host $_ -ForegroundColor Blue }
}

function Red {
    process { Write-Host $_ -ForegroundColor Red }
}

DetectChanges