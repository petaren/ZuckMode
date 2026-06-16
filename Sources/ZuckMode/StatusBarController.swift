import AppKit

class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    init() {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "Quit ZuckMode", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        statusItem.menu = menu
        update(smileScore: 0)
    }

    func update(smileScore: Float) {
        switch smileScore {
        case 0.6...: statusItem.button?.title = "😊"
        case 0.3..<0.6: statusItem.button?.title = "😐"
        default: statusItem.button?.title = "😑"
        }
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
