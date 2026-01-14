import XCTest
@testable import RecipeKitShared

final class RecipeTests: XCTestCase {
    
    func testRecipeCodable() throws {
        let recipe = Recipe(
            id: UUID(),
            userId: UUID(),
            name: "Test Recipe",
            description: "A test recipe",
            ingredients: ["Flour", "Sugar"],
            instructions: ["Mix", "Bake"],
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            tags: ["dessert"],
            isFavorite: true
        )
        
        let encoded = try sharedJSONEncoder.encode(recipe)
        let decoded = try sharedJSONDecoder.decode(Recipe.self, from: encoded)
        
        XCTAssertEqual(recipe.id, decoded.id)
        XCTAssertEqual(recipe.name, decoded.name)
        XCTAssertEqual(recipe.ingredients, decoded.ingredients)
        XCTAssertEqual(recipe.instructions, decoded.instructions)
        XCTAssertEqual(recipe.prepTime, decoded.prepTime)
        XCTAssertEqual(recipe.cookTime, decoded.cookTime)
    }
    
    func testRecipeTotalTime() {
        let recipe = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["b"],
            prepTime: 15,
            cookTime: 30
        )
        XCTAssertEqual(recipe.totalTime, 45)
    }
    
    func testRecipeTotalTimeFormatted() {
        let recipe1 = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["b"],
            prepTime: 15,
            cookTime: 30
        )
        XCTAssertEqual(recipe1.totalTimeFormatted, "45m")
        
        let recipe2 = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["b"],
            prepTime: 30,
            cookTime: 90
        )
        XCTAssertEqual(recipe2.totalTimeFormatted, "2h")
        
        let recipe3 = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["b"],
            prepTime: 35,
            cookTime: 90
        )
        XCTAssertEqual(recipe3.totalTimeFormatted, "2h 5m")
    }
    
    func testRecipeIngredientCount() {
        let recipe = Recipe(
            name: "Test",
            ingredients: ["a", "b", "c"],
            instructions: ["x"]
        )
        XCTAssertEqual(recipe.ingredientCount, 3)
    }
    
    func testRecipeStepCount() {
        let recipe = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["x", "y", "z"]
        )
        XCTAssertEqual(recipe.stepCount, 3)
    }
    
    func testRecipeHasImage() {
        let recipeWithImage = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["x"],
            image: "https://example.com/image.jpg"
        )
        XCTAssertTrue(recipeWithImage.hasImage)
        
        let recipeWithoutImage = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["x"],
            image: nil
        )
        XCTAssertFalse(recipeWithoutImage.hasImage)
        
        let recipeWithEmptyImage = Recipe(
            name: "Test",
            ingredients: ["a"],
            instructions: ["x"],
            image: ""
        )
        XCTAssertFalse(recipeWithEmptyImage.hasImage)
    }
    
    func testRecipeJSONCodingKeys() throws {
        let json = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "userId": "660e8400-e29b-41d4-a716-446655440000",
            "name": "Test Recipe",
            "description": "A test",
            "ingredients": ["Flour", "Sugar"],
            "instructions": ["Mix", "Bake"],
            "prepTime": 10,
            "cookTime": 20,
            "servings": 4,
            "tags": ["dessert"],
            "image": null,
            "isFavorite": true,
            "createdAt": "2024-01-01T00:00:00Z",
            "updatedAt": "2024-01-01T00:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let recipe = try sharedJSONDecoder.decode(Recipe.self, from: data)
        
        XCTAssertEqual(recipe.name, "Test Recipe")
        XCTAssertEqual(recipe.prepTime, 10)
        XCTAssertEqual(recipe.cookTime, 20)
        XCTAssertEqual(recipe.servings, 4)
        XCTAssertTrue(recipe.isFavorite)
        XCTAssertEqual(recipe.ingredients.count, 2)
        XCTAssertEqual(recipe.instructions.count, 2)
    }
    
    func testSampleRecipeIsValid() {
        #if DEBUG
        let recipe = Recipe.sample
        XCTAssertFalse(recipe.name.isEmpty)
        XCTAssertFalse(recipe.ingredients.isEmpty)
        XCTAssertFalse(recipe.instructions.isEmpty)
        XCTAssertGreaterThan(recipe.servings, 0)
        #endif
    }
    
    func testSampleArrayIsValid() {
        #if DEBUG
        let recipes = Recipe.sampleArray
        XCTAssertGreaterThan(recipes.count, 0)
        for recipe in recipes {
            XCTAssertFalse(recipe.name.isEmpty)
            XCTAssertFalse(recipe.ingredients.isEmpty)
            XCTAssertFalse(recipe.instructions.isEmpty)
        }
        #endif
    }
}
