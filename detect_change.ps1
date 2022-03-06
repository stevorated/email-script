
$drop = $args[0]

function DetectChanges () {
    Write-Output "[INFO]: Change detect script started on $drop folder..." | Green

    try {
        Get-Drop
    
        # Send-Email -To "garbers8@gmail.com" -Subject "Testing" -Body "bla bla bla..."
        Send-Gmail -To "garbers8@gmail.com"
    }
    catch {
        Write-Error $Error[0]
    }
    
    Write-Output "[INFO]: Change detect script done!" | Green      
}

function Get-Drop() {
    Write-Output "[INFO]: Getting drop..."

    # copy new to old
    Get-Content .\drop.txt | Out-File .\old_drop.txt

    # create new drop file
    Get-ChildItem -Recurse "$drop" | Select-Object -ExpandProperty FullName | Out-File .\drop.txt
    
    # fetch drop files
    $old_drop_file = Get-Content .\old_drop.txt
    $drop_file = Get-Content .\drop.txt
    
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
                Add-Content .\diff.txt "$($grp.InputObject)`n"
                # Send-Email -To "garbers8@gmail.com" -Subject "Testing..." -Body "did this work?!"
            }
        }
    }
    else {
        Write-Output "[INFO]: Differences NOT found" | Blue
    }
}

function Send-Gmail() {
    param(
        [Parameter(mandatory = $true)][string]$To
    )

    try {
        $diff_file = Get-Content .\diff.txt -ErrorAction stop
        # run python script with $diff_files as attached files
        foreach ($file in $diff_file) {
            Write-Output $file
            if($file.Length) {
                python send_email.py $To $file    
            }
        }
    
        Remove-Item -Path .\diff.txt -ErrorAction stop

    } catch {
        # Write-Error $Error[0]
    }

}

function Send-Email() {
    param(
        [Parameter(mandatory = $true)][string]$To,
        [Parameter(mandatory = $true)][string]$Subject,
        [Parameter(mandatory = $true)][string]$Body
    )

    try {
        # check for diff file created by Get-Drop
        $diff_file = Get-Content .\diff.txt -ErrorAction stop

        # if diff file exists (found new changes or handling remaining diff file)

        # get user creds
        $username = (Get-Content -Path "C:\Users\garbe\projects\email_script\creds")[0]
        $password = (Get-Content -Path "C:\Users\garbe\projects\email_script\creds")[1] | ConvertTo-SecureString -AsPlainText -Force
    
        # Write-Output "username: $username pass: $password"
        # Write-Output "To: $To"
        # Write-Output "Subject: $Subject"
        # Write-Output "Body: $Body"
        # Write-Output $diff_file
    
        $email = @{
            from       = $username
            to         = $To
            subject    = $Subject
            smtpserver = "smtp.gmail.com"
            body       = $Body
            credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
            usessl     = $true
            verbose    = $true
        }
    
        Send-MailMessage @email -ErrorAction stop
    
        Remove-Item -Path .\diff.txt -ErrorAction stop
    }
    catch {
        Write-Warning "$($Error[0]) Not Sending Email"
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