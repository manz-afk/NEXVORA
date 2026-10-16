# Menyesuaikan project Android hasil `flutter create`:
# nama app, izin, queries (TTS/STT), cleartext, FlutterFragmentActivity + tema AppCompat,
# minSdk 24, compileSdk 36 (app dan semua plugin), dan mematikan R8/minify di release.
import glob, os, re, sys

android = sys.argv[1]
manifest = os.path.join(android, 'app/src/main/AndroidManifest.xml')

# --- manifest ---
t = open(manifest).read()
t = re.sub(r'android:label="[^"]*"', 'android:label="Nexvora"', t, count=1)

lines = ''
for x in ['INTERNET', 'READ_MEDIA_IMAGES', 'READ_MEDIA_VIDEO', 'READ_MEDIA_AUDIO']:
    if 'android.permission.' + x not in t:
        lines += '    <uses-permission android:name="android.permission.%s"/>\n' % x
if 'READ_EXTERNAL_STORAGE' not in t:
    lines += '    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>\n'
if 'WRITE_EXTERNAL_STORAGE' not in t:
    lines += '    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>\n'
if lines:
    t = t.replace('<application', lines + '    <application', 1)

if '<queries>' not in t:
    t = t.replace('</manifest>',
        '    <queries>\n'
        '        <intent><action android:name="android.intent.action.TTS_SERVICE"/></intent>\n'
        '        <intent><action android:name="android.speech.RecognitionService"/></intent>\n'
        '    </queries>\n</manifest>', 1)

if 'usesCleartextTraffic' not in t:
    t = t.replace('<application', '<application android:usesCleartextTraffic="true"', 1)

open(manifest, 'w').write(t)

# --- MainActivity -> FlutterFragmentActivity (dibutuhkan local_auth) ---
for f in glob.glob(os.path.join(android, 'app/src/main/**/MainActivity.*'), recursive=True):
    s = open(f).read()
    open(f, 'w').write(s.replace('FlutterActivity', 'FlutterFragmentActivity'))

# --- tema AppCompat untuk BiometricPrompt ---
for f in glob.glob(os.path.join(android, 'app/src/main/res/values*/styles.xml')):
    s = open(f).read()
    s = s.replace('@android:style/Theme.Light.NoTitleBar', 'Theme.AppCompat.Light.NoActionBar') \
         .replace('@android:style/Theme.Black.NoTitleBar', 'Theme.AppCompat.NoActionBar')
    open(f, 'w').write(s)

# --- minSdk 24 (ffmpeg, ML Kit) ---
for f in glob.glob(os.path.join(android, 'app/build.gradle*')):
    s = open(f).read()
    open(f, 'w').write(re.sub(r'flutter\.minSdkVersion', '24', s))

# --- compileSdk 36 untuk app ---
def _bump(m):
    v = m.group(2)
    if v.isdigit() and int(v) >= 36:
        return m.group(0)
    return m.group(1) + '36'

for f in glob.glob(os.path.join(android, 'app/build.gradle*')):
    s = open(f).read()
    s = re.sub(r'(compileSdk(?:Version)?\s*=?\s*)(flutter\.compileSdkVersion|\d+)', _bump, s)
    open(f, 'w').write(s)

# --- compileSdk 36 untuk SEMUA plugin (root build.gradle) ---
# Plugin seperti flutter_inappwebview_android punya build.gradle sendiri dengan compileSdk lama.
MARK = '// NEXVORA-COMPILESDK36'
for f in glob.glob(os.path.join(android, 'build.gradle*')):
    s = open(f).read()
    if MARK in s:
        continue
    if f.endswith('.kts'):
        block = f'''
{MARK}
subprojects {{
    val setSdk = {{
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.compileSdkVersion(36)
    }}
    if (state.executed) setSdk() else afterEvaluate {{ setSdk() }}
}}
'''
    else:
        block = f'''
{MARK}
subprojects {{
    def setSdk = {{ p ->
        def ext = p.extensions.findByName('android')
        if (ext != null) ext.compileSdkVersion(36)
    }}
    if (state.executed) setSdk(project) else afterEvaluate {{ setSdk(it) }}
}}
'''
    open(f, 'w').write(s + block)
    print('compileSdk 36 untuk subproject ditambahkan di', f)

# --- matikan R8/minify di release (R8 gagal dengan ML Kit & inappwebview) ---
for f in glob.glob(os.path.join(android, 'app/build.gradle*')):
    s = open(f).read()
    if 'isMinifyEnabled' not in s and 'minifyEnabled' not in s:
        if f.endswith('.kts'):
            block = '\n            isMinifyEnabled = false\n            isShrinkResources = false'
        else:
            block = '\n            minifyEnabled false\n            shrinkResources false'
        s = re.sub(r'(buildTypes\s*\{\s*release\s*\{)', lambda m: m.group(1) + block, s, count=1)
        open(f, 'w').write(s)
        print('minify dimatikan di', f)

print('android dipatch (tanpa widget)')
