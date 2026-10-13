import SwiftUI

@main
struct KRAiSDApp: App {
    var body: some Scene {
        WindowGroup("КР АиСД — вариант 15") {
            ContentView()
                .frame(minWidth: 760, minHeight: 560)
        }
        .defaultSize(width: 1180, height: 760)
        .windowStyle(.titleBar)
        .windowResizability(.contentMinSize)
    }
}
