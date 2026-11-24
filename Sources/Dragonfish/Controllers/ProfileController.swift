import Vapor
import Fluent
import JWT

struct ProfileController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let profiles = routes.grouped("profiles")

        profiles.group(":profileID") { route in 
            route.get("", use: getProfile)
            route.group("blogs") { blogs in 
                let secure = blogs.grouped(
                    Session.Token.authenticator(), 
                    Session.Token.guardMiddleware(), 
                    IdentityGuard(needs: [.user], checkProfile: true)
                )

                blogs.get("", use: getPublicBlogs)
                secure.get("all", use: getAllBlogs)
                secure.post("new", use: createBlog)
                blogs.group(":blogID") { blogs in 
                    let secure = blogs.grouped(
                        Session.Token.authenticator(), 
                        Session.Token.guardMiddleware(), 
                        IdentityGuard(needs: [.user], checkProfile: true)
                    )

                    blogs.get("", use: getPublicBlog)
                    secure.group(":blogID") { route in 
                        secure.patch("update", use: updateBlog)
                        secure.patch("delete", use: deleteBlog)
                    }
                }
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
    func getPublicBlog(request: Request) async throws -> BlogObject {
        let profileID = request.parameters.get("profileID")!
        let blogID = request.parameters.get("blogID")!
        let includesNSFW = request.query[Bool.self, at: "nsfw"] ?? false

        let validStates: [ContentVisibility] = [.profile, .public]
        var query = Blog.query(on: request.db)
            .with(\.$author)
            .filter(\.$id == blogID)
            .filter(\.$author.$id == profileID)
            .filter(\.$visibility ~~ validStates)
            .filter(\.$publishedOn != nil)
            .filter(\.$publishedOn <= Date())
        if !includesNSFW {
            query = query.filter(\.$nsfw == false)
        }

        guard let blog = try await query.first() else {
            throw Abort(.notFound, reason: "The blog you're looking for cannot be found.")
        }
        return blog.toObject()
    }

    @Sendable
    func getAllBlogs(request: Request) async throws -> Page<BlogObject> {
        guard let profile = request.user?.profile else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        return try await profile.$blogs.query(on: request.db).paginate(for: request).map { $0.toObject() }
    }

    @Sendable
    func createBlog(request: Request) async throws -> HTTPResponseStatus {
        guard let profile = request.user?.profile else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }
        try Blog.CreateForm.validate(content: request)
        let formInfo = try request.content.decode(Blog.CreateForm.self)

        let newBlog = Blog(from: formInfo)
        try await profile.$blogs.create(newBlog, on: request.db)

        return .created
    }

    @Sendable
    func updateBlog(request: Request) async throws -> BlogObject {
        guard let profile = request.user?.profile else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        let blogID = request.parameters.get("blogID")!
        try Blog.UpdateForm.validate(content: request)
        let formInfo = try request.content.decode(Blog.UpdateForm.self)

        guard let blog = try await profile.$blogs.query(on: request.db).with(\.$author).filter(\.$id == blogID).first() else {
            throw Abort(.expectationFailed, reason: GENERIC_ERROR_MESSAGE)
        }

        blog.title = formInfo.title
        blog.body = formInfo.body
        blog.nsfw = formInfo.nsfw
        blog.license = formInfo.license
        blog.visibility = formInfo.visibility
        if formInfo.publishedOn != nil {
            blog.editedOn = Date.now
        }
        blog.publishedOn = formInfo.publishedOn

        try await blog.save(on: request.db)
        return blog.toObject()
    }

    @Sendable
    func deleteBlog(request: Request) async throws -> HTTPResponseStatus {
        guard let profile = request.user?.profile else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        let blogID = request.parameters.get("blogID")!
        try await profile.$blogs.query(on: request.db).filter(\.$id == blogID).delete()

        return .ok
    }
}