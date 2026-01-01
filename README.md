A foundation for implementing your own 3D map editor

Provides:
- Automatic MapObject registration & handling
- Automatically generated `Add` button popup panel GUI (based on registered MapObjects)
- Automatic inspector panel GUI (based on registered MapObject's `data`)
- Ray picking using automatically generated collision shape from given `mesh`
- Saving & loading
- 3D gizmo (position, rotation, & scale)
- Select, deselect, delete, duplicate

Intended to be used either directly for new games by reading from output JSON, or by feeding JSON into custom converter program which would convert it to an already existing map file format for an existing game/engine.


# Usage

1) Create a .gd script in MapObjects/ which inherits from `MapObject` and sets `mesh` (and optionally `data`), example:
```py
extends MapObject


func _init() -> void:
        mesh = BoxMesh.new()

        data = {
                "Example key": "Example value"
        }
```
(supported value types are `bool`, `int`, `float`, and `String`. Use `null` for just label in GUI.)

2) Export


# Controls

- While holding down right mouse button:
        - W = forward
        - S = back
        - A = left
        - D = right
        - Space = up
        - CTRL = down

- Click = select/deselect MapObject instance

- Alt+D = duplicate selected MapObject instance

- Del = delete selected MapObject instance

- Scroll = change camera move speed

- F = toggle Fullbright

- 0 = reset camera position to 0, 0, 0

- Esc = unfocus GUI