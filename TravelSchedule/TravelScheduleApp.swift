import SwiftUI

@main
struct TravelScheduleApp: App {

    init() {
        configureTabBar()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        appearance.backgroundColor = UIColor(named: "YPWhite")
        appearance.shadowColor = UIColor(named: "DropShadow")

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
