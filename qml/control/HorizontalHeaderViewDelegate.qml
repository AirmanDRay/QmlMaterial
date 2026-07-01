pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qcm.Material as MD

// Qt 6.8 compatibility note:
// T.HeaderViewDelegate was only added in Qt 6.10. MD.ItemDelegate (this
// module's own thin wrapper around T.ItemDelegate) is used as the base
// instead, so this also inherits its implicitWidth/implicitHeight
// formula rather than redeclaring one.
//
// Reconstructed by hand:
//   - row / column / model / selected: the standard TableView
//     "required property" convention. HorizontalHeaderView is itself
//     built on TableView under the hood, so declaring `required
//     property bool selected` here keeps it genuinely synced with the
//     syncView's selectionModel, exactly as T.HeaderViewDelegate would
//     — this sync has never been gated behind 6.10, TableView has
//     supported it since 6.2.
//   - headerView: recovered via the TableView.view attached property
//     (available since Qt 5.14), cast to T.HorizontalHeaderView — which,
//     unlike plain TableView, genuinely is a QtQuick.Templates type as
//     of Qt 6.8 (see HorizontalHeaderView.qml in this module).
MD.ItemDelegate {
    id: control

    leftPadding: 16
    rightPadding: 16
    topPadding: 8
    bottomPadding: 8

    required property int column
    required property int row
    required property var model
    required property bool selected

    readonly property T.HorizontalHeaderView headerView: TableView.view as T.HorizontalHeaderView
    readonly property int section: Math.max(row, column)
    readonly property string textRole: control.headerView?.textRole ?? ""
    readonly property int columns: {
        const syncColumns = control.headerView?.syncView?.columns ?? 0;
        if (syncColumns > 0)
            return syncColumns;
        const headerModel = control.headerView?.model;
        if (Array.isArray(headerModel))
            return headerModel.length;
        if (typeof headerModel?.length === "number")
            return headerModel.length;
        const headerColumns = control.headerView?.columns ?? 0;
        if (headerColumns > 0)
            return headerColumns;
        return control.headerView?.syncView?.columns ?? 0;
    }
    readonly property int radius: (control.headerView?.syncView as MD.TableView)?.effectiveRadius ?? 0
    readonly property MD.corners corners: MD.Util.corners(section === 0 ? radius : 0, section + 1 === columns ? radius : 0, 0, 0)
    readonly property var displayText: {
        if (control.model === undefined || control.model === null)
            return "";
        if (control.textRole.length > 0 && control.model[control.textRole] !== undefined)
            return control.model[control.textRole];
        if (control.model.display !== undefined)
            return control.model.display;
        if (control.model.modelData !== undefined)
            return control.model.modelData;
        return control.model;
    }
    highlighted: control.selected

    background: MD.Rectangle {
        implicitWidth: 64
        implicitHeight: 48
        corners: control.corners
        color: control.selected ? MD.Token.color.surface_container_highest : MD.Token.color.surface_container

        MD.Ripple {
            anchors.fill: parent
            corners: control.corners
            pressX: control.pressX
            pressY: control.pressY
            pressed: control.pressed
            stateOpacity: control.pressed ? MD.Token.state.pressed.state_layer_opacity : (control.hovered ? MD.Token.state.hover.state_layer_opacity : 0)
            color: MD.Token.color.on_surface
        }

        MD.Divider {
            anchors.bottom: parent.bottom
            width: parent.width
        }

        MD.Divider {
            anchors.right: parent.right
            height: parent.height
            orientation: Qt.Vertical
            visible: control.section + 1 !== control.columns
        }
    }

    contentItem: MD.Label {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: control.displayText ?? ""
        typescale: MD.Token.typescale.title_small
        color: control.hovered ? MD.Token.color.on_surface : MD.Token.color.on_surface_variant
    }
}
