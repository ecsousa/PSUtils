function Set-Signature {
    param(
            [Parameter(Position=0, Mandatory=$TRUE, ValueFromPipeline=$TRUE)]
            [IO.FileInfo] $file,
            [Parameter(Position=1, Mandatory=$FALSE, ValueFromPipeline=$FALSE)]
            [System.Security.Cryptography.X509Certificates.X509Certificate] $Certificate
         );

    begin {
        if(-not $Certificate) {
            $Certificate = (dir cert:currentuser\my\ -CodeSigningCert | ? { $_.Extensions } | Select-Object -First 1)
        }

        if(-not ($Certificate) ) {
            Write-Warning 'Could not find certificate for signing'
            return
        }
    }
    process {
        if($Certificate) {
            Set-AuthenticodeSignature $file -Certificate $Certificate -IncludeChain all -TimestampServer http://timestamp.verisign.com/scripts/timstamp.dll
        }
    }
}

