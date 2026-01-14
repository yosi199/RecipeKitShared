# RecipeKitShared - Next Steps Guide

This document provides the complete roadmap for integrating RecipeKitShared into your Recipe App ecosystem.

## Current Status ✅

**RecipeKitShared v1.0.0 is complete!**

- ✅ 21 source files (1,683 lines of Swift)
- ✅ 61 passing unit tests
- ✅ UUID-based models
- ✅ Comprehensive validation
- ✅ Integration guides for Vapor and iOS
- ✅ Git repository initialized with v1.0.0 tag

**Location:** `/Users/yosimizrachi/Documents/GitHub/Cursor Projects/RecipeKitShared`

---

## Phase 1: Publish to GitHub

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `RecipeKitShared`
3. Description: "Shared Swift models, DTOs, and validation for Recipe App"
4. Visibility: Private (or Public)
5. **DO NOT** initialize with README (already exists)
6. Click "Create repository"

### Step 2: Push to GitHub

```bash
cd "/Users/yosimizrachi/Documents/GitHub/Cursor Projects/RecipeKitShared"

# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/RecipeKitShared.git

# Push code and tags
git push -u origin main
git push --tags
```

### Step 3: Verify

- Visit https://github.com/YOUR_USERNAME/RecipeKitShared
- Verify all files are present
- Verify tag 1.0.0 exists in "Releases"

---

## Phase 2: Migrate Vapor Backend to UUID

**CRITICAL:** Your current Node.js/Express backend uses `SERIAL` (integer) IDs. RecipeKitShared uses `UUID`. You must migrate the database.

### Current Backend Location
`/Users/yosimizrachi/Documents/GitHub/Cursor Projects/Recipe App`

### Database Migration Strategy

**Option A: Clean Migration (Recommended - WIP project)**

Since your project is still in development, the cleanest approach is to drop existing tables and recreate with UUIDs.

#### SQL Migration Script

```sql
-- Connect to your PostgreSQL database
-- WARNING: This will DELETE ALL EXISTING DATA

-- Drop existing tables
DROP TABLE IF EXISTS recipes CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Enable UUID extension
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

#### How to Run Migration

**If using Railway:**
```bash
# Get your DATABASE_URL from Railway dashboard
# Then connect using psql:
psql "YOUR_DATABASE_URL" -f migration.sql
```

**If using local PostgreSQL:**
```bash
psql recipe_app_db -f migration.sql
```

### Update Node.js Backend

You have two options:

**Option A: Keep Node.js with UUID support**
- Update `db/index.js` to use the new schema
- Change all ID fields from `SERIAL` to `UUID`
- Update routes to handle UUID parameters
- Update Passport.js user serialization

**Option B: Migrate to Vapor (Server-side Swift)**
- This was the original plan for full type-safety
- Follow `INTEGRATION_VAPOR.md` guide
- Complete rewrite but shares models with iOS

**RECOMMENDATION:** Keep Node.js for now, migrate to Vapor later if desired.

---

## Phase 3: Update Node.js Backend for UUID

### Files to Modify

#### 1. Update Database Schema (`db/index.js`)

**Current (lines 16-45):**
```javascript
// Uses SERIAL for id
id SERIAL PRIMARY KEY
```

**Change to:**
```javascript
// Enable UUID extension first
await pool.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`)

// Then create tables with UUID
await pool.query(`
  CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    google_id VARCHAR(255) UNIQUE NOT NULL,
    -- ... rest of schema
  )
`)
```

#### 2. Update Routes (`routes/recipes.js`)

**Current issues:**
- Line 26: `WHERE user_id = $1` assumes INT
- Line 46: `WHERE id = $1 AND user_id = $2` assumes INT
- Line 91: INSERT returns INT

**Changes needed:**
- Update all ID parameters to accept UUID strings
- Parse UUIDs: `req.params.id` → validate UUID format
- Update Passport user serialization to use UUID

#### 3. Update Passport Config (`auth/passport.js`)

**Changes:**
- User serialization: `done(null, user.id)` (now UUID string)
- User deserialization: Find by UUID instead of INT

### Testing After Migration

```bash
# Test all endpoints
curl http://localhost:3000/api/recipes
curl http://localhost:3000/api/auth/me

# Verify UUIDs in responses
# Should see: "id": "550e8400-e29b-41d4-a716-446655440000"
# Not: "id": 123
```

---

## Phase 4: Build iOS App

### Project Setup

1. **Create new Xcode project:**
   - Product Name: "RecipeApp"
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 16.0

2. **Add RecipeKitShared dependency:**
   - File → Add Package Dependencies
   - Enter: `https://github.com/YOUR_USERNAME/RecipeKitShared.git`
   - Version: 1.0.0 - Next Major

### Recommended App Structure

```
RecipeApp/
├── RecipeApp.swift (entry point)
├── Models/
│   └── (empty - using RecipeKitShared!)
├── Services/
│   ├── RecipeAPIClient.swift
│   └── AuthService.swift
├── Views/
│   ├── RecipeList/
│   │   ├── RecipeListView.swift
│   │   └── RecipeRow.swift
│   ├── RecipeDetail/
│   │   └── RecipeDetailView.swift
│   ├── RecipeForm/
│   │   ├── CreateRecipeView.swift
│   │   └── EditRecipeView.swift
│   └── Auth/
│       └── LoginView.swift
└── ViewModels/
    ├── RecipeListViewModel.swift
    └── RecipeFormViewModel.swift
```

### Implementation Order

1. **RecipeAPIClient** (see INTEGRATION_IOS.md)
2. **RecipeListView** with sample data
3. **CreateRecipeView** with validation
4. **Authentication flow**
5. **Image upload/display**
6. **Search and filtering**

---

## Phase 5: Future Enhancements

### RecipeKitShared v2.0 Ideas

**New Models:**
- `MealPlan` - Weekly meal planning
- `ShoppingList` - Auto-generated from recipes
- `Category` - Recipe categorization
- `UserPreferences` - Dietary restrictions, favorites

**New Features:**
- Pagination support
- Search/filter DTOs
- Recipe sharing
- Ingredient substitutions
- Nutritional information

### Example: Adding MealPlan

**1. Create model in RecipeKitShared:**
```swift
// Sources/RecipeKitShared/Models/Core/MealPlan.swift
public struct MealPlan: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let meals: [PlannedMeal]
    // ...
}
```

**2. Add endpoints:**
```swift
// Sources/RecipeKitShared/Networking/APIEndpoint.swift
extension APIEndpoint {
    public static let getAllMealPlans = APIEndpoint(path: "/api/meal-plans", method: .get)
    // ...
}
```

**3. Update backend** (Node.js or Vapor)

**4. Use in iOS** - automatically gets type safety!

---

## Commands Reference

### RecipeKitShared Package

```bash
# Build
cd "/Users/yosimizrachi/Documents/GitHub/Cursor Projects/RecipeKitShared"
swift build

# Test
swift test

# Open in Xcode
xed .
```

### Node.js Backend

```bash
# Install dependencies
cd "/Users/yosimizrachi/Documents/GitHub/Cursor Projects/Recipe App"
npm install

# Run locally
npm run dev

# Deploy to Railway
git push
```

### Database

```bash
# Connect to local PostgreSQL
psql recipe_app_db

# Connect to Railway database
psql "postgresql://user:pass@host:port/database"

# Run migration
psql recipe_app_db -f migration.sql
```

---

## Troubleshooting

### Issue: "UUID not found in database"
**Solution:** Run `CREATE EXTENSION IF NOT EXISTS "pgcrypto"` in PostgreSQL

### Issue: "Type mismatch: expected String, got Int"
**Solution:** Ensure all ID fields are UUID strings, not integers

### Issue: "Package not found"
**Solution:** Make sure RecipeKitShared is pushed to GitHub with tag 1.0.0

### Issue: "Validation error but input looks valid"
**Solution:** Check for whitespace. Use `String.trimmed` extension

---

## Contact Points

**RecipeKitShared Repository:**
- Location: `/Users/yosimizrachi/Documents/GitHub/Cursor Projects/RecipeKitShared`
- Version: 1.0.0
- Tests: 61 passing

**Recipe App Backend:**
- Location: `/Users/yosimizrachi/Documents/GitHub/Cursor Projects/Recipe App`
- Framework: Node.js + Express
- Database: PostgreSQL (needs UUID migration)

**Documentation:**
- `INTEGRATION_VAPOR.md` - Vapor integration guide
- `INTEGRATION_IOS.md` - iOS integration guide
- `README.md` - Package overview

---

## Starting a New Chat Session

**To continue this migration in a new chat, simply say:**

> "I'm continuing the Recipe App migration to RecipeKitShared. The package is complete at v1.0.0. I need help with [Phase 2/3/4]. Please read NEXT_STEPS.md in the RecipeKitShared directory for context."

**The AI will:**
1. Read this NEXT_STEPS.md file
2. Understand exactly where you are
3. Continue from the appropriate phase
4. Have access to all integration guides

---

## Quick Start Commands for New Session

```bash
# Show RecipeKitShared status
cd "/Users/yosimizrachi/Documents/GitHub/Cursor Projects/RecipeKitShared"
git log --oneline
git tag

# Show current backend status
cd "/Users/yosimizrachi/Documents/GitHub/Cursor Projects/Recipe App"
cat db/index.js | grep "id SERIAL"  # Should show current INT-based schema

# Run tests
cd "/Users/yosimizrachi/Documents/GitHub/Cursor Projects/RecipeKitShared"
swift test
```

---

## Success Criteria

### Phase 1 Complete When:
- ✅ RecipeKitShared is on GitHub
- ✅ Tag 1.0.0 is published
- ✅ README and integration guides are visible

### Phase 2 Complete When:
- ✅ Database uses UUID for all IDs
- ✅ Node.js backend accepts/returns UUIDs
- ✅ All existing tests pass
- ✅ Postman/curl tests show UUID in responses

### Phase 3 Complete When:
- ✅ iOS project created
- ✅ RecipeKitShared added as dependency
- ✅ API client implemented
- ✅ Recipe list displays sample data

### Phase 4 Complete When:
- ✅ Full CRUD works from iOS
- ✅ Client-side validation prevents bad requests
- ✅ Authentication flow complete
- ✅ App submitted to TestFlight (optional)

---

**Last Updated:** 2026-01-14  
**Package Version:** 1.0.0  
**Status:** Ready for Phase 1 (GitHub publish)
