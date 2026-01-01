Foundation for making your own 3D map editor

Provides:
- Automatic MapObject registration & handling
- Automatically generated `Add` button panel GUI (based on registered MapObjects)
- Automatic inspector panel GUI (based on registered MapObject's `data`)
- Ray picking using automatically generated collision shape from given `mesh`
- Saving & loading
- 3D gizmo (position, rotation, & scale)
- Select, deselect, delete, duplicate


# Usage

1) Create a .gd script in MapObjects/ which inherits from `MapObject` and sets `mesh` (and optionally `data`), example:
```py
extends MapObject


func _ready() -> void:
        mesh = BoxMesh.new()

        data = {
                "Example key": "Example value"
        }
```
(supported value types are `bool`, `int`, `float`, `String`, and `Color`. Use `null` for just label in GUI.)

2) Export