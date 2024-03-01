import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            SubscriptionsListView()
                .tabItem {
                    Label("Subscriptions", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings Content")
    }
}
