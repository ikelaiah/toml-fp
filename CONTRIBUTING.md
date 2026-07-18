# Contributing to TOML-FP

Thank you for your interest in contributing to TOML-FP! This document provides guidelines and steps for contributing.

## Code Style

- Use Pascal case for type names: `TTOMLValue`
- Use camel case for variable names: `configFile`
- Include type information in variable names when not obvious
- Add comments for complex logic
- Follow existing code formatting

## Development Setup

1. Install Free Pascal Compiler 3.2.2 or later
2. Install Lazarus IDE 4.8 or later (required for the Lazarus project builds)
3. Clone the repository
4. Run the test suite to ensure everything works

## Testing

- Add tests for new features
- Ensure all tests pass before submitting PR
- Run both clean build modes: `lazbuild --build-all --build-mode=Debug tests/TestRunner.lpi` and `lazbuild --build-all --build-mode=Release tests/TestRunner.lpi`
- For parser changes, run the pinned conformance gate described in `tests/conformance/README.md`


## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Add/update tests
4. Update documentation
5. Submit PR with clear description

## Reporting Issues

- Use the GitHub issue tracker
- Include FPC/Lazarus version
- Provide minimal reproducible example
- Describe expected vs actual behavior

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
