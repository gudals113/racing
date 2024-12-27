import Foundation
import Cocoa

class GlobalKeyboardMonitor {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var onKeyPress: ((NSEvent) -> Void)?

    func startMonitoring(onKeyPress: @escaping (NSEvent) -> Void) {
        guard eventTap == nil else { return }

        self.onKeyPress = onKeyPress

        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { proxy, type, event, userInfo in
                return GlobalKeyboardMonitor.globalKeyboardCallback(proxy: proxy, type: type, event: event, userInfo: userInfo)
                        },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        } else {
            print("Failed to create event tap.")
        }
    }

    func stopMonitoring() {
        if let eventTap = eventTap {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
            self.runLoopSource = nil
        }
    }

    deinit {
        stopMonitoring()
    }

    /// 정적 콜백 함수: C 함수 포인터로 사용 가능
    private static func globalKeyboardCallback(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent,
        userInfo: UnsafeMutableRawPointer?
    ) -> Unmanaged<CGEvent>? {
        guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
        let monitor = Unmanaged<GlobalKeyboardMonitor>.fromOpaque(userInfo).takeUnretainedValue()

        if let nsEvent = NSEvent(cgEvent: event) {
            monitor.onKeyPress?(nsEvent)
        }

        return Unmanaged.passUnretained(event)
    }
}
