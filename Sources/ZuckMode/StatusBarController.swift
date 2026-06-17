import AppKit

enum AppMode {
    case standard
    case encouragement
}

class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var standardItem: NSMenuItem!
    private var encouragementItem: NSMenuItem!
    var onModeChange: ((AppMode) -> Void)?

    init() {
        buildMenu()
        update(smileScore: 0)
    }

    private func buildMenu() {
        let menu = NSMenu()

        standardItem = NSMenuItem(title: "Standard", action: #selector(selectStandard), keyEquivalent: "")
        standardItem.target = self
        standardItem.state = .off
        menu.addItem(standardItem)

        encouragementItem = NSMenuItem(title: "Encouragement Mode", action: #selector(selectEncouragement), keyEquivalent: "")
        encouragementItem.target = self
        encouragementItem.state = .on
        menu.addItem(encouragementItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit ZuckMode", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func update(smileScore: Float) {
        switch smileScore {
        case 0.6...: statusItem.button?.title = "😊"
        case 0.3..<0.6: statusItem.button?.title = "😐"
        default: statusItem.button?.title = "😑"
        }
    }

    @objc private func selectStandard() {
        standardItem.state = .on
        encouragementItem.state = .off
        onModeChange?(.standard)
    }

    @objc private func selectEncouragement() {
        standardItem.state = .off
        encouragementItem.state = .on
        onModeChange?(.encouragement)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
