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

      GlassEffectContainer(spacing: 8) {
        HStack(spacing: 8) {
          Circle()
            .fill(controller.isRunning ? Color.green : Color.secondary)
            .frame(width: 10, height: 10)
          Text(controller.isRunning
               ? "Running on http://\(ProcessInfo.processInfo.hostName):\(String(controller.boundPort ?? port))"
               : "Stopped")
          Spacer()
          Button(controller.isRunning ? "Stop" : "Start") {
            if controller.isRunning { controller.stop() } else { controller.start() }
          }
          .buttonStyle(.glassProminent)
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

      Divider()

      Text("Recent Requests")
        .font(.headline)

      if controller.log.entries.isEmpty {
        Text("No requests yet")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding(12)
          .glassEffect(in: .rect(cornerRadius: 12))
      } else {
        ScrollView {
          VStack(spacing: 8) {
            ForEach(Array(controller.log.entries.reversed())) { entry in
              VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                  Text("\(entry.command): \(entry.model)")
                    .font(.system(.body, design: .monospaced))
                  Spacer()
                  Text(entry.date, style: .time)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                  Image(systemName: entry.success ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(entry.success ? Color.green : Color.secondary)
                  Image(systemName: entry.success ? "xmark.circle" : "xmark.circle.fill")
                    .foregroundStyle(entry.success ? Color.secondary : Color.red)
                }
                if !entry.status.isEmpty {
                  Text(entry.status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                }
              }
              .padding(.horizontal, 4)
            }
          }
          .padding(8)
        }
        .frame(maxHeight: 160)
        .glassEffect(in: .rect(cornerRadius: 12))
      }
    }
    .padding(24)
    .frame(minWidth: 440)
  }
}
