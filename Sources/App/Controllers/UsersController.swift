import Vapor
import Crypto

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api","users")

   

        //usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use:getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.delete(User.parameter, use:deleteHandler)
        usersRoute.get(User.parameter, "acronyms", use: getAcronymsHandler)
        usersRoute.post(User.self, use: createHandler)
        usersRoute.put(User.parameter, use: updateHandler)
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
        
    }
    func createHandler(_ req: Request, user: User) throws -> Future<User.Public> {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }

    func getAllHandler(_ req: Request) throws -> Future<[User.Public]>{
        return User.query(on: req).decode(data:User.Public.self).all()
    }
    func getHandler (_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).convertToPublic()
    }
    func deleteHandler (_ req: Request) throws -> Future<HTTPStatus> {
        return try req
            .parameters
            .next(User.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    func getAcronymsHandler(_ req: Request) throws -> Future <[Acronym]> {
        return try req
            .parameters.next (User.self)
            .flatMap(to: [Acronym].self){ user in
                try user.acronyms.query(on: req).all()

        }
    }
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(
            to: User.Public.self,
            req.parameters.next(User.self),
            req.content.decode(User.self)
        ){ user, updatedUser in
            user.name = updatedUser.name
            user.username = updatedUser.username
            user.password = try BCrypt.hash(updatedUser.password)
            return user.save(on:req).convertToPublic()
        }
    }
    func loginHandler(_ req: Request) throws -> Future<Token> {
        print("User: \(User.self)" )
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save (on: req)
    }
}
