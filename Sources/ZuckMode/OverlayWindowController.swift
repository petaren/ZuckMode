import AppKit

class OverlayWindowController {
    private var overlays: [NSWindow] = []
    private var currentAlpha: CGFloat = 1.0

    init() {
        buildOverlays()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func buildOverlays() {
        overlays.forEach { $0.close() }
        overlays = NSScreen.screens.map { makeOverlay(for: $0) }
    }

    private func makeOverlay(for screen: NSScreen) -> NSWindow {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.backgroundColor = .black
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.alphaValue = currentAlpha
        window.orderFrontRegardless()
        return window
    }

    func update(smileScore: Float) {
        currentAlpha = CGFloat(1.0 - smileScore)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            for window in overlays {
                window.animator().alphaValue = currentAlpha
            }
        }
    }

    @objc private func screensChanged() {
        buildOverlays()
    }
}
