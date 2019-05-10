# FluentRepository

A *Vapor* provider to allow for easy adoption of the repository pattern found in
the [Style Guid](https://docs.vapor.codes/3.0/extras/style-guide/).


## Usage
--------

### configure.swift

Register the Fluent database provider for your project.

``` swift

    func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
        
        /// Register providers first.
        try services.register(FluentSQLiteProvider())
        ...
    }

```

### SQLiteBaseRepository.swift

Create a base repository for your application that all your repositories can
inherit from.

``` swift

    class SQLiteBaseRepository<M, R>: BaseRepository<M, SQLiteDatabase> where M:
    Model, M.Database == SQLiteDatabase { }

    extension SQLiteBaseRepository: ServiceType {
        
        static var serviceSupports: [Any.Type] { 
            return [R.self]
        }

        static func makeService(for container: Container) throws -> Self {
            return .init(try container.connectionPool(to: .sqlite)
        }

    }
```

### User.swift

Create a model to use in the application.

``` swift

    struct User: SQLiteModel, Migration, Parameter, Content {
        var id: Int?
        var name: String
    
        init(id: Int? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
```

### UserRepository.swift

Create a repository that can be used for the *User* model.  The basic CRUD
methods below will all work out of the box when inheriting from
a *BaseRepository*.

``` swift

    /// Create a generic representation of the repository, this will allow
    /// the backend to easily be switched out if needed.

    protocol UserRepository {
        
        func all() -> Future<[User]>
        func find(id: Int) -> Future<User?>
        func save(_ user: User) -> Future<User>
        func delete(id: Int) -> Future<Void>

    }

    /// Create the concrete repository that can be used with our SQLite
    database.

    final class SQLiteUserRepository: SQLiteBaseRepository<User, UserRepository>
    { }

    extension SQLiteUserRepository: UserRepository { }

```

### UserController.swift

Create a controller that uses the repository.

``` swift

    /// seealso: RepositoryRouteController
    /// seealso: BasicRouteController
    final class UserController: BasicRouteController<SQLiteUserRepository> { }
    
    /// seealso: RepositoryRouteController
    extension UserController: RouteCollection { }

```

### routes.swift

Register your routes.

``` swift

    func routes(_ router: Router, _ container: Container) throws {
        try router.register(collection: UserController("/user", on: container))
    }
    
```
