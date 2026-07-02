#pragma once
#include <QtCore/qtcoreexports.h>

// qml_material's linkage type (SHARED on Linux/macOS, STATIC on
// Windows/Emscripten -- see QML_MATERIAL_BUILD_TYPE in the root
// CMakeLists.txt) determines what QML_MATERIAL_API needs to expand to:
//
//   - SHARED, building qml_material's own sources: Q_DECL_EXPORT
//     (this target has CXX_VISIBILITY_PRESET hidden, so symbols need
//     this to be visible outside the .so/.dylib at all)
//   - SHARED, consuming from elsewhere (e.g. qml_materialplugin):
//     Q_DECL_IMPORT -- harmless boilerplate on ELF/Mach-O, but
//     necessary in general
//   - STATIC (any consumer, including qml_material's own sources):
//     nothing. A static archive has no import table, so
//     Q_DECL_IMPORT here is actively wrong -- it makes the compiler
//     emit a reference expecting a DLL import stub that will never
//     exist, which is a hard "undefined reference to `__imp_...`"
//     link error on Windows/PE-COFF (harmless-but-wrong on ELF/Mach-O,
//     which is why this was never caught on Linux/macOS).
//
// QML_MATERIAL_STATIC_DEFINE is defined PUBLIC on the qml_material
// target in CMakeLists.txt whenever QML_MATERIAL_BUILD_TYPE is
// STATIC, so it's visible both to qml_material's own sources and to
// anything that links against it.
#if defined(QML_MATERIAL_STATIC_DEFINE)
#    define QML_MATERIAL_API
#elif defined(QML_MATERIAL_EXPORT)
#    define QML_MATERIAL_API Q_DECL_EXPORT
#else
#    define QML_MATERIAL_API Q_DECL_IMPORT
#endif