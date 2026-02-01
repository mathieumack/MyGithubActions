# MyGithubActions

Private repository that contains custom GitHub Actions to automate building and publishing .NET NuGet packages.

## 🚀 Features

- **Automatic Semantic Versioning**: Query NuGet.org and increment versions (major/minor/patch)
- **Build & Test**: Compile .NET projects with version tagging and run unit tests with code coverage
- **Automated Publishing**: Push packages to NuGet.org based on branch conditions

---

## 📦 Actions

### 1. `nugetversion` - NuGet Version Generator

Queries NuGet.org for the latest package version and generates the next version based on semantic versioning.

**Inputs:**
- `nugetPackageIdentifier` (required): Package identifier to query on NuGet.org
- `versionIncrement` (optional): Version increment type - `major`, `minor`, or `patch` (default: `minor`)

**Outputs:**
- `buildversion`: Generated build version (e.g., `1.2.0`)
- `buildversionprefix`: Version prefix for pre-release versions (e.g., `-preview-001`)

**Example:**
```yaml
- id: version
  uses: your-org/MyGithubActions/actions/nugetversion@main
  with:
    nugetPackageIdentifier: 'MyPackage.Core'
    versionIncrement: 'minor'
```

---

### 2. `buildandtestdotnet` - Build and Test .NET Library

Builds a .NET library with specified version and runs unit tests with code coverage.

**Inputs:**
- `version` (required): Build version (e.g., `1.1.0`)
- `prefix` (optional): Version prefix (e.g., `-preview-31`)
- `workingDirectory` (optional): Directory containing source code (default: `src`)
- `dotnet-version` (optional): .NET SDK versions to install (default: `9.0.x, 10.0.x`)

**Example:**
```yaml
- uses: your-org/MyGithubActions/actions/buildandtestdotnet@main
  with:
    version: '1.2.0'
    prefix: '-preview-001'
    workingDirectory: 'src'
```

---

### 3. `dotnetlibworkflow` - Complete NuGet Workflow

Composite action that orchestrates the complete workflow: versioning, building, testing, and publishing.

**Inputs:**
- `nugetPackageIdentifier` (required): NuGet package identifier
- `nugetApiKey` (required): NuGet.org API key
- `publishToNuget` (optional): Force publish to NuGet.org (default: `false`)
- `workingDirectory` (optional): Source directory (default: `src`)
- `versionIncrement` (optional): `major`, `minor`, or `patch` (default: `minor`)

**Outputs:**
- `BUILD_VERSION`: Generated package version
- `BUILD_VERSION_PREFIX`: Version prefix

---

## 📋 Usage Example

Create `.github/workflows/dotnetlib.yml` in your repository:

```yaml
name: Build and Publish NuGet Package

on:
  push:
    branches: [ main, feature/** ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: your-org/MyGithubActions/dotnetlibworkflow@main
        with:
          nugetPackageIdentifier: 'MyCompany.MyPackage'
          nugetApiKey: ${{ secrets.NUGET_API_KEY }}
          versionIncrement: 'minor'
          workingDirectory: 'src'
```

---

## ⚙️ Configuration

### Required Secrets

Add these secrets to your repository:
- `NUGET_API_KEY`: Your NuGet.org API key

---

## 🔄 Version Increment Strategy

- **patch** (`1.0.0` → `1.0.1`): Bug fixes
- **minor** (`1.0.0` → `1.1.0`): New features, backward compatible
- **major** (`1.0.0` → `2.0.0`): Breaking changes

---

## 📝 Publishing Rules

Packages are automatically published to NuGet.org when:
- Pushed to `main` branch (stable release)
- Pushed to `feature/*` branches (pre-release with `-preview-XXX` suffix)
- `publishToNuget` is set to `true`

---

## 🛠️ Development

To test actions locally, use [act](https://github.com/nektos/act):
```bash
act -j build
```

---

## 📄 License

See [LICENSE](LICENSE) file for details.