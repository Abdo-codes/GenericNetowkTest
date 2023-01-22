

import SwiftUI

@main
struct TCAUsecaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(store: .init(initialState: .init(), reducer: ListFeature()))
        }
    }
}
