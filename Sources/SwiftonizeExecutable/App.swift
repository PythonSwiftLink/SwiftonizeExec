

import Foundation
import Swiftonize
import PythonSwiftCore
import PathKit
import ArgumentParser
//import XcodeEdit


@main
struct App: AsyncParsableCommand {
	
	static var pythonlib: String? = nil
	static var extra: String? = nil
	
	static var configuration = CommandConfiguration(
		commandName: "swiftonize",
		abstract: "Generate static references for autocompleted resources like images, fonts and localized strings in Swift projects",
		version: "0.2",
		subcommands: [Generate.self]
	)
	
	@Option(transform: { s in
			Self.pythonlib = s
	}) var stdlib: Void?
	//@Option var pyextra: String?
	@Option(transform: { s in
		Self.extra = s
	}) var pyextra: Void?
	
	static func launchPython() throws {
		let processInfo = ProcessInfo()
		
		var (stdlib, extra) = try {
			if let stdlib = App.pythonlib, let pyextra = App.extra {
				return (stdlib, pyextra)
			}
			else if let call = processInfo.arguments.first {
				let callp = PathKit.Path(call)
				if callp.isSymlink {
					let real = try callp.symlinkDestination()
					let root = real.parent()
					return (
						(root + "python_stdlib").string,
						(root + "python-extra").string
					)
				}
			}
			return ("","")
		}()
		
		
		let python = PythonHandler.shared
		if !python.defaultRunning {
			python.start(stdlib: stdlib, app_packages: [extra], debug: true)
		}
	}
}

extension App {
	struct Generate: AsyncParsableCommand {
		static var configuration = CommandConfiguration(abstract: "Generates swiftonized file")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination

		@Option(transform: { p -> PathKit.Path? in .init(p) }) var site
		
		func run() async throws {
			print(source)

			try App.launchPython()
			
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
			}
			
		}
	}
}


extension App {
	struct Macro: AsyncParsableCommand {
		
		static var configuration = CommandConfiguration(abstract: "Generates macros for swiftonized packages")
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var source
		@Argument(transform: { p -> PathKit.Path in .init(p) }) var destination
		
		func run() async throws {
			
			try App.launchPython()
			
			let wrappers = try SourceFilter(root: source)
			
			for file in wrappers.sources {
				
				switch file {
				case .pyi(let path):
					break
				case .py(let path):
					break
				case .both(_, let pyi):
					break
				}
			}
			
		}
	}
}
