import XCTest
@testable import RecipeKitShared

final class RecipeDTOTests: XCTestCase {
    
    // MARK: - CreateRecipeDTO Tests
    
    func testCreateRecipeDTOEncoding() throws {
        let dto = CreateRecipeDTO(
            name: "Test Recipe",
            description: "A test",
            ingredients: ["Flour", "Sugar"],
            instructions: ["Mix", "Bake"],
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            tags: ["dessert"]
        )
        
        let encoded = try sharedJSONEncoder.encode(dto)
        let decoded = try sharedJSONDecoder.decode(CreateRecipeDTO.self, from: encoded)
        
        XCTAssertEqual(dto.name, decoded.name)
        XCTAssertEqual(dto.ingredients, decoded.ingredients)
        XCTAssertEqual(dto.prepTime, decoded.prepTime)
    }
    
    func testCreateRecipeDTODefaultValues() {
        let dto = CreateRecipeDTO(
            name: "Test",
            ingredients: ["Flour"],
            instructions: ["Mix"]
        )
        
        XCTAssertNil(dto.description)
        XCTAssertEqual(dto.prepTime, 0)
        XCTAssertEqual(dto.cookTime, 0)
        XCTAssertEqual(dto.servings, 1)
        XCTAssertTrue(dto.tags.isEmpty)
        XCTAssertNil(dto.image)
        XCTAssertFalse(dto.isFavorite)
    }
    
    // MARK: - UpdateRecipeDTO Tests
    
    func testUpdateRecipeDTOHasUpdates() {
        let emptyDTO = UpdateRecipeDTO()
        XCTAssertFalse(emptyDTO.hasUpdates)
        
        let dtoWithName = UpdateRecipeDTO(name: "New Name")
        XCTAssertTrue(dtoWithName.hasUpdates)
        
        let dtoWithFavorite = UpdateRecipeDTO(isFavorite: true)
        XCTAssertTrue(dtoWithFavorite.hasUpdates)
    }
    
    func testUpdateRecipeDTOPartialUpdate() throws {
        let dto = UpdateRecipeDTO(name: "Updated Name")
        
        let encoded = try sharedJSONEncoder.encode(dto)
        let decoded = try sharedJSONDecoder.decode(UpdateRecipeDTO.self, from: encoded)
        
        XCTAssertEqual(decoded.name, "Updated Name")
        XCTAssertNil(decoded.description)
        XCTAssertNil(decoded.ingredients)
        XCTAssertNil(decoded.prepTime)
    }
    
    func testUpdateRecipeDTOFromRecipe() {
        let recipe = Recipe(
            name: "Original Recipe",
            description: "A recipe",
            ingredients: ["Flour", "Sugar"],
            instructions: ["Mix", "Bake"],
            prepTime: 15,
            cookTime: 30,
            servings: 4,
            tags: ["dessert"],
            isFavorite: true
        )
        
        let dto = UpdateRecipeDTO(from: recipe)
        
        XCTAssertEqual(dto.name, recipe.name)
        XCTAssertEqual(dto.description, recipe.description)
        XCTAssertEqual(dto.ingredients, recipe.ingredients)
        XCTAssertEqual(dto.instructions, recipe.instructions)
        XCTAssertEqual(dto.prepTime, recipe.prepTime)
        XCTAssertEqual(dto.cookTime, recipe.cookTime)
        XCTAssertEqual(dto.servings, recipe.servings)
        XCTAssertEqual(dto.tags, recipe.tags)
        XCTAssertEqual(dto.isFavorite, recipe.isFavorite)
    }
    
    // MARK: - CurrentUserDTO Tests
    
    func testCurrentUserDTOEncoding() throws {
        let dto = CurrentUserDTO(
            id: UUID(),
            email: "test@example.com",
            name: "Test User",
            picture: "https://example.com/pic.jpg"
        )
        
        let encoded = try sharedJSONEncoder.encode(dto)
        let decoded = try sharedJSONDecoder.decode(CurrentUserDTO.self, from: encoded)
        
        XCTAssertEqual(dto.id, decoded.id)
        XCTAssertEqual(dto.email, decoded.email)
        XCTAssertEqual(dto.name, decoded.name)
        XCTAssertEqual(dto.picture, decoded.picture)
    }
    
    func testCurrentUserDTOToUser() {
        let dto = CurrentUserDTO(
            id: UUID(),
            email: "test@example.com",
            name: "Test User"
        )
        
        let user = dto.toUser(googleId: "123")
        
        XCTAssertEqual(user.id, dto.id)
        XCTAssertEqual(user.email, dto.email)
        XCTAssertEqual(user.name, dto.name)
        XCTAssertEqual(user.googleId, "123")
    }
    
    // MARK: - ErrorResponse Tests
    
    func testErrorResponseEncoding() throws {
        let error = ErrorResponse(error: "Something went wrong", statusCode: 400)
        
        let encoded = try sharedJSONEncoder.encode(error)
        let decoded = try sharedJSONDecoder.decode(ErrorResponse.self, from: encoded)
        
        XCTAssertEqual(decoded.error, "Something went wrong")
        XCTAssertEqual(decoded.statusCode, 400)
    }
    
    func testErrorResponseLocalizedDescription() {
        let error = ErrorResponse(error: "Not found")
        XCTAssertEqual(error.localizedDescription, "Not found")
    }
    
    // MARK: - SuccessResponse Tests
    
    func testSuccessResponseEncoding() throws {
        let response = SuccessResponse(success: true)
        
        let encoded = try sharedJSONEncoder.encode(response)
        let decoded = try sharedJSONDecoder.decode(SuccessResponse.self, from: encoded)
        
        XCTAssertTrue(decoded.success)
    }
}
