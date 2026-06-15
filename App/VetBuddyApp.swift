import SwiftUI

@main
struct VetBuddyApp: App {

    @StateObject private var router = AppRouter()
    private let coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
                .environmentObject(coreDataStack)
        }
    }
}
