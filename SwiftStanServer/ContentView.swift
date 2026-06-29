import SwiftUI

struct ContentView: View {
  @Environment(ServerController.self) private var controller

  @AppStorage(ServerSettings.Key.cmdstanPath) private var cmdstanPath: String = ""
  @AppStorage(ServerSettings.Key.port) private var port: Int = ServerSettings.defaultPort

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("SwiftStanServer")
        .font(.largeTitle).bold()
      Text("Serves the SwiftStan commands over an OpenAPI/Hummingbird HTTP API on the local network.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Divider()

      HStack(spacing: 8) {
        Circle()
          .fill(controller.isRunning ? .green : .secondary)
          .frame(width: 10, height: 10)
        Text(controller.isRunning
             ? "Running on http://\(ProcessInfo.processInfo.hostName):\(controller.boundPort ?? port)"
             : "Stopped")
        Spacer()
        if controller.isRunning {
          Button("Stop") { controller.stop() }
        } else {
          Button("Start") { controller.start() }
        }
      }

      LabeledContent("Port") {
        TextField("8080", value: $port, format: .number.grouping(.never))
          .frame(width: 90)
      }

      LabeledContent("cmdstan path") {
        TextField("/Users/rob/Projects/StanSupport/cmdstan", text: $cmdstanPath)
          .font(.system(.body, design: .monospaced))
      }

      if let err = controller.lastError {
        Text(err)
          .font(.caption)
          .foregroundStyle(.red)
      }

      Text("Restart the server after changing the port or cmdstan path.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .padding(24)
    .frame(minWidth: 440)
  }
}
