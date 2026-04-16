# MyGithubActions
Private repository that contains custom GitHub Actions used to build all of my nuget packages

## Template workflows :

### Dotnet library
`.github/workflows/dotnetlib.yml`

This template workflow will build a dotnet library and publish it to nuget.org

#### NuGet Package Publishing Triggers

The workflow will publish packages to NuGet.org when any of the following conditions are met:

1. **Main branch**: Push to `refs/heads/main`
2. **Feature branches**: Branch name starts with `feature/`
3. **Copilot branches**: Branch name starts with `copilot/`
4. **Manual trigger**: `publishToNuget` input is set to `true`
5. **PR message request**: The last message in a Pull Request contains keywords indicating a build/package request

#### PR Message Detection

The workflow can automatically detect when a Pull Request requests a package build. The following keywords in PR comments or description will trigger a NuGet publish:

- "request to build and package"
- "please build and package"
- "build and package this version"
- "publish to nuget"
- "release to nuget"

**Example**: Add a comment to your PR with "I request to build and package this version" and the workflow will publish to NuGet when it runs.

## Composite actions

### actions/nugetversion
Generates version numbers for NuGet packages based on existing versions in the NuGet repository.

### actions/buildandtestdotnet
Builds and tests .NET projects with specified version information.