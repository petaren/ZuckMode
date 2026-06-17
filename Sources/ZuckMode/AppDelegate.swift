import Cocoa
import AVFoundation

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!
    private var cameraController: CameraController?
    private var overlayController: OverlayWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()

        // Request permission first — overlays only appear after, so the dialog is always visible.
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                self.overlayController = OverlayWindowController()
                self.statusBarController.onModeChange = { [weak self] mode in
                    self?.overlayController?.setMode(mode)
                }
                guard granted else { return }
                self.cameraController = CameraController { [weak self] smileScore in
                    DispatchQueue.main.async {
                        self?.overlayController?.update(smileScore: smileScore)
                        self?.statusBarController?.update(smileScore: smileScore)
                    }
                }
                self.cameraController?.start()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        cameraController?.stop()
    }
}
