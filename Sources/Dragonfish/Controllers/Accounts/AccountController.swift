import Vapor
import Fluent
import JWT

struct AccountController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let accounts = routes.grouped("accounts")
        let secure = accounts.grouped(
            Session.Token.authenticator(), 
            Session.Token.guardMiddleware()
        )

        secure.group("profiles") { profiles in 
            profiles.grouped(IdentityGuard(needs: [.user])).get("all", use: getAll)
            profiles.grouped(IdentityGuard(needs: [.user])).post("create", use: createProfile)
            profiles.group(":profileID") { ops in 
                let guarded = ops.grouped(IdentityGuard(needs: [.user], checkProfile: true))

                guarded.get("verify", use: verifyOwnership)
                guarded.patch("update", use: updateProfile)
                guarded.patch("avatar", use: changeAvatar)
                guarded.patch("banner", use: changeBanner)
                guarded.delete("delete", use: deleteProfile)
            }
        }
    }

    // Profile routes
    @Sendable
    func verifyOwnership(request: Request) async throws -> HTTPResponseStatus {
        guard request.user?.profile != nil else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        return .ok
    }

    @Sendable
    func getAll(request: Request) async throws -> [ProfileObject] { 
        guard let account = request.user?.account else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        return try await account.$profiles.get(on: request.db).map { $0.toObject() }
    }

    @Sendable
    func createProfile(request: Request) async throws -> HTTPStatus { 
        guard let account = request.user?.account else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        let profiles = try await account.$profiles.get(on: request.db)
        if profiles.count == 3 {
            throw Abort(.forbidden, reason: "Accounts can only have a maximum of 3 profiles.")
        }

        try Profile.FormInfo.validate(content: request)
        let formInfo = try request.content.decode(Profile.FormInfo.self)

        let trimmedUsername = formInfo.username.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedUsername.count < 3 || trimmedUsername.count > 32 {
            throw Abort(.badRequest, reason: "Your username should be between 3 and 32 characters long.")
        }

        let newProfile = Profile(from: formInfo)
        try await account.$profiles.create(newProfile, on: request.db)

        return .created
    }

    @Sendable
    func updateProfile(request: Request) async throws -> String { "hello world" }

    @Sendable
    func changeAvatar(request: Request) async throws -> String { "hello world" }

    @Sendable
    func changeBanner(request: Request) async throws -> String { "hello world" }

    @Sendable
    func deleteProfile(request: Request) async throws -> String { "hello world" }
}