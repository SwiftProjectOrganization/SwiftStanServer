import Foundation
import OpenAPIRuntime
import SwiftStan

/// Implements the OpenAPI-generated `APIProtocol` by forwarding each operation
/// to the corresponding `SwiftStan` library function.
///
/// IMPORTANT: the method names, `Operations.*` and `Components.Schemas.*` types
/// referenced below are emitted by the Swift OpenAPI Generator build plugin from
/// `OpenAPI/openapi.yaml`. They will not exist until the plugin is wired into the
/// target (see CLAUDE.md → "First-time setup"). After the plugin runs, reconcile
/// any naming differences (idiomatic naming strategy) against the generated
/// `APIProtocol` — Xcode will flag mismatches.
///
/// Contract: every operation returns HTTP 200 with a `CommandResult`. A non-empty
/// `error` field signals a *logical* failure (mirrors the library's
/// `(String, String)` convention); real 4xx/5xx are reserved for transport faults.
struct StanAPIHandler: APIProtocol {

  // MARK: - Helpers

  /// Resolve the cmdstan path: per-request override → server config → env → default.
  private func resolveCmdstan(_ override: String?) -> String {
    if let override, !override.isEmpty { return override }
    return ServerSettings.cmdstanPath()
  }

  /// Run a synchronous, blocking library call off the cooperative thread pool so
  /// the Hummingbird event loop isn't starved during multi-minute cmdstan runs.
  private func offload<T: Sendable>(_ work: @Sendable @escaping () -> T) async -> T {
    await Task.detached(priority: .userInitiated) { work() }.value
  }

  private func ok(status: String, error: String, outputPath: String? = nil)
    -> Components.Schemas.CommandResult {
    .init(status: status, error: error, outputPath: outputPath)
  }

  /// Map a throwing URL-returning library call to a `CommandResult` payload.
  private func fileResult(_ work: @Sendable @escaping () throws -> URL) async
    -> Components.Schemas.CommandResult {
    await offload {
      do {
        let url = try work()
        return self.ok(status: "Wrote \(url.lastPathComponent)", error: "", outputPath: url.path)
      } catch {
        return self.ok(status: "", error: "\(error)")
      }
    }
  }

  // MARK: - cmdstan-backed operations (return (status, error))

  func compile(_ input: Operations.Compile.Input) async throws -> Operations.Compile.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.compile(
        model: (req.model ?? "bernoulli").lowercased(),
        arguments: req.arguments ?? [],
        cmdstan: cmdstan,
        verbose: req.verbose ?? false,
        install: req.install ?? false,
        force: req.force ?? false)
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  func sample(_ input: Operations.Sample.Input) async throws -> Operations.Sample.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.sample(
        model: (req.model ?? "bernoulli").lowercased(),
        arguments: req.arguments ?? [],
        cmdstan: cmdstan,
        verbose: req.verbose ?? false,
        nosummary: req.nosummary ?? false,
        install: req.install ?? false)
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  func optimize(_ input: Operations.Optimize.Input) async throws -> Operations.Optimize.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.optimize(
        model: (req.model ?? "bernoulli").lowercased(),
        arguments: req.arguments ?? [],
        cmdstan: cmdstan,
        verbose: req.verbose ?? false)
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  func pathfinder(_ input: Operations.Pathfinder.Input) async throws -> Operations.Pathfinder.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.pathfinder(
        model: (req.model ?? "bernoulli").lowercased(),
        arguments: req.arguments ?? [],
        cmdstan: cmdstan,
        verbose: req.verbose ?? false)
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  func laplace(_ input: Operations.Laplace.Input) async throws -> Operations.Laplace.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.laplace(
        model: (req.model ?? "bernoulli").lowercased(),
        arguments: req.arguments ?? [],
        cmdstan: cmdstan,
        verbose: req.verbose ?? false)
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  func generatedQuantities(_ input: Operations.GeneratedQuantities.Input) async throws -> Operations.GeneratedQuantities.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.generated_Quantities(
        model: (req.model ?? "bernoulli").lowercased(),
        arguments: req.arguments ?? [],
        cmdstan: cmdstan,
        verbose: req.verbose ?? false)
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  func stansummary(_ input: Operations.Stansummary.Input) async throws -> Operations.Stansummary.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.stansummary(
        model: (req.model ?? "bernoulli").lowercased(),
        arguments: req.arguments ?? [],
        cmdstan: cmdstan,
        verbose: req.verbose ?? false)
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  func ulam(_ input: Operations.Ulam.Input) async throws -> Operations.Ulam.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let cmdstan = resolveCmdstan(req.cmdstan)
    let r = await offload {
      SwiftStan.ulamPipeline(
        model: (req.model ?? "bernoulli").lowercased(),
        cmdstan: cmdstan,
        verbose: req.verbose ?? false,
        force: req.force ?? false,
        arguments: req.arguments ?? [])
    }
    return .ok(.init(body: .json(ok(status: r.0, error: r.1))))
  }

  // MARK: - Pure-Swift file-translation operations (throw / return URL)

  func csv2json(_ input: Operations.Csv2json.Input) async throws -> Operations.Csv2json.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let payload = await fileResult { try SwiftStan.csv2json(model: req.model.lowercased(), verbose: req.verbose ?? false) }
    return .ok(.init(body: .json(payload)))
  }

  func alist2dsl(_ input: Operations.Alist2dsl.Input) async throws -> Operations.Alist2dsl.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let payload = await fileResult { try SwiftStan.alist2dsl(model: req.model.lowercased(), verbose: req.verbose ?? false) }
    return .ok(.init(body: .json(payload)))
  }

  func stancode(_ input: Operations.Stancode.Input) async throws -> Operations.Stancode.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let payload = await fileResult { try SwiftStan.stancode(model: req.model.lowercased(), verbose: req.verbose ?? false) }
    return .ok(.init(body: .json(payload)))
  }

  func stan2alist(_ input: Operations.Stan2alist.Input) async throws -> Operations.Stan2alist.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let payload = await fileResult { try SwiftStan.stan2alist(model: req.model.lowercased(), verbose: req.verbose ?? false, force: req.force ?? false) }
    return .ok(.init(body: .json(payload)))
  }

  func runinfo(_ input: Operations.Runinfo.Input) async throws -> Operations.Runinfo.Output {
    guard case let .json(req) = input.body else { return .ok(.init(body: .json(ok(status: "", error: "bad request")))) }
    let payload = await fileResult { try SwiftStan.runinfo(model: req.model.lowercased(), verbose: req.verbose ?? false) }
    return .ok(.init(body: .json(payload)))
  }

  // MARK: - Health

  func health(_ input: Operations.Health.Input) async throws -> Operations.Health.Output {
    .ok(.init(body: .json(.init(
      ok: true,
      cmdstan: ServerSettings.cmdstanPath(),
      stanCases: ServerSettings.stanCasesRoot()))))
  }
}
