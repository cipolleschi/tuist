import Foundation
import TuistAutomation
import TuistCache
import TuistGenerator
import XCTest

@testable import TuistCore
@testable import TuistCoreTesting
@testable import TuistKit
@testable import TuistSupportTesting

final class AutomationProjectMapperProviderTests: TuistUnitTestCase {
    private var subject: AutomationProjectMapperProvider!
    private var contentHasher: MockContentHasher!
    private var projectMapperProvider: MockProjectMapperProvider!

    override func setUpWithError() throws {
        try super.setUpWithError()
        contentHasher = .init()
        projectMapperProvider = .init()
        subject = AutomationProjectMapperProvider(
            xcodeProjDirectory: try temporaryPath(),
            projectMapperProvider: projectMapperProvider
        )
    }

    override func tearDown() {
        contentHasher = nil
        projectMapperProvider = nil
        subject = nil
        super.tearDown()
    }

    func test_map_when_disableAutogeneratedSchemes() throws {
        // When
        let got = subject.mapper(
            config: Config.test(
                generationOptions: [
                    .disableAutogeneratedSchemes,
                ]
            )
        )

        // Then
        let sequentialProjectMapper = try XCTUnwrap(got as? SequentialProjectMapper)
        XCTAssertEqual(
            sequentialProjectMapper.mappers
                .filter { $0 is AutogeneratedSchemesProjectMapper }.count,
            1
        )
    }

    func test_map() throws {
        // When
        let got = subject.mapper(
            config: Config.test()
        )

        // Then
        let sequentialProjectMapper = try XCTUnwrap(got as? SequentialProjectMapper)
        XCTAssertEqual(
            sequentialProjectMapper.mappers.filter { $0 is AutomationPathProjectMapper }.count,
            1
        )
        XCTAssertEqual(
            sequentialProjectMapper.mappers.filter { $0 is AutogeneratedSchemesProjectMapper }.count,
            0
        )
    }
}
