import FluentMySQL
import Vapor
import Authentication
/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    let databaseName: String
    /// Register providers first
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    if (env == .testing){
        databaseName = "vapor-test"
    }else{
        databaseName = "test"
    }
    

    /// Register the configured MySQL database to the database config.
    var databases = DatabasesConfig()
    let databaseConfig = MySQLDatabaseConfig(
        hostname:"192.168.0.5",
        username:"root",
        password:"admin",
        database:databaseName
    )
    let database = MySQLDatabase(config:databaseConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)
    Acronym.defaultDatabase = DatabaseIdentifier<MySQLDatabase> .mysql
    User.defaultDatabase = DatabaseIdentifier<MySQLDatabase> .mysql
    Category.defaultDatabase = DatabaseIdentifier<MySQLDatabase> .mysql
    AcronymCategoryPivot.defaultDatabase = DatabaseIdentifier<MySQLDatabase> .mysql
    //Token.defaultDatabase = DatabaseIdentifier<MySQLDatabase>.mysql
    /// Configure migrations
   // var migrations = MigrationConfig()
    //migrations.add(model:Acronym.self, database: .mysql)
   // services.register(migrations)
    
}
extension DatabaseIdentifier{
    static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return .init("test")
    }
}
