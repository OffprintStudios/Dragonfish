import Vapor
import Fluent
import JWT

struct ProfileController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let profiles = routes.grouped("profiles")

        profiles.group(":profileID") { route in 
            route.get("", use: getProfile)
            route.get("blogs", use: getPublicBlogs)
            route.group(
                Session.Token.authenticator(), 
                Session.Token.guardMiddleware(), 
                IdentityGuard(needs: [.user], checkProfile: true),
            ) { secureRoute in 
                secureRoute.get("blogs/all", use: getAllBlogs)
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

    @Sendable
    func getPublicBlogs(request: Request) async throws -> Page<BlogObject> {
        let id = request.parameters.get("profileID")!
        let includesNSFW = request.query[Bool.self, at: "nsfw"] ?? false

        let validStates: [ContentVisibility] = [.profile, .public]
        var query = Blog.query(on: request.db)
            .with(\.$author)
            .filter(\.$author.$id == id)
            .filter(\.$visibility ~~ validStates)
            .filter(\.$publishedOn != nil)
            .filter(\.$publishedOn <= Date())
        if !includesNSFW {
            query = query.filter(\.$nsfw == false)
        }
        return try await query.paginate(for: request).map { $0.toObject() }
    }

    @Sendable
    func getAllBlogs(request: Request) async throws -> Page<BlogObject> {
        guard let profile = request.user?.profile else {
            throw Abort(.unauthorized, reason: "You don't have permission to do that!")
        }

        return try await profile.$blogs.query(on: request.db).paginate(for: request).map { $0.toObject() }
    }
}