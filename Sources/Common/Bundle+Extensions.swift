///
///  Bundle+Extensions.swift
///  Pods
///
///  Created by Tony Stone on 3/5/17.
///
///
import Swift

///
/// Internal extensions on Bundle.
///
internal extension Bundle {

    ///
    /// Returns the first URL for the managedObjectModel.
    ///
    /// Note: Will search for "momd" followed by "mom"
    ///
    internal class func url(forManagedObjectModelName name: String, preferredBundle bundle: Bundle = Bundle.main) -> URL? {

        var url: URL? = bundle.url(forResource: name, withExtension: "momd") ?? bundle.url(forResource: name, withExtension: "mom")

        if url == nil {

            /// Check the inner bundles if not found in the main bundle
            for innerBundle in Bundle.allBundles {
                url = innerBundle.url(forResource: name, withExtension: "momd") ?? innerBundle.url(forResource: name, withExtension: "mom")

                if url != nil {
                    break
                }
            }
        }
        return url
    }
}
