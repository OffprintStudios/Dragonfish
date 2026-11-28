import Vapor
import Fluent
import JWT

struct ProfileController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let profiles = routes.grouped("profiles")
        
        try profiles.group(":profileID") { profile in
            profile.get("", use: getProfile)
            try profile.group("blogs") { blogs throws in 
                try blogs.register(collection: BlogController())
            }
        }
    }

    @Sendable
    func getProfile(request: Request) async throws -> ProfileObject {
        let id = request.parameters.get("profileID")!

        guard let profile = try await Profile.find(id, on: request.db) else {
            throw Abort(.notFound, reason: "You are lost in a sea of faces, traveler. Where will you go next?")
        }

        return profile.toObject()
    }
}