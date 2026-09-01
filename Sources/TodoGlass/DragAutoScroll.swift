import SwiftUI
import AppKit

/// Drives edge auto-scrolling and reliable drag-end cleanup while a task row is
/// being dragged.
///
/// A SwiftUI `.onDrag` gives us no "drag ended" callback, and its drop delegates
/// only fire when the pointer is released over a registered drop target — so a
/// drop into the empty space past the first/last row leaves the dragged row stuck
/// in its dimmed state. To solve both problems we run a timer during the drag:
///
/// * It reads the live cursor position and scrolls the underlying `NSScrollView`
///   when the cursor is inside the top/bottom edge zone.
/// * It watches the mouse button and, the moment it's released, clears the drag
///   state — regardless of where the drop happened.
///
/// The timer is added to the `.common` run-loop modes so it keeps firing during
/// AppKit's modal drag-tracking loop.
final class AutoScroller: ObservableObject {
    weak var scrollView: NSScrollView?

    private var timer: Timer?
    private var onEnd: (() -> Void)?

    /// How close (in points) to an edge the cursor must be to start scrolling.
    private let edgeZone: CGFloat = 48
    /// Maximum scroll speed in points per tick.
    private let maxSpeed: CGFloat = 16

    /// Begin monitoring for the current drag. `onEnd` runs once, on mouse-up.
    func begin(onEnd: @escaping () -> Void) {
        self.onEnd = onEnd
        guard timer == nil else { return }
        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        // Left mouse button released => the drag is over. Clean up.
        if NSEvent.pressedMouseButtons & 0x1 == 0 {
            finish()
            return
        }

        guard let scrollView, let window = scrollView.window else { return }

        // Viewport rectangle in screen coordinates.
        let viewportInWindow = scrollView.convert(scrollView.bounds, to: nil)
        let viewportOnScreen = window.convertToScreen(viewportInWindow)

        let mouse = NSEvent.mouseLocation

        // Ignore vertical scrolling when the cursor is well outside horizontally.
        guard mouse.x >= viewportOnScreen.minX - 40,
              mouse.x <= viewportOnScreen.maxX + 40 else { return }

        // Screen y grows upward: maxY is the top edge, minY the bottom edge.
        let distFromTop = viewportOnScreen.maxY - mouse.y
        let distFromBottom = mouse.y - viewportOnScreen.minY

        if distFromTop < edgeZone {
            scroll(by: -speed(forDistance: distFromTop))   // toward the start
        } else if distFromBottom < edgeZone {
            scroll(by: speed(forDistance: distFromBottom))  // toward the end
        }
    }

    /// Ramp speed up as the cursor gets closer to (or past) the edge.
    private func speed(forDistance distance: CGFloat) -> CGFloat {
        let clamped = max(0, min(edgeZone, distance))
        let intensity = 1 - (clamped / edgeZone) // 0 at inner boundary, 1 at edge
        return max(2, intensity * maxSpeed)
    }

    /// Scroll the clip view by `dy` points (negative = up), clamped to bounds.
    /// SwiftUI's document view is flipped, so y == 0 is the top.
    private func scroll(by dy: CGFloat) {
        guard let scrollView, let documentView = scrollView.documentView else { return }
        let clip = scrollView.contentView
        let maxY = max(0, documentView.frame.height - clip.bounds.height)
        var origin = clip.bounds.origin
        let newY = min(max(0, origin.y + dy), maxY)
        guard newY != origin.y else { return }
        origin.y = newY
        clip.scroll(to: origin)
        scrollView.reflectScrolledClipView(clip)
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        let callback = onEnd
        onEnd = nil
        callback?()
    }
}

/// Locates the `NSScrollView` backing a SwiftUI `ScrollView` by walking up from a
/// zero-sized probe view placed inside the scrolled content.
struct ScrollViewFinder: NSViewRepresentable {
    let onFound: (NSScrollView) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        findScrollView(from: view, attempt: 0)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    private func findScrollView(from view: NSView, attempt: Int) {
        DispatchQueue.main.async {
            if let scrollView = view.enclosingScrollView {
                onFound(scrollView)
            } else if attempt < 10 {
                findScrollView(from: view, attempt: attempt + 1)
            }
        }
    }
}
