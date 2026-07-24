import SwiftUI

@main
struct TodoGlassApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: ContentView.defaultWidth, height: ContentView.defaultHeight)
    }
}
