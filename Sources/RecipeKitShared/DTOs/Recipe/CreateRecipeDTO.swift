import Foundation

/// DTO for creating a new recipe via POST /api/recipes
public struct CreateRecipeDTO: Codable, Sendable {
    public let name: String
    public let description: String?
    public let ingredients: [String]
    public let instructions: [String]
    public let prepTime: Int
    public let cookTime: Int
    public let servings: Int
    public let tags: [String]
    public let image: String?
    public let isFavorite: Bool?
    
    public init(
        name: String,
        description: String? = nil,
        ingredients: [String],
        instructions: [String],
        prepTime: Int = 0,
        cookTime: Int = 0,
        servings: Int = 1,
        tags: [String] = [],
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
        case prepTime = "prepTime"
        case cookTime = "cookTime"
        case servings
        case tags
        case image
        case isFavorite = "isFavorite"
    }
}
