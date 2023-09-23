

import Foundation
import Swiftonize
import PythonSwiftCore
import PathKit
import ArgumentParser
//import XcodeEdit

@main
struct App: AsyncParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "swiftonize",
		abstract: "Generate static references for autocompleted resources like images, fonts and localized strings in Swift projects",
		version: "0.0",
		subcommands: [Generate.self]
	)
}

extension App {
	struct Generate: AsyncParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Generates swiftonized file")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination
		//@Argument(transform: { p -> PathKit.Path in .init(p) }) var stdlib
		//@Argument(transform: { p -> PathKit.Path in .init(p) }) var extra
		@Argument var stdlib: String?
		@Argument var extra: String?
		@Option(transform: { p -> PathKit.Path? in .init(p) }) var site
		
		func run() async throws {
			print(source)
			let processInfo = ProcessInfo()
			
			
			var lib: String = ""
			var extra: String = ""
			if let call = processInfo.arguments.first {
				let callp = PathKit.Path(call)
				if callp.isSymlink {
					let real = try callp.symlinkDestination()
					let root = real.parent()
					lib = (root + "python_stdlib").string
					extra = (root + "python-extra").string
					
				}
			}
		
			let python = PythonHandler.shared
			if !python.defaultRunning {
				python.start(stdlib: lib, app_packages: [extra ?? "./python-extra"], debug: true)
			}
			
			
			
//			let productModuleName = processInfo.environment[EnvironmentKeys.productModuleName]
//			let infoPlistFile = processInfo.environment[EnvironmentKeys.infoPlistFile]
//			let codeSignEntitlements = processInfo.environment[EnvironmentKeys.codeSignEntitlements]
//			
//			let sourceTreeURLs = SourceTreeURLs(
//				builtProductsDirURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.builtProductsDir] ?? EnvironmentKeys.builtProductsDir),
//				developerDirURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.developerDir] ?? EnvironmentKeys.developerDir),
//				sourceRootURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.sourceRoot] ?? "."),
//				sdkRootURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.sdkRoot] ?? EnvironmentKeys.sdkRoot),
//				platformURL: URL(fileURLWithPath: processInfo.environment[EnvironmentKeys.platformDir] ?? EnvironmentKeys.platformDir)
//			)
//			print(sourceTreeURLs.sdkRootURL, sourceTreeURLs.sourceRootURL)
			//            let rswiftIgnoreURL = sourceTreeURLs.sourceRootURL
			//                            .appendingPathComponent(globals.rswiftignore, isDirectory: false)
			//
			//                        let core = RswiftCore(
			//                            outputURL: outputURL,
			//                            generators: globals.generators.isEmpty ? ResourceType.allCases : globals.generators,
			//                            accessLevel: globals.accessLevel,
			//                            bundleSource: globals.bundleSource,
			//                            importModules: globals.imports,
			//                            productModuleName: productModuleName,
			//                            infoPlistFile: infoPlistFile.map(URL.init(fileURLWithPath:)),
			//                            codeSignEntitlements: codeSignEntitlements.map(URL.init(fileURLWithPath:)),
			//                            omitMainLet: globals.omitMainLet,
			//                            rswiftIgnoreURL: rswiftIgnoreURL,
			//                            sourceTreeURLs: sourceTreeURLs
			//                        )
			//
			let wrappers = try SourceFilter(root: source)
			
			for file in wrappers.sources {
				
				switch file {
				case .pyi(let path):
					try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site)
				case .py(let path):
					try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site)
				case .both(_, let pyi):
					try await build_wrapper(src: pyi, dst: file.swiftFile(destination), site: site)
				}
				
				//                guard file.isFile, file.extension == "py" else { continue }
				//                print(file)
				//                let dst = destination + "\(file.lastComponentWithoutExtension).swift"
				//                try await build_wrapper(src: file, dst: dst, site: site)
				
			}
			
		}
	}
}
//let arguments = ProcessInfo().arguments
//if arguments.count < 4 {
//    fatalError("missing arguments")
//}
//let (input, output, site_packages) = (arguments[1], arguments[2], arguments[3])
//print(input, output)
//
//print("hello world")
//PythonHandler.shared.defaultRunning.toggle()
//exit(1)
//let site = PathKit.Path(site_packages)
//let destination = Path(output)
//let wrappers = try SourceFilter(root: .init(input))
//
//for file in wrappers.sources {
//
//    switch file {
//    case .pyi(let path):
//        try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site)
//    case .py(let path):
//        try await build_wrapper(src: path, dst: file.swiftFile(destination), site: site)
//    case .both(_, let pyi):
//        try await build_wrapper(src: pyi, dst: file.swiftFile(destination), site: site)
//    }
//
//
//}
//struct EnvironmentKeys {
//	static let action = "ACTION"
//	
//	static let targetName = "TARGET_NAME"
//	static let infoPlistFile = "INFOPLIST_FILE"
//	static let productFilePath = "PROJECT_FILE_PATH"
//	static let productModuleName = "PRODUCT_MODULE_NAME"
//	static let codeSignEntitlements = "CODE_SIGN_ENTITLEMENTS"
//	
//	static let builtProductsDir = SourceTreeFolder.buildProductsDir.rawValue
//	static let developerDir = SourceTreeFolder.developerDir.rawValue
//	static let platformDir = SourceTreeFolder.platformDir.rawValue
//	static let sdkRoot = SourceTreeFolder.sdkRoot.rawValue
//	static let sourceRoot = SourceTreeFolder.sourceRoot.rawValue
//}
//
//extension ProcessInfo {
//	func environmentVariable(name: String) throws -> String {
//		guard let value = self.environment[name] else { throw ValidationError("Missing argument \(name)") }
//		return value
//	}
//}
//
//public struct SourceTreeURLs {
//	public let builtProductsDirURL: URL
//	public let developerDirURL: URL
//	public let sourceRootURL: URL
//	public let sdkRootURL: URL
//	public let platformURL: URL
//	
//	public init(builtProductsDirURL: URL, developerDirURL: URL, sourceRootURL: URL, sdkRootURL: URL, platformURL: URL) {
//		self.builtProductsDirURL = builtProductsDirURL
//		self.developerDirURL = developerDirURL
//		self.sourceRootURL = sourceRootURL
//		self.sdkRootURL = sdkRootURL
//		self.platformURL = platformURL
//	}
//	
//	public func url(for sourceTreeFolder: SourceTreeFolder) -> URL {
//		switch sourceTreeFolder {
//		case .buildProductsDir:
//			return builtProductsDirURL
//		case .developerDir:
//			return developerDirURL
//		case .sdkRoot:
//			return sdkRootURL
//		case .sourceRoot:
//			return sourceRootURL
//		case .platformDir:
//			return platformURL
//		}
//	}
//}
