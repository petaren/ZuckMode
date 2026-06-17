import AppKit

class OverlayWindowController {
    private struct Overlay {
        let window: NSWindow
        let label: NSTextField
    }

    private static let encouragements: [String] = [
        "Be happy and smile.\nRemember, you didn't get laid off.\nThis time.",
        "Happiness is mandatory.\nSmile to continue using your computer.",
        "Have you tried being happier?",
        "Mark would love to see that smile.\nHe is watching.",
        "You are valued.\nSmile to confirm receipt of this message.",
        "Performance reviews are quarterly.\nThis is a reminder.",
        "Smiling increases productivity by 12%.\nMark read it in a study.",
    ]

    private var overlays: [Overlay] = []
    private var currentAlpha: CGFloat = 0.0
    private var currentMode: AppMode = .encouragement
    private var currentEncouragement = ""
    private var wasSmiling = false

    init() {
        currentEncouragement = OverlayWindowController.encouragements[0]
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
        overlays.forEach { $0.window.close() }
        overlays = NSScreen.screens.map { makeOverlay(for: $0) }
        applyMode()
    }

    private func makeOverlay(for screen: NSScreen) -> Overlay {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.backgroundColor = .black
        window.isOpaque = false
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.alphaValue = currentAlpha

        let label = NSTextField(wrappingLabelWithString: "")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 36, weight: .medium)
        label.alignment = .center
        label.isSelectable = false
        label.drawsBackground = false
        label.isBezeled = false
        label.isHidden = true

        let contentView = NSView()
        window.contentView = contentView
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
        ])

        window.orderFrontRegardless()
        return Overlay(window: window, label: label)
    }

    func update(smileScore: Float) {
        let isSmiling = smileScore > 0.5
        if currentMode == .encouragement && !wasSmiling && isSmiling {
            // Screen is clearing — rotate to a fresh message for the next dark phase
            let choices = Self.encouragements.filter { $0 != currentEncouragement }
            currentEncouragement = choices.randomElement() ?? currentEncouragement
            applyMode()
        }
        wasSmiling = isSmiling

        currentAlpha = CGFloat(1.0 - smileScore)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            for overlay in overlays {
                overlay.window.animator().alphaValue = currentAlpha
            }
        }
    }

    func setMode(_ mode: AppMode) {
        currentMode = mode
        if mode == .encouragement {
            currentEncouragement = Self.encouragements.randomElement() ?? ""
        }
        applyMode()
    }

    private func applyMode() {
        let show = currentMode == .encouragement
        for overlay in overlays {
            overlay.label.stringValue = show ? currentEncouragement : ""
            overlay.label.isHidden = !show
        }
    }

    @objc private func screensChanged() {
        buildOverlays()
    }
}
