import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            IslandScreen()
                .tabItem { Label("Островок", systemImage: "moon.haze.fill") }
            SettingsScreen()
                .tabItem { Label("Настройки", systemImage: "slider.horizontal.3") }
            AboutScreen()
                .tabItem { Label("О приложении", systemImage: "info.circle") }
        }
    }
}
