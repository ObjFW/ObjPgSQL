fs = import('fs')

subdir('exceptions')

sources = files(
  'PGConnection.m',
  'PGResult.m',
  'PGResultRow.m',
)

objpgsql = library('objpgsql',
  sources + exceptions_sources,
  include_directories: incdir,
  dependencies: [objfw_dep, libpq_dep],
  install: true)

headers = ['ObjPgSQL.h']
foreach source: sources + exceptions_sources
  headers += fs.replace_suffix(source.full_path(), '.h')
endforeach

install_headers(headers, subdir: 'ObjPgSQL')
