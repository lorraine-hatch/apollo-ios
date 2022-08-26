import Foundation
import ArgumentParser

enum Error: LocalizedError {
  case missingSchemaDownloadConfiguration
  case fileAlreadyExists(String)
  case cannotReadFile(String)
  case cannotCreateFile(String)
  case conversionError
  case unknown(String)

  var sysexit: Int32 {
    switch self {
    case .missingSchemaDownloadConfiguration: return EX_CONFIG
    case .fileAlreadyExists: return EX_IOERR
    case .cannotReadFile: return EX_IOERR
    case .cannotCreateFile: return EX_CANTCREAT
    case .conversionError: return EX_DATAERR
    case .unknown: return EX_SOFTWARE
    }
  }

  var errorDescription: String {
    switch self {
    case .missingSchemaDownloadConfiguration: return """
      Missing schema download configuration. Hint: check the `schemaDownloadConfiguration` \
      property of your configuration.
      """

    case let .fileAlreadyExists(path): return """
      File already exists at \(path). Hint: use --overwrite to overwrite any existing \
      file at the path.
      """

    case let .cannotReadFile(path): return "Cannot read file at \(path)."

    case let .cannotCreateFile(path): return "Cannot create file at \(path)"

    case .conversionError: return "Cannot convert, source must be UTF-8."

    case let .unknown(message): return message
    }
  }

  func print() {
    Swift.print("Error: \(errorDescription)")
  }
}

extension ExitCode {
  init(_ error: CodegenCLI.Error) {
    self.init(error.sysexit)
  }
}
