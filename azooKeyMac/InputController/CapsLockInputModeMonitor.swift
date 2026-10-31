import Cocoa
import Core
import IOKit
import IOKit.hid

/// Caps Lockを「英数/かな」の切り替えに使うためのモニタ。
///
/// IMKInputControllerはCaps Lockの`flagsChanged`イベントを受け取れないため、
/// IOKitでCaps Lockの状態を定期的に監視する。Shiftを押さずにCaps Lockが押された場合は
/// 入力モードを切り替えたうえでCaps Lockを強制的にオフにする。
/// Shift+Caps Lockは通常のCaps Lock（大文字固定）として扱う。
@MainActor
final class CapsLockInputModeMonitor {
    static let shared = CapsLockInputModeMonitor()

    private weak var activeController: azooKeyMacInputController?
    private var timer: Timer?
    private var ioConnection: io_connect_t = 0
    private var lastCapsLockState = false
    private var shiftHistory: [Bool] = []
    private var isEnabled = Config.CapsLockInputModeSwitch().value
    private var observer: NSObjectProtocol?

    private static let pollingInterval: TimeInterval = 0.01
    private static let shiftHistoryCount = 8

    private init() {}

    func start() {
        guard self.timer == nil else {
            return
        }
        self.isEnabled = Config.CapsLockInputModeSwitch().value
        self.lastCapsLockState = self.readCapsLockState() ?? false
        self.shiftHistory.removeAll(keepingCapacity: true)
        self.observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: Config.userDefaults,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isEnabled = Config.CapsLockInputModeSwitch().value
            }
        }

        let timer = Timer(timeInterval: Self.pollingInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.poll()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        self.timer?.invalidate()
        self.timer = nil
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
        self.closeConnection()
    }

    func setActiveController(_ controller: azooKeyMacInputController) {
        self.activeController = controller
        self.start()
    }

    func clearActiveController(_ controller: azooKeyMacInputController) {
        guard self.activeController === controller else {
            return
        }
        self.activeController = nil
    }

    private func poll() {
        guard let currentState = self.readCapsLockState() else {
            return
        }

        let shiftPressed = CGEventSource.flagsState(.combinedSessionState).contains(.maskShift)
        self.shiftHistory.append(shiftPressed)
        if self.shiftHistory.count > Self.shiftHistoryCount {
            self.shiftHistory.removeFirst(self.shiftHistory.count - Self.shiftHistoryCount)
        }

        let previousState = self.lastCapsLockState
        guard currentState != previousState else {
            return
        }
        self.lastCapsLockState = currentState

        guard self.isEnabled, self.activeController != nil else {
            return
        }
        // Shift+Caps Lockは大文字固定のための操作として扱う
        guard !self.shiftHistory.contains(true) else {
            return
        }

        if currentState {
            // Caps Lockがオンになった直後にオフへ戻す
            guard self.writeCapsLockState(false) else {
                return
            }
            self.lastCapsLockState = false
        }
        self.activeController?.toggleInputLanguageForCapsLock()
    }

    private func openConnectionIfNeeded() -> io_connect_t? {
        if self.ioConnection != 0 {
            return self.ioConnection
        }
        guard let serviceDictionary = IOServiceMatching(kIOHIDSystemClass) else {
            return nil
        }
        let ioService = IOServiceGetMatchingService(kIOMainPortDefault, serviceDictionary)
        guard ioService != MACH_PORT_NULL else {
            return nil
        }
        var connection: io_connect_t = 0
        let result = IOServiceOpen(ioService, mach_task_self_, UInt32(kIOHIDParamConnectType), &connection)
        IOObjectRelease(ioService)
        guard result == KERN_SUCCESS else {
            return nil
        }
        self.ioConnection = connection
        return connection
    }

    private func closeConnection() {
        guard self.ioConnection != 0 else {
            return
        }
        IOServiceClose(self.ioConnection)
        self.ioConnection = 0
    }

    private func readCapsLockState() -> Bool? {
        guard let connection = self.openConnectionIfNeeded() else {
            return nil
        }
        var state = false
        let result = IOHIDGetModifierLockState(connection, Int32(kIOHIDCapsLockState), &state)
        guard result == KERN_SUCCESS else {
            self.closeConnection()
            return nil
        }
        return state
    }

    private func writeCapsLockState(_ enabled: Bool) -> Bool {
        guard let connection = self.openConnectionIfNeeded() else {
            return false
        }
        let result = IOHIDSetModifierLockState(connection, Int32(kIOHIDCapsLockState), enabled)
        if result != KERN_SUCCESS {
            self.closeConnection()
            return false
        }
        return true
    }
}
