///
///  BundleManager.swift
///  Pods
///
///  Created by Tony Stone on 4/6/17.
///
///
import Foundation

private struct Default {

    struct Bundle {
        ///
        /// The extension of the store bundle created for this store.
        ///
        static let `extension`: String = "connect"

        ///
        /// Location to store the connect store bundle.
        ///
        static let directory: FileManager.SearchPathDirectory = .documentDirectory
    }
}

///
/// Internal class to create the connect bundle.
///
/// - Note: you can not use a func on self for this
///         since we are initializing a content in self.
///
internal class BundleManager {

    class func url(for name: String, bundleLocation: URL) -> URL {
        return bundleLocation.appendingPathComponent("\(name).\(Default.Bundle.extension)", isDirectory: true)
    }

    class func createIfAbsent(url: URL) throws {

        ///
        /// create direcotry will throw if the directory can't be created.  If it already exists, it will simply return.
        ///
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
}

