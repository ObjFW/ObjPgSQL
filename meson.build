project('ObjPgSQL', 'objc',
  version: '1.0',
  meson_version: '>= 1.5.0',
  default_options: {
    'warning_level': '3',
  })

objfw_dep = dependency('objfw')
libpq_dep = dependency('libpq')

incdir = include_directories('src', 'src/exceptions')

subdir('src')
subdir('tests')

# Meson unfortunately does not allow access to the flags of libpq_dep.
pkgconfig = find_program('pkg-config')
libpq_cflags = run_command(
  [pkgconfig, '--cflags', 'libpq'],
  check: true).stdout().strip()
libpq_libs = run_command(
  [pkgconfig, '--libs', 'libpq'],
  check: true).stdout().strip()

objfwconfig = find_program('objfw-config')
packages_dir = run_command(
  [objfwconfig, '--packages-dir'],
  check: true).stdout().strip()

configure_file(
  input: 'ObjPgSQL.oc.in',
  output: 'ObjPgSQL.oc',
  configuration: {
    'libdir': get_option('prefix') / get_option('libdir'),
    'LIBPQ_CPPFLAGS': libpq_cflags,
    'LIBPQ_LIBS': libpq_libs,
  },
  install: true,
  install_dir: packages_dir)
