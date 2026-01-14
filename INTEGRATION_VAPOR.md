# Integrating RecipeKitShared into Vapor

This guide walks you through integrating the RecipeKitShared package into your Vapor backend.

## Prerequisites

- Vapor 4.0+
- PostgreSQL database
- Swift 5.9+

## Step 1: Add Dependency

Add RecipeKitShared to your Vapor project's `Package.swift`:

```swift
dependencies: [
    // ... existing Vapor dependencies
    .package(url: "https://github.com/YOUR_USERNAME/RecipeKitShared.git", from: "1.0.0")
]

targets: [
    .target(
        name: "App",
        dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            // Add RecipeKitShared
            .product(name: "RecipeKitShared", package: "RecipeKitShared")
        ]
    )
]
```

## Step 2: Migrate Database to UUID

Run this SQL migration to convert from `SERIAL` to `UUID`:

```sql
-- Drop existing tables (DESTRUCTIVE - only if acceptable)
DROP TABLE IF EXISTS recipes CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create PostgreSQL UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create users table with UUID
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    google_id VARCHAR(255) UNIQUE NOT NULL,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    picture TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create recipes table with UUID
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    ingredients JSONB NOT NULL DEFAULT '[]',
    instructions JSONB NOT NULL DEFAULT '[]',
    prep_time INTEGER DEFAULT 0,
    cook_time INTEGER DEFAULT 0,
    servings INTEGER DEFAULT 1,
    tags JSONB DEFAULT '[]',
    image TEXT,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_recipes_user_id ON recipes(user_id);
CREATE INDEX idx_recipes_is_favorite ON recipes(user_id, is_favorite);
CREATE INDEX idx_users_google_id ON users(google_id);
```

## Step 3: Update Fluent Models

Update your Fluent models to use UUID and convert to shared models:

**File: `Sources/App/Models/UserModel.swift`**

```swift
import Fluent
import Vapor
import RecipeKitShared

final class UserModel: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "google_id")
    var googleId: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "picture")
    var picture: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Children(for: \.$user)
    var recipes: [RecipeModel]
    
    init() {}
    
    init(id: UUID? = nil, googleId: String, email: String, name: String, picture: String? = nil) {
        self.id = id
        self.googleId = googleId
        self.email = email
        self.name = name
        self.picture = picture
    }
    
    // Convert to shared User model
    func toPublic() throws -> User {
        User(
            id: try requireID(),
            googleId: googleId,
            email: email,
            name: name,
            picture: picture,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}
```

**File: `Sources/App/Models/RecipeModel.swift`**

```swift
import Fluent
import Vapor
import RecipeKitShared

final class RecipeModel: Model, Content {
    static let schema = "recipes"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: UserModel
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @Field(key: "ingredients")
    var ingredients: [String]
    
    @Field(key: "instructions")
    var instructions: [String]
    
    @Field(key: "prep_time")
    var prepTime: Int
    
    @Field(key: "cook_time")
    var cookTime: Int
    
    @Field(key: "servings")
    var servings: Int
    
    @Field(key: "tags")
    var tags: [String]
    
    @OptionalField(key: "image")
    var image: String?
    
    @Field(key: "is_favorite")
    var isFavorite: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    // Convert to shared Recipe model
    func toPublic() throws -> Recipe {
        Recipe(
            id: try requireID(),
            userId: $user.id,
            name: name,
            description: description,
            ingredients: ingredients,
            instructions: instructions,
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            tags: tags,
            image: image,
            isFavorite: isFavorite,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
    
    // Create from DTO
    func update(from dto: CreateRecipeDTO) {
        self.name = dto.name
        self.description = dto.description
        self.ingredients = dto.ingredients
        self.instructions = dto.instructions
        self.prepTime = dto.prepTime
        self.cookTime = dto.cookTime
        self.servings = dto.servings
        self.tags = dto.tags
        self.image = dto.image
        self.isFavorite = dto.isFavorite
    }
    
    // Update from UpdateRecipeDTO
    func update(from dto: UpdateRecipeDTO) {
        if let name = dto.name { self.name = name }
        if let description = dto.description { self.description = description }
        if let ingredients = dto.ingredients { self.ingredients = ingredients }
        if let instructions = dto.instructions { self.instructions = instructions }
        if let prepTime = dto.prepTime { self.prepTime = prepTime }
        if let cookTime = dto.cookTime { self.cookTime = cookTime }
        if let servings = dto.servings { self.servings = servings }
        if let tags = dto.tags { self.tags = tags }
        if let image = dto.image { self.image = image }
        if let isFavorite = dto.isFavorite { self.isFavorite = isFavorite }
    }
}
```

## Step 4: Update Controllers

Update your controllers to use shared DTOs and validators:

**File: `Sources/App/Controllers/RecipeController.swift`**

```swift
import Vapor
import Fluent
import RecipeKitShared

struct RecipeController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let recipes = routes.grouped("api", "recipes")
            .grouped(AuthMiddleware())
        
        recipes.get(use: index)
        recipes.get(":id", use: show)
        recipes.post(use: create)
        recipes.put(":id", use: update)
        recipes.delete(":id", use: delete)
        recipes.patch(":id", "favorite", use: toggleFavorite)
    }
    
    // GET /api/recipes
    func index(req: Request) async throws -> [Recipe] {
        let user = try req.auth.require(UserModel.self)
        
        let recipes = try await RecipeModel.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .sort(\.$updatedAt, .descending)
            .all()
        
        return try recipes.map { try $0.toPublic() }
    }
    
    // POST /api/recipes
    func create(req: Request) async throws -> Recipe {
        // Decode using shared DTO
        let dto = try req.content.decode(CreateRecipeDTO.self)
        
        // Validate using shared validator
        try RecipeValidator.validate(dto)
        
        let user = try req.auth.require(UserModel.self)
        
        // Create database model
        let recipe = RecipeModel()
        recipe.$user.id = try user.requireID()
        recipe.update(from: dto)
        
        try await recipe.save(on: req.db)
        
        // Return shared model (client knows this type!)
        return try recipe.toPublic()
    }
    
    // PUT /api/recipes/:id
    func update(req: Request) async throws -> Recipe {
        let dto = try req.content.decode(UpdateRecipeDTO.self)
        try RecipeValidator.validate(dto)
        
        let user = try req.auth.require(UserModel.self)
        guard let recipeId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let recipe = try await RecipeModel.query(on: req.db)
            .filter(\.$id == recipeId)
            .filter(\.$user.$id == user.id!)
            .first() else {
            throw Abort(.notFound)
        }
        
        recipe.update(from: dto)
        try await recipe.save(on: req.db)
        
        return try recipe.toPublic()
    }
    
    // DELETE /api/recipes/:id
    func delete(req: Request) async throws -> SuccessResponse {
        let user = try req.auth.require(UserModel.self)
        guard let recipeId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let recipe = try await RecipeModel.query(on: req.db)
            .filter(\.$id == recipeId)
            .filter(\.$user.$id == user.id!)
            .first() else {
            throw Abort(.notFound)
        }
        
        try await recipe.delete(on: req.db)
        return SuccessResponse(success: true)
    }
    
    // PATCH /api/recipes/:id/favorite
    func toggleFavorite(req: Request) async throws -> Recipe {
        let user = try req.auth.require(UserModel.self)
        guard let recipeId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        
        guard let recipe = try await RecipeModel.query(on: req.db)
            .filter(\.$id == recipeId)
            .filter(\.$user.$id == user.id!)
            .first() else {
            throw Abort(.notFound)
        }
        
        recipe.isFavorite.toggle()
        try await recipe.save(on: req.db)
        
        return try recipe.toPublic()
    }
}
```

## Step 5: Configure JSON Encoding

**File: `Sources/App/configure.swift`**

```swift
import Vapor
import Fluent
import FluentPostgresDriver
import RecipeKitShared

public func configure(_ app: Application) throws {
    // Use shared JSON encoder/decoder with ISO8601 dates
    ContentConfiguration.global.use(encoder: sharedJSONEncoder, for: .json)
    ContentConfiguration.global.use(decoder: sharedJSONDecoder, for: .json)
    
    // Database configuration
    app.databases.use(.postgres(url: Environment.get("DATABASE_URL")!), as: .psql)
    
    // Middleware, routes, etc.
    // ...
}
```

## Benefits

✅ **Type Safety**: Compile-time checking for API contracts  
✅ **Shared Validation**: Same rules on client and server  
✅ **Zero Duplication**: Models defined once, used everywhere  
✅ **Breaking Changes**: iOS build fails if API changes  
✅ **Consistent JSON**: Shared encoder ensures compatibility

## Next Steps

- Test all endpoints with the new UUID-based models
- Update your frontend to use RecipeKitShared
- Remove old manual JSON parsing code
- Enjoy type-safe development!
