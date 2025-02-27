project(
  'io.github.ellie_commons.tomato',
  'vala', 'c',
  version: '3.0.1'
)

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

gresource = gnome.compile_resources(
    'as-resources',
    'data' / 'tomato.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

deps = [
    dependency('granite-7'),
    dependency('gtk4'),
    dependency('libadwaita-1'),
    dependency('libcanberra'),
]

executable(
    meson.project_name(),
    config_file,
    gresource,
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Enums.vala',

    'src/Services/SavedState.vala',
    'src/Services/Settings.vala',
    'src/Services/Preferences.vala',

    'src/Utils/Countdown.vala',
    'src/Utils/Timer.vala',

    'src/Managers/WorkManager.vala',
    'src/Managers/SoundManager.vala',
    'src/Managers/NotificationManager.vala',
    'src/Managers/LauncherManager.vala',

    'src/Dialogs/PreferencesDialog.vala',

    'src/Widgets/ValueRange.vala',
    
    dependencies: deps,
    install: true
)

subdir('data')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)