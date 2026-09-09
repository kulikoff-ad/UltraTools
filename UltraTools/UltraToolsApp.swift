import SwiftUI

@main
struct UltraToolsApp: App {
    @StateObject private var islandStore = IslandStore()
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(islandStore)
                .environmentObject(settingsStore)
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
    }
}
