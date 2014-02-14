if exists("b:current_syntax")
  finish
endif

syn match whiteLine '.*$' skipwhite
syn match warnLine 'WARNING:.*$' skipwhite
syn match errorLine 'ERROR:.*$' skipwhite
syn match infoLine 'INFO.*$' skipwhite

syn match unitTest 'Running .*$' skipwhite

syn region resultsRegion start='Results' end='\['

hi def link whiteLine Comment
hi def link infoLine Comment
hi def link errorLine ErrorMsg
hi def link warnLine WarningMsg
hi def link unitTest PreProc
hi def link resultsRegion PreProc 

let b:current_syntax = "mvnbuild"
