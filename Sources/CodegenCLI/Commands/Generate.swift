import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct Generate: ParsableCommand {

  // MARK: - Configuration
  
  public static var configuration = CommandConfiguration(
    abstract: "Generate Swift source code based on a code generation configuration."
  )

  @OptionGroup var inputs: InputOptions

  @Flag(
    name: .shortAndLong,
    help: "Fetch the GraphQL schema before Swift code generation."
  )
  var fetchSchema: Bool = false

  // MARK: - Implementation

  public init() { }

  public func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    codegenProvider: CodegenProvider.Type = ApolloCodegen.self,
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self
  ) throws {
    switch (inputs.string, inputs.path) {
    case let (.some(string), _):
      try generate(
        data: try string.asData(),
        codegenProvider: codegenProvider,
        schemaDownloadProvider: schemaDownloadProvider
      )

    case let (nil, path):
      let data = try fileManager.unwrappedContents(atPath: path)
      try generate(
        data: data,
        codegenProvider: codegenProvider,
        schemaDownloadProvider: schemaDownloadProvider
      )
    }
  }

  private func generate(
    data: Data,
    codegenProvider: CodegenProvider.Type,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    CodegenLogger.level = .warning

    if fetchSchema {
      guard
        let schemaDownloadConfiguration = configuration.schemaDownloadConfiguration
      else {
        let error = Error.missingSchemaDownloadConfiguration
        error.print()

        throw ExitCode(error)
      }

      try fetchSchema(
        configuration: schemaDownloadConfiguration,
        schemaDownloadProvider: schemaDownloadProvider
      )
    }

    do {
      try codegenProvider.build(with: configuration, withRootURL: rootOutputURL(for: inputs))
    }
    catch ApolloCodegenLib.FileManagerPathError.cannotCreateFile(let path) {
      let error = Error.cannotCreateFile(path)
      error.print()

      throw ExitCode(error)
    }
    catch {
      let exitError = Error.unknown(error.localizedDescription)
      exitError.print()

      throw ExitCode(exitError)
    }
  }

  private func fetchSchema(
    configuration: ApolloSchemaDownloadConfiguration,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    do {
      try schemaDownloadProvider.fetch(
        configuration: configuration,
        withRootURL: rootOutputURL(for: inputs)
      )
    }
    catch ApolloCodegenLib.FileManagerPathError.cannotCreateFile(let path) {
      let error = Error.cannotCreateFile(path)
      error.print()

      throw ExitCode(error)
    }
    catch {
      let exitError = Error.unknown(error.localizedDescription)
      exitError.print()

      throw ExitCode(exitError)
    }
  }
}
