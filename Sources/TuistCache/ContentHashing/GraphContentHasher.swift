import Foundation
import TSCBasic
import TuistCore
import TuistSupport

public protocol GraphContentHashing {
    /// Hashes graph
    /// - Parameters:
    ///     - filter: If `true`, `TargetNode` is hashed, otherwise it is skipped
    func contentHashes(for graph: TuistCore.Graph, filter: (TargetNode) -> Bool) throws -> [TargetNode: String]
    /// Hashes all of graph's targets
    func contentHashes(for graph: TuistCore.Graph) throws -> [TargetNode: String]
}

/// `GraphContentHasher`
/// is responsible for computing an hash that uniquely identifies a Tuist `Graph`.
/// It considers only targets that are considered cacheable: frameworks without dependencies on XCTest or on non-cacheable targets
public final class GraphContentHasher: GraphContentHashing {
    private let targetContentHasher: TargetContentHashing

    // MARK: - Init

    public convenience init(contentHasher: ContentHashing) {
        let targetContentHasher = TargetContentHasher(contentHasher: contentHasher)
        self.init(contentHasher: contentHasher, targetContentHasher: targetContentHasher)
    }

    public init(contentHasher _: ContentHashing, targetContentHasher: TargetContentHashing) {
        self.targetContentHasher = targetContentHasher
    }

    // MARK: - GraphContentHashing

    public func contentHashes(for graph: TuistCore.Graph, filter: (TargetNode) -> Bool) throws -> [TargetNode: String] {
        var visitedNodes: [TargetNode: Bool] = [:]
        let hashableTargets = graph.targets.values.flatMap { (targets: [TargetNode]) -> [TargetNode] in
            targets.compactMap { target in
                if isHashable(
                    target,
                    visited: &visitedNodes,
                    filter: filter
                ) {
                    return target
                } else {
                    return nil
                }
            }
        }
        let hashes = try hashableTargets.map {
            try targetContentHasher.contentHash(for: $0)
        }
        return Dictionary(uniqueKeysWithValues: zip(hashableTargets, hashes))
    }

    public func contentHashes(for graph: Graph) throws -> [TargetNode: String] {
        try contentHashes(for: graph, filter: { _ in true })
    }

    // MARK: - Private

    private func isHashable(
        _ target: TargetNode,
        visited: inout [TargetNode: Bool],
        filter: (TargetNode) -> Bool
    ) -> Bool {
        guard filter(target) else {
            visited[target] = false
            return false
        }
        if let visitedValue = visited[target] { return visitedValue }
        let allTargetDependenciesAreHashable = target.targetDependencies
            .allSatisfy {
                isHashable(
                    $0,
                    visited: &visited,
                    filter: filter
                )
            }
        visited[target] = allTargetDependenciesAreHashable
        return allTargetDependenciesAreHashable
    }
}
