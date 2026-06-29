import Foundation

/// Bounded, observable log of command requests handled by `StanAPIHandler`.
/// Owned by `ServerController` and read by `ContentView` via the controller's
/// environment object.
@Observable
@MainActor
final class RequestLog {
  struct Entry: Identifiable {
    let id = UUID()
    let command: String
    let model: String
    let status: String
    let date: Date
    let success: Bool
  }

  private(set) var entries: [Entry] = []
  private let maxEntries = 200

  func record(command: String, model: String, status: String, success: Bool, date: Date = Date()) {
    entries.append(Entry(command: command, model: model, status: status, date: date, success: success))
    if entries.count > maxEntries {
      entries.removeFirst(entries.count - maxEntries)
    }
  }
}
