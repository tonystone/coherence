/*
 *   Package.swift
 *
 *   Copyright 2016 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 10/30/16.
 */
import PackageDescription

let package = Package(
    name: "Coherence",
 
    /// Note: Currently only cache is supported in SPM due to the fact that TraceLog does not export it's ObjC code to SPM
    targets: [
        Target(
            name: "Coherence",
            dependencies: [])],

    dependencies: [.Package(url: "https://github.com/tonystone/tracelog.git", majorVersion: 2)],
    
    exclude: ["_Pods.xcodeproj", "Coherence.podspec", "Docs", "Example", "Scripts","Sources/Coherence/Configuration.swift","Tests/CoherenceTests/ConfigurationTests.swift", "Sources/ConfigurationCore","Tests/ConfigurationCoreTests", "Tests/Test Data", "Tests/en.lproj"]
)

/// Added the modules to a framework module
let dylib = Product(name: "Coherence", type: .Library(.Dynamic), modules: ["Coherence"])

products.append(dylib)
