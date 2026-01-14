import Foundation

/// Validation rules for recipes
public struct RecipeValidator {
    
    // MARK: - Validation Constants
    
    public static let minNameLength = 1
    public static let maxNameLength = 255
    public static let maxDescriptionLength = 5000
    public static let minIngredients = 1
    public static let maxIngredients = 100
    public static let minInstructions = 1
    public static let maxInstructions = 100
    public static let minServings = 1
    public static let maxServings = 1000
    public static let minTime = 0
    public static let maxTime = 10080  // 1 week in minutes
    
    // MARK: - Validation Methods
    
    /// Validate a CreateRecipeDTO
    public static func validate(_ dto: CreateRecipeDTO) throws {
        try validateName(dto.name)
        try validateDescription(dto.description)
        try validateIngredients(dto.ingredients)
        try validateInstructions(dto.instructions)
        try validateTime(prepTime: dto.prepTime, cookTime: dto.cookTime)
        try validateServings(dto.servings)
    }
    
    /// Validate an UpdateRecipeDTO
    public static func validate(_ dto: UpdateRecipeDTO) throws {
        if let name = dto.name {
            try validateName(name)
        }
        if let description = dto.description {
            try validateDescription(description)
        }
        if let ingredients = dto.ingredients {
            try validateIngredients(ingredients)
        }
        if let instructions = dto.instructions {
            try validateInstructions(instructions)
        }
        if let prepTime = dto.prepTime, let cookTime = dto.cookTime {
            try validateTime(prepTime: prepTime, cookTime: cookTime)
        } else if let prepTime = dto.prepTime {
            try validateTime(prepTime: prepTime, cookTime: 0)
        } else if let cookTime = dto.cookTime {
            try validateTime(prepTime: 0, cookTime: cookTime)
        }
        if let servings = dto.servings {
            try validateServings(servings)
        }
    }
    
    // MARK: - Individual Field Validators
    
    public static func validateName(_ name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ValidationError.fieldRequired("Recipe name is required")
        }
        guard trimmed.count >= minNameLength else {
            throw ValidationError.fieldTooShort("Recipe name must be at least \(minNameLength) character")
        }
        guard trimmed.count <= maxNameLength else {
            throw ValidationError.fieldTooLong("Recipe name cannot exceed \(maxNameLength) characters")
        }
    }
    
    public static func validateDescription(_ description: String?) throws {
        guard let description = description else { return }
        guard description.count <= maxDescriptionLength else {
            throw ValidationError.fieldTooLong("Description cannot exceed \(maxDescriptionLength) characters")
        }
    }
    
    public static func validateIngredients(_ ingredients: [String]) throws {
        guard !ingredients.isEmpty else {
            throw ValidationError.fieldRequired("At least one ingredient is required")
        }
        guard ingredients.count >= minIngredients else {
            throw ValidationError.invalidValue("Must have at least \(minIngredients) ingredient")
        }
        guard ingredients.count <= maxIngredients else {
            throw ValidationError.invalidValue("Cannot exceed \(maxIngredients) ingredients")
        }
        
        // Check each ingredient is not empty
        for (index, ingredient) in ingredients.enumerated() {
            let trimmed = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw ValidationError.invalidValue("Ingredient #\(index + 1) cannot be empty")
            }
        }
    }
    
    public static func validateInstructions(_ instructions: [String]) throws {
        guard !instructions.isEmpty else {
            throw ValidationError.fieldRequired("At least one instruction step is required")
        }
        guard instructions.count >= minInstructions else {
            throw ValidationError.invalidValue("Must have at least \(minInstructions) instruction")
        }
        guard instructions.count <= maxInstructions else {
            throw ValidationError.invalidValue("Cannot exceed \(maxInstructions) instructions")
        }
        
        // Check each instruction is not empty
        for (index, instruction) in instructions.enumerated() {
            let trimmed = instruction.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw ValidationError.invalidValue("Instruction #\(index + 1) cannot be empty")
            }
        }
    }
    
    public static func validateTime(prepTime: Int, cookTime: Int) throws {
        guard prepTime >= minTime else {
            throw ValidationError.invalidValue("Prep time cannot be negative")
        }
        guard cookTime >= minTime else {
            throw ValidationError.invalidValue("Cook time cannot be negative")
        }
        guard prepTime <= maxTime else {
            throw ValidationError.invalidValue("Prep time cannot exceed \(maxTime) minutes")
        }
        guard cookTime <= maxTime else {
            throw ValidationError.invalidValue("Cook time cannot exceed \(maxTime) minutes")
        }
    }
    
    public static func validateServings(_ servings: Int) throws {
        guard servings >= minServings else {
            throw ValidationError.invalidValue("Servings must be at least \(minServings)")
        }
        guard servings <= maxServings else {
            throw ValidationError.invalidValue("Servings cannot exceed \(maxServings)")
        }
    }
}
