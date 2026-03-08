---
sidebar_position: 2
---

# standard library
the pillarworks kit's "standard library" is a collection of utilities that are used throughout the kit.

they can be used to create objects, but are also used **outside of the kit itself** in areas such as **game logic**. this means they are *extendable* and are designed to be *easily integrated* into other systems.

## attribute utils
this module provides utilities for working with attributes.
- to get the attributes of an object, use the `get` function.

### attribute types
- strings can be accessed using `attributes.string`.
- numbers can be accessed using `attributes.number`.
- booleans can be accessed using `attributes.boolean`.
- cframes can be accessed using `attributes.cframe`.

## property utils
this module provides utilities for working with properties.
- to check if an instance has a property, use the `has_property` function.
- to get a property's value, use the `get_property` function.
- to set a property's value, use the `set_property` function.

## object utils
this module provides utilities for creating kit objects.
- to register a kit object, use the `register` function.

## player utils
this module provides utilities for working with players.
- to get the player from a hit part, use the `from_hit` function.
- to reliably get the local player, use the `get_player` function.
- to reliably get the player's character, use the `get_character` function.
- to reliably get the player's humanoid, use the `get_humanoid` function.