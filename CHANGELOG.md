# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Semantic versioning support with `major`, `minor`, and `patch` increment options
- Configurable `workingDirectory` input for flexible project structures
- `versionIncrement` parameter to control version bumps
- Comprehensive documentation with usage examples
- Test workflow (`.github/workflows/test-actions.yml`) to validate actions
- Unit tests execution enabled in build workflow with code coverage
- Enhanced .gitignore for .NET and GitHub Actions artifacts

### Changed
- Updated `actions/checkout` from v2 to v4
- Updated `actions/setup-dotnet` from v3 to v4
- Updated `actions/upload-artifact` from v3 to v4
- Replaced deprecated `::set-output` with `$GITHUB_OUTPUT`
- Improved input descriptions for all actions
- Enhanced version generation script with better error handling
- README completely rewritten with detailed usage examples

### Fixed
- Hard-coded paths replaced with configurable inputs
- Version prefix logic for pre-release versions
- Missing test execution in build workflow

### Security
- Removed default values from sensitive secret inputs
- Better handling of authentication tokens

## [1.0.0] - Previous Version
- Initial release with basic NuGet package workflow
