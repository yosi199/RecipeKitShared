import XCTest
@testable import RecipeKitShared

final class RecipeValidatorTests: XCTestCase {
    
    // MARK: - Valid Cases
    
    func testValidRecipeDTO() throws {
        let dto = CreateRecipeDTO(
            name: "Valid Recipe",
            ingredients: ["Flour", "Sugar"],
            instructions: ["Mix", "Bake"],
            prepTime: 10,
            cookTime: 20,
            servings: 4
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    // MARK: - Name Validation
    
    func testEmptyNameThrows() {
        let dto = CreateRecipeDTO(
            name: "",
            ingredients: ["Flour"],
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.fieldRequired = error else {
                XCTFail("Expected fieldRequired error, got \(error)")
                return
            }
        }
    }
    
    func testWhitespaceOnlyNameThrows() {
        let dto = CreateRecipeDTO(
            name: "   ",
            ingredients: ["Flour"],
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.fieldRequired = error else {
                XCTFail("Expected fieldRequired error")
                return
            }
        }
    }
    
    func testNameTooLongThrows() {
        let dto = CreateRecipeDTO(
            name: String(repeating: "a", count: 256), // Max is 255
            ingredients: ["Flour"],
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.fieldTooLong = error else {
                XCTFail("Expected fieldTooLong error")
                return
            }
        }
    }
    
    func testMaxLengthNameIsValid() throws {
        let dto = CreateRecipeDTO(
            name: String(repeating: "a", count: 255),
            ingredients: ["Flour"],
            instructions: ["Mix"]
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    // MARK: - Description Validation
    
    func testNilDescriptionIsValid() throws {
        let dto = CreateRecipeDTO(
            name: "Test",
            description: nil,
            ingredients: ["Flour"],
            instructions: ["Mix"]
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testDescriptionTooLongThrows() {
        let dto = CreateRecipeDTO(
            name: "Test",
            description: String(repeating: "a", count: 5001),
            ingredients: ["Flour"],
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.fieldTooLong = error else {
                XCTFail("Expected fieldTooLong error")
                return
            }
        }
    }
    
    // MARK: - Ingredients Validation
    
    func testEmptyIngredientsThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: [],
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.fieldRequired = error else {
                XCTFail("Expected fieldRequired error")
                return
            }
        }
    }
    
    func testTooManyIngredientsThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: Array(repeating: "Ingredient", count: 101), // Max is 100
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue = error else {
                XCTFail("Expected invalidValue error")
                return
            }
        }
    }
    
    func testMaxIngredientsIsValid() throws {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: Array(repeating: "Ingredient", count: 100),
            instructions: ["Mix"]
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testEmptyIngredientStringThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour", ""],
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue(let message) = error else {
                XCTFail("Expected invalidValue error")
                return
            }
            XCTAssertTrue(message.contains("Ingredient #2"))
        }
    }
    
    func testWhitespaceOnlyIngredientThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour", "   "],
            instructions: ["Mix"]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto))
    }
    
    // MARK: - Instructions Validation
    
    func testEmptyInstructionsThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: []
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.fieldRequired = error else {
                XCTFail("Expected fieldRequired error")
                return
            }
        }
    }
    
    func testTooManyInstructionsThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: Array(repeating: "Step", count: 101) // Max is 100
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue = error else {
                XCTFail("Expected invalidValue error")
                return
            }
        }
    }
    
    func testMaxInstructionsIsValid() throws {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: Array(repeating: "Step", count: 100)
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testEmptyInstructionStringThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix", ""]
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue(let message) = error else {
                XCTFail("Expected invalidValue error")
                return
            }
            XCTAssertTrue(message.contains("Instruction #2"))
        }
    }
    
    // MARK: - Time Validation
    
    func testNegativePrepTimeThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            prepTime: -1
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue = error else {
                XCTFail("Expected invalidValue error")
                return
            }
        }
    }
    
    func testNegativeCookTimeThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            cookTime: -5
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue = error else {
                XCTFail("Expected invalidValue error")
                return
            }
        }
    }
    
    func testExcessivePrepTimeThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            prepTime: 20000 // Exceeds max 10080
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue = error else {
                XCTFail("Expected invalidValue error")
                return
            }
        }
    }
    
    func testExcessiveCookTimeThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            cookTime: 20000
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto))
    }
    
    func testZeroTimeIsValid() throws {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            prepTime: 0,
            cookTime: 0
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testMaxTimeIsValid() throws {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            prepTime: 10080,
            cookTime: 10080
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    // MARK: - Servings Validation
    
    func testZeroServingsThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            servings: 0
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto)) { error in
            guard case ValidationError.invalidValue = error else {
                XCTFail("Expected invalidValue error")
                return
            }
        }
    }
    
    func testNegativeServingsThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            servings: -1
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto))
    }
    
    func testExcessiveServingsThrows() {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            servings: 1001 // Max is 1000
        )
        
        XCTAssertThrowsError(try RecipeValidator.validate(dto))
    }
    
    func testMaxServingsIsValid() throws {
        let dto = CreateRecipeDTO(
            name: "Recipe",
            ingredients: ["Flour"],
            instructions: ["Mix"],
            servings: 1000
        )
        
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    // MARK: - Update DTO Validation
    
    func testPartialUpdateValidation() throws {
        let dto = UpdateRecipeDTO(name: "New Name")
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testPartialUpdateWithInvalidField() {
        let dto = UpdateRecipeDTO(name: "")
        XCTAssertThrowsError(try RecipeValidator.validate(dto))
    }
    
    func testEmptyUpdateDTOIsValid() throws {
        let dto = UpdateRecipeDTO()
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testUpdateWithOnlyPrepTime() throws {
        let dto = UpdateRecipeDTO(prepTime: 15)
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testUpdateWithOnlyCookTime() throws {
        let dto = UpdateRecipeDTO(cookTime: 30)
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
    
    func testUpdateWithBothTimes() throws {
        let dto = UpdateRecipeDTO(prepTime: 15, cookTime: 30)
        XCTAssertNoThrow(try RecipeValidator.validate(dto))
    }
}
