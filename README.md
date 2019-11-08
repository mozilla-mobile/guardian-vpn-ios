
# Guardian iOS
This project contains an application for iOS. It uses components from the [WireGuard](http://www.wireguard.com/) project as a git submodule.
## Environment Setup
Install swiftlint and go:
```
$ brew install swiftlint go
```
## Cloning
If the repository is already cloned without the submodule (if the `WireGuard` directory is empty), run:
```
$ git submodule update --init --remote --recursive
```
## Building
Build Carthage dependencies from the repository root directory:
```
$ carthage bootstrap --platform ios --no-use-binaries
```
## Releasing
Update the version/build for both the app and the network extension targets.
