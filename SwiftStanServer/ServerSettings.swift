import Foundation

/// Server-side configuration. Mirrors `SwiftStanApp/AppSettings.swift` for the
/// cmdstan path so the two projects resolve it identically, and adds the HTTP
/// bind settings the server needs.
///
/// GUI apps launched by launchd don't inherit the shell's `$CMDSTAN`, so a
/// stored UserDefaults value wins, then the process env, then the historical
/// hardcoded fallback.
enum ServerSettings {
  /// UserDefaults keys (also bound from `ContentView` via `@AppStorage`).
  enum Key {
    static let cmdstanPath = "cmdstanPath"
    static let port = "serverPort"
  }

  static let defaultPort = 8080
  static let host = "0.0.0.0"

  static func cmdstanPath() -> String {
    if let stored = UserDefaults.standard.string(forKey: Key.cmdstanPath),
       !stored.isEmpty {
      return stored
    }
    if let env = ProcessInfo.processInfo.environment["CMDSTAN"], !env.isEmpty {
      return env
    }
    return "/Users/rob/Projects/StanSupport/cmdstan"
  }

  static func port() -> Int {
    let stored = UserDefaults.standard.integer(forKey: Key.port)
    return stored == 0 ? defaultPort : stored
  }

  /// The case-tree root the library writes under. Resolution lives in the
  /// library (`Support/CasePaths.swift`); this just reports what the server
  /// would use for the `/v1/health` response.
  static func stanCasesRoot() -> String {
    if let env = ProcessInfo.processInfo.environment["STAN_CASES"], !env.isEmpty {
      return (env as NSString).expandingTildeInPath
    }
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return docs.appendingPathComponent("StanCases").path
  }
}
