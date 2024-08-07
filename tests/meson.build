testexe = executable('tests', 'Tests.m',
  dependencies: objfw_dep,
  link_with: objpgsql,
  include_directories: incdir)
test('ObjPgSQL tests', testexe)
