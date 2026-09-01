import SwiftUI
import AppKit

/// Reaches into the hosting NSWindow to make it a borderless-feeling, always-on-top glass panel
/// that follows you across desktop Spaces (and above fullscreen apps), while keeping the native
/// minimize/close controls.
struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isOpaque = false
            window.backgroundColor = .clear
            window.hasShadow = true
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            // Keep this off: when the whole background is draggable, AppKit steals
            // row drags to move the window and drag-to-reorder never starts.
            // The header acts as the explicit move handle instead (see WindowDragArea).
            window.isMovableByWindowBackground = false
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

/// A transparent region that drags the host window when clicked, so we can move
/// the panel by its header while leaving list rows free to drag-to-reorder.
struct WindowDragArea: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { WindowDragNSView() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    private final class WindowDragNSView: NSView {
        override func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }
    }
}
