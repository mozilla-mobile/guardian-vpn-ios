# Guardian iOS

This project contains an application for iOS. It uses components from the [WireGuard](http://www.wireguard.com/) project as a git submodule.

## Cloning

To include the submodule, include the `--recurse-submodules` git clone option.
If the repository is already cloned without the submodule, run `git submodule update --init --remote --recursive` before building.

## Building

- Install swiftlint and go:

```
$ brew install swiftlint go
```

- Build Carthage dependencies:

```
$ cd Guardian
$ carthage update --platform ios --no-use-binaries
```

## Releasing

Update the version/build for both the app and the network extension targets.

## MPL-2.0 License

TBD...
