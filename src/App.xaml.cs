using System;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Media; // Required for the overlay colors

namespace winDialog
{
    public partial class App : Application
    {
        [DllImport("kernel32.dll")]
        private static extern bool AttachConsole(int dwProcessId);
        private const int ATTACH_PARENT_PROCESS = -1;

        private void Application_Startup(object sender, StartupEventArgs e)
        {
            // Intercept the --version flag
            for (int i = 0; i < e.Args.Length; i++)
            {
                if (e.Args[i] == "--version")
                {
                    AttachConsole(ATTACH_PARENT_PROCESS);
                    var version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version;
                    Console.WriteLine($"\nwinDialog Version: {version}");
                    Environment.Exit(0);
                }
            }

            string title = "winDialog";
            string message = "Default message.";
            string button1 = "OK";
            string button2 = "";
            string iconPath = "";
            string bannerPath = "";
            double windowWidth = 650; 
            double windowHeight = 450;
            int timerSeconds = 0; 
            string input1 = "";
            string input2 = "";
            string outputPath = "";
            
            // NEW: The Blur/Overlay Toggle
            bool useBlur = false;

            for (int i = 0; i < e.Args.Length; i++)
            {
                if (e.Args[i] == "--title" && i + 1 < e.Args.Length) title = e.Args[++i];
                else if (e.Args[i] == "--message" && i + 1 < e.Args.Length) message = e.Args[++i];
                else if (e.Args[i] == "--button1" && i + 1 < e.Args.Length) button1 = e.Args[++i];
                else if (e.Args[i] == "--button2" && i + 1 < e.Args.Length) button2 = e.Args[++i];
                else if (e.Args[i] == "--banner" && i + 1 < e.Args.Length) bannerPath = e.Args[++i];
                else if (e.Args[i] == "--icon" && i + 1 < e.Args.Length) iconPath = e.Args[++i];
                else if (e.Args[i] == "--width" && i + 1 < e.Args.Length) double.TryParse(e.Args[++i], out windowWidth);
                else if (e.Args[i] == "--height" && i + 1 < e.Args.Length) double.TryParse(e.Args[++i], out windowHeight);
                else if (e.Args[i] == "--timer" && i + 1 < e.Args.Length) int.TryParse(e.Args[++i], out timerSeconds);
                else if (e.Args[i] == "--input1" && i + 1 < e.Args.Length) input1 = e.Args[++i];
                else if (e.Args[i] == "--input2" && i + 1 < e.Args.Length) input2 = e.Args[++i];
                else if (e.Args[i] == "--output" && i + 1 < e.Args.Length) outputPath = e.Args[++i];
                
                // NEW: Parse the --blur flag (doesn't need an argument after it)
                else if (e.Args[i] == "--blur") useBlur = true;
            }

            // NEW: Generate the Full-Screen Dark Overlay if requested
            if (useBlur)
            {
                Window overlay = new Window
                {
                    WindowStyle = WindowStyle.None,
                    AllowsTransparency = true,
                    // Black with 80% opacity (ARGB: 200, 0, 0, 0)
                    Background = new SolidColorBrush(Color.FromArgb(200, 0, 0, 0)), 
                    Topmost = true,           // Force to the front
                    ShowInTaskbar = false,    // Don't clutter the taskbar
                    
                    // Span across all connected monitors perfectly
                    Left = SystemParameters.VirtualScreenLeft,
                    Top = SystemParameters.VirtualScreenTop,
                    Width = SystemParameters.VirtualScreenWidth,
                    Height = SystemParameters.VirtualScreenHeight
                };
                overlay.Show();
            }

            MainWindow mainWindow = new MainWindow(title, message, button1, button2, iconPath, bannerPath, windowWidth, windowHeight, timerSeconds, input1, input2, outputPath);
            
            // Ensure the main dialog sits explicitly ON TOP of our dark overlay
            if (useBlur) 
            {
                mainWindow.Topmost = true;
            }
            
            mainWindow.Show();
        }
    }
}