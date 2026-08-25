# MyGithubActions
Private repository that contains custom GitHub Actions used to build all of my nuget packages

## Template workflows :

### Dotnet library
`.github/workflows/dotnetlib.yml`

This reusable workflow builds, tests, and packs a .NET library in CI. Publishing
is performed by separate CD jobs.

#### NuGet Package Publishing

Packages from `feature/*` and `copilot/*` branches are preview versions. To
publish one, the caller must set `publishToNuget: true`, and a reviewer must
approve the `nuget-preview` environment deployment. Configure that environment
with required reviewers in every repository that calls the workflow. The input
defaults to `false`, so branch and pull-request builds never publish
automatically.

Release packages are published by the `nuget-release` environment only for a
push to `main` whose commit is associated with a merged pull request targeting
`main`. Direct pushes and pull-request builds cannot publish a release.

#### Trusted Publishing setup

Publishing uses [NuGet Trusted Publishing](https://learn.microsoft.com/nuget/nuget-org/trusted-publishing)
instead of a long-lived API key:

1. Configure NuGet.org Trusted Publishing policies for this reusable workflow
   and the `nuget-preview` and `nuget-release` GitHub environments.
2. Give the calling workflow `id-token: write` permission.
3. Pass the NuGet.org username as `nugetUser` and the package identifier as the
   `NUGETPACKAGEIDENTIFIER` secret. `NUGETAPIKEY` is no longer used.

Example caller:

```yaml
permissions:
  contents: read
  id-token: write
  pull-requests: read

jobs:
  dotnet:
    uses: mathieumack/MyGithubActions/.github/workflows/dotnetlib.yml@main
    with:
      nugetUser: my-nuget-username
      publishToNuget: false
    secrets:
      NUGETPACKAGEIDENTIFIER: My.Package
```

## Composite actions

### actions/nugetversion
Generates version numbers for NuGet packages based on existing versions in the NuGet repository.

### actions/buildandtestdotnet
Builds and tests .NET projects with specified version information.