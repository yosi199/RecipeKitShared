import Foundation

/// Represents a recipe in the system
public struct Recipe: Codable, Identifiable, Hashable, Sendable {
    public let id: UUID
    public let userId: UUID?
    public let name: String
    public let description: String?
    public let ingredients: [String]
    public let instructions: [String]
    public let prepTime: Int  // in minutes
    public let cookTime: Int  // in minutes
    public let servings: Int
    public let tags: [String]
    public let image: String?  // Base64 or URL
    public let isFavorite: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID? = nil,
        name: String,
        description: String? = nil,
        ingredients: [String],
        instructions: [String],
        prepTime: Int = 0,
        cookTime: Int = 0,
        servings: Int = 1,
        tags: [String] = [],
        image: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /// Total time in minutes
    public var totalTime: Int {
        prepTime + cookTime
    }
    
    /// Formatted time string for display (e.g., "1h 30m")
    public var totalTimeFormatted: String {
        let hours = totalTime / 60
        let mins = totalTime % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
        return "\(mins)m"
    }
    
    /// Number of ingredients
    public var ingredientCount: Int {
        ingredients.count
    }
    
    /// Number of steps
    public var stepCount: Int {
        instructions.count
    }
    
    /// Whether the recipe has an image
    public var hasImage: Bool {
        image != nil && !image!.isEmpty
    }
}

// MARK: - Codable Conformance
extension Recipe {
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "userId"
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
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

// MARK: - Sample Data for SwiftUI Previews
#if DEBUG
extension Recipe {
    public static let sample = Recipe(
        id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000")!,
        userId: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440000")!,
        name: "Chocolate Chip Cookies",
        description: "Classic homemade chocolate chip cookies that are crispy on the outside and chewy on the inside.",
        ingredients: [
            "2 cups all-purpose flour",
            "1 tsp baking soda",
            "1 cup butter, softened",
            "3/4 cup granulated sugar",
            "3/4 cup packed brown sugar",
            "2 large eggs",
            "2 tsp vanilla extract",
            "2 cups chocolate chips"
        ],
        instructions: [
            "Preheat oven to 375°F (190°C)",
            "Mix flour and baking soda in a bowl",
            "In another bowl, cream butter and sugars until fluffy",
            "Beat in eggs and vanilla extract",
            "Gradually blend in the flour mixture",
            "Fold in chocolate chips",
            "Drop rounded tablespoons of dough onto ungreased cookie sheets",
            "Bake for 10-12 minutes or until golden brown",
            "Cool on baking sheet for 2 minutes before transferring to wire rack"
        ],
        prepTime: 15,
        cookTime: 12,
        servings: 24,
        tags: ["dessert", "cookies", "baking", "chocolate"],
        image: nil,
        isFavorite: true,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    public static let sampleArray: [Recipe] = [
        sample,
        Recipe(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440001")!,
            userId: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440000")!,
            name: "Spaghetti Carbonara",
            description: "Traditional Italian pasta dish with eggs, cheese, and pancetta",
            ingredients: [
                "1 lb spaghetti",
                "4 large eggs",
                "1 cup grated Parmesan cheese",
                "8 oz pancetta or bacon, diced",
                "4 cloves garlic, minced",
                "Salt and black pepper to taste",
                "Fresh parsley for garnish"
            ],
            instructions: [
                "Cook spaghetti according to package directions",
                "Whisk eggs and Parmesan cheese together",
                "Cook pancetta until crispy",
                "Add garlic and cook for 1 minute",
                "Drain pasta, reserving 1 cup pasta water",
                "Toss hot pasta with pancetta",
                "Remove from heat and quickly stir in egg mixture",
                "Add pasta water as needed for creamy consistency",
                "Season with salt and pepper, garnish with parsley"
            ],
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            tags: ["pasta", "italian", "dinner"],
            isFavorite: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Recipe(
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440002")!,
            userId: UUID(uuidString: "660e8400-e29b-41d4-a716-446655440000")!,
            name: "Caesar Salad",
            description: "Crisp romaine lettuce with homemade Caesar dressing",
            ingredients: [
                "1 head romaine lettuce, chopped",
                "1/2 cup Parmesan cheese, shaved",
                "1 cup croutons",
                "2 cloves garlic",
                "2 anchovy fillets",
                "1 egg yolk",
                "2 tbsp lemon juice",
                "1 tsp Dijon mustard",
                "1/2 cup olive oil"
            ],
            instructions: [
                "Make dressing: blend garlic, anchovies, egg yolk, lemon juice, and mustard",
                "Slowly drizzle in olive oil while blending",
                "Toss lettuce with dressing",
                "Top with Parmesan and croutons",
                "Serve immediately"
            ],
            prepTime: 15,
            cookTime: 0,
            servings: 4,
            tags: ["salad", "vegetarian", "side dish"],
            isFavorite: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
#endif
