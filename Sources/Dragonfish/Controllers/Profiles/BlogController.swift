import Vapor
import Fluent
import JWT

struct BlogController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let secure = routes.grouped(
            Session.Token.authenticator(), 
            Session.Token.guardMiddleware(), 
            IdentityGuard(needs: [.user], checkProfile: true)
        )

        routes.get("", use: getPublicBlogs)
        routes.group(":blogID") { blog in 
            blog.get("", use: getPublicBlog)
        }

        secure.get("all", use: getAllBlogs)
        secure.post("new", use: createBlog)
        secure.group(":blogID") { secureBlog in 
            secureBlog.get("draft", use: getBlog)
            secureBlog.patch("update", use: updateBlog)
            secureBlog.patch("publish", use: publishBlog)
            secureBlog.patch("delete", use: deleteBlog)
        }
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

        return try await profile.$blogs.query(on: request.db).with(\.$author).paginate(for: request).map { $0.toObject() }
    }

    @Sendable
    func getBlog(request: Request) async throws -> BlogObject {
        let blogID = request.parameters.get("blogID")!
        guard let profile = request.user?.profile else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        guard let blog = try await profile.$blogs.query(on: request.db).with(\.$author).filter(\.$id == blogID).first() else {
            throw Abort(.notFound, reason: "This blog doesn't appear to exist.")
        }

        return blog.toObject()
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
    func publishBlog(request: Request) async throws -> HTTPResponseStatus {
        struct PublishBlog: Content {
            var publishedOn: Date?
        }
        let formInfo = try request.content.decode(PublishBlog.self)

        guard let profile = request.user?.profile else {
            throw Abort(.unauthorized, reason: UNAUTHORIZED_ERROR_MESSAGE)
        }

        let blogID = request.parameters.get("blogID")!
        guard let blog = try await profile.$blogs.query(on: request.db).filter(\.$id == blogID).first() else {
            throw Abort(.notFound, reason: "This blog doesn't appear to exist.")
        }

        if formInfo.publishedOn != nil {
            blog.publishedOn = formInfo.publishedOn
        } else {
            blog.publishedOn = Date.now
        }

        try await blog.save(on: request.db)
        return .ok
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