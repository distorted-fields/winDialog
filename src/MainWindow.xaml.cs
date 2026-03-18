using System;
using System.IO;
using System.Windows;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;

namespace winDialog
{
    public partial class MainWindow : Window
    {
        private DispatcherTimer _countdownTimer;
        private int _timeRemaining;
        private string _originalButton1Text;
        private string _outputPath; // Save the file path to use on exit

        public MainWindow(string title, string message, string button1Text, string button2Text, string iconPath, string bannerPath, double windowWidth, double windowHeight, int timerSeconds, string input1Label, string input2Label, string outputPath)
        {
            InitializeComponent();
            
            this.Width = windowWidth;
            this.Height = windowHeight;
            _outputPath = outputPath;

            TitleText.Text = title;
            MessageText.Text = message;
            _originalButton1Text = button1Text;
            Button1.Content = _originalButton1Text;

            // Handle Buttons, Banners, Icons (Same as before)
            if (!string.IsNullOrEmpty(button2Text)) { Button2.Content = button2Text; Button2.Visibility = Visibility.Visible; }
            if (!string.IsNullOrEmpty(bannerPath)) { try { BannerBrush.ImageSource = new BitmapImage(new Uri(bannerPath, UriKind.RelativeOrAbsolute)); } catch {} }
            if (!string.IsNullOrEmpty(iconPath)) { try { if (iconPath.StartsWith("http") || File.Exists(iconPath)) { DialogIcon.Source = new BitmapImage(new Uri(iconPath, UriKind.RelativeOrAbsolute)); DialogIcon.Visibility = Visibility.Visible; } } catch {} }

            // Handle Text Inputs
            if (!string.IsNullOrEmpty(input1Label) || !string.IsNullOrEmpty(input2Label))
            {
                InputPanel.Visibility = Visibility.Visible;
                
                if (!string.IsNullOrEmpty(input1Label))
                {
                    Input1Container.Visibility = Visibility.Visible;
                    Input1Label.Text = input1Label;
                }
                if (!string.IsNullOrEmpty(input2Label))
                {
                    Input2Container.Visibility = Visibility.Visible;
                    Input2Label.Text = input2Label;
                }
            }

            // Handle Timer
            if (timerSeconds > 0)
            {
                _timeRemaining = timerSeconds;
                Button1.Content = $"{_originalButton1Text} ({_timeRemaining})";
                _countdownTimer = new DispatcherTimer();
                _countdownTimer.Interval = TimeSpan.FromSeconds(1);
                _countdownTimer.Tick += CountdownTimer_Tick;
                _countdownTimer.Start();
            }
        }

        private void CountdownTimer_Tick(object sender, EventArgs e)
        {
            _timeRemaining--;
            if (_timeRemaining > 0) { Button1.Content = $"{_originalButton1Text} ({_timeRemaining})"; }
            else { FinishAndExit(0); }
        }

        private void Button1_Click(object sender, RoutedEventArgs e) { FinishAndExit(0); }
        private void Button2_Click(object sender, RoutedEventArgs e) { FinishAndExit(2); }

        // A helper function to save the text data before shutting down
        private void FinishAndExit(int exitCode)
        {
            if (_countdownTimer != null) _countdownTimer.Stop();

            // Only save the file if Button 1 (Success) was clicked and an output path was given
            if (exitCode == 0 && !string.IsNullOrEmpty(_outputPath))
            {
                try
                {
                    // Write data in a simple key=value format for easy RMM parsing
                    string data = $"Input1={Input1Box.Text}\nInput2={Input2Box.Text}";
                    File.WriteAllText(_outputPath, data);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Failed to write output file: " + ex.Message);
                }
            }

            Application.Current.Shutdown(exitCode);
        }
    }
}