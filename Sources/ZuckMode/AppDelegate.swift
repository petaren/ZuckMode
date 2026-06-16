import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var cameraController: CameraController!
    private var overlayController: OverlayWindowController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayController = OverlayWindowController()
        statusBarController = StatusBarController()
        cameraController = CameraController { [weak self] smileScore in
            DispatchQueue.main.async {
                self?.overlayController.update(smileScore: smileScore)
                self?.statusBarController.update(smileScore: smileScore)
            }
        }
        cameraController.requestAccessAndStart()
    }

    func applicationWillTerminate(_ notification: Notification) {
        cameraController?.stop()
    }
}
