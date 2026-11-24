import Vapor
import Fluent

struct IdentityGuard: AsyncMiddleware {
    var requiredRoles: [Account.Roles]
    var checkProfile: Bool
    var optional: Bool

    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        guard let sessionToken = request.auth.get(Session.Token.self) else {
            if optional {
                return try await next.respond(to: request)
            }
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        guard try await Session.query(on: request.db)
            .filter(\.$id == sessionToken.sessionId)
            .filter(\.$account.$id == sessionToken.accountId)
            .filter(\.$expiresOn > Date.now)
            .first() != nil else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        guard let account = try await Account.find(sessionToken.accountId, on: request.db) else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        guard canAccess(needs: requiredRoles, has: account.roles) else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        if checkProfile == true {
            let possibleID = request.parameters.get("profileID") ?? request.query["profileID"]
            guard let profileID = possibleID else {
                throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
            }

            guard let profile = try? await account.$profiles.query(on: request.db).filter(\.$id == profileID).first() else {
                request.logger.error("An attempt to authorize a profile's access level has failed. [Profile ID: \(profileID)] [Account ID: \(account.id?.uuidString ?? "")]")
                throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
            }

            request.user = .init(account: account, profile: profile)
        } else {
            request.user = .init(account: account, profile: nil)
        }

        return try await next.respond(to: request)
    }

    init(needs requiredRoles: [Account.Roles], checkProfile: Bool = false, optional: Bool = false) {
        self.requiredRoles = requiredRoles
        self.checkProfile = checkProfile
        self.optional = optional
    }
}