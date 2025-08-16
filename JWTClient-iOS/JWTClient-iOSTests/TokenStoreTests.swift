
import XCTest
@testable import JWTClient_iOS

final class TokenStoreTests: XCTestCase {

    func testInMemoryTokenStoreSaveLoadClear() throws {
        let store = InMemoryTokenStore()
        try store.save(accessToken: "abc123", refreshToken: "ref456")
        let loaded = try store.load()
        XCTAssertEqual(loaded.accessToken, "abc123")
        XCTAssertEqual(loaded.refreshToken, "ref456")

        try store.clear()
        let cleared = try store.load()
        XCTAssertNil(cleared.accessToken)
        XCTAssertNil(cleared.refreshToken)
    }
}
