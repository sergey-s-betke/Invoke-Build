# GitHub Action "Invoke-Build"

[![GitHub release](https://img.shields.io/github/v/release/IT-Service/Invoke-Build.svg?sort=semver&logo=github)](https://github.com/IT-Service/Invoke-Build/releases)

[![Semantic Versioning](https://img.shields.io/static/v1?label=Semantic%20Versioning&message=v2.0.0&color=green&logo=semver)](https://semver.org/lang/ru/spec/v2.0.0.html)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-v1.0.0-yellow.svg?logo=git)](https://conventionalcommits.org)

This action install and invoke [InvokeBuild][] for installing dependencies.

## Usage

See [action.yml](action.yml)

Basic:

```yaml
steps:
- uses: actions/checkout@v3
- uses: actions/Invoke-Build@v1
  with:
    version: 'latest' # InvokeBuild version
    task: check # build task. Default - "."
    file: 'build/x86.build.ps1' # path for build file. Default - .build.ps1
    verbose: true # switch build log to verbose log. Default - true
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE).

## Contributions

Contributions are welcome! See [Contributor's Guide](.github/CONTRIBUTING.md).

[InvokeBuild]: https://github.com/nightroman/Invoke-Build
