﻿



Write-Host "What woud you like to do"
Write-Host "   A) Collect new Baseline?"
Write-Host "   B) Begin monitoring files with saved Baseline?"
Write-Host ""

  $response = Read-Host -Prompt "Please enter 'A' or 'B'"
  Write-Host ""

  function calculate-File-Hash($filepath) {
        $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
       return $filehash

  }
   
 Function Erase-Baseline-If-Already-Exists() {
        $baselineExusts = Test-Path -Path .\baseline.txt

        if($baselineExusts){
        #Delete it
        Remove-Item -Path .\baseline.txt

        }
 }

if($response -eq "A".ToUpper()) {
    # Delete baseline.txt if it already exists
    Erase-Baseline-If-Already-Exists

   # calculate h ash from the target files and store in baseline.txt

   #collect all files in the target folder
   $files = Get-ChildItem -Path .\Files
   

   #For each file. calculate the hash,and write to baseline.txt
   foreach ($f in $files) {
       $hash = calculate-File-Hash $f.FullName
       "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
   }

   

   #Write-Host "Calculate Hashes, make new baseline.txt" -ForegroundColor Cyan

}elseif ($response -eq "B".ToUpper()){

    $fileHashDictionary = @{}
    
    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathesAndHashes = Get-Content -Path .\baseline.txt
    

    foreach ($f in $filePathesAndHashes) {
        $fileHashDictionary.Add($f.Split("|")[0],$f.Split("|")[1])
    }

    #$fileHashDictionary

    # Begin (continuously) monitoring files with saved baseline
    while ($true) {
            Start-Sleep -Seconds 1
           
           $files = Get-ChildItem -Path .\Files
   

   #For each file. calculate the hash,and write to baseline.txt
   foreach ($f in $files) {
       $hash = calculate-File-Hash $f.FullName
      # "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append

      if($fileHashDictionary[$hash.Path] -eq $null){
            #A new file has been created..!
            Write-Host "$($hash.Path) has been created!" -ForegroundColor Green
           

      }elseif ($fileHashDictionary[$hash.Path] -ne $null) {

            # Notify if a new file has been changed..

            if($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                #The file has not changed

            }else {
                    # File has been compromised!, notify the user
                    Write-Host "$($hash.Path) has changed!!" -ForegroundColor Yellow 
             
            }

      }

      
   }

   
      foreach ($key in $fileHashDictionary.keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                #one of the baseline files must have been deleted, notify the user

                Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray

            }
      }

    }

}