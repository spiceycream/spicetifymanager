# ============================================================
# SPICETIFY MANAGER // V2
# Animated WPF Manager
# ============================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$ErrorActionPreference = "Stop"

# ============================================================
# CONFIG
# ============================================================

$SpotifyInstallerUrl = "https://download.scdn.co/SpotifySetup.exe"
$SpicetifyInstallerUrl = "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1"

$script:Accent = "#C44DFF"
$script:Accent2 = "#7C3AED"
$script:SpotifyGreen = "#1ED760"
$script:Background = "#07070B"

$script:CurrentJob = $null
$script:CurrentOperation = ""
$script:IsBusy = $false

# ============================================================
# XAML
# ============================================================

[xml]$Xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Spicetify Manager"
    Width="1180"
    Height="760"
    MinWidth="1000"
    MinHeight="650"
    WindowStartupLocation="CenterScreen"
    Background="#07070B"
    Foreground="White"
    AllowsTransparency="False"
    ResizeMode="CanResize">

    <Window.Resources>

        <!-- ================================================= -->
        <!-- COLORS -->
        <!-- ================================================= -->

        <SolidColorBrush x:Key="Panel" Color="#101017"/>
        <SolidColorBrush x:Key="Panel2" Color="#14141D"/>
        <SolidColorBrush x:Key="Border" Color="#262631"/>
        <SolidColorBrush x:Key="Muted" Color="#888894"/>
        <SolidColorBrush x:Key="Accent" Color="#C44DFF"/>
        <SolidColorBrush x:Key="Accent2" Color="#7C3AED"/>

        <!-- ================================================= -->
        <!-- BUTTON -->
        <!-- ================================================= -->

        <Style x:Key="GlassButton" TargetType="Button">
            <Setter Property="Foreground" Value="#F7F7FB"/>
            <Setter Property="Background" Value="#15151E"/>
            <Setter Property="BorderBrush" Value="#292934"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="15,11"/>
            <Setter Property="Margin" Value="0,4"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>

            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border
                            x:Name="ButtonBorder"
                            Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="11"
                            Padding="{TemplateBinding Padding}">

                            <ContentPresenter
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>

                        </Border>

                        <ControlTemplate.Triggers>

                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="Background"
                                    Value="#20202B"/>

                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="BorderBrush"
                                    Value="#8F43B8"/>
                            </Trigger>

                            <Trigger Property="IsPressed" Value="True">
                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="RenderTransform">
                                    <Setter.Value>
                                        <ScaleTransform
                                            ScaleX="0.97"
                                            ScaleY="0.97"/>
                                    </Setter.Value>
                                </Setter>
                            </Trigger>

                            <Trigger Property="IsEnabled" Value="False">
                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="Opacity"
                                    Value="0.35"/>
                            </Trigger>

                        </ControlTemplate.Triggers>

                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ================================================= -->
        <!-- SIDEBAR BUTTON -->
        <!-- ================================================= -->

        <Style x:Key="NavButton" TargetType="Button">
            <Setter Property="Foreground" Value="#A7A7B4"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="14,11"/>
            <Setter Property="Margin" Value="0,3"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/>
            <Setter Property="Cursor" Value="Hand"/>

            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">

                        <Border
                            x:Name="NavBorder"
                            Background="{TemplateBinding Background}"
                            CornerRadius="10"
                            Padding="{TemplateBinding Padding}">

                            <ContentPresenter
                                HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"
                                VerticalAlignment="Center"/>

                        </Border>

                        <ControlTemplate.Triggers>

                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter
                                    TargetName="NavBorder"
                                    Property="Background"
                                    Value="#171720"/>

                                <Setter
                                    Property="Foreground"
                                    Value="#FFFFFF"/>
                            </Trigger>

                        </ControlTemplate.Triggers>

                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- ================================================= -->
        <!-- CARD -->
        <!-- ================================================= -->

        <Style x:Key="Card" TargetType="Border">
            <Setter Property="Background" Value="#101017"/>
            <Setter Property="BorderBrush" Value="#24242F"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="CornerRadius" Value="18"/>
        </Style>

    </Window.Resources>

    <!-- ===================================================== -->
    <!-- ROOT -->
    <!-- ===================================================== -->

    <Grid>

        <!-- Ambient background -->
        <Canvas IsHitTestVisible="False">

            <Ellipse
                x:Name="Glow1"
                Width="430"
                Height="430"
                Fill="#35105A"
                Opacity="0.23"
                Canvas.Left="-170"
                Canvas.Top="-170"/>

            <Ellipse
                x:Name="Glow2"
                Width="500"
                Height="500"
                Fill="#641B86"
                Opacity="0.12"
                Canvas.Right="-220"
                Canvas.Top="70"/>

            <Ellipse
                x:Name="Glow3"
                Width="300"
                Height="300"
                Fill="#3A1D9A"
                Opacity="0.10"
                Canvas.Left="430"
                Canvas.Bottom="-180"/>

        </Canvas>

        <!-- ================================================= -->
        <!-- MAIN -->
        <!-- ================================================= -->

        <Grid Margin="18">

            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="220"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- ================================================= -->
            <!-- SIDEBAR -->
            <!-- ================================================= -->

            <Border
                Grid.Column="0"
                Style="{StaticResource Card}"
                Margin="0,0,14,0">

                <Grid Margin="16">

                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- Logo -->

                    <StackPanel Grid.Row="0">

                        <Grid Height="55">

                            <Border
                                Width="42"
                                Height="42"
                                CornerRadius="13"
                                Background="#191222"
                                HorizontalAlignment="Left">

                                <TextBlock
                                    Text="S"
                                    FontSize="24"
                                    FontWeight="Bold"
                                    Foreground="#D65CFF"
                                    HorizontalAlignment="Center"
                                    VerticalAlignment="Center"/>

                            </Border>

                            <StackPanel
                                Margin="54,3,0,0">

                                <TextBlock
                                    Text="SPICETIFY"
                                    FontSize="15"
                                    FontWeight="Bold"
                                    Foreground="White"/>

                                <TextBlock
                                    Text="MANAGER"
                                    FontSize="9"
                                    FontWeight="SemiBold"
                                    Foreground="#7E7E8D"
                                    Margin="0,1,0,0"/>

                            </StackPanel>

                        </Grid>

                        <Separator
                            Margin="0,15,0,15"
                            Background="#252530"/>

                    </StackPanel>

                    <!-- Navigation -->

                    <StackPanel Grid.Row="1">

                        <TextBlock
                            Text="WORKSPACE"
                            FontSize="9"
                            FontWeight="Bold"
                            Foreground="#666674"
                            Margin="14,0,0,7"/>

                        <Button
                            x:Name="NavDashboard"
                            Style="{StaticResource NavButton}"
                            Content="⌂   Dashboard"/>

                        <Button
                            x:Name="NavThemes"
                            Style="{StaticResource NavButton}"
                            Content="✦   Themes"/>

                        <Button
                            x:Name="NavExtensions"
                            Style="{StaticResource NavButton}"
                            Content="◇   Extensions"/>

                        <Separator
                            Margin="0,15,0,15"
                            Background="#252530"/>

                        <TextBlock
                            Text="TOOLS"
                            FontSize="9"
                            FontWeight="Bold"
                            Foreground="#666674"
                            Margin="14,0,0,7"/>

                        <Button
                            x:Name="NavRepair"
                            Style="{StaticResource NavButton}"
                            Content="↻   Repair"/>

                        <Button
                            x:Name="NavBackup"
                            Style="{StaticResource NavButton}"
                            Content="◈   Backups"/>

                        <Button
                            x:Name="NavSettings"
                            Style="{StaticResource NavButton}"
                            Content="⚙   Settings"/>

                    </StackPanel>

                    <!-- Bottom -->

                    <StackPanel Grid.Row="2">

                        <Border
                            Background="#0B0B10"
                            BorderBrush="#22222C"
                            BorderThickness="1"
                            CornerRadius="13"
                            Padding="12"
                            Margin="0,0,0,10">

                            <StackPanel>

                                <TextBlock
                                    Text="SYSTEM"
                                    FontSize="9"
                                    FontWeight="Bold"
                                    Foreground="#666674"/>

                                <StackPanel
                                    Orientation="Horizontal"
                                    Margin="0,8,0,0">

                                    <Ellipse
                                        x:Name="SystemDot"
                                        Width="8"
                                        Height="8"
                                        Fill="#777"
                                        Margin="0,0,7,0"/>

                                    <TextBlock
                                        x:Name="SystemText"
                                        Text="Checking..."
                                        FontSize="11"
                                        Foreground="#A5A5B2"/>

                                </StackPanel>

                            </StackPanel>

                        </Border>

                        <Button
                            x:Name="CloseButton"
                            Style="{StaticResource GlassButton}"
                            Content="Close Manager"/>

                    </StackPanel>

                </Grid>

            </Border>

            <!-- ================================================= -->
            <!-- CONTENT -->
            <!-- ================================================= -->

            <Grid Grid.Column="1">

                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <!-- TOP -->

                <Grid Grid.Row="0" Margin="4,2,4,16">

                    <StackPanel>

                        <TextBlock
                            Text="Good to see you."
                            FontSize="28"
                            FontWeight="Bold"/>

                        <TextBlock
                            Text="Take control of your Spotify experience."
                            FontSize="13"
                            Foreground="#7F7F8D"
                            Margin="0,4,0,0"/>

                    </StackPanel>

                    <Border
                        HorizontalAlignment="Right"
                        Background="#101017"
                        BorderBrush="#24242F"
                        BorderThickness="1"
                        CornerRadius="12"
                        Padding="12,8">

                        <StackPanel Orientation="Horizontal">

                            <Ellipse
                                x:Name="HeaderDot"
                                Width="8"
                                Height="8"
                                Fill="#777"
                                Margin="0,0,7,0"/>

                            <TextBlock
                                x:Name="HeaderStatus"
                                Text="Initializing"
                                FontSize="11"
                                Foreground="#A5A5B2"/>

                        </StackPanel>

                    </Border>

                </Grid>

                <!-- ================================================= -->
                <!-- DASHBOARD -->
                <!-- ================================================= -->

                <Grid
                    x:Name="DashboardPage"
                    Grid.Row="1">

                    <Grid.RowDefinitions>
                        <RowDefinition Height="250"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- HERO -->

                    <Border
                        Grid.Row="0"
                        Style="{StaticResource Card}"
                        ClipToBounds="True">

                        <Grid>

                            <!-- Hero glow -->

                            <Ellipse
                                Width="400"
                                Height="400"
                                Fill="#6C1B86"
                                Opacity="0.12"
                                HorizontalAlignment="Right"
                                VerticalAlignment="Center"
                                Margin="0,-130,-70,0"/>

                            <StackPanel
                                Margin="28">

                                <TextBlock
                                    Text="YOUR SPOTIFY."
                                    FontSize="11"
                                    FontWeight="Bold"
                                    Foreground="#A05BFF"/>

                                <TextBlock
                                    Text="YOUR RULES."
                                    FontSize="34"
                                    FontWeight="Bold"
                                    Margin="0,4,0,0"/>

                                <TextBlock
                                    Text="Customize, repair and manage Spicetify without touching the terminal."
                                    Width="510"
                                    TextWrapping="Wrap"
                                    FontSize="13"
                                    Foreground="#8A8A98"
                                    Margin="0,7,0,18"/>

                                <StackPanel Orientation="Horizontal">

                                    <Button
                                        x:Name="HeroInstallButton"
                                        Style="{StaticResource GlassButton}"
                                        Width="170"
                                        Content="✦  Install Spicetify"/>

                                    <Button
                                        x:Name="HeroLaunchButton"
                                        Style="{StaticResource GlassButton}"
                                        Width="150"
                                        Margin="10,4,0,4"
                                        Content="▶  Launch Spotify"/>

                                </StackPanel>

                            </StackPanel>

                            <!-- Status orb -->

                            <Grid
                                HorizontalAlignment="Right"
                                VerticalAlignment="Center"
                                Margin="0,0,50,0"
                                Width="145"
                                Height="145">

                                <Ellipse
                                    x:Name="HeroOrbGlow"
                                    Width="145"
                                    Height="145"
                                    Fill="#8D32FF"
                                    Opacity="0.08"/>

                                <Ellipse
                                    Width="105"
                                    Height="105"
                                    Fill="#12121A"
                                    Stroke="#65329A"
                                    StrokeThickness="1.5"/>

                                <TextBlock
                                    x:Name="HeroOrbText"
                                    Text="S"
                                    FontSize="55"
                                    FontWeight="Bold"
                                    Foreground="#C855FF"
                                    HorizontalAlignment="Center"
                                    VerticalAlignment="Center"/>

                            </Grid>

                        </Grid>

                    </Border>

                    <!-- CARDS -->

                    <Grid
                        Grid.Row="1"
                        Margin="0,14,0,0">

                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <!-- Spotify -->

                        <Border
                            Grid.Column="0"
                            Style="{StaticResource Card}"
                            Margin="0,0,7,0"
                            Padding="18">

                            <StackPanel>

                                <TextBlock
                                    Text="SPOTIFY"
                                    FontSize="9"
                                    FontWeight="Bold"
                                    Foreground="#6F6F7C"/>

                                <StackPanel
                                    Orientation="Horizontal"
                                    Margin="0,10,0,0">

                                    <Ellipse
                                        x:Name="SpotifyDot"
                                        Width="10"
                                        Height="10"
                                        Fill="#777"
                                        Margin="0,0,8,0"/>

                                    <TextBlock
                                        x:Name="SpotifyStatus"
                                        Text="Checking..."
                                        FontSize="14"
                                        FontWeight="SemiBold"/>

                                </StackPanel>

                                <TextBlock
                                    x:Name="SpotifyPath"
                                    Text="Searching for Spotify..."
                                    FontSize="10"
                                    Foreground="#686875"
                                    TextWrapping="Wrap"
                                    Margin="0,8,0,0"/>

                                <Button
                                    x:Name="SpotifyButton"
                                    Style="{StaticResource GlassButton}"
                                    Content="Install Spotify"
                                    Margin="0,16,0,0"/>

                            </StackPanel>

                        </Border>

                        <!-- Spicetify -->

                        <Border
                            Grid.Column="1"
                            Style="{StaticResource Card}"
                            Margin="7,0,7,0"
                            Padding="18">

                            <StackPanel>

                                <TextBlock
                                    Text="SPICETIFY CLI"
                                    FontSize="9"
                                    FontWeight="Bold"
                                    Foreground="#6F6F7C"/>

                                <StackPanel
                                    Orientation="Horizontal"
                                    Margin="0,10,0,0">

                                    <Ellipse
                                        x:Name="SpicetifyDot"
                                        Width="10"
                                        Height="10"
                                        Fill="#777"
                                        Margin="0,0,8,0"/>

                                    <TextBlock
                                        x:Name="SpicetifyStatus"
                                        Text="Checking..."
                                        FontSize="14"
                                        FontWeight="SemiBold"/>

                                </StackPanel>

                                <TextBlock
                                    x:Name="SpicetifyVersion"
                                    Text="Version: detecting..."
                                    FontSize="10"
                                    Foreground="#686875"
                                    Margin="0,8,0,0"/>

                                <Button
                                    x:Name="InstallButton"
                                    Style="{StaticResource GlassButton}"
                                    Content="Install Spicetify"
                                    Margin="0,16,0,0"/>

                            </StackPanel>

                        </Border>

                        <!-- Activity -->

                        <Border
                            Grid.Column="2"
                            Style="{StaticResource Card}"
                            Margin="7,0,0,0"
                            Padding="18">

                            <StackPanel>

                                <TextBlock
                                    Text="ACTIVITY"
                                    FontSize="9"
                                    FontWeight="Bold"
                                    Foreground="#6F6F7C"/>

                                <TextBlock
                                    x:Name="ActivityTitle"
                                    Text="Ready"
                                    FontSize="15"
                                    FontWeight="SemiBold"
                                    Margin="0,10,0,0"/>

                                <TextBlock
                                    x:Name="ActivityDescription"
                                    Text="Everything is standing by."
                                    FontSize="10"
                                    Foreground="#686875"
                                    TextWrapping="Wrap"
                                    Margin="0,7,0,0"/>

                                <ProgressBar
                                    x:Name="Progress"
                                    Height="5"
                                    Minimum="0"
                                    Maximum="100"
                                    Value="0"
                                    Margin="0,18,0,0"/>

                                <TextBlock
                                    x:Name="ProgressText"
                                    Text="0%"
                                    FontSize="9"
                                    Foreground="#777784"
                                    HorizontalAlignment="Right"
                                    Margin="0,4,0,0"/>

                            </StackPanel>

                        </Border>

                    </Grid>

                </Grid>

                <!-- ================================================= -->
                <!-- ACTIVITY CONSOLE -->
                <!-- ================================================= -->

                <Border
                    x:Name="ConsolePanel"
                    Grid.Row="1"
                    Visibility="Collapsed"
                    Style="{StaticResource Card}"
                    Padding="18">

                    <Grid>

                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                        </Grid.RowDefinitions>

                        <TextBlock
                            Text="LIVE ACTIVITY"
                            FontSize="11"
                            FontWeight="Bold"
                            Foreground="#A05BFF"
                            Margin="0,0,0,12"/>

                        <ScrollViewer
                            Grid.Row="1"
                            VerticalScrollBarVisibility="Auto">

                            <TextBox
                                x:Name="LogBox"
                                IsReadOnly="True"
                                Background="#08080C"
                                BorderThickness="0"
                                Foreground="#BDBDCA"
                                FontFamily="Cascadia Mono"
                                FontSize="11"
                                Padding="14"
                                TextWrapping="Wrap"/>

                        </ScrollViewer>

                    </Grid>

                </Border>

                <!-- ================================================= -->
                <!-- FOOTER -->
                <!-- ================================================= -->

                <Grid
                    Grid.Row="2"
                    Margin="4,12,4,0">

                    <TextBlock
                        x:Name="FooterStatus"
                        Text="Ready"
                        Foreground="#70707D"
                        VerticalAlignment="Center"/>

                    <StackPanel
                        HorizontalAlignment="Right"
                        Orientation="Horizontal">

                        <Button
                            x:Name="RepairButton"
                            Style="{StaticResource GlassButton}"
                            Width="120"
                            Content="↻ Repair"/>

                        <Button
                            x:Name="BackupButton"
                            Style="{StaticResource GlassButton}"
                            Width="120"
                            Content="◈ Backup"/>

                        <Button
                            x:Name="RestoreButton"
                            Style="{StaticResource GlassButton}"
                            Width="120"
                            Content="Restore"/>

                        <Button
                            x:Name="UpdateButton"
                            Style="{StaticResource GlassButton}"
                            Width="120"
                            Content="Update"/>

                    </StackPanel>

                </Grid>

            </Grid>

        </Grid>

    </Grid>

</Window>
"@

# ============================================================
# LOAD WINDOW
# ============================================================

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)

# ============================================================
# CONTROLS
# ============================================================

$SpotifyStatus       = $Window.FindName("SpotifyStatus")
$SpotifyPath         = $Window.FindName("SpotifyPath")
$SpotifyDot          = $Window.FindName("SpotifyDot")
$SpotifyButton       = $Window.FindName("SpotifyButton")

$SpicetifyStatus     = $Window.FindName("SpicetifyStatus")
$SpicetifyVersion    = $Window.FindName("SpicetifyVersion")
$SpicetifyDot        = $Window.FindName("SpicetifyDot")
$InstallButton       = $Window.FindName("InstallButton")

$HeroInstallButton   = $Window.FindName("HeroInstallButton")
$HeroLaunchButton    = $Window.FindName("HeroLaunchButton")
$HeroOrbText         = $Window.FindName("HeroOrbText")
$HeroOrbGlow         = $Window.FindName("HeroOrbGlow")

$Progress            = $Window.FindName("Progress")
$ProgressText        = $Window.FindName("ProgressText")

$ActivityTitle       = $Window.FindName("ActivityTitle")
$ActivityDescription = $Window.FindName("ActivityDescription")

$FooterStatus        = $Window.FindName("FooterStatus")
$HeaderStatus        = $Window.FindName("HeaderStatus")
$HeaderDot           = $Window.FindName("HeaderDot")

$SystemText          = $Window.FindName("SystemText")
$SystemDot           = $Window.FindName("SystemDot")

$LogBox              = $Window.FindName("LogBox")
$ConsolePanel        = $Window.FindName("ConsolePanel")
$DashboardPage       = $Window.FindName("DashboardPage")

$RepairButton        = $Window.FindName("RepairButton")
$BackupButton        = $Window.FindName("BackupButton")
$RestoreButton       = $Window.FindName("RestoreButton")
$UpdateButton        = $Window.FindName("UpdateButton")

$CloseButton         = $Window.FindName("CloseButton")

$NavDashboard        = $Window.FindName("NavDashboard")
$NavThemes           = $Window.FindName("NavThemes")
$NavExtensions       = $Window.FindName("NavExtensions")
$NavRepair           = $Window.FindName("NavRepair")
$NavBackup           = $Window.FindName("NavBackup")
$NavSettings         = $Window.FindName("NavSettings")

# ============================================================
# ANIMATION HELPERS
# ============================================================

function Animate-Double {
    param(
        [System.Windows.DependencyObject]$Target,
        [string]$Property,
        [double]$From,
        [double]$To,
        [int]$Duration = 500
    )

    $Animation = New-Object System.Windows.Media.Animation.DoubleAnimation

    $Animation.From = $From
    $Animation.To = $To
    $Animation.Duration = [System.Windows.Duration]::new(
        [TimeSpan]::FromMilliseconds($Duration)
    )

    $Animation.EasingFunction =
        New-Object System.Windows.Media.Animation.CubicEase

    $Animation.EasingFunction.EasingMode =
        [System.Windows.Media.Animation.EasingMode]::EaseOut

    $Target.BeginAnimation(
        [System.Windows.DependencyProperty]::FromName(
            $Property,
            $Target.GetType()
        ),
        $Animation
    )
}

function Fade-In {
    param(
        [System.Windows.UIElement]$Element,
        [int]$Duration = 500
    )

    $Element.Opacity = 0

    $Animation = New-Object System.Windows.Media.Animation.DoubleAnimation
    $Animation.From = 0
    $Animation.To = 1
    $Animation.Duration = [System.Windows.Duration]::new(
        [TimeSpan]::FromMilliseconds($Duration)
    )

    $Element.BeginAnimation(
        [System.Windows.UIElement]::OpacityProperty,
        $Animation
    )
}

function Pulse-Orb {

    $Animation = New-Object System.Windows.Media.Animation.DoubleAnimation

    $Animation.From = 0.05
    $Animation.To = 0.20

    $Animation.Duration = [System.Windows.Duration]::new(
        [TimeSpan]::FromMilliseconds(1400)
    )

    $Animation.AutoReverse = $true
    $Animation.RepeatBehavior =
        [System.Windows.Media.Animation.RepeatBehavior]::Forever

    $HeroOrbGlow.BeginAnimation(
        [System.Windows.UIElement]::OpacityProperty,
        $Animation
    )
}

# ============================================================
# LOGGING
# ============================================================

function Write-Log {
    param([string]$Message)

    $Window.Dispatcher.Invoke([Action]{

        $Timestamp = Get-Date -Format "HH:mm:ss"

        $LogBox.AppendText(
            "[$Timestamp] $Message`r`n"
        )

        $LogBox.ScrollToEnd()

    })
}

function Set-Activity {
    param(
        [string]$Title,
        [string]$Description
    )

    $ActivityTitle.Text = $Title
    $ActivityDescription.Text = $Description
    $FooterStatus.Text = $Title
}

function Set-ProgressValue {
    param([double]$Value)

    $Progress.Value = $Value
    $ProgressText.Text = "$([math]::Round($Value))%"
}

# ============================================================
# PATH REFRESH
# ============================================================

function Refresh-EnvironmentPath {

    $MachinePath =
        [Environment]::GetEnvironmentVariable(
            "Path",
            "Machine"
        )

    $UserPath =
        [Environment]::GetEnvironmentVariable(
            "Path",
            "User"
        )

    $env:Path = "$MachinePath;$UserPath"
}

# ============================================================
# SPOTIFY DETECTION
# ============================================================

function Find-Spotify {

    $Candidates = @(
        "$env:APPDATA\Spotify\Spotify.exe",
        "$env:LOCALAPPDATA\Spotify\Spotify.exe",
        "$env:ProgramFiles\Spotify\Spotify.exe",
        "${env:ProgramFiles(x86)}\Spotify\Spotify.exe",
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\SpotifyAB.SpotifyMusic_*"
    )

    foreach ($Path in $Candidates) {

        if ($Path -and (Test-Path $Path)) {

            if ((Get-Item $Path).PSIsContainer) {

                $Found = Get-ChildItem `
                    -Path $Path `
                    -Filter "Spotify.exe" `
                    -Recurse `
                    -ErrorAction SilentlyContinue |
                    Select-Object -First 1

                if ($Found) {
                    return $Found.FullName
                }

            } else {

                return (Resolve-Path $Path).Path

            }
        }
    }

    try {

        $Command = Get-Command spotify.exe `
            -ErrorAction SilentlyContinue

        if ($Command) {
            return $Command.Source
        }

    } catch {}

    return $null
}

# ============================================================
# SPICETIFY DETECTION
# ============================================================

function Find-Spicetify {

    Refresh-EnvironmentPath

    try {

        $Command = Get-Command spicetify.exe `
            -ErrorAction SilentlyContinue

        if ($Command) {
            return $Command.Source
        }

        $Command = Get-Command spicetify `
            -ErrorAction SilentlyContinue

        if ($Command) {
            return $Command.Source
        }

    } catch {}

    $Candidates = @(
        "$env:USERPROFILE\.spicetify\spicetify.exe",
        "$env:LOCALAPPDATA\spicetify\spicetify.exe",
        "$env:APPDATA\spicetify\spicetify.exe",
        "$env:ProgramFiles\Spicetify\spicetify.exe",
        "${env:ProgramFiles(x86)}\Spicetify\spicetify.exe"
    )

    foreach ($Path in $Candidates) {

        if (Test-Path $Path) {
            return (Resolve-Path $Path).Path
        }

    }

    return $null
}

# ============================================================
# STATUS
# ============================================================

function Refresh-Status {

    Refresh-EnvironmentPath

    $Spotify = Find-Spotify
    $Spicetify = Find-Spicetify

    if ($Spotify) {

        $SpotifyStatus.Text = "Installed"
        $SpotifyStatus.Foreground = "#1ED760"
        $SpotifyDot.Fill = "#1ED760"
        $SpotifyButton.Content = "Reinstall Spotify"

        $SpotifyPath.Text = $Spotify

    } else {

        $SpotifyStatus.Text = "Not installed"
        $SpotifyStatus.Foreground = "#FF6670"
        $SpotifyDot.Fill = "#FF6670"
        $SpotifyButton.Content = "Install Spotify"

        $SpotifyPath.Text = "Spotify executable not found."

    }

    if ($Spicetify) {

        $SpicetifyStatus.Text = "Installed"
        $SpicetifyStatus.Foreground = "#C855FF"
        $SpicetifyDot.Fill = "#C855FF"

        try {

            $Version =
                & $Spicetify "--version" 2>$null

            if ($Version) {
                $SpicetifyVersion.Text =
                    "Version: $Version"
            }

        } catch {

            $SpicetifyVersion.Text =
                "Version: installed"

        }

        $HeroInstallButton.Content =
            "✦  Manage Spicetify"

    } else {

        $SpicetifyStatus.Text = "Not installed"
        $SpicetifyStatus.Foreground = "#FF6670"
        $SpicetifyDot.Fill = "#FF6670"

        $SpicetifyVersion.Text =
            "Spicetify CLI not detected."

        $HeroInstallButton.Content =
            "✦  Install Spicetify"
    }

    if ($Spotify -and $Spicetify) {

        $HeaderStatus.Text = "System ready"
        $HeaderDot.Fill = "#1ED760"

        $SystemText.Text = "Ready"
        $SystemDot.Fill = "#1ED760"

    } elseif ($Spotify) {

        $HeaderStatus.Text = "Spicetify required"
        $HeaderDot.Fill = "#F0B429"

        $SystemText.Text = "Needs setup"
        $SystemDot.Fill = "#F0B429"

    } else {

        $HeaderStatus.Text = "Spotify required"
        $HeaderDot.Fill = "#FF6670"

        $SystemText.Text = "Needs setup"
        $SystemDot.Fill = "#FF6670"
    }
}

# ============================================================
# DISABLE / ENABLE ACTIONS
# ============================================================

function Set-Busy {
    param([bool]$Busy)

    $script:IsBusy = $Busy

    $Controls = @(
        $SpotifyButton,
        $InstallButton,
        $HeroInstallButton,
        $HeroLaunchButton,
        $RepairButton,
        $BackupButton,
        $RestoreButton,
        $UpdateButton
    )

    foreach ($Control in $Controls) {
        $Control.IsEnabled = -not $Busy
    }

    if ($Busy) {
        $HeaderStatus.Text = "Working..."
        $HeaderDot.Fill = "#C855FF"
    } else {
        Refresh-Status
    }
}

# ============================================================
# BACKGROUND OPERATION
# ============================================================

function Start-Operation {

    param(
        [string]$Name,
        [scriptblock]$Script
    )

    if ($script:IsBusy) {
        return
    }

    Set-Busy $true

    Set-ProgressValue 5
    Set-Activity $Name "Working in the background..."

    Write-Log "================================================"
    Write-Log "Starting: $Name"
    Write-Log "================================================"

    $script:CurrentOperation = $Name

    $script:CurrentJob = Start-Job -ScriptBlock $Script

    $Timer = New-Object System.Windows.Threading.DispatcherTimer

    $Timer.Interval = [TimeSpan]::FromMilliseconds(150)

    $Timer.Add_Tick({

        if (-not $script:CurrentJob) {
            $Timer.Stop()
            return
        }

        $Output = Receive-Job `
            -Job $script:CurrentJob `
            -ErrorAction SilentlyContinue

        foreach ($Line in $Output) {

            if ($null -ne $Line) {

                $Text = "$Line"

                Write-Log $Text

                if ($Text -match "download") {
                    Set-ProgressValue 35
                }

                elseif ($Text -match "install") {
                    Set-ProgressValue 65
                }

                elseif ($Text -match "backup") {
                    Set-ProgressValue 45
                }

                elseif ($Text -match "apply") {
                    Set-ProgressValue 75
                }

            }
        }

        if ($script:CurrentJob.State -in @(
            "Completed",
            "Failed",
            "Stopped"
        )) {

            $Timer.Stop()

            $State = $script:CurrentJob.State

            if ($State -eq "Completed") {

                Set-ProgressValue 100

                Write-Log "$($script:CurrentOperation) completed."

                Set-Activity `
                    "Operation complete" `
                    "$($script:CurrentOperation) finished successfully."

            } else {

                Set-ProgressValue 0

                Write-Log "$($script:CurrentOperation) failed."

                Set-Activity `
                    "Operation failed" `
                    "Check the activity console for details."
            }

            Remove-Job `
                -Job $script:CurrentJob `
                -Force `
                -ErrorAction SilentlyContinue

            $script:CurrentJob = $null

            Set-Busy $false

            Refresh-Status
        }

    })

    $Timer.Start()
}

# ============================================================
# INSTALL SPOTIFY
# ============================================================

function Install-Spotify {

    Start-Operation `
        -Name "Installing Spotify" `
        -Script {

            $Temp = Join-Path `
                $env:TEMP `
                "SpicetifyManager-SpotifySetup.exe"

            Write-Output "Downloading official Spotify installer..."

            Invoke-WebRequest `
                -Uri "https://download.scdn.co/SpotifySetup.exe" `
                -OutFile $Temp `
                -UseBasicParsing

            Write-Output "Download complete."
            Write-Output "Launching Spotify installer..."

            Start-Process `
                -FilePath $Temp `
                -Wait

            Write-Output "Spotify installer finished."

            Remove-Item `
                $Temp `
                -Force `
                -ErrorAction SilentlyContinue

            Write-Output "Spotify installation complete."
        }
}

# ============================================================
# INSTALL SPICETIFY
# ============================================================

function Install-Spicetify {

    if (-not (Find-Spotify)) {

        Set-Activity `
            "Spotify required" `
            "Install Spotify before installing Spicetify."

        return
    }

    Start-Operation `
        -Name "Installing Spicetify" `
        -Script {

            Write-Output "Downloading official Spicetify installer..."

            $Response = Invoke-WebRequest `
                -Uri "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" `
                -UseBasicParsing

            Write-Output "Installer downloaded."
            Write-Output "Executing official installer..."

            Invoke-Expression $Response.Content

            Write-Output "Spicetify installer finished."
        }
}

# ============================================================
# BACKUP
# ============================================================

function Backup-Spicetify {

    $Spice = Find-Spicetify

    if (-not $Spice) {

        Set-Activity `
            "Spicetify required" `
            "Spicetify CLI is not installed."

        return
    }

    Start-Operation `
        -Name "Creating backup" `
        -Script {

            & "spicetify" backup 2>&1 |
                ForEach-Object {
                    Write-Output "$_"
                }
        }
}

# ============================================================
# RESTORE
# ============================================================

function Restore-Spicetify {

    $Spice = Find-Spicetify

    if (-not $Spice) {

        Set-Activity `
            "Spicetify required" `
            "Spicetify CLI is not installed."

        return
    }

    Start-Operation `
        -Name "Restoring Spotify" `
        -Script {

            & "spicetify" restore 2>&1 |
                ForEach-Object {
                    Write-Output "$_"
                }
        }
}

# ============================================================
# REPAIR
# ============================================================

function Repair-Spicetify {

    $Spice = Find-Spicetify

    if (-not $Spice) {

        Set-Activity `
            "Spicetify required" `
            "Install Spicetify first."

        return
    }

    Start-Operation `
        -Name "Repairing Spicetify" `
        -Script {

            Write-Output "Creating Spotify backup..."

            & "spicetify" backup 2>&1 |
                ForEach-Object {
                    Write-Output "$_"
                }

            Write-Output "Applying Spicetify..."

            & "spicetify" apply 2>&1 |
                ForEach-Object {
                    Write-Output "$_"
                }

            Write-Output "Repair/reapply complete."
        }
}

# ============================================================
# UPDATE
# ============================================================

function Update-Spicetify {

    $Spice = Find-Spicetify

    if (-not $Spice) {

        Set-Activity `
            "Spicetify required" `
            "Install Spicetify first."

        return
    }

    Start-Operation `
        -Name "Updating Spicetify" `
        -Script {

            & "spicetify" update 2>&1 |
                ForEach-Object {
                    Write-Output "$_"
                }
        }
}

# ============================================================
# UPGRADE
# ============================================================

function Upgrade-Spicetify {

    Start-Operation `
        -Name "Upgrading Spicetify" `
        -Script {

            & "spicetify" upgrade 2>&1 |
                ForEach-Object {
                    Write-Output "$_"
                }
        }
}

# ============================================================
# LAUNCH SPOTIFY
# ============================================================

function Launch-Spotify {

    $Spotify = Find-Spotify

    if ($Spotify) {

        Write-Log "Launching Spotify..."

        Start-Process `
            -FilePath $Spotify

        Set-Activity `
            "Spotify launched" `
            "Spotify is starting."

    } else {

        Set-Activity `
            "Spotify not found" `
            "Install Spotify before launching it."
    }
}

# ============================================================
# NAVIGATION
# ============================================================

function Show-Dashboard {

    $DashboardPage.Visibility = "Visible"
    $ConsolePanel.Visibility = "Collapsed"

    Fade-In $DashboardPage 300
}

function Show-Console {

    $DashboardPage.Visibility = "Collapsed"
    $ConsolePanel.Visibility = "Visible"

    Fade-In $ConsolePanel 300
}

$NavDashboard.Add_Click({

    Show-Dashboard
})

$NavThemes.Add_Click({

    Show-Console

    Write-Log "Themes workspace selected."
    Write-Log "Theme management will be available here."
})

$NavExtensions.Add_Click({

    Show-Console

    Write-Log "Extensions workspace selected."
    Write-Log "Extension management will be available here."
})

$NavRepair.Add_Click({

    Repair-Spicetify
})

$NavBackup.Add_Click({

    Backup-Spicetify
})

$NavSettings.Add_Click({

    Show-Console

    Write-Log "Settings workspace selected."
    Write-Log "Manager settings will be available here."
})

# ============================================================
# BUTTON EVENTS
# ============================================================

$SpotifyButton.Add_Click({

    Install-Spotify
})

$InstallButton.Add_Click({

    Install-Spicetify
})

$HeroInstallButton.Add_Click({

    if (Find-Spicetify) {

        Show-Console

        Write-Log "Spicetify is already installed."
        Write-Log "Opening management console."

    } else {

        Install-Spicetify
    }
})

$HeroLaunchButton.Add_Click({

    Launch-Spotify
})

$RepairButton.Add_Click({

    Repair-Spicetify
})

$BackupButton.Add_Click({

    Backup-Spicetify
})

$RestoreButton.Add_Click({

    Restore-Spicetify
})

$UpdateButton.Add_Click({

    Update-Spicetify
})

$CloseButton.Add_Click({

    $Window.Close()
})

# ============================================================
# STARTUP ANIMATION
# ============================================================

$Window.Opacity = 0

$Window.Add_Loaded({

    # Fade window in
    $Fade = New-Object System.Windows.Media.Animation.DoubleAnimation

    $Fade.From = 0
    $Fade.To = 1

    $Fade.Duration =
        [System.Windows.Duration]::new(
            [TimeSpan]::FromMilliseconds(650)
        )

    $Window.BeginAnimation(
        [System.Windows.Window]::OpacityProperty,
        $Fade
    )

    Pulse-Orb

    # Ambient glow movement
    $GlowTimer =
        New-Object System.Windows.Threading.DispatcherTimer

    $GlowTimer.Interval =
        [TimeSpan]::FromMilliseconds(40)

    $script:GlowPhase = 0

    $GlowTimer.Add_Tick({

        $script:GlowPhase += 0.015

        $Glow1.RenderTransform =
            New-Object System.Windows.Media.TranslateTransform(
                [math]::Sin($script:GlowPhase) * 18,
                [math]::Cos($script:GlowPhase) * 14
            )

        $Glow2.RenderTransform =
            New-Object System.Windows.Media.TranslateTransform(
                [math]::Cos($script:GlowPhase * 0.7) * 25,
                [math]::Sin($script:GlowPhase * 0.7) * 18
            )

    })

    $GlowTimer.Start()

    # Startup sequence
    $StartupTimer =
        New-Object System.Windows.Threading.DispatcherTimer

    $StartupTimer.Interval =
        [TimeSpan]::FromMilliseconds(900)

    $script:StartupStep = 0

    $StartupTimer.Add_Tick({

        $script:StartupStep++

        switch ($script:StartupStep) {

            1 {

                $HeroOrbText.Text = "●"
                $HeroOrbText.Foreground =
                    "#1ED760"

                Write-Log "Initializing Spicetify Manager..."
            }

            2 {

                $HeroOrbText.Text = "S"
                $HeroOrbText.Foreground =
                    "#C855FF"

                Write-Log "Loading Spotify integration..."
            }

            3 {

                Write-Log "Loading Spicetify integration..."
                Refresh-Status
            }

            4 {

                Write-Log "Manager ready."

                Set-Activity `
                    "Ready" `
                    "Everything is standing by."

                $StartupTimer.Stop()
            }

        }

    })

    $StartupTimer.Start()

})

# ============================================================
# START
# ============================================================

Write-Log "Spicetify Manager v2 starting..."
Write-Log "Initializing interface..."

Show-Dashboard

$Window.ShowDialog() | Out-Null
