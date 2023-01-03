# Togemon

Togemon is an open source macOS application written in Swift that allows you to toggle your external monitor on or off from the menu bar. This can be useful if you are using a computer connected to an external monitor, but the screen is not currently visible and you don't want to have to disconnect the monitor.

## Installation

To install Togemon, download the latest release from the releases page and drag the app to your Applications folder. You may have to allow unsigned applications in `Security and Privacy`.

Alternatively, you can clone the repository and build the app from source:

```
git clone https://github.com/brgj/Togemon.git
cd Togemon
xcodebuild
```

## Usage

To use Togemon, simply left-click the app icon in the menu bar. Whichever monitor the icon is clicked for will become the primary, and all other connected monitors will mirror that one. You can also right-click the icon to show a dropdown menu which details which monitors are currently visible to the operating system, and whether or not they are active or mirroring another monitor. Clicking on any of these will either toggle mirroring off, or set the selected monitor as the primary.

### Example

## License

Togemon is licensed under the Apache License v2.
