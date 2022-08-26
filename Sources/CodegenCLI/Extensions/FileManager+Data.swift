import Foundation
import ArgumentParser

extension FileManager {
  /// Returns the contents of the file at the specified path or throws an error.
  func unwrappedContents(atPath path: String) throws -> Data {
    guard let data = contents(atPath: path) else {
      let error = Error.cannotReadFile(path)
      error.print()

      throw ExitCode(error)
    }

    return data
  }
}
