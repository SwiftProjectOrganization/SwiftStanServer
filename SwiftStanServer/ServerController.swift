import Foundation
import Observation
import Hummingbird
import OpenAPIHummingbird
import OpenAPIRuntime

/// Owns the Hummingbird HTTP server lifecycle and exposes observable state for
/// the GUI (`ContentView`). The server binds to all interfaces (0.0.0.0) so it
/// is reachable from the local network, not just localhost. Registers the
/// OpenAPI-generated handlers from `StanAPIHandler`.
///
/// cmdstan runs (compile/sample/...) can take minutes; the response/idle timeouts
/// are set generously so synchronous calls aren't cut off.
@Observable
@MainActor
final class ServerController {
  var isRunning = false
  var lastError: String?
  var boundPort: Int?

  private var runTask: Task<Void, Never>?

  func start() {
    guard !isRunning else { return }
    let port = ServerSettings.port()
    lastError = nil

    runTask = Task { [weak self] in
      do {
        let router = Router()
        let handler = StanAPIHandler()
        try handler.registerHandlers(on: router)

        let app = Application(
          router: router,
          configuration: .init(
            address: .hostname(ServerSettings.host, port: port),
            serverName: "SwiftStanServer"))

        self?.isRunning = true
        self?.boundPort = port
        try await app.runService()
      } catch {
        self?.lastError = "\(error)"
        self?.isRunning = false
        self?.boundPort = nil
      }
      self?.isRunning = false
      self?.boundPort = nil
    }
  }

  func stop() {
    runTask?.cancel()
    runTask = nil
    isRunning = false
    boundPort = nil
  }
}
