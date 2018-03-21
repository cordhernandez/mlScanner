<!-- ![](Graphics/Letterhead-Clear-Black.png) -->
<img src="Graphics/Letterhead-Clear-Black.png" width=400> </img>
======================================================================

#### > A SWIFT LOGGER

##### Archeota: Keeper of the archives

---

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/RedRoma/Sulcus.svg?branch=develop)](https://travis-ci.org/RedRoma/Sulcus)

# Download

## Carthage

```
github "RedRoma/Archeota"
```

# API

The Archeota Logger can be accessed by importing the Archeota package.

```swift
import Archeota
```

From there, interact with the `LOG` object to print messages.

```swift
LOG.debug("Debug messages are verbose messages useful for debugging")
LOG.info("Info messages are for FYI-level messages")
LOG.warn("Warn messages are for errors and weird situations that does not adversely impact the user experience")
LOG.error("Error messages are the most severe messages, and represent messages that affect the user's experience.")
```

## Settings

### Log Level
You can adjust the Log Level by tuning the `LOG.level` enum.
The Logger will ignore messages that are below this level.

```swift
LOG.level = .warn

LOG.info("Info and Debug messages are ignored")
LOG.warn("Warn and Error messages are printed")
```
The default `LogLevel` is `.info`.
