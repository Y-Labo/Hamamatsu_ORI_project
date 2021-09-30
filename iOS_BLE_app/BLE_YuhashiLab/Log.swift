

import Foundation

class Log {
    private static let file = "BLELog.csv"

    static func write(_ log: String) {
        writeToFile(file: file, text: log)
    }

    private static func writeToFile(file: String, text: String) {
        guard let documentPath =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask).first else { return }

        let path = documentPath.appendingPathComponent(file)
        _ = appendText(fileURL: path, text: text)
    }

    private static func appendText(fileURL: URL, text: String) -> Bool {
        guard let stream = OutputStream(url: fileURL, append: true) else { return false }
        stream.open()

        defer { stream.close() }

        guard let data = text.data(using: .utf8) else { return false }

        let result = data.withUnsafeBytes {
            stream.write($0, maxLength: data.count)
        }

        return (result > 0)
    }
}
