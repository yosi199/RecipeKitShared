# Integrating RecipeKitShared into iOS App

This guide walks you through integrating the RecipeKitShared package into your iOS application.

## Prerequisites

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Step 1: Add Package Dependency

### Option A: Using Xcode GUI

1. Open your iOS project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/YOUR_USERNAME/RecipeKitShared.git`
4. Select **Dependency Rule**: "Up to Next Major Version" from **1.0.0**
5. Click **Add Package**
6. Select your app target and click **Add Package**

### Option B: Using Package.swift (for SPM-based projects)

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/RecipeKitShared.git", from: "1.0.0")
],
targets: [
    .target(
        name: "RecipeApp",
        dependencies: [
            .product(name: "RecipeKitShared", package: "RecipeKitShared")
        ]
    )
]
```

## Step 2: Create API Client

Create a type-safe API client using shared models:

**File: `Services/RecipeAPIClient.swift`**

```swift
import Foundation
import RecipeKitShared

@MainActor
class RecipeAPIClient: ObservableObject {
    let baseURL: URL
    
    init(baseURL: URL = URL(string: "https://your-vapor-app.fly.dev")!) {
        self.baseURL = baseURL
    }
    
    // MARK: - Recipes
    
    func getAllRecipes() async throws -> [Recipe] {
        let endpoint = APIEndpoint.getAllRecipes
        let url = baseURL.appendingPathComponent(endpoint.path)
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try sharedJSONDecoder.decode([Recipe].self, from: data)
    }
    
    func getRecipe(id: UUID) async throws -> Recipe {
        let endpoint = APIEndpoint.getRecipe(id: id)
        let url = baseURL.appendingPathComponent(endpoint.path)
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try sharedJSONDecoder.decode(Recipe.self, from: data)
    }
    
    func createRecipe(_ dto: CreateRecipeDTO) async throws -> Recipe {
        // Validate client-side first (better UX - immediate feedback)
        try RecipeValidator.validate(dto)
        
        let endpoint = APIEndpoint.createRecipe
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try sharedJSONEncoder.encode(dto)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try sharedJSONDecoder.decode(Recipe.self, from: data)
    }
    
    func updateRecipe(id: UUID, dto: UpdateRecipeDTO) async throws -> Recipe {
        try RecipeValidator.validate(dto)
        
        let endpoint = APIEndpoint.updateRecipe(id: id)
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try sharedJSONEncoder.encode(dto)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try sharedJSONDecoder.decode(Recipe.self, from: data)
    }
    
    func deleteRecipe(id: UUID) async throws {
        let endpoint = APIEndpoint.deleteRecipe(id: id)
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        
        let (data, _) = try await URLSession.shared.data(for: request)
        _ = try sharedJSONDecoder.decode(SuccessResponse.self, from: data)
    }
    
    func toggleFavorite(id: UUID) async throws -> Recipe {
        let endpoint = APIEndpoint.toggleFavorite(id: id)
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try sharedJSONDecoder.decode(Recipe.self, from: data)
    }
    
    // MARK: - Auth
    
    func getCurrentUser() async throws -> CurrentUserDTO {
        let endpoint = APIEndpoint.getCurrentUser
        let url = baseURL.appendingPathComponent(endpoint.path)
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try sharedJSONDecoder.decode(CurrentUserDTO.self, from: data)
    }
    
    func logout() async throws {
        let endpoint = APIEndpoint.logout
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method.rawValue
        
        let (data, _) = try await URLSession.shared.data(for: request)
        _ = try sharedJSONDecoder.decode(SuccessResponse.self, from: data)
    }
}
```

## Step 3: Use in SwiftUI Views

### Recipe List View

```swift
import SwiftUI
import RecipeKitShared

struct RecipeListView: View {
    @StateObject private var apiClient = RecipeAPIClient()
    @State private var recipes: [Recipe] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading recipes...")
                } else if let error = error {
                    ErrorView(error: error, retry: loadRecipes)
                } else {
                    List(recipes) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            RecipeRow(recipe: recipe)
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    // Show create recipe view
                }
            }
            .task {
                await loadRecipes()
            }
        }
    }
    
    func loadRecipes() async {
        isLoading = true
        error = nil
        
        do {
            recipes = try await apiClient.getAllRecipes()
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(recipe.name)
                    .font(.headline)
                Spacer()
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
            
            Text("\(recipe.ingredientCount) ingredients • \(recipe.totalTimeFormatted)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !recipe.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(recipe.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecipeRow(recipe: .sample)
}
```

### Create Recipe Form

```swift
import SwiftUI
import RecipeKitShared

struct CreateRecipeView: View {
    @StateObject private var apiClient = RecipeAPIClient()
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var ingredients: [String] = [""]
    @State private var instructions: [String] = [""]
    @State private var prepTime = 0
    @State private var cookTime = 0
    @State private var servings = 4
    @State private var tags: [String] = []
    
    @State private var validationError: String?
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Recipe Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Ingredients") {
                    ForEach(ingredients.indices, id: \.self) { index in
                        HStack {
                            TextField("Ingredient", text: $ingredients[index])
                            Button(action: { ingredients.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button("Add Ingredient", systemImage: "plus.circle.fill") {
                        ingredients.append("")
                    }
                }
                
                Section("Instructions") {
                    ForEach(instructions.indices, id: \.self) { index in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .foregroundColor(.secondary)
                            TextField("Step", text: $instructions[index], axis: .vertical)
                            Button(action: { instructions.remove(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    Button("Add Step", systemImage: "plus.circle.fill") {
                        instructions.append("")
                    }
                }
                
                Section("Details") {
                    Stepper("Prep Time: \(prepTime) min", value: $prepTime, in: 0...300, step: 5)
                    Stepper("Cook Time: \(cookTime) min", value: $cookTime, in: 0...480, step: 5)
                    Stepper("Servings: \(servings)", value: $servings, in: 1...100)
                }
                
                if let error = validationError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await saveRecipe() }
                    }
                    .disabled(isSaving)
                }
            }
        }
    }
    
    func saveRecipe() async {
        isSaving = true
        validationError = nil
        
        let dto = CreateRecipeDTO(
            name: name,
            description: description.isEmpty ? nil : description,
            ingredients: ingredients.filter { !$0.isBlank },
            instructions: instructions.filter { !$0.isBlank },
            prepTime: prepTime,
            cookTime: cookTime,
            servings: servings,
            tags: tags
        )
        
        do {
            // Validate locally before API call (immediate feedback)
            try RecipeValidator.validate(dto)
            
            _ = try await apiClient.createRecipe(dto)
            dismiss()
        } catch let error as ValidationError {
            validationError = error.localizedDescription
        } catch {
            validationError = "Failed to save recipe: \(error.localizedDescription)"
        }
        
        isSaving = false
    }
}

#Preview {
    CreateRecipeView()
}
```

## Step 4: Use SwiftUI Previews with Shared Sample Data

```swift
import SwiftUI
import RecipeKitShared

struct RecipeDetailView: View {
    let recipe: Recipe
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Recipe details...
            }
        }
        .navigationTitle(recipe.name)
    }
}

#Preview("Chocolate Chip Cookies") {
    NavigationView {
        RecipeDetailView(recipe: .sample)
    }
}

#Preview("Multiple Recipes") {
    NavigationView {
        List(Recipe.sampleArray) { recipe in
            RecipeRow(recipe: recipe)
        }
    }
}
```

## Benefits

✅ **Type Safety**: Compile errors if API changes  
✅ **Client-Side Validation**: Immediate user feedback  
✅ **Zero Duplication**: Models shared with backend  
✅ **SwiftUI Previews**: Use `.sample` data everywhere  
✅ **Computed Properties**: `totalTimeFormatted`, `ingredientCount`, etc.

## Advanced: Error Handling

```swift
enum APIError: LocalizedError {
    case validation(ValidationError)
    case network(Error)
    case server(ErrorResponse)
    
    var errorDescription: String? {
        switch self {
        case .validation(let error):
            return error.localizedDescription
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        case .server(let error):
            return error.error
        }
    }
}

extension RecipeAPIClient {
    func handleError(_ error: Error) -> APIError {
        if let validationError = error as? ValidationError {
            return .validation(validationError)
        } else if let errorResponse = error as? ErrorResponse {
            return .server(errorResponse)
        } else {
            return .network(error)
        }
    }
}
```

## Next Steps

- Implement authentication flow
- Add offline support with Core Data
- Implement image upload
- Add search and filtering
- Enjoy type-safe development!
