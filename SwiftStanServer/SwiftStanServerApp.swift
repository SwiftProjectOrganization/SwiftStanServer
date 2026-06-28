import SwiftUI

@main
struct SwiftStanServerApp: App {
  @State private var controller = ServerController()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(controller)
        .onAppear { controller.start() }
    }
    .defaultSize(width: 480, height: 280)
  }
}
