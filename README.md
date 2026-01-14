# RecipeKitShared

Shared Swift models, DTOs, and validation logic for the Recipe App ecosystem.

## Features

- 🎯 Type-safe models shared between server and iOS client
- ✅ Built-in validation with detailed error messages
- 📦 Zero dependencies - pure Swift
- 🔄 ISO8601 date encoding/decoding
- 🆔 UUID-based entity identifiers

## Supported Platforms

- iOS 16.0+
- macOS 13.0+
- watchOS 9.0+
- tvOS 16.0+
- Server-side Swift (Vapor 4+)

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/RecipeKitShared.git", from: "1.0.0")
]
```

## Usage

```swift
import RecipeKitShared

// Create a recipe DTO
let dto = CreateRecipeDTO(
    name: "Chocolate Cake",
    ingredients: ["Flour", "Sugar", "Cocoa"],
    instructions: ["Mix", "Bake"],
    prepTime: 20,
    cookTime: 45,
    servings: 8
)

// Validate before sending to server
try RecipeValidator.validate(dto)

// Use in your API client or Vapor controller
```

## Models

- **User** - User account data
- **Recipe** - Recipe entity with ingredients, instructions, and metadata

## DTOs

- **CreateRecipeDTO** - For POST /api/recipes
- **UpdateRecipeDTO** - For PUT /api/recipes/:id
- **CurrentUserDTO** - For GET /api/auth/me
- **ErrorResponse** - Standard error format
- **SuccessResponse** - Standard success format

## Validation

All DTOs include built-in validation:

```swift
try RecipeValidator.validate(createDTO)  // Throws ValidationError if invalid
```

## License

MIT
