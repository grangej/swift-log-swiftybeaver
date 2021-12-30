import Foundation
import SwiftyBeaver
import Logging

extension SwiftyBeaver {
    public struct LogHandler: Logging.LogHandler {
        public let label: String
        public var metadata: Logger.Metadata
        public var logLevel: Logger.Level

        public init(_ label: String, level: Logger.Level = .trace, metadata: Logger.Metadata = [:]) {
            self.label = label
            self.metadata = metadata
            self.logLevel = level
            destinations.forEach { SwiftyBeaver.addDestination($0) }
        }

        public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get { self.metadata[key] }
            set(newValue) { self.metadata[key] = newValue }
        }

        public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {

            let messageMetadata = jsonStringFromDict(metadata)
            let loggerMetadata = jsonStringFromDict(self.metadata)

            var formattedMessage = "\(source.isEmpty ? "" : "[\(source)] ")\(message)"

            if let messageMetadata = messageMetadata {
                formattedMessage += " -- messageMetadata: \(messageMetadata)"
            }

            if let loggerMetadata = loggerMetadata {
                formattedMessage += " -- loggerMetadata: \(loggerMetadata)"
            }


            switch level {
            case .trace:
                SwiftyBeaver.verbose(formattedMessage, file, function, line: Int(line), context: metadata)

            case .debug:
                SwiftyBeaver.debug(formattedMessage, file, function, line: Int(line), context: metadata)

            case .info:
                SwiftyBeaver.info(formattedMessage, file, function, line: Int(line), context: metadata)

            case .notice, .warning:
                SwiftyBeaver.warning(formattedMessage, file, function, line: Int(line), context: metadata)

            case .error, .critical:
                SwiftyBeaver.error(formattedMessage, file, function, line: Int(line), context: metadata)
            }
        }

        private func unpackMetadata(_ value: Logger.MetadataValue) -> Any {
            switch value {
            case .string(let value):
                return value
            case .stringConvertible(let value):
                return value
            case .array(let value):
                return value.map { unpackMetadata($0) }
            case .dictionary(let value):
                return value.mapValues { unpackMetadata($0) }
            }
        }

        private func jsonStringFromDict(_ dict: [String: Logger.MetadataValue]?) -> String? {

            guard let dict = dict else { return nil }
            guard !dict.isEmpty else { return nil }

            let jsonDict = unpackMetadata(.dictionary(dict))

            var jsonString: String?

            // try to create JSON string
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                jsonString = String(data: jsonData, encoding: .utf8)
            } catch {
                print("SwiftyBeaver could not create JSON from dict.")
            }
            return jsonString
        }
    }
}
