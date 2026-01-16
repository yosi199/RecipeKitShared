import Foundation

/// DTO for updating an existing recipe via PUT /api/recipes/:id
/// All fields are optional to support partial updates
public struct UpdateRecipeDTO: Codable, Sendable {
    public let name: String?
    public let description: String?
    public let ingredients: [String]?
    public let instructions: [String]?
    public let prepTime: Int?
    public let cookTime: Int?
    public let servings: Int?
    public let tags: [String]?
    public let image: String?
    public let isFavorite: Bool?
    
    public init(
        name: String? = nil,
        description: String? = nil,
        ingredients: [String]? = nil,
        instructions: [String]? = nil,
        prepTime: Int? = nil,
        cookTime: Int? = nil,
        servings: Int? = nil,
        tags: [String]? = nil,
        image: String? = nil,
        isFavorite: Bool? = nil
    ) {
        self.name = name
        self.description = description
        self.ingredients = ingredients
        self.instructions = instructions
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.tags = tags
        self.image = image
        self.isFavorite = isFavorite
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case ingredients
        case instructions
        case prepTime
        case cookTime
        case servings
        case tags
        case image
        case isFavorite
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        ingredients = try container.decodeIfPresent([String].self, forKey: .ingredients)
        instructions = try container.decodeIfPresent([String].self, forKey: .instructions)
        prepTime = try container.decodeIfPresent(Int.self, forKey: .prepTime)
        cookTime = try container.decodeIfPresent(Int.self, forKey: .cookTime)
        servings = try container.decodeIfPresent(Int.self, forKey: .servings)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite)
    }

    /// Check if DTO has any fields to update
    public var hasUpdates: Bool {
        name != nil || description != nil || ingredients != nil ||
        instructions != nil || prepTime != nil || cookTime != nil ||
        servings != nil || tags != nil || image != nil || isFavorite != nil
    }
}

// MARK: - Convenience Initializer
extension UpdateRecipeDTO {
    /// Create UpdateRecipeDTO from existing Recipe
    public init(from recipe: Recipe) {
        self.init(
            name: recipe.name,
            description: recipe.description,
            ingredients: recipe.ingredients,
            instructions: recipe.instructions,
            prepTime: recipe.prepTime,
            cookTime: recipe.cookTime,
            servings: recipe.servings,
            tags: recipe.tags,
            image: recipe.image,
            isFavorite: recipe.isFavorite
        )
    }
}
