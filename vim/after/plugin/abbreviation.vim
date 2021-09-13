" vim:ts=58:

" Name:         correction.vim
" Author:       Le Tien Tai <letientai299@gmail.com>
" Description:  This is not only contains spelling correction, but also
" shortcuts for my often typed words

"------------------------------------------------------------------------------
" Normal vim abbreviation
"------------------------------------------------------------------------------
" Abolish cannot handle auto convert to upper case.
iab gui GUI
iab Gui GUI
iab ok OK
iab wtf WTF
iab Ok OK
iab SD Software Development
iab SE Software Engineer
iab SSE Senior Software Engineer

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

"------------------------------------------------------------------------------
" With Abolish
"------------------------------------------------------------------------------
" Auo failse if the abolish not found
if (exists(":Abolish") != 2) || exists("g:loaded_autocorrect")
  finish
endif
let g:loaded_autocorrect = 1

Abolish Ameria{,n}                                        America{,n}
Abolish acheiv{e,ed,ing}                                  achiev{}
Abolish acom{,m}{o,a}date                                 accommodate
Abolish adequit{,e}                                       adequate
Abolish agreem{,ee}n{,e}t                                 agreement
Abolish agreem{,ee}n{,e}ts                                agreements
Abolish alm{ots,sot}                                      almost
Abolish alr{aedy,eayd,eday}                               already
Abolish al{,l}{aw,wa}{sy,ys,y,s}                          always
Abolish andt{eh,he}                                       and the
Abolish appar{ant,rent}                                   apparent
Abolish applicaiton{,s}                                   application{}
Abolish approrp{r,}iate                                   appropriate
Abolish aquisition{,s}                                    acquisition{}
Abolish artic{a,e}l                                       article
Abolish ar{,e}{nt,tn}                                     aren't
Abolish aud{ei,ia}nce                                     audience
Abolish bal{e,la}nce                                      balance
Abolish because{a,of,the,you}                             because {}
Abolish becom{e,m}ing                                     becoming
Abolish beg{gin,in,inin}ing                               beginning
Abolish belei{ve,f,ve,ved,ves}                            belie{}
Abolish benifit{,s}                                       benefit{}
Abolish be{cuse,cuase,acuse,casue,caus}                   because
Abolish cal{cul,u}late{,d}                                calculate{,d}
Abolish candidtae{,s}                                     candidate{}
Abolish cat{a,egi}gor{y,ies}                              cat{e}gor{}
Abolish ca{nt,tn}                                         can't
Abolish challange{,s}                                     challenge{}
Abolish chaneg{,s}                                        change{}
Abolish chang{able,eing,ng}                               chang{eable,ing,ing}
Abolish char{a,e}c{hter,tor,ter}{,s}                      char{a}c{ter,ter,ter}{}
Abolish cheif{,s}                                         chief{}
Abolish chekc{,s}                                         check{}
Abolish chnag{e,ing,er,es}                                chang{}
Abolish claer{,ed,ly}                                     clear{}
Abolish cm{,s}                                            command{}
Abolish coma{,p}n{y,ies}                                  com{p}an{}
Abolish combintation{,s}                                  combination{}
Abolish comit{ed,ee,tee,tment,tments}                     commit{ted,tee,tee,ment,ments}
Abolish committment{,s}                                   commitment{}
Abolish commit{ee,te,ty}                                  committee
Abolish comntain{,s}                                      contain{}
Abolish compleat{ed,ly,ness}                              complet{ed,ely,eness}
Abolish complet{ly,ness}                                  complete{}
Abolish comtain{,s}                                       contain{}
Abolish comunicat{e,es,ion,ions}                          communicat{}
Abolish comunit{y,ies}                                    communit{}
Abolish conect{,s,ed,ion,ions}                            connect{}
Abolish considerit{,e}                                    considerate
Abolish consultent{,s}                                    consultant{}
Abolish convertable{,s}                                   convertible{}
Abolish coop{a,o}rate                                     cooperate
Abolish corproation{,s}                                   corporation{}
Abolish cu{sot,tso}mer{,s}                                cu{sto}mer{}
Abolish c{ou,uo}{dl,d,l,ld}                               could
Abolish c{ou,uo}{dl,d,l,ld}{n,t,nt}                       couldn't
Abolish dcument{,s,ation}                                 document{}
Abolish decison{,s}                                       decision{}
Abolish defendent{,s}                                     defendant{}
Abolish desi{c,s}ion{,s}                                  deci{s}ion{}
Abolish developor{,s}                                     developer{}
Abolish develpment{,s}                                    development{}
Abolish devel{l,e}op{e,}{,ed,er,ers,ing,ment,ments,s}     deve{l}{o}p{}
Abolish did{i,}nt                                         didn't
Abolish diff{er,re}nt                                     different
Abolish dif{ef,fe}r{e,a}n{t,ce,ces}                       dif{fe}r{e}n{}
Abolish directer{,s}                                      director{}
Abolish distribusion{,s}                                  distribution{}
Abolish docu{ement,emnt,metn,mnet}{,s}                    docu{ment}{}
Abolish do{nig,ign,img,ind}                               doing
Abolish db{nig,ign,img,ind}                               database{}
Abolish efort{,s}                                         effort{}
Abolish embarass{,ing,ed,es}                              embarrass{}
Abolish espe{cally,cialyl,sially}                         especially
Abolish experi{ance,enc}{,es,ed,ing}                      experi{enc}{e,es,ed,ing}
Abolish exprience{,d}                                     experience{}
Abolish exp{,d}                                     experience{}
Abolish faeture{,s}                                       feature{}
Abolish fam{,m}il{air,ar,liar,iar}{,ize,ized,ized,izing}  fa{m}il{iar}{}
Abolish feild{,s}                                         field{}
Abolish follwo{,ing}                                      follow{}
Abolish forwrd{,s,ing,er,most}                            forward{}
Abolish foward{,s,ing,er}                                 forward{}
Abolish freind{,ly,s}                                     friend{}
Abolish gove{n,r}ment                                     government
Abolish gruop{,s}                                         group
Abolish hapen{,ed,ing,s}                                  happen{}
Abolish hva{e,ing}                                        hav{}
Abolish imediat{e,ly}                                     immediate{,ly}
Abolish import{en,na}t{,ly}                               import{an}t{}
Abolish improv{em,me}nt{,s}                               improve{me}nt{}
Abolish indenpenden{ce,t}                                 independen{}
Abolish independan{ce,t}                                  independen{}
Abolish itnerest{,ed,int,s}                               interest{}
Abolish jav                                               java
Abolish knowl{d,e}ge                                      knowledge
Abolish k{nwo,onw}{,n,s}                                  k{now}{}
Abolish lib{ary,arry,rery}                                library
Abolish liek{,d}                                          like{}
Abolish mesage{,s}                                        message{}
Abolish mispell{,ing,ings,ed,s}                           misspell{}
Abolish mka{e,es,ing}                                     mak{}
Abolish nec{ass,cess,es}ar{y,ily}                         nec{ess}ar{}
Abolish nw{o,e}                                           n{}w
Abolish oc{,c}ur{,ed,ence,rance}                          oc{c}urr{,ed,ence,ence}
Abolish oppos{ate,it}                                     opposite
Abolish opp{o,er}tunit{y,ies}                             opp{or}tunit{}
Abolish orginiz{e,ed,ation}                               organiz{}
Abolish peice{,s}                                         piece{}
Abolish peo{lpe,pel}                                      people
Abolish perh{asp,pas}                                     perhaps
Abolish perm{a,e,i}n{a,e,i}nt{,ly}                        perm{a}n{e}nt{}
Abolish porblem{,s}                                       problem{}
Abolish probelm{,s}                                       problem{}
Abolish prominant{,ly}                                    prominent{}
Abolish prot{e,o}ge                                       protégé
Abolish psoition{,ed,ally,s}                              position{}
Abolish quater{,s,ly}                                     quarter{}
Abolish que{,s}{,t}{io,oi}{n,ns,ms,sn}                    que{s}{t}{io}n{,s,s,s}
Abolish recomend{,ation,ations,ed,s}                      recommend{}
Abolish rec{eie,ie}v{e,ed,ing}                            rec{ei}v{}
Abolish rem{m,e,me}ber{,d,ed,de}                          rem{em}ber{,ed}
Abolish respom{d,se}                                      respon{}
Abolish respons{able,ibile,ability,iblity}                responsib{le,le,ility,ility}
Abolish rest{arau,uara}nt                                 restaurant
Abolish reveiw{,s,ed,ing}                                 review{}
Abolish re{c,cc}o{m,mm}end                                recommend
Abolish scedul{e,es,ed,ing,er}                            schedul{}
Abolish sep{are,er}ate                                    separate
Abolish soudn{,s}                                         sound{}
Abolish specificaly{,l}                                   specifically
Abolish statment{,s}                                      statement{}
Abolish successful{l,y,yl}                                successful{,ly,ly}
Abolish supris{e,ed,es,ing}                               surpris{}
Abolish teh                                               the
Abolish thnig{,s}                                         thing{}
Abolish thn{a,e}                                          th{}n
Abolish tka{e,es,ing}                                     tak{}
Abolish ton{gih,ihg}t                                     tonight
Abolish totaly{,l}                                        totally
Abolish tru{el,le}y                                       truly
Abolish untill{,l}                                        until
Abolish wer{,e}{nt,tn}                                    weren't
Abolish wnat{,s,ed}                                       want{}
Abolish yer{as,sa}                                        years
Abolish yuo{,r}                                           you{}
