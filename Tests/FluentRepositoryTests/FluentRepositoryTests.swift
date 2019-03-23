import XCTest
import Vapor
@testable import FluentRepository

final class FluentRepositoryTests: VaporTestCase {
    
    func testSanity() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssert(true)
    }
    
    func testSaveUser() {
        perform {
            let user = User(name: "foo")
            let resp = try app.getResponse(
                to: "user",
                method: .POST,
                headers: .init(),
                data: user,
                decodeTo: User.self
            )
            
            XCTAssertEqual(resp.name, "foo")
        }
    }
    
    func testGetAll() {
        perform {
            let resp = try app.getResponse(
                to: "user", decodeTo: [User].self)
            XCTAssertEqual(resp.count, 0)
        }
    }
    
    func testGetOne() {
        perform {
            let user = User(name: "foo")
            let savedUser = try app.getResponse(
                to: "user",
                method: .POST,
                data: user,
                decodeTo: User.self
            )
            
            let id = try savedUser.requireID()
            let repo = try app.make(UserRepository.self)
            
            let fetched = try repo.find(id: id).wait()
            XCTAssertEqual(fetched!.id!, id)
        }
    }
    
    func testDelete() {
        perform {
            let user = User(name: "foo")
            let savedUser = try app.getResponse(
                to: "user",
                method: .POST,
                data: user,
                decodeTo: User.self
            )
            
            let id = try savedUser.requireID()
            let url = "user/\(id)"
            
            let resp = try app.sendRequest(
                to: url,
                method: .DELETE
            )
            
            XCTAssertEqual(resp.http.status, .ok)
        }
    }
    
    func testDeleteThrows() {
        perform {
            let repo = try app.make(UserRepository.self)
            XCTAssertThrowsError(try repo.delete(id: 100).wait())
            
        }
    }

    static var allTests = [
        ("testSanity", testSanity),
        ("testSaveUser", testSaveUser),
        ("testGetAll", testGetAll),
        ("testGetOne", testGetOne),
        ("testDelete", testDelete),
    ]
}
