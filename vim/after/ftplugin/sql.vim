" use alternative delimiter. the default is '--', we want to use '/* */'
let g:NERDAltDelims_sql = 1

let g:neoformat_enabled_sql = ['sqlformatter']
let g:neoformat_sql_sqlformatter = {
      \ 'exe': 'sql-formatter',
      \ 'stdin': 1,
      \ }
