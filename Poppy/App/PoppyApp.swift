import SwiftUI
import ComposableArchitecture
import PoppyCore

@main
struct PoppyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No visible window — menu bar only. Suppress default window.
        WindowGroup { }.defaultLaunchBehavior(.suppressed)
    }
}
