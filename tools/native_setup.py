#!/usr/bin/env python3
"""Configuración nativa (Android / iOS) de BugTatsu Sec.

Uso, desde la carpeta raíz del proyecto Flutter:

    python native_setup.py rebrand         # etapa 1: nombre y paquete com.bugtatsu.sec
    python native_setup.py network         # etapa 3: permisos de red (Android)
    python native_setup.py camera          # etapa 5: permiso de cámara (Android + iOS)
    python native_setup.py notifications   # etapa 7: notificaciones (Android 13+ y desugaring)

Es idempotente (se puede ejecutar varias veces) y guarda una copia de seguridad de cada
archivo que modifica en .dart_tool/native_setup_backup/. Si no encuentra el lugar exacto de un cambio, no inventa:
imprime el paso manual que debes hacer.
"""
import re
import shutil
import sys
from pathlib import Path

NEW_ID = 'com.bugtatsu.sec'
APP_NAME = 'BugTatsu Sec'

root = Path.cwd()
manifest = root / 'android/app/src/main/AndroidManifest.xml'
plist = root / 'ios/Runner/Info.plist'
pbxproj = root / 'ios/Runner.xcodeproj/project.pbxproj'
podfile = root / 'ios/Podfile'
changed, manual = [], []


def read(p):
    return p.read_text(encoding='utf-8')


def write(p, text):
    # La copia de seguridad va a .dart_tool (que Git ignora), no al código del proyecto.
    bak = root / '.dart_tool' / 'native_setup_backup' / (str(p.relative_to(root)).replace('\\', '/') + '.bak')
    if not bak.exists():
        bak.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, bak)
    p.write_text(text, encoding='utf-8', newline='')
    if str(p.relative_to(root)) not in changed:
        changed.append(str(p.relative_to(root)))


def find_gradle():
    for name in ('build.gradle.kts', 'build.gradle'):
        p = root / 'android/app' / name
        if p.exists():
            return p
    return None


def add_permission(permission, extra=''):
    """Agrega <uses-permission> (o <uses-feature>) justo después de <manifest ...>."""
    if not manifest.exists():
        manual.append(f'No existe {manifest}; agrega {permission} al AndroidManifest.xml.')
        return
    text = read(manifest)
    line = permission
    if line in text:
        return
    m = re.search(r'<manifest\b[^>]*>', text)
    if not m:
        manual.append(f'No encontré <manifest> en AndroidManifest.xml; agrega: {line}')
        return
    text = text[:m.end()] + '\n    ' + line + text[m.end():]
    write(manifest, text)


def uses_permission(name):
    return f'<uses-permission android:name="{name}"/>'


# ---------------------------------------------------------------- rebrand
def rebrand():
    gradle = find_gradle()
    if gradle is None:
        manual.append('No encontré android/app/build.gradle(.kts).')
        return
    text = read(gradle)
    m = re.search(r'applicationId\s*=?\s*"([^"]+)"', text)
    if not m:
        manual.append('No encontré applicationId en build.gradle; cámbialo a ' + NEW_ID)
        return
    old_id = m.group(1)
    if old_id != NEW_ID:
        new = text.replace(f'"{old_id}"', f'"{NEW_ID}"')
        write(gradle, new)

        # MainActivity: cambia el package y mueve el archivo a la nueva carpeta.
        kotlin_root = root / 'android/app/src/main'
        for lang in ('kotlin', 'java'):
            for src in (kotlin_root / lang).rglob('MainActivity.*') if (kotlin_root / lang).exists() else []:
                code = read(src).replace(f'package {old_id}', f'package {NEW_ID}')
                dest_dir = kotlin_root / lang / NEW_ID.replace('.', '/')
                dest_dir.mkdir(parents=True, exist_ok=True)
                dest = dest_dir / src.name
                if dest != src:
                    dest.write_text(code, encoding='utf-8')
                    src.unlink()
                    changed.append(f'{src.relative_to(root)} -> {dest.relative_to(root)}')
                    # limpia carpetas vacías del paquete anterior
                    parent = src.parent
                    while parent != kotlin_root / lang and not any(parent.iterdir()):
                        parent.rmdir()
                        parent = parent.parent
        # cualquier otro archivo de android/ que mencione el paquete viejo
        for p in (root / 'android').rglob('*'):
            if p.suffix in ('.kt', '.java', '.xml', '.gradle', '.kts') and p.is_file():
                try:
                    t = read(p)
                except UnicodeDecodeError:
                    continue
                if old_id in t:
                    write(p, t.replace(old_id, NEW_ID))

    # Nombre visible en Android
    if manifest.exists():
        t = read(manifest)
        t2 = re.sub(r'android:label="[^"]*"', f'android:label="{APP_NAME}"', t, count=1)
        if t2 != t:
            write(manifest, t2)
    else:
        manual.append('No existe AndroidManifest.xml.')

    # iOS
    if pbxproj.exists():
        t = read(pbxproj)
        t2 = re.sub(r'(PRODUCT_BUNDLE_IDENTIFIER = )com\.example\.[A-Za-z0-9_]+(\.RunnerTests)?;',
                    lambda m: f'{m.group(1)}{NEW_ID}{m.group(2) or ""};', t)
        if t2 != t:
            write(pbxproj, t2)
    else:
        manual.append('No existe ios/Runner.xcodeproj/project.pbxproj (¿no se generó la carpeta ios?).')
    if plist.exists():
        t = read(plist)
        t2 = re.sub(r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)', rf'\g<1>{APP_NAME}\g<2>', t)
        t2 = re.sub(r'(<key>CFBundleName</key>\s*<string>)[^<]*(</string>)', rf'\g<1>{APP_NAME}\g<2>', t2)
        if t2 != t:
            write(plist, t2)


# ---------------------------------------------------------------- network
def network():
    add_permission(uses_permission('android.permission.INTERNET'))
    add_permission(uses_permission('android.permission.ACCESS_NETWORK_STATE'))


# ---------------------------------------------------------------- camera
def camera():
    add_permission(uses_permission('android.permission.CAMERA'))
    add_permission('<uses-feature android:name="android.hardware.camera" android:required="false"/>')

    keys = {
        'NSCameraUsageDescription': 'BugTatsu Sec usa la cámara para adjuntar capturas como evidencia.',
        'NSPhotoLibraryUsageDescription': 'BugTatsu Sec accede a tus fotos para adjuntar evidencia.',
    }
    if plist.exists():
        t = read(plist)
        add = ''.join(f'\t<key>{k}</key>\n\t<string>{v}</string>\n'
                      for k, v in keys.items() if f'<key>{k}</key>' not in t)
        if add:
            i = t.rfind('</dict>')
            if i == -1:
                manual.append('Info.plist sin </dict>; agrega NSCameraUsageDescription y NSPhotoLibraryUsageDescription.')
            else:
                write(plist, t[:i] + add + t[i:])
    else:
        manual.append('No existe ios/Runner/Info.plist; agrega NSCameraUsageDescription y NSPhotoLibraryUsageDescription.')

    # permission_handler en iOS: activar solo el permiso de cámara en el Podfile.
    if podfile.exists():
        t = read(podfile)
        if 'PERMISSION_CAMERA' not in t:
            anchor = re.search(r'^(\s*)flutter_additional_ios_build_settings\(target\)\s*$', t, re.M)
            if anchor:
                ind = anchor.group(1)
                block = (
                    f"\n{ind}target.build_configurations.each do |config|\n"
                    f"{ind}  config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [\n"
                    f"{ind}    '$(inherited)',\n"
                    f"{ind}    'PERMISSION_CAMERA=1',\n"
                    f"{ind}  ]\n"
                    f"{ind}end"
                )
                write(podfile, t[:anchor.end()] + block + t[anchor.end():])
            else:
                manual.append("Podfile: agrega 'PERMISSION_CAMERA=1' en GCC_PREPROCESSOR_DEFINITIONS dentro de post_install.")
    else:
        manual.append('No existe ios/Podfile (solo importa si vas a compilar para iOS).')


# ---------------------------------------------------------------- notifications
def notifications():
    add_permission(uses_permission('android.permission.POST_NOTIFICATIONS'))

    gradle = find_gradle()
    if gradle is None:
        manual.append('No encontré android/app/build.gradle(.kts).')
        return
    text = read(gradle)
    kts = gradle.suffix == '.kts'
    if 'coreLibraryDesugaring' in text and ('isCoreLibraryDesugaringEnabled' in text or 'coreLibraryDesugaringEnabled' in text):
        return

    flag = 'isCoreLibraryDesugaringEnabled = true' if kts else 'coreLibraryDesugaringEnabled true'
    dep = ('    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")'
           if kts else "    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'")

    ok = True
    if 'CoreLibraryDesugaring' not in text and 'coreLibraryDesugaringEnabled' not in text:
        m = re.search(r'(compileOptions\s*\{\n)', text)
        if m:
            text = text[:m.end()] + f'        {flag}\n' + text[m.end():]
        else:
            ok = False
    if 'coreLibraryDesugaring(' not in text and 'coreLibraryDesugaring ' not in text:
        m = re.search(r'^dependencies\s*\{\n', text, re.M)
        if m:
            text = text[:m.end()] + dep + '\n' + text[m.end():]
        else:
            text = text.rstrip('\n') + f'\n\ndependencies {{\n{dep}\n}}\n'
    if ok:
        write(gradle, text)
    else:
        manual.append(
            f'En {gradle.relative_to(root)}, dentro de android {{ compileOptions {{ }} }} agrega:\n'
            f'        {flag}\n'
            f'y al final del archivo:\n'
            f'dependencies {{\n{dep}\n}}')


STEPS = {'rebrand': rebrand, 'network': network, 'camera': camera, 'notifications': notifications}

if __name__ == '__main__':
    if len(sys.argv) != 2 or sys.argv[1] not in STEPS:
        print(__doc__)
        sys.exit(2)
    if not (root / 'pubspec.yaml').exists():
        print('Ejecuta este script desde la carpeta raíz del proyecto (donde está pubspec.yaml).')
        sys.exit(2)
    STEPS[sys.argv[1]]()
    print(f'== {sys.argv[1]} ==')
    if changed:
        print('Archivos modificados:')
        for c in changed:
            print('  -', c)
    else:
        print('Sin cambios (ya estaba configurado).')
    if manual:
        print('\nPASOS MANUALES PENDIENTES:')
        for m in manual:
            print('  *', m)
        sys.exit(1)
