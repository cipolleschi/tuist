import Foundation

@discardableResult
func dumpIfNeeded<E: Encodable>(_ entity: E) -> Bool {
    guard
        CommandLine.argc > 0,
        CommandLine.arguments.contains("--tuist-dump")
    else { return false }
    let encoder = JSONEncoder()
    // swiftlint:disable:next force_try
    let data = try! encoder.encode(entity)
    let manifest = String(data: data, encoding: .utf8)!
    print("TUIST_MANIFEST_START")
    print(manifest)
    print("TUIST_MANIFEST_END")
    return true
}
