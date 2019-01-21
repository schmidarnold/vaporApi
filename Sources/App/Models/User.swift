import Vapor
import FluentMySQL
import Authentication


final class User: Codable {
    var id : Int?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String){
        self.name = name
        self.username = username
        self.password = password
    }
    final class Public: Codable {
        var id: Int?
        var name: String
        var username: String
        init(id: Int?, name: String, username: String){
            self.id = id
            self.name = name
            self.username = username
        }
    }
}
extension User: MySQLModel{}
extension User: Parameter{}
extension User.Public: Content{}
extension User: Migration{}
extension User: Content{}
extension User {
    var acronyms: Children<User, Acronym>{
        return children(\.userID)
    }
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username)
    }
}
extension Future where T: User {
    func convertToPublic()->Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
    
}
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
