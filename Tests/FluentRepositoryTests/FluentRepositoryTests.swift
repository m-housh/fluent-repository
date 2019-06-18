import XCTest
import Vapor
import FluentSQLite
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
            
            let fetched2 = try repo.find(id: id).wait()
            let fetched = try app.getResponse(to: "/user/\(id)", decodeTo: User.self)
            XCTAssertEqual(fetched.id!, id)
            XCTAssertEqual(fetched2!.id!, id)

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
    
    func testPagination() {
        let users = [
            User(name: "One"),
            User(name: "Two"),
            User(name: "Three")
        ]
        
        perform {
        
            _ = try users.map { user in
                return try app.getResponse(
                    to: "user",
                    method: .POST,
                    data: user,
                    decodeTo: User.self
                )
            }
            
            let query = DefaultPaginationQuery(page: 1)
            let fetched = try app.getResponse(to: "user", query: query, decodeTo: [User].self)
            XCTAssertEqual(fetched.count, 2)
            
            let query2 = DefaultPaginationQuery(page: 2)
            let fetched2 = try app.getResponse(to: "user", query: query2, decodeTo: [User].self)
            XCTAssertEqual(fetched2.count, 1)

            
        }
    }
    
    func testDefaultPaginationConfig() {
        perform {
            let config = try app.make(DefaultPaginationConfig.self)
            XCTAssertEqual(config.pageLimit, 25)
        }
    }
    
    func testInvalidPageThrowsError() {
        perform {
            let query = DefaultPaginationQuery(page: 0)
            
            let resp = try app.sendRequest(
                to: "user",
                method: .GET,
                headers: .init(),
                query: query
            )
            
            XCTAssertEqual(resp.http.status.code, 500)
            
        }
    }
    
    func testPageLimitThrowsError() {
        XCTAssertThrowsError(try DefaultPaginationConfig(pageLimit: 0))
    }
    
    func testWithConnection() {
        perform {
            let user = try app.getResponse(to: "user", method: .POST, data: User(name: "foo"), decodeTo: User.self)
            
            let repo = try app.make(UserRepository.self)
            
            let found = try repo.withConnection { conn in
                return User.query(on: conn).filter(\.name == "foo").first()
            }.wait()
            
            XCTAssertEqual(user.id!, found!.id!)
        }
    }

    static var allTests = [
        ("testSanity", testSanity),
        ("testSaveUser", testSaveUser),
        ("testGetAll", testGetAll),
        ("testGetOne", testGetOne),
        ("testDelete", testDelete),
        ("testDeleteThrows", testDeleteThrows),
        ("testPagination", testPagination),
        ("testDefaultPaginationConfig", testDefaultPaginationConfig),
        ("testInvalidPageThrowsError", testInvalidPageThrowsError),
        ("testPageLimitThrowsError", testPageLimitThrowsError),
        ("testWithConnection", testWithConnection),
    ]
}
