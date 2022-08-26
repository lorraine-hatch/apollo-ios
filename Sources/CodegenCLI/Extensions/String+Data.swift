import Foundation
import ArgumentParser

extension String {
  func asData() throws -> Data {
    guard let data = data(using: .utf8) else {
      let error = Error.conversionError
      error.print()

      throw ExitCode(error)
    }

    return data
  }
}
