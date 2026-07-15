import Cocoa
import Carbon.HIToolbox

/// Registers system-wide (global) keyboard shortcuts using the Carbon Event Manager.
/// This still works fine on Apple Silicon / modern macOS for global hotkeys and does
/// not require Accessibility permission (unlike moving other apps' windows, which does).
final class HotKeyManager {
    typealias Handler = () -> Void

    private var handlers: [UInt32: Handler] = [:]
    private var hotKeyRefs: [EventHotKeyRef?] = []
    private var eventHandler: EventHandlerRef?
    private var nextID: UInt32 = 1
    private static let signature: OSType = 0x44495644 // 'DIVD'

    init() {
        installHandler()
    }

    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                       eventKind: UInt32(kEventHotKeyPressed))
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(GetApplicationEventTarget(), { _, eventRef, userData in
            guard let eventRef = eventRef, let userData = userData else { return noErr }
            var hotKeyID = EventHotKeyID()
            GetEventParameter(eventRef,
                               EventParamName(kEventParamDirectObject),
                               EventParamType(typeEventHotKeyID),
                               nil,
                               MemoryLayout<EventHotKeyID>.size,
                               nil,
                               &hotKeyID)
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
            manager.handlers[hotKeyID.id]?()
            return noErr
        }, 1, &eventType, selfPtr, &eventHandler)
    }

    @discardableResult
    func register(keyCode: Int, modifiers: UInt32, handler: @escaping Handler) -> Bool {
        let id = nextID
        nextID += 1

        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: Self.signature, id: id)
        let status = RegisterEventHotKey(UInt32(keyCode),
                                          modifiers,
                                          hotKeyID,
                                          GetApplicationEventTarget(),
                                          0,
                                          &hotKeyRef)
        guard status == noErr else { return false }
        handlers[id] = handler
        hotKeyRefs.append(hotKeyRef)
        return true
    }
}

/// Carbon modifier flag helpers (RegisterEventHotKey expects the old Carbon bit flags).
enum HotKeyModifier {
    static let control: UInt32 = UInt32(controlKey)
    static let option: UInt32 = UInt32(optionKey)
    static let command: UInt32 = UInt32(cmdKey)
    static let shift: UInt32 = UInt32(shiftKey)
}
