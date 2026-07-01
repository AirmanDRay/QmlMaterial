import QtQuick
import QtQuick.Templates as T
import Qcm.Material as MD

MD.MState {
    id: root

    // Qt 6.8 compatibility note: T.TableViewDelegate was only added in
    // Qt 6.10. TableViewDelegate.qml (the only place `item` is ever
    // assigned) is based on T.ItemDelegate now, so this type is loosened
    // to match. This file has no `pragma ComponentBehavior: Bound`, so
    // the extra properties read off `item` below (selected, rowHovered,
    // etc.) resolve dynamically against the actual instance at runtime
    // rather than being statically checked against this declared type
    // -- nothing else here needs to change.
    required property T.ItemDelegate item

    elevation: MD.Token.elevation.level0
    readonly property bool selected: item.selected || item.highlighted

    textColor: root.ctx.color.on_surface
    backgroundColor: root.selected ? root.ctx.color.surface_container_highest : root.ctx.color.surface
    outlineColor: root.ctx.color.outline_variant
    supportTextColor: root.ctx.color.on_surface_variant
    stateLayerOpacity: 0.0
    stateLayerColor: root.ctx.color.on_surface

    state: MD.Util.stateText(item.enabled, item.pressed, item.rowHovered, item.visualFocus)

    states: [
        State {
            name: "disabled"
            PropertyChanges {
                root.elevation: MD.Token.elevation.level0
                root.textColor: root.ctx.color.on_surface
                root.supportTextColor: root.ctx.color.on_surface
                root.backgroundColor: root.ctx.color.on_surface
                root.contentOpacity: MD.Token.state.disabled_content
                root.backgroundOpacity: MD.Token.state.disabled_content
            }
        },
        State {
            name: "pressed"
            PropertyChanges {
                root.stateLayerOpacity: MD.Token.state.pressed.state_layer_opacity
            }
        },
        State {
            name: "hovered"
            PropertyChanges {
                root.stateLayerOpacity: MD.Token.state.hover.state_layer_opacity
            }
        },
        State {
            name: "focus"
            PropertyChanges {
                root.stateLayerOpacity: MD.Token.state.focus.state_layer_opacity
            }
        }
    ]
}
