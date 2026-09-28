using System.Windows;
using RF4PIP.Capture;
using RF4PIP.Presentation;
namespace RF4PIP;
public partial class App : Application
{
    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        try
        {
            await using var capture = new CaptureMonitor(new GameWindowLocator());
            capture.Start();
            await new WpfPictureInPicturePresenter(Dispatcher).ShowAsync(capture, CancellationToken.None);
        }
        catch (Exception error)
        {
            MessageBox.Show(error.Message, "RF4 PIP", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        finally { Shutdown(); }
    }
}
