" Abolish cannot handle auto convert to upper case.
iab gui GUI
iab Gui GUI
iab ok OK
iab Ok OK
iab vlc VLC
iab Vlc VLC

" Date time inserting
"Tue 29 Mar 2016 09:07:43 AM ICT
iab <expr> dtf strftime("%c")
iab <expr> Dtf strftime("%c")
"2016-04-07
iab <expr> dtd strftime("%Y-%m-%d")
iab <expr> Dtd strftime("%Y-%m-%d")
"090756
iab <expr> dtt strftime("%T")
iab <expr> Dtt strftime("%T")
" Need to make another variant that have first letter capitalized to use with
" the auto-capitalisation mode

