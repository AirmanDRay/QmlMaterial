pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qcm.Material as MD

// Qt 6.8 compatibility note:
// T.TableViewDelegate was only added in Qt 6.10. MD.ItemDelegate (this
// module's own thin wrapper around T.ItemDelegate, available since long
// before 6.8 — see ItemDelegate.qml) is used as the base instead, so
// this also inherits its implicitWidth/implicitHeight formula rather
// than redeclaring one.
//
// Everything T.TableViewDelegate would have supplied automatically is
// reconstructed by hand below:
//   - row / column / model: the standard "required property" convention
//     any TableView delegate can opt into, regardless of base type.
//   - selected / current / editing: same convention. TableView has kept
//     these in sync with its selectionModel for ANY delegate that
//     declares them as required properties since Qt 6.2/6.4 — this was
//     never gated behind T.TableViewDelegate, which just declares them
//     for you as a convenience. Genuine sync, not a stand-in.
//   - tableView: recovered via the TableView.view attached property
//     (available since Qt 5.14).
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
    required property bool current
    required property bool editing

    readonly property TableView tableView: TableView.view as TableView
    // Qt 6.8 compatibility note: cast to QtObject here, not MD.TableView.
    // MD.TableView (TableView.qml) is a composite, QML-file-defined type
    // in this same module, and its own `delegate: MD.TableViewDelegate {}`
    // already makes MD.TableView structurally depend on THIS file. Casting
    // back to the in-module MD.TableView type here would close that loop,
    // and the QML type loader detects it as a cycle at load time --
    // reported as "qt.qml.typeresolution.cycle" and, downstream, "Type
    // MD.TableView unavailable". QtObject is a foundational QtQml type
    // outside this module, so it carries no such dependency.
    // hoveredRow/effectiveRadius/hasHeader below still resolve correctly
    // via ordinary dynamic property lookup on the real MD.TableView
    // instance at runtime -- only static type-checking of these accesses
    // is given up, not the values themselves.
    readonly property QtObject mdTableView: TableView.view as QtObject
    readonly property bool rowHovered: hovered || (mdTableView?.hoveredRow ?? -1) === row
    property int rows: TableView.view?.rows ?? 0
    property int columns: TableView.view?.columns ?? 0
    property MD.StateTableViewDelegate mdState: MD.StateTableViewDelegate {
        item: control
    }
    property int radius: mdTableView?.effectiveRadius ?? 0
    property MD.corners corners: mdTableView?.hasHeader ? MD.Util.tableWithHeaderCorners(row, column, rows, columns, radius) : MD.Util.tableCorners(row, column, rows, columns, radius)

    highlighted: selected

    onHoveredChanged: MD.Util.cellHoveredOn(TableView.view, hovered, row, column)

    contentItem: MD.Label {
        clip: false
        text: control.model.display ?? ""
        elide: Text.ElideRight
        typescale: MD.Token.typescale.body_medium
        verticalAlignment: Text.AlignVCenter
        color: control.mdState.textColor
        opacity: control.mdState.contentOpacity
        visible: !control.editing
    }

    background: MD.ElevationRectangle {
        implicitWidth: 64
        implicitHeight: 44

        opacity: control.mdState.backgroundOpacity

        corners: control.corners

        color: control.mdState.backgroundColor

        elevationVisible: elevation && color.a > 0
        elevation: control.mdState.elevation

        MD.Ripple {
            id: m_ripple
            corners: control.corners
            width: parent.width
            height: parent.height
            pressX: control.pressX
            pressY: control.pressY
            pressed: control.pressed
            stateOpacity: control.mdState.stateLayerOpacity
            color: control.mdState.stateLayerColor
        }

        MD.Divider {
            anchors.bottom: parent.bottom
            width: parent.width
            color: control.mdState.outlineColor
            visible: control.row + 1 !== control.rows
        }

        MD.Divider {
            anchors.right: parent.right
            height: parent.height
            orientation: Qt.Vertical
            color: control.mdState.outlineColor
            visible: control.column + 1 !== control.columns
        }
    }

    // TableView.editDelegate: FocusScope {
    //     width: parent.width
    //     height: parent.height

    //     TableView.onCommit: {
    //         let model = control.tableView.model;
    //         if (!model)
    //             return;
    //         let succeed = false;
    //         const index = model.index(control.row, control.column);
    //         succeed = model.setData(index, textField.text, Qt.EditRole);
    //         if (!succeed)
    //             console.warn("The model does not allow setting the EditRole data.");
    //     }

    //     Component.onCompleted: textField.selectAll()

    //     TextField {
    //         id: textField
    //         anchors.fill: parent
    //         text: control.model.edit ?? control.model.display ?? ""
    //         focus: true
    //     }
    // }
}
