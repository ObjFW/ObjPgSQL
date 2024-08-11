fs = import('fs')

subdir('exceptions')

sources = files(
  'PGSQLConnection.m',
  'PGSQLResult.m',
  'PGSQLResultRow.m',
)

objpgsql = library('objpgsql',
  sources + exceptions_sources,
  include_directories: incdir,
  dependencies: [objfw_dep, libpq_dep],
  soversion: '1.0.0',
  install: true)

headers = ['ObjPgSQL.h']
foreach source: sources + exceptions_sources
  headers += fs.replace_suffix(source.full_path(), '.h')
endforeach

install_headers(headers, subdir: 'ObjPgSQL')
