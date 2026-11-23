#SingleInstance
#Requires AutoHotkey v2+
; Library of HotStrings for AutoCorrect2.  Please note that the f() function calls require the function that is defined in the AutoCorrectSystem.ahk code.
; Library updated 5-30-2026 
; Ignore the debug function call.  If the f() definition is not present, this replacement text will appear in the error message.
:B0XC:Ign0re Th!s STRing::f("Did you forget to '#Include' the AutoCorrectSystem.ahk file in AutoCorrect2?")

; ; Two hotstrings for testing keyboard input buffering (or lack thereof).
; :B0X*?:zx::f("lllllllllllllllllllllllllllllllllllllllllllllllll")
; :*?:zx::lllllllllllllllllllllllllllllllllllllllllllllllll

#Hotstring Z ; The Z causes the end char to be reset after each activation and helps prevent a zombie outbreak. 

;============== Determine start line of autocorrect items ======================
; Please don't change the "ACitemsStartAt := A_LineNumber" it is used by several scripts. 
ACitemsStartAt := A_LineNumber  ; hh2 validity checks will skip lines until it gets to here. 
; ==============================================
; MARK: Nullifiers
; ===== Trigger strings to nullify the potential misspellings that are indicated. =====
; Used the word "corrects" in place of fix to avoid double-counting these as potential fixes.
:B0*:hadn':: ; Here for :?:adn::and, which corrects 339 words. 
:B0*:horror:: ; Here for :*?:orror::error, which corrects 56 words.
:B0*:showtime:: ; Here for :*?:showt::short ; Which corrects 79 words.
:B0:Savitr:: ; (Important Hindu god) Here for :?:itr::it, which corrects 366 words.
:B0:Unisys:: ; Here for :?C:sys::sies, which corrects 113 words
:B0:Vaisyas:: ; (A member of the mercantile and professional Hindu caste.) Here for :?:syas::says, which corrects 12 words.
:B0:Wheatley:: ; (a fictional artificial intelligence from the Portal franchise) Here for :?:atley::ately, which corrects 162 words.
:B0:arraign:: ; Here for :?:ign::ing, which corrects 11384 words. (This is from the 2007 AutoCorrect script.)
:B0:bialy:: ; (Flat crusty-bottomed onion roll) Here for :?:ialy::ially, which corrects 244 words.
:B0:callsign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:champaign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:coign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:condign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:consign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:coreign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:cosign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:countersign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:deign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:deraign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:eloign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:ensign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:expansys:: ; Here for :?C:sys::sies, which corrects 113 words
:B0:feign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:gravitino:: ; Here for :?:itino::ition, which corrects 133 words.
:B0:indign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:kc:: ; (thousand per second) Here for :?:kc::ck, which corrects 610 words.
:B0:linksys:: ; Here for :?C:sys::sies, which corrects 113 words
:B0:miliary:: ; Here for :?:miliary::military, which corrects 4 words.
:B0:minyanim:: ; (The quorum required by Jewish law to be present for public worship) Here for :?:anim::anism, which corrects 123 words.
:B0:paraed:: ; Here for :?:raed::read ; Web Freq 543.13 | Fixes 47 words
:B0:pfennig:: ; (100 pfennigs formerly equaled 1 Deutsche Mark in Germany) Here for :?:nig::ing, which corrects 11414 words.
:B0:reign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:scaly:: ; Here for :?:caly::cally ; which corrects 1596 words.
:B0:sice:: ; (The number six at dice) Here for :?:sice::sive, which corrects 166 words.
:B0:sign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:to and fro:: ; To protect ::fro::for 
:B0:verisign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:align:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:assign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:benign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:campaign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:design:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:foreign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:resign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:sovereign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0C:Ganesh:: ; Here for ::ganes::games, which corrects 12 words. 
{	
	return  ; This makes the above hotstrings do nothing so that they override the indicated rules below.
} ; ===== End of nullifier strings ==================

;===============================================================================
; When considering "conflicting" hotstrings, remember that sometimes conflicting autocorrect items can peacefully coexist... Read more in pdf manual, here https://github.com/kunkel321/AutoCorrect2
; The below "Don't Sort Items" Are "word beginning" matches to items in the main list and are supersets of the main list items.  Therefore, they must appear before the corresponding items in the main list.  It is okay to sort this sublist, but do NOT combine these items with the main list.
; Also, don't remove the below 'Mark No Sort' flag...  It gets used by the validation class. 

; MARK: No Sort
; ===== Beginning of Don't Sort items ==========

 :B0X*:eyte::f("eye") ; Web Freq 123.80 | Fixes 113 words 
:B0X*:inteh::f("in the") ; Fixes 1 word
:B0X*:ireleven::f("irrelevan") ; Web Freq 3.51 | Fixes 6 words 
:B0X*:managerial reign::f("managerial rein") ; Fixes 1 word
:B0X*:minsitr::f("ministr") ; Web Freq 37.01 | Fixes 8 words 
:B0X*:peculure::f("peculiar") ; Web Freq 3.30 | Fixes 6 words 
:B0X*:presed::f("presid") ; Web Freq 255.88 | Fixes 23 words 
:B0X*:recommed::f("recommend") ; Web Freq 158.17 | Fixes 12 words 
:B0X*:thge::f("the") ; Web Freq 27360.01 | Fixes 533 words 
:B0X*:thsi::f("this") ; Web Freq 3230.96 | Fixes 12 words 
:B0X*:trafic::f("traffic") ; Web Freq 61.50 | Fixes 13 words 
:B0X*:unkow::f("unknow") ; Web Freq 49.48 | Fixes 14 words 
:B0X*?:abotu::f("about") ; Web Freq 1229.89 | Fixes 41 words 
:B0X*?:allign::f("align") ; Web Freq 24.66 | Fixes 49 words 
:B0X*?:arign::f("aring") ; Web Freq 177.44 | Fixes 184 words 
:B0X*?:asign::f("assign") ; Web Freq 64.32 | Fixes 38 words 
:B0X*?:awya::f("away") ; Web Freq 133.55 | Fixes 72 words 
:B0X*?:bakc::f("back") ; Web Freq 937.85 | Fixes 591 words 
:B0X*?:blihs::f("blish") ; Web Freq 341.93 | Fixes 80 words 
:B0X*?:charecter::f("character") ; Web Freq 140.27 | Fixes 45 words 
:B0X*?:comnt::f("cont") ; Web Freq 2191.75 | Fixes 679 words 
:B0X*?:degred::f("degrad") ; Web Freq 8.92 | Fixes 36 words 
:B0X*?:dessign::f("design") ; Web Freq 495.80 | Fixes 62 words 
:B0X*?:disign::f("design") ; Web Freq 495.80 | Fixes 62 words 
:B0X*?:dquater::f("dquarter") ; Web Freq 13.74 | Fixes 6 words 
:B0X*?:ecomon::f("econom") ; Web Freq 195.89 | Fixes 58 words 
:B0X*?:esorce::f("esource") ; Web Freq 318.21 | Fixes 12 words 
:B0X*?:fisio::f("fissio") ; Web Freq 0.93 | Fixes 10 words 
:B0X*?:juristiction::f("jurisdiction") ; Web Freq 17.51 | Fixes 5 words 
:B0X*?:konw::f("know") ; Web Freq 609.38 | Fixes 81 words 
:B0X*?:mmadn::f("mmand") ; Web Freq 98.58 | Fixes 28 words 
:B0X*?:mmorow::f("morrow") ; Web Freq 24.07 | Fixes 4 words 
:B0X*?:ngiht::f("night") ; Web Freq 378.95 | Fixes 128 words 
:B0X*?:orign::f("origin") ; Web Freq 211.06 | Fixes 38 words 
:B0X*?:oteh::f("othe") ; Web Freq 1620.02 | Fixes 499 words 
:B0X*?:ouiseh::f("ouseh") ; Web Freq 39.93 | Fixes 7 words
:B0X*?:phsa::f("phas") ; Web Freq 80.23 | Fixes 137 words 
:B0X*?:rnign::f("rning") ; Web Freq 349.85 | Fixes 101 words 
:B0X*?:sensur::f("censur") ; Web Freq 2.68 | Fixes 15 words 
:B0X*?:soverign::f("sovereign") ; Web Freq 6.95 | Fixes 10 words 
:B0X*?:ssurect::f("surrect") ; Web Freq 8.20 | Fixes 21 words 
:B0X*?:tatn::f("tant") ; Web Freq 409.99 | Fixes 414 words 
:B0X*?:thakn::f("thank") ; Web Freq 174.90 | Fixes 37 words 
:B0X*?:thnig::f("thing") ; Web Freq 712.51 | Fixes 169 words 
:B0X*?:threatn::f("threaten") ; Web Freq 17.86 | Fixes 12 words 
:B0X*?:tihkn::f("think") ; Web Freq 280.85 | Fixes 56 words 
:B0X*?:tiojn::f("tion") ; Web Freq 14369.56 | Fixes 8482 words 
:B0X*?:toinm::f("tionm") ; Web Freq 0.93 | Fixes 8 words 
:B0X*?:visiosn::f("vision") ; Web Freq 306.55 | Fixes 77 words 
:B0X*?C:ehte::f("ethe") ; Web Freq 275.93 | Fixes 160 words 
:B0X*?C:rhc::f("rch") ; Web Freq 2708.77 | Fixes 953 words
:B0X*?C:rinm::f("rin") ; Web Freq 2599.00 | Fixes 3640 words 
:B0X*?C:sinm::f("sin") ; Web Freq 2541.30 | Fixes 2442 words 
:B0X:addign::f("assign") ; Web Freq 7.01 | Fixes 1 word 
:B0X:doesnt::f("doesn't") ; Fixes 1 word 
:B0X:had forbad::f("had forbidden") ; Fixes 1 word
:B0X:has forbad::f("has forbidden") ; Fixes 1 word
:B0X:inprocess::f("in process") ; Fixes 1 word
:B0X:thatn::f("that") ; Web Freq 3400.03 | Fixes 1 word 
:B0X?:adresing::f("addressing") ; Web Freq 9.38 | Fixes 3 words 
:B0X?:bakk::f("back") ; Web Freq 749.64 | Fixes 114 words 
:B0X?:clas::f("class") ; Web Freq 194.57 | Fixes 12 words 
:B0X?:efull::f("eful") ; Web Freq 93.63 | Fixes 97 words 
:B0X?:gnision::f("gnition") ; Web Freq 27.94 | Fixes 9 words ; Allows :?:nision::nisation to exist below.
:B0X?:withh::f("which") ; Web Freq 810.51 | Fixes 1 word ; Allows :B0X?:inm::f("in") to exist below

;============== Determine end line of no-sort items ======================
; Please don't change the "NoSortItemsEndAt := A_LineNumber". 
NoSortItemsEndAt := A_LineNumber ; ConflictingStringLocator tool uses this. 
; ==============================================

; MARK: Main List

:B0X*:Buddist::f("Buddhist") ; Web Freq 4.34 | Fixes 3 words
:B0X*:Feburary::f("February") ; Web Freq 127.70 | Fixes 1 word
:B0X*:Hatian::f("Haitian") ; Web Freq 2.21 | Fixes 2 words
:B0X*:Isaax ::f("Isaac") ; Web Freq 5.93 | Fixes 2 words
:B0X*:Israelies::f("Israelis") ; Web Freq 1.82 | Fixes 1 word
:B0X*:Janurar::f("Januar") ; Web Freq 310.35 | Fixes 2 words
:B0X*:Januray::f("January") ; Web Freq 310.35 | Fixes 1 word
:B0X*:Karent::f("Karen") ; Web Freq 13.11 | Fixes 3 words
:B0X*:Montnana::f("Montana") ; Web Freq 22.38 | Fixes 3 words
:B0X*:Naploeon::f("Napoleon") ; Web Freq 6.95 | Fixes 5 words
:B0X*:Napolean::f("Napoleon") ; Web Freq 6.95 | Fixes 5 words
:B0X*:Novermber::f("November") ; Web Freq 163.34 | Fixes 2 words
:B0X*:Pennyslvania::f("Pennsylvania") ; Web Freq 37.29 | Fixes 3 words
:B0X*:Queenland::f("Queensland") ; Web Freq 9.60 | Fixes 3 words
:B0X*:Sacremento::f("Sacramento") ; Web Freq 15.55 | Fixes 1 word
:B0X*:Straight of::f("Strait of") ; Fixes 1 word
:B0X*:Thues::f("Thurs") ; Web Freq 70.54 | Fixes 4 words
:B0X*:ToolTop::f("ToolTip") ; Web Freq 0.70 | Fixes 2 words
:B0X*:a FM::f("an FM") ; Fixes 1 word
:B0X*:a MRI::f("an MRI") ; Fixes 1 word
:B0X*:a businessmen::f("a businessman") ; Fixes 1 word
:B0X*:a businesswomen::f("a businesswoman") ; Fixes 1 word
:B0X*:a consortia::f("a consortium") ; Fixes 1 word
:B0X*:a criteria::f("a criterion") ; Fixes 1 word
:B0X*:a falling out::f("a falling-out") ; Fixes 1 word
:B0X*:a firemen::f("a fireman") ; Fixes 1 word
:B0X*:a flagella::f("a flagellum") ; Fixes 1 word
:B0X*:a forward by::f("a foreword by") ; Fixes 1 word
:B0X*:a freshmen::f("a freshman") ; Fixes 1 word
:B0X*:a fungi::f("a fungus") ; Fixes 1 word
:B0X*:a gunmen::f("a gunman") ; Fixes 1 word
:B0X*:a heir::f("an heir") ; Fixes 1 word
:B0X*:a herb::f("an herb") ; Fixes 1 word
:B0X*:a honest::f("an honest") ; Fixes 1 word
:B0X*:a honor::f("an honor") ; Fixes 1 word
:B0X*:a hour::f("an hour") ; Fixes 1 word
:B0X*:a larvae::f("a larva") ; Fixes 1 word
:B0X*:a lock up::f("a lockup") ; Fixes 1 word
:B0X*:a nuclei::f("a nucleus") ; Fixes 1 word
:B0X*:a numbers of::f("a number of") ; Fixes 1 word
:B0X*:a ocean::f("an ocean") ; Fixes 1 word
:B0X*:a offen::f("an offen") ; Fixes 1 word
:B0X*:a offic::f("an offic") ; Fixes 1 word
:B0X*:a one of the::f("one of the") ; Fixes 1 word
:B0X*:a oupl::f("a coupl") ; Fixes 1 word
:B0X*:a parentheses::f("a parenthesis") ; Fixes 1 word
:B0X*:a pupae::f("a pupa") ; Fixes 1 word
:B0X*:a radii::f("a radius") ; Fixes 1 word
:B0X*:a regular bases::f("a regular basis") ; Fixes 1 word
:B0X*:a resent::f("a recent") ; Fixes 1 word
:B0X*:a run in::f("a run-in") ; Fixes 1 word
:B0X*:a set back::f("a set-back") ; Fixes 1 word
:B0X*:a set up::f("a setup") ; Fixes 1 word
:B0X*:a several::f("several") ; Web Freq 107.87 | Fixes 16 words
:B0X*:a simple as::f("as simple as") ; Fixes 1 word
:B0X*:a spermatozoa::f("a spermatozoon") ; Fixes 1 word
:B0X*:a statesmen::f("a statesman") ; Fixes 1 word
:B0X*:a two months::f("a two-month") ; Fixes 1 word
:B0X*:a urban::f("an urban") ; Fixes 1 word
:B0X*:a vertebrae::f("a vertebra") ; Fixes 1 word
:B0X*:a women::f("a woman") ; Fixes 1 word
:B0X*:a work out::f("a workout") ; Fixes 1 word
:B0X*:abandonned::f("abandoned") ; Web Freq 6.37 | Fixes 2 words
:B0X*:abcense::f("absence") ; Web Freq 15.76 | Fixes 2 words
:B0X*:aberan::f("aberran") ; Web Freq 0.37 | Fixes 7 words
:B0X*:aberat::f("aberrat") ; Web Freq 0.90 | Fixes 8 words
:B0X*:abondon::f("abandon") ; Web Freq 11.77 | Fixes 10 words
:B0X*:about it's::f("about its") ; Fixes 1 word
:B0X*:about they're::f("about their") ; Fixes 1 word
:B0X*:about who to::f("about whom to") ; Fixes 1 word
:B0X*:about who's::f("about whose") ; Fixes 1 word
:B0X*:abouta::f("about a") ; Fixes 1 word
:B0X*:aboutit::f("about it") ; Fixes 1 word
:B0X*:aboutthe::f("about the") ; Fixes 1 word
:B0X*:above it's::f("above its") ; Fixes 1 word
:B0X*:abreviat::f("abbreviat") ; Web Freq 6.80 | Fixes 9 words
:B0X*:absail::f("abseil") ; Web Freq 0.23 | Fixes 6 words
:B0X*:abscen::f("absen") ; Web Freq 26.62 | Fixes 19 words
:B0X*:absense::f("absence") ; Web Freq 15.76 | Fixes 2 words
:B0X*:abutts::f("abuts") ; Web Freq 0.11 | Fixes 1 word
:B0X*:acclimit::f("acclimat") ; Web Freq 0.56 | Fixes 20 words
:B0X*:accomd::f("accommod") ; Web Freq 81.88 | Fixes 17 words
:B0X*:accordeon::f("accordion") ; Web Freq 1.38 | Fixes 4 words
:B0X*:accordian::f("accordion") ; Web Freq 1.38 | Fixes 4 words
:B0X*:according a::f("according to a") ; Fixes 1 word
:B0X*:accordingto::f("according to") ; Fixes 1 word
:B0X*:achei::f("achie") ; Web Freq 75.25 | Fixes 12 words
:B0X*:ackward::f("awkward") ; Web Freq 2.64 | Fixes 6 words
:B0X*:acquite::f("acquitte") ; Web Freq 0.59 | Fixes 3 words
:B0X*:across it's::f("across its") ; Fixes 1 word
:B0X*:acuse::f("accuse") ; Web Freq 10.88 | Fixes 6 words
:B0X*:adbandon::f("abandon") ; Web Freq 11.77 | Fixes 10 words
:B0X*:adhear::f("adher") ; Web Freq 7.46 | Fixes 14 words
:B0X*:adheran::f("adheren") ; Web Freq 2.62 | Fixes 7 words
:B0X*:adresa::f("addressa") ; Web Freq 0.34 | Fixes 3 words
:B0X*:adress::f("address") ; Web Freq 317.77 | Fixes 15 words
:B0X*:afair::f("affair") ; Web Freq 43.11 | Fixes 4 words
:B0X*:affect upon::f("effect upon") ; Fixes 1 word
:B0X*:afficianad::f("aficionad") ; Web Freq 0.62 | Fixes 4 words
:B0X*:afficionad::f("aficionad") ; Web Freq 0.62 | Fixes 4 words
:B0X*:after awhile::f("after a while") ; Fixes 1 word
:B0X*:after been::f("after being") ; Fixes 1 word
:B0X*:after it's::f("after its") ; Fixes 1 word
:B0X*:after quite awhile::f("after quite a while") ; Fixes 1 word
:B0X*:afterthe::f("after the") ; Fixes 1 word
:B0X*:against it's::f("against its") ; Fixes 1 word
:B0X*:againstt he::f("against the") ; Fixes 1 word
:B0X*:agani::f("again") ; Web Freq 298.04 | Fixes 2 words
:B0X*:aggregious::f("egregious") ; Web Freq 0.48 | Fixes 4 words
:B0X*:agian::f("again") ; Web Freq 298.04 | Fixes 2 words
:B0X*:agina::f("again") ; Web Freq 298.04 | Fixes 2 words
:B0X*:aginn::f("again") ; Web Freq 298.04 | Fixes 2 words
:B0X*:aginst::f("against") ; Web Freq 147.26 | Fixes 1 word
:B0X*:agriev::f("aggriev") ; Web Freq 0.53 | Fixes 7 words
:B0X*:ahjk::f("ahk") ; Autohotkey file extension
:B0X*:aiport::f("airport") ; Web Freq 76.11 | Fixes 2 words
:B0X*:airplane hanger::f("airplane hangar") ; Fixes 1 word
:B0X*:airrcraft::f("aircraft") ; Web Freq 24.75 | Fixes 5 words
:B0X*:aledg::f("alleg") ; Web Freq 26.96 | Fixes 50 words
:B0X*:aleea::f("alrea") ; Web Freq 108.32 | Fixes 1 word
:B0X*:aleg::f("alleg") ; Web Freq 26.96 | Fixes 50 words, but misspells alegar (vinegar made of ale), alegge (Old English verb derived from the Latin 'alleviare' meaning "to lighten")
:B0X*:algebraical::f("algebraic") ; Web Freq 2.26 | Fixes 1 word
:B0X*:all it's::f("all its") ; Fixes 1 word
:B0X*:all tolled::f("all told") ; Fixes 1 word
:B0X*:allegedy::f("allegedly") ; Web Freq 3.22 | Fixes 1 word
:B0X*:allegely::f("allegedly") ; Web Freq 3.22 | Fixes 1 word
:B0X*:allot of::f("a lot of") ; Fixes 1 word
:B0X*:allr::f("alr") ; Web Freq 111.96 | Fixes 2 words
:B0X*:alltime::f("all-time") ; Fixes 1 word
:B0X*:alma matter::f("alma mater") ; Fixes 1 word
:B0X*:almots::f("almost") ; Web Freq 66.40 | Fixes 1 word
:B0X*:along it's::f("along its") ; Fixes 1 word
:B0X*:along side::f("alongside") ; Web Freq 4.74 | Fixes 1 word
:B0X*:along time::f("a long time") ; Fixes 1 word
:B0X*:alongside it's::f("alongside its") ; Fixes 1 word
:B0X*:alter boy::f("altar boy") ; Fixes 1 word
:B0X*:alter server::f("altar server") ; Fixes 1 word
:B0X*:alterio::f("ulterio") ; Web Freq 0.19 | Fixes 4 words
:B0X*:alternit::f("alternat") ; Web Freq 91.33 | Fixes 17 words
:B0X*:althought::f("although") ; Web Freq 79.58 | Fixes 1 word
:B0X*:altoug::f("althoug") ; Web Freq 79.58 | Fixes 1 word
:B0X*:alusi::f("allusi") ; Web Freq 0.75 | Fixes 6 words
:B0X*:am loathe to::f("am loath to") ; Fixes 1 word
:B0X*:amalgom::f("amalgam") ; Web Freq 1.66 | Fixes 11 words
:B0X*:amature::f("amateur") ; Web Freq 47.31 | Fixes 8 words
:B0X*:amid it's::f("amid its") ; Fixes 1 word
:B0X*:amidst it's::f("amidst its") ; Fixes 1 word
:B0X*:amme::f("ame") ; Web Freq 502.85 | Fixes 137 words, but misspells ammeter (electrician's tool)
:B0X*:ammuse::f("amuse") ; Web Freq 6.31 | Fixes 8 words .
:B0X*:among it's::f("among it") ; Fixes 1 word
:B0X*:among others things::f("among other things") ; Fixes 1 word
:B0X*:amongst it's::f("amongst its") ; Fixes 1 word
:B0X*:amongst one of the::f("amongst the") ; Fixes 1 word
:B0X*:amongst others things::f("amongst other things") ; Fixes 1 word
:B0X*:amung::f("among") ; Web Freq 91.09 | Fixes 2 words
:B0X*:amunition::f("ammunition") ; Web Freq 2.61 | Fixes 2 words
:B0X*:an USB::f("a USB") ; Fixes 1 word
:B0X*:an Unix::f("a Unix") ; Fixes 1 word
:B0X*:an another::f("another") ; Web Freq 192.54 | Fixes 1 word
:B0X*:an antennae::f("an antenna") ; Fixes 1 word
:B0X*:an film::f("a film") ; Fixes 1 word
:B0X*:an half::f("a half") ; Fixes 1 word
:B0X*:an halt::f("a halt") ; Fixes 1 word
:B0X*:an hand::f("a hand") ; Fixes 1 word
:B0X*:an head::f("a head") ; Fixes 1 word
:B0X*:an heart::f("a heart") ; Fixes 1 word
:B0X*:an helicopter::f("a helicopter") ; Fixes 1 word
:B0X*:an hero::f("a hero") ; Fixes 1 word
:B0X*:an high::f("a high") ; Fixes 1 word
:B0X*:an histor::f("a histor") ; Fixes 1 word
:B0X*:an hospital::f("a hospital") ; Fixes 1 word
:B0X*:an hotel::f("a hotel") ; Fixes 1 word
:B0X*:an humanitarian::f("a humanitarian") ; Fixes 1 word
:B0X*:an large::f("a large") 
:B0X*:an law::f("a law") ; Fixes 1 word
:B0X*:an local::f("a local") ; Fixes 1 word
:B0X*:an new::f("a new") ; Fixes 1 word
:B0X*:an nin::f("a nin") ; Fixes 1 word
:B0X*:an non::f("a non") ; Fixes 1 word
:B0X*:an number::f("a number") ; Fixes 1 word
:B0X*:an pair::f("a pair") ; Fixes 1 word
:B0X*:an player::f("a player") ; Fixes 1 word
:B0X*:an popular::f("a popular") ; Fixes 1 word
:B0X*:an pre-::f("a pre-") ; Fixes 1 word
:B0X*:an sec::f("a sec") ; Fixes 1 word
:B0X*:an ser::f("a ser") ; Fixes 1 word
:B0X*:an seven::f("a seven") ; Fixes 1 word
:B0X*:an six::f("a six") ; Fixes 1 word
:B0X*:an song::f("a song") ; Fixes 1 word
:B0X*:an spec::f("a spec") ; Fixes 1 word
:B0X*:an stat::f("a stat") ; Fixes 1 word
:B0X*:an ten::f("a ten") ; Fixes 1 word
:B0X*:an union::f("a union") ; Fixes 1 word
:B0X*:an unit::f("a unit") ; Fixes 1 word
:B0X*:analag::f("analog") ; Web Freq 21.67 | Fixes 26 words
:B0X*:anarchim::f("anarchism") ; Web Freq 0.46 | Fixes 2 words
:B0X*:anarchistm::f("anarchism") ; Web Freq 0.46 | Fixes 2 words
:B0X*:and/of::f("and/or") ; Fixes 1 word
:B0X*:andd::f("and") ; Web Freq 13125.07 | Fixes 100 words
:B0X*:andone::f("and one") ; Fixes 1 word
:B0X*:androgenous::f("androgynous") ; Web Freq 0.11 | Fixes 3 words
:B0X*:androgeny::f("androgyny") ; Web Freq 0.05 | Fixes 1 word
:B0X*:anih::f("annih") ; Web Freq 1.39 | Fixes 10 words
:B0X*:aniv::f("anniv") ; Web Freq 20.12 | Fixes 2 words
:B0X*:anonim::f("anonym") ; Web Freq 35.72 | Fixes 20 words
:B0X*:anoy::f("annoy") ; Web Freq 10.68 | Fixes 11 words
:B0X*:ansal::f("nasal") ; Web Freq 2.58 | Fixes 22 words
:B0X*:ansest::f("ancest") ; Web Freq 10.79 | Fixes 10 words
:B0X*:anti-semetic::f("anti-Semitic") ; Fixes 1 word
:B0X*:anual::f("annual") ; Web Freq 96.10 | Fixes 15 words
:B0X*:anul::f("annul") ; Web Freq 1.46 | Fixes 18 words
:B0X*:any another::f("another") ; Web Freq 192.54 | Fixes 1 word
:B0X*:any resent::f("any recent") ; Fixes 1 word
:B0X*:any where::f("anywhere") ; Web Freq 23.95 | Fixes 2 words
:B0X*:anyother::f("any other") ; Fixes 1 word
:B0X*:anytying::f("anything") ; Web Freq 76.00 | Fixes 2 words
:B0X*:aoubt::f("about") ; Web Freq 1226.73 | Fixes 2 words
:B0X*:apart form::f("apart from") ; Fixes 1 word
:B0X*:aproxim::f("approxim") ; Web Freq 48.77 | Fixes 14 words
:B0X*:aquaduct::f("aqueduct") ; Web Freq 0.47 | Fixes 2 words
:B0X*:aquir::f("acquir") ; Web Freq 27.30 | Fixes 12 words
:B0X*:arbouret::f("arboret") ; Web Freq 0.91 | Fixes 3 words
:B0X*:archiac::f("archaic") ; Web Freq 0.80 | Fixes 7 words
:B0X*:archimedian::f("Archimedean") ; Web Freq 0.06 | Fixes 1 word
:B0X*:archtyp::f("archetyp") ; Web Freq 1.22 | Fixes 6 words
:B0X*:are aloud to::f("are allowed to") ; Fixes 1 word
:B0X*:are build::f("are built") ; Fixes 1 word
:B0X*:are drew::f("are drawn") ; Fixes 1 word
:B0X*:are it's::f("are its") ; Fixes 1 word
:B0X*:are know::f("are known") ; Fixes 1 word
:B0X*:are lain::f("are laid") ; Fixes 1 word
:B0X*:are loathe to::f("are loath to") ; Fixes 1 word
:B0X*:are ran by::f("are run by") ; Fixes 1 word
:B0X*:are set-up::f("are set up") ; Fixes 1 word
:B0X*:are setup::f("are set up") ; Fixes 1 word
:B0X*:are shutdown::f("are shut down") ; Fixes 1 word
:B0X*:are shutout::f("are shut out") ; Fixes 1 word
:B0X*:aready::f("already") ; Web Freq 108.32 | Fixes 1 word
:B0X*:areod::f("aerod") ; Web Freq 1.62 | Fixes 14 words
:B0X*:arised::f("arose") ; Web Freq 2.61 | Fixes 1 word
:B0X*:ariv::f("arriv") ; Web Freq 57.67 | Fixes 12 words
:B0X*:armistace::f("armistice") ; Web Freq 0.27 | Fixes 2 words
:B0X*:arn't::f("aren't") ; Fixes 1 word
:B0X*:aroga::f("arroga") ; Web Freq 2.60 | Fixes 15 words
:B0X*:arond::f("around") ; Web Freq 178.81 | Fixes 1 word
:B0X*:aroud::f("around") ; Web Freq 178.81 | Fixes 1 word
:B0X*:around it's::f("around its") ; Fixes 1 word
:B0X*:arrat::f("array") ; Web Freq 29.47 | Fixes 8 words
:B0X*:arren::f("arran") ; Web Freq 51.35 | Fixes 13 words
:B0X*:arrou::f("arou") ; Web Freq 181.23 | Fixes 11 words
:B0X*:artc::f("artic") ; Web Freq 341.06 | Fixes 28 words
:B0X*:artical::f("article") ; Web Freq 333.54 | Fixes 3 words
:B0X*:artifical::f("artificial") ; Web Freq 11.58 | Fixes 7 words
:B0X*:artillar::f("artiller") ; Web Freq 2.59 | Fixes 6 words
:B0X*:as a resulted::f("as a result") ; Fixes 1 word
:B0X*:as apposed to::f("as opposed to") ; Fixes 1 word
:B0X*:as back up::f("as backup") ; Fixes 1 word
:B0X*:as oppose to::f("as opposed to") ; Fixes 1 word
:B0X*:asetic::f("ascetic") ; Web Freq 0.36 | Fixes 6 words
:B0X*:asfar::f("as far") ; Fixes 1 word
:B0X*:aside form::f("aside from") ; Fixes 1 word
:B0X*:aside it's::f("aside its") ; Fixes 1 word
:B0X*:asoo::f("also") ; Web Freq 616.83 | Fixes 3 words
:B0X*:aspect ration::f("aspect ratio") ; Fixes 1 word
:B0X*:asphyxa::f("asphyxia") ; Web Freq 0.27 | Fixes 13 words
:B0X*:assasin::f("assassin") ; Web Freq 5.56 | Fixes 10 words
:B0X*:assiden::f("acciden") ; Web Freq 34.53 | Fixes 10 words
:B0X*:assignemen::f("assignmen") ; Web Freq 25.01 | Fixes 2 words
:B0X*:assisn::f("assassin") ; Web Freq 5.56 | Fixes 10 words
:B0X*:assisten::f("assistan") ; Web Freq 94.79 | Fixes 7 words
:B0X*:assita::f("assista") ; Web Freq 94.79 | Fixes 7 words
:B0X*:assume the reigns::f("assume the reins") ; Fixes 1 word
:B0X*:assume the roll::f("assume the role") ; Fixes 1 word
:B0X*:asum::f("assum") ; Web Freq 82.92 | Fixes 21 words
:B0X*:aswell::f("as well") ; Fixes 1 word
:B0X*:at it's::f("at its") ; Fixes 1 word
:B0X*:at of::f("at or") ; Fixes 1 word
:B0X*:at the alter::f("at the altar") ; Fixes 1 word
:B0X*:at the reigns::f("at the reins") ; Fixes 1 word
:B0X*:at then end::f("at the end") ; Fixes 1 word
:B0X*:at-rist::f("at-risk ") ; Fixes 1 word
:B0X*:atheistical::f("atheistic") ; Web Freq 0.16 | Fixes 5 words
:B0X*:athenean::f("Athenian") ; Web Freq 0.57 | Fixes 2 words
:B0X*:atleast::f("at least") ; Fixes 1 word
:B0X*:atn::f("ant") ; Web Freq 306.40 | Fixes 1319 words
:B0X*:atorn::f("attorn") ; Web Freq 57.16 | Fixes 10 words
:B0X*:attant::f("attent") ; Web Freq 46.72 | Fixes 8 words
:B0X*:attened::f("attended") ; Web Freq 12.28 | Fixes 1 word
:B0X*:attour::f("attor") ; Web Freq 57.16 | Fixes 10 words
:B0X*:atuo::f("auto") ; Web Freq 294.20 | Fixes 388 words
:B0X*:audialo::f("audiolo") ; Web Freq 1.27 | Fixes 6 words
:B0X*:authora::f("authorita") ; Web Freq 3.47 | Fixes 8 words
:B0X*:authorites::f("authorities") ; Web Freq 23.25 | Fixes 1 word
:B0X*:authoritiv::f("authoritativ") ; Web Freq 2.46 | Fixes 4 words
:B0X*:autocto::f("autochtho") ; Web Freq 0.05 | Fixes 10 words
:B0X*:autsi::f("autis") ; Web Freq 4.82 | Fixes 7 words
:B0X*:auxila::f("auxilia") ; Web Freq 4.77 | Fixes 2 words
:B0X*:auxilla::f("auxilia") ; Web Freq 4.77 | Fixes 2 words
:B0X*:auxilli::f("auxili") ; Web Freq 4.77 | Fixes 2 words
:B0X*:avalance::f("avalanche") ; Web Freq 3.08 | Fixes 3 words
:B0X*:avati::f("aviati") ; Web Freq 17.18 | Fixes 4 words
:B0X*:avengence::f("a vengeance") ; Fixes 1 word
:B0X*:away form::f("away from") ; Fixes 1 word
:B0X*:aywa::f("away") ; Web Freq 113.24 | Fixes 6 words
:B0X*:baceau::f("becau") ; Web Freq 271.32 | Fixes 1 word
:B0X*:back and fourth::f("back and forth") ; Fixes 1 word
:B0X*:back drop::f("backdrop") ; Web Freq 2.12 | Fixes 5 words
:B0X*:back fir::f("backfir") ; Web Freq 0.59 | Fixes 4 words
:B0X*:back peddle::f("backpedal") ; Web Freq 0.04 | Fixes 6 words
:B0X*:back round::f("background") ; Web Freq 60.00 | Fixes 6 words
:B0X*:badly effected::f("badly affected") ; Fixes 1 word
:B0X*:baited breath::f("bated breath") ; Fixes 1 word
:B0X*:baled out::f("bailed out") ; Fixes 1 word
:B0X*:baling out::f("bailing out") ; Fixes 1 word
:B0X*:banann::f("banan") ; Web Freq 7.46 | Fixes 2 words
:B0X*:bandonn::f("abandon") ; Web Freq 11.77 | Fixes 10 words
:B0X*:bandwit::f("bandwidt") ; Web Freq 13.15 | Fixes 2 words
:B0X*:bankrupc::f("bankruptc") ; Web Freq 18.30 | Fixes 2 words
:B0X*:banrup::f("bankrup") ; Web Freq 19.82 | Fixes 7 words
:B0X*:barb wire::f("barbed wire") ; Fixes 1 word
:B0X*:bare the brunt::f("bear the brunt") ; Fixes 1 word
:B0X*:bare the burden::f("bear the burden") ; Fixes 1 word
:B0X*:bare the consequence::f("bear the consequence") ; Fixes 1 word
:B0X*:bare the cost::f("bear the cost") ; Fixes 1 word
:B0X*:bare the pain::f("bear the pain") ; Fixes 1 word
:B0X*:barily::f("barely") ; Web Freq 6.76 | Fixes 1 word
:B0X*:basic principal::f("basic principle") ; Fixes 1 word
:B0X*:be apart of::f("be a part of") ; Fixes 1 word
:B0X*:be build::f("be built") ; Fixes 1 word
:B0X*:be cause::f("because") ; Web Freq 271.32 | Fixes 1 word
:B0X*:be drew::f("be drawn") ; Fixes 1 word
:B0X*:be it's::f("be its") ; Fixes 1 word
:B0X*:be know as::f("be known as") ; Fixes 1 word
:B0X*:be lain::f("be laid") ; Fixes 1 word
:B0X*:be loathe to::f("be loath to") ; Fixes 1 word
:B0X*:be rebuild::f("be rebuilt") ; Fixes 1 word
:B0X*:be set-up::f("be set up") ; Fixes 1 word
:B0X*:be setup::f("be set up") ; Fixes 1 word
:B0X*:be shutdown::f("be shut down") ; Fixes 1 word
:B0X*:be ware::f("beware") ; Web Freq 3.74 | Fixes 3 words
:B0X*:beaau::f("becau") ; Web Freq 271.32 | Fixes 1 word
:B0X*:beachead::f("beachhead") ; Web Freq 0.09 | Fixes 2 words
:B0X*:beacu::f("becau") ; Web Freq 271.32 | Fixes 1 word
:B0X*:beastia::f("bestia") ; Web Freq 17.64 | Fixes 14 words
:B0X*:became it's::f("became its") ; Fixes 1 word
:B0X*:becass::f("becaus") ; Web Freq 271.32 | Fixes 1 word
:B0X*:because of it's::f("because of its") ; Fixes 1 word
:B0X*:becausea::f("because a") ; Fixes 1 word
:B0X*:becauseof::f("because of") ; Fixes 1 word
:B0X*:becausethe::f("because the") ; Fixes 1 word
:B0X*:becauseyou::f("because you") ; Fixes 1 word
:B0X*:beccau::f("becau") ; Web Freq 271.32 | Fixes 1 word
:B0X*:becous::f("becaus") ; Web Freq 271.32 | Fixes 1 word
:B0X*:becus::f("becaus") ; Web Freq 271.32 | Fixes 1 word
:B0X*:been accustom to::f("been accustomed to") ; Fixes 1 word
:B0X*:been build::f("been built") ; Fixes 1 word
:B0X*:been it's::f("been its") ; Fixes 1 word
:B0X*:been lain::f("been laid") ; Fixes 1 word
:B0X*:been loathe to::f("been loath to") ; Fixes 1 word
:B0X*:been mislead::f("been misled") ; Fixes 1 word
:B0X*:been rebuild::f("been rebuilt") ; Fixes 1 word
:B0X*:been set-up::f("been set up") ; Fixes 1 word
:B0X*:been setup::f("been set up") ; Fixes 1 word
:B0X*:been show on::f("been shown on") ; Fixes 1 word
:B0X*:been shutdown::f("been shut down") ; Fixes 1 word
:B0X*:before hand::f("beforehand") ; Web Freq 1.44 | Fixes 1 word
:B0X*:began it's::f("began its") ; Fixes 1 word
:B0X*:beggine::f("beginne") ; Web Freq 11.70 | Fixes 2 words
:B0X*:beggins::f("begins") ; Web Freq 22.76 | Fixes 1 word
:B0X*:begini::f("beginni") ; Web Freq 51.59 | Fixes 3 words
:B0X*:behau::f("becau") ; Web Freq 271.32 | Fixes 1 word
:B0X*:behind it's::f("behind its") ; Fixes 1 word
:B0X*:behwe::f("betwe") ; Web Freq 255.45 | Fixes 7 words
:B0X*:being build::f("being built") ; Fixes 1 word
:B0X*:being it's::f("being its") ; Fixes 1 word
:B0X*:being lain::f("being laid") ; Fixes 1 word
:B0X*:being loathe to::f("being loath to") ; Fixes 1 word
:B0X*:being set-up::f("being set up") ; Fixes 1 word
:B0X*:being setup::f("being set up") ; Fixes 1 word
:B0X*:being show on::f("being shown on") ; Fixes 1 word
:B0X*:being shutdown::f("being shut down") ; Fixes 1 word
:B0X*:beligum::f("Belgium") ; Web Freq 23.70 | Fixes 1 word
:B0X*:beliv::f("believ") ; Web Freq 111.47 | Fixes 13 words, but misspells Belive (Archaic term denoting 'soon', 'quickly', or 'to remain')
:B0X*:bellweat::f("bellwet") ; Web Freq 0.18 | Fixes 2 words
:B0X*:below it's::f("below its") ; Fixes 1 word
:B0X*:beneath it's::f("beneath its") ; Fixes 1 word
:B0X*:beoor::f("befor") ; Web Freq 278.98 | Fixes 3 words
:B0X*:bergamont::f("bergamot") ; Web Freq 0.39 | Fixes 2 words
:B0X*:beseig::f("besieg") ; Web Freq 0.50 | Fixes 9 words
:B0X*:beside it's::f("beside its") ; Fixes 1 word
:B0X*:besides it's::f("besides its") ; Fixes 1 word
:B0X*:beteen::f("between") ; Web Freq 255.45 | Fixes 7 words
:B0X*:better know as::f("better known as") ; Fixes 1 word
:B0X*:better know for::f("better known for") ; Fixes 1 word
:B0X*:better then::f("better than") ; Fixes 1 word
:B0X*:between he and::f("between him and") ; Fixes 1 word
:B0X*:between it's::f("between its") ; Fixes 1 word
:B0X*:between they and::f("between them and") ; Fixes 1 word
:B0X*:betwen::f("between") ; Web Freq 255.45 | Fixes 7 words
:B0X*:beut::f("beaut") ; Web Freq 154.10 | Fixes 30 words
:B0X*:beuuti::f("beauti") ; Web Freq 66.27 | Fixes 19 words
:B0X*:bevore::f("before") ; Web Freq 278.98 | Fixes 3 words
:B0X*:beween::f("between") ; Web Freq 255.45 | Fixes 7 words
:B0X*:bewte::f("betwe") ; Web Freq 255.45 | Fixes 7 words
:B0X*:bewwe::f("betwe") ; Web Freq 255.45 | Fixes 7 words
:B0X*:beyond it's::f("beyond its") ; Fixes 1 word
:B0X*:billingual::f("bilingual") ; Web Freq 3.74 | Fixes 9 words
:B0X*:bizzar::f("bizarr") ; Web Freq 8.49 | Fixes 9 words
:B0X*:blitzkreig::f("Blitzkrieg") ; Web Freq 0.59 | Fixes 4 words
:B0X*:boder::f("border") ; Web Freq 35.58 | Fixes 13 words was 'border-line'
:B0X*:bodydb::f("bodyb") ; Web Freq 3.51 | Fixes 10 words
:B0X*:boilerplac::f("boilerplat") ; Web Freq 0.24 | Fixes 2 words
:B0X*:bonifid::f("bona fide") ; Fixes 1 word 
:B0X*:bonofid::f("bona fide") ; Fixes 1 word
:B0X*:both it's::f("both its") ; Fixes 1 word
:B0X*:both of it's::f("both of its") ; Fixes 1 word
:B0X*:both of them is::f("both of them are") ; Fixes 1 word
:B0X*:boyan::f("buoyan") ; Web Freq 1.10 | Fixes 7 words
:B0X*:brake away::f("break away") ; Fixes 1 word
:B0X*:brake the rule::f("break the rule") ; Fixes 1 word
:B0X*:brake through::f("break through") ; Fixes 1 word
:B0X*:brasillian::f("Brazilian") ; Web Freq 9.63 | Fixes 2 words
:B0X*:breakthough::f("breakthrough") ; Web Freq 4.51 | Fixes 2 words
:B0X*:breath fire::f("breathe fire") ; Fixes 1 word
:B0X*:brethen::f("brethren") ; Web Freq 2.17 | Fixes 1 word
:B0X*:bretheren::f("brethren") ; Web Freq 2.17 | Fixes 1 word
:B0X*:brew haha::f("brouhaha") ; Web Freq 0.10 | Fixes 2 words
:B0X*:brillan::f("brillian") ; Web Freq 12.79 | Fixes 10 words
:B0X*:brimeston::f("brimston") ; Web Freq 0.30 | Fixes 3 words
:B0X*:britian::f("Britain") ; Web Freq 23.03 | Fixes 1 word
:B0X*:britti::f("Briti") ; Web Freq 70.98 | Fixes 8 words
:B0X*:broady::f("broadly") ; Web Freq 2.94 | Fixes 1 word
:B0X*:brocolli::f("broccoli") ; Web Freq 1.63 | Fixes 2 words
:B0X*:buddah::f("Buddha") ; Web Freq 8.81 | Fixes 4 words
:B0X*:bueaus::f("becaus") ; Web Freq 271.32 | Fixes 1 word
:B0X*:bunth::f("bunch") ; Web Freq 11.37 | Fixes 16 words
:B0X*:buoan::f("buoyan") ; Web Freq 1.10 | Fixes 7 words
:B0X*:by it's::f("by its") ; Fixes 1 word
:B0X*:by who's::f("by whose") ; Fixes 1 word
:B0X*:byt he::f("by the") ; Fixes 1 word
:B0X*:cacus::f("caucus") ; Web Freq 2.12 | Fixes 7 words
:B0X*:calaber::f("caliber") ; Web Freq 1.86 | Fixes 2 words
:B0X*:calander::f("calendar") ; Web Freq 113.07 | Fixes 4 words
:B0X*:calender::f("calendar") ; Web Freq 113.07 | Fixes 4 words
:B0X*:califroni::f("Californi") ; Web Freq 121.00 | Fixes 6 words
:B0X*:caligra::f("calligra") ; Web Freq 1.52 | Fixes 15 words
:B0X*:callipig::f("callipyg") ; Fixes 2 words
:B0X*:cambrige::f("Cambridge") ; Web Freq 24.05 | Fixes 2 words
:B0X*:camofla::f("camoufla") ; Web Freq 1.68 | Fixes 6 words
:B0X*:can backup::f("can back up") ; Fixes 1 word
:B0X*:can been::f("can be") ; Fixes 1 word
:B0X*:can blackout::f("can black out") ; Fixes 1 word
:B0X*:can checkout::f("can check out") ; Fixes 1 word
:B0X*:can playback::f("can play back") ; Fixes 1 word
:B0X*:can setup::f("can set up") ; Fixes 1 word
:B0X*:can tryout::f("can try out") ; Fixes 1 word
:B0X*:can workout::f("can work out") ; Fixes 1 word
:B0X*:candidiat::f("candidat") ; Web Freq 41.94 | Fixes 4 words
:B0X*:canend::f("calend") ; Web Freq 113.36 | Fixes 10 words
:B0X*:cannota::f("connota") ; Web Freq 0.64 | Fixes 5 words
:B0X*:cansel::f("cancel") ; Web Freq 42.61 | Fixes 21 words
:B0X*:cansent::f("consent ") ; Web Freq 22.81 | Fixes 13 words
:B0X*:cantalop::f("cantaloup") ; Web Freq 0.25 | Fixes 4 words
:B0X*:capetown::f("Cape Town") ; Fixes 1 word
:B0X*:carnege::f("Carnegie") ; Web Freq 4.46 | Fixes 2 words
:B0X*:carnige::f("Carnegie") ; Web Freq 4.46 | Fixes 2 words
:B0X*:carniver::f("carnivor") ; Web Freq 1.06 | Fixes 10 words
:B0X*:carree::f("caree") ; Web Freq 118.83 | Fixes 16 words
:B0X*:carrib::f("Carib") ; Web Freq 23.61 | Fixes 10 words
:B0X*:carthog::f("cartog") ; Web Freq 1.46 | Fixes 9 words
:B0X*:casion::f("caisson") ; Web Freq 0.11 | Fixes 2 words
:B0X*:cassawor::f("cassowar") ; Web Freq 0.05 | Fixes 2 words
:B0X*:cassowarr::f("cassowar") ; Web Freq 0.05 | Fixes 2 words
:B0X*:casula::f("casual") ; Web Freq 20.84 | Fixes 19 words
:B0X*:catapillar::f("caterpillar") ; Web Freq 4.24 | Fixes 3 words
:B0X*:catapiller::f("caterpillar") ; Web Freq 4.24 | Fixes 3 words
:B0X*:catepillar::f("caterpillar") ; Web Freq 4.24 | Fixes 3 words
:B0X*:caterpilar::f("caterpillar") ; Web Freq 4.24 | Fixes 3 words
:B0X*:caterpiller::f("caterpillar") ; Web Freq 4.24 | Fixes 3 words
:B0X*:catterpilar::f("caterpillar") ; Web Freq 4.24 | Fixes 3 words
:B0X*:catterpillar::f("caterpillar") ; Web Freq 4.24 | Fixes 3 words
:B0X*:caucasion::f("Caucasian") ; Web Freq 2.18 | Fixes 2 words
:B0X*:caught in the site::f("caught in the sight") ; Fixes 2 words
:B0X*:ceasa::f("Caesa") ; Web Freq 8.54 | Fixes 18 words
:B0X*:celcius::f("Celsius") ; Web Freq 1.04 | Fixes 1 word
:B0X*:cementar::f("cemeter") ; Web Freq 13.19 | Fixes 3 words
:B0X*:cemetar::f("cemeter") ; Web Freq 13.19 | Fixes 3 words
:B0X*:centut::f("centur") ; Web Freq 62.44 | Fixes 5 words
:B0X*:cereal connection::f("serial connection") ; Fixes 1 word
:B0X*:cereal interface::f("serial interface") ; Fixes 1 word
:B0X*:cereal killer::f("serial killer") ; Fixes 1 word
:B0X*:cereal offender::f("serial offender") ; Fixes 1 word
:B0X*:cereal port::f("serial port") ; Fixes 1 word
:B0X*:cervial::f("cervical") ; Web Freq 2.98 | Fixes 1 word
:B0X*:chalk full::f("chock-full") ; Fixes 1 word
:B0X*:champang::f("champagn") ; Web Freq 11.82 | Fixes 5 words
:B0X*:changed it's::f("changed its") ; Fixes 1 word
:B0X*:charistic::f("characteristic") ; Web Freq 31.35 | Fixes 4 words
:B0X*:chauffer::f("chauffeur") ; Web Freq 1.17 | Fixes 4 words
:B0X*:checge::f("change") ; Web Freq 398.90 | Fixes 29 words
:B0X*:childrens::f("children's") ; Fixes 1 word
:B0X*:chock it up::f("chalk it up") ; Fixes 1 word
:B0X*:chocked full::f("chock-full") ; Fixes 1 word
:B0X*:choclat::f("chocolat") ; Web Freq 26.79 | Fixes 7 words
:B0X*:chomping at the bit::f("champing at the bit") ; Fixes 1 word
:B0X*:choosen::f("chosen") ; Web Freq 42.69 | Fixes 2 words
:B0X*:cincinatti::f("Cincinnati") ; Web Freq 15.39 | Fixes 1 word
:B0X*:cincinnatti::f("Cincinnati") ; Web Freq 15.39 | Fixes 1 word
:B0X*:cirtu::f("citru") ; Web Freq 4.07 | Fixes 7 words
:B0X*:cite administrator::f("site administrator") ; Fixes 1 word
:B0X*:cite analys::f("site analys") ; Fixes 1 word
:B0X*:cite host::f("site host") ; Fixes 1 word
:B0X*:cite metric::f("site metric") ; Fixes 1 word
:B0X*:cite performance::f("site performance") ; Fixes 1 word
:B0X*:clera::f("clear") ; Web Freq 166.74 | Fixes 41 words
:B0X*:clipaoard::f("clipboard") ; Web Freq 3.30 | Fixes 2 words
:B0X*:clopbo::f("clipbo") ; Web Freq 3.30 | Fixes 2 words
:B0X*:closed it's::f("closed its") ; Fixes 1 word
:B0X*:closer then::f("closer than") ; Fixes 1 word
:B0X*:co-incid::f("coincid") ; Web Freq 6.38 | Fixes 10 words
:B0X*:colate::f("collate") ; Web Freq 4.92 | Fixes 20 words
:B0X*:colead::f("co-lead") ; Fixes 1 word
:B0X*:coleag::f("colleag") ; Web Freq 15.08 | Fixes 4 words
:B0X*:collaber::f("collabor") ; Web Freq 37.04 | Fixes 16 words
:B0X*:collosa::f("colossa") ; Web Freq 0.93 | Fixes 3 words
:B0X*:collose::f("coloss") ; Web Freq 4.41 | Fixes 11 words
:B0X*:collosi::f("colossi") ; Web Freq 1.14 | Fixes 3 words
:B0X*:colonel update::f("kernel update") ; Fixes 1 word
:B0X*:comand::f("command") ; Web Freq 98.27 | Fixes 24 words, but misspells Comandra (small genus of chiefly North American parasitic plants)
:B0X*:comback::f("comeback") ; Web Freq 1.97 | Fixes 4 words
:B0X*:commerorat::f("commemorat") ; Web Freq 4.24 | Fixes 12 words
:B0X*:commonly know as::f("commonly known as") ; Fixes 1 word
:B0X*:commonly know for::f("commonly known for") ; Fixes 1 word
:B0X*:compair::f("compare") ; Web Freq 221.50 | Fixes 5 words
:B0X*:compariti::f("comparati") ; Web Freq 11.44 | Fixes 9 words
:B0X*:comparito::f("comparato") ; Web Freq 0.93 | Fixes 2 words
:B0X*:compona::f("compone") ; Web Freq 94.74 | Fixes 6 words
:B0X*:compulsar::f("compulsor") ; Web Freq 4.11 | Fixes 4 words
:B0X*:compulser::f("compulsor") ; Web Freq 4.11 | Fixes 4 words
:B0X*:conciet::f("conceit") ; Web Freq 0.53 | Fixes 7 words
:B0X*:conda::f("conde") ; Web Freq 15.72 | Fixes 40 words
:B0X*:congradulat::f("congratulat") ; Web Freq 9.42 | Fixes 9 words
:B0X*:coniv::f("conniv") ; Web Freq 0.21 | Fixes 14 words
:B0X*:connet::f("connect") ; Web Freq 227.21 | Fixes 27 words
:B0X*:conot::f("connot") ; Web Freq 0.84 | Fixes 9 words
:B0X*:conquerer::f("conqueror") ; Web Freq 0.83 | Fixes 2 words
:B0X*:consin::f("contin") ; Web Freq 262.10 | Fixes 56 words
:B0X*:consorci::f("consorti") ; Web Freq 8.24 | Fixes 4 words
:B0X*:construction sight::f("construction site") ; Fixes 1 word
:B0X*:consulan::f("consultan") ; Web Freq 44.79 | Fixes 6 words
:B0X*:consulten::f("consultan") ; Web Freq 44.79 | Fixes 6 words
:B0X*:copy or report::f("copy of report") ; Fixes 1 word
:B0X*:copy or signed::f("copy of signed") ; Fixes 1 word
:B0X*:core principal::f("core principle") ; Fixes 1 word
:B0X*:corob::f("corrob") ; Web Freq 0.90 | Fixes 14 words
:B0X*:corod::f("corrod") ; Web Freq 0.34 | Fixes 11 words, but misspells Corody (Archic English term for right to claim provisions from another's land)
:B0X*:coros::f("corros") ; Web Freq 4.44 | Fixes 7 words
:B0X*:corrdinat::f("coordinat") ; Web Freq 53.34 | Fixes 12 words
:B0X*:correcpond::f("correspond") ; Web Freq 42.02 | Fixes 12 words
:B0X*:correpo::f("correspo") ; Web Freq 42.02 | Fixes 13 words
:B0X*:corridoor::f("corridor") ; Web Freq 6.32 | Fixes 2 words
:B0X*:couci::f("counci") ; Web Freq 126.73 | Fixes 17 words
:B0X*:coudn't::f("couldn't") ; Fixes 1 word
:B0X*:could backup::f("could back up") ; Fixes 1 word
:B0X*:could setup::f("could set up") ; Fixes 1 word
:B0X*:could workout::f("could work out") ; Fixes 1 word
:B0X*:coulse::f("course") ; Web Freq 249.40 | Fixes 10 words
:B0X*:councello::f("counselo") ; Web Freq 7.86 | Fixes 4 words
:B0X*:counr::f("countr") ; Web Freq 279.31 | Fixes 21 words
:B0X*:counsel member::f("council member") ; Fixes 1 word
:B0X*:courd::f("could") ; Web Freq 302.34 | Fixes 5 words
:B0X*:critere::f("criteri") ; Web Freq 38.65 | Fixes 7 words
:B0X*:criteria is::f("criteria are") ; Fixes 1 word
:B0X*:criteria was::f("criteria were") ; Fixes 1 word
:B0X*:critiz::f("criticiz") ; Web Freq 4.43 | Fixes 7 words
:B0X*:crucificti::f("crucifixi") ; Web Freq 1.09 | Fixes 4 words
:B0X*:culimi::f("culmi") ; Web Freq 2.46 | Fixes 9 words
:B0X*:curriculm::f("curriculum") ; Web Freq 24.57 | Fixes 2 words
:B0X*:dacquiri::f("daiquiri") ; Web Freq 0.13 | Fixes 2 words
:B0X*:dakiri::f("daiquiri") ; Web Freq 0.13 | Fixes 2 words
:B0X*:dalmation::f("dalmatian") ; Web Freq 1.33 | Fixes 4 words
:B0X*:darker then::f("darker than") ; Fixes 1 word
:B0X*:datyb::f("dayb") ; Web Freq 1.36 | Fixes 8 words
:B0X*:datyd::f("dayd") ; Web Freq 0.97 | Fixes 9 words
:B0X*:datyl::f("dayl") ; Web Freq 5.06 | Fixes 9 words
:B0X*:datyt::f("dayt") ; Web Freq 16.11 | Fixes 6 words
:B0X*:daye::f("date") ; Web Freq 541.77 | Fixes 24 words
:B0X*:deaful::f("defaul") ; Web Freq 58.13 | Fixes 6 words
:B0X*:decathal::f("decathl") ; Web Freq 0.26 | Fixes 4 words
:B0X*:deciding on how::f("deciding how") ; Fixes 1 word
:B0X*:decompositing::f("decomposing") ; Web Freq 0.24 | Fixes 1 word
:B0X*:decomposits::f("decomposes") ; Web Freq 0.14 | Fixes 1 word
:B0X*:decress::f("decrees") ; Web Freq 0.75 | Fixes 1 word
:B0X*:deep-seeded::f("deep-seated") ; Fixes 1 word
:B0X*:definan::f("defian") ; Web Freq 2.60 | Fixes 5 words
:B0X*:degug::f("debug") ; Web Freq 16.18 | Fixes 6 words
:B0X*:delapid::f("dilapid") ; Web Freq 0.31 | Fixes 6 words
:B0X*:deleri::f("deliri") ; Web Freq 1.10 | Fixes 9 words
:B0X*:delima::f("dilemma") ; Web Freq 4.06 | Fixes 3 words
:B0X*:demographical::f("demographic") ; Web Freq 10.04 | Fixes 2 words
:B0X*:deseas::f("diseas") ; Web Freq 85.28 | Fixes 6 words
:B0X*:desica::f("desicca") ; Web Freq 0.46 | Fixes 11 words
:B0X*:desint::f("disint") ; Web Freq 1.82 | Fixes 34 words
:B0X*:desktio::f("deskto") ; Web Freq 65.63 | Fixes 2 words
:B0X*:desktip::f("desktop") ; Web Freq 65.63 | Fixes 2 words
:B0X*:desorder::f("disorder") ; Web Freq 31.16 | Fixes 10 words
:B0X*:desori::f("disori") ; Web Freq 0.60 | Fixes 10 words
:B0X*:despar::f("desper") ; Web Freq 13.46 | Fixes 10 words
:B0X*:dessica::f("desicca") ; Web Freq 0.46 | Fixes 11 words
:B0X*:deteria::f("deteriora") ; Web Freq 4.04 | Fixes 7 words
:B0X*:detrem::f("detrim") ; Web Freq 2.40 | Fixes 6 words
:B0X*:devaste::f("devastate") ; Web Freq 1.33 | Fixes 3 words
:B0X*:devestat::f("devastat") ; Web Freq 5.08 | Fixes 10 words
:B0X*:devined::f("defined") ; Web Freq 51.03 | Fixes 2 words
:B0X*:devista::f("devasta") ; Web Freq 5.08 | Fixes 10 words
:B0X*:diablic::f("diabolic") ; Web Freq 0.69 | Fixes 5 words
:B0X*:diagog::f("dialog") ; Web Freq 23.47 | Fixes 28 words
:B0X*:dicht::f("dichot") ; Web Freq 0.80 | Fixes 22 words, but misspells Mulloidichthys (a genus of Mullidae. goatfishes or red mullets)
:B0X*:dicon::f("discon") ; Web Freq 15.64 | Fixes 60 words
:B0X*:did attempted::f("did attempt") ; Fixes 1 word
:B0X*:didint::f("didn't") ; Fixes 1 word
:B0X*:didn't fair::f("didn't fare") ; Fixes 1 word
:B0X*:didnot::f("did not") ; Fixes 1 word
:B0X*:didnt::f("didn't") ; Fixes 1 word
:B0X*:dieties::f("deities") ; Web Freq 0.72 | Fixes 1 word
:B0X*:diety::f("deity") ; Web Freq 1.26 | Fixes 1 word
:B0X*:diffc::f("diffic") ; Web Freq 65.42 | Fixes 7 words
:B0X*:different tact::f("different tack") ; Fixes 1 word
:B0X*:diffuse the::f("defuse the") ; Fixes 1 word
:B0X*:dificu::f("difficu") ; Web Freq 65.22 | Fixes 5 words
:B0X*:diminuit::f("diminut") ; Web Freq 0.62 | Fixes 7 words
:B0X*:dimunit::f("diminut") ; Web Freq 0.62 | Fixes 7 words
:B0X*:diphtong::f("diphthong") ; Web Freq 0.08 | Fixes 17 words
:B0X*:diplomanc::f("diplomac") ; Web Freq 2.35 | Fixes 2 words
:B0X*:diptheria::f("diphtheria") ; Web Freq 0.43 | Fixes 3 words
:B0X*:dipthong::f("diphthong") ; Web Freq 0.08 | Fixes 17 words
:B0X*:direct affect::f("direct effect") ; Fixes 1 word
:B0X*:disastero::f("disastro") ; Web Freq 1.34 | Fixes 3 words
:B0X*:disati::f("dissati") ; Web Freq 2.42 | Fixes 11 words
:B0X*:disatro::f("disastro") ; Web Freq 1.34 | Fixes 3 words
:B0X*:discract::f("distract") ; Web Freq 5.07 | Fixes 18 words
:B0X*:discus a::f("discuss a") ; Fixes 1 word
:B0X*:discus the::f("discuss the") ; Fixes 1 word
:B0X*:discus this::f("discuss this") ; Fixes 1 word
:B0X*:disemin::f("dissemin") ; Web Freq 8.00 | Fixes 11 words
:B0X*:disente::f("dissente") ; Web Freq 0.42 | Fixes 3 words
:B0X*:dispair::f("despair") ; Web Freq 2.67 | Fixes 8 words
:B0X*:disparing::f("disparaging") ; Web Freq 0.21 | Fixes 2 words
:B0X*:dispele::f("dispelle") ; Web Freq 0.16 | Fixes 3 words
:B0X*:dispic::f("despic") ; Web Freq 0.36 | Fixes 6 words
:B0X*:dispite::f("despite") ; Web Freq 28.15 | Fixes 9 words
:B0X*:dissag::f("disag") ; Web Freq 13.26 | Fixes 18 words
:B0X*:dissap::f("disap") ; Web Freq 25.33 | Fixes 37 words
:B0X*:dissar::f("disar") ; Web Freq 2.91 | Fixes 25 words
:B0X*:dissob::f("disob") ; Web Freq 1.46 | Fixes 16 words
:B0X*:divinition::f("divination") ; Web Freq 0.77 | Fixes 2 words
:B0X*:docri::f("doctri") ; Web Freq 8.32 | Fixes 8 words
:B0X*:doe snot::f("does not") ; Fixes 1 word *could* be legitimate... but very unlikely!
:B0X*:doen't::f("doesn't") ; Fixes 1 word
:B0X*:doent::f("don't") ; Fixes 1 word
:B0X*:dolling out::f("doling out") ; Fixes 1 word
:B0X*:dominate player::f("dominant player") ; Fixes 1 word
:B0X*:dominate role::f("dominant role") ; Fixes 1 word
:B0X*:don't no::f("don't know") ; Fixes 1 word
:B0X*:dont::f("don't") ; Fixes 1 word
:B0X*:door jam::f("doorjamb") ; Fixes 2 words
:B0X*:dosen't::f("doesn't") ; Fixes 1 word
:B0X*:dosn't::f("doesn't") ; Fixes 1 word
:B0X*:double header::f("doubleheader") ; Web Freq 0.22 | Fixes 2 words
:B0X*:down it's::f("down its") ; Fixes 1 word
:B0X*:down side::f("downside") ; Web Freq 1.48 | Fixes 2 words
:B0X*:draughtm::f("draughtsm") ; Web Freq 0.10 | Fixes 4 words
:B0X*:drunkeness::f("drunkenness") ; Web Freq 0.29 | Fixes 2 words
:B0X*:due to it's::f("due to its") ; Fixes 1 word
:B0X*:dukeship::f("dukedom") ; Web Freq 0.04 | Fixes 2 words
:B0X*:dumbell::f("dumbbell") ; Web Freq 0.75 | Fixes 2 words
:B0X*:during it's::f("during its") ; Fixes 1 word
:B0X*:during they're::f("during their") ; Fixes 1 word
:B0X*:each phenomena::f("each phenomenon") ; Fixes 1 word
:B0X*:ealie::f("earlie") ; Web Freq 39.20 | Fixes 2 words
:B0X*:efort::f("effort") ; Web Freq 80.50 | Fixes 10 words
:B0X*:eiter::f("either") ; Web Freq 99.14 | Fixes 1 word
:B0X*:eiyh::f("with") ; Web Freq 3696.95 | Fixes 58 words
:B0X*:elphan::f("elephan") ; Web Freq 8.28 | Fixes 7 words
:B0X*:eluded to::f("alluded to") ; Fixes 1 word
:B0X*:emane::f("ename") ; Web Freq 3.35 | Fixes 16 words
:B0X*:embargos::f("embargoes") ; Web Freq 0.14 | Fixes 1 word
:B0X*:embezell::f("embezzle") ; Web Freq 0.39 | Fixes 7 words
:B0X*:emial::f("email") ; Web Freq 462.33 | Fixes 7 words
:B0X*:emina::f("emana") ; Web Freq 1.22 | Fixes 10 words
:B0X*:emite::f("emitte") ; Web Freq 2.27 | Fixes 3 words
:B0X*:emne::f("enme") ; Web Freq 0.09 | Fixes 7 words
:B0X*:emporer::f("emperor") ; Web Freq 6.26 | Fixes 4 words
:B0X*:enameld::f("enamelled") ; Web Freq 0.17 | Fixes 1 word
:B0X*:enchanc::f("enhanc") ; Web Freq 67.55 | Fixes 9 words
:B0X*:encyl::f("encycl") ; Web Freq 28.21 | Fixes 21 words
:B0X*:endevo::f("endeavo") ; Web Freq 6.88 | Fixes 8 words
:B0X*:endire::f("entire") ; Web Freq 73.45 | Fixes 7 words
:B0X*:endolithec::f("endolithic") ; Fixes 1 word
:B0X*:ened::f("need") ; Web Freq 538.21 | Fixes 53 words
:B0X*:enlargment::f("enlargement") ; Web Freq 8.97 | Fixes 2 words
:B0X*:enlish::f("English") ; Web Freq 345.77 | Fixes 12 words
:B0X*:enought::f("enough") ; Web Freq 83.59 | Fixes 2 words
:B0X*:enourmo::f("enormo") ; Web Freq 7.89 | Fixes 4 words
:B0X*:enscons::f("ensconc") ; Web Freq 0.12 | Fixes 4 words
:B0X*:enteratin::f("entertain") ; Web Freq 125.72 | Fixes 10 words
:B0X*:entrepen::f("entrepren") ; Web Freq 17.75 | Fixes 8 words
:B0X*:envalop::f("envelop") ; Web Freq 12.02 | Fixes 10 words
:B0X*:enviorm::f("environm") ; Web Freq 202.12 | Fixes 8 words
:B0X*:enviorn::f("environ") ; Web Freq 206.56 | Fixes 12 words
:B0X*:envirom::f("environm") ; Web Freq 202.12 | Fixes 8 words
:B0X*:envrio::f("enviro") ; Web Freq 207.17 | Fixes 14 words
:B0X*:epidso::f("episo") ; Web Freq 30.26 | Fixes 10 words
:B0X*:epsiod::f("episod") ; Web Freq 30.25 | Fixes 6 words
:B0X*:equitor::f("equator") ; Web Freq 5.48 | Fixes 6 words
:B0X*:eral::f("real") ; Web Freq 597.49 | Fixes 80 words
:B0X*:erati::f("errati") ; Web Freq 0.83 | Fixes 7 words
:B0X*:erest::f("arrest") ; Web Freq 20.17 | Fixes 17 words
:B0X*:erruc::f("eruc") ; Web Freq 0.02 | Fixes 14 words
:B0X*:errup::f("erup") ; Web Freq 3.24 | Fixes 11 words
:B0X*:escta::f("ecsta") ; Web Freq 2.50 | Fixes 13 words
:B0X*:esle::f("else") ; Web Freq 114.53 | Fixes 4 words
:B0X*:europian::f("European") ; Web Freq 82.23 | Fixes 15 words
:B0X*:eurpean::f("European") ; Web Freq 82.23 | Fixes 15 words
:B0X*:eurpoean::f("European") ; Web Freq 82.23 | Fixes 15 words
:B0X*:evant::f("event") ; Web Freq 347.59 | Fixes 28 words
:B0X*:evental::f("eventual") ; Web Freq 19.85 | Fixes 4 words
:B0X*:eventhough::f("even though") ; Fixes 1 word
:B0X*:eventia::f("eventua") ; Web Freq 19.90 | Fixes 10 words
:B0X*:everthing::f("everything") ; Web Freq 91.39 | Fixes 1 word
:B0X*:everytime::f("every time") ; Fixes 1 word
:B0X*:everyting::f("everything") ; Web Freq 91.39 | Fixes 1 word
:B0X*:evesdrop::f("eavesdrop") ; Web Freq 0.90 | Fixes 6 words
:B0X*:excede::f("exceed") ; Web Freq 28.34 | Fixes 12 words
:B0X*:exceel::f("excell") ; Web Freq 77.04 | Fixes 11 words
:B0X*:excele::f("excelle") ; Web Freq 76.90 | Fixes 10 words
:B0X*:excellan::f("excellen") ; Web Freq 76.49 | Fixes 9 words
:B0X*:excells::f("excels") ; Web Freq 1.54 | Fixes 3 words
:B0X*:execti::f("executi") ; Web Freq 108.17 | Fixes 10 words
:B0X*:exeellen::f("excellen") ; Web Freq 76.49 | Fixes 9 words
:B0X*:exele::f("excelle") ; Web Freq 76.90 | Fixes 10 words
:B0X*:exerbat::f("exacerbat") ; Web Freq 1.64 | Fixes 7 words
:B0X*:exerpt::f("excerpt") ; Web Freq 15.65 | Fixes 10 words
:B0X*:exertern::f("extern") ; Web Freq 56.88 | Fixes 28 words
:B0X*:exhalt::f("exalt") ; Web Freq 1.44 | Fixes 12 words
:B0X*:exib::f("exhib") ; Web Freq 58.33 | Fixes 22 words
:B0X*:exilera::f("exhilara") ; Web Freq 0.82 | Fixes 10 words
:B0X*:exla::f("excla") ; Web Freq 2.80 | Fixes 14 words
:B0X*:exlu::f("exclu") ; Web Freq 77.01 | Fixes 27 words
:B0X*:expatriot::f("expatriate") ; Web Freq 1.25 | Fixes 3 words
:B0X*:explainat::f("explanat") ; Web Freq 22.54 | Fixes 7 words
:B0X*:exploter::f("explorer") ; Web Freq 47.88 | Fixes 3 words
:B0X*:exteme::f("extreme") ; Web Freq 55.69 | Fixes 7 words
:B0X*:extermis::f("extremis") ; Web Freq 2.49 | Fixes 4 words
:B0X*:extract punishment::f("exact punishment") ; Fixes 1 word
:B0X*:extract revenge::f("exact revenge") ; Fixes 1 word
:B0X*:extradict::f("extradit") ; Web Freq 1.06 | Fixes 7 words
:B0X*:extremeop::f("extremop") ; Web Freq 0.03 | Fixes 2 words
:B0X*:extt::f("exit") ; Web Freq 27.93 | Fixes 5 words
:B0X*:eyar::f("year") ; Web Freq 799.38 | Fixes 20 words
:B0X*:eye brow::f("eyebrow") ; Web Freq 1.96 | Fixes 2 words
:B0X*:eye lash::f("eyelash") ; Web Freq 0.67 | Fixes 2 words
:B0X*:eye lid::f("eyelid") ; Web Freq 1.12 | Fixes 2 words
:B0X*:eye sight::f("eyesight") ; Web Freq 0.55 | Fixes 2 words
:B0X*:eye sore::f("eyesore") ; Web Freq 0.17 | Fixes 2 words
:B0X*:faciliat::f("facilitat") ; Web Freq 23.49 | Fixes 10 words
:B0X*:facinat::f("fascinat") ; Web Freq 8.46 | Fixes 10 words
:B0X*:faired as well::f("fared as well") ; Fixes 1 word
:B0X*:faired badly::f("fared badly") ; Fixes 1 word
:B0X*:faired better::f("fared better") ; Fixes 1 word
:B0X*:faired far::f("fared far") ; Fixes 1 word
:B0X*:faired less::f("fared less") ; Fixes 1 word
:B0X*:faired little::f("fared little") ; Fixes 1 word
:B0X*:faired much::f("fared much") ; Fixes 1 word
:B0X*:faired no better::f("fared no better") ; Fixes 1 word
:B0X*:faired poorly::f("fared poorly") ; Fixes 1 word
:B0X*:faired quite::f("fared quite") ; Fixes 1 word
:B0X*:faired rather::f("fared rather") ; Fixes 1 word
:B0X*:faired slightly::f("fared slightly") ; Fixes 1 word
:B0X*:faired somewhat::f("fared somewhat") ; Fixes 1 word
:B0X*:faired worse::f("fared worse") ; Fixes 1 word
:B0X*:fanatism::f("fanaticism") ; Web Freq 0.27 | Fixes 2 words
:B0X*:farenheit::f("Fahrenheit") ; Web Freq 1.70 | Fixes 2 words
:B0X*:farther then::f("farther than") ; Fixes 1 word
:B0X*:faster then::f("faster than") ; Fixes 1 word
:B0X*:febuar::f("Februar") ; Web Freq 127.70 | Fixes 2 words
:B0X*:femail::f("female") ; Web Freq 74.02 | Fixes 5 words
:B0X*:feromon::f("pheromon") ; Web Freq 1.34 | Fixes 3 words
:B0X*:ffed::f("feed") ; Web Freq 264.06 | Fixes 25 words
:B0X*:fianl::f("final") ; Web Freq 163.26 | Fixes 26 words
:B0X*:ficed::f("fixed") ; Web Freq 49.31 | Fixes 4 words
:B0X*:figure head::f("figurehead") ; Web Freq 0.15 | Fixes 2 words
:B0X*:filled a lawsuit::f("filed a lawsuit") ; Fixes 1 word
:B0X*:flag ship::f("flagship") ; Web Freq 1.92 | Fixes 2 words
:B0X*:flair up::f("flare up") ; Fixes 1 word
:B0X*:fleed::f("freed") ; Web Freq 44.87 | Fixes 7 words
:B0X*:floresc::f("fluoresc") ; Web Freq 6.25 | Fixes 14 words, but misspells florescence (the time and process of budding and unfolding of blossoms)
:B0X*:flouresc::f("fluoresc") ; Web Freq 6.25 | Fixes 14 words
:B0X*:folder cash::f("folder cache") ; Fixes 1 word
:B0X*:follow suite::f("follow suit") ; Fixes 1 word
:B0X*:following it's::f("following its") ; Fixes 1 word
:B0X*:for awhile::f("for a while") ; Fixes 1 word
:B0X*:for quite awhile::f("for quite a while") ; Fixes 1 word
:B0X*:for way it's::f("for what it's") ; Fixes 1 word
:B0X*:fore ground::f("foreground") ; Web Freq 1.61 | Fixes 5 words
:B0X*:forego her::f("forgo her") ; Fixes 1 word
:B0X*:forego his::f("forgo his") ; Fixes 1 word
:B0X*:forego their::f("forgo their") ; Fixes 1 word
:B0X*:foreward::f("foreword") ; Web Freq 1.76 | Fixes 2 words
:B0X*:forgone conclusion::f("foregone conclusion") ; Fixes 1 word
:B0X*:forh::f("foreh") ; Web Freq 2.14 | Fixes 11 words
:B0X*:forth grade::f("fourth grade") ; Fixes 1 word
:B0X*:forunner::f("forerunner") ; Web Freq 0.65 | Fixes 2 words
:B0X*:foundar::f("foundr") ; Web Freq 2.89 | Fixes 5 words
:B0X*:fouth::f("fourth") ; Web Freq 26.28 | Fixes 3 words
:B0X*:fouum::f("forum") ; Web Freq 412.89 | Fixes 2 words
:B0X*:fransisca::f("Francisca") ; Web Freq 0.97 | Fixes 3 words
:B0X*:frieay::f("friday") ; Web Freq 87.37 | Fixes 2 words
:B0X*:fromt he::f("from the") ; Fixes 1 word
:B0X*:froniter::f("frontier") ; Web Freq 8.20 | Fixes 6 words
:B0X*:full compliment of::f("full complement of") ; Fixes 1 word
:B0X*:furner::f("funer") ; Web Freq 14.07 | Fixes 6 words
:B0X*:furure::f("future") ; Web Freq 129.32 | Fixes 7 words
:B0X*:fururi::f("futuri") ; Web Freq 2.19 | Fixes 9 words
:B0X*:futhe::f("furthe") ; Web Freq 122.83 | Fixes 12 words
:B0X*:galatic::f("galactic") ; Web Freq 3.50 | Fixes 5 words
:B0X*:gameboy::f("Game Boy") ; Fixes 1 word, but misspells gameboy (Common misspelling of Game Boy)
:B0X*:ganst::f("gangst") ; Web Freq 2.76 | Fixes 9 words
:B0X*:gaol::f("goal") ; Web Freq 83.41 | Fixes 28 words, but misspells gaol (British spelling of "jail")
:B0X*:gauren::f("guaran") ; Web Freq 78.23 | Fixes 18 words
:B0X*:gave advise::f("gave advice") ; Fixes 1 word
:B0X*:geneer::f("gender") ; Web Freq 30.15 | Fixes 14 words
:B0X*:geneol::f("geneal") ; Web Freq 12.64 | Fixes 7 words
:B0X*:genialia::f("genitalia") ; Web Freq 0.36 | Fixes 2 words
:B0X*:gentlemens::f("gentlemen's") ; Fixes 1 word
:B0X*:gerat::f("great") ; Web Freq 396.80 | Fixes 18 words
:B0X*:get setup::f("get set up") ; Fixes 1 word
:B0X*:geting::f("getting") ; Web Freq 93.51 | Fixes 2 words
:B0X*:gets it's::f("gets its") ; Fixes 1 word
:B0X*:ghandi::f("Gandhi") ; Web Freq 2.57 | Fixes 3 words
:B0X*:gien::f("gian") ; Web Freq 24.57 | Fixes 12 words
:B0X*:girat::f("gyrat") ; Web Freq 0.39 | Fixes 10 words
:B0X*:give advise::f("give advice") ; Fixes 1 word
:B0X*:gives advise::f("gives advice") ; Fixes 1 word
:B0X*:glight::f("flight") ; Web Freq 71.38 | Fixes 14 words
:B0X*:going threw::f("going through") ; Fixes 1 word
:B0X*:goodle::f("google") ; Web Freq 169.79 | Fixes 6 words
:B0X*:got ran::f("got run") ; Fixes 1 word
:B0X*:got setup::f("got set up") ; Fixes 1 word
:B0X*:got shutdown::f("got shut down") ; Fixes 1 word
:B0X*:got shutout::f("got shut out") ; Fixes 1 word
:B0X*:gouvener::f("governor") ; Web Freq 25.21 | Fixes 6 words
:B0X*:governer::f("governor") ; Web Freq 25.21 | Fixes 6 words
:B0X*:grafitti::f("graffiti") ; Web Freq 3.06 | Fixes 7 words
:B0X*:grammer::f("grammar") ; Web Freq 8.75 | Fixes 4 words
:B0X*:greater then::f("greater than") ; Fixes 1 word
:B0X*:greif::f("grief") ; Web Freq 4.62 | Fixes 5 words
:B0X*:gridle::f("griddle") ; Web Freq 0.62 | Fixes 5 words
:B0X*:ground work::f("groundwork") ; Web Freq 0.95 | Fixes 2 words
:B0X*:guadulup::f("Guadalup") ; Fixes 1 word 
:B0X*:guag::f("gaug") ; Web Freq 13.14 | Fixes 10 words
:B0X*:guatam::f("Guatem") ; Web Freq 9.02 | Fixes 3 words
:B0X*:guerrila::f("guerrilla") ; Web Freq 1.89 | Fixes 2 words
:B0X*:guest stared::f("guest-starred") ; Fixes 1 word
:B0X*:guidl::f("guidel") ; Web Freq 49.70 | Fixes 3 words
:B0X*:guiliani::f("Giuliani") ; Fixes 1 word
:B0X*:guilio::f("Giulio") ; Fixes 1 word
:B0X*:guiness::f("Guinness") ; Web Freq 1.84 | Fixes 1 word
:B0X*:guiseppe::f("Giuseppe") ; Fixes 1 word
:B0X*:gunanine::f("guanine") ; Web Freq 0.37 | Fixes 2 words It's in bat poop. LOL
:B0X*:gutteral::f("guttural") ; Web Freq 0.10 | Fixes 6 words
:B0X*:habaeus::f("habeas") ; Web Freq 0.86 | Fixes 1 word
:B0X*:habeus::f("habeas") ; Web Freq 0.86 | Fixes 1 word
:B0X*:habsbourg::f("Habsburg") ; Web Freq 0.19 | Fixes 2 words
:B0X*:had arose::f("had arisen") ; Fixes 1 word
:B0X*:had became::f("had become") ; Fixes 1 word
:B0X*:had began::f("had begun") ; Fixes 1 word
:B0X*:had being::f("had been") ; Fixes 1 word
:B0X*:had brung::f("had brought") ; Fixes 1 word
:B0X*:had came::f("had come") ; Fixes 1 word
:B0X*:had comeback::f("had come back") ; Fixes 1 word
:B0X*:had cut-off::f("had cut off") ; Fixes 1 word
:B0X*:had drank::f("had drunk") ; Fixes 1 word
:B0X*:had drew::f("had drawn") ; Fixes 1 word
:B0X*:had drove::f("had driven") ; Fixes 1 word
:B0X*:had flew::f("had flown") ; Fixes 1 word
:B0X*:had gave::f("had given") ; Fixes 1 word
:B0X*:had grew::f("had grown") ; Fixes 1 word
:B0X*:had it's::f("had its") ; Fixes 1 word
:B0X*:had knew::f("had known") ; Fixes 1 word
:B0X*:had lead for::f("had led for") ; Fixes 1 word
:B0X*:had lead the::f("had led the") ; Fixes 1 word
:B0X*:had lead to::f("had led to") ; Fixes 1 word
:B0X*:had mislead::f("had misled") ; Fixes 1 word
:B0X*:had overcame::f("had overcome") ; Fixes 1 word
:B0X*:had overran::f("had overrun") ; Fixes 1 word
:B0X*:had overtook::f("had overtaken") ; Fixes 1 word
:B0X*:had runaway::f("had run away") ; Fixes 1 word
:B0X*:had sang::f("had sung") ; Fixes 1 word
:B0X*:had send::f("had sent") ; Fixes 1 word
:B0X*:had set-up::f("had set up") ; Fixes 1 word
:B0X*:had setup::f("had set up") ; Fixes 1 word
:B0X*:had shook::f("had shaken") ; Fixes 1 word
:B0X*:had shut-down::f("had shut down") ; Fixes 1 word
:B0X*:had shutdown::f("had shut down") ; Fixes 1 word
:B0X*:had shutout::f("had shut out") ; Fixes 1 word
:B0X*:had sowed::f("had sown") ; Fixes 1 word
:B0X*:had spend::f("had spent") ; Fixes 1 word
:B0X*:had sprang::f("had sprung") ; Fixes 1 word
:B0X*:had threw::f("had thrown") ; Fixes 1 word
:B0X*:had thunk::f("had thought") ; Fixes 1 word
:B0X*:had to much::f("had too much") ; Fixes 1 word
:B0X*:had to used::f("had to use") ; Fixes 1 word
:B0X*:had took::f("had taken") ; Fixes 1 word
:B0X*:had tore::f("had torn") ; Fixes 1 word
:B0X*:had undertook::f("had undertaken") ; Fixes 1 word
:B0X*:had underwent::f("had undergone") ; Fixes 1 word
:B0X*:had went::f("had gone") ; Fixes 1 word
:B0X*:had wore::f("had worn") ; Fixes 1 word
:B0X*:had wrote::f("had written") ; Fixes 1 word
:B0X*:hadbeen::f("had been") ; Fixes 1 word
:B0X*:halari::f("hilari") ; Web Freq 3.86 | Fixes 6 words
:B0X*:half and hour::f("half an hour") ; Fixes 1 word
:B0X*:hallowean::f("Halloween") ; Web Freq 11.12 | Fixes 2 words
:B0X*:halp::f("help") ; Web Freq 745.39 | Fixes 24 words
:B0X*:hand the reigns::f("hand the reins") ; Fixes 1 word
:B0X*:hapen::f("happen") ; Web Freq 86.29 | Fixes 9 words
:B0X*:harase::f("harasse") ; Web Freq 0.76 | Fixes 5 words
:B0X*:harasm::f("harassm") ; Web Freq 5.20 | Fixes 2 words
:B0X*:harassem::f("harassm") ; Web Freq 5.20 | Fixes 2 words
:B0X*:has brung::f("has brought") ; Fixes 1 word
:B0X*:has came::f("has come") ; Fixes 1 word
:B0X*:has cut-off::f("has cut off") ; Fixes 1 word
:B0X*:has did::f("has done") ; Fixes 1 word
:B0X*:has drank::f("has drunk") ; Fixes 1 word
:B0X*:has drew::f("has drawn") ; Fixes 1 word
:B0X*:has gave::f("has given") ; Fixes 1 word
:B0X*:has having::f("as having") ; Fixes 1 word
:B0X*:has it's::f("has its") ; Fixes 1 word
:B0X*:has lead the::f("has led the") ; Fixes 1 word
:B0X*:has lead to::f("has led to") ; Fixes 1 word
:B0X*:has mislead::f("has misled") ; Fixes 1 word
:B0X*:has overcame::f("has overcome") ; Fixes 1 word
:B0X*:has rang::f("has rung") ; Fixes 1 word
:B0X*:has sang::f("has sung") ; Fixes 1 word
:B0X*:has set-up::f("has set up") ; Fixes 1 word
:B0X*:has setup::f("has set up") ; Fixes 1 word
:B0X*:has shook::f("has shaken") ; Fixes 1 word
:B0X*:has sprang::f("has sprung") ; Fixes 1 word
:B0X*:has threw::f("has thrown") ; Fixes 1 word
:B0X*:has throve::f("has thrived") ; Fixes 1 word
:B0X*:has thunk::f("has thought") ; Fixes 1 word
:B0X*:has took::f("has taken") ; Fixes 1 word
:B0X*:has undertook::f("has undertaken") ; Fixes 1 word
:B0X*:has underwent::f("has undergone") ; Fixes 1 word
:B0X*:has went::f("has gone") ; Fixes 1 word
:B0X*:has wrote::f("has written") ; Fixes 1 word
:B0X*:hasbeen::f("has been") ; Fixes 1 word
:B0X*:hasnt::f("hasn't") ; Fixes 1 word
:B0X*:have drank::f("have drunk") ; Fixes 1 word
:B0X*:have it's::f("have its") ; Fixes 1 word
:B0X*:have lead to::f("have led to") ; Fixes 1 word
:B0X*:have mislead::f("have misled") ; Fixes 1 word
:B0X*:have sang::f("have sung") ; Fixes 1 word
:B0X*:have setup::f("have set up") ; Fixes 1 word
:B0X*:have sprang::f("have sprung") ; Fixes 1 word
:B0X*:have took::f("have taken") ; Fixes 1 word
:B0X*:have underwent::f("have undergone") ; Fixes 1 word
:B0X*:have went::f("have gone") ; Fixes 1 word
:B0X*:havebeen::f("have been") ; Fixes 1 word
:B0X*:haveto::f("have to") ; Fixes 1 word
:B0X*:havie::f("heavie") ; Web Freq 2.82 | Fixes 3 words
:B0X*:having became::f("having become") ; Fixes 1 word
:B0X*:having began::f("having begun") ; Fixes 1 word
:B0X*:having being::f("having been") ; Fixes 1 word
:B0X*:having it's::f("having its") ; Fixes 1 word
:B0X*:having sang::f("having sung") ; Fixes 1 word
:B0X*:having setup::f("having set up") ; Fixes 1 word
:B0X*:having took::f("having taken") ; Fixes 1 word
:B0X*:having underwent::f("having undergone") ; Fixes 1 word
:B0X*:having went::f("having gone") ; Fixes 1 word
:B0X*:hay day::f("heyday") ; Web Freq 0.39 | Fixes 2 words
:B0X*:hda::f("had") ; Web Freq 487.44 | Fixes 43 words
:B0X*:he begun::f("he began") ; Fixes 1 word
:B0X*:he let's::f("he lets") ; Fixes 1 word
:B0X*:he seen::f("he saw") ; Fixes 1 word
:B0X*:he's drank::f("he drank") ; Fixes 1 word
:B0X*:head gear::f("headgear") ; Web Freq 0.54 | Fixes 2 words
:B0X*:head quarter::f("headquarter") ; Web Freq 13.68 | Fixes 4 words
:B0X*:head stone::f("headstone") ; Web Freq 0.58 | Fixes 2 words
:B0X*:head wear::f("headwear") ; Web Freq 0.83 | Fixes 1 word
:B0X*:headquarer::f("headquarter") ; Web Freq 13.68 | Fixes 4 words
:B0X*:heae::f("here") ; Web Freq 1315.49 | Fixes 62 words
:B0X*:healther::f("health") ; Web Freq 503.17 | Fixes 13 words
:B0X*:heared::f("heard") ; Web Freq 45.44 | Fixes 1 word
:B0X*:heathy::f("healthy") ; Web Freq 30.36 | Fixes 1 word, but misspells heathy (Related to a low evergreen shrub of the family Ericaceae)
:B0X*:heidelburg::f("Heidelberg") ; Web Freq 2.34 | Fixes 1 word
:B0X*:heigher::f("higher") ; Web Freq 82.59 | Fixes 2 words
:B0X*:held the reigns::f("held the reins") ; Fixes 1 word
:B0X*:helf::f("held") ; Web Freq 76.10 | Fixes 3 words
:B0X*:hellow::f("hello") ; Web Freq 33.06 | Fixes 5 words
:B0X*:helment::f("helmet") ; Web Freq 10.36 | Fixes 7 words
:B0X*:help and make::f("help to make") ; Fixes 1 word
:B0X*:hemmorhage::f("hemorrhage") ; Web Freq 1.06 | Fixes 3 words
:B0X*:herf=::f("href=") ; Fixes 1 word
:B0X*:heroei::f("heroi") ; Web Freq 6.81 | Fixes 25 words 
:B0X*:heros::f("heroes") ; Web Freq 10.67 | Fixes 1 word
:B0X*:hersuit::f("hirsute") ; Web Freq 0.48 | Fixes 3 words
:B0X*:hesaid::f("he said") ; Fixes 1 word
:B0X*:hesista::f("hesita") ; Web Freq 6.32 | Fixes 19 words
:B0X*:heterogeno::f("heterogeneo") ; Web Freq 2.06 | Fixes 4 words
:B0X*:hewas::f("he was") ; Fixes 1 word
:B0X*:hge::f("he") ; Web Freq 6188.39 | Fixes 2196 words
:B0X*:higer::f("higher") ; Web Freq 82.59 | Fixes 2 words
:B0X*:higest::f("highest") ; Web Freq 46.23 | Fixes 1 word
:B0X*:higher then::f("higher than") ; Fixes 1 word
:B0X*:hinderan::f("hindran") ; Web Freq 0.52 | Fixes 2 words
:B0X*:hinderen::f("hindran") ; Web Freq 0.52 | Fixes 2 words
:B0X*:hindren::f("hindran") ; Web Freq 0.52 | Fixes 2 words
:B0X*:hipo::f("hippo") ; Web Freq 5.05 | Fixes 34 words
:B0X*:his resent::f("his recent") ; Fixes 1 word ; not good for 'her'
:B0X*:hismelf::f("himself") ; Web Freq 39.76 | Fixes 1 word
:B0X*:hit the breaks::f("hit the brakes") ; Fixes 1 word
:B0X*:hitsingles::f("hit singles") ; Fixes 1 word
:B0X*:hlep::f("help") ; Web Freq 745.39 | Fixes 24 words
:B0X*:hold onto::f("hold on to") ; Fixes 1 word
:B0X*:hold the reigns::f("hold the reins") ; Fixes 1 word
:B0X*:holding the reigns::f("holding the reins") ; Fixes 1 word
:B0X*:holds the reigns::f("holds the reins") ; Fixes 1 word
:B0X*:hollida::f("holida") ; Web Freq 125.64 | Fixes 8 words
:B0X*:homestate::f("home state") ; Fixes 1 word
:B0X*:honed in::f("homed in") ; Fixes 1 word
:B0X*:honory::f("honorary") ; Web Freq 2.66 | Fixes 1 word
:B0X*:honourarium::f("honorarium") ; Web Freq 0.19 | Fixes 2 words
:B0X*:honourific::f("honorific") ; Web Freq 0.08 | Fixes 4 words
:B0X*:hosit::f("hoist") ; Web Freq 1.82 | Fixes 6 words
:B0X*:hostring::f("hotstring") ; Fixes 1 word
:B0X*:hotring::f("hotstring") ; Fixes 1 word
:B0X*:hotsring::f("hotstring") ; Fixes 1 word
:B0X*:hotsting::f("hotstring") ; Fixes 1 word
:B0X*:hotter then::f("hotter than") ; Fixes 1 word
:B0X*:house hold::f("household") ; Web Freq 39.93 | Fixes 4 words
:B0X*:housr::f("hours") ; Web Freq 198.24 | Fixes 1 word
:B0X*:hte::f("the") ; Web Freq 27360.01 | Fixes 533 words
:B0X*:hti::f("thi") ; Web Freq 3934.33 | Fixes 260 words
:B0X*:htp`:::f("http:") ; Fixes 1 word 
:B0X*:htps`:::f("https:") ; Fixes 1 word 
:B0X*:huminoid::f("humanoid") ; Web Freq 0.57 | Fixes 2 words
:B0X*:humoural::f("humoral") ; Web Freq 0.23 | Fixes 2 words
:B0X*:hwi::f("whi") ; Web Freq 1552.76 | Fixes 408 words
:B0X*:hwo::f("who") ; Web Freq 1488.25 | Fixes 134 words
:B0X*:hydropil::f("hydrophil") ; Web Freq 0.32 | Fixes 3 words
:B0X*:hydropob::f("hydrophob") ; Web Freq 0.80 | Fixes 8 words
:B0X*:hyjack::f("hijack") ; Web Freq 3.09 | Fixes 7 words
:B0X*:hypocrac::f("hypocris") ; Web Freq 1.44 | Fixes 2 words
:B0X*:hypocras::f("hypocris") ; Web Freq 1.44 | Fixes 2 words
:B0X*:hypocric::f("hypocris") ; Web Freq 1.44 | Fixes 2 words
:B0X*:hypocrits::f("hypocrites") ; Web Freq 0.39 | Fixes 1 word
:B0X*:i"m::f("I'm") ; Fixes 1 word
:B0X*:i;d::f("I'd") ; Fixes 1 word
:B0X*:icon cash::f("icon cache") ; Fixes 1 word
:B0X*:iconcla::f("iconocla") ; Web Freq 0.31 | Fixes 6 words
:B0X*:idae::f("idea") ; Web Freq 167.65 | Fixes 43 words
:B0X*:idealogi::f("ideologi") ; Web Freq 2.98 | Fixes 11 words
:B0X*:idealogy::f("ideology") ; Web Freq 2.98 | Fixes 1 word
:B0X*:identife::f("identifie") ; Web Freq 49.75 | Fixes 4 words
:B0X*:ideosyncra::f("idiosyncra") ; Web Freq 0.67 | Fixes 4 words
:B0X*:idesa::f("ideas") ; Web Freq 67.31 | Fixes 1 word
:B0X*:idiosyncrac::f("idiosyncras") ; Web Freq 0.18 | Fixes 2 words
:B0X*:ifb y::f("if by") ; Fixes 1 word
:B0X*:ifi t::f("if it") ; Fixes 1 word
:B0X*:ift he::f("if the") ; Fixes 1 word
:B0X*:ignoren::f("ignoran") ; Web Freq 6.56 | Fixes 7 words
:B0X*:iits the::f("it's the") ; Fixes 1 word
:B0X*:illegim::f("illegitim") ; Web Freq 0.74 | Fixes 6 words
:B0X*:illess::f("illness") ; Web Freq 15.50 | Fixes 2 words
:B0X*:illicited::f("elicited") ; Web Freq 0.62 | Fixes 1 word
:B0X*:ilness::f("illness") ; Web Freq 15.50 | Fixes 2 words
:B0X*:ilog::f("illog") ; Web Freq 0.89 | Fixes 8 words
:B0X*:ilu::f("illu") ; Web Freq 60.88 | Fixes 76 words
:B0X*:imaginery::f("imaginary") ; Web Freq 2.35 | Fixes 1 word
:B0X*:iman::f("immin") ; Web Freq 2.14 | Fixes 11 words
:B0X*:imigr::f("immigr") ; Web Freq 25.63 | Fixes 9 words
:B0X*:immida::f("immedia") ; Web Freq 62.76 | Fixes 6 words
:B0X*:immidi::f("immedi") ; Web Freq 62.76 | Fixes 8 words
:B0X*:imminent domain::f("eminent domain") ; Fixes 1 word
:B0X*:impeca::f("impecca") ; Web Freq 0.88 | Fixes 6 words
:B0X*:impeden::f("impedan") ; Web Freq 2.46 | Fixes 2 words
:B0X*:impressa::f("impresa") ; Web Freq 0.20 | Fixes 4 words
:B0X*:improvision::f("improvisation") ; Web Freq 1.38 | Fixes 4 words
:B0X*:in anyway::f("in any way") ; Fixes 1 word
:B0X*:in awhile::f("in a while") ; Fixes 1 word
:B0X*:in edition to::f("in addition to") ; Fixes 1 word
:B0X*:in lu of::f("in lieu of") ; Fixes 1 word
:B0X*:in masse::f("en masse") ; Fixes 1 word
:B0X*:in parenthesis::f("in parentheses") ; Fixes 1 word
:B0X*:in placed::f("in place") ; Fixes 1 word
:B0X*:in quite awhile::f("in quite a while") ; Fixes 1 word
:B0X*:in regards to::f("in regard to") ; Fixes 1 word
:B0X*:in stead of::f("instead of") ; Fixes 1 word
:B0X*:in tact::f("intact") ; Web Freq 3.93 | Fixes 4 words
:B0X*:in the long-term::f("in the long term") ; Fixes 1 word
:B0X*:in the short-term::f("in the short term") ; Fixes 1 word
:B0X*:in titled::f("entitled") ; Web Freq 18.14 | Fixes 2 words
:B0X*:in vein::f("in vain") ; Fixes 1 word
:B0X*:inagu::f("inaugu") ; Web Freq 4.34 | Fixes 11 words
:B0X*:inate::f("innate") ; Web Freq 1.14 | Fixes 4 words
:B0X*:inaugure::f("inaugurate") ; Web Freq 0.92 | Fixes 3 words
:B0X*:inbala::f("imbala") ; Web Freq 2.18 | Fixes 3 words
:B0X*:inbalm::f("imbalm") ; Fixes 6 words
:B0X*:inbetween::f("between") ; Web Freq 255.45 | Fixes 7 words
:B0X*:incase of::f("in case of") ; Fixes 1 word
:B0X*:increadi::f("incredi") ; Web Freq 16.25 | Fixes 6 words
:B0X*:increadu::f("incredu") ; Web Freq 0.36 | Fixes 5 words
:B0X*:increated::f("increased") ; Web Freq 49.55 | Fixes 2 words
:B0X*:incuding::f("including") ; Web Freq 214.20 | Fixes 1 word
:B0X*:indentic::f("identic") ; Web Freq 9.67 | Fixes 5 words
:B0X*:indluded::f("included") ; Web Freq 92.00 | Fixes 2 words
:B0X*:inevitib::f("inevitab") ; Web Freq 6.69 | Fixes 7 words
:B0X*:inevititab::f("inevitab") ; Web Freq 6.69 | Fixes 7 words
:B0X*:infact::f("in fact") ; Fixes 1 word
:B0X*:infitation::f("invitation") ; Web Freq 16.25 | Fixes 4 words
:B0X*:ingreedian::f("ingredien") ; Web Freq 18.25 | Fixes 2 words
:B0X*:inoce::f("innoce") ; Web Freq 11.64 | Fixes 10 words
:B0X*:inofficia::f("unofficia") ; Web Freq 5.15 | Fixes 3 words
:B0X*:inpen::f("impen") ; Web Freq 1.66 | Fixes 22 words
:B0X*:inperson::f("in-person") ; Fixes 1 word
:B0X*:inspite::f("in spite") ; Fixes 1 word
:B0X*:int he::f("in the") ; Fixes 1 word
:B0X*:interelat::f("interrelat") ; Web Freq 1.42 | Fixes 11 words
:B0X*:interrim::f("interim") ; Web Freq 9.46 | Fixes 2 words
:B0X*:interrugum::f("interregnum") ; Web Freq 0.06 | Fixes 2 words
:B0X*:interum::f("interim") ; Web Freq 9.46 | Fixes 2 words
:B0X*:intial::f("initial") ; Web Freq 62.02 | Fixes 28 words
:B0X*:into affect::f("into effect") ; Fixes 1 word
:B0X*:into it's::f("into its") ; Fixes 1 word
:B0X*:intrust::f("entrust") ; Web Freq 1.73 | Fixes 6 words, but misspells intrust (Uncommon variant of entrust)
:B0X*:inumer::f("innumer") ; Web Freq 0.66 | Fixes 9 words
:B0X*:inwhich::f("in which") ; Fixes 1 word
:B0X*:iresis::f("irresis") ; Web Freq 1.39 | Fixes 6 words
:B0X*:irregard::f("regard") ; Web Freq 103.34 | Fixes 16 words, but misspells irregardless (Slang)
:B0X*:is front of::f("in front of") ; Fixes 1 word
:B0X*:is it's::f("is its") ; Fixes 1 word
:B0X*:is loathe to::f("is loath to") ; Fixes 1 word
:B0X*:is ran by::f("is run by") ; Fixes 1 word
:B0X*:is renown for::f("is renowned for") ; Fixes 1 word
:B0X*:is schedule to::f("is scheduled to") ; Fixes 1 word
:B0X*:is set-up::f("is set up") ; Fixes 1 word
:B0X*:is setup::f("is set up") ; Fixes 1 word
:B0X*:is were::f("is where") ; Fixes 1 word
:B0X*:isnt::f("isn't") ; Fixes 1 word
:B0X*:it begun::f("it began") ; Fixes 1 word
:B0X*:it lead to::f("it led to") ; Fixes 1 word
:B0X*:it set-up::f("it set up") ; Fixes 1 word
:B0X*:it setup::f("it set up") ; Fixes 1 word
:B0X*:it snot::f("it's not") ; Fixes 1 word
:B0X*:it spend::f("it spent") ; Fixes 1 word
:B0X*:it was her who::f("it was she who") ; Fixes 1 word
:B0X*:it was him who::f("it was he who") ; Fixes 1 word
:B0X*:it weighted::f("it weighed") ; Fixes 1 word
:B0X*:it weights::f("it weighs") ; Fixes 1 word
:B0X*:it' snot::f("it's not") ; Fixes 1 word
:B0X*:it's end::f("its end") ; Fixes 1 word
:B0X*:it's entire::f("its entire") ; Fixes 1 word
:B0X*:it's goal::f("its goal") ; Fixes 1 word
:B0X*:it's name::f("its name") ; Fixes 1 word
:B0X*:it's own::f("its own") ; Fixes 1 word
:B0X*:it's performance::f("its performance") ; Fixes 1 word
:B0X*:it's successor::f("its successor") ; Fixes 1 word
:B0X*:it's tail::f("its tail") ; Fixes 1 word
:B0X*:it's theme::f("its theme") ; Fixes 1 word
:B0X*:it's timeslot::f("its timeslot") ; Fixes 1 word
:B0X*:it's toll::f("its toll") ; Fixes 1 word
:B0X*:it's website::f("its website") ; Fixes 1 word
:B0X*:itis::f("it is") ; Fixes 1 word
:B0X*:itr::f("it") ; Web Freq 6999.11 | Fixes 128 words, but misspells itraconazole (Antifungal drug)
:B0X*:its not::f("it's not") ; Fixes 1 word
:B0X*:its the::f("it's the") ; Fixes 1 word
:B0X*:itwas::f("it was") ; Fixes 1 word
:B0X*:iunior::f("junior") ; Web Freq 60.62 | Fixes 8 words
:B0X*:jask::f("jack") ; Web Freq 184.06 | Fixes 90 words
:B0X*:jeapard::f("jeopard") ; Web Freq 2.83 | Fixes 17 words
:B0X*:jewelery::f("jewelry") ; Web Freq 72.58 | Fixes 1 word
:B0X*:jive with::f("jibe with") ; Fixes 1 word
:B0X*:johanine::f("Johannine") ; Fixes 1 word
:B0X*:jospeh::f("Joseph") ; Web Freq 61.15 | Fixes 4 words
:B0X*:juadaism::f("Judaism") ; Web Freq 3.00 | Fixes 1 word
:B0X*:juadism::f("Judaism") ; Web Freq 3.00 | Fixes 1 word
:B0X*:key note::f("keynote") ; Web Freq 4.35 | Fixes 5 words
:B0X*:klenex::f("kleenex") ; Web Freq 0.51 | Fixes 4 words
:B0X*:knifes::f("knives") ; Web Freq 7.74 | Fixes 1 word
:B0X*:lable::f("label") ; Web Freq 73.97 | Fixes 17 words
:B0X*:labrator::f("laborator") ; Web Freq 41.04 | Fixes 2 words
:B0X*:lack there of::f("lack thereof") ; Fixes 1 word
:B0X*:laid ahead::f("lay ahead") ; Fixes 1 word
:B0X*:laid dormant::f("lay dormant") ; Fixes 1 word
:B0X*:laid empty::f("lay empty") ; Fixes 1 word
:B0X*:larger then::f("larger than") ; Fixes 1 word
:B0X*:largley::f("largely") ; Web Freq 11.59 | Fixes 1 word
:B0X*:largst::f("largest") ; Web Freq 45.31 | Fixes 1 word
:B0X*:lasoo::f("lasso") ; Web Freq 1.15 | Fixes 8 words
:B0X*:lastyear::f("last year") ; Fixes 1 word
:B0X*:laughing stock::f("laughingstock") ; Web Freq 0.03 | Fixes 2 words
:B0X*:law suite::f("lawsuit") ; Web Freq 9.51 | Fixes 2 words
:B0X*:lay low::f("lie low") ; Fixes 1 word
:B0X*:layed::f("laid") ; Web Freq 13.36 | Fixes 2 words
:B0X*:laying around::f("lying around") ; Fixes 1 word
:B0X*:laying awake::f("lying awake") ; Fixes 1 word
:B0X*:laying low::f("lying low") ; Fixes 1 word
:B0X*:lays atop::f("lies atop") ; Fixes 1 word
:B0X*:lays beside::f("lies beside") ; Fixes 1 word
:B0X*:lays in::f("lies in") ; Fixes 1 word
:B0X*:lays low::f("lies low") ; Fixes 1 word
:B0X*:lays near::f("lies near") ; Fixes 1 word
:B0X*:lays on::f("lies on") ; Fixes 1 word
:B0X*:lazer::f("laser") ; Web Freq 42.34 | Fixes 9 words
:B0X*:lead by::f("led by") ; Fixes 1 word
:B0X*:lead roll::f("lead role") ; Fixes 1 word
:B0X*:leading roll::f("leading role") ; Fixes 1 word
:B0X*:leage::f("league") ; Web Freq 45.50 | Fixes 7 words
:B0X*:learin::f("leavin") ; Web Freq 23.88 | Fixes 2 words
:B0X*:lefr::f("left") ; Web Freq 177.56 | Fixes 24 words
:B0X*:leran::f("learn") ; Web Freq 334.81 | Fixes 14 words
:B0X*:less dominate::f("less dominant") ; Fixes 1 word
:B0X*:less that::f("less than") ; Fixes 1 word
:B0X*:less then::f("less than") ; Fixes 1 word
:B0X*:lesser then::f("less than") ; Fixes 1 word
:B0X*:leuten::f("lieuten") ; Web Freq 4.19 | Fixes 4 words
:B0X*:libar::f("librar") ; Web Freq 198.76 | Fixes 6 words
:B0X*:lible::f("libel") ; Web Freq 1.47 | Fixes 24 words
:B0X*:librer::f("librar") ; Web Freq 198.76 | Fixes 6 words
:B0X*:liesur::f("leisur") ; Web Freq 24.12 | Fixes 7 words
:B0X*:liev::f("live") ; Web Freq 286.20 | Fixes 78 words, but misspells Lieve (Dutch adjective meaning dear or sweet)
:B0X*:life time::f("lifetime") ; Web Freq 14.83 | Fixes 2 words
:B0X*:liftime::f("lifetime") ; Web Freq 14.83 | Fixes 2 words
:B0X*:lighter then::f("lighter than") ; Fixes 1 word
:B0X*:lightyear::f("light year") ; Fixes 1 word
:B0X*:linconl::f("lincoln") ; Web Freq 24.00 | Fixes 5 words
:B0X*:line of site::f("line of sight") ; Fixes 1 word
:B0X*:line-of-site::f("line-of-sight") ; Fixes 1 word
:B0X*:lions share::f("lion's share") ; Fixes 1 word
:B0X*:litature::f("literature") ; Web Freq 47.30 | Fixes 2 words
:B0X*:lonk::f("link") ; Web Freq 627.66 | Fixes 25 words
:B0X*:loosing effort::f("losing effort") ; Fixes 1 word
:B0X*:loosing record::f("losing record") ; Fixes 1 word
:B0X*:loosing season::f("losing season") ; Fixes 1 word
:B0X*:loosing streak::f("losing streak") ; Fixes 1 word
:B0X*:loosing team::f("losing team") ; Fixes 1 word
:B0X*:loosing to::f("losing to") ; Fixes 1 word
:B0X*:lower that::f("lower than") ; Fixes 1 word ; Possible but not likely.
:B0X*:lower then::f("lower than") ; Fixes 1 word
:B0X*:lsat::f("last") ; Web Freq 431.64 | Fixes 17 words
:B0X*:lsit::f("list") ; Web Freq 1015.82 | Fixes 41 words
:B0X*:lveo::f("love") ; Web Freq 272.22 | Fixes 58 words
:B0X*:lvoe::f("love") ; Web Freq 272.22 | Fixes 58 words
:B0X*:lybia::f("Libya") ; Web Freq 6.44 | Fixes 3 words
:B0X*:machinar::f("machiner") ; Web Freq 13.06 | Fixes 2 words
:B0X*:maching::f("matching") ; Web Freq 34.80 | Fixes 1 word
:B0X*:mackeral::f("mackerel") ; Web Freq 0.58 | Fixes 2 words
:B0X*:made it's::f("made its") ; Fixes 1 word
:B0X*:magasin::f("magazin") ; Web Freq 135.32 | Fixes 5 words
:B0X*:maginc::f("magic") ; Web Freq 45.89 | Fixes 9 words
:B0X*:magizin::f("magazin") ; Web Freq 135.32 | Fixes 5 words
:B0X*:magnificien::f("magnificen") ; Web Freq 5.80 | Fixes 5 words
:B0X*:magor::f("major") ; Web Freq 282.57 | Fixes 20 words
:B0X*:maintance::f("maintenance") ; Web Freq 52.01 | Fixes 2 words
:B0X*:major roll::f("major role") ; Fixes 1 word
:B0X*:make due::f("make do") ; Fixes 1 word
:B0X*:make it's::f("make its") ; Fixes 1 word
:B0X*:malcom::f("Malcolm") ; Web Freq 4.61 | Fixes 2 words
:B0X*:manisf::f("manif") ; Web Freq 14.31 | Fixes 23 words
:B0X*:mannor::f("manor") ; Web Freq 7.35 | Fixes 5 words
:B0X*:marrtyr::f("martyr") ; Web Freq 2.51 | Fixes 27 words
:B0X*:massachussets::f("Massachusetts") ; Web Freq 32.27 | Fixes 1 word
:B0X*:massachussetts::f("Massachusetts") ; Web Freq 32.27 | Fixes 1 word
:B0X*:massmedia::f("mass media") ; Fixes 1 word
:B0X*:masterbat::f("masturbat") ; Web Freq 14.94 | Fixes 9 words
:B0X*:mataph::f("metaph") ; Web Freq 6.89 | Fixes 20 words
:B0X*:mean while::f("meanwhile") ; Web Freq 8.11 | Fixes 2 words Possible but unlikely
:B0X*:mechandi::f("merchandi") ; Web Freq 23.14 | Fixes 13 words
:B0X*:medievel::f("medieval") ; Web Freq 8.16 | Fixes 7 words
:B0X*:meditera::f("Mediterra") ; Web Freq 13.82 | Fixes 3 words
:B0X*:meerkrat::f("meerkat") ; Web Freq 0.15 | Fixes 2 words
:B0X*:megapicel::f("megapixel") ; Web Freq 7.16 | Fixes 2 words
:B0X*:meliisa::f("melissa") ; Web Freq 10.42 | Fixes 1 word
:B0X*:membranaph::f("membranoph") ; Fixes 2 words
:B0X*:menally::f("mentally") ; Web Freq 3.84 | Fixes 1 word
:B0X*:mercent::f("mercant") ; Web Freq 0.95 | Fixes 7 words
:B0X*:mesag::f("messag") ; Web Freq 494.47 | Fixes 5 words
:B0X*:messenging::f("messaging") ; Web Freq 11.62 | Fixes 2 words
:B0X*:michagan::f("Michigan") ; Web Freq 46.48 | Fixes 3 words
:B0X*:milib::f("millib") ; Web Freq 0.12 | Fixes 2 words
:B0X*:milig::f("millig") ; Web Freq 1.57 | Fixes 9 words
:B0X*:milil::f("millil") ; Web Freq 0.28 | Fixes 9 words
:B0X*:milim::f("millim") ; Web Freq 1.66 | Fixes 13 words
:B0X*:milio::f("millio") ; Web Freq 143.57 | Fixes 13 words
:B0X*:milip::f("millip") ; Web Freq 0.12 | Fixes 4 words
:B0X*:miliv::f("milliv") ; Web Freq 0.08 | Fixes 4 words
:B0X*:miliw::f("milliw") ; Web Freq 0.05 | Fixes 2 words
:B0X*:milleped::f("milliped") ; Web Freq 0.12 | Fixes 4 words
:B0X*:miniscul::f("minuscul") ; Web Freq 0.18 | Fixes 3 words
:B0X*:ministery::f("ministry") ; Web Freq 30.28 | Fixes 1 word
:B0X*:minor roll::f("minor role") ; Fixes 1 word
:B0X*:minstri::f("ministri") ; Web Freq 6.58 | Fixes 1 word
:B0X*:minstry::f("ministry") ; Web Freq 30.28 | Fixes 1 word
:B0X*:minum::f("minim") ; Web Freq 81.26 | Fixes 38 words
:B0X*:minuri::f("minori") ; Web Freq 17.70 | Fixes 3 words
:B0X*:mirrorr::f("mirror") ; Web Freq 33.97 | Fixes 6 words
:B0X*:mischevious::f("mischievous") ; Web Freq 0.49 | Fixes 4 words
:B0X*:mischievious::f("mischievous") ; Web Freq 0.49 | Fixes 4 words
:B0X*:misdamean::f("misdemean") ; Web Freq 1.82 | Fixes 10 words
:B0X*:misour::f("Missour") ; Web Freq 30.58 | Fixes 5 words
:B0X*:mispel::f("misspel") ; Web Freq 1.32 | Fixes 6 words
:B0X*:misteri::f("mysteri") ; Web Freq 9.80 | Fixes 5 words
:B0X*:mistery::f("mystery") ; Web Freq 19.28 | Fixes 1 word
:B0X*:mohammedan::f("muslim") ; Web Freq 18.38 | Fixes 5 words
:B0X*:momento::f("memento") ; Web Freq 0.72 | Fixes 3 words
:B0X*:monc::f("monoc") ; Web Freq 5.39 | Fixes 81 words
:B0X*:monestar::f("monaster") ; Web Freq 2.59 | Fixes 2 words
:B0X*:monf::f("monof") ; Web Freq 0.19 | Fixes 6 words
:B0X*:monh::f("monoh") ; Web Freq 0.33 | Fixes 9 words
:B0X*:monick::f("monik") ; Web Freq 1.15 | Fixes 4 words
:B0X*:monkie::f("monkey") ; Web Freq 14.25 | Fixes 12 words
:B0X*:monl::f("monol") ; Web Freq 3.04 | Fixes 43 words
:B0X*:monp::f("monop") ; Web Freq 11.62 | Fixes 72 words
:B0X*:montain::f("mountain") ; Web Freq 74.20 | Fixes 18 words
:B0X*:montyp::f("monotyp") ; Web Freq 0.42 | Fixes 3 words
:B0X*:more dominate::f("more dominant") ; Fixes 1 word
:B0X*:more of less::f("more or less") ; Fixes 1 word
:B0X*:more often then::f("more often than") ; Fixes 1 word
:B0X*:more that::f("more than") ; Fixes 1 word
:B0X*:more then::f("more than") ; Fixes 1 word
:B0X*:moreso::f("more so") ; Fixes 1 word
:B0X*:most populace::f("most populous") ; Fixes 1 word
:B0X*:movei::f("movie") ; Web Freq 341.63 | Fixes 16 words
:B0X*:muhammadan::f("muslim") ; Web Freq 18.38 | Fixes 5 words
:B0X*:multi0::f("multi-") ; Fixes 1 word
:B0X*:multipin::f("multilin") ; Web Freq 2.71 | Fixes 5 words
:B0X*:multipled::f("multiplied") ; Web Freq 1.79 | Fixes 1 word
:B0X*:multipler::f("multiplier") ; Web Freq 1.82 | Fixes 2 words
:B0X*:muncipal::f("municipal") ; Web Freq 25.71 | Fixes 17 words
:B0X*:munnicipal::f("municipal") ; Web Freq 25.71 | Fixes 17 words
:B0X*:muscician::f("musician") ; Web Freq 15.85 | Fixes 5 words
:B0X*:mute point::f("moot point") ; Fixes 1 word
:B0X*:mutli::f("multi") ; Web Freq 221.43 | Fixes 375 words
:B0X*:myown::f("my own") ; Fixes 1 word
:B0X*:myraid::f("myriad") ; Web Freq 1.95 | Fixes 3 words
:B0X*:mysogy::f("misogy") ; Web Freq 0.24 | Fixes 10 words
:B0X*:mysterous::f("mysterious") ; Web Freq 5.91 | Fixes 4 words
:B0X*:naieve::f("naive") ; Web Freq 2.18 | Fixes 13 words
:B0X*:napoleonian::f("Napoleonic") ; Web Freq 0.50 | Fixes 1 word
:B0X*:nation wide::f("nationwide") ; Web Freq 15.93 | Fixes 1 word
:B0X*:nazereth::f("Nazareth") ; Web Freq 1.05 | Fixes 1 word
:B0X*:near by::f("nearby") ; Web Freq 27.26 | Fixes 1 word
:B0X*:necessiat::f("necessitat") ; Web Freq 1.56 | Fixes 6 words
:B0X*:nedd::f("need") ; Web Freq 538.21 | Fixes 53 words, but misspells neddy (A British term for a donkey or a foolish person)
:B0X*:neglib::f("negligib") ; Web Freq 1.66 | Fixes 5 words
:B0X*:negligab::f("negligib") ; Web Freq 1.66 | Fixes 5 words
:B0X*:neverthless::f("nevertheless") ; Web Freq 8.59 | Fixes 1 word
:B0X*:new comer::f("newcomer") ; Web Freq 3.24 | Fixes 2 words
:B0X*:newletter::f("newsletter") ; Web Freq 122.70 | Fixes 2 words
:B0X*:newyork::f("New York") ; Fixes 1 word
:B0X*:niee::f("nice") ; Web Freq 145.58 | Fixes 11 words
:B0X*:nieth::f("neith") ; Web Freq 22.64 | Fixes 1 word
:B0X*:nightime::f("nighttime") ; Web Freq 1.03 | Fixes 2 words
:B0X*:nineth::f("ninth") ; Web Freq 4.39 | Fixes 3 words
:B0X*:ninteen::f("nineteen") ; Web Freq 4.18 | Fixes 5 words
:B0X*:ninties::f("nineties") ; Web Freq 0.72 | Fixes 1 word
:B0X*:ninty::f("ninety") ; Web Freq 2.59 | Fixes 5 words
:B0X*:nip it in the butt::f("nip it in the bud") ; Fixes 1 word 
:B0X*:nkwo::f("know") ; Web Freq 533.81 | Fixes 32 words
:B0X*:no where to::f("nowhere to") ; Fixes 1 word
:B0X*:nontheless::f("nonetheless") ; Web Freq 3.99 | Fixes 1 word
:B0X*:norh::f("north") ; Web Freq 627.35 | Fixes 62 words
:B0X*:northen::f("northern") ; Web Freq 109.44 | Fixes 10 words
:B0X*:northereast::f("northeast") ; Web Freq 25.11 | Fixes 14 words
:B0X*:note worth::f("noteworth") ; Web Freq 1.81 | Fixes 6 words
:B0X*:noteri::f("notori") ; Web Freq 4.22 | Fixes 5 words
:B0X*:nothern::f("northern") ; Web Freq 109.44 | Fixes 10 words
:B0X*:notise::f("notice") ; Web Freq 148.57 | Fixes 12 words
:B0X*:notive::f("notice") ; Web Freq 148.57 | Fixes 12 words
:B0X*:notwhith::f("notwith") ; Web Freq 4.21 | Fixes 1 word
:B0X*:noveau::f("nouveau") ; Web Freq 2.15 | Fixes 2 words
:B0X*:nowdays::f("nowadays") ; Web Freq 2.55 | Fixes 1 word
:B0X*:nuisans::f("nuisanc") ; Web Freq 2.05 | Fixes 2 words
:B0X*:numberof::f("number of") ; Fixes 1 word
:B0X*:numberol::f("numerol") ; Web Freq 0.66 | Fixes 6 words
:B0X*:numberou::f("numerou") ; Web Freq 19.71 | Fixes 4 words
:B0X*:nutur::f("nurtur") ; Web Freq 3.29 | Fixes 10 words
:B0X*:nver::f("never") ; Web Freq 158.98 | Fixes 5 words
:B0X*:nwe::f("new") ; Web Freq 4189.83 | Fixes 159 words
:B0X*:nwo::f("now") ; Web Freq 619.92 | Fixes 27 words
:B0X*:obess::f("obsess") ; Web Freq 6.61 | Fixes 17 words
:B0X*:obssess::f("obsess") ; Web Freq 6.61 | Fixes 17 words
:B0X*:ocasion::f("occasion") ; Web Freq 37.91 | Fixes 12 words
:B0X*:ocass::f("occas") ; Web Freq 37.91 | Fixes 12 words
:B0X*:occaison::f("occasion") ; Web Freq 37.91 | Fixes 12 words
:B0X*:occati::f("occasi") ; Web Freq 37.91 | Fixes 12 words
:B0X*:of it's kind::f("of its kind") ; Fixes 1 word
:B0X*:ofits::f("of its") ; Fixes 1 word
:B0X*:oft he::f("of the") ; Fixes 1 word . Could be legitimate in poetry, but usually a typo.
:B0X*:oging::f("going") ; Web Freq 155.86 | Fixes 2 words
:B0X*:oil barron::f("oil baron") ; Fixes 1 word
:B0X*:okease::f("please") ; Web Freq 394.35 | Fixes 7 words
:B0X*:omited::f("omitted") ; Web Freq 4.33 | Fixes 1 word
:B0X*:omiting::f("omitting") ; Web Freq 0.53 | Fixes 1 word
:B0X*:omlette::f("omelette") ; Web Freq 0.29 | Fixes 2 words
:B0X*:ommite::f("omitte") ; Web Freq 4.33 | Fixes 3 words
:B0X*:ommiting::f("omitting") ; Web Freq 0.53 | Fixes 1 word
:B0X*:ommitt::f("omitt") ; Web Freq 4.86 | Fixes 5 words
:B0X*:on accident::f("by accident") ; Fixes 1 word
:B0X*:on going::f("ongoing") ; Web Freq 16.98 | Fixes 4 words
:B0X*:on-going::f("ongoing") ; Web Freq 16.98 | Fixes 4 words
:B0X*:oncs::f("ones") ; Web Freq 38.59 | Fixes 4 words
:B0X*:oneof::f("one of") ; Fixes 1 word
:B0X*:ongoing bases::f("ongoing basis") ; Fixes 1 word
:B0X*:onot::f("not") ; Web Freq 3298.07 | Fixes 146 words
:B0X*:onpar::f("on par") ; Fixes 1 word
:B0X*:ont he::f("on the") ; Fixes 1 word
:B0X*:onyl::f("only") ; Web Freq 661.84 | Fixes 1 word
:B0X*:open pour::f("open pore") ; Fixes 1 word
:B0X*:opol::f("apol") ; Web Freq 22.39 | Fixes 45 words
:B0X*:oponen::f("opponen") ; Web Freq 11.33 | Fixes 5 words
:B0X*:opose::f("oppose") ; Web Freq 15.10 | Fixes 7 words
:B0X*:oposi::f("opposi") ; Web Freq 40.80 | Fixes 18 words
:B0X*:oppositit::f("opposit") ; Web Freq 37.30 | Fixes 16 words
:B0X*:opre::f("oppre") ; Web Freq 4.46 | Fixes 12 words
:B0X*:orded::f("ordered") ; Web Freq 20.05 | Fixes 2 words
:B0X*:other then::f("other than") ; Fixes 1 word
:B0X*:othersis::f("otherwis") ; Web Freq 53.41 | Fixes 2 words
:B0X*:our resent::f("our recent") ; Fixes 1 word
:B0X*:oustand::f("outstand") ; Web Freq 21.70 | Fixes 5 words
:B0X*:out grow::f("outgrow") ; Web Freq 0.82 | Fixes 6 words
:B0X*:out of sink::f("out of sync") ; Fixes 1 word
:B0X*:out of state::f("out-of-state") ; Fixes 1 word
:B0X*:out side::f("outside") ; Web Freq 69.93 | Fixes 7 words
:B0X*:outof::f("out of") ; Fixes 1 word
:B0X*:outpot::f("output") ; Web Freq 62.16 | Fixes 4 words
:B0X*:over hea::f("overhea") ; Web Freq 9.71 | Fixes 18 words
:B0X*:over look::f("overlook") ; Web Freq 7.66 | Fixes 6 words
:B0X*:over rate::f("overrate") ; Web Freq 0.64 | Fixes 3 words
:B0X*:over saw::f("oversaw") ; Web Freq 0.35 | Fixes 1 word
:B0X*:over see::f("oversee") ; Web Freq 5.24 | Fixes 10 words
:B0X*:overthere::f("over there") ; Fixes 1 word
:B0X*:overwelm::f("overwhelm") ; Web Freq 7.62 | Fixes 6 words
:B0X*:owudl::f("would") ; Web Freq 572.87 | Fixes 6 words
:B0X*:owuld::f("would") ; Web Freq 572.87 | Fixes 6 words
:B0X*:oximoron::f("oxymoron") ; Web Freq 0.48 | Fixes 4 words
:B0X*:paleolitic::f("paleolithic") ; Web Freq 0.36 | Fixes 2 words
:B0X*:palist::f("Palest") ; Web Freq 20.83 | Fixes 9 words
:B0X*:paln::f("plan") ; Web Freq 562.17 | Fixes 146 words
:B0X*:pamflet::f("pamphlet") ; Web Freq 2.56 | Fixes 8 words
:B0X*:pamplet::f("pamphlet") ; Web Freq 2.56 | Fixes 8 words
:B0X*:pantomin::f("pantomim") ; Web Freq 0.34 | Fixes 9 words
:B0X*:paranthe::f("parenthe") ; Web Freq 2.55 | Fixes 15 words
:B0X*:paraphenalia::f("paraphernalia") ; Web Freq 0.54 | Fixes 1 word
:B0X*:parrakeet::f("parakeet") ; Web Freq 0.36 | Fixes 2 words
:B0X*:partof::f("part of") ; Fixes 1 word
:B0X*:pasenger::f("passenger") ; Web Freq 20.11 | Fixes 2 words
:B0X*:past away::f("passed away") ; Fixes 1 word
:B0X*:past down::f("passed down") ; Fixes 1 word
:B0X*:pasttime::f("pastime") ; Web Freq 1.05 | Fixes 2 words
:B0X*:pastural::f("pastoral") ; Web Freq 3.26 | Fixes 12 words
:B0X*:pavillion::f("pavilion") ; Web Freq 6.64 | Fixes 4 words
:B0X*:peacefuland::f("peaceful and") ; Fixes 1 word
:B0X*:peageant::f("pageant") ; Web Freq 1.88 | Fixes 4 words
:B0X*:peak her interest::f("pique her interest") ; Fixes 1 word
:B0X*:peak his interest::f("pique his interest") ; Fixes 1 word
:B0X*:peaked my interest::f("piqued my interest") ; Fixes 1 word
:B0X*:pedestrain::f("pedestrian") ; Web Freq 4.68 | Fixes 15 words
:B0X*:peek performance::f("peak performance") ; Fixes 1 word
:B0X*:pensle::f("pencil") ; Web Freq 8.21 | Fixes 12 words
:B0X*:peom::f("poem") ; Web Freq 21.57 | Fixes 2 words
:B0X*:perade::f("parade") ; Web Freq 9.50 | Fixes 5 words
:B0X*:percentof::f("percent of") ; Fixes 1 word
:B0X*:percentto::f("percent to") ; Fixes 1 word
:B0X*:peretrat::f("perpetrat") ; Web Freq 2.56 | Fixes 8 words
:B0X*:perheaps::f("perhaps") ; Web Freq 42.45 | Fixes 2 words
:B0X*:perhpas::f("perhaps") ; Web Freq 42.45 | Fixes 2 words
:B0X*:peripathetic::f("peripatetic") ; Web Freq 0.17 | Fixes 7 words
:B0X*:peristen::f("persisten") ; Web Freq 8.72 | Fixes 6 words
:B0X*:perjer::f("perjur") ; Web Freq 0.83 | Fixes 10 words
:B0X*:perjorative::f("pejorative") ; Web Freq 0.16 | Fixes 3 words
:B0X*:permsssi::f("permissi") ; Web Freq 52.10 | Fixes 14 words
:B0X*:perogative::f("prerogative") ; Web Freq 0.70 | Fixes 3 words
:B0X*:perpindicular::f("perpendicular") ; Web Freq 1.46 | Fixes 6 words
:B0X*:persan::f("person") ; Web Freq 514.58 | Fixes 58 words
:B0X*:persent::f("percent") ; Web Freq 125.63 | Fixes 7 words
:B0X*:perseveren::f("perseveran") ; Web Freq 0.83 | Fixes 4 words
:B0X*:personal affect::f("personal effect") ; Fixes 1 word
:B0X*:personell::f("personnel") ; Web Freq 33.34 | Fixes 2 words
:B0X*:personnell::f("personnel") ; Web Freq 33.34 | Fixes 2 words
:B0X*:pharoah::f("Pharaoh") ; Web Freq 2.97 | Fixes 4 words
:B0X*:pheonix::f("phoenix") ; Web Freq 56.05 | Fixes 4 words
:B0X*:picel::f("pixel") ; Web Freq 19.39 | Fixes 23 words
:B0X*:pilgrimm::f("pilgrim") ; Web Freq 8.17 | Fixes 10 words
:B0X*:pinapple::f("pineapple") ; Web Freq 2.65 | Fixes 2 words
:B0X*:pinnaple::f("pineapple") ; Web Freq 2.65 | Fixes 2 words
:B0X*:plagar::f("plagiar") ; Web Freq 1.97 | Fixes 23 words
:B0X*:plantiff::f("plaintiff") ; Web Freq 10.35 | Fixes 2 words
:B0X*:plateu::f("plateau") ; Web Freq 2.81 | Fixes 5 words
:B0X*:playright::f("playwright") ; Web Freq 1.52 | Fixes 4 words
:B0X*:playwrite::f("playwright") ; Web Freq 1.52 | Fixes 4 words
:B0X*:plebicit::f("plebiscit") ; Web Freq 0.15 | Fixes 3 words
:B0X*:poety::f("poetry") ; Web Freq 25.31 | Fixes 1 word
:B0X*:pomegranite::f("pomegranate") ; Web Freq 0.60 | Fixes 2 words
:B0X*:pore attempt::f("poor attempt") ; Fixes 1 word
:B0X*:pore choice::f("poor choice") ; Fixes 1 word
:B0X*:pore connection::f("poor connection") ; Fixes 1 word
:B0X*:pore effort::f("poor effort") ; Fixes 1 word
:B0X*:pore example::f("poor example") ; Fixes 1 word
:B0X*:pore excuse::f("poor excuse") ; Fixes 1 word
:B0X*:pore execution::f("poor execution") ; Fixes 1 word
:B0X*:pore grade::f("poor grade") ; Fixes 1 word
:B0X*:pore outcome::f("poor outcome") ; Fixes 1 word
:B0X*:pore performance::f("poor performance") ; Fixes 1 word
:B0X*:pore qualit::f("poor qualit") ; Fixes 1 word
:B0X*:pore rating::f("poor rating") ; Fixes 1 word
:B0X*:pore showing::f("poor showing") ; Fixes 1 word
:B0X*:pore sport::f("poor sport") ; Fixes 1 word
:B0X*:pore taste::f("poor taste") ; Fixes 1 word
:B0X*:portugese::f("Portuguese") ; Web Freq 11.16 | Fixes 2 words
:B0X*:portuguease::f("Portuguese") ; Web Freq 11.16 | Fixes 2 words
:B0X*:posthomous::f("posthumous") ; Web Freq 0.46 | Fixes 4 words
:B0X*:potra::f("portra") ; Web Freq 21.95 | Fixes 15 words
:B0X*:pour attempt::f("poor attempt") ; Fixes 1 word
:B0X*:pour choice::f("poor choice") ; Fixes 1 word
:B0X*:pour connection::f("poor connection") ; Fixes 1 word
:B0X*:pour effort::f("poor effort") ; Fixes 1 word
:B0X*:pour example::f("poor example") ; Fixes 1 word
:B0X*:pour excuse::f("poor excuse") ; Fixes 1 word
:B0X*:pour execution::f("poor execution") ; Fixes 1 word
:B0X*:pour grade::f("poor grade") ; Fixes 1 word
:B0X*:pour judgment::f("poor judgment") ; Fixes 1 word
:B0X*:pour outcome::f("poor outcome") ; Fixes 1 word
:B0X*:pour plan::f("poor plan") ; Fixes 1 word
:B0X*:pour rating::f("poor rating") ; Fixes 1 word
:B0X*:pour result::f("poor result") ; Fixes 1 word
:B0X*:pour sport::f("poor sport") ; Fixes 1 word
:B0X*:pour start::f("poor start") ; Fixes 1 word
:B0X*:pour taste::f("poor taste") ; Fixes 1 word
:B0X*:prairy::f("prairie") ; Web Freq 9.48 | Fixes 2 words
:B0X*:prarie::f("prairie") ; Web Freq 9.48 | Fixes 2 words
:B0X*:pre-Colombian::f("pre-Columbian") ; Fixes 1 word
:B0X*:preample::f("preamble") ; Web Freq 1.47 | Fixes 3 words
:B0X*:precedessor::f("predecessor") ; Web Freq 3.07 | Fixes 2 words
:B0X*:precentage::f("percentage") ; Web Freq 27.90 | Fixes 2 words
:B0X*:precurser::f("precursor") ; Web Freq 3.82 | Fixes 3 words
:B0X*:preferra::f("prefera") ; Web Freq 5.62 | Fixes 5 words
:B0X*:premei::f("premie") ; Web Freq 32.20 | Fixes 10 words, but misspells Premeiotic (existing before cell division for reproduction)
:B0X*:preminen::f("preeminen") ; Web Freq 0.48 | Fixes 4 words
:B0X*:premissio::f("permissio") ; Web Freq 49.67 | Fixes 3 words
:B0X*:prepart::f("preparat") ; Web Freq 31.37 | Fixes 9 words
:B0X*:prepat::f("preparat") ; Web Freq 31.37 | Fixes 9 words, but misspells Prepatent (period of time between initial parasite infection and detectability)
:B0X*:prepera::f("prepara") ; Web Freq 31.37 | Fixes 9 words
:B0X*:presitg::f("prestig") ; Web Freq 8.24 | Fixes 7 words
:B0X*:prevers::f("pervers") ; Web Freq 1.50 | Fixes 11 words
:B0X*:prevoi::f("previo") ; Web Freq 229.39 | Fixes 4 words
:B0X*:primarly::f("primarily") ; Web Freq 17.98 | Fixes 1 word
:B0X*:primativ::f("primitiv") ; Web Freq 5.77 | Fixes 12 words
:B0X*:primorda::f("primordia") ; Web Freq 0.56 | Fixes 5 words
:B0X*:principaly::f("principally") ; Web Freq 1.85 | Fixes 1 word
:B0X*:principle accommodation::f("principal accommodation") ; Fixes 1 word
:B0X*:principle adaptation::f("principal adaptation") ; Fixes 1 word
:B0X*:principle advantage::f("principal advantage") ; Fixes 1 word
:B0X*:principle advisor::f("principal advisor") ; Fixes 1 word
:B0X*:principle aide::f("principal aide") ; Fixes 1 word
:B0X*:principle approval::f("principal approval") ; Fixes 1 word
:B0X*:principle assistant::f("principal assistant") ; Fixes 1 word
:B0X*:principle balance::f("principal balance") ; Fixes 1 word
:B0X*:principle behavior::f("principal behavior*") ; Fixes 1 word
:B0X*:principle cause::f("principal cause") ; Fixes 1 word
:B0X*:principle character::f("principal character") ; Fixes 1 word
:B0X*:principle classification::f("principal classification") ; Fixes 1 word
:B0X*:principle component::f("principal component") ; Fixes 1 word
:B0X*:principle concern::f("principal concern") ; Fixes 1 word
:B0X*:principle conference::f("principal conference") ; Fixes 1 word
:B0X*:principle decision::f("principal decision") ; Fixes 1 word
:B0X*:principle diagnos::f("principal diagnos") ; Fixes 1 word
:B0X*:principle direction::f("principal direction") ; Fixes 1 word
:B0X*:principle directive::f("principal directive") ; Fixes 1 word
:B0X*:principle disabilit::f("principal disabilit") ; Fixes 1 word
:B0X*:principle evaluation::f("principal evaluation") ; Fixes 1 word
:B0X*:principle focus::f("principal focus") ; Fixes 1 word
:B0X*:principle goal::f("principal goal") ; Fixes 1 word
:B0X*:principle group::f("principal group") ; Fixes 1 word
:B0X*:principle guidance::f("principal guidance") ; Fixes 1 word
:B0X*:principle inclusion::f("principal inclusion") ; Fixes 1 word
:B0X*:principle interest::f("principal interest") ; Fixes 1 word
:B0X*:principle intervention::f("principal intervention") ; Fixes 1 word
:B0X*:principle investigator::f("principal investigator") ; Fixes 1 word
:B0X*:principle method::f("principal method") ; Fixes 1 word
:B0X*:principle objective::f("principal objective") ; Fixes 1 word
:B0X*:principle observation::f("principal observation") ; Fixes 1 word
:B0X*:principle owner::f("principal owner") ; Fixes 1 word
:B0X*:principle source::f("principal source") ; Fixes 1 word
:B0X*:principle strateg::f("principal strateg") ; Fixes 1 word
:B0X*:principle student::f("principal student") ; Fixes 1 word
:B0X*:principle supervisor::f("principal supervisor") ; Fixes 1 word
:B0X*:principle support::f("principal support") ; Fixes 1 word
:B0X*:principle symptom::f("principal symptom") ; Fixes 1 word
:B0X*:principle transition::f("principal transition") ; Fixes 1 word
:B0X*:principle value::f("principal value") ; Fixes 1 word
:B0X*:principly::f("principally") ; Web Freq 1.85 | Fixes 1 word
:B0X*:pringa::f("printa") ; Web Freq 23.71 | Fixes 5 words 
:B0X*:pringe::f("printe") ; Web Freq 129.72 | Fixes 5 words 
:B0X*:pringm::f("printm") ; Web Freq 0.86 | Fixes 4 words 
:B0X*:procede::f("proceed") ; Web Freq 52.96 | Fixes 7 words
:B0X*:proceding::f("proceeding") ; Web Freq 31.42 | Fixes 2 words
:B0X*:proceedur::f("procedur") ; Web Freq 87.80 | Fixes 5 words
:B0X*:profilic::f("prolific") ; Web Freq 1.54 | Fixes 8 words
:B0X*:progid::f("prodig") ; Web Freq 2.35 | Fixes 11 words
:B0X*:prologomen::f("prolegomen") ; Web Freq 0.04 | Fixes 3 words
:B0X*:promiscous::f("promiscuous") ; Web Freq 0.42 | Fixes 4 words
:B0X*:pronomial::f("pronominal") ; Web Freq 0.06 | Fixes 3 words
:B0X*:proof read::f("proofread") ; Web Freq 1.22 | Fixes 5 words
:B0X*:prophac::f("prophec") ; Web Freq 3.82 | Fixes 2 words
:B0X*:prophet margin::f("profit margin") ; Fixes 1 word
:B0X*:proseletyz::f("proselytiz") ; Web Freq 0.18 | Fixes 8 words
:B0X*:protocal::f("protocol") ; Web Freq 41.62 | Fixes 6 words
:B0X*:protruber::f("protuber") ; Web Freq 0.08 | Fixes 13 words
:B0X*:provious::f("previous") ; Web Freq 229.39 | Fixes 4 words
:B0X*:proximt::f("proximit") ; Web Freq 4.34 | Fixes 2 words
:B0X*:puch::f("push") ; Web Freq 37.26 | Fixes 46 words
:B0X*:pumkin::f("pumpkin") ; Web Freq 4.93 | Fixes 4 words
:B0X*:puritannic::f("puritanic") ; Web Freq 0.09 | Fixes 4 words
:B0X*:purpot::f("purport") ; Web Freq 2.15 | Fixes 5 words
:B0X*:puting::f("putting") ; Web Freq 18.52 | Fixes 2 words
:B0X*:quess::f("guess") ; Web Freq 33.46 | Fixes 14 words
:B0X*:quinessen::f("quintessen") ; Web Freq 1.00 | Fixes 4 words
:B0X*:quize::f("quizze") ; Web Freq 6.73 | Fixes 4 words
:B0X*:racaus::f("raucous") ; Web Freq 0.32 | Fixes 4 words
:B0X*:racio::f("radio") ; Web Freq 138.21 | Fixes 152 words
:B0X*:raed::f("read") ; Web Freq 704.67 | Fixes 77 words
:B0X*:raing::f("rating") ; Web Freq 271.64 | Fixes 2 words
:B0X*:rasberr::f("raspberr") ; Web Freq 2.40 | Fixes 2 words
:B0X*:rather then::f("rather than") ; Fixes 1 word
:B0X*:read carpet::f("red carpet") ; Fixes 1 word
:B0X*:reasing::f("reading") ; Web Freq 199.26 | Fixes 3 words
:B0X*:rebounce::f("rebound") ; Web Freq 9.81 | Fixes 6 words
:B0X*:receivedfrom::f("received from") ; Fixes 1 word
:B0X*:recie::f("recei") ; Web Freq 260.42 | Fixes 19 words
:B0X*:reciv::f("receiv") ; Web Freq 241.01 | Fixes 13 words
:B0X*:recomen::f("recommen") ; Web Freq 158.27 | Fixes 18 words
:B0X*:reconi::f("recogni") ; Web Freq 77.94 | Fixes 28 words
:B0X*:recuit::f("recruit") ; Web Freq 42.73 | Fixes 9 words
:B0X*:redicu::f("ridicu") ; Web Freq 5.37 | Fixes 10 words
:B0X*:reek havoc::f("wreak havoc") ; Fixes 1 word
:B0X*:reevala::f("reevalu") ; Web Freq 0.55 | Fixes 6 words
:B0X*:refedend::f("referend") ; Web Freq 3.30 | Fixes 3 words
:B0X*:reica::f("reinca") ; Web Freq 0.92 | Fixes 9 words
:B0X*:reigns of power::f("reins of power") ; Fixes 1 word
:B0X*:rein check::f("rain check") ; Fixes 1 word
:B0X*:reknown::f("renown") ; Web Freq 5.10 | Fixes 6 words
:B0X*:relect::f("reelect") ; Web Freq 0.62 | Fixes 6 words
:B0X*:reliza::f("realiza") ; Web Freq 3.62 | Fixes 6 words
:B0X*:relizb::f("reliab") ; Web Freq 38.91 | Fixes 7 words
:B0X*:relize::f("realize") ; Web Freq 26.74 | Fixes 5 words
:B0X*:relizn::f("relian") ; Web Freq 7.48 | Fixes 4 words
:B0X*:remaing::f("remaining") ; Web Freq 21.11 | Fixes 1 word
:B0X*:rememberabl::f("memorabl") ; Web Freq 4.63 | Fixes 4 words, but misspells rememberable (Non-standard word)
:B0X*:remenant::f("remnant") ; Web Freq 2.19 | Fixes 3 words
:B0X*:reminent::f("remnant") ; Web Freq 2.19 | Fixes 3 words
:B0X*:reminsic::f("reminisc") ; Web Freq 2.59 | Fixes 12 words
:B0X*:remiva::f("remova") ; Web Freq 34.19 | Fixes 10 words 
:B0X*:remivi::f("removi") ; Web Freq 9.44 | Fixes 1 word 
:B0X*:rendevous::f("rendezvous") ; Web Freq 1.43 | Fixes 4 words
:B0X*:rendezous::f("rendezvous") ; Web Freq 1.43 | Fixes 4 words
:B0X*:repid::f("rapid") ; Web Freq 38.51 | Fixes 9 words
:B0X*:repon::f("respon") ; Web Freq 314.35 | Fixes 28 words, but misspells Repone (reinstatement in Scottish Law)
:B0X*:repreto::f("reperto") ; Web Freq 2.71 | Fixes 4 words
:B0X*:reprto::f("reperto") ; Web Freq 2.71 | Fixes 4 words
:B0X*:repubi::f("republi") ; Web Freq 100.94 | Fixes 21 words
:B0X*:resaura::f("restaura") ; Web Freq 107.20 | Fixes 8 words
:B0X*:resembe::f("resemble") ; Web Freq 3.76 | Fixes 5 words
:B0X*:resently::f("recently") ; Web Freq 61.64 | Fixes 1 word
:B0X*:resevoir::f("reservoir") ; Web Freq 7.13 | Fixes 2 words
:B0X*:resignement::f("resignation") ; Web Freq 2.83 | Fixes 2 words
:B0X*:resignment::f("resignation") ; Web Freq 2.83 | Fixes 2 words
:B0X*:resse::f("rese") ; Web Freq 743.32 | Fixes 151 words
:B0X*:resson::f("reason") ; Web Freq 144.90 | Fixes 18 words
:B0X*:ressurrect::f("resurrect") ; Web Freq 7.65 | Fixes 10 words
:B0X*:restara::f("restaura") ; Web Freq 107.20 | Fixes 8 words
:B0X*:restaurati::f("restorati") ; Web Freq 25.89 | Fixes 9 words
:B0X*:resteraunt::f("restaurant") ; Web Freq 106.85 | Fixes 6 words
:B0X*:restraunt::f("restaurant") ; Web Freq 106.85 | Fixes 6 words
:B0X*:restura::f("restaura") ; Web Freq 107.20 | Fixes 8 words
:B0X*:retalitat::f("retaliat") ; Web Freq 1.98 | Fixes 10 words
:B0X*:reult::f("result") ; Web Freq 429.38 | Fixes 9 words
:B0X*:revaluat::f("reevaluat") ; Web Freq 0.55 | Fixes 6 words
:B0X*:reveral::f("reversal") ; Web Freq 2.75 | Fixes 2 words
:B0X*:reverral::f("referral") ; Web Freq 16.36 | Fixes 2 words
:B0X*:rfere::f("refere") ; Web Freq 183.57 | Fixes 20 words
:B0X*:right buffer::f("write buffer") ; Fixes 1 word
:B0X*:right permission::f("write permission") ; Fixes 1 word
:B0X*:right protect::f("write protect") ; Fixes 1 word
:B0X*:rite answer::f("right answer") ; Fixes 1 word
:B0X*:rite call::f("right call") ; Fixes 1 word
:B0X*:rite choice::f("right choice") ; Fixes 1 word
:B0X*:rite conclusion::f("right conclusion") ; Fixes 1 word
:B0X*:rite decision::f("right decision") ; Fixes 1 word
:B0X*:rite direction::f("right direction") ; Fixes 1 word
:B0X*:rite guess::f("right guess") ; Fixes 1 word
:B0X*:rite idea::f("right idea") ; Fixes 1 word
:B0X*:rite moment::f("right moment") ; Fixes 1 word
:B0X*:rite move::f("right move") ; Fixes 1 word
:B0X*:rite path::f("right path") ; Fixes 1 word
:B0X*:rite permission::f("write permission") ; Fixes 1 word
:B0X*:rite place::f("right place") ; Fixes 1 word
:B0X*:rite protect::f("write protect") ; Fixes 1 word
:B0X*:rite tim::f("right tim") ; Fixes 1 word
:B0X*:rite track::f("right track") ; Fixes 1 word
:B0X*:rockerfeller::f("Rockefeller") ; Web Freq 1.56 | Fixes 2 words
:B0X*:rococco::f("rococo") ; Web Freq 0.36 | Fixes 2 words
:B0X*:role call::f("roll call") ; Fixes 1 word
:B0X*:role out::f("roll out") ; Fixes 1 word
:B0X*:roll model::f("role model") ; Fixes 1 word
:B0X*:roll play::f("role play") ; Fixes 1 word
:B0X*:romorrow::f("tomorrow") ; Web Freq 21.26 | Fixes 2 words
:B0X*:roomate::f("roommate") ; Web Freq 11.62 | Fixes 2 words
:B0X*:root optimization::f("route optimization") ; Fixes 1 word
:B0X*:root protocol::f("route protocol") ; Fixes 1 word
:B0X*:root table::f("route table") ; Fixes 1 word
:B0X*:roudn::f("round") ; Web Freq 84.73 | Fixes 51 words
:B0X*:rowed the wave::f("rode the wave") ; Fixes 1 word
:B0X*:rucul::f("recul") ; Fixes 5 words
:B0X*:rucum::f("recum") ; Web Freq 0.46 | Fixes 8 words
:B0X*:rucup::f("recup") ; Web Freq 0.44 | Fixes 11 words
:B0X*:rucus::f("recus") ; Web Freq 0.24 | Fixes 12 words
:B0X*:rulle::f("rule") ; Web Freq 167.69 | Fixes 12 words
:B0X*:rumer::f("rumor") ; Web Freq 6.53 | Fixes 8 words
:B0X*:runner up::f("runner-up") ; Fixes 1 word
:B0X*:rythem::f("rhythm") ; Web Freq 10.69 | Fixes 17 words
:B0X*:rythm::f("rhythm") ; Web Freq 10.69 | Fixes 17 words
:B0X*:sacrelig::f("sacrileg") ; Web Freq 0.19 | Fixes 6 words
:B0X*:sacrifical::f("sacrificial") ; Web Freq 0.52 | Fixes 2 words
:B0X*:saddle up to::f("sidle up to") ; Fixes 1 word
:B0X*:safegard::f("safeguard") ; Web Freq 5.98 | Fixes 4 words
:B0X*:saidhe::f("said he") ; Fixes 1 word
:B0X*:saidt he::f("said the") ; Fixes 1 word
:B0X*:salery::f("salary") ; Web Freq 21.19 | Fixes 4 words
:B0X*:sandess::f("sadness") ; Web Freq 1.91 | Fixes 2 words
:B0X*:sandwhich::f("sandwich") ; Web Freq 9.61 | Fixes 6 words
:B0X*:sargan::f("sergean") ; Web Freq 3.41 | Fixes 8 words
:B0X*:sargean::f("sergean") ; Web Freq 3.41 | Fixes 8 words
:B0X*:saterday::f("Saturday") ; Web Freq 70.96 | Fixes 2 words
:B0X*:saxaphon::f("saxophon") ; Web Freq 2.73 | Fixes 5 words
:B0X*:say la v::f("c'est la vie") ; Fixes 1 word
:B0X*:scandanavia::f("Scandinavia") ; Web Freq 4.07 | Fixes 3 words
:B0X*:scaricit::f("scarcit") ; Web Freq 0.92 | Fixes 2 words
:B0X*:scavang::f("scaveng") ; Web Freq 1.27 | Fixes 6 words
:B0X*:school principle::f("school principal") ; Fixes 1 word
:B0X*:scrutinit::f("scrutin") ; Web Freq 4.83 | Fixes 18 words
:B0X*:secceed::f("seced") ; Web Freq 0.22 | Fixes 6 words
:B0X*:see know::f("see now") ; Fixes 1 word
:B0X*:seen the site::f("seen the sight") ; Fixes 1 word
:B0X*:seguoy::f("segue") ; Web Freq 0.32 | Fixes 4 words
:B0X*:seinor::f("senior") ; Web Freq 68.56 | Fixes 5 words
:B0X*:selett::f("select") ; Web Freq 338.92 | Fixes 32 words
:B0X*:semect::f("semest") ; Web Freq 18.13 | Fixes 14 words
:B0X*:senari::f("scenari") ; Web Freq 16.36 | Fixes 4 words, but misspells senarius (a Roman unit of currency equivalent to six asses or a six-line verse)
:B0X*:senc::f("sens") ; Web Freq 135.64 | Fixes 131 words
:B0X*:sentan::f("senten") ; Web Freq 26.59 | Fixes 14 words
:B0X*:sepina::f("subpoena") ; Web Freq 2.22 | Fixes 4 words
:B0X*:sergent::f("sergeant") ; Web Freq 3.41 | Fixes 6 words
:B0X*:set back::f("setback") ; Web Freq 2.12 | Fixes 2 words
:B0X*:severley::f("severely") ; Web Freq 3.99 | Fixes 1 word
:B0X*:severly::f("severely") ; Web Freq 3.99 | Fixes 1 word
:B0X*:shamen::f("shaman") ; Web Freq 2.45 | Fixes 16 words
:B0X*:she begun::f("she began") ; Fixes 1 word
:B0X*:she let's::f("she lets") ; Fixes 1 word
:B0X*:she seen::f("she saw") ; Fixes 1 word
:B0X*:short coming::f("shortcoming") ; Web Freq 1.77 | Fixes 2 words
:B0X*:shorter then::f("shorter than") ; Fixes 1 word
:B0X*:shortly there after::f("shortly thereafter") ; Fixes 1 word
:B0X*:shortwhile::f("short while") ; Fixes 1 word
:B0X*:shoudl::f("should") ; Web Freq 419.67 | Fixes 12 words
:B0X*:should backup::f("should back up") ; Fixes 1 word
:B0X*:should've went::f("should have gone") ; Fixes 1 word
:B0X*:shreak::f("shriek") ; Web Freq 0.70 | Fixes 11 words
:B0X*:shrinked::f("shrunk") ; Web Freq 0.88 | Fixes 2 words
:B0X*:side affect::f("side effect") ; Fixes 1 word
:B0X*:side kick::f("sidekick") ; Web Freq 1.29 | Fixes 2 words
:B0X*:sideral::f("sidereal") ; Web Freq 0.13 | Fixes 2 words
:B0X*:sight administrator::f("site administrator") ; Fixes 1 word
:B0X*:sight analys::f("site analys") ; Fixes 1 word
:B0X*:sight license::f("site license") ; Fixes 1 word
:B0X*:sight metric::f("site metric") ; Fixes 1 word
:B0X*:sight performance::f("site performance") ; Fixes 1 word
:B0X*:sight reliabilit::f("site reliabilit") ; Fixes 1 word
:B0X*:sight securit::f("site securit") ; Fixes 1 word
:B0X*:silicone chip::f("silicon chip") ; Fixes 1 word
:B0X*:simetr::f("symmetr") ; Web Freq 7.56 | Fixes 19 words
:B0X*:simplier::f("simpler") ; Web Freq 3.64 | Fixes 1 word
:B0X*:single handily::f("single-handedly") ; Fixes 1 word
:B0X*:singsog::f("singsong") ; Web Freq 0.03 | Fixes 5 words
:B0X*:site line::f("sight line") ; Fixes 1 word
:B0X*:site-word recog::f("sight-word recog") ; Fixes 1 word
:B0X*:slue of::f("slew of") ; Fixes 1 word
:B0X*:smaller then::f("smaller than") ; Fixes 1 word
:B0X*:smarter then::f("smarter than") ; Fixes 1 word
:B0X*:sn;r::f("able") ; Web Freq 110.06 | Fixes 15 words
:B0X*:sneak peak::f("sneak peek") ; Fixes 1 word
:B0X*:sneek::f("sneak") ; Web Freq 6.24 | Fixes 17 words
:B0X*:so it you::f("so if you") ; Fixes 1 word
:B0X*:soar experience::f("sore experience") ; Fixes 1 word
:B0X*:soar feeling::f("sore feeling") ; Fixes 1 word
:B0X*:soar lesson::f("sore lesson") ; Fixes 1 word
:B0X*:soar loser::f("sore loser") ; Fixes 1 word
:B0X*:soar memor::f("sore memor") ; Fixes 1 word
:B0X*:soar muscle::f("sore muscle") ; Fixes 1 word
:B0X*:soar point::f("sore point") ; Fixes 1 word
:B0X*:soar reminder::f("sore reminder") ; Fixes 1 word
:B0X*:soar sport::f("sore sport") ; Fixes 1 word
:B0X*:soar spot::f("sore spot") ; Fixes 1 word
:B0X*:soar subject::f("sore subject") ; Fixes 1 word
:B0X*:soar temper::f("sore temper") ; Fixes 1 word
:B0X*:soar throat::f("sore throat") ; Fixes 1 word
:B0X*:soar thumb::f("sore thumb") ; Fixes 1 word
:B0X*:soar topic::f("sore topic") ; Fixes 1 word
:B0X*:soar winner::f("sore winner") ; Fixes 1 word
:B0X*:sofwa::f("softwa") ; Web Freq 371.78 | Fixes 2 words
:B0X*:soilder::f("soldier") ; Web Freq 26.35 | Fixes 15 words
:B0X*:solatar::f("solitar") ; Web Freq 1.63 | Fixes 5 words
:B0X*:soley::f("solely") ; Web Freq 10.09 | Fixes 1 word
:B0X*:soliders::f("soldiers") ; Web Freq 16.18 | Fixes 3 words
:B0X*:soliliqu::f("soliloqu") ; Web Freq 0.21 | Fixes 14 words
:B0X*:some what::f("somewhat") ; Web Freq 15.62 | Fixes 2 words
:B0X*:some where::f("somewhere") ; Web Freq 14.34 | Fixes 2 words
:B0X*:somene::f("someone") ; Web Freq 76.55 | Fixes 3 words
:B0X*:someting::f("something") ; Web Freq 132.22 | Fixes 2 words
:B0X*:somthing::f("something") ; Web Freq 132.22 | Fixes 2 words
:B0X*:somtime::f("sometime") ; Web Freq 52.18 | Fixes 2 words
:B0X*:somwhere::f("somewhere") ; Web Freq 14.34 | Fixes 2 words
:B0X*:soon there after::f("soon thereafter") ; Fixes 1 word
:B0X*:sooner then::f("sooner than") ; Fixes 1 word
:B0X*:soory::f("sorry") ; Web Freq 35.60 | Fixes 2 words
:B0X*:sophmor::f("sophomor") ; Web Freq 3.68 | Fixes 4 words
:B0X*:sorceror::f("sorcerer") ; Web Freq 1.28 | Fixes 2 words
:B0X*:sorround::f("surround") ; Web Freq 33.67 | Fixes 6 words
:B0X*:soryy::f("sorry") ; Web Freq 35.60 | Fixes 2 words
:B0X*:sot hat::f("so that") ; Fixes 1 word
:B0X*:soul focus::f("sole focus") ; Fixes 1 word
:B0X*:soul intention::f("sole intention") ; Fixes 1 word
:B0X*:soul proprietor::f("sole proprietor") ; Fixes 1 word
:B0X*:soul purpose::f("sole purpose") ; Fixes 1 word
:B0X*:sould::f("should") ; Web Freq 419.67 | Fixes 12 words
:B0X*:sountrack::f("soundtrack") ; Web Freq 13.44 | Fixes 2 words
:B0X*:source cite::f("source site") ; Fixes 1 word
:B0X*:source sight::f("source site") ; Fixes 1 word
:B0X*:sourth::f("south") ; Web Freq 610.21 | Fixes 74 words
:B0X*:souvenier::f("souvenir") ; Web Freq 3.86 | Fixes 2 words
:B0X*:soveit::f("soviet") ; Web Freq 19.55 | Fixes 20 words
:B0X*:sovereignit::f("sovereignt") ; Web Freq 2.91 | Fixes 4 words
:B0X*:spainish::f("Spanish") ; Web Freq 46.48 | Fixes 1 word
:B0X*:speach::f("speech") ; Web Freq 38.32 | Fixes 19 words
:B0X*:specch::f("speech") ; Web Freq 38.32 | Fixes 19 words
:B0X*:speciman::f("specimen") ; Web Freq 7.41 | Fixes 2 words
:B0X*:spendour::f("splendour") ; Web Freq 0.58 | Fixes 2 words
:B0X*:spilt among::f("split among") ; Fixes 1 word
:B0X*:spilt between::f("split between") ; Fixes 1 word
:B0X*:spilt into::f("split into") ; Fixes 1 word
:B0X*:spilt up::f("split up") ; Fixes 1 word
:B0X*:spinal chord::f("spinal cord") ; Fixes 1 word
:B0X*:split in to::f("split into") ; Fixes 1 word
:B0X*:sportscar::f("sports car") ; Fixes 1 word
:B0X*:sq ft::f("ft²") ; Fixes 1 word
:B0X*:sq in::f("in²") ; Fixes 1 word
:B0X*:sq km::f("km²") ; Fixes 1 word
:B0X*:squared feet::f("square feet") ; Fixes 1 word
:B0X*:squared inch::f("square inch") ; Fixes 1 word
:B0X*:squared kilometer::f("square kilometer") ; Fixes 1 word
:B0X*:squared meter::f("square meter") ; Fixes 1 word
:B0X*:squared mile::f("square mile") ; Fixes 1 word
:B0X*:stale mat::f("stalemat") ; Web Freq 0.37 | Fixes 4 words
:B0X*:staring role::f("starring role") ; Fixes 1 word
:B0X*:starring roll::f("starring role") ; Fixes 1 word
:B0X*:stay a while::f("stay awhile") ; Fixes 1 word
:B0X*:stilus::f("stylus") ; Web Freq 8.60 | Fixes 2 words
:B0X*:stornegst::f("strongest") ; Web Freq 3.48 | Fixes 1 word
:B0X*:stpo::f("stop") ; Web Freq 112.80 | Fixes 47 words
:B0X*:straight jacket::f("straitjacket") ; Web Freq 0.12 | Fixes 4 words
:B0X*:strait jacket::f("straitjacket") ; Web Freq 0.12 | Fixes 4 words
:B0X*:strait lace::f("straitlace") ; Fixes 4 words
:B0X*:strenous::f("strenuous") ; Web Freq 0.74 | Fixes 4 words
:B0X*:strictist::f("strictest") ; Web Freq 0.32 | Fixes 1 word
:B0X*:strike out::f("strikeout") ; Web Freq 0.46 | Fixes 2 words
:B0X*:strikely::f("strikingly") ; Web Freq 0.53 | Fixes 1 word
:B0X*:stronger then::f("stronger than") ; Fixes 1 word
:B0X*:stroy::f("story") ; Web Freq 145.40 | Fixes 17 words
:B0X*:struggel::f("struggle") ; Web Freq 15.72 | Fixes 5 words
:B0X*:strugl::f("struggl") ; Web Freq 20.41 | Fixes 7 words
:B0X*:stubborness::f("stubbornness") ; Web Freq 0.13 | Fixes 2 words
:B0X*:student's that::f("students that") ; Fixes 1 word
:B0X*:stuggl::f("struggl") ; Web Freq 20.41 | Fixes 7 words
:B0X*:stule::f("style") ; Web Freq 126.73 | Fixes 14 words
:B0X*:stuli::f("styli") ; Web Freq 17.25 | Fixes 34 words
:B0X*:stuuggl::f("struggl") ; Web Freq 20.41 | Fixes 7 words
:B0X*:subjold::f("subfold") ; Web Freq 0.36 | Fixes 2 words
:B0X*:subjudga::f("subjuga") ; Web Freq 0.38 | Fixes 9 words
:B0X*:subpeci::f("subspeci") ; Web Freq 0.83 | Fixes 10 words
:B0X*:subrra::f("subtra") ; Web Freq 4.20 | Fixes 16 words
:B0X*:subsidar::f("subsidiar") ; Web Freq 12.62 | Fixes 6 words
:B0X*:subsiduar::f("subsidiar") ; Web Freq 12.62 | Fixes 6 words
:B0X*:subsquen::f("subsequen") ; Web Freq 22.65 | Fixes 6 words
:B0X*:substace::f("substance") ; Web Freq 32.23 | Fixes 3 words
:B0X*:substract::f("subtract") ; Web Freq 4.20 | Fixes 12 words
:B0X*:subtance::f("substance") ; Web Freq 32.23 | Fixes 3 words
:B0X*:suburburban::f("suburban") ; Web Freq 5.78 | Fixes 17 words
:B0X*:succedd::f("succeed") ; Web Freq 14.63 | Fixes 7 words
:B0X*:succeds::f("succeeds") ; Web Freq 1.40 | Fixes 1 word
:B0X*:suceed::f("succeed") ; Web Freq 14.63 | Fixes 7 words
:B0X*:sucid::f("suicid") ; Web Freq 13.20 | Fixes 8 words
:B0X*:sufferag::f("suffrag") ; Web Freq 0.86 | Fixes 10 words
:B0X*:sumar::f("summar") ; Web Freq 96.14 | Fixes 24 words
:B0X*:supercede::f("supersede") ; Web Freq 2.31 | Fixes 7 words
:B0X*:suplim::f("supplem") ; Web Freq 40.84 | Fixes 13 words
:B0X*:supplim::f("supplem") ; Web Freq 40.84 | Fixes 13 words
:B0X*:suppose to::f("supposed to") ; Fixes 1 word
:B0X*:supposingly::f("supposedly") ; Web Freq 2.90 | Fixes 1 word
:B0X*:surplant::f("supplant") ; Web Freq 0.55 | Fixes 8 words
:B0X*:surrended::f("surrendered") ; Web Freq 1.04 | Fixes 1 word
:B0X*:surrepetitious::f("surreptitious") ; Web Freq 0.25 | Fixes 3 words
:B0X*:surreptious::f("surreptitious") ; Web Freq 0.25 | Fixes 3 words
:B0X*:surrond::f("surround") ; Web Freq 33.67 | Fixes 6 words
:B0X*:surrunder::f("surrender") ; Web Freq 5.62 | Fixes 6 words
:B0X*:surveilen::f("surveillan") ; Web Freq 10.35 | Fixes 4 words
:B0X*:surviver::f("survivor") ; Web Freq 11.27 | Fixes 4 words
:B0X*:survivied::f("survived") ; Web Freq 4.43 | Fixes 1 word
:B0X*:swiming::f("swimming") ; Web Freq 20.51 | Fixes 3 words
:B0X*:synagouge::f("synagogue") ; Web Freq 1.86 | Fixes 2 words
:B0X*:synph::f("symph") ; Web Freq 8.81 | Fixes 31 words
:B0X*:syrap::f("syrup") ; Web Freq 3.60 | Fixes 9 words
:B0X*:tabacco::f("tobacco") ; Web Freq 13.80 | Fixes 5 words
:B0X*:take over the reigns::f("take over the reins") ; Fixes 1 word
:B0X*:take the reigns::f("take the reins") ; Fixes 1 word
:B0X*:taken the reigns::f("taken the reins") ; Fixes 1 word
:B0X*:taking the reigns::f("taking the reins") ; Fixes 1 word
:B0X*:tatoo::f("tattoo") ; Web Freq 11.57 | Fixes 8 words
:B0X*:teaching principal::f("teaching principle") ; Fixes 1 word
:B0X*:telelev::f("telev") ; Web Freq 58.29 | Fixes 23 words
:B0X*:televiz::f("televis") ; Web Freq 58.21 | Fixes 12 words
:B0X*:tellt he::f("tell the") ; Fixes 1 word
:B0X*:temerat::f("temperat") ; Web Freq 52.74 | Fixes 6 words
:B0X*:temperment::f("temperament") ; Web Freq 1.27 | Fixes 5 words
:B0X*:temperture::f("temperature") ; Web Freq 51.56 | Fixes 2 words
:B0X*:tenacle::f("tentacle") ; Web Freq 1.21 | Fixes 3 words
:B0X*:termoil::f("turmoil") ; Web Freq 1.24 | Fixes 4 words
:B0X*:testomon::f("testimon") ; Web Freq 27.82 | Fixes 4 words
:B0X*:tghi::f("thi") ; Web Freq 3934.33 | Fixes 260 words
:B0X*:thansk::f("thanks") ; Web Freq 104.82 | Fixes 5 words
:B0X*:thare::f("there") ; Web Freq 803.68 | Fixes 34 words
:B0X*:thast::f("that's") ; Fixes 1 word
:B0X*:that him and::f("that he and") ; Fixes 1 word
:B0X*:thats::f("that's") ; Fixes 1 word
:B0X*:thatt he::f("that the") ; Fixes 1 word
:B0X*:the absent of::f("the absence of") ; Fixes 1 word
:B0X*:the affect on::f("the effect on") ; Fixes 1 word
:B0X*:the affects of::f("the effects of") ; Fixes 1 word
:B0X*:the both the::f("both the") ; Fixes 1 word
:B0X*:the break down::f("the breakdown") ; Fixes 1 word
:B0X*:the break up::f("the breakup") ; Fixes 1 word
:B0X*:the build up::f("the buildup") ; Fixes 1 word
:B0X*:the clamp down::f("the clampdown") ; Fixes 1 word
:B0X*:the crack down::f("the crackdown") ; Fixes 1 word
:B0X*:the follow up::f("the follow-up") ; Fixes 1 word
:B0X*:the injures::f("the injuries") ; Fixes 1 word
:B0X*:the lead up::f("the lead-up") ; Fixes 1 word
:B0X*:the phenomena is::f("the phenomenon is") ; Fixes 1 word
:B0X*:the rational behind::f("the rationale behind") ; Fixes 1 word
:B0X*:the rational for::f("the rationale for") ; Fixes 1 word
:B0X*:the resent::f("the recent") ; Fixes 1 word
:B0X*:the set up::f("the setup") ; Fixes 1 word
:B0X*:thecompany::f("the company") ; Fixes 1 word
:B0X*:thefirst::f("the first") ; Fixes 1 word
:B0X*:thegovernment::f("the government") ; Fixes 1 word
:B0X*:theif::f("thief") ; Web Freq 2.97 | Fixes 1 word
:B0X*:their are::f("there are") ; Fixes 1 word
:B0X*:their had::f("there had") ; Fixes 1 word
:B0X*:their has::f("there has") ; Fixes 1 word
:B0X*:their have::f("there have") ; Fixes 1 word
:B0X*:their may be::f("there may be") ; Fixes 1 word
:B0X*:their was::f("there was") ; Fixes 1 word
:B0X*:their were::f("there were") ; Fixes 1 word
:B0X*:their would::f("there would") ; Fixes 1 word
:B0X*:them selves::f("themselves") ; Web Freq 47.18 | Fixes 1 word
:B0X*:themselfs::f("themselves") ; Web Freq 47.18 | Fixes 1 word
:B0X*:thenew::f("the new") ; Fixes 1 word
:B0X*:therafter::f("thereafter") ; Web Freq 5.23 | Fixes 1 word
:B0X*:therby::f("thereby") ; Web Freq 8.33 | Fixes 1 word
:B0X*:there accommodation::f("their accommodation") ; Fixes 1 word
:B0X*:there assessment::f("their assessment") ; Fixes 1 word
:B0X*:there behavior::f("their behavior") ; Fixes 1 word
:B0X*:there best::f("their best") ; Fixes 1 word
:B0X*:there classification::f("their classification") ; Fixes 1 word
:B0X*:there diagnos::f("their diagnos") ; Fixes 1 word
:B0X*:there final::f("their final") ; Fixes 1 word
:B0X*:there first::f("their first") ; Fixes 1 word
:B0X*:there goal::f("their goal") ; Fixes 1 word
:B0X*:there habit::f("their habit") ; Fixes 1 word
:B0X*:there modification::f("their modification") ; Fixes 1 word
:B0X*:there motivation::f("their motivation") ; Fixes 1 word
:B0X*:there new::f("their new") ; Fixes 1 word
:B0X*:there own::f("their own") ; Fixes 1 word
:B0X*:there path::f("their path") ; Fixes 1 word
:B0X*:there placement::f("their placement") ; Fixes 1 word
:B0X*:there promot::f("they're promot") ; Fixes 1 word
:B0X*:there servic::f("their servic") ; Fixes 1 word
:B0X*:there where::f("there were") ; Fixes 1 word
:B0X*:there's is::f("theirs is") ; Fixes 1 word
:B0X*:there's three::f("there are three") ; Fixes 1 word
:B0X*:there's two::f("there are two") ; Fixes 1 word
:B0X*:therr::f("their") ; Web Freq 784.96 | Fixes 3 words
:B0X*:thesame::f("the same") ; Fixes 1 word
:B0X*:these includes::f("these include") ; Fixes 1 word
:B0X*:these type of::f("these types of") ; Fixes 1 word
:B0X*:these where::f("these were") ; Fixes 1 word
:B0X*:thetwo::f("the two") ; Fixes 1 word
:B0X*:they begun::f("they began") ; Fixes 1 word
:B0X*:they we're::f("they were") ; Fixes 1 word
:B0X*:they weight::f("they weigh") ; Fixes 1 word
:B0X*:they where::f("they were") ; Fixes 1 word
:B0X*:they're are::f("there are") ; Fixes 1 word
:B0X*:they're assessment::f("their assessment") ; Fixes 1 word
:B0X*:they're classification::f("their classification") ; Fixes 1 word
:B0X*:they're goal::f("their goal") ; Fixes 1 word
:B0X*:they're grade::f("their grade") ; Fixes 1 word
:B0X*:they're habit::f("their habit") ; Fixes 1 word
:B0X*:they're is::f("there is") ; Fixes 1 word
:B0X*:they're mindset::f("their mindset") ; Fixes 1 word
:B0X*:they're modification::f("their modification") ; Fixes 1 word
:B0X*:they're motivation::f("their motivation") ; Fixes 1 word
:B0X*:they're path::f("their path") ; Fixes 1 word
:B0X*:they're placement::f("their placement") ; Fixes 1 word
:B0X*:they're productivity::f("their productivity") ; Fixes 1 word
:B0X*:they're provider::f("their provider") ; Fixes 1 word
:B0X*:they're routine::f("their routine") ; Fixes 1 word
:B0X*:they're schedule::f("their schedule") ; Fixes 1 word
:B0X*:theyll::f("they'll") ; Fixes 1 word
:B0X*:theyre::f("they're") ; Fixes 1 word
:B0X*:theyve::f("they've") ; Fixes 1 word
:B0X*:thiers::f("theirs") ; Web Freq 2.11 | Fixes 2 words 
:B0X*:thiir::f("their") ; Web Freq 784.96 | Fixes 3 words
:B0X*:thilf::f("filth") ; Web Freq 3.84 | Fixes 8 words
:B0X*:thirr::f("their") ; Web Freq 784.96 | Fixes 3 words
:B0X*:this data::f("these data") ; Fixes 1 word
:B0X*:this gut::f("this guy") ; Fixes 1 word
:B0X*:this maybe::f("this may be") ; Fixes 1 word
:B0X*:this resent::f("this recent") ; Fixes 1 word
:B0X*:thisyear::f("this year") ; Fixes 1 word
:B0X*:thna::f("than") ; Web Freq 681.01 | Fixes 49 words
:B0X*:thoroughly bread::f("thoroughly bred") ; Fixes 1 word
:B0X*:those includes::f("those include") ; Fixes 1 word
:B0X*:those maybe::f("those may be") ; Fixes 1 word
:B0X*:thoughout::f("throughout") ; Web Freq 51.16 | Fixes 1 word
:B0X*:thousend::f("thousand") ; Web Freq 56.48 | Fixes 5 words
:B0X*:threatend::f("threatened") ; Web Freq 7.16 | Fixes 1 word
:B0X*:thrid::f("third") ; Web Freq 99.92 | Fixes 5 words, but misspells Thrid (Archaic term.  To pierce, penetrate or thread through)
:B0X*:through it's::f("through its") ; Fixes 1 word
:B0X*:through the ringer::f("through the wringer") ; Fixes 1 word
:B0X*:throughly::f("thoroughly") ; Web Freq 6.55 | Fixes 1 word
:B0X*:throughout it's::f("throughout its") ; Fixes 1 word
:B0X*:througout::f("throughout") ; Web Freq 51.16 | Fixes 1 word
:B0X*:throws of passion::f("throes of passion") ; Fixes 1 word
:B0X*:thta::f("that") ; Web Freq 3403.27 | Fixes 20 words
:B0X*:tiem::f("time") ; Web Freq 1168.83 | Fixes 64 words, but misspells Tiemannite (a rare mercury sulfide mineral)
:B0X*:time out::f("timeout") ; Web Freq 4.78 | Fixes 2 words
:B0X*:timeschedule::f("time schedule") ; Fixes 1 word
:B0X*:timne::f("time") ; Web Freq 1168.83 | Fixes 64 words
:B0X*:tiome::f("time") ; Web Freq 1168.83 | Fixes 64 words
:B0X*:to back-off::f("to back off") ; Fixes 1 word
:B0X*:to back-out::f("to back out") ; Fixes 1 word
:B0X*:to back-up::f("to back up") ; Fixes 1 word
:B0X*:to backoff::f("to back off") ; Fixes 1 word
:B0X*:to backout::f("to back out") ; Fixes 1 word
:B0X*:to backup::f("to back up") ; Fixes 1 word
:B0X*:to bailout::f("to bail out") ; Fixes 1 word
:B0X*:to blackout::f("to black out") ; Fixes 1 word
:B0X*:to blastoff::f("to blast off") ; Fixes 1 word
:B0X*:to blowout::f("to blow out") ; Fixes 1 word
:B0X*:to blowup::f("to blow up") ; Fixes 1 word
:B0X*:to breakdown::f("to break down") ; Fixes 1 word
:B0X*:to buildup::f("to build up") ; Fixes 1 word
:B0X*:to built::f("to build") ; Fixes 1 word
:B0X*:to buyout::f("to buy out") ; Fixes 1 word
:B0X*:to comeback::f("to come back") ; Fixes 1 word
:B0X*:to crackdown on::f("to crack down on") ; Fixes 1 word
:B0X*:to cutback::f("to cut back") ; Fixes 1 word
:B0X*:to cutoff::f("to cut off") ; Fixes 1 word
:B0X*:to dropout::f("to drop out") ; Fixes 1 word
:B0X*:to emphasis the::f("to emphasise the") ; Fixes 1 word
:B0X*:to fill-in::f("to fill in") ; Fixes 1 word
:B0X*:to forego::f("to forgo") ; Fixes 1 word
:B0X*:to happened::f("to happen") ; Fixes 1 word
:B0X*:to he and::f("to him and") ; Fixes 1 word
:B0X*:to holdout::f("to hold out") ; Fixes 1 word
:B0X*:to kickoff::f("to kick off") ; Fixes 1 word
:B0X*:to lockout::f("to lock out") ; Fixes 1 word
:B0X*:to lockup::f("to lock up") ; Fixes 1 word
:B0X*:to login::f("to log in") ; Fixes 1 word
:B0X*:to logout::f("to log out") ; Fixes 1 word
:B0X*:to lookup::f("to look up") ; Fixes 1 word
:B0X*:to markup::f("to mark up") ; Fixes 1 word
:B0X*:to opt-in::f("to opt in") ; Fixes 1 word
:B0X*:to opt-out::f("to opt out") ; Fixes 1 word
:B0X*:to phaseout::f("to phase out") ; Fixes 1 word
:B0X*:to pickup::f("to pick up") ; Fixes 1 word
:B0X*:to playback::f("to play back") ; Fixes 1 word
:B0X*:to rebuilt::f("to be rebuilt") ; Fixes 1 word
:B0X*:to rollback::f("to roll back") ; Fixes 1 word
:B0X*:to runaway::f("to run away") ; Fixes 1 word
:B0X*:to seen::f("to be seen") ; Fixes 1 word
:B0X*:to sent::f("to send") ; Fixes 1 word
:B0X*:to setup::f("to set up") ; Fixes 1 word
:B0X*:to shut-down::f("to shut down") ; Fixes 1 word
:B0X*:to shutdown::f("to shut down") ; Fixes 1 word
:B0X*:to spent::f("to spend") ; Fixes 1 word
:B0X*:to spin-off::f("to spin off") ; Fixes 1 word
:B0X*:to spinoff::f("to spin off") ; Fixes 1 word
:B0X*:to takeover::f("to take over") ; Fixes 1 word
:B0X*:to that affect::f("to that effect") ; Fixes 1 word
:B0X*:to they're::f("to their") ; Fixes 1 word
:B0X*:to touchdown::f("to touch down") ; Fixes 1 word
:B0X*:to try-out::f("to try out") ; Fixes 1 word
:B0X*:to tryout::f("to try out") ; Fixes 1 word
:B0X*:to turn-off::f("to turn off") ; Fixes 1 word
:B0X*:to turnaround::f("to turn around") ; Fixes 1 word
:B0X*:to turnoff::f("to turn off") ; Fixes 1 word
:B0X*:to turnout::f("to turn out") ; Fixes 1 word
:B0X*:to turnover::f("to turn over") ; Fixes 1 word
:B0X*:to wakeup::f("to wake up") ; Fixes 1 word
:B0X*:to walkout::f("to walk out") ; Fixes 1 word
:B0X*:to wipeout::f("to wipe out") ; Fixes 1 word
:B0X*:to withdrew::f("to withdraw") ; Fixes 1 word
:B0X*:to workaround::f("to work around") ; Fixes 1 word
:B0X*:to workout::f("to work out") ; Fixes 1 word
:B0X*:today of::f("today or") ; Fixes 1 word
:B0X*:todays::f("today's") ; Fixes 1 word, but misspells todays (Could be legit if used poetically)
:B0X*:todya::f("today") ; Web Freq 241.36 | Fixes 2 words
:B0X*:toldt he::f("told the") ; Fixes 1 word
:B0X*:tolkein::f("Tolkien") ; Web Freq 1.78 | Fixes 2 words
:B0X*:tomatos::f("tomatoes") ; Web Freq 5.92 | Fixes 1 word
:B0X*:tommorrow::f("tomorrow") ; Web Freq 21.26 | Fixes 2 words
:B0X*:tomoor::f("tomorr") ; Web Freq 21.26 | Fixes 2 words
:B0X*:tomottow::f("tomorrow") ; Web Freq 21.26 | Fixes 2 words
:B0X*:tomror::f("tomorr") ; Web Freq 21.26 | Fixes 2 words
:B0X*:took affect::f("took effect") ; Fixes 1 word
:B0X*:took and interest::f("took an interest") ; Fixes 1 word
:B0X*:took awhile::f("took a while") ; Fixes 1 word
:B0X*:took over the reigns::f("took over the reins") ; Fixes 1 word
:B0X*:took the reigns::f("took the reins") ; Fixes 1 word
:B0X*:toolket::f("toolkit") ; Web Freq 5.92 | Fixes 2 words
:B0X*:torpeados::f("torpedoes") ; Web Freq 0.24 | Fixes 1 word
:B0X*:tortise::f("tortoise") ; Web Freq 1.44 | Fixes 4 words
:B0X*:tot he::f("to the") ; Fixes 1 word
:B0X*:traffice::f("trafficke") ; Web Freq 0.90 | Fixes 3 words
:B0X*:trafficing::f("trafficking") ; Web Freq 3.31 | Fixes 1 word
:B0X*:trancend::f("transcend") ; Web Freq 4.15 | Fixes 17 words
:B0X*:transcendan::f("transcenden") ; Web Freq 1.51 | Fixes 13 words
:B0X*:transend::f("transcend") ; Web Freq 4.15 | Fixes 17 words
:B0X*:transfered::f("transferred") ; Web Freq 11.02 | Fixes 1 word
:B0X*:transferin::f("transferrin") ; Web Freq 3.58 | Fixes 3 words
:B0X*:translater::f("translator") ; Web Freq 9.54 | Fixes 3 words
:B0X*:transpora::f("transporta") ; Web Freq 106.64 | Fixes 8 words
:B0X*:tremelo::f("tremolo") ; Web Freq 0.28 | Fixes 2 words
:B0X*:tresson::f("treason") ; Web Freq 1.30 | Fixes 8 words
:B0X*:triathalon::f("triathlon") ; Web Freq 2.12 | Fixes 2 words
:B0X*:tried to used::f("tried to use") ; Fixes 1 word
:B0X*:triguer::f("trigger") ; Web Freq 15.08 | Fixes 8 words
:B0X*:triolog::f("trilog") ; Web Freq 3.87 | Fixes 2 words
:B0X*:try and::f("try to") ; Fixes 1 word
:B0X*:tthe::f("the") ; Web Freq 27360.01 | Fixes 533 words
:B0X*:turn for the worst::f("turn for the worse") ; Fixes 1 word
:B0X*:tuscon::f("Tucson") ; Web Freq 8.14 | Fixes 1 word
:B0X*:tust::f("trust") ; Web Freq 93.10 | Fixes 42 words, but misspells Tustin (A city in California)
:B0X*:tution::f("tuition") ; Web Freq 9.91 | Fixes 3 words
:B0X*:twelth::f("twelfth") ; Web Freq 1.44 | Fixes 4 words
:B0X*:twelve month's::f("twelve months") ; Fixes 1 word
:B0X*:twice as much than::f("twice as much as") ; Fixes 1 word
:B0X*:two in a half::f("two and a half") ; Fixes 1 word
:B0X*:tyo::f("to") ; Web Freq 15535.85 | Fixes 1581 words
:B0X*:tyrany::f("tyranny") ; Web Freq 1.62 | Fixes 1 word
:B0X*:tyrrani::f("tyranni") ; Web Freq 0.39 | Fixes 23 words
:B0X*:tyrrany::f("tyranny") ; Web Freq 1.62 | Fixes 1 word
:B0X*:ubli::f("publi") ; Web Freq 711.01 | Fixes 37 words
:B0X*:uec::f("euc") ; Web Freq 5.83 | Fixes 39 words
:B0X*:ueg::f("eug") ; Web Freq 8.34 | Fixes 32 words
:B0X*:uel::f("eul") ; Web Freq 1.81 | Fixes 29 words
:B0X*:uep::f("eup") ; Web Freq 2.61 | Fixes 101 words
:B0X*:uer::f("eur") ; Web Freq 300.76 | Fixes 111 words
:B0X*:uet::f("eut") ; Web Freq 1.90 | Fixes 41 words
:B0X*:ukran::f("Ukrain") ; Web Freq 19.28 | Fixes 3 words
:B0X*:ulser::f("ulcer") ; Web Freq 3.39 | Fixes 15 words
:B0X*:unanym::f("unanim") ; Web Freq 5.69 | Fixes 8 words
:B0X*:unbeknowst::f("unbeknownst") ; Web Freq 0.17 | Fixes 1 word
:B0X*:under go::f("undergo") ; Web Freq 7.27 | Fixes 8 words
:B0X*:under it's::f("under its") ; Fixes 1 word
:B0X*:under rate::f("underrate") ; Web Freq 0.51 | Fixes 3 words
:B0X*:under take::f("undertake") ; Web Freq 15.09 | Fixes 5 words
:B0X*:under went::f("underwent") ; Web Freq 1.45 | Fixes 1 word
:B0X*:underat::f("underrat") ; Web Freq 0.51 | Fixes 4 words
:B0X*:undert he::f("under the") ; Fixes 1 word
:B0X*:undoubtely::f("undoubtedly") ; Web Freq 2.69 | Fixes 1 word
:B0X*:undreg::f("underg") ; Web Freq 42.43 | Fixes 33 words
:B0X*:unecessar::f("unnecessar") ; Web Freq 6.42 | Fixes 3 words
:B0X*:unequalit::f("inequalit") ; Web Freq 5.29 | Fixes 2 words
:B0X*:unevant::f("unevent") ; Web Freq 0.34 | Fixes 4 words
:B0X*:unihabit::f("uninhabit") ; Web Freq 0.36 | Fixes 6 words
:B0X*:unitedstates::f("United States") ; Fixes 1 word
:B0X*:unitesstates::f("United States") ; Fixes 1 word
:B0X*:univeral::f("universal") ; Web Freq 40.55 | Fixes 24 words
:B0X*:univerist::f("universit") ; Web Freq 330.26 | Fixes 2 words
:B0X*:univerit::f("universit") ; Web Freq 330.26 | Fixes 2 words
:B0X*:universti::f("universit") ; Web Freq 330.26 | Fixes 2 words
:B0X*:univesit::f("universit") ; Web Freq 330.26 | Fixes 2 words
:B0X*:unoperat::f("nonoperat") ; Web Freq 0.13 | Fixes 4 words
:B0X*:unotic::f("unnotic") ; Web Freq 0.79 | Fixes 4 words
:B0X*:unplease::f("displease") ; Web Freq 0.34 | Fixes 5 words
:B0X*:unuseable::f("unusable") ; Web Freq 0.61 | Fixes 2 words, but misspells unuseable (Uncommon spelling)
:B0X*:up field::f("upfield") ; Web Freq 0.04 | Fixes 1 word
:B0X*:up it's::f("up its") ; Fixes 1 word
:B0X*:up side::f("upside") ; Web Freq 2.92 | Fixes 2 words
:B0X*:upon it's::f("upon its") ; Fixes 1 word
:B0X*:usally::f("usually") ; Web Freq 94.48 | Fixes 1 word
:B0X*:use to::f("used to") ; Fixes 1 word
:B0X*:vacinit::f("vicinit") ; Web Freq 3.79 | Fixes 2 words
:B0X*:vaguar::f("vagar") ; Web Freq 0.22 | Fixes 4 words
:B0X*:vanella::f("vanilla") ; Web Freq 5.42 | Fixes 2 words
:B0X*:varit::f("variet") ; Web Freq 55.54 | Fixes 5 words
:B0X*:vehicule::f("vehicle") ; Web Freq 91.33 | Fixes 2 words
:B0X*:vengance::f("vengeance") ; Web Freq 2.27 | Fixes 2 words
:B0X*:vengence::f("vengeance") ; Web Freq 2.27 | Fixes 2 words
:B0X*:verfi::f("verifi") ; Web Freq 24.66 | Fixes 15 words
:B0X*:verior::f("varior") ; Web Freq 0.02 | Fixes 2 words
:B0X*:veriou::f("variou") ; Web Freq 91.63 | Fixes 4 words
:B0X*:vermillion::f("vermilion") ; Web Freq 0.70 | Fixes 4 words
:B0X*:versitilat::f("versatilit") ; Web Freq 1.59 | Fixes 2 words
:B0X*:versitlit::f("versatilit") ; Web Freq 1.59 | Fixes 2 words
:B0X*:vetwee::f("betwee") ; Web Freq 255.45 | Fixes 7 words
:B0X*:via it's::f("via its") ; Fixes 1 word
:B0X*:viathe::f("via the") ; Fixes 1 word
:B0X*:vigour::f("vigor") ; Web Freq 4.24 | Fixes 11 words, but misspells vigour (British spelling)
:B0X*:villian::f("villain") ; Web Freq 3.14 | Fixes 12 words
:B0X*:villifi::f("vilifi") ; Web Freq 0.22 | Fixes 6 words
:B0X*:villify::f("vilify") ; Web Freq 0.09 | Fixes 2 words
:B0X*:villin::f("villain") ; Web Freq 3.14 | Fixes 12 words
:B0X*:vincinit::f("vicinit") ; Web Freq 3.79 | Fixes 2 words
:B0X*:virutal::f("virtual") ; Web Freq 62.36 | Fixes 17 words
:B0X*:visabl::f("visibl") ; Web Freq 16.47 | Fixes 4 words
:B0X*:vise versa::f("vice versa") ; Fixes 1 word
:B0X*:vistor::f("visitor") ; Web Freq 64.03 | Fixes 2 words
:B0X*:vitor::f("victor") ; Web Freq 99.78 | Fixes 17 words
:B0X*:vocal chord::f("vocal cord") ; Fixes 1 word
:B0X*:voidemail::f("voicemail") ; Web Freq 1.73 | Fixes 2 words
:B0X*:voley::f("volley") ; Web Freq 8.40 | Fixes 8 words
:B0X*:volkswagon::f("Volkswagen") ; Web Freq 7.23 | Fixes 2 words
:B0X*:vriet::f("variet") ; Web Freq 55.54 | Fixes 5 words
:B0X*:wa snot::f("was not") ; Fixes 1 word
:B0X*:waived off::f("waved off") ; Fixes 1 word
:B0X*:wan tit::f("want it") ; Fixes 1 word
:B0X*:warantee::f("warranty") ; Web Freq 33.92 | Fixes 2 words
:B0X*:wardob::f("wardrob") ; Web Freq 4.06 | Fixes 4 words
:B0X*:warn away::f("worn away") ; Fixes 1 word
:B0X*:warn down::f("worn down") ; Fixes 1 word
:B0X*:warn out::f("worn out") ; Fixes 1 word
:B0X*:was apart of::f("was a part of") ; Fixes 1 word
:B0X*:was build::f("was built") ; Fixes 1 word
:B0X*:was cutoff::f("was cut off") ; Fixes 1 word
:B0X*:was do to::f("was due to") ; Fixes 1 word
:B0X*:was drank::f("was drunk") ; Fixes 1 word
:B0X*:was it's::f("was its") ; Fixes 1 word
:B0X*:was knew::f("was known") ; Fixes 1 word
:B0X*:was lain::f("was laid") ; Fixes 1 word
:B0X*:was laying on::f("was lying on") ; Fixes 1 word
:B0X*:was lead to::f("was led to") ; Fixes 1 word
:B0X*:was leaded by::f("was led by") ; Fixes 1 word
:B0X*:was loathe to::f("was loath to") ; Fixes 1 word
:B0X*:was loathed to::f("was loath to") ; Fixes 1 word
:B0X*:was meet by::f("was met by") ; Fixes 1 word
:B0X*:was meet with::f("was met with") ; Fixes 1 word
:B0X*:was mislead::f("was misled") ; Fixes 1 word
:B0X*:was rebuild::f("was rebuilt") ; Fixes 1 word
:B0X*:was release by::f("was released by") ; Fixes 1 word
:B0X*:was release on::f("was released on") ; Fixes 1 word
:B0X*:was reran::f("was rerun") ; Fixes 1 word
:B0X*:was sang::f("was sung") ; Fixes 1 word
:B0X*:was schedule to::f("was scheduled to") ; Fixes 1 word
:B0X*:was send::f("was sent") ; Fixes 1 word
:B0X*:was sentence to::f("was sentenced to") ; Fixes 1 word
:B0X*:was set-up::f("was set up") ; Fixes 1 word
:B0X*:was setup::f("was set up") ; Fixes 1 word
:B0X*:was shook::f("was shaken") ; Fixes 1 word
:B0X*:was shoot::f("was shot") ; Fixes 1 word
:B0X*:was show by::f("was shown by") ; Fixes 1 word
:B0X*:was show on::f("was shown on") ; Fixes 1 word
:B0X*:was showed::f("was shown") ; Fixes 1 word
:B0X*:was shut-off::f("was shut off") ; Fixes 1 word
:B0X*:was shutdown::f("was shut down") ; Fixes 1 word
:B0X*:was shutoff::f("was shut off") ; Fixes 1 word
:B0X*:was shutout::f("was shut out") ; Fixes 1 word
:B0X*:was sold-out::f("was sold out") ; Fixes 1 word
:B0X*:was spend::f("was spent") ; Fixes 1 word
:B0X*:was succeed by::f("was succeeded by") ; Fixes 1 word
:B0X*:was though that::f("was thought that") ; Fixes 1 word
:B0X*:wasnt::f("wasn't") ; Fixes 1 word
:B0X*:way side::f("wayside") ; Web Freq 0.65 | Fixes 2 words
:B0X*:wayword::f("wayward") ; Web Freq 0.67 | Fixes 4 words
:B0X*:we;d::f("we'd") ; Fixes 1 word
:B0X*:weaponar::f("weaponr") ; Web Freq 0.80 | Fixes 2 words
:B0X*:weekness::f("weakness") ; Web Freq 9.34 | Fixes 2 words
:B0X*:well know::f("well known") ; Fixes 1 word
:B0X*:wendsay::f("Wednesday") ; Web Freq 68.90 | Fixes 2 words
:B0X*:wensday::f("Wednesday") ; Web Freq 68.90 | Fixes 2 words
:B0X*:went rouge::f("went rogue") ; Fixes 1 word
:B0X*:went threw::f("went through") ; Fixes 1 word
:B0X*:were apart of::f("were a part of") ; Fixes 1 word
:B0X*:were began::f("were begun") ; Fixes 1 word
:B0X*:were cutoff::f("were cut off") ; Fixes 1 word
:B0X*:were drew::f("were drawn") ; Fixes 1 word
:B0X*:were he was::f("where he was") ; Fixes 1 word
:B0X*:were it was::f("where it was") ; Fixes 1 word
:B0X*:were it's::f("were its") ; Fixes 1 word
:B0X*:were knew::f("were known") ; Fixes 1 word
:B0X*:were know::f("were known") ; Fixes 1 word
:B0X*:were lain::f("were laid") ; Fixes 1 word
:B0X*:were loathe to::f("were loath to") ; Fixes 1 word
:B0X*:were meet by::f("were met by") ; Fixes 1 word
:B0X*:were meet with::f("were met with") ; Fixes 1 word
:B0X*:were overran::f("were overrun") ; Fixes 1 word
:B0X*:were reran::f("were rerun") ; Fixes 1 word
:B0X*:were sang::f("were sung") ; Fixes 1 word
:B0X*:were set-up::f("were set up") ; Fixes 1 word
:B0X*:were setup::f("were set up") ; Fixes 1 word
:B0X*:were she was::f("where she was") ; Fixes 1 word
:B0X*:were showed::f("were shown") ; Fixes 1 word
:B0X*:were shut-out::f("were shut out") ; Fixes 1 word
:B0X*:were shutdown::f("were shut down") ; Fixes 1 word
:B0X*:were shutoff::f("were shut off") ; Fixes 1 word
:B0X*:were shutout::f("were shut out") ; Fixes 1 word
:B0X*:were took::f("were taken") ; Fixes 1 word
:B0X*:werea::f("wherea") ; Web Freq 15.58 | Fixes 6 words
:B0X*:wern't::f("weren't") ; Fixes 1 word
:B0X*:wet your::f("whet your") ; Fixes 1 word
:B0X*:wether or not::f("whether or not") ; Fixes 1 word
:B0X*:what lead to::f("what led to") ; Fixes 1 word
:B0X*:what lied::f("what lay") ; Fixes 1 word
:B0X*:whenhe::f("whethe") ; Web Freq 105.01 | Fixes 1 word ; will it break "when he"?
:B0X*:whent he::f("when the") ; Fixes 1 word
:B0X*:wheras::f("whereas") ; Web Freq 14.66 | Fixes 2 words
:B0X*:where being::f("were being") ; Fixes 1 word
:B0X*:where by::f("whereby") ; Web Freq 3.65 | Fixes 1 word
:B0X*:where him::f("where he") ; Fixes 1 word
:B0X*:where made::f("were made") ; Fixes 1 word
:B0X*:where taken::f("were taken") ; Fixes 1 word
:B0X*:where upon::f("whereupon") ; Web Freq 0.62 | Fixes 1 word
:B0X*:where won::f("were won") ; Fixes 1 word
:B0X*:whereever::f("wherever") ; Web Freq 6.76 | Fixes 1 word
:B0X*:whetev::f("whatev") ; Web Freq 31.96 | Fixes 3 words
:B0X*:whether permit::f("weather permit") ; Fixes 1 word
:B0X*:which had lead::f("which had led") ; Fixes 1 word
:B0X*:which has lead::f("which has led") ; Fixes 1 word
:B0X*:which have lead::f("which have led") ; Fixes 1 word
:B0X*:which where::f("which were") ; Fixes 1 word
:B0X*:whicht he::f("which the") ; Fixes 1 word
:B0X*:while him::f("while he") ; Fixes 1 word
:B0X*:who had lead::f("who had led") ; Fixes 1 word
:B0X*:who has lead::f("who has led") ; Fixes 1 word
:B0X*:who have lead::f("who have led") ; Fixes 1 word
:B0X*:who setup::f("who set up") ; Fixes 1 word
:B0X*:who where::f("who were") ; Fixes 1 word
:B0X*:who's actual::f("whose actual") ; Fixes 1 word
:B0X*:who's brother::f("whose brother") ; Fixes 1 word
:B0X*:who's father::f("whose father") ; Fixes 1 word
:B0X*:who's mother::f("whose mother") ; Fixes 1 word
:B0X*:who's name::f("whose name") ; Fixes 1 word
:B0X*:who's opinion::f("whose opinion") ; Fixes 1 word
:B0X*:who's own::f("whose own") ; Fixes 1 word
:B0X*:who's parents::f("whose parents") ; Fixes 1 word
:B0X*:who's previous::f("whose previous") ; Fixes 1 word
:B0X*:who's team::f("whose team") ; Fixes 1 word
:B0X*:wholey::f("wholly") ; Web Freq 4.49 | Fixes 1 word
:B0X*:wholy::f("wholly") ; Web Freq 4.49 | Fixes 1 word
:B0X*:whould::f("would") ; Web Freq 572.87 | Fixes 6 words
:B0X*:whther::f("whether") ; Web Freq 105.01 | Fixes 1 word
:B0X*:widesread::f("widespread") ; Web Freq 6.25 | Fixes 3 words
:B0X*:wihch::f("which") ; Web Freq 813.75 | Fixes 3 words
:B0X*:wihh::f("withh") ; Web Freq 6.26 | Fixes 7 words
:B0X*:will backup::f("will back up") ; Fixes 1 word
:B0X*:will buyout::f("will buy out") ; Fixes 1 word
:B0X*:will shutdown::f("will shut down") ; Fixes 1 word
:B0X*:will shutoff::f("will shut off") ; Fixes 1 word
:B0X*:willbe::f("will be") ; Fixes 1 word
:B0X*:wirrd::f("weird") ; Web Freq 24.73 | Fixes 17 words
:B0X*:with be::f("will be") ; Fixes 1 word
:B0X*:with it's::f("with its") ; Fixes 1 word
:B0X*:with out::f("without") ; Web Freq 219.19 | Fixes 4 words
:B0X*:with regards to::f("with regard to") ; Fixes 1 word
:B0X*:witheld::f("withheld") ; Web Freq 2.69 | Fixes 1 word
:B0X*:withi t::f("with it") ; Fixes 1 word
:B0X*:within it's::f("within its") ; Fixes 1 word
:B0X*:within site of::f("within sight of") ; Fixes 1 word
:B0X*:witht he::f("with the") ; Fixes 1 word
:B0X*:wno::f("sno") ; Web Freq 115.80 | Fixes 249 words
:B0X*:won it's::f("won its") ; Fixes 1 word
:B0X*:wordlwide::f("worldwide") ; Web Freq 61.32 | Fixes 2 words
:B0X*:working progress::f("work in progress") ; Fixes 1 word
:B0X*:world wide::f("worldwide") ; Web Freq 61.32 | Fixes 2 words
:B0X*:worng::f("wrong") ; Web Freq 54.65 | Fixes 22 words
:B0X*:worse comes to worse::f("worse comes to worst") ; Fixes 1 word
:B0X*:worse then::f("worse than") ; Fixes 1 word
:B0X*:worse-case scenario::f("worst-case scenario") ; Fixes 1 word
:B0X*:worst comes to worst::f("worse comes to worst") ; Fixes 1 word
:B0X*:worst than::f("worse than") ; Fixes 1 word
:B0X*:worsten::f("worsen") ; Web Freq 1.95 | Fixes 5 words
:B0X*:worth it's::f("worth its") ; Fixes 1 word
:B0X*:woudl::f("would") ; Web Freq 572.87 | Fixes 6 words
:B0X*:would backup::f("would back up") ; Fixes 1 word
:B0X*:would comeback::f("would come back") ; Fixes 1 word
:B0X*:would fair::f("would fare") ; Fixes 1 word
:B0X*:would forego::f("would forgo") ; Fixes 1 word
:B0X*:would setup::f("would set up") ; Fixes 1 word
:B0X*:wouldbe::f("would be") ; Fixes 1 word
:B0X*:wreck havoc::f("wreak havoc") ; Fixes 1 word
:B0X*:wreckless::f("reckless") ; Web Freq 1.93 | Fixes 4 words
:B0X*:write answer::f("right answer") ; Fixes 1 word
:B0X*:write call::f("right call") ; Fixes 1 word
:B0X*:write choice::f("right choice") ; Fixes 1 word
:B0X*:write conclusion::f("right conclusion") ; Fixes 1 word
:B0X*:write decision::f("right decision") ; Fixes 1 word
:B0X*:write direction::f("right direction") ; Fixes 1 word
:B0X*:write idea::f("right idea") ; Fixes 1 word
:B0X*:write moment::f("right moment") ; Fixes 1 word
:B0X*:write move::f("right move") ; Fixes 1 word
:B0X*:writers block::f("writer's block") ; Fixes 1 word
:B0X*:wront::f("wrong") ; Web Freq 54.65 | Fixes 22 words
:B0X*:xome::f("some") ; Web Freq 879.43 | Fixes 43 words
:B0X*:xoom::f("zoom") ; Web Freq 65.68 | Fixes 24 words
:B0X*:yatch::f("yacht") ; Web Freq 10.16 | Fixes 16 words
:B0X*:year old::f("year-old") ; Fixes 1 word
:B0X*:yelow::f("yellow") ; Web Freq 86.23 | Fixes 30 words
:B0X*:yera::f("year") ; Web Freq 799.38 | Fixes 20 words
:B0X*:yhou::f("thou") ; Web Freq 283.72 | Fixes 22 words
:B0X*:yotube::f("youtube") ; Web Freq 0.12 | Fixes 4 words
:B0X*:you're own::f("your own") ; Fixes 1 word
:B0X*:you;d::f("you'd") ; Fixes 1 word
:B0X*:youare::f("you are") ; Fixes 1 word
:B0X*:yould::f("would") ; Web Freq 572.87 | Fixes 6 words
:B0X*:your their::f("you're their") ; Fixes 1 word
:B0X*:your your::f("you're your") ; Fixes 1 word
:B0X*:youself::f("yourself") ; Web Freq 51.53 | Fixes 1 word
:B0X*:yrea::f("year") ; Web Freq 799.38 | Fixes 20 words
:B0X*:yri::f("tri") ; Web Freq 461.48 | Fixes 918 words
:B0X*?:0n0::f("-n-") ; Fixes 1 word For this-n-that
:B0X*?:a;;::f("all") ; Web Freq 6331.59 | Fixes 5105 words
:B0X*?:aall::f("all") ; Web Freq 6331.59 | Fixes 5105 words
:B0X*?:abaila::f("availa") ; Web Freq 470.73 | Fixes 18 words
:B0X*?:abaptiv::f("adaptiv") ; Web Freq 5.98 | Fixes 10 words
:B0X*?:abberr::f("aberr") ; Web Freq 1.47 | Fixes 23 words
:B0X*?:abbout::f("about") ; Web Freq 1229.89 | Fixes 41 words
:B0X*?:abck::f("back") ; Web Freq 937.85 | Fixes 591 words
:B0X*?:abilt::f("abilit") ; Web Freq 397.95 | Fixes 1267 words
:B0X*?:abinn::f("abbin") ; Web Freq 3.11 | Fixes 44 words
:B0X*?:ablilit::f("abilit") ; Web Freq 397.95 | Fixes 1267 words
:B0X*?:ablit::f("abilit") ; Web Freq 397.95 | Fixes 1267 words
:B0X*?:aboid::f("avoid") ; Web Freq 51.66 | Fixes 15 words, but misspells aboideau (French dam), scaraboid (Egyptian bug)
:B0X*?:abolision::f("abolition") ; Web Freq 1.53 | Fixes 7 words
:B0X*?:abrit::f("arbit") ; Web Freq 18.17 | Fixes 62 words
:B0X*?:abser::f("obser") ; Web Freq 87.34 | Fixes 53 words
:B0X*?:abuda::f("abunda") ; Web Freq 9.36 | Fixes 15 words
:B0X*?:academci::f("academic") ; Web Freq 63.00 | Fixes 16 words
:B0X*?:acadm::f("academ") ; Web Freq 96.82 | Fixes 36 words
:B0X*?:accach::f("attach") ; Web Freq 65.31 | Fixes 25 words
:B0X*?:accadem::f("academ") ; Web Freq 96.82 | Fixes 36 words
:B0X*?:acccu::f("accu") ; Web Freq 97.94 | Fixes 111 words
:B0X*?:acceller::f("acceler") ; Web Freq 19.06 | Fixes 28 words
:B0X*?:accelora::f("accelera") ; Web Freq 18.58 | Fixes 24 words
:B0X*?:accensi::f("ascensi") ; Web Freq 3.65 | Fixes 7 words
:B0X*?:acceptib::f("acceptab") ; Web Freq 18.70 | Fixes 11 words
:B0X*?:accessab::f("accessib") ; Web Freq 38.84 | Fixes 15 words
:B0X*?:accoc::f("assoc") ; Web Freq 277.49 | Fixes 55 words
:B0X*?:accomadat::f("accommodat") ; Web Freq 81.88 | Fixes 25 words
:B0X*?:accomo::f("accommo") ; Web Freq 81.88 | Fixes 25 words
:B0X*?:accoring::f("according") ; Web Freq 81.51 | Fixes 3 words
:B0X*?:accosi::f("associ") ; Web Freq 272.83 | Fixes 43 words
:B0X*?:accoud::f("accord") ; Web Freq 114.77 | Fixes 21 words
:B0X*?:accous::f("acous") ; Web Freq 14.52 | Fixes 17 words
:B0X*?:accqu::f("acqu") ; Web Freq 70.59 | Fixes 110 words
:B0X*?:accro::f("acro") ; Web Freq 131.54 | Fixes 216 words, but misspells Accroides (a type of resin from Australian grass trees)
:B0X*?:accuss::f("accus") ; Web Freq 16.18 | Fixes 54 words
:B0X*?:acede::f("acade") ; Web Freq 98.30 | Fixes 40 words
:B0X*?:achiv::f("achiev") ; Web Freq 75.67 | Fixes 40 words
:B0X*?:aciden::f("acciden") ; Web Freq 34.53 | Fixes 11 words
:B0X*?:acocu::f("accou") ; Web Freq 315.21 | Fixes 42 words
:B0X*?:acommo::f("accommo") ; Web Freq 81.88 | Fixes 25 words
:B0X*?:acomo::f("accommo") ; Web Freq 81.88 | Fixes 25 words, but misspells Giacomo (Italian name similar to James)
:B0X*?:acord::f("accord") ; Web Freq 114.77 | Fixes 21 words
:B0X*?:acquainten::f("acquaintan") ; Web Freq 2.02 | Fixes 6 words
:B0X*?:acquianten::f("acquaintan") ; Web Freq 2.02 | Fixes 6 words
:B0X*?:actaul::f("actual") ; Web Freq 120.00 | Fixes 40 words
:B0X*?:actem::f("actm") ; Web Freq 2.65 | Fixes 4 words
:B0X*?:actial::f("actical") ; Web Freq 40.65 | Fixes 35 words
:B0X*?:actival::f("actical") ; Web Freq 40.65 | Fixes 35 words
:B0X*?:acurac::f("accurac") ; Web Freq 34.61 | Fixes 4 words
:B0X*?:acustom::f("accustom") ; Web Freq 1.82 | Fixes 20 words
:B0X*?:acutal::f("actual") ; Web Freq 120.00 | Fixes 40 words
:B0X*?:acuua::f("actua") ; Web Freq 126.38 | Fixes 53 words
:B0X*?:adantag::f("advantag") ; Web Freq 55.75 | Fixes 18 words
:B0X*?:adaptib::f("adaptab") ; Web Freq 1.68 | Fixes 9 words
:B0X*?:adaption::f("adaptation") ; Web Freq 6.69 | Fixes 17 words
:B0X*?:adavan::f("advan") ; Web Freq 291.88 | Fixes 33 words
:B0X*?:addion::f("addition") ; Web Freq 226.05 | Fixes 9 words
:B0X*?:addm::f("adm") ; Web Freq 298.43 | Fixes 212 words
:B0X*?:addop::f("adop") ; Web Freq 61.20 | Fixes 47 words
:B0X*?:addow::f("adow") ; Web Freq 33.38 | Fixes 56 words
:B0X*?:addression::f("aggression") ; Web Freq 2.61 | Fixes 9 words
:B0X*?:adequite::f("adequate") ; Web Freq 24.67 | Fixes 8 words
:B0X*?:adif::f("atif") ; Web Freq 7.86 | Fixes 60 words, but misspells Gadiformes (Cods, haddocks, grenadiers; in some classifications considered equivalent to the order Anacanthini)
:B0X*?:adiqua::f("adequa") ; Web Freq 27.35 | Fixes 12 words
:B0X*?:admend::f("amend") ; Web Freq 70.33 | Fixes 15 words
:B0X*?:admissab::f("admissib") ; Web Freq 1.93 | Fixes 9 words
:B0X*?:admited::f("admitted") ; Web Freq 10.13 | Fixes 6 words
:B0X*?:adquate::f("adequate") ; Web Freq 24.67 | Fixes 8 words
:B0X*?:adquir::f("acquir") ; Web Freq 27.36 | Fixes 16 words
:B0X*?:aduust::f("adjust") ; Web Freq 57.36 | Fixes 45 words
:B0X*?:advanag::f("advantag") ; Web Freq 55.75 | Fixes 18 words
:B0X*?:adventr::f("adventur") ; Web Freq 52.32 | Fixes 31 words
:B0X*?:advertant::f("advertent") ; Web Freq 1.56 | Fixes 4 words
:B0X*?:adves::f("advers") ; Web Freq 16.53 | Fixes 19 words
:B0X*?:adviced::f("advised") ; Web Freq 9.47 | Fixes 8 words
:B0X*?:advixed::f("advised") ; Web Freq 9.47 | Fixes 8 words
:B0X*?:aelog::f("aeolog") ; Web Freq 9.16 | Fixes 12 words
:B0X*?:aerch::f("earch") ; Web Freq 1477.37 | Fixes 43 words
:B0X*?:aeriel::f("aerial") ; Web Freq 7.26 | Fixes 9 words
:B0X*?:affilat::f("affiliat") ; Web Freq 94.74 | Fixes 18 words
:B0X*?:affilliat::f("affiliat") ; Web Freq 94.74 | Fixes 18 words
:B0X*?:affort::f("afford") ; Web Freq 44.28 | Fixes 15 words
:B0X*?:affraid::f("afraid") ; Web Freq 11.02 | Fixes 4 words
:B0X*?:afged::f("agged") ; Web Freq 20.23 | Fixes 69 words
:B0X*?:afoer::f("afore") ; Web Freq 2.99 | Fixes 10 words
:B0X*?:agail::f("avail") ; Web Freq 476.02 | Fixes 38 words
:B0X*?:aggree::f("agree") ; Web Freq 229.06 | Fixes 34 words
:B0X*?:agrava::f("aggrava") ; Web Freq 2.67 | Fixes 9 words
:B0X*?:agreg::f("aggreg") ; Web Freq 17.93 | Fixes 31 words
:B0X*?:agress::f("aggress") ; Web Freq 12.24 | Fixes 30 words
:B0X*?:ahev::f("have") ; Web Freq 1610.90 | Fixes 70 words
:B0X*?:ahpp::f("happ") ; Web Freq 167.19 | Fixes 55 words
:B0X*?:ahve::f("have") ; Web Freq 1610.90 | Fixes 70 words, but misspells Ahvenanmaa, Jahvey, Wahvey, Yahve, Yahveh (All are different Hebrew names for God.)
:B0X*?:aible::f("able") ; Web Freq 1820.58 | Fixes 3120 words
:B0X*?:aicraft::f("aircraft") ; Web Freq 24.82 | Fixes 7 words
:B0X*?:ailabe::f("ailable") ; Web Freq 389.37 | Fixes 16 words
:B0X*?:ailiab::f("ailab") ; Web Freq 470.89 | Fixes 34 words
:B0X*?:ailib::f("ailab") ; Web Freq 470.89 | Fixes 34 words
:B0X*?:aiotn::f("ation") ; Web Freq 8408.91 | Fixes 6209 words
:B0X*?:airbourn::f("airborn") ; Web Freq 3.35 | Fixes 1 word 
:B0X*?:airts::f("airst") ; Web Freq 3.04 | Fixes 18 words, but misspells Airts (Scottish word representing the directions on a compass)
:B0X*?:aisian::f("Asian") ; Web Freq 72.52 | Fixes 18 words, but misspells Rabelaisian (of or relating to or characteristic of Francois Rabelais or his works)
:B0X*?:aiton::f("ation") ; Web Freq 8408.91 | Fixes 6209 words
:B0X*?:akeng::f("aking") ; Web Freq 290.26 | Fixes 209 words
:B0X*?:akse::f("akes") ; Web Freq 218.39 | Fixes 152 words
:B0X*?:alamm::f("alarm") ; Web Freq 23.96 | Fixes 17 words
:B0X*?:albiet::f("albeit") ; Web Freq 2.48 | Fixes 1 word
:B0X*?:alchohol::f("alcohol") ; Web Freq 32.71 | Fixes 34 words
:B0X*?:alchol::f("alcohol") ; Web Freq 32.71 | Fixes 34 words
:B0X*?:alcohal::f("alcohol") ; Web Freq 32.71 | Fixes 34 words
:B0X*?:aleld::f("alled") ; Web Freq 148.10 | Fixes 97 words
:B0X*?:alell::f("allel") ; Web Freq 26.02 | Fixes 72 words
:B0X*?:aliab::f("ailab") ; Web Freq 470.89 | Fixes 34 words
:B0X*?:alibit::f("abilit") ; Web Freq 397.95 | Fixes 1267 words
:B0X*?:alientat::f("alienat") ; Web Freq 2.14 | Fixes 9 words
:B0X*?:aligib::f("eligib") ; Web Freq 48.52 | Fixes 15 words
:B0X*?:aligy::f("alify") ; Web Freq 16.18 | Fixes 15 words
:B0X*?:alitv::f("lativ") ; Web Freq 86.02 | Fixes 118 words
:B0X*?:alledg::f("alleg") ; Web Freq 26.96 | Fixes 51 words
:B0X*?:allivi::f("allevi") ; Web Freq 2.99 | Fixes 13 words
:B0X*?:allta::f("alta") ; Web Freq 19.11 | Fixes 31 words
:B0X*?:allte::f("alte") ; Web Freq 139.27 | Fixes 155 words
:B0X*?:allth::f("alth") ; Web Freq 632.28 | Fixes 68 words
:B0X*?:allts::f("alts") ; Web Freq 3.09 | Fixes 21 words
:B0X*?:alochol::f("alcohol") ; Web Freq 32.71 | Fixes 34 words
:B0X*?:alott::f("allott") ; Web Freq 1.30 | Fixes 14 words, but misspells Shalott (An uncommon name), Calotte (French for "skullcap")
:B0X*?:alowe::f("allowe") ; Web Freq 58.46 | Fixes 30 words
:B0X*?:alrrm::f("alarm") ; Web Freq 23.96 | Fixes 17 words
:B0X*?:alsay::f("alway") ; Web Freq 130.41 | Fixes 4 words
:B0X*?:alsitic::f("alistic") ; Web Freq 15.81 | Fixes 118 words
:B0X*?:altion::f("lation") ; Web Freq 657.01 | Fixes 580 words
:B0X*?:aluz::f("alyz") ; Web Freq 27.83 | Fixes 62 words
:B0X*?:alyl::f("ally") ; Web Freq 1140.29 | Fixes 2694 words
:B0X*?:amange::f("manage") ; Web Freq 494.31 | Fixes 57 words
:B0X*?:ameria::f("America") ; Web Freq 403.10 | Fixes 28 words
:B0X*?:amerli::f("ameli") ; Web Freq 3.24 | Fixes 48 words
:B0X*?:ametal::f("amental") ; Web Freq 28.04 | Fixes 34 words
:B0X*?:aminter::f("aminer") ; Web Freq 5.90 | Fixes 10 words
:B0X*?:amke::f("make") ; Web Freq 575.40 | Fixes 190 words
:B0X*?:amking::f("making") ; Web Freq 132.19 | Fixes 73 words
:B0X*?:ammm::f("amm") ; Web Freq 311.41 | Fixes 623 words
:B0X*?:ammn::f("amen") ; Web Freq 224.09 | Fixes 246 words
:B0X*?:ammou::f("amou") ; Web Freq 168.49 | Fixes 116 words
:B0X*?:amny::f("many") ; Web Freq 411.58 | Fixes 9 words
:B0X*?:amouro::f("amoro") ; Web Freq 1.67 | Fixes 21 words, but misspells glamourous (British spelling)
:B0X*?:ampel::f("ample") ; Web Freq 279.80 | Fixes 45 words, but misspells ampelopsis (A type of vine)
:B0X*?:analitic::f("analytic") ; Web Freq 15.70 | Fixes 20 words
:B0X*?:anbd::f("and") ; Web Freq 16443.74 | Fixes 2777 words
:B0X*?:anciet::f("anxiet") ; Web Freq 10.02 | Fixes 5 words
:B0X*?:ancles::f("acles") ; Web Freq 9.33 | Fixes 25 words
:B0X*?:andici::f("antici") ; Web Freq 17.12 | Fixes 58 words
:B0X*?:aneing::f("aning") ; Web Freq 77.37 | Fixes 74 words
:B0X*?:angeing::f("anging") ; Web Freq 59.50 | Fixes 51 words
:B0X*?:angeng::f("anging") ; Web Freq 59.50 | Fixes 51 words
:B0X*?:anmd::f("and") ; Web Freq 16443.74 | Fixes 2777 words
:B0X*?:annn::f("ann") ; Web Freq 892.28 | Fixes 877 words
:B0X*?:annod::f("anod") ; Web Freq 2.62 | Fixes 37 words
:B0X*?:annoe::f("anoe") ; Web Freq 8.78 | Fixes 44 words
:B0X*?:annoi::f("anoi") ; Web Freq 6.39 | Fixes 56 words
:B0X*?:annom::f("anom") ; Web Freq 8.03 | Fixes 58 words
:B0X*?:annora::f("anora") ; Web Freq 7.11 | Fixes 11 words
:B0X*?:anomo::f("anoma") ; Web Freq 6.65 | Fixes 23 words
:B0X*?:anoun::f("announ") ; Web Freq 111.91 | Fixes 13 words
:B0X*?:ansiet::f("anxiet") ; Web Freq 10.02 | Fixes 5 words
:B0X*?:antaine::f("antine") ; Web Freq 7.95 | Fixes 38 words
:B0X*?:antartic::f("antarctic") ; Web Freq 10.67 | Fixes 4 words
:B0X*?:anthrom::f("anthropom") ; Web Freq 0.41 | Fixes 31 words
:B0X*?:antohe::f("anothe") ; Web Freq 192.54 | Fixes 4 words
:B0X*?:anwser::f("answer") ; Web Freq 137.35 | Fixes 23 words
:B0X*?:anyicipat::f("anticipat") ; Web Freq 15.72 | Fixes 14 words
:B0X*?:anythe::f("anothe") ; Web Freq 192.54 | Fixes 4 words
:B0X*?:aost::f("oast") ; Web Freq 93.11 | Fixes 99 words
:B0X*?:aouut::f("about") ; Web Freq 1229.89 | Fixes 41 words
:B0X*?:aparen::f("apparen") ; Web Freq 25.47 | Fixes 11 words
:B0X*?:apear::f("appear") ; Web Freq 139.70 | Fixes 26 words
:B0X*?:apeea::f("appea") ; Web Freq 186.90 | Fixes 62 words
:B0X*?:aplic::f("applic") ; Web Freq 322.33 | Fixes 25 words
:B0X*?:aplie::f("applie") ; Web Freq 61.79 | Fixes 15 words
:B0X*?:apoint::f("appoint") ; Web Freq 60.29 | Fixes 34 words . Misspells username Datapoint.
:B0X*?:appand::f("append") ; Web Freq 30.53 | Fixes 25 words
:B0X*?:apparan::f("apparen") ; Web Freq 25.47 | Fixes 11 words
:B0X*?:appart::f("apart") ; Web Freq 88.21 | Fixes 17 words
:B0X*?:appeares::f("appears") ; Web Freq 34.65 | Fixes 4 words
:B0X*?:appearr::f("appear") ; Web Freq 139.70 | Fixes 26 words
:B0X*?:appera::f("appeara") ; Web Freq 22.76 | Fixes 8 words
:B0X*?:appol::f("apol") ; Web Freq 58.18 | Fixes 80 words
:B0X*?:apprear::f("appear") ; Web Freq 139.70 | Fixes 26 words
:B0X*?:apreh::f("appreh") ; Web Freq 2.26 | Fixes 27 words
:B0X*?:apropr::f("appropr") ; Web Freq 97.06 | Fixes 36 words
:B0X*?:aprov::f("approv") ; Web Freq 107.24 | Fixes 33 words
:B0X*?:aptue::f("apture") ; Web Freq 32.72 | Fixes 16 words
:B0X*?:apuur::f("aptur") ; Web Freq 36.00 | Fixes 26 words
:B0X*?:aquai::f("acquai") ; Web Freq 3.99 | Fixes 22 words
:B0X*?:aquian::f("acquain") ; Web Freq 3.99 | Fixes 22 words
:B0X*?:aquisi::f("acquisi") ; Web Freq 24.56 | Fixes 15 words
:B0X*?:arange::f("arrange") ; Web Freq 50.56 | Fixes 27 words
:B0X*?:aratte::f("aracte") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:arbitar::f("arbitrar") ; Web Freq 7.64 | Fixes 9 words
:B0X*?:archao::f("archeo") ; Web Freq 1.72 | Fixes 13 words
:B0X*?:archetect::f("architect") ; Web Freq 71.50 | Fixes 24 words
:B0X*?:architectual::f("architectural") ; Web Freq 10.46 | Fixes 4 words
:B0X*?:areat::f("arat") ; Web Freq 178.32 | Fixes 172 words
:B0X*?:arhip::f("arship") ; Web Freq 25.08 | Fixes 12 words
:B0X*?:ariage::f("arriage") ; Web Freq 41.58 | Fixes 28 words
:B0X*?:arima::f("airma") ; Web Freq 33.74 | Fixes 19 words, but misspells Arimathea (A place in the Bible)
:B0X*?:arogen::f("arrogan") ; Web Freq 2.56 | Fixes 8 words
:B0X*?:arrern::f("attern") ; Web Freq 61.51 | Fixes 21 words
:B0X*?:artdri::f("artri") ; Web Freq 29.18 | Fixes 6 words
:B0X*?:articel::f("article") ; Web Freq 357.55 | Fixes 18 words
:B0X*?:artrige::f("artridge") ; Web Freq 29.18 | Fixes 6 words
:B0X*?:asdver::f("adver") ; Web Freq 268.22 | Fixes 75 words
:B0X*?:asemm::f("asem") ; Web Freq 10.43 | Fixes 34 words
:B0X*?:asnd::f("and") ; Web Freq 16443.74 | Fixes 2777 words
:B0X*?:asnio::f("ansio") ; Web Freq 27.18 | Fixes 17 words
:B0X*?:asociat::f("associat") ; Web Freq 272.83 | Fixes 39 words
:B0X*?:asorb::f("absorb") ; Web Freq 10.66 | Fixes 43 words
:B0X*?:assempl::f("assembl") ; Web Freq 52.59 | Fixes 44 words
:B0X*?:assept::f("accept") ; Web Freq 160.33 | Fixes 42 words
:B0X*?:assertation::f("assertion") ; Web Freq 4.28 | Fixes 6 words
:B0X*?:assesm::f("assessm") ; Web Freq 69.49 | Fixes 6 words
:B0X*?:assoca::f("associa") ; Web Freq 272.83 | Fixes 43 words
:B0X*?:asss::f("ass") ; Web Freq 2266.13 | Fixes 1763 words
:B0X*?:assualt::f("assault") ; Web Freq 22.16 | Fixes 13 words
:B0X*?:assym::f("asym") ; Web Freq 5.88 | Fixes 17 words
:B0X*?:asthet::f("aesthet") ; Web Freq 6.45 | Fixes 49 words
:B0X*?:astsd::f("asted") ; Web Freq 17.55 | Fixes 66 words
:B0X*?:asue::f("ause") ; Web Freq 422.69 | Fixes 83 words, but misspells Ultrasuede (a synthetic suede cloth)
:B0X*?:atain::f("attain") ; Web Freq 10.91 | Fixes 30 words
:B0X*?:atedg::f("ating") ; Web Freq 830.02 | Fixes 1341 words
:B0X*?:ateing::f("ating") ; Web Freq 830.02 | Fixes 1341 words
:B0X*?:atempt::f("attempt") ; Web Freq 51.90 | Fixes 11 words
:B0X*?:atention::f("attention") ; Web Freq 45.39 | Fixes 7 words
:B0X*?:athce::f("atche") ; Web Freq 156.00 | Fixes 176 words
:B0X*?:athori::f("authori") ; Web Freq 147.33 | Fixes 57 words
:B0X*?:aticula::f("articula") ; Web Freq 124.93 | Fixes 80 words
:B0X*?:ationna::f("ationa") ; Web Freq 1085.77 | Fixes 508 words
:B0X*?:atoin::f("ation") ; Web Freq 8408.91 | Fixes 6209 words
:B0X*?:atrea::f("atera") ; Web Freq 18.92 | Fixes 94 words
:B0X*?:atribut::f("attribut") ; Web Freq 41.46 | Fixes 32 words
:B0X*?:attachem::f("attachm") ; Web Freq 28.24 | Fixes 6 words
:B0X*?:attand::f("attend") ; Web Freq 67.38 | Fixes 23 words
:B0X*?:attech::f("attach") ; Web Freq 65.31 | Fixes 25 words
:B0X*?:attemt::f("attempt") ; Web Freq 51.90 | Fixes 11 words
:B0X*?:attenden::f("attendan") ; Web Freq 17.72 | Fixes 7 words
:B0X*?:attensi::f("attenti") ; Web Freq 47.09 | Fixes 20 words
:B0X*?:attentan::f("attendan") ; Web Freq 17.72 | Fixes 7 words
:B0X*?:attentioin::f("attention") ; Web Freq 45.39 | Fixes 7 words
:B0X*?:attmpt::f("attempt") ; Web Freq 51.90 | Fixes 11 words
:B0X*?:attro::f("atro") ; Web Freq 24.22 | Fixes 150 words, but misspells quattrocento (15th century in Italian art and literature)
:B0X*?:auclar::f("acular") ; Web Freq 12.54 | Fixes 37 words
:B0X*?:audiance::f("audience") ; Web Freq 29.37 | Fixes 4 words
:B0X*?:auise::f("ause") ; Web Freq 422.69 | Fixes 83 words
:B0X*?:auoo::f("auto") ; Web Freq 294.52 | Fixes 443 words
:B0X*?:auot::f("auto") ; Web Freq 294.52 | Fixes 443 words
:B0X*?:auromat::f("automat") ; Web Freq 95.43 | Fixes 42 words
:B0X*?:aurra::f("aura") ; Web Freq 125.25 | Fixes 41 words
:B0X*?:auther::f("author") ; Web Freq 384.99 | Fixes 75 words
:B0X*?:authobiograph::f("autobiograph") ; Web Freq 4.21 | Fixes 8 words
:B0X*?:autit::f("audit") ; Web Freq 51.68 | Fixes 33 words
:B0X*?:autochto::f("autochtho") ; Web Freq 0.05 | Fixes 10 words
:B0X*?:autocoore::f("autocorre") ; Web Freq 0.46 | Fixes 6 words
:B0X*?:automonom::f("autonom") ; Web Freq 7.83 | Fixes 13 words
:B0X*?:autorit::f("authorit") ; Web Freq 84.13 | Fixes 15 words
:B0X*?:avaialb::f("availab") ; Web Freq 470.73 | Fixes 18 words
:B0X*?:availb::f("availab") ; Web Freq 470.73 | Fixes 18 words
:B0X*?:avalab::f("availab") ; Web Freq 470.73 | Fixes 18 words
:B0X*?:avalib::f("availab") ; Web Freq 470.73 | Fixes 18 words
:B0X*?:aveing::f("aving") ; Web Freq 205.09 | Fixes 76 words
:B0X*?:avila::f("availa") ; Web Freq 470.73 | Fixes 18 words
:B0X*?:avle::f("avel") ; Web Freq 367.35 | Fixes 146 words
:B0X*?:avove::f("above") ; Web Freq 142.21 | Fixes 7 words
:B0X*?:awaye::f("aware") ; Web Freq 67.94 | Fixes 22 words
:B0X*?:awess::f("awless") ; Web Freq 2.72 | Fixes 13 words
:B0X*?:babilat::f("babilit") ; Web Freq 15.28 | Fixes 21 words
:B0X*?:ballan::f("balan") ; Web Freq 106.50 | Fixes 49 words, but misspells Ballantine (A name and a whiskey)
:B0X*?:ballt::f("balt") ; Web Freq 29.97 | Fixes 23 words
:B0X*?:baly::f("bally") ; Web Freq 5.25 | Fixes 16 words
:B0X*?:baou::f("abou") ; Web Freq 1276.75 | Fixes 97 words
:B0X*?:basksp::f("backsp") ; Web Freq 0.66 | Fixes 12 words
:B0X*?:bateabl::f("batabl") ; Web Freq 0.39 | Fixes 6 words
:B0X*?:bcak::f("back") ; Web Freq 937.85 | Fixes 591 words
:B0X*?:beaav::f("behav") ; Web Freq 68.93 | Fixes 43 words
:B0X*?:beahv::f("behav") ; Web Freq 68.93 | Fixes 43 words
:B0X*?:beatifu::f("beautifu") ; Web Freq 63.66 | Fixes 10 words
:B0X*?:beauroc::f("bureauc") ; Web Freq 4.03 | Fixes 29 words
:B0X*?:becavi::f("behavi") ; Web Freq 63.54 | Fixes 33 words
:B0X*?:beceo::f("beco") ; Web Freq 170.58 | Fixes 19 words
:B0X*?:becoe::f("become") ; Web Freq 147.96 | Fixes 4 words
:B0X*?:becomm::f("becom") ; Web Freq 170.58 | Fixes 13 words
:B0X*?:becor::f("befor") ; Web Freq 279.05 | Fixes 5 words
:B0X*?:becween::f("between") ; Web Freq 255.45 | Fixes 7 words
:B0X*?:bedore::f("before") ; Web Freq 279.05 | Fixes 5 words
:B0X*?:beei::f("bei") ; Web Freq 270.05 | Fixes 57 words
:B0X*?:beeng::f("being") ; Web Freq 250.31 | Fixes 12 words will it break 'been'?
:B0X*?:beeter::f("better") ; Web Freq 158.06 | Fixes 11 words
:B0X*?:befinn::f("beginn") ; Web Freq 63.29 | Fixes 7 words
:B0X*?:behaio::f("behavio") ; Web Freq 62.52 | Fixes 31 words
:B0X*?:behaiv::f("behavi") ; Web Freq 63.54 | Fixes 33 words
:B0X*?:belan::f("blan") ; Web Freq 41.10 | Fixes 77 words, but misspells libelant (a person who brings a libel action or complaint in a legal context)
:B0X*?:beleev::f("believ") ; Web Freq 115.72 | Fixes 37 words
:B0X*?:belei::f("belie") ; Web Freq 138.05 | Fixes 53 words
:B0X*?:belligeran::f("belligeren") ; Web Freq 0.44 | Fixes 14 words
:B0X*?:benif::f("benef") ; Web Freq 143.82 | Fixes 45 words
:B0X*?:beofre::f("before") ; Web Freq 279.05 | Fixes 5 words
:B0X*?:bext::f("best") ; Web Freq 788.22 | Fixes 97 words, but misspells Bextra (A brand name of drug)
:B0X*?:bhaav::f("behav") ; Web Freq 68.93 | Fixes 43 words
:B0X*?:bigin::f("begin") ; Web Freq 176.92 | Fixes 14 words, but misspells rubiginous (Rust colored)
:B0X*?:bilsh::f("blish") ; Web Freq 341.93 | Fixes 80 words
:B0X*?:biul::f("buil") ; Web Freq 344.00 | Fixes 82 words
:B0X*?:blaim::f("blame") ; Web Freq 11.14 | Fixes 19 words
:B0X*?:blamat::f("blemat") ; Web Freq 3.01 | Fixes 37 words
:B0X*?:blence::f("blance") ; Web Freq 1.50 | Fixes 7 words
:B0X*?:bliah::f("blish") ; Web Freq 341.93 | Fixes 80 words
:B0X*?:blich::f("blish") ; Web Freq 341.93 | Fixes 80 words
:B0X*?:blisg::f("blish") ; Web Freq 341.93 | Fixes 80 words
:B0X*?:bllish::f("blish") ; Web Freq 341.93 | Fixes 80 words
:B0X*?:blmm::f("blem") ; Web Freq 270.13 | Fixes 91 words
:B0X*?:boaut::f("about") ; Web Freq 1229.89 | Fixes 41 words
:B0X*?:boilerplan::f("boilerplat") ; Web Freq 0.24 | Fixes 2 words
:B0X*?:bombardem::f("bombardm") ; Web Freq 0.57 | Fixes 4 words
:B0X*?:bondary::f("boundary") ; Web Freq 13.09 | Fixes 3 words
:B0X*?:borrom::f("bottom") ; Web Freq 48.49 | Fixes 19 words
:B0X*?:bortom::f("bottom") ; Web Freq 48.49 | Fixes 19 words
:B0X*?:botton::f("button") ; Web Freq 82.60 | Fixes 41 words
:B0X*?:bottow::f("borrow") ; Web Freq 16.75 | Fixes 11 words
:B0X*?:boudn::f("bound") ; Web Freq 76.23 | Fixes 102 words
:B0X*?:boundr::f("boundar") ; Web Freq 22.98 | Fixes 4 words
:B0X*?:bouth::f("bout") ; Web Freq 1245.69 | Fixes 61 words
:B0X*?:boxs::f("boxes") ; Web Freq 31.37 | Fixes 70 words
:B0X*?:bradc::f("broadc") ; Web Freq 36.06 | Fixes 17 words
:B0X*?:braet::f("breat") ; Web Freq 27.80 | Fixes 56 words 
:B0X*?:breif::f("brief") ; Web Freq 58.54 | Fixes 28 words .
:B0X*?:brenc::f("branc") ; Web Freq 52.61 | Fixes 94 words
:B0X*?:broadaca::f("broadca") ; Web Freq 35.91 | Fixes 15 words
:B0X*?:buise::f("buse") ; Web Freq 49.92 | Fixes 44 words
:B0X*?:buisn::f("busin") ; Web Freq 691.66 | Fixes 26 words
:B0X*?:bullding::f("building") ; Web Freq 162.69 | Fixes 25 words
:B0X*?:buoto::f("butto") ; Web Freq 83.48 | Fixes 43 words
:B0X*?:buring::f("burying") ; Web Freq 0.50 | Fixes 4 words
:B0X*?:burrie::f("burie") ; Web Freq 7.44 | Fixes 9 words, but misspells burrier (Uncommon form of barrier)
:B0X*?:burron::f("button") ; Web Freq 82.60 | Fixes 41 words
:B0X*?:bussine::f("busine") ; Web Freq 690.52 | Fixes 21 words
:B0X*?:butoon::f("button") ; Web Freq 82.60 | Fixes 41 words
:B0X*?:butten::f("button") ; Web Freq 82.60 | Fixes 41 words
:B0X*?:buttom::f("bottom") ; Web Freq 48.49 | Fixes 19 words
:B0X*?:caculater::f("calculator") ; Web Freq 28.59 | Fixes 3 words
:B0X*?:caffine::f("caffein") ; Web Freq 3.11 | Fixes 14 words
:B0X*?:caharcter::f("character") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:cahrac::f("charac") ; Web Freq 140.59 | Fixes 53 words
:B0X*?:calanda::f("calenda") ; Web Freq 113.07 | Fixes 5 words
:B0X*?:calbe::f("cable") ; Web Freq 134.64 | Fixes 87 words
:B0X*?:calculater::f("calculator") ; Web Freq 28.59 | Fixes 3 words
:B0X*?:calculla::f("calcula") ; Web Freq 88.22 | Fixes 43 words
:B0X*?:calculs::f("calculus") ; Web Freq 4.10 | Fixes 4 words
:B0X*?:caldnd::f("calend") ; Web Freq 113.36 | Fixes 14 words
:B0X*?:caledda::f("calenda") ; Web Freq 113.07 | Fixes 5 words
:B0X*?:calrif::f("clarif") ; Web Freq 13.25 | Fixes 10 words
:B0X*?:calss::f("class") ; Web Freq 480.82 | Fixes 168 words
:B0X*?:caluclat::f("calculat") ; Web Freq 88.00 | Fixes 33 words
:B0X*?:caluculat::f("calculat") ; Web Freq 88.00 | Fixes 33 words
:B0X*?:calulat::f("calculat") ; Web Freq 88.00 | Fixes 33 words
:B0X*?:caluul::f("calcul") ; Web Freq 92.62 | Fixes 54 words
:B0X*?:camae::f("came") ; Web Freq 300.62 | Fixes 77 words
:B0X*?:campagin::f("campaign") ; Web Freq 48.32 | Fixes 8 words
:B0X*?:campain::f("campaign") ; Web Freq 48.32 | Fixes 8 words
:B0X*?:candad::f("candid") ; Web Freq 47.92 | Fixes 25 words
:B0X*?:candiat::f("candidat") ; Web Freq 41.94 | Fixes 7 words
:B0X*?:candica::f("candida") ; Web Freq 44.24 | Fixes 14 words
:B0X*?:candidta::f("candidat") ; Web Freq 41.94 | Fixes 7 words
:B0X*?:cannonic::f("canonic") ; Web Freq 2.12 | Fixes 10 words
:B0X*?:caperb::f("capab") ; Web Freq 49.84 | Fixes 21 words
:B0X*?:capibl::f("capabl") ; Web Freq 18.35 | Fixes 16 words
:B0X*?:capical::f("capital") ; Web Freq 152.45 | Fixes 68 words
:B0X*?:captia::f("capita") ; Web Freq 157.71 | Fixes 82 words
:B0X*?:caracht::f("charact") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:caract::f("charact") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:carcira::f("carcera") ; Web Freq 1.72 | Fixes 15 words
:B0X*?:carism::f("charism") ; Web Freq 2.06 | Fixes 11 words
:B0X*?:cartileg::f("cartilag") ; Web Freq 1.42 | Fixes 7 words
:B0X*?:cartilidg::f("cartilag") ; Web Freq 1.42 | Fixes 7 words
:B0X*?:casette::f("cassette") ; Web Freq 14.66 | Fixes 8 words
:B0X*?:catagor::f("categor") ; Web Freq 356.37 | Fixes 66 words
:B0X*?:categro::f("categor") ; Web Freq 356.37 | Fixes 66 words
:B0X*?:catergor::f("categor") ; Web Freq 356.37 | Fixes 66 words
:B0X*?:cathlic::f("catholic") ; Web Freq 48.29 | Fixes 34 words
:B0X*?:catholoc::f("catholic") ; Web Freq 48.29 | Fixes 34 words
:B0X*?:catre::f("cater") ; Web Freq 24.66 | Fixes 28 words, but misspells fornicatress (A promiscuous or disreputable woman)
:B0X*?:ccce::f("cce") ; Web Freq 833.06 | Fixes 215 words
:B0X*?:ccesi::f("ccessi") ; Web Freq 57.81 | Fixes 36 words
:B0X*?:ccures::f("ccurs") ; Web Freq 16.39 | Fixes 11 words
:B0X*?:ceiev::f("ceiv") ; Web Freq 261.63 | Fixes 90 words
:B0X*?:ceing::f("cing") ; Web Freq 314.71 | Fixes 374 words, but misspells glaceing (Cullinary term for glazing), Recceing (appreviation for reconnaissance)
:B0X*?:ceist::f("ciest") ; Web Freq 0.10 | Fixes 22 words
:B0X*?:cencu::f("censu") ; Web Freq 28.51 | Fixes 22 words
:B0X*?:centente::f("centen") ; Web Freq 4.80 | Fixes 40 words
:B0X*?:cerimo::f("ceremo") ; Web Freq 13.18 | Fixes 20 words
:B0X*?:ceromo::f("ceremo") ; Web Freq 13.18 | Fixes 20 words
:B0X*?:certian::f("certain") ; Web Freq 119.90 | Fixes 28 words, but misspells lacertian (Lacertidae, a group of small to medium-sized lizards found primarily in Europe and Asia)
:B0X*?:cesion::f("cession") ; Web Freq 18.35 | Fixes 60 words
:B0X*?:cesor::f("cessor") ; Web Freq 222.53 | Fixes 35 words
:B0X*?:cesser::f("cessor") ; Web Freq 222.53 | Fixes 35 words
:B0X*?:cev::f("ceiv") ; Web Freq 261.63 | Fixes 90 words, but misspells Lawrenceville (A city name), ceviche (South American seafood dish)
:B0X*?:chack::f("check") ; Web Freq 368.90 | Fixes 117 words, but, misspells chack (Sound a bird makes)
:B0X*?:chagee::f("change") ; Web Freq 499.25 | Fixes 83 words
:B0X*?:chagge::f("change") ; Web Freq 499.25 | Fixes 83 words Will it confound "charge"?
:B0X*?:chagn::f("chang") ; Web Freq 542.03 | Fixes 104 words
:B0X*?:chahe::f("cache") ; Web Freq 32.00 | Fixes 23 words
:B0X*?:chalen::f("challen") ; Web Freq 76.27 | Fixes 21 words
:B0X*?:challang::f("challeng") ; Web Freq 76.27 | Fixes 21 words
:B0X*?:challengabl::f("challengeabl") ; Web Freq 0.02 | Fixes 4 words
:B0X*?:changab::f("changeab") ; Web Freq 2.77 | Fixes 29 words
:B0X*?:characto::f("characte") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:charasm::f("charism") ; Web Freq 2.06 | Fixes 11 words
:B0X*?:charater::f("character") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:charector::f("character") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:charga::f("chargea") ; Web Freq 4.95 | Fixes 8 words
:B0X*?:chartia::f("charita") ; Web Freq 6.07 | Fixes 9 words
:B0X*?:cheif::f("chief") ; Web Freq 54.10 | Fixes 27 words
:B0X*?:cheis::f("chies") ; Web Freq 1.77 | Fixes 103 words
:B0X*?:chemest::f("chemist") ; Web Freq 35.93 | Fixes 69 words
:B0X*?:chenge::f("change") ; Web Freq 499.25 | Fixes 83 words, but misspells Schengen Agreement (An accord between several European countries)
:B0X*?:chict::f("chit") ; Web Freq 83.88 | Fixes 94 words
:B0X*?:childen::f("children") ; Web Freq 210.42 | Fixes 7 words
:B0X*?:choss::f("choos") ; Web Freq 106.48 | Fixes 20 words
:B0X*?:chracter::f("character") ; Web Freq 140.27 | Fixes 45 words
:B0X*?:chter::f("cter") ; Web Freq 161.86 | Fixes 261 words, but misspells yachter (person who sails a yacht)
:B0X*?:chuch::f("church") ; Web Freq 106.98 | Fixes 56 words, but misspells Cachucha (a Cuban solo dance or a type of hat)
:B0X*?:cidan::f("ciden") ; Web Freq 71.12 | Fixes 51 words
:B0X*?:cidently::f("cidentally") ; Web Freq 4.51 | Fixes 4 words
:B0X*?:cieent::f("cident") ; Web Freq 62.43 | Fixes 43 words
:B0X*?:ciel::f("ceil") ; Web Freq 13.07 | Fixes 16 words, but misspells Ciel (French term for sky or heavens)
:B0X*?:ciencio::f("cientio") ; Web Freq 1.05 | Fixes 9 words
:B0X*?:ciepen::f("cipien") ; Web Freq 20.51 | Fixes 22 words
:B0X*?:ciese::f("cises") ; Web Freq 10.55 | Fixes 48 words
:B0X*?:ciev::f("ceiv") ; Web Freq 261.63 | Fixes 90 words
:B0X*?:cigic::f("cific") ; Web Freq 303.94 | Fixes 58 words
:B0X*?:cilation::f("ciliation") ; Web Freq 4.70 | Fixes 8 words
:B0X*?:cilbe::f("cible") ; Web Freq 4.31 | Fixes 45 words
:B0X*?:cilind::f("cylind") ; Web Freq 11.46 | Fixes 12 words
:B0X*?:cilliar::f("cillar") ; Web Freq 2.05 | Fixes 8 words
:B0X*?:cillit::f("cilit") ; Web Freq 138.25 | Fixes 24 words
:B0X*?:circut::f("circuit") ; Web Freq 35.16 | Fixes 17 words
:B0X*?:ciric::f("circ") ; Web Freq 140.18 | Fixes 223 words
:B0X*?:cirp::f("crip") ; Web Freq 444.91 | Fixes 149 words, but misspells Scirpus (Rhizomatous perennial grasslike herbs)
:B0X*?:cison::f("cision") ; Web Freq 119.95 | Fixes 34 words
:B0X*?:citment::f("citement") ; Web Freq 5.58 | Fixes 7 words
:B0X*?:ciull::f("cill") ; Web Freq 19.68 | Fixes 142 words
:B0X*?:civilli::f("civili") ; Web Freq 21.15 | Fixes 56 words
:B0X*?:ckking::f("cking") ; Web Freq 244.50 | Fixes 333 words
:B0X*?:clasic::f("classic") ; Web Freq 112.12 | Fixes 50 words
:B0X*?:clincia::f("clinica") ; Web Freq 45.37 | Fixes 8 words
:B0X*?:clisk::f("click") ; Web Freq 568.06 | Fixes 13 words
:B0X*?:clomation::f("clamation") ; Web Freq 5.06 | Fixes 12 words
:B0X*?:closk::f("clock") ; Web Freq 40.47 | Fixes 26 words, but misspells McCloskey (A common Irish name)
:B0X*?:closs::f("class") ; Web Freq 480.82 | Fixes 168 words, but misspells Auchincloss (United States writer born in 1917)
:B0X*?:cment::f("cement") ; Web Freq 171.89 | Fixes 86 words
:B0X*?:coee::f("code") ; Web Freq 334.65 | Fixes 126 words
:B0X*?:coform::f("conform") ; Web Freq 17.33 | Fixes 54 words
:B0X*?:cogiit::f("cognit") ; Web Freq 33.54 | Fixes 22 words
:B0X*?:cogis::f("cognis") ; Web Freq 12.80 | Fixes 36 words
:B0X*?:cogiz::f("cogniz") ; Web Freq 44.65 | Fixes 44 words
:B0X*?:cogntivie::f("cognitive") ; Web Freq 8.48 | Fixes 5 words
:B0X*?:colab::f("collab") ; Web Freq 37.04 | Fixes 16 words
:B0X*?:colecti::f("collecti") ; Web Freq 192.92 | Fixes 54 words
:B0X*?:colelct::f("collect") ; Web Freq 270.55 | Fixes 80 words
:B0X*?:collon::f("colon") ; Web Freq 46.12 | Fixes 116 words
:B0X*?:colomn::f("column") ; Web Freq 65.24 | Fixes 20 words
:B0X*?:comanie::f("companie") ; Web Freq 127.74 | Fixes 5 words
:B0X*?:comany::f("company") ; Web Freq 333.55 | Fixes 8 words
:B0X*?:comapan::f("compan") ; Web Freq 474.98 | Fixes 43 words
:B0X*?:comapn::f("compan") ; Web Freq 474.98 | Fixes 43 words
:B0X*?:comban::f("combin") ; Web Freq 97.35 | Fixes 45 words
:B0X*?:combaten::f("combatan") ; Web Freq 1.27 | Fixes 4 words
:B0X*?:combinatin::f("combination") ; Web Freq 36.05 | Fixes 6 words
:B0X*?:combon::f("combin") ; Web Freq 97.35 | Fixes 45 words
:B0X*?:combusi::f("combusti") ; Web Freq 4.65 | Fixes 22 words
:B0X*?:comde::f("conde") ; Web Freq 21.17 | Fixes 60 words
:B0X*?:comemo::f("commemo") ; Web Freq 4.24 | Fixes 12 words
:B0X*?:cometime::f("sometime") ; Web Freq 52.18 | Fixes 2 words
:B0X*?:comiss::f("commiss") ; Web Freq 114.36 | Fixes 36 words
:B0X*?:comite::f("committe") ; Web Freq 170.45 | Fixes 17 words
:B0X*?:comitt::f("committ") ; Web Freq 172.81 | Fixes 29 words
:B0X*?:commed::f("comed") ; Web Freq 32.11 | Fixes 22 words
:B0X*?:commemerat::f("commemorat") ; Web Freq 4.24 | Fixes 12 words
:B0X*?:commerica::f("commercia") ; Web Freq 101.65 | Fixes 43 words
:B0X*?:commericia::f("commercia") ; Web Freq 101.65 | Fixes 43 words
:B0X*?:commini::f("communi") ; Web Freq 501.51 | Fixes 144 words
:B0X*?:commite::f("committe") ; Web Freq 170.45 | Fixes 17 words
:B0X*?:commuica::f("communica") ; Web Freq 176.19 | Fixes 84 words
:B0X*?:commuinica::f("communica") ; Web Freq 176.19 | Fixes 84 words
:B0X*?:communcia::f("communica") ; Web Freq 176.19 | Fixes 84 words
:B0X*?:communia::f("communica") ; Web Freq 176.19 | Fixes 84 words
:B0X*?:comparibl::f("comparabl") ; Web Freq 8.49 | Fixes 11 words
:B0X*?:compatiab::f("compatib") ; Web Freq 46.32 | Fixes 20 words
:B0X*?:compeit::f("competit") ; Web Freq 88.44 | Fixes 24 words
:B0X*?:compenc::f("compens") ; Web Freq 32.24 | Fixes 33 words
:B0X*?:competan::f("competen") ; Web Freq 19.53 | Fixes 23 words
:B0X*?:competat::f("competit") ; Web Freq 88.44 | Fixes 24 words
:B0X*?:competens::f("competenc") ; Web Freq 12.15 | Fixes 12 words
:B0X*?:comphr::f("compr") ; Web Freq 102.11 | Fixes 126 words
:B0X*?:compine::f("combine") ; Web Freq 49.94 | Fixes 12 words
:B0X*?:compleate::f("complete") ; Web Freq 253.15 | Fixes 21 words
:B0X*?:compleatne::f("completene") ; Web Freq 3.97 | Fixes 5 words
:B0X*?:compltee::f("complete") ; Web Freq 253.15 | Fixes 21 words
:B0X*?:compoeh::f("compreh") ; Web Freq 44.23 | Fixes 49 words
:B0X*?:componenc::f("component") ; Web Freq 94.98 | Fixes 7 words
:B0X*?:comporta::f("comforta") ; Web Freq 25.05 | Fixes 10 words
:B0X*?:comprab::f("comparab") ; Web Freq 9.06 | Fixes 17 words
:B0X*?:comprim::f("comprom") ; Web Freq 10.22 | Fixes 15 words
:B0X*?:comun::f("commun") ; Web Freq 505.03 | Fixes 172 words
:B0X*?:concide::f("conside") ; Web Freq 186.47 | Fixes 35 words
:B0X*?:concious::f("conscious") ; Web Freq 18.45 | Fixes 34 words
:B0X*?:condidt::f("condit") ; Web Freq 279.21 | Fixes 45 words
:B0X*?:conect::f("connect") ; Web Freq 241.03 | Fixes 66 words
:B0X*?:conesencu::f("consensu") ; Web Freq 8.61 | Fixes 5 words
:B0X*?:conferan::f("conferen") ; Web Freq 130.41 | Fixes 18 words
:B0X*?:confert::f("convert") ; Web Freq 77.44 | Fixes 54 words
:B0X*?:confidenta::f("confidentia") ; Web Freq 16.73 | Fixes 6 words
:B0X*?:configurea::f("configura") ; Web Freq 45.83 | Fixes 15 words
:B0X*?:confise::f("confuse") ; Web Freq 10.64 | Fixes 10 words
:B0X*?:conflist::f("conflict") ; Web Freq 36.02 | Fixes 17 words
:B0X*?:confort::f("comfort") ; Web Freq 60.86 | Fixes 24 words
:B0X*?:conllict::f("conflict") ; Web Freq 36.02 | Fixes 17 words
:B0X*?:consenn::f("concern") ; Web Freq 103.44 | Fixes 23 words Will it confound "consent"?
:B0X*?:consentr::f("concentr") ; Web Freq 40.26 | Fixes 43 words
:B0X*?:consept::f("concept") ; Web Freq 67.75 | Fixes 57 words
:B0X*?:conservit::f("conservat") ; Web Freq 69.63 | Fixes 59 words
:B0X*?:consic::f("consc") ; Web Freq 24.08 | Fixes 68 words
:B0X*?:considerd::f("considered") ; Web Freq 57.88 | Fixes 5 words
:B0X*?:considerit::f("considerat") ; Web Freq 33.08 | Fixes 14 words
:B0X*?:consio::f("conscio") ; Web Freq 18.73 | Fixes 43 words
:B0X*?:conspiric::f("conspirac") ; Web Freq 6.95 | Fixes 6 words
:B0X*?:constai::f("constrai") ; Web Freq 19.94 | Fixes 15 words
:B0X*?:constin::f("contin") ; Web Freq 275.90 | Fixes 89 words
:B0X*?:consumat::f("consummat") ; Web Freq 0.96 | Fixes 15 words
:B0X*?:consumbe::f("consume") ; Web Freq 98.03 | Fixes 23 words
:B0X*?:contant::f("content") ; Web Freq 272.68 | Fixes 35 words
:B0X*?:contect::f("context") ; Web Freq 46.45 | Fixes 37 words
:B0X*?:contian::f("contain") ; Web Freq 165.12 | Fixes 35 words
:B0X*?:contide::f("conside") ; Web Freq 186.47 | Fixes 35 words
:B0X*?:contien::f("conscien") ; Web Freq 4.83 | Fixes 15 words
:B0X*?:contigen::f("contingen") ; Web Freq 6.92 | Fixes 9 words
:B0X*?:contined::f("continued") ; Web Freq 45.00 | Fixes 4 words
:B0X*?:continentia::f("continenta") ; Web Freq 28.74 | Fixes 10 words
:B0X*?:continet::f("continent") ; Web Freq 42.29 | Fixes 20 words
:B0X*?:contino::f("continuo") ; Web Freq 28.18 | Fixes 12 words
:B0X*?:contitio::f("conditio") ; Web Freq 279.18 | Fixes 39 words
:B0X*?:contitu::f("constitu") ; Web Freq 107.31 | Fixes 48 words
:B0X*?:contoll::f("control") ; Web Freq 306.22 | Fixes 40 words
:B0X*?:contool::f("control") ; Web Freq 306.22 | Fixes 40 words
:B0X*?:contorl::f("control") ; Web Freq 306.22 | Fixes 40 words
:B0X*?:contravers::f("controvers") ; Web Freq 11.71 | Fixes 12 words
:B0X*?:contributer::f("contributor") ; Web Freq 15.39 | Fixes 4 words
:B0X*?:controle::f("controlle") ; Web Freq 50.73 | Fixes 13 words
:B0X*?:controverc::f("controvers") ; Web Freq 11.71 | Fixes 12 words
:B0X*?:controveri::f("controversi") ; Web Freq 6.54 | Fixes 11 words
:B0X*?:controversa::f("controversia") ; Web Freq 5.62 | Fixes 10 words
:B0X*?:controvertial::f("controversial") ; Web Freq 5.62 | Fixes 10 words
:B0X*?:contru::f("constru") ; Web Freq 149.31 | Fixes 89 words
:B0X*?:convenant::f("covenant") ; Web Freq 6.16 | Fixes 12 words
:B0X*?:convential::f("conventional") ; Web Freq 13.89 | Fixes 25 words
:B0X*?:convice::f("convince") ; Web Freq 10.38 | Fixes 13 words
:B0X*?:copm::f("comp") ; Web Freq 2330.25 | Fixes 911 words
:B0X*?:copty::f("copy") ; Web Freq 491.90 | Fixes 94 words
:B0X*?:coput::f("comput") ; Web Freq 411.79 | Fixes 79 words
:B0X*?:copywrite::f("copyright") ; Web Freq 390.50 | Fixes 7 words
:B0X*?:coreect::f("correct") ; Web Freq 114.75 | Fixes 48 words
:B0X*?:coropor::f("corpor") ; Web Freq 210.79 | Fixes 86 words
:B0X*?:corpar::f("corpor") ; Web Freq 210.79 | Fixes 86 words
:B0X*?:corpera::f("corpora") ; Web Freq 210.36 | Fixes 69 words
:B0X*?:corporta::f("corporat") ; Web Freq 208.22 | Fixes 62 words
:B0X*?:corprat::f("corporat") ; Web Freq 208.22 | Fixes 62 words
:B0X*?:corpro::f("corpor") ; Web Freq 210.79 | Fixes 86 words
:B0X*?:corris::f("corres") ; Web Freq 42.02 | Fixes 13 words
:B0X*?:costit::f("constit") ; Web Freq 107.31 | Fixes 48 words
:B0X*?:cotten::f("cotton") ; Web Freq 25.07 | Fixes 21 words
:B0X*?:cottrov::f("controv") ; Web Freq 11.87 | Fixes 25 words
:B0X*?:coudl::f("could") ; Web Freq 302.34 | Fixes 5 words
:B0X*?:couise::f("couse") ; Web Freq 1.42 | Fixes 9 words 
:B0X*?:countain::f("contain") ; Web Freq 165.12 | Fixes 35 words
:B0X*?:countir::f("countri") ; Web Freq 83.10 | Fixes 8 words
:B0X*?:couraing::f("couraging") ; Web Freq 7.81 | Fixes 7 words
:B0X*?:couree::f("course") ; Web Freq 260.61 | Fixes 39 words
:B0X*?:couro::f("coro") ; Web Freq 13.33 | Fixes 75 words
:B0X*?:courur::f("cour") ; Web Freq 637.54 | Fixes 197 words
:B0X*?:covelan::f("covalen") ; Web Freq 0.67 | Fixes 6 words 
:B0X*?:coverate::f("coverage") ; Web Freq 44.23 | Fixes 4 words 
:B0X*?:craet::f("creat") ; Web Freq 479.03 | Fixes 97 words 
:B0X*?:crata::f("creta") ; Web Freq 64.91 | Fixes 30 words, but misspells Crataegus (Thorny shrubs)
:B0X*?:creaet::f("creat") ; Web Freq 479.03 | Fixes 97 words
:B0X*?:createn::f("creatin") ; Web Freq 41.79 | Fixes 16 words
:B0X*?:credia::f("credita") ; Web Freq 7.65 | Fixes 15 words
:B0X*?:credida::f("credita") ; Web Freq 7.65 | Fixes 15 words
:B0X*?:creeden::f("creden") ; Web Freq 6.88 | Fixes 17 words
:B0X*?:cretit::f("credit") ; Web Freq 237.85 | Fixes 44 words
:B0X*?:criib::f("crib") ; Web Freq 263.48 | Fixes 141 words
:B0X*?:crrrect::f("correct") ; Web Freq 114.75 | Fixes 48 words
:B0X*?:crtic::f("critic") ; Web Freq 84.28 | Fixes 62 words
:B0X*?:crusie::f("cruise") ; Web Freq 50.84 | Fixes 10 words
:B0X*?:crutia::f("crucia") ; Web Freq 10.99 | Fixes 22 words
:B0X*?:crystalisa::f("crystallisa") ; Web Freq 0.08 | Fixes 5 words
:B0X*?:cstion::f("cation") ; Web Freq 1857.36 | Fixes 686 words
:B0X*?:ctail::f("cktail") ; Web Freq 7.29 | Fixes 12 words
:B0X*?:cteme::f("ctme") ; Web Freq 5.57 | Fixes 11 words
:B0X*?:ctent::f("ctant") ; Web Freq 6.89 | Fixes 42 words
:B0X*?:ctionna::f("ctiona") ; Web Freq 139.33 | Fixes 208 words
:B0X*?:ctoin::f("ction") ; Web Freq 2415.79 | Fixes 901 words
:B0X*?:cualr::f("cular") ; Web Freq 195.67 | Fixes 309 words
:B0X*?:cuas::f("caus") ; Web Freq 415.77 | Fixes 61 words
:B0X*?:cuise::f("cuse") ; Web Freq 56.05 | Fixes 69 words
:B0X*?:culity::f("culty") ; Web Freq 65.16 | Fixes 6 words
:B0X*?:cultral::f("cultural") ; Web Freq 75.84 | Fixes 52 words
:B0X*?:culure::f("culture") ; Web Freq 147.93 | Fixes 59 words
:B0X*?:cunction::f("function") ; Web Freq 218.54 | Fixes 63 words
:B0X*?:curcuit::f("circuit") ; Web Freq 35.16 | Fixes 17 words
:B0X*?:currett::f("current") ; Web Freq 318.34 | Fixes 36 words
:B0X*?:cusotm::f("custom") ; Web Freq 395.36 | Fixes 54 words
:B0X*?:cutr::f("ctur") ; Web Freq 765.12 | Fixes 218 words, but misspells executrix (a woman executor)
:B0X*?:cutsom::f("custom") ; Web Freq 395.36 | Fixes 54 words
:B0X*?:cuture::f("culture") ; Web Freq 147.93 | Fixes 59 words
:B0X*?:cyclind::f("cylind") ; Web Freq 11.46 | Fixes 12 words
:B0X*?:dael::f("deal") ; Web Freq 283.59 | Fixes 102 words, but misspells Passchendaele (A village in Belgim), groenendael (black-coated sheepdog)
:B0X*?:damenor::f("demeanor") ; Web Freq 2.26 | Fixes 4 words
:B0X*?:damenour::f("demeanour") ; Web Freq 0.17 | Fixes 4 words
:B0X*?:dammag::f("damag") ; Web Freq 61.89 | Fixes 21 words
:B0X*?:damy::f("demy") ; Web Freq 30.02 | Fixes 31 words
:B0X*?:datye::f("date") ; Web Freq 895.83 | Fixes 216 words
:B0X*?:datys::f("days") ; Web Freq 372.84 | Fixes 49 words
:B0X*?:daugher::f("daughter") ; Web Freq 34.94 | Fixes 12 words
:B0X*?:dcument::f("document") ; Web Freq 230.19 | Fixes 30 words
:B0X*?:deatil::f("detail") ; Web Freq 382.33 | Fixes 12 words
:B0X*?:decend::f("descend") ; Web Freq 12.81 | Fixes 31 words
:B0X*?:deceo::f("deco") ; Web Freq 72.15 | Fixes 295 words
:B0X*?:decideab::f("decidab") ; Web Freq 0.39 | Fixes 6 words
:B0X*?:decomposited::f("decomposed") ; Web Freq 0.47 | Fixes 2 words
:B0X*?:dectect::f("detect") ; Web Freq 63.65 | Fixes 30 words
:B0X*?:defenden::f("defendan") ; Web Freq 17.11 | Fixes 4 words
:B0X*?:deffe::f("defe") ; Web Freq 176.62 | Fixes 179 words
:B0X*?:deffi::f("defi") ; Web Freq 236.12 | Fixes 131 words
:B0X*?:definte::f("definite") ; Web Freq 22.58 | Fixes 10 words
:B0X*?:definti::f("definiti") ; Web Freq 70.09 | Fixes 14 words
:B0X*?:degrat::f("degrad") ; Web Freq 8.92 | Fixes 36 words
:B0X*?:deinc::f("dienc") ; Web Freq 32.80 | Fixes 22 words
:B0X*?:delag::f("deleg") ; Web Freq 17.75 | Fixes 49 words
:B0X*?:delevop::f("develop") ; Web Freq 542.96 | Fixes 56 words
:B0X*?:delimma::f("dilemma") ; Web Freq 4.06 | Fixes 3 words
:B0X*?:demeno::f("demeano") ; Web Freq 2.43 | Fixes 8 words
:B0X*?:demmi::f("demi") ; Web Freq 83.77 | Fixes 165 words
:B0X*?:demolisi::f("demoliti") ; Web Freq 3.02 | Fixes 4 words
:B0X*?:demorcr::f("democr") ; Web Freq 103.24 | Fixes 31 words
:B0X*?:dencia::f("dentia") ; Web Freq 68.66 | Fixes 47 words
:B0X*?:denegrat::f("denigrat") ; Web Freq 0.36 | Fixes 10 words
:B0X*?:dentational::f("dental") ; Web Freq 38.10 | Fixes 60 words
:B0X*?:depedan::f("dependen") ; Web Freq 137.09 | Fixes 36 words
:B0X*?:depede::f("depende") ; Web Freq 138.23 | Fixes 38 words
:B0X*?:dependan::f("dependen") ; Web Freq 137.09 | Fixes 36 words
:B0X*?:deptart::f("depart") ; Web Freq 257.01 | Fixes 35 words
:B0X*?:deram::f("dream") ; Web Freq 73.12 | Fixes 60 words
:B0X*?:deriviate::f("derive") ; Web Freq 21.35 | Fixes 14 words
:B0X*?:derivit::f("derivat") ; Web Freq 11.89 | Fixes 24 words
:B0X*?:descib::f("describ") ; Web Freq 93.80 | Fixes 24 words
:B0X*?:desided::f("decided") ; Web Freq 34.99 | Fixes 9 words
:B0X*?:desinat::f("destinat") ; Web Freq 47.61 | Fixes 13 words
:B0X*?:desirea::f("desira") ; Web Freq 7.91 | Fixes 14 words
:B0X*?:desisi::f("decisi") ; Web Freq 105.28 | Fixes 19 words
:B0X*?:desitn::f("destin") ; Web Freq 57.67 | Fixes 35 words
:B0X*?:despatch::f("dispatch") ; Web Freq 20.40 | Fixes 7 words, but misspells despatch and variants (British spelling)
:B0X*?:despensib::f("dispensab") ; Web Freq 1.93 | Fixes 12 words
:B0X*?:despict::f("depict") ; Web Freq 8.75 | Fixes 12 words
:B0X*?:despira::f("despera") ; Web Freq 13.46 | Fixes 10 words
:B0X*?:destory::f("destroy") ; Web Freq 24.86 | Fixes 8 words
:B0X*?:detecab::f("detectab") ; Web Freq 1.70 | Fixes 7 words
:B0X*?:deteoriat::f("deteriorat") ; Web Freq 4.04 | Fixes 9 words
:B0X*?:detree::f("degree") ; Web Freq 95.25 | Fixes 12 words
:B0X*?:devello::f("develo") ; Web Freq 542.96 | Fixes 56 words
:B0X*?:developem::f("developm") ; Web Freq 313.74 | Fixes 22 words
:B0X*?:developor::f("developer") ; Web Freq 59.98 | Fixes 6 words
:B0X*?:developpe::f("develope") ; Web Freq 124.56 | Fixes 14 words
:B0X*?:develp::f("develop") ; Web Freq 542.96 | Fixes 56 words
:B0X*?:devid::f("divid") ; Web Freq 188.63 | Fixes 74 words
:B0X*?:devolop::f("develop") ; Web Freq 542.96 | Fixes 56 words
:B0X*?:dgeing::f("dging") ; Web Freq 27.27 | Fixes 69 words
:B0X*?:dgement::f("dgment") ; Web Freq 22.28 | Fixes 20 words, but Americanizes 19 British words! (see exam pane)
:B0X*?:diabnos::f("diagnos") ; Web Freq 42.14 | Fixes 41 words
:B0X*?:diapl::f("displ") ; Web Freq 177.03 | Fixes 45 words
:B0X*?:diarhe::f("diarrhoe") ; Web Freq 0.67 | Fixes 7 words
:B0X*?:dicatb::f("dictab") ; Web Freq 6.01 | Fixes 16 words
:B0X*?:diciplin::f("disciplin") ; Web Freq 30.75 | Fixes 34 words
:B0X*?:dicover::f("discover") ; Web Freq 75.67 | Fixes 35 words
:B0X*?:dicus::f("discus") ; Web Freq 227.54 | Fixes 20 words
:B0X*?:dielo::f("dialo") ; Web Freq 23.47 | Fixes 28 words
:B0X*?:difef::f("diffe") ; Web Freq 293.78 | Fixes 55 words
:B0X*?:diferen::f("differen") ; Web Freq 277.02 | Fixes 47 words
:B0X*?:diferre::f("differe") ; Web Freq 278.07 | Fixes 48 words
:B0X*?:differan::f("differen") ; Web Freq 277.02 | Fixes 47 words
:B0X*?:diffren::f("differen") ; Web Freq 277.02 | Fixes 47 words
:B0X*?:difin::f("defin") ; Web Freq 210.89 | Fixes 74 words
:B0X*?:difit::f("digit") ; Web Freq 219.83 | Fixes 58 words
:B0X*?:digine::f("digen") ; Web Freq 9.44 | Fixes 31 words
:B0X*?:dilbe::f("dible") ; Web Freq 19.40 | Fixes 43 words
:B0X*?:dilema::f("dilemma") ; Web Freq 4.06 | Fixes 3 words
:B0X*?:dimenio::f("dimensio") ; Web Freq 47.78 | Fixes 23 words
:B0X*?:dimentio::f("dimensio") ; Web Freq 47.78 | Fixes 23 words
:B0X*?:diosese::f("diocese") ; Web Freq 3.44 | Fixes 4 words
:B0X*?:dipend::f("depend") ; Web Freq 190.86 | Fixes 54 words
:B0X*?:dirfer::f("differ") ; Web Freq 293.62 | Fixes 51 words
:B0X*?:diriv::f("deriv") ; Web Freq 34.18 | Fixes 43 words
:B0X*?:discrib::f("describ") ; Web Freq 93.80 | Fixes 24 words
:B0X*?:discrict::f("district") ; Web Freq 115.26 | Fixes 13 words
:B0X*?:discues::f("discuss") ; Web Freq 226.61 | Fixes 18 words
:B0X*?:disentin::f("dissentin") ; Web Freq 1.03 | Fixes 2 words
:B0X*?:disgno::f("diagno") ; Web Freq 42.14 | Fixes 41 words
:B0X*?:disipl::f("discipl") ; Web Freq 35.39 | Fixes 39 words
:B0X*?:disolv::f("dissolv") ; Web Freq 5.42 | Fixes 19 words
:B0X*?:dispaly::f("display") ; Web Freq 168.49 | Fixes 11 words
:B0X*?:dispenc::f("dispens") ; Web Freq 10.10 | Fixes 25 words
:B0X*?:dispensib::f("dispensab") ; Web Freq 1.93 | Fixes 12 words
:B0X*?:disric::f("distric") ; Web Freq 115.26 | Fixes 13 words
:B0X*?:distio::f("dictio") ; Web Freq 90.99 | Fixes 35 words
:B0X*?:distruc::f("destruc") ; Web Freq 17.67 | Fixes 30 words
:B0X*?:diton::f("dition") ; Web Freq 720.91 | Fixes 103 words, but misspells ditone (A musical term)
:B0X*?:ditrib::f("distrib") ; Web Freq 145.31 | Fixes 45 words
:B0X*?:divice::f("device") ; Web Freq 98.51 | Fixes 4 words
:B0X*?:divsi::f("divisi") ; Web Freq 89.97 | Fixes 34 words
:B0X*?:dizt::f("dist") ; Web Freq 449.83 | Fixes 408 words
:B0X*?:dmant::f("dment") ; Web Freq 44.51 | Fixes 30 words
:B0X*?:dminst::f("dminist") ; Web Freq 174.21 | Fixes 38 words
:B0X*?:doccu::f("docu") ; Web Freq 230.27 | Fixes 37 words
:B0X*?:docotr::f("doctor") ; Web Freq 124.89 | Fixes 30 words
:B0X*?:doctin::f("doctrin") ; Web Freq 8.76 | Fixes 18 words
:B0X*?:docueme::f("docume") ; Web Freq 230.19 | Fixes 30 words
:B0X*?:dolan::f("dolen") ; Web Freq 1.51 | Fixes 16 words, but misspells Dolan (An Irish surname)
:B0X*?:doller::f("dollar") ; Web Freq 75.65 | Fixes 19 words
:B0X*?:dominen::f("dominan") ; Web Freq 13.99 | Fixes 23 words
:B0X*?:douise::f("douse") ; Web Freq 0.19 | Fixes 5 words 
:B0X*?:dounl::f("downl") ; Web Freq 351.08 | Fixes 26 words
:B0X*?:dowload::f("download") ; Web Freq 350.13 | Fixes 11 words
:B0X*?:downoo::f("downlo") ; Web Freq 350.13 | Fixes 11 words
:B0X*?:dpend::f("depend") ; Web Freq 190.86 | Fixes 54 words
:B0X*?:dramti::f("dramati") ; Web Freq 15.34 | Fixes 58 words
:B0X*?:driect::f("direct") ; Web Freq 685.23 | Fixes 96 words
:B0X*?:drnik::f("drink") ; Web Freq 60.42 | Fixes 25 words
:B0X*?:dseh::f("dshe") ; Web Freq 6.16 | Fixes 20 words
:B0X*?:dstion::f("dation") ; Web Freq 243.07 | Fixes 121 words
:B0X*?:duect::f("duct") ; Web Freq 1205.88 | Fixes 299 words
:B0X*?:dulgue::f("dulge") ; Web Freq 4.56 | Fixes 23 words
:B0X*?:dupicat::f("duplicat") ; Web Freq 16.41 | Fixes 34 words
:B0X*?:durig::f("during") ; Web Freq 208.65 | Fixes 8 words
:B0X*?:durring::f("during") ; Web Freq 208.65 | Fixes 8 words
:B0X*?:duting::f("during") ; Web Freq 208.65 | Fixes 8 words
:B0X*?:dyness::f("diness") ; Web Freq 4.61 | Fixes 99 words
:B0X*?:eacg::f("each") ; Web Freq 779.37 | Fixes 212 words
:B0X*?:eacll::f("ecall") ; Web Freq 20.17 | Fixes 13 words
:B0X*?:eallt::f("ealt") ; Web Freq 605.63 | Fixes 68 words
:B0X*?:ealted::f("elated") ; Web Freq 239.67 | Fixes 33 words
:B0X*?:eamile::f("emaile") ; Web Freq 3.81 | Fixes 6 words
:B0X*?:eamili::f("emaili") ; Web Freq 1.45 | Fixes 2 words
:B0X*?:eamils::f("emails") ; Web Freq 13.38 | Fixes 4 words
:B0X*?:eannor::f("eanor") ; Web Freq 2.26 | Fixes 4 words
:B0X*?:eanr::f("earn") ; Web Freq 403.72 | Fixes 92 words
:B0X*?:eaolog::f("eolog") ; Web Freq 45.83 | Fixes 167 words
:B0X*?:eareanc::f("earanc") ; Web Freq 46.34 | Fixes 14 words
:B0X*?:earence::f("earance") ; Web Freq 46.34 | Fixes 14 words
:B0X*?:earren::f("earran") ; Web Freq 2.07 | Fixes 12 words
:B0X*?:easeer::f("easier") ; Web Freq 26.86 | Fixes 5 words
:B0X*?:easen::f("easan") ; Web Freq 19.01 | Fixes 39 words, but misspells peasen (An archaic plural form of "pea")
:B0X*?:eatile::f("etaile") ; Web Freq 72.50 | Fixes 12 words
:B0X*?:eatili::f("etaili") ; Web Freq 8.55 | Fixes 5 words
:B0X*?:eatils::f("etails") ; Web Freq 281.61 | Fixes 12 words
:B0X*?:ecco::f("eco") ; Web Freq 1428.15 | Fixes 1293 words, but misspells Prosecco (Italian wine), recco (abbrev. for Reconnaissance)
:B0X*?:eccu::f("ecu") ; Web Freq 601.36 | Fixes 462 words
:B0X*?:eceed::f("ecede") ; Web Freq 14.52 | Fixes 38 words
:B0X*?:eceoa::f("ecoa") ; Web Freq 0.48 | Fixes 22 words
:B0X*?:eceoc::f("ecoc") ; Web Freq 1.20 | Fixes 35 words
:B0X*?:eceod::f("ecod") ; Web Freq 9.96 | Fixes 31 words
:B0X*?:eceog::f("ecog") ; Web Freq 79.02 | Fixes 60 words
:B0X*?:eceoi::f("ecoi") ; Web Freq 0.90 | Fixes 21 words
:B0X*?:eceol::f("ecol") ; Web Freq 23.75 | Fixes 155 words
:B0X*?:eceom::f("ecom") ; Web Freq 392.89 | Fixes 192 words
:B0X*?:eceon::f("econ") ; Web Freq 487.28 | Fixes 470 words
:B0X*?:eceor::f("ecor") ; Web Freq 341.10 | Fixes 100 words
:B0X*?:eceos::f("ecos") ; Web Freq 11.20 | Fixes 24 words
:B0X*?:eceot::f("ecot") ; Web Freq 1.49 | Fixes 39 words
:B0X*?:eceou::f("ecou") ; Web Freq 6.17 | Fixes 43 words
:B0X*?:eceov::f("ecov") ; Web Freq 58.10 | Fixes 24 words
:B0X*?:eceoy::f("ecoy") ; Web Freq 0.91 | Fixes 6 words
:B0X*?:ecepi::f("ecipi") ; Web Freq 29.44 | Fixes 42 words
:B0X*?:eclisp::f("eclips") ; Web Freq 9.23 | Fixes 9 words
:B0X*?:econtit::f("econstit") ; Web Freq 0.95 | Fixes 6 words
:B0X*?:ecrib::f("escrib") ; Web Freq 108.21 | Fixes 36 words
:B0X*?:ectem::f("ectm") ; Web Freq 0.66 | Fixes 5 words
:B0X*?:ecuat::f("equat") ; Web Freq 54.63 | Fixes 32 words
:B0X*?:ecyl::f("ecycl") ; Web Freq 23.80 | Fixes 20 words
:B0X*?:edabl::f("edibl") ; Web Freq 21.65 | Fixes 16 words, but misspells feedable (Able to be fed.  Not really a word)
:B0X*?:edein::f("edien") ; Web Freq 23.47 | Fixes 33 words
:B0X*?:editro::f("editor") ; Web Freq 130.66 | Fixes 35 words
:B0X*?:eearl::f("earl") ; Web Freq 244.74 | Fixes 95 words
:B0X*?:eeen::f("een") ; Web Freq 1758.00 | Fixes 675 words
:B0X*?:eeep::f("eep") ; Web Freq 368.70 | Fixes 431 words
:B0X*?:eelei::f("eelie") ; Web Freq 0.32 | Fixes 9 words
:B0X*?:eemsd::f("eemed") ; Web Freq 32.54 | Fixes 16 words
:B0X*?:eesag::f("essag") ; Web Freq 495.36 | Fixes 9 words
:B0X*?:eferan::f("eferen") ; Web Freq 210.46 | Fixes 41 words
:B0X*?:efered::f("eferred") ; Web Freq 54.03 | Fixes 6 words
:B0X*?:efern::f("eferen") ; Web Freq 210.46 | Fixes 41 words
:B0X*?:effeci::f("effici") ; Web Freq 65.13 | Fixes 16 words
:B0X*?:efinat::f("efinit") ; Web Freq 92.67 | Fixes 28 words
:B0X*?:efineab::f("efinab") ; Web Freq 0.60 | Fixes 16 words
:B0X*?:efious::f("evious") ; Web Freq 231.13 | Fixes 8 words
:B0X*?:efoer::f("efore") ; Web Freq 343.30 | Fixes 20 words
:B0X*?:egth::f("ength") ; Web Freq 133.34 | Fixes 43 words
:B0X*?:eidt::f("edit") ; Web Freq 671.54 | Fixes 203 words
:B0X*?:eild::f("ield") ; Web Freq 341.02 | Fixes 200 words
:B0X*?:elavan::f("elevan") ; Web Freq 57.93 | Fixes 17 words
:B0X*?:elcti::f("electi") ; Web Freq 163.68 | Fixes 56 words
:B0X*?:elecat::f("elevat") ; Web Freq 19.36 | Fixes 23 words
:B0X*?:electic::f("electric") ; Web Freq 106.52 | Fixes 55 words
:B0X*?:electria::f("electrica") ; Web Freq 35.27 | Fixes 15 words
:B0X*?:eleif::f("elief") ; Web Freq 48.72 | Fixes 12 words
:B0X*?:eleir::f("elier") ; Web Freq 5.31 | Fixes 40 words
:B0X*?:elemin::f("elimin") ; Web Freq 43.12 | Fixes 15 words
:B0X*?:eleopr::f("eloper") ; Web Freq 59.98 | Fixes 10 words
:B0X*?:eletric::f("electric") ; Web Freq 106.52 | Fixes 55 words
:B0X*?:elibib::f("eligib") ; Web Freq 48.52 | Fixes 15 words
:B0X*?:elien::f("elian") ; Web Freq 9.02 | Fixes 31 words
:B0X*?:eligab::f("eligib") ; Web Freq 48.52 | Fixes 15 words
:B0X*?:eligo::f("eligio") ; Web Freq 83.06 | Fixes 38 words, but misspells Heligoland (a small German archipelago)
:B0X*?:eliiib::f("eligib") ; Web Freq 48.52 | Fixes 15 words
:B0X*?:elimen::f("elemen") ; Web Freq 106.24 | Fixes 22 words
:B0X*?:eloda::f("eload") ; Web Freq 12.79 | Fixes 23 words
:B0X*?:elyhood::f("elihood") ; Web Freq 7.76 | Fixes 6 words
:B0X*?:embaac::f("embrac") ; Web Freq 9.05 | Fixes 22 words
:B0X*?:embac::f("embrac") ; Web Freq 9.05 | Fixes 22 words
:B0X*?:embaras::f("embarras") ; Web Freq 5.14 | Fixes 18 words
:B0X*?:emce::f("ence") ; Web Freq 1577.12 | Fixes 958 words, but misspells emcee (host at formal occasion)
:B0X*?:emiting::f("emitting") ; Web Freq 1.38 | Fixes 7 words
:B0X*?:emmedi::f("immedi") ; Web Freq 62.76 | Fixes 8 words
:B0X*?:emmig::f("emig") ; Web Freq 2.96 | Fixes 37 words
:B0X*?:emmina::f("emina") ; Web Freq 45.36 | Fixes 66 words
:B0X*?:emmis::f("emis") ; Web Freq 88.05 | Fixes 267 words
:B0X*?:emmit::f("emitt") ; Web Freq 5.81 | Fixes 32 words
:B0X*?:emmm::f("emm") ; Web Freq 29.21 | Fixes 135 words
:B0X*?:emntal::f("mental") ; Web Freq 228.25 | Fixes 231 words
:B0X*?:emostr::f("emonstr") ; Web Freq 51.02 | Fixes 52 words
:B0X*?:empahs::f("emphas") ; Web Freq 28.19 | Fixes 54 words
:B0X*?:emperic::f("empiric") ; Web Freq 6.91 | Fixes 13 words
:B0X*?:emphais::f("emphasis") ; Web Freq 17.66 | Fixes 25 words
:B0X*?:emphsis::f("emphasis") ; Web Freq 17.66 | Fixes 25 words
:B0X*?:empiria::f("imperia") ; Web Freq 12.36 | Fixes 20 words
:B0X*?:emprison::f("imprison") ; Web Freq 4.80 | Fixes 11 words
:B0X*?:empry::f("empty") ; Web Freq 26.98 | Fixes 4 words
:B0X*?:enchang::f("enchant") ; Web Freq 5.30 | Fixes 30 words
:B0X*?:encial::f("ential") ; Web Freq 234.46 | Fixes 163 words
:B0X*?:enciat::f("entiat") ; Web Freq 9.71 | Fixes 34 words
:B0X*?:endand::f("endant") ; Web Freq 37.98 | Fixes 19 words
:B0X*?:enduc::f("induc") ; Web Freq 29.36 | Fixes 51 words
:B0X*?:eneing::f("ening") ; Web Freq 182.42 | Fixes 289 words
:B0X*?:enence::f("enance") ; Web Freq 54.58 | Fixes 23 words
:B0X*?:enflam::f("inflam") ; Web Freq 7.59 | Fixes 30 words
:B0X*?:engagm::f("engagem") ; Web Freq 13.74 | Fixes 8 words
:B0X*?:engeneer::f("engineer") ; Web Freq 131.45 | Fixes 21 words
:B0X*?:engieneer::f("engineer") ; Web Freq 131.45 | Fixes 21 words
:B0X*?:engten::f("engthen") ; Web Freq 17.03 | Fixes 21 words
:B0X*?:enss::f("ness") ; Web Freq 1095.77 | Fixes 9296 words, but misspells OpenSSL (Computer stuff), rensselaerite (a kind of soft talc)
:B0X*?:entagl::f("entangl") ; Web Freq 1.51 | Fixes 21 words
:B0X*?:entaly::f("entally") ; Web Freq 16.41 | Fixes 48 words
:B0X*?:entatr::f("entar") ; Web Freq 81.58 | Fixes 99 words
:B0X*?:entce::f("ence") ; Web Freq 1577.12 | Fixes 958 words
:B0X*?:entgh::f("ength") ; Web Freq 133.34 | Fixes 43 words
:B0X*?:enthusiat::f("enthusiast") ; Web Freq 10.90 | Fixes 8 words
:B0X*?:envok::f("invok") ; Web Freq 6.84 | Fixes 11 words
:B0X*?:envolu::f("evolu") ; Web Freq 61.37 | Fixes 70 words
:B0X*?:enxt::f("next") ; Web Freq 436.23 | Fixes 29 words
:B0X*?:eoxigen::f("eoxygen") ; Web Freq 0.04 | Fixes 19 words
:B0X*?:eperat::f("eparat") ; Web Freq 106.00 | Fixes 41 words
:B0X*?:epetan::f("epentan") ; Web Freq 1.27 | Fixes 7 words
:B0X*?:equalibr::f("equilibr") ; Web Freq 7.37 | Fixes 34 words
:B0X*?:equiale::f("equivale") ; Web Freq 30.06 | Fixes 18 words
:B0X*?:equilibi::f("equilibri") ; Web Freq 7.06 | Fixes 17 words
:B0X*?:equilibrum::f("equilibrium") ; Web Freq 6.31 | Fixes 6 words
:B0X*?:equivilan::f("equivalen") ; Web Freq 30.06 | Fixes 18 words
:B0X*?:equivile::f("equivale") ; Web Freq 30.06 | Fixes 18 words
:B0X*?:eragee::f("erage") ; Web Freq 183.49 | Fixes 77 words
:B0X*?:erchen::f("erchan") ; Web Freq 82.56 | Fixes 49 words
:B0X*?:ereance::f("earance") ; Web Freq 46.34 | Fixes 14 words
:B0X*?:eremt::f("erent") ; Web Freq 222.16 | Fixes 117 words
:B0X*?:erionn::f("ersion") ; Web Freq 303.08 | Fixes 74 words
:B0X*?:ernece::f("erence") ; Web Freq 412.96 | Fixes 64 words
:B0X*?:escision::f("ecision") ; Web Freq 116.39 | Fixes 21 words
:B0X*?:escripter::f("escriptor") ; Web Freq 3.72 | Fixes 3 words
:B0X*?:escus::f("iscus") ; Web Freq 228.60 | Fixes 35 words
:B0X*?:esemm::f("esem") ; Web Freq 5.91 | Fixes 20 words
:B0X*?:esential::f("essential") ; Web Freq 58.65 | Fixes 25 words
:B0X*?:esisten::f("esistan") ; Web Freq 31.61 | Fixes 15 words
:B0X*?:esitma::f("estima") ; Web Freq 100.03 | Fixes 43 words
:B0X*?:esnio::f("ensio") ; Web Freq 153.12 | Fixes 123 words
:B0X*?:esrly::f("estly") ; Web Freq 6.22 | Fixes 12 words
:B0X*?:essense::f("essence") ; Web Freq 8.32 | Fixes 4 words
:B0X*?:essentail::f("essential") ; Web Freq 58.65 | Fixes 25 words
:B0X*?:essentual::f("essential") ; Web Freq 58.65 | Fixes 25 words
:B0X*?:estabish::f("establish") ; Web Freq 110.23 | Fixes 41 words
:B0X*?:estsd::f("ested") ; Web Freq 160.76 | Fixes 88 words
:B0X*?:esxual::f("sexual") ; Web Freq 77.87 | Fixes 116 words
:B0X*?:etanc::f("etenc") ; Web Freq 12.42 | Fixes 24 words
:B0X*?:etead::f("eated") ; Web Freq 140.55 | Fixes 79 words
:B0X*?:ethime::f("etime") ; Web Freq 69.05 | Fixes 21 words
:B0X*?:euise::f("euse") ; Web Freq 6.62 | Fixes 52 words
:B0X*?:eurra::f("eura") ; Web Freq 8.06 | Fixes 42 words
:B0X*?:evalved::f("evolved") ; Web Freq 5.35 | Fixes 5 words
:B0X*?:evison::f("evision") ; Web Freq 90.13 | Fixes 18 words 
:B0X*?:evle::f("evel") ; Web Freq 886.15 | Fixes 155 words
:B0X*?:evlluation::f("evaluation") ; Web Freq 53.09 | Fixes 14 words
:B0X*?:evsion::f("evision") ; Web Freq 90.13 | Fixes 18 words
:B0X*?:exagerat::f("exaggerat") ; Web Freq 2.44 | Fixes 20 words
:B0X*?:exagerrat::f("exaggerat") ; Web Freq 2.44 | Fixes 20 words
:B0X*?:exampt::f("exempt") ; Web Freq 19.43 | Fixes 13 words
:B0X*?:exapan::f("expan") ; Web Freq 89.08 | Fixes 49 words
:B0X*?:excact::f("exact") ; Web Freq 55.35 | Fixes 31 words
:B0X*?:excang::f("exchang") ; Web Freq 92.29 | Fixes 14 words
:B0X*?:excec::f("exec") ; Web Freq 146.34 | Fixes 55 words
:B0X*?:excedd::f("exceed") ; Web Freq 28.34 | Fixes 13 words
:B0X*?:excerc::f("exerc") ; Web Freq 56.37 | Fixes 21 words
:B0X*?:exchanch::f("exchang") ; Web Freq 92.29 | Fixes 14 words
:B0X*?:excist::f("exist") ; Web Freq 129.54 | Fixes 46 words
:B0X*?:execis::f("exercis") ; Web Freq 56.35 | Fixes 17 words
:B0X*?:exectued::f("executed") ; Web Freq 8.90 | Fixes 3 words
:B0X*?:exeed::f("exceed") ; Web Freq 28.34 | Fixes 13 words
:B0X*?:exemple::f("example") ; Web Freq 169.63 | Fixes 7 words
:B0X*?:exept::f("except") ; Web Freq 92.15 | Fixes 31 words
:B0X*?:exersize::f("exercise") ; Web Freq 53.38 | Fixes 13 words
:B0X*?:exict::f("excit") ; Web Freq 38.85 | Fixes 58 words
:B0X*?:exinct::f("extinct") ; Web Freq 3.71 | Fixes 8 words
:B0X*?:exisit::f("exist") ; Web Freq 129.54 | Fixes 46 words
:B0X*?:existan::f("existen") ; Web Freq 19.84 | Fixes 27 words
:B0X*?:exlile::f("exile") ; Web Freq 4.01 | Fixes 7 words
:B0X*?:exmapl::f("exampl") ; Web Freq 169.63 | Fixes 8 words
:B0X*?:exonor::f("exoner") ; Web Freq 0.41 | Fixes 7 words
:B0X*?:expalin::f("explain") ; Web Freq 61.22 | Fixes 24 words
:B0X*?:expeced::f("expected") ; Web Freq 62.71 | Fixes 8 words
:B0X*?:expecial::f("especial") ; Web Freq 59.89 | Fixes 5 words
:B0X*?:experian::f("experien") ; Web Freq 193.43 | Fixes 20 words
:B0X*?:expidi::f("expedi") ; Web Freq 18.51 | Fixes 37 words
:B0X*?:expierenc::f("experienc") ; Web Freq 192.22 | Fixes 16 words
:B0X*?:expirien::f("experien") ; Web Freq 193.43 | Fixes 20 words
:B0X*?:explanit::f("explanat") ; Web Freq 22.54 | Fixes 8 words
:B0X*?:explict::f("explicit") ; Web Freq 16.00 | Fixes 9 words
:B0X*?:explotat::f("exploitat") ; Web Freq 4.33 | Fixes 12 words
:B0X*?:exprienc::f("experienc") ; Web Freq 192.22 | Fixes 16 words
:B0X*?:exress::f("express") ; Web Freq 140.05 | Fixes 64 words
:B0X*?:exsis::f("exis") ; Web Freq 131.10 | Fixes 58 words
:B0X*?:exsst::f("exist") ; Web Freq 129.54 | Fixes 46 words
:B0X*?:extention::f("extension") ; Web Freq 47.21 | Fixes 12 words
:B0X*?:extint::f("extinct") ; Web Freq 3.71 | Fixes 8 words
:B0X*?:extravagen::f("extravagan") ; Web Freq 1.91 | Fixes 10 words
:B0X*?:extrordin::f("extraordin") ; Web Freq 9.91 | Fixes 6 words
:B0X*?:facist::f("fascist") ; Web Freq 1.63 | Fixes 11 words
:B0X*?:facor::f("favor") ; Web Freq 119.41 | Fixes 36 words
:B0X*?:faet::f("feat") ; Web Freq 339.95 | Fixes 89 words
:B0X*?:fagia::f("phagia") ; Web Freq 0.39 | Fixes 20 words
:B0X*?:falab::f("fallib") ; Web Freq 0.79 | Fixes 10 words
:B0X*?:fallab::f("fallib") ; Web Freq 0.79 | Fixes 10 words
:B0X*?:famila::f("familia") ; Web Freq 22.70 | Fixes 46 words
:B0X*?:familes::f("families") ; Web Freq 47.52 | Fixes 5 words
:B0X*?:familli::f("famili") ; Web Freq 70.22 | Fixes 55 words
:B0X*?:fammi::f("fami") ; Web Freq 328.90 | Fixes 76 words
:B0X*?:fascit::f("facet") ; Web Freq 4.69 | Fixes 18 words, but misspells fascitis (A medical term)
:B0X*?:fasia::f("phasia") ; Web Freq 0.32 | Fixes 12 words
:B0X*?:fature::f("facture") ; Web Freq 115.39 | Fixes 15 words
:B0X*?:faught::f("fought") ; Web Freq 5.54 | Fixes 8 words
:B0X*?:fautt::f("fault") ; Web Freq 77.70 | Fixes 34 words
:B0X*?:favir::f("favor") ; Web Freq 119.41 | Fixes 36 words
:B0X*?:feasable::f("feasible") ; Web Freq 4.64 | Fixes 10 words
:B0X*?:fectuo::f("fectio") ; Web Freq 43.10 | Fixes 64 words
:B0X*?:fedre::f("feder") ; Web Freq 227.17 | Fixes 60 words
:B0X*?:feedaack::f("feedback") ; Web Freq 152.48 | Fixes 5 words
:B0X*?:femmi::f("femi") ; Web Freq 10.87 | Fixes 82 words
:B0X*?:fencive::f("fensive") ; Web Freq 16.11 | Fixes 19 words
:B0X*?:ferec::f("ferenc") ; Web Freq 416.89 | Fixes 56 words
:B0X*?:ferente::f("ference") ; Web Freq 406.93 | Fixes 44 words
:B0X*?:feriang::f("ferring") ; Web Freq 12.34 | Fixes 12 words
:B0X*?:ferren::f("feren") ; Web Freq 630.06 | Fixes 133 words
:B0X*?:fesser::f("fessor") ; Web Freq 46.02 | Fixes 15 words
:B0X*?:festion::f("festation") ; Web Freq 3.94 | Fixes 8 words
:B0X*?:fferr::f("ffer") ; Web Freq 729.57 | Fixes 219 words
:B0X*?:fficen::f("fficien") ; Web Freq 98.13 | Fixes 26 words
:B0X*?:ffoer::f("ffore") ; Web Freq 0.20 | Fixes 21 words
:B0X*?:ffred::f("ffered") ; Web Freq 61.13 | Fixes 13 words
:B0X*?:fialr::f("filar") ; Web Freq 0.14 | Fixes 22 words
:B0X*?:fianit::f("finit") ; Web Freq 117.65 | Fixes 62 words
:B0X*?:fictious::f("fictitious") ; Web Freq 0.94 | Fixes 4 words
:B0X*?:ficur::f("figur") ; Web Freq 205.31 | Fixes 98 words
:B0X*?:fieed::f("fixed") ; Web Freq 50.73 | Fixes 17 words
:B0X*?:fileer::f("filter") ; Web Freq 83.87 | Fixes 17 words
:B0X*?:filiament::f("filament") ; Web Freq 2.04 | Fixes 14 words
:B0X*?:filitrat::f("filtrat") ; Web Freq 6.10 | Fixes 25 words
:B0X*?:filld::f("field") ; Web Freq 297.11 | Fixes 141 words
:B0X*?:fimil::f("famil") ; Web Freq 327.23 | Fixes 65 words
:B0X*?:finac::f("financ") ; Web Freq 302.56 | Fixes 33 words
:B0X*?:finati::f("finiti") ; Web Freq 70.73 | Fixes 25 words
:B0X*?:finatu::f("finitu") ; Web Freq 0.06 | Fixes 6 words
:B0X*?:firend::f("friend") ; Web Freq 621.53 | Fixes 49 words
:B0X*?:firmm::f("firm") ; Web Freq 153.50 | Fixes 105 words
:B0X*?:firts::f("first") ; Web Freq 582.35 | Fixes 14 words
:B0X*?:fised::f("fixed") ; Web Freq 50.73 | Fixes 17 words
:B0X*?:fises::f("fixes") ; Web Freq 9.94 | Fixes 15 words
:B0X*?:fisip::f("fissip") ; Fixes 9 words
:B0X*?:flama::f("flamma") ; Web Freq 8.63 | Fixes 23 words
:B0X*?:flixib::f("flexib") ; Web Freq 33.47 | Fixes 12 words
:B0X*?:flourin::f("fluorin") ; Web Freq 0.45 | Fixes 10 words, but misspells flouriness (being flour-like)
:B0X*?:fluan::f("fluen") ; Web Freq 56.45 | Fixes 72 words
:B0X*?:fluente::f("fluence") ; Web Freq 40.84 | Fixes 28 words
:B0X*?:fluorish::f("flourish") ; Web Freq 2.68 | Fixes 11 words
:B0X*?:focuss::f("focus") ; Web Freq 107.53 | Fixes 54 words, but Americanizes 19 British words
:B0X*?:foee::f("fore") ; Web Freq 594.20 | Fixes 434 words
:B0X*?:foera::f("forea") ; Web Freq 1.01 | Fixes 4 words
:B0X*?:foerb::f("foreb") ; Web Freq 0.56 | Fixes 24 words
:B0X*?:foerc::f("forec") ; Web Freq 51.54 | Fixes 28 words
:B0X*?:foerd::f("fored") ; Web Freq 0.03 | Fixes 18 words
:B0X*?:foerf::f("foref") ; Web Freq 2.70 | Fixes 18 words
:B0X*?:foerg::f("foreg") ; Web Freq 4.96 | Fixes 18 words
:B0X*?:foerh::f("foreh") ; Web Freq 3.58 | Fixes 13 words
:B0X*?:foeri::f("forei") ; Web Freq 70.75 | Fixes 10 words
:B0X*?:foerk::f("forek") ; Web Freq 0.15 | Fixes 7 words
:B0X*?:foerl::f("forel") ; Web Freq 0.32 | Fixes 13 words
:B0X*?:foerm::f("forem") ; Web Freq 6.39 | Fixes 15 words
:B0X*?:foern::f("foren") ; Web Freq 5.87 | Fixes 10 words
:B0X*?:foero::f("foreo") ; Web Freq 0.03 | Fixes 6 words
:B0X*?:foerp::f("forep") ; Web Freq 0.48 | Fixes 12 words
:B0X*?:foerr::f("forer") ; Web Freq 0.65 | Fixes 12 words
:B0X*?:foers::f("fores") ; Web Freq 77.13 | Fixes 153 words
:B0X*?:foert::f("foret") ; Web Freq 0.78 | Fixes 32 words
:B0X*?:foerv::f("forev") ; Web Freq 17.46 | Fixes 5 words
:B0X*?:foerw::f("forew") ; Web Freq 2.06 | Fixes 15 words
:B0X*?:foerx::f("forex") ; Web Freq 3.98 | Fixes 2 words
:B0X*?:folliwing::f("following") ; Web Freq 221.36 | Fixes 4 words
:B0X*?:follwo::f("follow") ; Web Freq 365.53 | Fixes 18 words
:B0X*?:folor::f("color") ; Web Freq 259.22 | Fixes 148 words
:B0X*?:folow::f("follow") ; Web Freq 365.53 | Fixes 18 words
:B0X*?:fomat::f("format") ; Web Freq 1146.64 | Fixes 92 words
:B0X*?:fomed::f("formed") ; Web Freq 100.03 | Fixes 45 words
:B0X*?:fomm::f("from") ; Web Freq 2276.83 | Fixes 8 words
:B0X*?:fomr::f("form") ; Web Freq 2047.97 | Fixes 703 words
:B0X*?:foneti::f("phoneti") ; Web Freq 1.25 | Fixes 18 words
:B0X*?:fontrier::f("frontier") ; Web Freq 8.20 | Fixes 6 words
:B0X*?:fooot::f("foot") ; Web Freq 146.03 | Fixes 203 words
:B0X*?:forbide::f("forbidde") ; Web Freq 5.42 | Fixes 6 words
:B0X*?:forder::f("folder") ; Web Freq 27.91 | Fixes 14 words
:B0X*?:foretu::f("fortu") ; Web Freq 42.18 | Fixes 30 words
:B0X*?:forgeta::f("forgetta") ; Web Freq 2.11 | Fixes 7 words
:B0X*?:forgiveab::f("forgivab") ; Web Freq 0.24 | Fixes 6 words
:B0X*?:forguna::f("fortuna") ; Web Freq 28.56 | Fixes 13 words
:B0X*?:formidib::f("formidab") ; Web Freq 1.32 | Fixes 6 words
:B0X*?:formost::f("foremost") ; Web Freq 2.73 | Fixes 4 words
:B0X*?:forsee::f("foresee") ; Web Freq 3.67 | Fixes 16 words
:B0X*?:forwrd::f("forward") ; Web Freq 75.18 | Fixes 23 words
:B0X*?:foucs::f("focus") ; Web Freq 107.53 | Fixes 54 words
:B0X*?:foudn::f("found") ; Web Freq 354.72 | Fixes 79 words
:B0X*?:fourti::f("forti") ; Web Freq 5.41 | Fixes 32 words
:B0X*?:fourtun::f("fortun") ; Web Freq 41.95 | Fixes 24 words
:B0X*?:foward::f("forward") ; Web Freq 75.18 | Fixes 23 words
:B0X*?:frein::f("frien") ; Web Freq 621.53 | Fixes 49 words
:B0X*?:frence::f("ference") ; Web Freq 406.93 | Fixes 44 words
:B0X*?:fromed::f("formed") ; Web Freq 100.03 | Fixes 45 words
:B0X*?:fromi::f("formi") ; Web Freq 46.25 | Fixes 104 words
:B0X*?:fued::f("feud") ; Web Freq 1.83 | Fixes 51 words, but misspells Snafued (a situation wrought with errors or chaos)
:B0X*?:fufill::f("fulfill") ; Web Freq 14.30 | Fixes 18 words
:B0X*?:fugur::f("figur") ; Web Freq 205.31 | Fixes 98 words
:B0X*?:fuise::f("fuse") ; Web Freq 42.79 | Fixes 83 words
:B0X*?:fulen::f("fluen") ; Web Freq 56.45 | Fixes 72 words
:B0X*?:fulfiled::f("fulfilled") ; Web Freq 3.27 | Fixes 3 words
:B0X*?:fullfill::f("fulfill") ; Web Freq 14.30 | Fixes 18 words
:B0X*?:furra::f("fura") ; Web Freq 0.45 | Fixes 31 words
:B0X*?:furut::f("furt") ; Web Freq 133.87 | Fixes 23 words ; Will it break "future"?
:B0X*?:fuult::f("fault") ; Web Freq 77.70 | Fixes 34 words
:B0X*?:fyness::f("finess") ; Web Freq 0.78 | Fixes 38 words
:B0X*?:gallax::f("galax") ; Web Freq 10.82 | Fixes 8 words
:B0X*?:galvin::f("galvan") ; Web Freq 2.03 | Fixes 29 words, but misspells Galvin (A name)
:B0X*?:ganera::f("genera") ; Web Freq 511.82 | Fixes 139 words
:B0X*?:ganno::f("gano") ; Web Freq 2.25 | Fixes 51 words, but misspells Dungannon (A town in Ireland)
:B0X*?:garant::f("guarant") ; Web Freq 77.19 | Fixes 11 words
:B0X*?:garav::f("grav") ; Web Freq 44.56 | Fixes 152 words
:B0X*?:garnison::f("garrison") ; Web Freq 4.67 | Fixes 5 words
:B0X*?:gauar::f("guar") ; Web Freq 147.77 | Fixes 119 words
:B0X*?:gauran::f("guaran") ; Web Freq 78.23 | Fixes 19 words
:B0X*?:gaurd::f("guard") ; Web Freq 60.99 | Fixes 80 words
:B0X*?:gemer::f("gener") ; Web Freq 547.68 | Fixes 173 words
:B0X*?:generatt::f("generat") ; Web Freq 147.33 | Fixes 71 words
:B0X*?:genuane::f("genuine") ; Web Freq 15.21 | Fixes 5 words
:B0X*?:gestab::f("gestib") ; Web Freq 0.48 | Fixes 22 words
:B0X*?:ggect::f("ffect") ; Web Freq 347.00 | Fixes 95 words
:B0X*?:ggining::f("ginning") ; Web Freq 51.68 | Fixes 7 words
:B0X*?:gicial::f("gical") ; Web Freq 142.97 | Fixes 464 words
:B0X*?:gloabl::f("global") ; Web Freq 104.22 | Fixes 20 words
:B0X*?:gnaww::f("gnaw") ; Web Freq 0.35 | Fixes 16 words
:B0X*?:gnficia::f("gnifica") ; Web Freq 92.96 | Fixes 34 words
:B0X*?:gnizen::f("gnizan") ; Web Freq 0.76 | Fixes 9 words
:B0X*?:godess::f("goddess") ; Web Freq 5.50 | Fixes 5 words
:B0X*?:gooten::f("gotten") ; Web Freq 22.16 | Fixes 9 words
:B0X*?:gorund::f("ground") ; Web Freq 179.46 | Fixes 98 words
:B0X*?:gourp::f("group") ; Web Freq 472.11 | Fixes 55 words
:B0X*?:govement::f("government") ; Web Freq 235.46 | Fixes 29 words
:B0X*?:govenment::f("government") ; Web Freq 235.46 | Fixes 29 words
:B0X*?:govenrment::f("government") ; Web Freq 235.46 | Fixes 29 words
:B0X*?:govera::f("governa") ; Web Freq 13.70 | Fixes 11 words
:B0X*?:goverment::f("government") ; Web Freq 235.46 | Fixes 29 words
:B0X*?:govorm::f("governme") ; Web Freq 235.46 | Fixes 29 words
:B0X*?:graet::f("great") ; Web Freq 396.83 | Fixes 20 words 
:B0X*?:graffitti::f("graffiti") ; Web Freq 3.06 | Fixes 8 words
:B0X*?:grama::f("gramma") ; Web Freq 16.32 | Fixes 85 words, but misspells grama (Pasture grass)
:B0X*?:greatful::f("grateful") ; Web Freq 7.01 | Fixes 12 words
:B0X*?:grede::f("grade") ; Web Freq 135.96 | Fixes 70 words
:B0X*?:gropu::f("group") ; Web Freq 472.11 | Fixes 55 words
:B0X*?:grouth::f("growth") ; Web Freq 81.32 | Fixes 28 words
:B0X*?:gruop::f("group") ; Web Freq 472.11 | Fixes 55 words
:B0X*?:gstion::f("gation") ; Web Freq 180.61 | Fixes 149 words
:B0X*?:gueme::f("gume") ; Web Freq 54.59 | Fixes 42 words
:B0X*?:guiden::f("guidan") ; Web Freq 23.72 | Fixes 4 words
:B0X*?:gurantee::f("guarantee") ; Web Freq 75.22 | Fixes 5 words
:B0X*?:gurra::f("gura") ; Web Freq 52.20 | Fixes 72 words
:B0X*?:habbit::f("habit") ; Web Freq 36.78 | Fixes 81 words
:B0X*?:habitans::f("habitants") ; Web Freq 3.89 | Fixes 3 words
:B0X*?:habition::f("hibition") ; Web Freq 33.13 | Fixes 21 words
:B0X*?:haev::f("have") ; Web Freq 1610.90 | Fixes 70 words was ::haev::have
:B0X*?:hainvg::f("having") ; Web Freq 113.43 | Fixes 6 words
:B0X*?:hallt::f("halt") ; Web Freq 11.69 | Fixes 35 words
:B0X*?:haneg::f("hange") ; Web Freq 503.32 | Fixes 101 words
:B0X*?:havour::f("havior") ; Web Freq 45.34 | Fixes 21 words
:B0X*?:havpen::f("happen") ; Web Freq 86.29 | Fixes 16 words
:B0X*?:heee::f("hee") ; Web Freq 246.01 | Fixes 502 words
:B0X*?:heirarch::f("hierarch") ; Web Freq 10.59 | Fixes 19 words
:B0X*?:heirog::f("hierog") ; Web Freq 0.46 | Fixes 8 words
:B0X*?:heiv::f("hiev") ; Web Freq 78.82 | Fixes 63 words
:B0X*?:helath::f("health") ; Web Freq 504.64 | Fixes 25 words
:B0X*?:herant::f("herent") ; Web Freq 11.13 | Fixes 11 words
:B0X*?:heridit::f("heredit") ; Web Freq 1.70 | Fixes 19 words
:B0X*?:hertia::f("herita") ; Web Freq 29.42 | Fixes 24 words
:B0X*?:hertzs::f("hertz") ; Web Freq 4.01 | Fixes 16 words
:B0X*?:hialr::f("hilar") ; Web Freq 9.48 | Fixes 18 words
:B0X*?:hibt::f("hibit") ; Web Freq 103.69 | Fixes 79 words
:B0X*?:hicial::f("hical") ; Web Freq 45.57 | Fixes 203 words
:B0X*?:hierach::f("hierarch") ; Web Freq 10.59 | Fixes 19 words
:B0X*?:hierarci::f("hierarchi") ; Web Freq 4.03 | Fixes 15 words
:B0X*?:higwa::f("highwa") ; Web Freq 29.95 | Fixes 8 words
:B0X*?:hiull::f("hill") ; Web Freq 240.54 | Fixes 159 words
:B0X*?:hoo;::f("hool") ; Web Freq 485.60 | Fixes 114 words
:B0X*?:hospiti::f("hospita") ; Web Freq 92.99 | Fixes 42 words
:B0X*?:houdn::f("hound") ; Web Freq 10.11 | Fixes 53 words
:B0X*?:houise::f("house") ; Web Freq 394.71 | Fixes 363 words 
:B0X*?:houno::f("hono") ; Web Freq 63.42 | Fixes 134 words
:B0X*?:hraet::f("hreat") ; Web Freq 46.29 | Fixes 25 words 
:B0X*?:hstor::f("histor") ; Web Freq 297.12 | Fixes 74 words
:B0X*?:humerous::f("humorous") ; Web Freq 2.92 | Fixes 7 words
:B0X*?:humur::f("humour") ; Web Freq 5.10 | Fixes 12 words
:B0X*?:hvee::f("have") ; Web Freq 1610.90 | Fixes 70 words
:B0X*?:hwere::f("where") ; Web Freq 463.59 | Fixes 39 words
:B0X*?:hydog::f("hydrog") ; Web Freq 11.75 | Fixes 53 words
:B0X*?:hygein::f("hygien") ; Web Freq 6.45 | Fixes 20 words
:B0X*?:hymm::f("hym") ; Web Freq 13.82 | Fixes 184 words
:B0X*?:ialbe::f("iable") ; Web Freq 110.07 | Fixes 165 words
:B0X*?:ialliz::f("ializ") ; Web Freq 44.44 | Fixes 224 words
:B0X*?:ialra::f("ilara") ; Web Freq 0.82 | Fixes 10 words
:B0X*?:ialri::f("ilari") ; Web Freq 11.61 | Fixes 31 words
:B0X*?:ialrl::f("ilarl") ; Web Freq 10.10 | Fixes 5 words
:B0X*?:ianno::f("iano") ; Web Freq 29.35 | Fixes 32 words
:B0X*?:ibile::f("ible") ; Web Freq 553.34 | Fixes 478 words
:B0X*?:ibilt::f("ibilit") ; Web Freq 182.41 | Fixes 302 words
:B0X*?:iblit::f("ibilit") ; Web Freq 182.41 | Fixes 302 words
:B0X*?:ibti::f("ibiti") ; Web Freq 37.43 | Fixes 37 words
:B0X*?:ibto::f("ibito") ; Web Freq 13.65 | Fixes 14 words
:B0X*?:icibl::f("iceabl") ; Web Freq 3.10 | Fixes 18 words
:B0X*?:iciton::f("iction") ; Web Freq 184.99 | Fixes 122 words
:B0X*?:ictem::f("ictm") ; Web Freq 2.45 | Fixes 4 words
:B0X*?:idecen::f("idescen") ; Web Freq 0.46 | Fixes 5 words
:B0X*?:idenital::f("idential") ; Web Freq 59.30 | Fixes 22 words
:B0X*?:ieldl::f("ield") ; Web Freq 341.02 | Fixes 200 words
:B0X*?:ifiy::f("ify") ; Web Freq 201.79 | Fixes 446 words
:B0X*?:igeou::f("igiou") ; Web Freq 41.17 | Fixes 32 words, but misspells epigeous (plants or fungi that grow above ground)
:B0X*?:igini::f("igni") ; Web Freq 134.15 | Fixes 156 words
:B0X*?:ignf::f("ignif") ; Web Freq 96.13 | Fixes 58 words
:B0X*?:ignot::f("ignor") ; Web Freq 34.88 | Fixes 51 words
:B0X*?:igous::f("igious") ; Web Freq 41.17 | Fixes 32 words, but misspells pemphigous (a skin disease)
:B0X*?:igth::f("ight") ; Web Freq 2659.84 | Fixes 1044 words from Jack Dunning's book :)
:B0X*?:ilair::f("iliar") ; Web Freq 27.31 | Fixes 54 words
:B0X*?:illedg::f("illeg") ; Web Freq 24.66 | Fixes 29 words
:B0X*?:illk::f("ill") ; Web Freq 3534.96 | Fixes 2501 words
:B0X*?:illution::f("illusion") ; Web Freq 6.09 | Fixes 18 words
:B0X*?:imagen::f("imagin") ; Web Freq 52.03 | Fixes 49 words
:B0X*?:imco::f("inco") ; Web Freq 192.77 | Fixes 326 words, but misspells skimcoat (Draywall coat with a mixture of gypsum and spackle)
:B0X*?:immita::f("imita") ; Web Freq 26.36 | Fixes 48 words
:B0X*?:immm::f("imm") ; Web Freq 214.92 | Fixes 569 words
:B0X*?:implim::f("implem") ; Web Freq 110.80 | Fixes 24 words
:B0X*?:imploy::f("employ") ; Web Freq 270.52 | Fixes 61 words
:B0X*?:imporaa::f("importa") ; Web Freq 170.44 | Fixes 21 words
:B0X*?:imporat::f("importa") ; Web Freq 170.44 | Fixes 21 words
:B0X*?:importen::f("importan") ; Web Freq 169.08 | Fixes 11 words
:B0X*?:imprion::f("imprison") ; Web Freq 4.80 | Fixes 11 words
:B0X*?:improbe::f("improve") ; Web Freq 149.86 | Fixes 10 words
:B0X*?:improt::f("import") ; Web Freq 225.46 | Fixes 46 words
:B0X*?:incede::f("incide") ; Web Freq 37.29 | Fixes 23 words
:B0X*?:incidentia::f("incidenta") ; Web Freq 5.50 | Fixes 6 words
:B0X*?:incra::f("incre") ; Web Freq 219.21 | Fixes 36 words
:B0X*?:inctro::f("intro") ; Web Freq 143.15 | Fixes 82 words
:B0X*?:indeca::f("indica") ; Web Freq 115.88 | Fixes 41 words
:B0X*?:indend::f("intend") ; Web Freq 72.25 | Fixes 30 words
:B0X*?:indenp::f("indep") ; Web Freq 101.41 | Fixes 12 words
:B0X*?:indite::f("indict") ; Web Freq 4.39 | Fixes 32 words, but misspells indite (Produce a literary work)
:B0X*?:indutr::f("industr") ; Web Freq 261.66 | Fixes 67 words
:B0X*?:indvid::f("individ") ; Web Freq 151.43 | Fixes 36 words
:B0X*?:inece::f("ience") ; Web Freq 471.21 | Fixes 117 words
:B0X*?:ineing::f("ining") ; Web Freq 415.43 | Fixes 263 words
:B0X*?:inevatib::f("inevitab") ; Web Freq 6.69 | Fixes 7 words
:B0X*?:infite::f("invite") ; Web Freq 30.77 | Fixes 19 words
:B0X*?:infrant::f("infant") ; Web Freq 25.20 | Fixes 32 words
:B0X*?:infrige::f("infringe") ; Web Freq 7.51 | Fixes 8 words
:B0X*?:ingeniu::f("ingeniou") ; Web Freq 0.98 | Fixes 5 words
:B0X*?:inheritage::f("inheritance") ; Web Freq 4.11 | Fixes 4 words
:B0X*?:inheriten::f("inheritan") ; Web Freq 4.11 | Fixes 4 words
:B0X*?:inining::f("ining") ; Web Freq 415.43 | Fixes 263 words
:B0X*?:ininis::f("inis") ; Web Freq 365.28 | Fixes 496 words
:B0X*?:inital::f("initial") ; Web Freq 62.80 | Fixes 39 words
:B0X*?:inllude::f("include") ; Web Freq 387.05 | Fixes 4 words
:B0X*?:inmi::f("immi") ; Web Freq 55.72 | Fixes 111 words, but misspells ginmill (Slang for bar.  Where alcohol is served)
:B0X*?:inng::f("ing") ; Web Freq 18410.23 | Fixes 20290 words
:B0X*?:innocul::f("inocul") ; Web Freq 7.10 | Fixes 29 words
:B0X*?:inpeach::f("impeach") ; Web Freq 2.47 | Fixes 15 words
:B0X*?:inpoli::f("impoli") ; Web Freq 0.21 | Fixes 11 words
:B0X*?:inprison::f("imprison") ; Web Freq 4.80 | Fixes 11 words
:B0X*?:inprov::f("improv") ; Web Freq 171.47 | Fixes 48 words
:B0X*?:inslu::f("inclu") ; Web Freq 623.54 | Fixes 20 words
:B0X*?:institue::f("institute") ; Web Freq 84.90 | Fixes 8 words
:B0X*?:instu::f("instru") ; Web Freq 196.71 | Fixes 50 words
:B0X*?:intelec::f("intellec") ; Web Freq 23.54 | Fixes 52 words
:B0X*?:inteli::f("intelli") ; Web Freq 48.87 | Fixes 30 words
:B0X*?:intenati::f("internati") ; Web Freq 601.81 | Fixes 27 words
:B0X*?:intente::f("intende") ; Web Freq 44.46 | Fixes 15 words
:B0X*?:intepre::f("interpre") ; Web Freq 43.29 | Fixes 45 words
:B0X*?:interation::f("internation") ; Web Freq 601.81 | Fixes 27 words
:B0X*?:interferan::f("interferen") ; Web Freq 6.45 | Fixes 5 words
:B0X*?:intergrat::f("integrat") ; Web Freq 92.08 | Fixes 43 words
:B0X*?:interpet::f("interpret") ; Web Freq 43.29 | Fixes 45 words
:B0X*?:intertain::f("entertain") ; Web Freq 125.72 | Fixes 13 words
:B0X*?:interup::f("interrup") ; Web Freq 12.89 | Fixes 18 words
:B0X*?:intervin::f("interven") ; Web Freq 21.89 | Fixes 21 words
:B0X*?:inteven::f("interven") ; Web Freq 21.89 | Fixes 21 words
:B0X*?:inther::f("inter") ; Web Freq 2202.18 | Fixes 1281 words
:B0X*?:intorm::f("inform") ; Web Freq 1025.70 | Fixes 58 words
:B0X*?:intrdu::f("introdu") ; Web Freq 128.05 | Fixes 17 words
:B0X*?:intrest::f("interest") ; Web Freq 261.20 | Fixes 27 words
:B0X*?:intruduc::f("introduc") ; Web Freq 128.05 | Fixes 17 words
:B0X*?:intrument::f("instrument") ; Web Freq 82.21 | Fixes 21 words
:B0X*?:intut::f("intuit") ; Web Freq 8.56 | Fixes 22 words
:B0X*?:inudst::f("indust") ; Web Freq 262.24 | Fixes 70 words
:B0X*?:inventer::f("inventor") ; Web Freq 30.51 | Fixes 10 words 
:B0X*?:investinga::f("investiga") ; Web Freq 72.22 | Fixes 20 words
:B0X*?:invision::f("envision") ; Web Freq 2.82 | Fixes 8 words
:B0X*?:iodal::f("oidal") ; Web Freq 2.45 | Fixes 87 words
:B0X*?:iousit::f("iosit") ; Web Freq 3.32 | Fixes 22 words
:B0X*?:irita::f("irrita") ; Web Freq 6.73 | Fixes 30 words
:B0X*?:irtse::f("irste") ; Web Freq 0.02 | Fixes 7 words
:B0X*?:irtsi::f("irsti") ; Web Freq 0.06 | Fixes 11 words
:B0X*?:iseh::f("ishe") ; Web Freq 386.24 | Fixes 569 words, but misspells Eskisehir (A city in Turkey)
:B0X*?:isemm::f("isem") ; Web Freq 44.55 | Fixes 102 words
:B0X*?:isherr::f("isher") ; Web Freq 116.80 | Fixes 114 words
:B0X*?:ishor::f("isher") ; Web Freq 116.80 | Fixes 114 words
:B0X*?:ishre::f("isher") ; Web Freq 116.80 | Fixes 114 words
:B0X*?:isile::f("issile") ; Web Freq 8.34 | Fixes 15 words
:B0X*?:isment::f("isement") ; Web Freq 42.85 | Fixes 22 words
:B0X*?:issence::f("issance") ; Web Freq 18.28 | Fixes 15 words
:B0X*?:istsd::f("isted") ; Web Freq 154.19 | Fixes 70 words
:B0X*?:itina::f("itiona") ; Web Freq 217.07 | Fixes 94 words, but misspells Mephitinae (skunk), neritina (snail)
:B0X*?:itionna::f("itiona") ; Web Freq 217.07 | Fixes 94 words
:B0X*?:ititia::f("initia") ; Web Freq 121.13 | Fixes 61 words
:B0X*?:itition::f("ition") ; Web Freq 1278.62 | Fixes 459 words
:B0X*?:itnere::f("intere") ; Web Freq 261.71 | Fixes 40 words
:B0X*?:itnro::f("intro") ; Web Freq 143.15 | Fixes 82 words
:B0X*?:itoin::f("ition") ; Web Freq 1278.62 | Fixes 459 words
:B0X*?:itttle::f("ittle") ; Web Freq 191.41 | Fixes 60 words
:B0X*?:iveing::f("iving") ; Web Freq 266.88 | Fixes 104 words
:B0X*?:ivelan::f("ivalen") ; Web Freq 31.14 | Fixes 49 words
:B0X*?:iverous::f("ivorous") ; Web Freq 0.56 | Fixes 18 words
:B0X*?:ivison::f("ivision") ; Web Freq 88.65 | Fixes 19 words 
:B0X*?:ivle::f("ivel") ; Web Freq 133.31 | Fixes 622 words, but misspells braaivleis (Type of S. African BBQ)
:B0X*?:iwll::f("will") ; Web Freq 1514.90 | Fixes 106 words
:B0X*?:iwth::f("with") ; Web Freq 3703.67 | Fixes 82 words
:B0X*?:jist::f("gist") ; Web Freq 417.36 | Fixes 697 words, but misspells swarajist (Supporter of self-government, India)
:B0X*?:jorunal::f("journal") ; Web Freq 163.54 | Fixes 33 words
:B0X*?:jstu::f("just") ; Web Freq 645.00 | Fixes 108 words
:B0X*?:jsut::f("just") ; Web Freq 645.00 | Fixes 108 words
:B0X*?:judical::f("judicial") ; Web Freq 13.24 | Fixes 11 words
:B0X*?:judisua::f("judicia") ; Web Freq 18.31 | Fixes 13 words
:B0X*?:juduci::f("judici") ; Web Freq 18.93 | Fixes 24 words
:B0X*?:jugment::f("judgment") ; Web Freq 18.97 | Fixes 12 words
:B0X*?:jurra::f("jura") ; Web Freq 3.89 | Fixes 22 words
:B0X*?:jurring::f("juring") ; Web Freq 0.65 | Fixes 8 words
:B0X*?:kindergard::f("kindergart") ; Web Freq 5.34 | Fixes 8 words
:B0X*?:kiull::f("kill") ; Web Freq 184.41 | Fixes 99 words
:B0X*?:kloda::f("kload") ; Web Freq 3.78 | Fixes 10 words
:B0X*?:knowldeg::f("knowledg") ; Web Freq 124.75 | Fixes 36 words
:B0X*?:knowldg::f("knowledg") ; Web Freq 124.75 | Fixes 36 words
:B0X*?:knowleg::f("knowledg") ; Web Freq 124.75 | Fixes 36 words
:B0X*?:knwo::f("know") ; Web Freq 609.38 | Fixes 81 words
:B0X*?:kwno::f("know") ; Web Freq 609.38 | Fixes 81 words
:B0X*?:kwwp::f("keep") ; Web Freq 178.89 | Fixes 95 words
:B0X*?:kyness::f("kiness") ; Web Freq 0.69 | Fixes 166 words
:B0X*?:laas::f("leas") ; Web Freq 837.66 | Fixes 150 words, but misspells plaas (Afrikaans for "farm")
:B0X*?:labat::f("laborat") ; Web Freq 83.71 | Fixes 43 words
:B0X*?:laeg::f("leag") ; Web Freq 67.05 | Fixes 30 words
:B0X*?:laguage::f("language") ; Web Freq 176.03 | Fixes 16 words
:B0X*?:laimation::f("lamation") ; Web Freq 5.06 | Fixes 12 words
:B0X*?:lalbe::f("lable") ; Web Freq 399.26 | Fixes 164 words
:B0X*?:langaage::f("language") ; Web Freq 176.03 | Fixes 16 words
:B0X*?:lanious::f("laneous") ; Web Freq 32.50 | Fixes 6 words
:B0X*?:lanno::f("lano") ; Web Freq 8.78 | Fixes 63 words
:B0X*?:laraty::f("larity") ; Web Freq 33.13 | Fixes 47 words
:B0X*?:lastes::f("lates") ; Web Freq 196.54 | Fixes 274 words
:B0X*?:lateab::f("latab") ; Web Freq 4.01 | Fixes 38 words
:B0X*?:lattit::f("latit") ; Web Freq 8.47 | Fixes 32 words
:B0X*?:launh::f("launch") ; Web Freq 52.79 | Fixes 18 words
:B0X*?:lcud::f("clud") ; Web Freq 656.38 | Fixes 40 words
:B0X*?:leagur::f("leaguer") ; Web Freq 0.53 | Fixes 10 words
:B0X*?:leathal::f("lethal") ; Web Freq 3.46 | Fixes 13 words
:B0X*?:lece::f("lesce") ; Web Freq 12.81 | Fixes 66 words, but misspells Illecebrum (trailing plant native to Europe), scoleces (Part of a tapeworm)
:B0X*?:lecton::f("lection") ; Web Freq 287.02 | Fixes 71 words
:B0X*?:leee::f("lee") ; Web Freq 241.02 | Fixes 319 words
:B0X*?:lefy::f("left") ; Web Freq 178.80 | Fixes 39 words, but misspells Calefy (Archaic; to heat; make warm)
:B0X*?:legitam::f("legitim") ; Web Freq 10.60 | Fixes 77 words
:B0X*?:legue::f("league") ; Web Freq 60.94 | Fixes 19 words
:B0X*?:leiv::f("liev") ; Web Freq 123.28 | Fixes 58 words
:B0X*?:libaar::f("librar") ; Web Freq 199.57 | Fixes 13 words
:B0X*?:libgui::f("lingui") ; Web Freq 9.71 | Fixes 44 words
:B0X*?:licenc::f("licens") ; Web Freq 153.29 | Fixes 28 words, but Americanizes 9 British words!
:B0X*?:liement::f("lement") ; Web Freq 303.35 | Fixes 162 words
:B0X*?:lieuenan::f("lieutenan") ; Web Freq 4.19 | Fixes 6 words
:B0X*?:lifiing::f("lifying") ; Web Freq 7.63 | Fixes 19 words
:B0X*?:ligrar::f("librar") ; Web Freq 199.57 | Fixes 13 words
:B0X*?:ligui::f("liqui") ; Web Freq 30.32 | Fixes 65 words
:B0X*?:ligyi::f("lifyi") ; Web Freq 7.63 | Fixes 19 words
:B0X*?:likl::f("likel") ; Web Freq 69.74 | Fixes 16 words
:B0X*?:likt::f("list") ; Web Freq 1197.54 | Fixes 949 words
:B0X*?:liscen::f("licen") ; Web Freq 168.63 | Fixes 47 words
:B0X*?:lisen::f("licen") ; Web Freq 168.63 | Fixes 47 words, but misspells lisente (100 lisente equal 1 loti in Lesotho, S. Afterica)
:B0X*?:lishee::f("lishe") ; Web Freq 246.57 | Fixes 76 words
:B0X*?:lishh::f("lish") ; Web Freq 767.82 | Fixes 271 words
:B0X*?:lissh::f("lish") ; Web Freq 767.82 | Fixes 271 words
:B0X*?:listn::f("listen") ; Web Freq 76.02 | Fixes 19 words
:B0X*?:litav::f("lativ") ; Web Freq 86.02 | Fixes 118 words
:B0X*?:litert::f("literat") ; Web Freq 50.78 | Fixes 64 words
:B0X*?:littel::f("little") ; Web Freq 188.69 | Fixes 17 words
:B0X*?:litteral::f("literal") ; Web Freq 11.53 | Fixes 32 words
:B0X*?:littoe::f("little") ; Web Freq 188.69 | Fixes 17 words
:B0X*?:liuke::f("like") ; Web Freq 643.79 | Fixes 707 words
:B0X*?:lizt::f("list") ; Web Freq 1197.54 | Fixes 949 words
:B0X*?:llanous::f("llaneous") ; Web Freq 32.50 | Fixes 5 words
:B0X*?:llarious::f("larious") ; Web Freq 3.60 | Fixes 7 words
:B0X*?:llegen::f("llegian") ; Web Freq 2.31 | Fixes 8 words
:B0X*?:llegie::f("llegia") ; Web Freq 6.99 | Fixes 21 words
:B0X*?:lligy::f("llify") ; Web Freq 0.30 | Fixes 10 words
:B0X*?:llka::f("lla") ; Web Freq 691.11 | Fixes 1541 words
:B0X*?:llko::f("llo") ; Web Freq 943.29 | Fixes 1160 words
:B0X*?:llku::f("llu") ; Web Freq 130.28 | Fixes 447 words
:B0X*?:llky::f("lly") ; Web Freq 1447.05 | Fixes 3137 words
:B0X*?:lloct::f("llect") ; Web Freq 294.18 | Fixes 134 words
:B0X*?:llopon::f("llophon") ; Web Freq 0.05 | Fixes 8 words
:B0X*?:llthi::f("lthi") ; Web Freq 4.23 | Fixes 31 words
:B0X*?:lltho::f("ltho") ; Web Freq 80.93 | Fixes 10 words
:B0X*?:llths::f("lths") ; Web Freq 0.09 | Fixes 9 words
:B0X*?:llthy::f("lthy") ; Web Freq 36.79 | Fixes 5 words
:B0X*?:lodae::f("loade") ; Web Freq 42.30 | Fixes 34 words
:B0X*?:lodai::f("loadi") ; Web Freq 31.32 | Fixes 17 words
:B0X*?:lodas::f("loads") ; Web Freq 114.51 | Fixes 45 words
:B0X*?:logict::f("logist") ; Web Freq 40.45 | Fixes 564 words
:B0X*?:lonle::f("lonel") ; Web Freq 13.21 | Fixes 11 words
:B0X*?:looged::f("logged") ; Web Freq 33.74 | Fixes 16 words
:B0X*?:loogi::f("loggi") ; Web Freq 22.10 | Fixes 32 words
:B0X*?:looot::f("loot") ; Web Freq 2.45 | Fixes 17 words
:B0X*?:lsemm::f("lsem") ; Web Freq 0.04 | Fixes 6 words
:B0X*?:lstion::f("lation") ; Web Freq 657.01 | Fixes 580 words
:B0X*?:ltara::f("ltura") ; Web Freq 76.04 | Fixes 68 words
:B0X*?:ltent::f("ltant") ; Web Freq 39.06 | Fixes 10 words
:B0X*?:ltitid::f("ltitud") ; Web Freq 7.88 | Fixes 11 words
:B0X*?:lurra::f("lura") ; Web Freq 4.80 | Fixes 37 words
:B0X*?:machne::f("machine") ; Web Freq 121.52 | Fixes 13 words
:B0X*?:magol::f("magnol") ; Web Freq 2.92 | Fixes 9 words
:B0X*?:maintina::f("maintain") ; Web Freq 87.28 | Fixes 14 words
:B0X*?:maintion::f("mention") ; Web Freq 53.34 | Fixes 15 words
:B0X*?:majorot::f("majorit") ; Web Freq 28.87 | Fixes 8 words
:B0X*?:making it's::f("making its") 
:B0X*?:mallise::f("malize") ; Web Freq 3.83 | Fixes 29 words
:B0X*?:mallize::f("malize") ; Web Freq 3.83 | Fixes 29 words
:B0X*?:mamal::f("mammal") ; Web Freq 7.14 | Fixes 16 words, but misspells mamaliga (Romanian and Moldovan dish made from cornmeal)
:B0X*?:mamant::f("mament") ; Web Freq 2.54 | Fixes 12 words
:B0X*?:managab::f("manageab") ; Web Freq 1.93 | Fixes 10 words
:B0X*?:managm::f("managem") ; Web Freq 304.86 | Fixes 13 words
:B0X*?:mandito::f("mandato") ; Web Freq 9.92 | Fixes 7 words
:B0X*?:maneouv::f("manoeuv") ; Web Freq 0.74 | Fixes 13 words
:B0X*?:manoeuver::f("maneuver") ; Web Freq 2.81 | Fixes 14 words
:B0X*?:manouver::f("maneuver") ; Web Freq 2.81 | Fixes 14 words
:B0X*?:mantain::f("maintain") ; Web Freq 87.28 | Fixes 14 words
:B0X*?:mantion::f("mention") ; Web Freq 53.34 | Fixes 15 words
:B0X*?:manuever::f("maneuver") ; Web Freq 2.81 | Fixes 14 words
:B0X*?:manuver::f("maneuver") ; Web Freq 2.81 | Fixes 14 words
:B0X*?:marjorit::f("majorit") ; Web Freq 28.87 | Fixes 8 words
:B0X*?:markes::f("marks") ; Web Freq 116.95 | Fixes 48 words
:B0X*?:markett::f("market") ; Web Freq 360.92 | Fixes 66 words
:B0X*?:marrage::f("marriage") ; Web Freq 34.69 | Fixes 17 words
:B0X*?:materali::f("materiali") ; Web Freq 2.66 | Fixes 58 words
:B0X*?:matham::f("mathem") ; Web Freq 39.62 | Fixes 27 words
:B0X*?:mathematican::f("mathematician") ; Web Freq 1.51 | Fixes 6 words
:B0X*?:mathetician::f("mathematician") ; Web Freq 1.51 | Fixes 6 words
:B0X*?:mathm::f("mathem") ; Web Freq 39.62 | Fixes 27 words
:B0X*?:mberan::f("mbran") ; Web Freq 16.58 | Fixes 38 words
:B0X*?:mbintat::f("mbinat") ; Web Freq 37.54 | Fixes 19 words
:B0X*?:mchan::f("mechan") ; Web Freq 66.87 | Fixes 66 words
:B0X*?:mcial::f("mical") ; Web Freq 83.30 | Fixes 198 words
:B0X*?:meber::f("member") ; Web Freq 663.90 | Fixes 42 words
:B0X*?:meceo::f("meco") ; Web Freq 2.61 | Fixes 31 words
:B0X*?:medac::f("medic") ; Web Freq 302.08 | Fixes 99 words
:B0X*?:medeiv::f("mediev") ; Web Freq 8.16 | Fixes 9 words
:B0X*?:medevia::f("medieva") ; Web Freq 8.16 | Fixes 9 words
:B0X*?:meen::f("men") ; Web Freq 6054.28 | Fixes 3446 words
:B0X*?:meing::f("ming") ; Web Freq 489.74 | Fixes 584 words
:B0X*?:melad::f("malad") ; Web Freq 1.28 | Fixes 25 words
:B0X*?:melei::f("melie") ; Web Freq 0.21 | Fixes 11 words
:B0X*?:memmo::f("memo") ; Web Freq 224.40 | Fixes 81 words
:B0X*?:memt::f("ment") ; Web Freq 5091.73 | Fixes 2162 words
:B0X*?:memver::f("member") ; Web Freq 663.90 | Fixes 42 words
:B0X*?:menat::f("menta") ; Web Freq 429.16 | Fixes 438 words, but misspells catechumenate (convert being taught the principles of Christianity by a catechist)
:B0X*?:metalic::f("metallic") ; Web Freq 14.13 | Fixes 16 words
:B0X*?:metero::f("meteoro") ; Web Freq 4.49 | Fixes 25 words
:B0X*?:metn::f("ment") ; Web Freq 5091.73 | Fixes 2162 words
:B0X*?:mettin::f("meetin") ; Web Freq 160.19 | Fixes 8 words
:B0X*?:mialr::f("milar") ; Web Freq 137.37 | Fixes 16 words
:B0X*?:mibil::f("mobil") ; Web Freq 335.49 | Fixes 99 words
:B0X*?:micheal::f("Michael") ; Web Freq 90.41 | Fixes 7 words
:B0X*?:micial::f("mical") ; Web Freq 83.30 | Fixes 198 words
:B0X*?:micos::f("micros") ; Web Freq 119.26 | Fixes 86 words
:B0X*?:mileau::f("milieu") ; Web Freq 0.71 | Fixes 3 words
:B0X*?:milen::f("millen") ; Web Freq 9.77 | Fixes 50 words
:B0X*?:mileu::f("milieu") ; Web Freq 0.71 | Fixes 3 words, but misspells keratomileuses (surgical vision procedure)
:B0X*?:milirat::f("militar") ; Web Freq 74.35 | Fixes 57 words
:B0X*?:millit::f("milit") ; Web Freq 81.68 | Fixes 96 words
:B0X*?:millon::f("million") ; Web Freq 143.97 | Fixes 16 words, but misspells semillon (type of grape used for wine)
:B0X*?:milta::f("milita") ; Web Freq 77.71 | Fixes 79 words
:B0X*?:minatur::f("miniatur") ; Web Freq 10.12 | Fixes 32 words, but misspells seminatural (Uncommon usage)
:B0X*?:mintue::f("minute") ; Web Freq 139.58 | Fixes 17 words
:B0X*?:minuee::f("minute") ; Web Freq 139.58 | Fixes 17 words
:B0X*?:miranaa::f("miranda") ; Web Freq 2.53 | Fixes 1 word
:B0X*?:miscela::f("miscella") ; Web Freq 33.91 | Fixes 10 words
:B0X*?:mision::f("mission") ; Web Freq 351.84 | Fixes 85 words
:B0X*?:missabi::f("missibi") ; Web Freq 0.58 | Fixes 13 words
:B0X*?:missle::f("missile") ; Web Freq 8.12 | Fixes 10 words
:B0X*?:misson::f("mission") ; Web Freq 351.84 | Fixes 85 words
:B0X*?:misspall::f("misspell") ; Web Freq 1.30 | Fixes 5 words
:B0X*?:mition::f("mission") ; Web Freq 351.84 | Fixes 85 words, but misspells Dormition (Orthodox holiday about Virgn Mary)
:B0X*?:mittm::f("mitm") ; Web Freq 28.73 | Fixes 12 words
:B0X*?:mitty::f("mittee") ; Web Freq 149.39 | Fixes 14 words
:B0X*?:miull::f("mill") ; Web Freq 281.82 | Fixes 272 words
:B0X*?:mkae::f("make") ; Web Freq 575.40 | Fixes 190 words
:B0X*?:mkaing::f("making") ; Web Freq 132.19 | Fixes 73 words
:B0X*?:mkea::f("make") ; Web Freq 575.40 | Fixes 190 words
:B0X*?:mmei::f("mmie") ; Web Freq 5.97 | Fixes 90 words
:B0X*?:mmme::f("mme") ; Web Freq 1163.97 | Fixes 744 words
:B0X*?:mnet::f("ment") ; Web Freq 5091.73 | Fixes 2162 words, but misspells limnetic (living in the open water of a lake or pond, especially the well-lit surface layer away from the shore)
:B0X*?:moced::f("moved") ; Web Freq 65.48 | Fixes 10 words
:B0X*?:modle::f("model") ; Web Freq 282.45 | Fixes 33 words
:B0X*?:moent::f("moment") ; Web Freq 55.30 | Fixes 13 words
:B0X*?:moleclue::f("molecule") ; Web Freq 10.70 | Fixes 7 words
:B0X*?:monrin::f("mornin") ; Web Freq 55.32 | Fixes 5 words
:B0X*?:morgag::f("mortgag") ; Web Freq 94.94 | Fixes 18 words
:B0X*?:mornal::f("normal") ; Web Freq 91.93 | Fixes 72 words
:B0X*?:moror::f("motor") ; Web Freq 133.82 | Fixes 99 words
:B0X*?:morot::f("motor") ; Web Freq 133.82 | Fixes 99 words
:B0X*?:morow::f("morrow") ; Web Freq 24.07 | Fixes 4 words
:B0X*?:morrag::f("morrhag") ; Web Freq 1.90 | Fixes 12 words
:B0X*?:mortag::f("mortgag") ; Web Freq 94.94 | Fixes 18 words
:B0X*?:mostur::f("moistur") ; Web Freq 10.14 | Fixes 16 words
:B0X*?:mouise::f("mouse") ; Web Freq 36.20 | Fixes 29 words 
:B0X*?:moung::f("mong") ; Web Freq 104.61 | Fixes 113 words
:B0X*?:mounth::f("month") ; Web Freq 281.02 | Fixes 15 words
:B0X*?:mpatab::f("mpatib") ; Web Freq 46.32 | Fixes 20 words 
:B0X*?:mpinon::f("mpion") ; Web Freq 45.82 | Fixes 18 words
:B0X*?:mpossa::f("mpossi") ; Web Freq 16.49 | Fixes 8 words
:B0X*?:mprega::f("mpregna") ; Web Freq 0.81 | Fixes 17 words
:B0X*?:mpregne::f("mpregna") ; Web Freq 0.81 | Fixes 17 words
:B0X*?:mprobal::f("mprobabl") ; Web Freq 0.99 | Fixes 3 words
:B0X*?:mstion::f("mation") ; Web Freq 1061.86 | Fixes 146 words
:B0X*?:mtion::f("mation") ; Web Freq 1061.86 | Fixes 146 words
:B0X*?:mucuo::f("muco") ; Web Freq 2.02 | Fixes 35 words
:B0X*?:muder::f("murder") ; Web Freq 23.42 | Fixes 14 words
:B0X*?:muise::f("muse") ; Web Freq 72.47 | Fixes 69 words
:B0X*?:mulatat::f("mulat") ; Web Freq 90.30 | Fixes 137 words
:B0X*?:mulit::f("multi") ; Web Freq 221.62 | Fixes 385 words, but misspells Nummulitidae (large fossil protozoan of the Tertiary period)
:B0X*?:munites::f("munities") ; Web Freq 43.30 | Fixes 6 words
:B0X*?:muscel::f("muscle") ; Web Freq 27.02 | Fixes 13 words
:B0X*?:muscial::f("musical") ; Web Freq 49.93 | Fixes 28 words
:B0X*?:mutilia::f("mutila") ; Web Freq 1.10 | Fixes 9 words
:B0X*?:naisance::f("naissance") ; Web Freq 18.14 | Fixes 9 words
:B0X*?:nalbe::f("nable") ; Web Freq 166.27 | Fixes 272 words
:B0X*?:nallt::f("nalt") ; Web Freq 21.77 | Fixes 23 words
:B0X*?:narri::f("narra") ; Web Freq 12.59 | Fixes 27 words
:B0X*?:naton::f("nation") ; Web Freq 1364.86 | Fixes 528 words, but misspells Akhenaton (Early ruler of Egypt who regected old gods and replaced with sun worship, died 1358 BC), unatoned (not having received religious atonement)
:B0X*?:nchei::f("nchie") ; Web Freq 0.58 | Fixes 32 words
:B0X*?:ncontit::f("nconstit") ; Web Freq 1.68 | Fixes 5 words
:B0X*?:ncottro::f("ncontro") ; Web Freq 2.01 | Fixes 20 words
:B0X*?:ndefint::f("ndefinit") ; Web Freq 2.93 | Fixes 6 words
:B0X*?:ndemm::f("ndemn") ; Web Freq 11.11 | Fixes 24 words
:B0X*?:ndesp::f("ndisp") ; Web Freq 3.01 | Fixes 27 words, but misspells Gelandesprung (a ski technique for jumping over obstacles)
:B0X*?:ndicid::f("ndivid") ; Web Freq 151.90 | Fixes 43 words
:B0X*?:ndunt::f("ndant") ; Web Freq 46.66 | Fixes 40 words
:B0X*?:necass::f("necess") ; Web Freq 103.74 | Fixes 27 words
:B0X*?:necces::f("necess") ; Web Freq 103.74 | Fixes 27 words
:B0X*?:neceo::f("neco") ; Web Freq 3.38 | Fixes 28 words
:B0X*?:necesar::f("necessar") ; Web Freq 95.00 | Fixes 9 words
:B0X*?:neciss::f("necess") ; Web Freq 103.74 | Fixes 27 words
:B0X*?:neeed::f("need") ; Web Freq 538.91 | Fixes 59 words
:B0X*?:nefica::f("neficia") ; Web Freq 14.88 | Fixes 14 words
:B0X*?:negocia::f("negotia") ; Web Freq 31.15 | Fixes 30 words
:B0X*?:negota::f("negotia") ; Web Freq 31.15 | Fixes 30 words
:B0X*?:neice::f("niece") ; Web Freq 1.75 | Fixes 4 words
:B0X*?:neigboo::f("neighbo") ; Web Freq 57.11 | Fixes 23 words 
:B0X*?:neize::f("nize") ; Web Freq 92.19 | Fixes 606 words
:B0X*?:neoliti::f("neolithi") ; Web Freq 0.98 | Fixes 5 words
:B0X*?:nerial::f("neral") ; Web Freq 397.74 | Fixes 113 words
:B0X*?:nerib::f("nerab") ; Web Freq 21.85 | Fixes 23 words
:B0X*?:nervio::f("nervo") ; Web Freq 9.58 | Fixes 7 words
:B0X*?:nessas::f("necess") ; Web Freq 103.74 | Fixes 27 words
:B0X*?:nessec::f("necess") ; Web Freq 103.74 | Fixes 27 words
:B0X*?:nfered::f("nferred") ; Web Freq 3.09 | Fixes 5 words
:B0X*?:nfinat::f("nfinit") ; Web Freq 13.35 | Fixes 19 words
:B0X*?:nfoer::f("nfore") ; Web Freq 3.76 | Fixes 12 words
:B0X*?:ngng::f("nging") ; Web Freq 113.67 | Fixes 171 words
:B0X*?:niant::f("nant") ; Web Freq 81.88 | Fixes 193 words
:B0X*?:niare::f("naire") ; Web Freq 15.65 | Fixes 43 words
:B0X*?:nicial::f("nical") ; Web Freq 197.92 | Fixes 251 words
:B0X*?:nickle::f("nickel") ; Web Freq 11.62 | Fixes 17 words
:B0X*?:nifig::f("nific") ; Web Freq 102.10 | Fixes 83 words
:B0X*?:nihgt::f("night") ; Web Freq 378.95 | Fixes 128 words
:B0X*?:nilog::f("nolog") ; Web Freq 348.72 | Fixes 295 words
:B0X*?:nisator::f("niser") ; Web Freq 4.31 | Fixes 48 words
:B0X*?:nistion::f("nisation") ; Web Freq 47.06 | Fixes 144 words
:B0X*?:nitian::f("nician") ; Web Freq 15.82 | Fixes 10 words
:B0X*?:niton::f("nition") ; Web Freq 97.44 | Fixes 50 words, but misspells Honiton (A town in England), niton (an old name for the element radon)
:B0X*?:nizator::f("nizer") ; Web Freq 11.68 | Fixes 72 words
:B0X*?:nlees::f("nless") ; Web Freq 74.99 | Fixes 135 words
:B0X*?:nloda::f("nload") ; Web Freq 353.05 | Fixes 28 words
:B0X*?:nmae::f("name") ; Web Freq 725.61 | Fixes 144 words
:B0X*?:nnolo::f("nolo") ; Web Freq 350.38 | Fixes 310 words
:B0X*?:nnung::f("nning") ; Web Freq 317.55 | Fixes 157 words
:B0X*?:noee::f("note") ; Web Freq 347.36 | Fixes 77 words
:B0X*?:nominclat::f("nomenclat") ; Web Freq 1.50 | Fixes 8 words
:B0X*?:nonom::f("nonym") ; Web Freq 41.06 | Fixes 46 words
:B0X*?:notece::f("notice") ; Web Freq 149.35 | Fixes 16 words
:B0X*?:noticabl::f("noticeabl") ; Web Freq 2.63 | Fixes 6 words
:B0X*?:notiee::f("notice") ; Web Freq 149.35 | Fixes 16 words
:B0X*?:notmal::f("normal") ; Web Freq 91.93 | Fixes 72 words
:B0X*?:notwwo::f("notewo") ; Web Freq 1.81 | Fixes 6 words
:B0X*?:nouce::f("nounce") ; Web Freq 116.56 | Fixes 50 words
:B0X*?:nounch::f("nounc") ; Web Freq 119.94 | Fixes 58 words
:B0X*?:nouncia::f("nuncia") ; Web Freq 3.82 | Fixes 52 words
:B0X*?:nsemm::f("nsem") ; Web Freq 8.10 | Fixes 15 words
:B0X*?:nsenc::f("nsens") ; Web Freq 14.91 | Fixes 47 words
:B0X*?:nsern::f("ncern") ; Web Freq 103.44 | Fixes 23 words
:B0X*?:nsistan::f("nsisten") ; Web Freq 43.43 | Fixes 20 words
:B0X*?:nsitu::f("nstitu") ; Web Freq 268.08 | Fixes 104 words
:B0X*?:nsnet::f("nsent") ; Web Freq 22.92 | Fixes 22 words
:B0X*?:nstade::f("nstead") ; Web Freq 57.28 | Fixes 13 words
:B0X*?:nstatan::f("nstan") ; Web Freq 119.82 | Fixes 54 words
:B0X*?:nsted::f("nstead") ; Web Freq 57.28 | Fixes 13 words, but misspells Stansted (A town in England)
:B0X*?:nstion::f("nation") ; Web Freq 1364.86 | Fixes 528 words
:B0X*?:nstiv::f("nsitiv") ; Web Freq 32.75 | Fixes 73 words
:B0X*?:ntaines::f("ntains") ; Web Freq 80.89 | Fixes 9 words
:B0X*?:ntamp::f("ntemp") ; Web Freq 37.62 | Fixes 67 words, but misspells untampered (Not altered)
:B0X*?:ntentianal::f("ntentional") ; Web Freq 6.03 | Fixes 8 words
:B0X*?:ntfic::f("ntific") ; Web Freq 70.12 | Fixes 37 words
:B0X*?:ntifc::f("ntific") ; Web Freq 70.12 | Fixes 37 words
:B0X*?:ntiiv::f("nitiv") ; Web Freq 15.61 | Fixes 36 words
:B0X*?:ntionna::f("ntiona") ; Web Freq 20.90 | Fixes 43 words
:B0X*?:ntrui::f("nturi") ; Web Freq 9.54 | Fixes 26 words
:B0X*?:nucula::f("nuclea") ; Web Freq 36.14 | Fixes 66 words
:B0X*?:nuculea::f("nuclea") ; Web Freq 36.14 | Fixes 66 words
:B0X*?:nuddke::f("middle") ; Web Freq 80.72 | Fixes 20 words
:B0X*?:nuei::f("nui") ; Web Freq 57.66 | Fixes 44 words
:B0X*?:nuise::f("nuse") ; Web Freq 9.93 | Fixes 40 words
:B0X*?:numberic::f("numeric") ; Web Freq 15.90 | Fixes 11 words
:B0X*?:nuptua::f("nuptia") ; Web Freq 0.44 | Fixes 10 words
:B0X*?:nuque::f("nique") ; Web Freq 134.91 | Fixes 31 words
:B0X*?:nvien::f("nven") ; Web Freq 136.75 | Fixes 137 words
:B0X*?:nvison::f("nvision") ; Web Freq 2.82 | Fixes 8 words 
:B0X*?:obedian::f("obedien") ; Web Freq 4.13 | Fixes 12 words
:B0X*?:obelm::f("oblem") ; Web Freq 265.40 | Fixes 33 words
:B0X*?:obide::f("ovide") ; Web Freq 545.15 | Fixes 21 words
:B0X*?:obram::f("ogram") ; Web Freq 609.83 | Fixes 299 words, but misspells Tobramycin (An antibiotic--trade name Nebcin)
:B0X*?:occassi::f("occasi") ; Web Freq 38.54 | Fixes 15 words
:B0X*?:occasti::f("occasi") ; Web Freq 38.54 | Fixes 15 words
:B0X*?:occour::f("occur") ; Web Freq 73.89 | Fixes 20 words
:B0X*?:occura::f("occurre") ; Web Freq 26.60 | Fixes 11 words
:B0X*?:occurra::f("occurre") ; Web Freq 26.60 | Fixes 11 words
:B0X*?:ocottro::f("ocontro") ; Web Freq 1.30 | Fixes 4 words
:B0X*?:octohe::f("octahe") ; Web Freq 0.18 | Fixes 8 words
:B0X*?:ocunt::f("count") ; Web Freq 1119.83 | Fixes 612 words
:B0X*?:ocurra::f("occurre") ; Web Freq 26.60 | Fixes 11 words
:B0X*?:odouriferous::f("odoriferous") ; Web Freq 0.02 | Fixes 4 words
:B0X*?:odourousn::f("odorousn") ; Fixes 5 words 
:B0X*?:odual::f("odule") ; Web Freq 69.69 | Fixes 9 words
:B0X*?:oducab::f("oducib") ; Web Freq 1.41 | Fixes 15 words
:B0X*?:oduec::f("oduce") ; Web Freq 178.52 | Fixes 38 words
:B0X*?:oeceo::f("oeco") ; Web Freq 5.13 | Fixes 27 words
:B0X*?:oeny::f("oney") ; Web Freq 217.68 | Fixes 111 words
:B0X*?:oeopl::f("eopl") ; Web Freq 497.34 | Fixes 78 words
:B0X*?:oepra::f("opera") ; Web Freq 380.11 | Fixes 128 words
:B0X*?:offce::f("office") ; Web Freq 376.45 | Fixes 16 words
:B0X*?:offesi::f("ofessi") ; Web Freq 176.10 | Fixes 42 words
:B0X*?:offical::f("official") ; Web Freq 146.34 | Fixes 26 words
:B0X*?:ofoer::f("ofore") ; Web Freq 0.92 | Fixes 7 words
:B0X*?:ogeous::f("ogous") ; Web Freq 4.03 | Fixes 16 words, but misspells hypogeous (organisms, that grow underground)
:B0X*?:ogess::f("ogress") ; Web Freq 74.28 | Fixes 46 words
:B0X*?:ointim::f("ointm") ; Web Freq 27.98 | Fixes 14 words
:B0X*?:olgist::f("ologist") ; Web Freq 27.39 | Fixes 529 words
:B0X*?:olld::f("ould") ; Web Freq 1316.51 | Fixes 71 words
:B0X*?:olledg::f("olleg") ; Web Freq 209.94 | Fixes 29 words
:B0X*?:ollub::f("olub") ; Web Freq 4.31 | Fixes 60 words
:B0X*?:ollum::f("olum") ; Web Freq 215.74 | Fixes 97 words
:B0X*?:ollun::f("olun") ; Web Freq 82.90 | Fixes 35 words
:B0X*?:oloda::f("olida") ; Web Freq 164.03 | Fixes 46 words
:B0X*?:olther::f("other") ; Web Freq 1564.40 | Fixes 285 words
:B0X*?:oluab::f("olub") ; Web Freq 4.31 | Fixes 60 words
:B0X*?:omenom::f("omenon") ; Web Freq 6.10 | Fixes 10 words
:B0X*?:ommm::f("omm") ; Web Freq 2131.28 | Fixes 710 words
:B0X*?:omnio::f("omino") ; Web Freq 11.54 | Fixes 19 words
:B0X*?:ompina::f("ombina") ; Web Freq 40.34 | Fixes 30 words
:B0X*?:omptab::f("ompatib") ; Web Freq 46.32 | Fixes 20 words
:B0X*?:omre::f("more") ; Web Freq 3163.45 | Fixes 118 words
:B0X*?:omse::f("onse") ; Web Freq 263.83 | Fixes 216 words, but misspells momser (Yiddish for someone who is untrustworthy or deceptive)
:B0X*?:onbour::f("onboar") ; Web Freq 2.44 | Fixes 5 words
:B0X*?:oncens::f("onsens") ; Web Freq 13.18 | Fixes 23 words
:B0X*?:oneing::f("oning") ; Web Freq 74.67 | Fixes 275 words
:B0X*?:onffese::f("onfesse") ; Web Freq 1.27 | Fixes 4 words
:B0X*?:ongraph::f("onograph") ; Web Freq 5.80 | Fixes 47 words
:B0X*?:onnal::f("onal") ; Web Freq 2167.53 | Fixes 1344 words
:B0X*?:onomatopeia::f("onomatopoeia") ; Web Freq 0.06 | Fixes 2 words
:B0X*?:ononent::f("onent") ; Web Freq 113.73 | Fixes 28 words
:B0X*?:ononym::f("onym") ; Web Freq 48.31 | Fixes 168 words
:B0X*?:onsce::f("onse") ; Web Freq 263.83 | Fixes 216 words
:B0X*?:ontruc::f("onstruc") ; Web Freq 145.50 | Fixes 78 words
:B0X*?:ontstr::f("onstr") ; Web Freq 222.58 | Fixes 193 words
:B0X*?:onvertab::f("onvertib") ; Web Freq 6.23 | Fixes 22 words
:B0X*?:onyic::f("onic") ; Web Freq 334.69 | Fixes 494 words
:B0X*?:onymn::f("onym") ; Web Freq 48.31 | Fixes 168 words
:B0X*?:onyn::f("onym") ; Web Freq 48.31 | Fixes 168 words, but misspells Cronyn (Canadian actor 1911-2003)
:B0X*?:ooksd::f("ooked") ; Web Freq 49.46 | Fixes 34 words
:B0X*?:oook::f("ook") ; Web Freq 2021.53 | Fixes 591 words
:B0X*?:oopor::f("ooper") ; Web Freq 70.36 | Fixes 60 words
:B0X*?:oorper::f("ooper") ; Web Freq 70.36 | Fixes 60 words
:B0X*?:oparat::f("operat") ; Web Freq 335.83 | Fixes 95 words, but misspells hypoparathyroidism (medical thing)
:B0X*?:openess::f("openness") ; Web Freq 1.78 | Fixes 3 words
:B0X*?:operact::f("operat") ; Web Freq 335.83 | Fixes 95 words
:B0X*?:opinon::f("opion") ; Web Freq 0.74 | Fixes 10 words
:B0X*?:oportun::f("opportun") ; Web Freq 131.67 | Fixes 16 words
:B0X*?:oppasi::f("opposi") ; Web Freq 40.80 | Fixes 19 words
:B0X*?:opperat::f("operat") ; Web Freq 335.83 | Fixes 95 words
:B0X*?:oppert::f("opport") ; Web Freq 131.67 | Fixes 16 words
:B0X*?:oppini::f("opini") ; Web Freq 89.65 | Fixes 17 words, but misspells scaloppini (Italian dish)
:B0X*?:opprot::f("opport") ; Web Freq 131.67 | Fixes 16 words
:B0X*?:opth::f("ophth") ; Web Freq 3.81 | Fixes 53 words
:B0X*?:optm::f("optim") ; Web Freq 60.58 | Fixes 50 words
:B0X*?:optomi::f("optimi") ; Web Freq 42.81 | Fixes 35 words
:B0X*?:ordiant::f("ordinat") ; Web Freq 62.77 | Fixes 53 words
:B0X*?:orginis::f("organiz") ; Web Freq 189.52 | Fixes 44 words
:B0X*?:orginiz::f("organiz") ; Web Freq 189.52 | Fixes 44 words
:B0X*?:oridal::f("ordial") ; Web Freq 1.65 | Fixes 16 words
:B0X*?:oridina::f("ordina") ; Web Freq 100.00 | Fixes 76 words
:B0X*?:origion::f("origin") ; Web Freq 211.06 | Fixes 38 words
:B0X*?:ormenc::f("ormanc") ; Web Freq 151.95 | Fixes 14 words
:B0X*?:orror::f("error") ; Web Freq 176.82 | Fixes 56 words  ; horror is in protective word list, above.
:B0X*?:orthag::f("orthog") ; Web Freq 1.90 | Fixes 28 words
:B0X*?:osedon::f("osecon") ; Web Freq 0.90 | Fixes 16 words 
:B0X*?:oseing::f("osing") ; Web Freq 70.54 | Fixes 96 words
:B0X*?:osemm::f("osem") ; Web Freq 5.26 | Fixes 23 words
:B0X*?:osible::f("osable") ; Web Freq 4.91 | Fixes 31 words, but misspells erosible (capable of being eroded)
:B0X*?:osrly::f("ostly") ; Web Freq 32.44 | Fixes 9 words
:B0X*?:ossese::f("ossesse") ; Web Freq 5.09 | Fixes 11 words 
:B0X*?:ostsd::f("osted") ; Web Freq 306.95 | Fixes 27 words
:B0X*?:oteab::f("otab") ; Web Freq 10.87 | Fixes 29 words, but misspells toteable (Can be carried, uncommon word), voteable (Can be voted, uncommon word)
:B0X*?:othiu::f("othi") ; Web Freq 170.08 | Fixes 94 words
:B0X*?:otionna::f("otiona") ; Web Freq 30.98 | Fixes 43 words
:B0X*?:oublish::f("publish") ; Web Freq 231.67 | Fixes 32 words
:B0X*?:oudna::f("ounda") ; Web Freq 97.32 | Fixes 28 words
:B0X*?:oudni::f("oundi") ; Web Freq 38.11 | Fixes 58 words
:B0X*?:oudns::f("ounds") ; Web Freq 104.72 | Fixes 103 words
:B0X*?:ouevr::f("oeuvr") ; Web Freq 1.59 | Fixes 15 words
:B0X*?:ougnbl::f("oubl") ; Web Freq 131.08 | Fixes 75 words
:B0X*?:ouiseb::f("ouseb") ; Web Freq 1.02 | Fixes 23 words 
:B0X*?:ouised::f("oused") ; Web Freq 4.28 | Fixes 33 words 
:B0X*?:ouisek::f("ousek") ; Web Freq 3.06 | Fixes 7 words 
:B0X*?:ouisem::f("ousem") ; Web Freq 0.92 | Fixes 18 words 
:B0X*?:ouisep::f("ousep") ; Web Freq 1.32 | Fixes 12 words 
:B0X*?:ouiser::f("ouser") ; Web Freq 5.97 | Fixes 36 words 
:B0X*?:ouises::f("ouses") ; Web Freq 41.71 | Fixes 150 words 
:B0X*?:ouiset::f("ouset") ; Web Freq 0.32 | Fixes 12 words 
:B0X*?:ouldnt::f("ouldn't") ; Fixes 3 words
:B0X*?:ouness::f("ousness") ; Web Freq 12.99 | Fixes 929 words
:B0X*?:ouney::f("ourney") ; Web Freq 24.66 | Fixes 15 words
:B0X*?:ountian::f("ountain") ; Web Freq 84.42 | Fixes 28 words, but misspells countian (Member of a county, uncommon)
:B0X*?:ourious::f("orious") ; Web Freq 9.90 | Fixes 39 words
:B0X*?:ournied::f("ourneyed") ; Web Freq 0.23 | Fixes 2 words
:B0X*?:ournies::f("ourneys") ; Web Freq 2.95 | Fixes 2 words
:B0X*?:ourring::f("ouring") ; Web Freq 12.49 | Fixes 65 words
:B0X*?:ouuld::f("ould") ; Web Freq 1316.51 | Fixes 71 words
:B0X*?:ovison::f("ovision") ; Web Freq 64.99 | Fixes 18 words 
:B0X*?:ovle::f("ovel") ; Web Freq 63.25 | Fixes 115 words
:B0X*?:owinf::f("owing") ; Web Freq 385.44 | Fixes 183 words
:B0X*?:oxiden::f("oxidan") ; Web Freq 3.51 | Fixes 4 words
:B0X*?:oxigena::f("oxygena") ; Web Freq 1.16 | Fixes 24 words
:B0X*?:paiti::f("pati") ; Web Freq 276.12 | Fixes 195 words
:B0X*?:palbe::f("pable") ; Web Freq 19.97 | Fixes 64 words
:B0X*?:paliament::f("parliament") ; Web Freq 24.90 | Fixes 11 words
:B0X*?:panno::f("pano") ; Web Freq 11.48 | Fixes 51 words
:B0X*?:papaer::f("paper") ; Web Freq 319.79 | Fixes 91 words
:B0X*?:paralel::f("parallel") ; Web Freq 22.68 | Fixes 45 words
:B0X*?:pareed::f("pared") ; Web Freq 72.60 | Fixes 14 words
:B0X*?:parellel::f("parallel") ; Web Freq 22.68 | Fixes 45 words
:B0X*?:parision::f("parison") ; Web Freq 42.99 | Fixes 8 words
:B0X*?:parisit::f("parasit") ; Web Freq 5.14 | Fixes 72 words
:B0X*?:paritucla::f("particula") ; Web Freq 118.63 | Fixes 29 words
:B0X*?:parlim::f("parliam") ; Web Freq 24.90 | Fixes 11 words
:B0X*?:parment::f("partment") ; Web Freq 306.72 | Fixes 51 words
:B0X*?:parnn::f("paren") ; Web Freq 174.32 | Fixes 100 words
:B0X*?:parralel::f("parallel") ; Web Freq 22.68 | Fixes 45 words
:B0X*?:parrall::f("parall") ; Web Freq 23.14 | Fixes 48 words
:B0X*?:parren::f("paren") ; Web Freq 174.32 | Fixes 100 words
:B0X*?:particulary::f("particularly") ; Web Freq 42.16 | Fixes 2 words
:B0X*?:partiol::f("partial") ; Web Freq 24.47 | Fixes 13 words
:B0X*?:pased::f("passed") ; Web Freq 35.79 | Fixes 13 words
:B0X*?:pattent::f("patent") ; Web Freq 35.39 | Fixes 16 words
:B0X*?:pbuli::f("publi") ; Web Freq 821.32 | Fixes 90 words
:B0X*?:pcial::f("pical") ; Web Freq 63.59 | Fixes 126 words
:B0X*?:pcitur::f("pictur") ; Web Freq 344.06 | Fixes 29 words
:B0X*?:peall::f("peal") ; Web Freq 52.91 | Fixes 38 words
:B0X*?:peapl::f("peopl") ; Web Freq 491.50 | Fixes 55 words
:B0X*?:pefor::f("perfor") ; Web Freq 250.31 | Fixes 52 words
:B0X*?:peice::f("piece") ; Web Freq 82.05 | Fixes 78 words
:B0X*?:peion::f("ption") ; Web Freq 748.29 | Fixes 229 words
:B0X*?:peiti::f("petiti") ; Web Freq 103.54 | Fixes 46 words
:B0X*?:pelase::f("please") ; Web Freq 394.69 | Fixes 17 words, but misspells erysipelases (A type of streptococcal infection)
:B0X*?:pendece::f("pendence") ; Web Freq 35.43 | Fixes 16 words
:B0X*?:pendendet::f("pendent") ; Web Freq 94.27 | Fixes 22 words
:B0X*?:penerat::f("penetrat") ; Web Freq 10.60 | Fixes 19 words
:B0X*?:penisula::f("peninsula") ; Web Freq 7.10 | Fixes 3 words
:B0X*?:penninsula::f("peninsula") ; Web Freq 7.10 | Fixes 3 words
:B0X*?:pennisula::f("peninsula") ; Web Freq 7.10 | Fixes 3 words
:B0X*?:pensanti::f("pensati") ; Web Freq 26.13 | Fixes 14 words
:B0X*?:pensinula::f("peninsula") ; Web Freq 7.10 | Fixes 3 words
:B0X*?:penten::f("pentan") ; Web Freq 1.43 | Fixes 14 words, but misspells pentene (A type of chemical)
:B0X*?:pention::f("pension") ; Web Freq 35.21 | Fixes 19 words
:B0X*?:peopel::f("people") ; Web Freq 491.46 | Fixes 47 words
:B0X*?:peot::f("poet") ; Web Freq 38.92 | Fixes 50 words
:B0X*?:percential::f("percentile") ; Web Freq 3.41 | Fixes 2 words
:B0X*?:percepted::f("perceived") ; Web Freq 6.55 | Fixes 7 words
:B0X*?:perfom::f("perform") ; Web Freq 247.99 | Fixes 40 words
:B0X*?:performes::f("performs") ; Web Freq 6.39 | Fixes 3 words
:B0X*?:permenan::f("permanen") ; Web Freq 34.99 | Fixes 18 words
:B0X*?:perminen::f("permanen") ; Web Freq 34.99 | Fixes 18 words
:B0X*?:permissa::f("permissi") ; Web Freq 52.38 | Fixes 21 words
:B0X*?:peronal::f("personal") ; Web Freq 291.85 | Fixes 56 words, but misspells piperonal (A fragrant organic compound)
:B0X*?:perosn::f("person") ; Web Freq 528.81 | Fixes 163 words
:B0X*?:persista::f("persiste") ; Web Freq 9.52 | Fixes 10 words
:B0X*?:persud::f("persuad") ; Web Freq 4.09 | Fixes 20 words
:B0X*?:persue::f("pursue") ; Web Freq 11.33 | Fixes 11 words
:B0X*?:persui::f("pursui") ; Web Freq 10.90 | Fixes 8 words
:B0X*?:pertrat::f("petrat") ; Web Freq 2.56 | Fixes 14 words
:B0X*?:pertub::f("perturb") ; Web Freq 2.66 | Fixes 25 words
:B0X*?:peteti::f("petiti") ; Web Freq 103.54 | Fixes 46 words
:B0X*?:petion::f("petition") ; Web Freq 70.84 | Fixes 17 words
:B0X*?:petive::f("petitive") ; Web Freq 32.57 | Fixes 24 words
:B0X*?:phenomenona::f("phenomena") ; Web Freq 6.52 | Fixes 19 words
:B0X*?:phenomo::f("phenome") ; Web Freq 13.55 | Fixes 30 words
:B0X*?:phenonm::f("phenom") ; Web Freq 13.81 | Fixes 32 words
:B0X*?:philiso::f("philoso") ; Web Freq 39.91 | Fixes 33 words
:B0X*?:phillipi::f("Philippi") ; Web Freq 23.50 | Fixes 7 words
:B0X*?:phillo::f("philo") ; Web Freq 40.51 | Fixes 77 words
:B0X*?:philosph::f("philosoph") ; Web Freq 39.91 | Fixes 33 words
:B0X*?:phoricia::f("phorica") ; Web Freq 0.60 | Fixes 8 words
:B0X*?:phyllis::f("philis") ; Web Freq 1.64 | Fixes 36 words
:B0X*?:phylosoph::f("philosoph") ; Web Freq 39.91 | Fixes 33 words
:B0X*?:pialr::f("pilar") ; Web Freq 0.35 | Fixes 4 words
:B0X*?:piant::f("pient") ; Web Freq 20.60 | Fixes 19 words
:B0X*?:piblish::f("publish") ; Web Freq 231.67 | Fixes 32 words
:B0X*?:picial::f("pical") ; Web Freq 63.59 | Fixes 126 words
:B0X*?:piten::f("peten") ; Web Freq 19.53 | Fixes 33 words
:B0X*?:piull::f("pill") ; Web Freq 58.44 | Fixes 109 words
:B0X*?:plament::f("plement") ; Web Freq 166.36 | Fixes 54 words
:B0X*?:plausa::f("plausi") ; Web Freq 2.41 | Fixes 13 words
:B0X*?:plesan::f("pleasan") ; Web Freq 14.92 | Fixes 17 words
:B0X*?:plesean::f("pleasan") ; Web Freq 14.92 | Fixes 17 words
:B0X*?:pletetion::f("pletion") ; Web Freq 21.40 | Fixes 11 words
:B0X*?:plicatl::f("plicabl") ; Web Freq 35.42 | Fixes 17 words
:B0X*?:ploda::f("pload") ; Web Freq 33.88 | Fixes 12 words
:B0X*?:pmant::f("pment") ; Web Freq 473.21 | Fixes 48 words
:B0X*?:poenis::f("penis") ; Web Freq 18.82 | Fixes 4 words
:B0X*?:poepl::f("peopl") ; Web Freq 491.50 | Fixes 55 words
:B0X*?:poleg::f("polog") ; Web Freq 24.43 | Fixes 75 words
:B0X*?:polina::f("pollina") ; Web Freq 0.94 | Fixes 12 words
:B0X*?:polinom::f("polynom") ; Web Freq 3.78 | Fixes 2 words
:B0X*?:politican::f("politician") ; Web Freq 9.53 | Fixes 6 words
:B0X*?:polti::f("politi") ; Web Freq 151.67 | Fixes 80 words
:B0X*?:polut::f("pollut") ; Web Freq 22.23 | Fixes 23 words
:B0X*?:pomot::f("promot") ; Web Freq 115.12 | Fixes 23 words
:B0X*?:ponan::f("ponen") ; Web Freq 113.71 | Fixes 24 words
:B0X*?:ponsab::f("ponsib") ; Web Freq 139.78 | Fixes 13 words
:B0X*?:poporti::f("proporti") ; Web Freq 20.54 | Fixes 41 words
:B0X*?:popoul::f("popul") ; Web Freq 215.05 | Fixes 88 words
:B0X*?:porble::f("proble") ; Web Freq 265.06 | Fixes 27 words
:B0X*?:portad::f("ported") ; Web Freq 115.86 | Fixes 28 words
:B0X*?:portay::f("portray") ; Web Freq 5.31 | Fixes 14 words
:B0X*?:posat::f("posit") ; Web Freq 333.68 | Fixes 244 words
:B0X*?:posential::f("potential") ; Web Freq 78.64 | Fixes 8 words
:B0X*?:posess::f("possess") ; Web Freq 24.13 | Fixes 49 words
:B0X*?:posion::f("poison") ; Web Freq 10.92 | Fixes 25 words
:B0X*?:possab::f("possib") ; Web Freq 183.76 | Fixes 16 words
:B0X*?:possit::f("posit") ; Web Freq 333.68 | Fixes 244 words
:B0X*?:postion::f("position") ; Web Freq 198.39 | Fixes 117 words
:B0X*?:postiv::f("positiv") ; Web Freq 63.38 | Fixes 41 words
:B0X*?:potuni::f("portuni") ; Web Freq 131.39 | Fixes 12 words
:B0X*?:poudn::f("pound") ; Web Freq 69.66 | Fixes 59 words
:B0X*?:pouise::f("pouse") ; Web Freq 13.01 | Fixes 13 words 
:B0X*?:poulat::f("populat") ; Web Freq 78.13 | Fixes 38 words
:B0X*?:poverful::f("powerful") ; Web Freq 34.32 | Fixes 7 words
:B0X*?:poweful::f("powerful") ; Web Freq 34.32 | Fixes 7 words
:B0X*?:ppmen::f("pmen") ; Web Freq 473.53 | Fixes 57 words
:B0X*?:ppore::f("ppose") ; Web Freq 45.41 | Fixes 29 words
:B0X*?:pposs::f("ppos") ; Web Freq 88.39 | Fixes 106 words
:B0X*?:practioner::f("practitioner") ; Web Freq 13.98 | Fixes 4 words
:B0X*?:practiv::f("practic") ; Web Freq 176.99 | Fixes 48 words
:B0X*?:prait::f("priat") ; Web Freq 97.54 | Fixes 41 words
:B0X*?:pratic::f("practic") ; Web Freq 176.99 | Fixes 48 words
:B0X*?:precende::f("precede") ; Web Freq 12.40 | Fixes 18 words
:B0X*?:precic::f("precis") ; Web Freq 28.14 | Fixes 31 words
:B0X*?:precid::f("preced") ; Web Freq 18.85 | Fixes 19 words
:B0X*?:precti::f("practi") ; Web Freq 194.67 | Fixes 60 words
:B0X*?:preety::f("pretty") ; Web Freq 51.64 | Fixes 4 words
:B0X*?:prefent::f("prevent") ; Web Freq 88.30 | Fixes 27 words
:B0X*?:pregab::f("pregnab") ; Web Freq 0.09 | Fixes 9 words
:B0X*?:pregat::f("pregnat") ; Web Freq 0.72 | Fixes 9 words
:B0X*?:pregneb::f("pregnab") ; Web Freq 0.09 | Fixes 9 words
:B0X*?:pregnenc::f("pregnanc") ; Web Freq 24.17 | Fixes 4 words
:B0X*?:pregnent::f("pregnant") ; Web Freq 19.99 | Fixes 8 words
:B0X*?:pregnet::f("pregnat") ; Web Freq 0.72 | Fixes 9 words
:B0X*?:pregress::f("progress") ; Web Freq 74.17 | Fixes 30 words
:B0X*?:preiod::f("period") ; Web Freq 147.32 | Fixes 52 words
:B0X*?:prelifer::f("prolifer") ; Web Freq 5.41 | Fixes 14 words
:B0X*?:prepair::f("prepare") ; Web Freq 61.58 | Fixes 15 words
:B0X*?:prerio::f("perio") ; Web Freq 189.98 | Fixes 75 words
:B0X*?:prerty::f("pretty") ; Web Freq 51.64 | Fixes 4 words
:B0X*?:presan::f("presen") ; Web Freq 423.30 | Fixes 116 words, but misspells presanctify (Before making holy.  Rare word)
:B0X*?:prespi::f("perspi") ; Web Freq 0.66 | Fixes 26 words
:B0X*?:presty::f("pretty") ; Web Freq 51.64 | Fixes 4 words
:B0X*?:pretect::f("protect") ; Web Freq 193.19 | Fixes 55 words
:B0X*?:pricip::f("princip") ; Web Freq 88.80 | Fixes 29 words
:B0X*?:priestood::f("priesthood") ; Web Freq 0.87 | Fixes 3 words
:B0X*?:principial::f("principal") ; Web Freq 33.51 | Fixes 12 words
:B0X*?:prinic::f("princ") ; Web Freq 138.70 | Fixes 59 words
:B0X*?:prisonn::f("prison") ; Web Freq 35.65 | Fixes 24 words
:B0X*?:privale::f("privile") ; Web Freq 16.03 | Fixes 7 words
:B0X*?:privele::f("privile") ; Web Freq 16.03 | Fixes 7 words
:B0X*?:privelig::f("privileg") ; Web Freq 16.03 | Fixes 7 words
:B0X*?:privelle::f("privile") ; Web Freq 16.03 | Fixes 7 words
:B0X*?:privid::f("provid") ; Web Freq 603.10 | Fixes 22 words
:B0X*?:privilag::f("privileg") ; Web Freq 16.03 | Fixes 7 words
:B0X*?:priviledg::f("privileg") ; Web Freq 16.03 | Fixes 7 words
:B0X*?:privt::f("privat") ; Web Freq 204.30 | Fixes 53 words
:B0X*?:probabli::f("probabili") ; Web Freq 16.75 | Fixes 12 words
:B0X*?:probale::f("probable") ; Web Freq 5.89 | Fixes 6 words
:B0X*?:probess::f("process") ; Web Freq 324.97 | Fixes 49 words
:B0X*?:probpt::f("prompt") ; Web Freq 22.73 | Fixes 22 words
:B0X*?:procc::f("proc") ; Web Freq 504.43 | Fixes 258 words
:B0X*?:proclame::f("proclaime") ; Web Freq 1.96 | Fixes 4 words
:B0X*?:profesor::f("professor") ; Web Freq 45.77 | Fixes 13 words
:B0X*?:proffesor::f("professor") ; Web Freq 45.77 | Fixes 13 words
:B0X*?:proffess::f("profess") ; Web Freq 222.98 | Fixes 60 words
:B0X*?:progrom::f("program") ; Web Freq 597.64 | Fixes 74 words
:B0X*?:prohabi::f("prohibi") ; Web Freq 28.09 | Fixes 18 words
:B0X*?:proir::f("prior") ; Web Freq 111.57 | Fixes 42 words
:B0X*?:promar::f("primar") ; Web Freq 83.70 | Fixes 9 words
:B0X*?:prominan::f("prominen") ; Web Freq 8.59 | Fixes 8 words
:B0X*?:prominate::f("prominent") ; Web Freq 7.49 | Fixes 4 words
:B0X*?:promona::f("promine") ; Web Freq 8.69 | Fixes 12 words
:B0X*?:proor::f("prior") ; Web Freq 111.57 | Fixes 42 words
:B0X*?:proov::f("prov") ; Web Freq 1050.99 | Fixes 244 words
:B0X*?:propiet::f("propriet") ; Web Freq 11.43 | Fixes 22 words
:B0X*?:propiiat::f("propriat") ; Web Freq 97.54 | Fixes 41 words
:B0X*?:propmt::f("prompt") ; Web Freq 22.73 | Fixes 22 words
:B0X*?:propog::f("propag") ; Web Freq 11.30 | Fixes 33 words
:B0X*?:proportiat::f("proportionat") ; Web Freq 2.68 | Fixes 16 words
:B0X*?:propotion::f("proportion") ; Web Freq 20.54 | Fixes 41 words
:B0X*?:propro::f("pro") ; Web Freq 6382.24 | Fixes 3033 words
:B0X*?:prorp::f("propr") ; Web Freq 109.50 | Fixes 81 words
:B0X*?:prosuma::f("presuma") ; Web Freq 3.47 | Fixes 3 words
:B0X*?:prosumi::f("presumi") ; Web Freq 0.22 | Fixes 2 words
:B0X*?:prosump::f("presump") ; Web Freq 2.38 | Fixes 9 words
:B0X*?:protie::f("protei") ; Web Freq 73.92 | Fixes 64 words
:B0X*?:protray::f("portray") ; Web Freq 5.31 | Fixes 14 words
:B0X*?:protty::f("pretty") ; Web Freq 51.64 | Fixes 4 words
:B0X*?:prounc::f("pronounc") ; Web Freq 5.44 | Fixes 24 words
:B0X*?:provd::f("provid") ; Web Freq 603.10 | Fixes 22 words
:B0X*?:provicial::f("provincial") ; Web Freq 9.46 | Fixes 16 words
:B0X*?:provinic::f("provinc") ; Web Freq 36.32 | Fixes 18 words
:B0X*?:proxia::f("proxima") ; Web Freq 50.80 | Fixes 24 words
:B0X*?:psect::f("spect") ; Web Freq 359.82 | Fixes 228 words
:B0X*?:psoit::f("posit") ; Web Freq 333.68 | Fixes 244 words
:B0X*?:pstion::f("pation") ; Web Freq 68.40 | Fixes 41 words
:B0X*?:psued::f("pseud") ; Web Freq 7.22 | Fixes 117 words
:B0X*?:psyco::f("psycho") ; Web Freq 54.79 | Fixes 205 words
:B0X*?:psyh::f("psych") ; Web Freq 78.83 | Fixes 262 words, but misspells gypsyhood (About gypsies, nomadic Romani peoples)
:B0X*?:ptenc::f("ptanc") ; Web Freq 37.13 | Fixes 9 words
:B0X*?:ptete::f("pete") ; Web Freq 186.84 | Fixes 76 words
:B0X*?:ptionna::f("ptiona") ; Web Freq 56.36 | Fixes 36 words
:B0X*?:ptitid::f("ptitud") ; Web Freq 1.34 | Fixes 10 words
:B0X*?:ptition::f("petition") ; Web Freq 70.84 | Fixes 17 words
:B0X*?:ptogress::f("progress") ; Web Freq 74.17 | Fixes 30 words
:B0X*?:ptoin::f("ption") ; Web Freq 748.29 | Fixes 229 words
:B0X*?:ptrea::f("ptera") ; Web Freq 3.85 | Fixes 78 words
:B0X*?:pturd::f("ptured") ; Web Freq 9.09 | Fixes 7 words
:B0X*?:pubish::f("publish") ; Web Freq 231.67 | Fixes 32 words
:B0X*?:publian::f("publican") ; Web Freq 42.81 | Fixes 14 words
:B0X*?:publise::f("publishe") ; Web Freq 173.69 | Fixes 16 words
:B0X*?:publush::f("publish") ; Web Freq 231.67 | Fixes 32 words
:B0X*?:pucli::f("publi") ; Web Freq 821.32 | Fixes 90 words
:B0X*?:puise::f("puse") ; Web Freq 3.58 | Fixes 22 words
:B0X*?:pulare::f("pular") ; Web Freq 134.41 | Fixes 47 words
:B0X*?:puler::f("pular") ; Web Freq 134.41 | Fixes 47 words, but misspells puler (French word for the "chirp" of a bird)
:B0X*?:pulish::f("publish") ; Web Freq 231.67 | Fixes 32 words
:B0X*?:puplish::f("publish") ; Web Freq 231.67 | Fixes 32 words
:B0X*?:purra::f("pura") ; Web Freq 1.25 | Fixes 42 words
:B0X*?:pursuad::f("persuad") ; Web Freq 4.09 | Fixes 20 words
:B0X*?:purtun::f("portun") ; Web Freq 131.72 | Fixes 31 words
:B0X*?:pususa::f("persua") ; Web Freq 7.62 | Fixes 36 words
:B0X*?:puszl::f("puzzl") ; Web Freq 26.05 | Fixes 19 words
:B0X*?:putar::f("puter") ; Web Freq 348.29 | Fixes 51 words
:B0X*?:putib::f("putab") ; Web Freq 3.12 | Fixes 37 words
:B0X*?:pwoer::f("power") ; Web Freq 421.22 | Fixes 100 words
:B0X*?:pyness::f("piness") ; Web Freq 8.68 | Fixes 118 words
:B0X*?:pysch::f("psych") ; Web Freq 78.83 | Fixes 262 words
:B0X*?:pysci::f("psychi") ; Web Freq 18.20 | Fixes 32 words
:B0X*?:quantat::f("quantit") ; Web Freq 53.28 | Fixes 22 words
:B0X*?:quesec::f("quenc") ; Web Freq 109.05 | Fixes 53 words
:B0X*?:quesion::f("question") ; Web Freq 306.63 | Fixes 32 words
:B0X*?:questiom::f("question") ; Web Freq 306.63 | Fixes 32 words
:B0X*?:queston::f("question") ; Web Freq 306.63 | Fixes 32 words
:B0X*?:quetion::f("question") ; Web Freq 306.63 | Fixes 32 words
:B0X*?:quirment::f("quirement") ; Web Freq 120.54 | Fixes 4 words
:B0X*?:qush::f("quish") ; Web Freq 2.85 | Fixes 29 words
:B0X*?:radiact::f("radioact") ; Web Freq 4.51 | Fixes 5 words
:B0X*?:raell::f("reall") ; Web Freq 162.97 | Fixes 34 words
:B0X*?:raete::f("reate") ; Web Freq 363.24 | Fixes 78 words 
:B0X*?:raeth::f("reath") ; Web Freq 30.13 | Fixes 79 words 
:B0X*?:raeti::f("reati") ; Web Freq 218.26 | Fixes 82 words 
:B0X*?:raetm::f("reatm") ; Web Freq 103.80 | Fixes 15 words 
:B0X*?:raets::f("reats") ; Web Freq 17.64 | Fixes 17 words 
:B0X*?:raetu::f("reatu") ; Web Freq 11.28 | Fixes 8 words 
:B0X*?:raety::f("reaty") ; Web Freq 9.15 | Fixes 2 words 
:B0X*?:raige::f("riage") ; Web Freq 42.17 | Fixes 34 words
:B0X*?:railia::f("ralia") ; Web Freq 160.25 | Fixes 19 words
:B0X*?:ranie::f("rannie") ; Web Freq 2.39 | Fixes 10 words, but misspells guaranies (plural for Indigenous Guaraní person)
:B0X*?:ratly::f("rately") ; Web Freq 24.10 | Fixes 31 words
:B0X*?:raverci::f("roversi") ; Web Freq 6.64 | Fixes 21 words
:B0X*?:rcaft::f("craft") ; Web Freq 95.43 | Fixes 87 words
:B0X*?:rchei::f("rchie") ; Web Freq 2.14 | Fixes 55 words
:B0X*?:reaate::f("relate") ; Web Freq 255.31 | Fixes 38 words
:B0X*?:reaccur::f("recur") ; Web Freq 16.26 | Fixes 36 words
:B0X*?:reaci::f("reachi") ; Web Freq 12.50 | Fixes 24 words
:B0X*?:reasea::f("resea") ; Web Freq 344.40 | Fixes 30 words
:B0X*?:reatil::f("retail") ; Web Freq 83.75 | Fixes 13 words
:B0X*?:rebll::f("rebell") ; Web Freq 4.50 | Fixes 18 words
:B0X*?:receo::f("reco") ; Web Freq 645.80 | Fixes 615 words
:B0X*?:recide::f("reside") ; Web Freq 366.26 | Fixes 51 words
:B0X*?:recomment::f("recommend") ; Web Freq 158.17 | Fixes 13 words
:B0X*?:recona::f("reconna") ; Web Freq 1.30 | Fixes 4 words
:B0X*?:recqu::f("requ") ; Web Freq 685.89 | Fixes 119 words
:B0X*?:recration::f("recreation") ; Web Freq 40.22 | Fixes 7 words
:B0X*?:recrod::f("record") ; Web Freq 292.36 | Fixes 34 words
:B0X*?:recter::f("rector") ; Web Freq 373.94 | Fixes 32 words
:B0X*?:recue::f("reque") ; Web Freq 273.40 | Fixes 40 words
:B0X*?:recuring::f("recurring") ; Web Freq 3.37 | Fixes 3 words
:B0X*?:recurran::f("recurren") ; Web Freq 4.25 | Fixes 5 words
:B0X*?:redard::f("regard") ; Web Freq 106.35 | Fixes 25 words
:B0X*?:reedem::f("redeem") ; Web Freq 13.72 | Fixes 27 words
:B0X*?:reee::f("ree") ; Web Freq 2928.48 | Fixes 1356 words
:B0X*?:reenfo::f("reinfo") ; Web Freq 11.24 | Fixes 18 words
:B0X*?:referal::f("referral") ; Web Freq 16.36 | Fixes 2 words
:B0X*?:reffer::f("refer") ; Web Freq 359.01 | Fixes 69 words
:B0X*?:refrer::f("refer") ; Web Freq 359.01 | Fixes 69 words
:B0X*?:refridg::f("refrig") ; Web Freq 13.28 | Fixes 12 words
:B0X*?:regogn::f("recogn") ; Web Freq 79.02 | Fixes 58 words
:B0X*?:reher::f("rehear") ; Web Freq 4.33 | Fixes 17 words
:B0X*?:reigin::f("reign") ; Web Freq 83.07 | Fixes 34 words
:B0X*?:reiind::f("remind") ; Web Freq 24.95 | Fixes 11 words
:B0X*?:reimn::f("remin", 0) ; Web Freq 27.75 | Fixes 49 words 
:B0X*?:reing::f("ring") ; Web Freq 1630.67 | Fixes 2002 words
:B0X*?:reiv::f("riev") ; Web Freq 34.81 | Fixes 61 words, but misspells reive (Archaic word for rob/plunder)
:B0X*?:relase::f("relate") ; Web Freq 255.31 | Fixes 38 words
:B0X*?:relese::f("release") ; Web Freq 246.76 | Fixes 14 words
:B0X*?:releven::f("relevan") ; Web Freq 57.85 | Fixes 13 words
:B0X*?:reliize::f("realize") ; Web Freq 27.33 | Fixes 9 words
:B0X*?:relucten::f("reluctan") ; Web Freq 4.58 | Fixes 7 words
:B0X*?:remenic::f("reminisc") ; Web Freq 2.59 | Fixes 13 words
:B0X*?:remines::f("reminis") ; Web Freq 2.59 | Fixes 16 words
:B0X*?:reminsc::f("reminisc") ; Web Freq 2.59 | Fixes 13 words
:B0X*?:remive::f("remove") ; Web Freq 87.85 | Fixes 8 words
:B0X*?:remmi::f("remi") ; Web Freq 138.05 | Fixes 226 words
:B0X*?:remom::f("recom") ; Web Freq 164.44 | Fixes 88 words
:B0X*?:remond::f("remind") ; Web Freq 24.95 | Fixes 11 words
:B0X*?:rencia::f("rentia") ; Web Freq 22.28 | Fixes 53 words
:B0X*?:renewl::f("renewal") ; Web Freq 11.38 | Fixes 5 words
:B0X*?:renial::f("rennial") ; Web Freq 3.19 | Fixes 7 words
:B0X*?:renno::f("reno") ; Web Freq 34.02 | Fixes 125 words
:B0X*?:rentor::f("renter") ; Web Freq 3.38 | Fixes 5 words
:B0X*?:renuw::f("renew") ; Web Freq 30.82 | Fixes 23 words
:B0X*?:reomm::f("recomm") ; Web Freq 158.51 | Fixes 33 words
:B0X*?:reoomme::f("recomme") ; Web Freq 158.27 | Fixes 19 words
:B0X*?:repatit::f("repetit") ; Web Freq 5.27 | Fixes 13 words
:B0X*?:repb::f("repub") ; Web Freq 107.04 | Fixes 36 words
:B0X*?:repetent::f("repentant") ; Web Freq 0.27 | Fixes 5 words
:B0X*?:replacab::f("replaceab") ; Web Freq 0.91 | Fixes 10 words
:B0X*?:requist::f("request") ; Web Freq 193.13 | Fixes 9 words
:B0X*?:resardi::f("regardi") ; Web Freq 50.71 | Fixes 2 words
:B0X*?:resense::f("resence") ; Web Freq 28.83 | Fixes 6 words
:B0X*?:resion::f("ression") ; Web Freq 129.52 | Fixes 93 words
:B0X*?:resistab::f("resistib") ; Web Freq 1.39 | Fixes 11 words
:B0X*?:resiv::f("ressiv") ; Web Freq 42.40 | Fixes 103 words
:B0X*?:resord::f("record") ; Web Freq 292.36 | Fixes 34 words
:B0X*?:responc::f("respons") ; Web Freq 254.35 | Fixes 42 words
:B0X*?:responda::f("responde") ; Web Freq 44.89 | Fixes 22 words
:B0X*?:restict::f("restrict") ; Web Freq 50.42 | Fixes 32 words
:B0X*?:resuest::f("request") ; Web Freq 193.13 | Fixes 9 words
:B0X*?:retrun::f("return") ; Web Freq 322.23 | Fixes 16 words
:B0X*?:reuuest::f("request") ; Web Freq 193.13 | Fixes 9 words
:B0X*?:revelan::f("relevan") ; Web Freq 57.85 | Fixes 13 words
:B0X*?:reversab::f("reversib") ; Web Freq 3.68 | Fixes 15 words
:B0X*?:rhitm::f("rithm") ; Web Freq 31.86 | Fixes 26 words
:B0X*?:rhythem::f("rhythm") ; Web Freq 12.18 | Fixes 49 words
:B0X*?:rhytm::f("rhythm") ; Web Freq 12.18 | Fixes 49 words
:B0X*?:ributre::f("ribute") ; Web Freq 128.07 | Fixes 31 words
:B0X*?:ridgid::f("rigid") ; Web Freq 6.01 | Fixes 29 words
:B0X*?:rieciat::f("reciat") ; Web Freq 35.90 | Fixes 40 words
:B0X*?:rifing::f("rifying") ; Web Freq 5.61 | Fixes 37 words
:B0X*?:rigeur::f("rigor") ; Web Freq 4.34 | Fixes 15 words
:B0X*?:rigourous::f("rigorous") ; Web Freq 3.58 | Fixes 7 words, but Americanizes rigourous
:B0X*?:riiba::f("riba") ; Web Freq 15.10 | Fixes 80 words
:B0X*?:riibb::f("ribb") ; Web Freq 35.83 | Fixes 67 words
:B0X*?:riibe::f("ribe") ; Web Freq 261.85 | Fixes 112 words
:B0X*?:riibi::f("ribi") ; Web Freq 12.87 | Fixes 29 words
:B0X*?:riibl::f("ribl") ; Web Freq 17.66 | Fixes 21 words
:B0X*?:riibu::f("ribu") ; Web Freq 322.37 | Fixes 135 words
:B0X*?:rilbe::f("rible") ; Web Freq 14.83 | Fixes 17 words
:B0X*?:rilia::f("rillia") ; Web Freq 12.79 | Fixes 13 words
:B0X*?:rimetal::f("rimental") ; Web Freq 22.03 | Fixes 12 words
:B0X*?:rimind::f("remind") ; Web Freq 24.95 | Fixes 11 words
:B0X*?:rininging::f("ringing") ; Web Freq 20.66 | Fixes 32 words
:B0X*?:rioria::f("riora") ; Web Freq 4.04 | Fixes 12 words was: ::deterioriat::deteriorat
:B0X*?:ritent::f("rient") ; Web Freq 56.77 | Fixes 88 words
:B0X*?:riull::f("rill") ; Web Freq 88.31 | Fixes 243 words
:B0X*?:riut::f("ruit") ; Web Freq 79.29 | Fixes 83 words
:B0X*?:rixon::f("rison") ; Web Freq 98.29 | Fixes 47 words
:B0X*?:rloda::f("rload") ; Web Freq 4.12 | Fixes 12 words
:B0X*?:rmaton::f("rmation") ; Web Freq 1003.08 | Fixes 56 words
:B0X*?:rmeemb::f("rememb") ; Web Freq 96.92 | Fixes 23 words
:B0X*?:rocord::f("record") ; Web Freq 292.36 | Fixes 34 words
:B0X*?:rodued::f("roduced") ; Web Freq 78.74 | Fixes 10 words
:B0X*?:roffese::f("rofesse") ; Web Freq 0.60 | Fixes 4 words
:B0X*?:rogect::f("roject") ; Web Freq 372.49 | Fixes 35 words
:B0X*?:rogit::f("rogat") ; Web Freq 7.96 | Fixes 78 words
:B0X*?:rograss::f("rogress") ; Web Freq 74.28 | Fixes 44 words
:B0X*?:rooot::f("root") ; Web Freq 63.28 | Fixes 158 words
:B0X*?:roow::f("rrow") ; Web Freq 100.03 | Fixes 124 words
:B0X*?:ropiat::f("ropriat") ; Web Freq 97.54 | Fixes 41 words
:B0X*?:rouise::f("rouse") ; Web Freq 10.44 | Fixes 48 words 
:B0X*?:roximite::f("roximate") ; Web Freq 44.19 | Fixes 9 words
:B0X*?:rpinon::f("rpion") ; Web Freq 3.76 | Fixes 11 words
:B0X*?:rpoor::f("repor") ; Web Freq 516.80 | Fixes 44 words
:B0X*?:rriib::f("rrib") ; Web Freq 18.02 | Fixes 13 words
:B0X*?:rriing::f("rrying") ; Web Freq 20.23 | Fixes 33 words
:B0X*?:rrri::f("rri") ; Web Freq 564.79 | Fixes 860 words
:B0X*?:rrwit::f("rwrit") ; Web Freq 6.13 | Fixes 10 words
:B0X*?:rsemm::f("rsem") ; Web Freq 16.09 | Fixes 25 words
:B0X*?:rshan::f("rtion") ; Web Freq 88.67 | Fixes 123 words, but misspells darshan (Hindu word for being in presence of divine)
:B0X*?:rshon::f("rtion") ; Web Freq 88.67 | Fixes 123 words, but misspells Gershon (a Hebrew name)
:B0X*?:rshun::f("rtion") ; Web Freq 88.67 | Fixes 123 words
:B0X*?:rstion::f("ration") ; Web Freq 958.33 | Fixes 676 words
:B0X*?:rtait::f("rtrait") ; Web Freq 16.64 | Fixes 6 words
:B0X*?:rtaure::f("rature") ; Web Freq 99.21 | Fixes 16 words
:B0X*?:rthiu::f("rthi") ; Web Freq 4.83 | Fixes 115 words
:B0X*?:rtiing::f("riting") ; Web Freq 103.00 | Fixes 47 words
:B0X*?:rtionna::f("rtiona") ; Web Freq 7.65 | Fixes 38 words
:B0X*?:rtitid::f("rtitud") ; Web Freq 0.60 | Fixes 6 words
:B0X*?:rtnat::f("rtant") ; Web Freq 142.72 | Fixes 9 words
:B0X*?:rtoin::f("rtion") ; Web Freq 88.67 | Fixes 123 words
:B0X*?:rucur::f("recur") ; Web Freq 16.26 | Fixes 36 words
:B0X*?:rucut::f("recut") ; Web Freq 0.23 | Fixes 6 words
:B0X*?:ruming::f("rumming") ; Web Freq 1.13 | Fixes 5 words
:B0X*?:ruptab::f("ruptib") ; Web Freq 0.62 | Fixes 14 words
:B0X*?:rurra::f("rura") ; Web Freq 31.04 | Fixes 37 words
:B0X*?:russina::f("Russian") ; Web Freq 48.09 | Fixes 29 words
:B0X*?:russion::f("Russian") ; Web Freq 48.09 | Fixes 29 words
:B0X*?:ruy::f("ury") ; Web Freq 212.72 | Fixes 125 words, but misspells gruyere (Swiss cheese with small holes)
:B0X*?:rvison::f("rvision") ; Web Freq 9.93 | Fixes 3 words 
:B0X*?:rwite::f("write") ; Web Freq 204.85 | Fixes 71 words
:B0X*?:rwiti::f("writi") ; Web Freq 102.69 | Fixes 33 words
:B0X*?:rwitt::f("writt") ; Web Freq 103.35 | Fixes 13 words
:B0X*?:ryed::f("ried") ; Web Freq 140.59 | Fixes 133 words
:B0X*?:rythym::f("rhythm") ; Web Freq 12.18 | Fixes 49 words
:B0X*?:saccar::f("sacchar") ; Web Freq 5.03 | Fixes 51 words
:B0X*?:safte::f("safet") ; Web Freq 111.73 | Fixes 12 words
:B0X*?:saidit::f("said it") ; Fixes 1 word
:B0X*?:saidth::f("said th") ; Fixes 1 word
:B0X*?:salbe::f("sable") ; Web Freq 51.61 | Fixes 213 words
:B0X*?:sallt::f("salt") ; Web Freq 59.31 | Fixes 115 words
:B0X*?:samele::f("sample") ; Web Freq 106.05 | Fixes 21 words
:B0X*?:santion::f("sanction") ; Web Freq 8.21 | Fixes 7 words
:B0X*?:sarre::f("sarra") ; Web Freq 0.45 | Fixes 15 words
:B0X*?:sassan::f("sassin") ; Web Freq 5.56 | Fixes 13 words
:B0X*?:satelit::f("satellit") ; Web Freq 45.98 | Fixes 9 words
:B0X*?:satric::f("satiric") ; Web Freq 0.64 | Fixes 4 words
:B0X*?:sattelit::f("satellit") ; Web Freq 45.98 | Fixes 9 words
:B0X*?:scael::f("scale") ; Web Freq 63.69 | Fixes 56 words
:B0X*?:scaleab::f("scalab") ; Web Freq 5.00 | Fixes 7 words
:B0X*?:scane::f("scale") ; Web Freq 63.69 | Fixes 56 words
:B0X*?:scedu::f("schedu") ; Web Freq 111.64 | Fixes 18 words
:B0X*?:schedual::f("schedule") ; Web Freq 102.39 | Fixes 13 words
:B0X*?:scheen::f("screen") ; Web Freq 158.01 | Fixes 66 words
:B0X*?:schg::f("sch") ; Web Freq 801.62 | Fixes 763 words
:B0X*?:schhol::f("school") ; Web Freq 484.80 | Fixes 100 words
:B0X*?:schoes::f("scores") ; Web Freq 23.87 | Fixes 11 words
:B0X*?:scholarstic::f("scholastic") ; Web Freq 4.75 | Fixes 12 words
:B0X*?:scholl::f("school") ; Web Freq 484.80 | Fixes 100 words
:B0X*?:schore::f("score") ; Web Freq 113.47 | Fixes 45 words
:B0X*?:sciipt::f("script") ; Web Freq 439.96 | Fixes 130 words
:B0X*?:scince::f("science") ; Web Freq 227.61 | Fixes 33 words, but misspells Scincella (A reptile genus of Scincidae)
:B0X*?:scipt::f("script") ; Web Freq 439.96 | Fixes 130 words
:B0X*?:scoond::f("second") ; Web Freq 241.78 | Fixes 41 words
:B0X*?:scoool::f("school") ; Web Freq 484.80 | Fixes 100 words
:B0X*?:scorol::f("school") ; Web Freq 484.80 | Fixes 100 words will it misspell 'scroll'?
:B0X*?:scripton::f("scription") ; Web Freq 303.13 | Fixes 38 words
:B0X*?:scrite::f("scribe") ; Web Freq 243.40 | Fixes 79 words
:B0X*?:scritt::f("script") ; Web Freq 439.96 | Fixes 130 words
:B0X*?:scron::f("stron") ; Web Freq 118.77 | Fixes 98 words
:B0X*?:scrren::f("screen") ; Web Freq 158.01 | Fixes 66 words
:B0X*?:sctic::f("stric") ; Web Freq 192.90 | Fixes 121 words
:B0X*?:sctip::f("scrip") ; Web Freq 441.98 | Fixes 135 words
:B0X*?:sctruct::f("struct") ; Web Freq 455.62 | Fixes 227 words
:B0X*?:scupt::f("sculpt") ; Web Freq 14.98 | Fixes 24 words
:B0X*?:sdide::f("side") ; Web Freq 987.65 | Fixes 447 words
:B0X*?:sdie::f("side") ; Web Freq 987.65 | Fixes 447 words
:B0X*?:seach::f("search") ; Web Freq 1477.37 | Fixes 33 words, but misspells Taoiseach (The prime minister of the Irish Republic)
:B0X*?:secdon::f("second") ; Web Freq 241.78 | Fixes 41 words
:B0X*?:seceo::f("seco") ; Web Freq 242.25 | Fixes 60 words
:B0X*?:secretery::f("secretary") ; Web Freq 46.31 | Fixes 5 words
:B0X*?:sectu::f("secu") ; Web Freq 377.74 | Fixes 112 words
:B0X*?:sedere::f("sidere") ; Web Freq 58.02 | Fixes 7 words
:B0X*?:sedond::f("second") ; Web Freq 241.78 | Fixes 41 words 
:B0X*?:seee::f("see") ; Web Freq 1098.81 | Fixes 313 words
:B0X*?:seeting::f("setting") ; Web Freq 90.67 | Fixes 30 words
:B0X*?:segement::f("segment") ; Web Freq 25.07 | Fixes 19 words
:B0X*?:sehd::f("shed") ; Web Freq 279.97 | Fixes 301 words
:B0X*?:sehl::f("shel") ; Web Freq 75.36 | Fixes 127 words
:B0X*?:sehn::f("shen") ; Web Freq 6.27 | Fixes 31 words
:B0X*?:sehp::f("shep") ; Web Freq 8.41 | Fixes 12 words
:B0X*?:sehr::f("sher") ; Web Freq 188.88 | Fixes 306 words, but misspells Dussehra (a major Hindu festival)
:B0X*?:sehw::f("shew") ; Web Freq 1.32 | Fixes 11 words
:B0X*?:seige::f("siege") ; Web Freq 4.41 | Fixes 11 words
:B0X*?:seiv::f("siev") ; Web Freq 1.21 | Fixes 6 words
:B0X*?:selfes::f("selves") ; Web Freq 63.91 | Fixes 6 words
:B0X*?:semma::f("sema") ; Web Freq 17.59 | Fixes 75 words
:B0X*?:semmb::f("semb") ; Web Freq 66.82 | Fixes 116 words
:B0X*?:semme::f("seme") ; Web Freq 92.73 | Fixes 117 words
:B0X*?:semming::f("seeming") ; Web Freq 4.70 | Fixes 6 words
:B0X*?:semmo::f("semo") ; Web Freq 0.10 | Fixes 14 words
:B0X*?:semmp::f("semp") ; Web Freq 0.70 | Fixes 35 words
:B0X*?:senden::f("senten") ; Web Freq 26.75 | Fixes 28 words
:B0X*?:senqu::f("sequ") ; Web Freq 116.43 | Fixes 114 words
:B0X*?:sensativ::f("sensitiv") ; Web Freq 31.87 | Fixes 40 words
:B0X*?:sentente::f("sentence") ; Web Freq 23.47 | Fixes 15 words
:B0X*?:sentive::f("sentative") ; Web Freq 53.22 | Fixes 18 words, but misspells assentive (Agreeable, rare word)
:B0X*?:separet::f("separat") ; Web Freq 73.74 | Fixes 29 words
:B0X*?:seper::f("separ") ; Web Freq 75.02 | Fixes 46 words, but misspells houseperson (Uncommon)
:B0X*?:sepulchure::f("sepulcher") ; Web Freq 0.05 | Fixes 8 words
:B0X*?:sepulcre::f("sepulcher") ; Web Freq 0.05 | Fixes 8 words
:B0X*?:serach::f("search") ; Web Freq 1477.37 | Fixes 33 words
:B0X*?:sercu::f("circu") ; Web Freq 102.74 | Fixes 185 words
:B0X*?:sertain::f("certain") ; Web Freq 119.90 | Fixes 28 words
:B0X*?:sevic::f("servic") ; Web Freq 1611.30 | Fixes 40 words, but misspells seviche (South American dish of raw fish)
:B0X*?:shoool::f("school") ; Web Freq 484.80 | Fixes 100 words
:B0X*?:shoose::f("choose") ; Web Freq 93.67 | Fixes 11 words
:B0X*?:sicial::f("sical") ; Web Freq 175.44 | Fixes 114 words
:B0X*?:sicion::f("cision") ; Web Freq 119.95 | Fixes 34 words
:B0X*?:sicne::f("since") ; Web Freq 222.73 | Fixes 23 words
:B0X*?:sidenta::f("sidentia") ; Web Freq 42.28 | Fixes 12 words
:B0X*?:siez::f("seiz") ; Web Freq 10.60 | Fixes 36 words
:B0X*?:signifa::f("significa") ; Web Freq 91.10 | Fixes 21 words
:B0X*?:significe::f("significa") ; Web Freq 91.10 | Fixes 21 words
:B0X*?:signite::f("signate") ; Web Freq 42.23 | Fixes 10 words
:B0X*?:signiti::f("signati") ; Web Freq 11.76 | Fixes 14 words
:B0X*?:signito::f("signato") ; Web Freq 1.70 | Fixes 7 words
:B0X*?:signitu::f("signatu") ; Web Freq 33.03 | Fixes 5 words
:B0X*?:sigua::f("situa") ; Web Freq 70.61 | Fixes 14 words
:B0X*?:silbe::f("sible") ; Web Freq 270.80 | Fixes 177 words
:B0X*?:simala::f("simila") ; Web Freq 139.71 | Fixes 45 words
:B0X*?:simele::f("simple") ; Web Freq 93.56 | Fixes 17 words
:B0X*?:similia::f("simila") ; Web Freq 139.71 | Fixes 45 words
:B0X*?:simmi::f("simi") ; Web Freq 146.18 | Fixes 86 words
:B0X*?:simpt::f("sympt") ; Web Freq 27.32 | Fixes 19 words
:B0X*?:simulare::f("simulate") ; Web Freq 6.91 | Fixes 10 words
:B0X*?:sincerl::f("sincerel") ; Web Freq 4.35 | Fixes 2 words
:B0X*?:sinse::f("since") ; Web Freq 222.73 | Fixes 23 words, but misspells sinsemilla (A type of marijuana)
:B0X*?:sistend::f("sistent") ; Web Freq 40.03 | Fixes 12 words
:B0X*?:sistion::f("sition") ; Web Freq 254.36 | Fixes 150 words
:B0X*?:sitck::f("stick") ; Web Freq 62.31 | Fixes 142 words
:B0X*?:sitll::f("still") ; Web Freq 203.66 | Fixes 79 words
:B0X*?:siton::f("sition") ; Web Freq 254.36 | Fixes 150 words
:B0X*?:skelat::f("skelet") ; Web Freq 7.59 | Fixes 29 words
:B0X*?:slcss::f("class") ; Web Freq 480.82 | Fixes 168 words
:B0X*?:slowy::f("slowly") ; Web Freq 13.00 | Fixes 2 words
:B0X*?:smae::f("same") ; Web Freq 473.63 | Fixes 28 words
:B0X*?:smealt::f("smelt") ; Web Freq 1.10 | Fixes 16 words
:B0X*?:smoe::f("some") ; Web Freq 930.50 | Fixes 400 words
:B0X*?:snese::f("sense") ; Web Freq 63.91 | Fixes 21 words
:B0X*?:snwo::f("snow") ; Web Freq 97.46 | Fixes 121 words
:B0X*?:socit::f("societ") ; Web Freq 122.28 | Fixes 8 words
:B0X*?:socre::f("score") ; Web Freq 113.47 | Fixes 45 words
:B0X*?:soem::f("some") ; Web Freq 930.50 | Fixes 400 words
:B0X*?:sohw::f("show") ; Web Freq 551.85 | Fixes 121 words
:B0X*?:soica::f("socia") ; Web Freq 429.44 | Fixes 155 words
:B0X*?:sollu::f("solu") ; Web Freq 288.75 | Fixes 107 words
:B0X*?:sonen::f("sonan") ; Web Freq 7.45 | Fixes 43 words
:B0X*?:sonsis::f("consis") ; Web Freq 76.00 | Fixes 21 words
:B0X*?:sophicat::f("sophisticat") ; Web Freq 10.67 | Fixes 18 words
:B0X*?:sorbsi::f("sorpti") ; Web Freq 7.60 | Fixes 35 words
:B0X*?:sorbti::f("sorpti") ; Web Freq 7.60 | Fixes 35 words
:B0X*?:sosica::f("socia") ; Web Freq 429.44 | Fixes 155 words
:B0X*?:sotry::f("story") ; Web Freq 361.67 | Fixes 33 words
:B0X*?:sotyr::f("story") ; Web Freq 361.67 | Fixes 33 words
:B0X*?:soudn::f("sound") ; Web Freq 159.68 | Fixes 63 words
:B0X*?:sourse::f("source") ; Web Freq 569.40 | Fixes 34 words
:B0X*?:specal::f("special") ; Web Freq 440.86 | Fixes 68 words
:B0X*?:specfic::f("specific") ; Web Freq 194.95 | Fixes 30 words
:B0X*?:spectau::f("spectacu") ; Web Freq 11.07 | Fixes 8 words
:B0X*?:spectum::f("spectrum") ; Web Freq 15.44 | Fixes 4 words
:B0X*?:speedh::f("speech") ; Web Freq 38.32 | Fixes 20 words
:B0X*?:speical::f("special") ; Web Freq 440.86 | Fixes 68 words
:B0X*?:speing::f("spring") ; Web Freq 118.30 | Fixes 75 words
:B0X*?:speling::f("spelling") ; Web Freq 8.80 | Fixes 11 words
:B0X*?:spesial::f("special") ; Web Freq 440.86 | Fixes 68 words
:B0X*?:spiria::f("spira") ; Web Freq 42.42 | Fixes 85 words
:B0X*?:spoac::f("spac") ; Web Freq 187.04 | Fixes 121 words
:B0X*?:sponib::f("sponsib") ; Web Freq 139.78 | Fixes 13 words
:B0X*?:sponser::f("sponsor") ; Web Freq 151.57 | Fixes 16 words
:B0X*?:sppech::f("speech") ; Web Freq 38.32 | Fixes 20 words
:B0X*?:spred::f("spread") ; Web Freq 47.39 | Fixes 44 words
:B0X*?:spririt::f("spirit") ; Web Freq 77.75 | Fixes 85 words
:B0X*?:spritual::f("spiritual") ; Web Freq 29.91 | Fixes 39 words, but misspells spritual (A light spar that crosses a fore-and-aft sail diagonally)
:B0X*?:spyc::f("psyc") ; Web Freq 78.83 | Fixes 262 words, but misspells spycam (secret spy stuff), spycatcher (secret spy stuff)
:B0X*?:ssange::f("ssenge") ; Web Freq 42.76 | Fixes 6 words
:B0X*?:ssemm::f("ssem") ; Web Freq 61.55 | Fixes 86 words
:B0X*?:ssesed::f("ssessed") ; Web Freq 12.31 | Fixes 10 words 
:B0X*?:ssignit::f("ssignat") ; Web Freq 0.05 | Fixes 4 words
:B0X*?:ssill::f("ssibl") ; Web Freq 182.22 | Fixes 78 words
:B0X*?:ssition::f("sition") ; Web Freq 254.36 | Fixes 150 words
:B0X*?:sstion::f("sation") ; Web Freq 133.59 | Fixes 949 words
:B0X*?:stablise::f("stabilise") ; Web Freq 0.84 | Fixes 10 words
:B0X*?:stancial::f("stantial") ; Web Freq 24.13 | Fixes 45 words
:B0X*?:standars::f("standards") ; Web Freq 82.18 | Fixes 2 words
:B0X*?:stange::f("strange") ; Web Freq 30.18 | Fixes 18 words
:B0X*?:starna::f("sterna") ; Web Freq 0.73 | Fixes 17 words
:B0X*?:starteg::f("strateg") ; Web Freq 127.73 | Fixes 28 words
:B0X*?:stateman::f("statesman") ; Web Freq 1.83 | Fixes 6 words
:B0X*?:statia::f("stantia") ; Web Freq 27.57 | Fixes 77 words
:B0X*?:statme::f("stateme") ; Web Freq 137.86 | Fixes 18 words
:B0X*?:stcipt::f("script") ; Web Freq 439.96 | Fixes 130 words
:B0X*?:steroty::f("stereoty") ; Web Freq 3.44 | Fixes 13 words
:B0X*?:stingen::f("stringen") ; Web Freq 2.43 | Fixes 16 words
:B0X*?:stiring::f("stirring") ; Web Freq 2.17 | Fixes 6 words
:B0X*?:stirrs::f("stirs") ; Web Freq 0.43 | Fixes 4 words
:B0X*?:stituan::f("stituen") ; Web Freq 8.66 | Fixes 7 words
:B0X*?:stoin::f("stion") ; Web Freq 360.62 | Fixes 66 words, but misspells histoincompatibility (Medical term)
:B0X*?:stong::f("strong") ; Web Freq 98.54 | Fixes 33 words
:B0X*?:stradeg::f("strateg") ; Web Freq 127.73 | Fixes 28 words
:B0X*?:stratagi::f("strategi") ; Web Freq 70.56 | Fixes 25 words
:B0X*?:streem::f("stream") ; Web Freq 82.47 | Fixes 62 words
:B0X*?:strengh::f("strength") ; Web Freq 51.39 | Fixes 17 words
:B0X*?:stripted::f("scripted") ; Web Freq 0.83 | Fixes 6 words
:B0X*?:stripting::f("scripting") ; Web Freq 7.26 | Fixes 4 words
:B0X*?:stripts::f("scripts") ; Web Freq 26.49 | Fixes 16 words
:B0X*?:strnad::f("strand") ; Web Freq 16.96 | Fixes 16 words
:B0X*?:strrt::f("start") ; Web Freq 362.36 | Fixes 56 words
:B0X*?:structua::f("structura") ; Web Freq 17.94 | Fixes 23 words
:B0X*?:strungs::f("strings") ; Web Freq 12.66 | Fixes 15 words
:B0X*?:strungth::f("strength") ; Web Freq 51.39 | Fixes 17 words
:B0X*?:ststem::f("system") ; Web Freq 653.25 | Fixes 84 words
:B0X*?:stuct::f("struct") ; Web Freq 455.62 | Fixes 227 words
:B0X*?:studdy::f("study") ; Web Freq 162.85 | Fixes 10 words
:B0X*?:studing::f("studying") ; Web Freq 9.76 | Fixes 5 words
:B0X*?:sturct::f("struct") ; Web Freq 455.62 | Fixes 227 words
:B0X*?:stution::f("stitution") ; Web Freq 140.43 | Fixes 88 words
:B0X*?:substanci::f("substanti") ; Web Freq 28.69 | Fixes 77 words
:B0X*?:substitud::f("substitut") ; Web Freq 22.21 | Fixes 19 words
:B0X*?:succesf::f("successf") ; Web Freq 63.66 | Fixes 7 words
:B0X*?:succsess::f("success") ; Web Freq 137.39 | Fixes 26 words
:B0X*?:sucess::f("success") ; Web Freq 137.39 | Fixes 26 words
:B0X*?:sudent::f("student") ; Web Freq 348.73 | Fixes 10 words
:B0X*?:sueing::f("suing") ; Web Freq 10.14 | Fixes 12 words
:B0X*?:suffc::f("suffic") ; Web Freq 35.07 | Fixes 16 words
:B0X*?:sufficia::f("sufficie") ; Web Freq 33.01 | Fixes 10 words
:B0X*?:suise::f("suse") ; Web Freq 12.30 | Fixes 32 words
:B0X*?:suop::f("soup") ; Web Freq 13.01 | Fixes 24 words
:B0X*?:superintenda::f("superintende") ; Web Freq 6.61 | Fixes 7 words
:B0X*?:suppoe::f("suppose") ; Web Freq 30.02 | Fixes 9 words
:B0X*?:suppy::f("supply") ; Web Freq 76.94 | Fixes 8 words
:B0X*?:suprass::f("surpass") ; Web Freq 3.12 | Fixes 15 words
:B0X*?:supress::f("suppress") ; Web Freq 11.61 | Fixes 35 words
:B0X*?:supris::f("surpris") ; Web Freq 37.49 | Fixes 17 words
:B0X*?:supriz::f("surpris") ; Web Freq 37.49 | Fixes 17 words
:B0X*?:surect::f("surrect") ; Web Freq 8.20 | Fixes 21 words
:B0X*?:surenc::f("suranc") ; Web Freq 209.43 | Fixes 14 words
:B0X*?:surfce::f("surface") ; Web Freq 61.11 | Fixes 18 words
:B0X*?:surle::f("surel") ; Web Freq 9.32 | Fixes 13 words
:B0X*?:suro::f("surro") ; Web Freq 35.08 | Fixes 17 words
:B0X*?:surpii::f("surpris") ; Web Freq 37.49 | Fixes 17 words 
:B0X*?:surpress::f("suppress") ; Web Freq 11.61 | Fixes 35 words
:B0X*?:surpriz::f("surpris") ; Web Freq 37.49 | Fixes 17 words
:B0X*?:surring::f("suring") ; Web Freq 25.05 | Fixes 28 words
:B0X*?:susept::f("suscept") ; Web Freq 4.76 | Fixes 30 words
:B0X*?:svae::f("save") ; Web Freq 240.39 | Fixes 33 words
:B0X*?:sxh::f("sch") ; Web Freq 801.62 | Fixes 763 words
:B0X*?:sylabl::f("syllabl") ; Web Freq 1.75 | Fixes 22 words
:B0X*?:symetr::f("symmetr") ; Web Freq 11.97 | Fixes 42 words
:B0X*?:symmetral::f("symmetric") ; Web Freq 6.58 | Fixes 20 words
:B0X*?:syncro::f("synchro") ; Web Freq 14.77 | Fixes 81 words
:B0X*?:syness::f("siness") ; Web Freq 691.91 | Fixes 112 words
:B0X*?:sypmto::f("sympto") ; Web Freq 27.32 | Fixes 19 words
:B0X*?:sysmati::f("systemati") ; Web Freq 9.37 | Fixes 41 words
:B0X*?:sytem::f("system") ; Web Freq 653.25 | Fixes 84 words
:B0X*?:sytl::f("styl") ; Web Freq 185.87 | Fixes 148 words
:B0X*?:tacal::f("tacle") ; Web Freq 11.45 | Fixes 17 words, but misspells Catacala (moths whose larvae are cutworms: underwings)
:B0X*?:tagan::f("tagon") ; Web Freq 16.43 | Fixes 42 words, but misspells yatagan (Ottoman Turkish sword)
:B0X*?:tahl::f("thal") ; Web Freq 13.94 | Fixes 195 words, but misspells Stahl (A German surname, German for steel)
:B0X*?:tahn::f("than") ; Web Freq 717.79 | Fixes 202 words
:B0X*?:taht::f("that") ; Web Freq 3403.48 | Fixes 36 words
:B0X*?:tahw::f("thaw") ; Web Freq 2.71 | Fixes 20 words
:B0X*?:tailled::f("tailed") ; Web Freq 55.69 | Fixes 23 words
:B0X*?:taimi::f("tami") ; Web Freq 57.34 | Fixes 155 words
:B0X*?:tainen::f("tenan") ; Web Freq 71.00 | Fixes 53 words
:B0X*?:taion::f("tation") ; Web Freq 819.94 | Fixes 602 words
:B0X*?:taitj::f("traitj") ; Web Freq 0.12 | Fixes 4 words
:B0X*?:taito::f("traito") ; Web Freq 1.18 | Fixes 7 words
:B0X*?:talbe::f("table") ; Web Freq 516.19 | Fixes 634 words
:B0X*?:tanous::f("taneous") ; Web Freq 19.12 | Fixes 33 words, but misspells titanous (Referring to titanium)
:B0X*?:taral::f("tural") ; Web Freq 236.99 | Fixes 178 words, but misspells glutaraldehydes (chemical compound used as a disinfectant)
:B0X*?:tarat::f("turat") ; Web Freq 8.20 | Fixes 97 words
:B0X*?:tarrif::f("tariff") ; Web Freq 8.91 | Fixes 6 words
:B0X*?:tartet::f("target") ; Web Freq 83.16 | Fixes 15 words
:B0X*?:tatch::f("tach") ; Web Freq 83.43 | Fixes 149 words
:B0X*?:taxan::f("taxon") ; Web Freq 6.44 | Fixes 22 words
:B0X*?:tchei::f("tchie") ; Web Freq 1.69 | Fixes 48 words
:B0X*?:teahh::f("teach") ; Web Freq 202.59 | Fixes 38 words
:B0X*?:teceo::f("teco") ; Web Freq 3.15 | Fixes 22 words
:B0X*?:techic::f("technic") ; Web Freq 126.02 | Fixes 53 words
:B0X*?:techini::f("techni") ; Web Freq 185.13 | Fixes 60 words
:B0X*?:techt::f("tect") ; Web Freq 330.64 | Fixes 157 words
:B0X*?:tehi::f("thei") ; Web Freq 791.56 | Fixes 74 words
:B0X*?:tehm::f("them") ; Web Freq 559.09 | Fixes 128 words
:B0X*?:tehn::f("then") ; Web Freq 440.06 | Fixes 198 words
:B0X*?:tehs::f("thes") ; Web Freq 632.20 | Fixes 276 words, but misspells Tehsil (an administrative division in some countries of South Asia)
:B0X*?:telpho::f("telepho") ; Web Freq 76.14 | Fixes 23 words
:B0X*?:tempalt::f("templat") ; Web Freq 48.60 | Fixes 18 words
:B0X*?:tempar::f("temper") ; Web Freq 58.74 | Fixes 50 words
:B0X*?:temperar::f("temporar") ; Web Freq 54.18 | Fixes 17 words
:B0X*?:tempoa::f("tempora") ; Web Freq 60.62 | Fixes 53 words
:B0X*?:temporaneu::f("temporaneou") ; Web Freq 0.67 | Fixes 8 words
:B0X*?:tencia::f("tentia") ; Web Freq 81.15 | Fixes 36 words
:B0X*?:tendac::f("tendenc") ; Web Freq 6.16 | Fixes 11 words
:B0X*?:tendor::f("tender") ; Web Freq 22.85 | Fixes 62 words
:B0X*?:tenen::f("tenan") ; Web Freq 71.00 | Fixes 53 words
:B0X*?:tepmor::f("tempor") ; Web Freq 60.83 | Fixes 94 words
:B0X*?:teriod::f("teroid") ; Web Freq 10.30 | Fixes 29 words
:B0X*?:terrani::f("terrane") ; Web Freq 14.49 | Fixes 10 words
:B0X*?:terresti::f("terrestri") ; Web Freq 3.72 | Fixes 9 words
:B0X*?:terrior::f("territor") ; Web Freq 36.01 | Fixes 33 words
:B0X*?:territorist::f("terrorist") ; Web Freq 18.03 | Fixes 13 words
:B0X*?:terrois::f("terroris") ; Web Freq 35.98 | Fixes 35 words
:B0X*?:thaph::f("taph") ; Web Freq 9.24 | Fixes 74 words
:B0X*?:thatks::f("thanks") ; Web Freq 104.82 | Fixes 8 words
:B0X*?:theather::f("theater") ; Web Freq 40.49 | Fixes 10 words
:B0X*?:theese::f("these") ; Web Freq 547.01 | Fixes 25 words
:B0X*?:themslves::f("themselves") ; Web Freq 47.18 | Fixes 1 word
:B0X*?:thenke::f("thanke") ; Web Freq 2.04 | Fixes 6 words
:B0X*?:thenkf::f("thankf") ; Web Freq 3.76 | Fixes 9 words
:B0X*?:thenks::f("thanks") ; Web Freq 104.82 | Fixes 8 words
:B0X*?:theug::f("thoug") ; Web Freq 295.79 | Fixes 38 words
:B0X*?:thhing::f("tching") ; Web Freq 89.31 | Fixes 114 words
:B0X*?:thikk::f("think") ; Web Freq 280.85 | Fixes 56 words
:B0X*?:thiuc::f("thic") ; Web Freq 79.91 | Fixes 210 words
:B0X*?:thiue::f("thie") ; Web Freq 14.66 | Fixes 145 words
:B0X*?:thiun::f("thin") ; Web Freq 1279.13 | Fixes 350 words
:B0X*?:thiur::f("thir") ; Web Freq 120.30 | Fixes 53 words
:B0X*?:thogu::f("thoug") ; Web Freq 295.79 | Fixes 38 words
:B0X*?:thouth::f("though") ; Web Freq 295.79 | Fixes 38 words
:B0X*?:thouugh::f("through") ; Web Freq 401.62 | Fixes 12 words
:B0X*?:threshhold::f("threshold") ; Web Freq 12.95 | Fixes 5 words
:B0X*?:thror::f("thor") ; Web Freq 419.96 | Fixes 255 words
:B0X*?:thsoe::f("those") ; Web Freq 270.07 | Fixes 10 words
:B0X*?:thyat::f("that") ; Web Freq 3403.48 | Fixes 36 words
:B0X*?:tiait::f("tiat") ; Web Freq 101.36 | Fixes 159 words
:B0X*?:tiatiation::f("tiation") ; Web Freq 23.46 | Fixes 38 words
:B0X*?:tibut::f("tribut") ; Web Freq 303.69 | Fixes 104 words
:B0X*?:ticial::f("tical") ; Web Freq 410.64 | Fixes 994 words
:B0X*?:ticio::f("titio") ; Web Freq 99.95 | Fixes 84 words
:B0X*?:ticlul::f("ticul") ; Web Freq 137.01 | Fixes 169 words
:B0X*?:tiget::f("tiger") ; Web Freq 27.81 | Fixes 17 words
:B0X*?:tiion::f("tion") ; Web Freq 14369.56 | Fixes 8482 words
:B0X*?:tince::f("tence") ; Web Freq 53.62 | Fixes 74 words
:B0X*?:tingish::f("tinguish") ; Web Freq 19.29 | Fixes 39 words
:B0X*?:tinoa::f("tiona") ; Web Freq 1608.06 | Fixes 1101 words
:B0X*?:tinoe::f("tione") ; Web Freq 88.93 | Fixes 147 words
:B0X*?:tioge::f("toge") ; Web Freq 100.71 | Fixes 124 words
:B0X*?:tionnab::f("tionab") ; Web Freq 8.55 | Fixes 48 words
:B0X*?:tionnar::f("tionar") ; Web Freq 70.60 | Fixes 106 words
:B0X*?:tionnat::f("tionat") ; Web Freq 4.38 | Fixes 35 words
:B0X*?:tionne::f("tione") ; Web Freq 88.93 | Fixes 147 words
:B0X*?:tionni::f("tioni") ; Web Freq 47.56 | Fixes 362 words
:B0X*?:titidi::f("titudi") ; Web Freq 0.45 | Fixes 46 words
:B0X*?:titity::f("tity") ; Web Freq 83.66 | Fixes 18 words
:B0X*?:titui::f("tituti") ; Web Freq 143.72 | Fixes 102 words
:B0X*?:tiull::f("till") ; Web Freq 233.20 | Fixes 218 words
:B0X*?:tiviat::f("tivat") ; Web Freq 59.40 | Fixes 127 words
:B0X*?:tje::f("the") ; Web Freq 30399.85 | Fixes 2819 words, but misspells Betjeman (an English poet and writer.), Ondaatje (Canadian writer born in Sri Lanka 1943)
:B0X*?:tkaing::f("taking") ; Web Freq 79.62 | Fixes 25 words
:B0X*?:tloda::f("tload") ; Web Freq 0.51 | Fixes 12 words
:B0X*?:toake::f("talke") ; Web Freq 12.19 | Fixes 23 words
:B0X*?:tobbaco::f("tobacco") ; Web Freq 13.80 | Fixes 8 words
:B0X*?:todather::f("together") ; Web Freq 98.39 | Fixes 6 words
:B0X*?:todeth::f("togeth") ; Web Freq 98.39 | Fixes 6 words
:B0X*?:togani::f("tagoni") ; Web Freq 6.39 | Fixes 26 words
:B0X*?:togheth::f("togeth") ; Web Freq 98.39 | Fixes 6 words
:B0X*?:toina::f("tiona") ; Web Freq 1608.06 | Fixes 1101 words
:B0X*?:toine::f("tione") ; Web Freq 88.93 | Fixes 147 words
:B0X*?:toini::f("tioni") ; Web Freq 47.56 | Fixes 362 words
:B0X*?:toinl::f("tionl") ; Web Freq 0.80 | Fixes 33 words
:B0X*?:toleren::f("toleran") ; Web Freq 12.59 | Fixes 12 words
:B0X*?:tollu::f("tolu") ; Web Freq 0.96 | Fixes 28 words
:B0X*?:toubl::f("troubl") ; Web Freq 41.56 | Fixes 32 words
:B0X*?:tounge::f("tongue") ; Web Freq 11.80 | Fixes 16 words
:B0X*?:tourch::f("torch") ; Web Freq 5.22 | Fixes 36 words
:B0X*?:toword::f("toward") ; Web Freq 66.97 | Fixes 9 words
:B0X*?:towrad::f("toward") ; Web Freq 66.97 | Fixes 9 words
:B0X*?:tradion::f("tradition") ; Web Freq 75.41 | Fixes 28 words
:B0X*?:tradtion::f("tradition") ; Web Freq 75.41 | Fixes 28 words
:B0X*?:traet::f("treat") ; Web Freq 183.63 | Fixes 79 words 
:B0X*?:tranf::f("transf") ; Web Freq 134.20 | Fixes 106 words
:B0X*?:trangf::f("transf") ; Web Freq 134.20 | Fixes 106 words
:B0X*?:trangla::f("transla") ; Web Freq 70.92 | Fixes 38 words
:B0X*?:trangp::f("transp") ; Web Freq 191.66 | Fixes 112 words
:B0X*?:transcripting::f("transcribing") ; Web Freq 0.30 | Fixes 2 words
:B0X*?:transger::f("transfer") ; Web Freq 91.45 | Fixes 46 words
:B0X*?:transmissa::f("transmissi") ; Web Freq 27.74 | Fixes 16 words
:B0X*?:treab::f("terab") ; Web Freq 0.85 | Fixes 43 words
:B0X*?:treag::f("terag") ; Web Freq 1.40 | Fixes 20 words
:B0X*?:trear::f("terar") ; Web Freq 12.81 | Fixes 23 words
:B0X*?:triann::f("trienn") ; Web Freq 0.31 | Fixes 8 words
:B0X*?:tribusion::f("tribution") ; Web Freq 122.74 | Fixes 25 words
:B0X*?:triger::f("trigger") ; Web Freq 15.76 | Fixes 10 words
:B0X*?:triib::f("trib") ; Web Freq 345.14 | Fixes 186 words
:B0X*?:triing::f("trying") ; Web Freq 57.54 | Fixes 5 words
:B0X*?:tritian::f("trician") ; Web Freq 5.03 | Fixes 32 words
:B0X*?:tritut::f("tribut") ; Web Freq 303.69 | Fixes 104 words
:B0X*?:troling::f("trolling") ; Web Freq 10.28 | Fixes 10 words
:B0X*?:troverci::f("troversi") ; Web Freq 6.64 | Fixes 21 words
:B0X*?:trubution::f("tribution") ; Web Freq 122.74 | Fixes 25 words
:B0X*?:truch::f("truth") ; Web Freq 75.32 | Fixes 30 words
:B0X*?:tseh::f("tshe") ; Web Freq 3.30 | Fixes 15 words
:B0X*?:tstion::f("tation") ; Web Freq 819.94 | Fixes 602 words
:B0X*?:ttele::f("ttle") ; Web Freq 376.31 | Fixes 293 words
:B0X*?:ttitid::f("ttitud") ; Web Freq 20.12 | Fixes 16 words
:B0X*?:tuara::f("taura") ; Web Freq 107.69 | Fixes 13 words
:B0X*?:tudonal::f("tudinal") ; Web Freq 3.38 | Fixes 12 words
:B0X*?:turra::f("tura") ; Web Freq 249.24 | Fixes 325 words
:B0X*?:turring::f("turing") ; Web Freq 77.60 | Fixes 58 words
:B0X*?:tyfull::f("tiful") ; Web Freq 66.27 | Fixes 32 words
:B0X*?:tyhe::f("the") ; Web Freq 30399.85 | Fixes 2819 words, but misspells platyhelminth (parasitic or free-living worms having a flattened body)
:B0X*?:tyhi::f("thi") ; Web Freq 4766.06 | Fixes 1161 words
:B0X*?:udein::f("udien") ; Web Freq 29.39 | Fixes 8 words
:B0X*?:udner::f("under") ; Web Freq 637.98 | Fixes 951 words
:B0X*?:udnet::f("udent") ; Web Freq 353.38 | Fixes 27 words
:B0X*?:ugth::f("ught") ; Web Freq 322.93 | Fixes 198 words
:B0X*?:uisef::f("usef") ; Web Freq 60.76 | Fixes 14 words
:B0X*?:uisel::f("usel") ; Web Freq 8.01 | Fixes 47 words
:B0X*?:uiseu::f("useu") ; Web Freq 58.25 | Fixes 6 words
:B0X*?:uisew::f("usew") ; Web Freq 21.65 | Fixes 26 words
:B0X*?:uitiou::f("uitou") ; Web Freq 2.83 | Fixes 20 words
:B0X*?:uiton::f("uition") ; Web Freq 12.55 | Fixes 14 words
:B0X*?:ulaton::f("ulation") ; Web Freq 260.36 | Fixes 250 words
:B0X*?:ullk::f("ull") ; Web Freq 683.03 | Fixes 785 words
:B0X*?:ultue::f("ulture") ; Web Freq 149.02 | Fixes 65 words
:B0X*?:umei::f("umie") ; Web Freq 0.05 | Fixes 12 words
:B0X*?:umetal::f("umental") ; Web Freq 9.54 | Fixes 30 words
:B0X*?:understoon::f("understood") ; Web Freq 13.28 | Fixes 4 words
:B0X*?:uneing::f("uning") ; Web Freq 9.08 | Fixes 18 words
:B0X*?:unigue::f("unique") ; Web Freq 68.40 | Fixes 15 words
:B0X*?:untion::f("unction") ; Web Freq 240.71 | Fixes 91 words
:B0X*?:unviers::f("univers") ; Web Freq 393.07 | Fixes 36 words
:B0X*?:upaat::f("updat") ; Web Freq 268.58 | Fixes 11 words
:B0X*?:updaten::f("updatin") ; Web Freq 8.68 | Fixes 2 words
:B0X*?:updoad::f("upload") ; Web Freq 33.87 | Fixes 10 words
:B0X*?:upresp::f("upersp") ; Web Freq 0.02 | Fixes 17 words
:B0X*?:uraet::f("ureat") ; Web Freq 2.43 | Fixes 14 words 
:B0X*?:uraunt::f("urant") ; Web Freq 108.93 | Fixes 47 words
:B0X*?:urison::f("ursion") ; Web Freq 6.53 | Fixes 10 words
:B0X*?:urrar::f("urar") ; Web Freq 0.07 | Fixes 24 words
:B0X*?:urual::f("ural") ; Web Freq 293.07 | Fixes 321 words
:B0X*?:urveyer::f("urveyor") ; Web Freq 4.85 | Fixes 4 words
:B0X*?:useage::f("usage") ; Web Freq 29.55 | Fixes 10 words
:B0X*?:usege::f("usage") ; Web Freq 29.55 | Fixes 10 words
:B0X*?:useing::f("using") ; Web Freq 369.51 | Fixes 116 words
:B0X*?:usemm::f("usem") ; Web Freq 5.41 | Fixes 24 words
:B0X*?:useres::f("users") ; Web Freq 154.55 | Fixes 33 words
:B0X*?:ustsd::f("usted") ; Web Freq 34.21 | Fixes 48 words
:B0X*?:usuab::f("usab") ; Web Freq 10.79 | Fixes 44 words
:B0X*?:ususal::f("usual") ; Web Freq 125.70 | Fixes 9 words
:B0X*?:utent::f("utant") ; Web Freq 12.23 | Fixes 29 words
:B0X*?:utionna::f("utiona") ; Web Freq 44.26 | Fixes 110 words
:B0X*?:utrab::f("urab") ; Web Freq 24.17 | Fixes 125 words
:B0X*?:uttoo::f("utto") ; Web Freq 91.15 | Fixes 86 words
:B0X*?:uyt::f("ut") ; Web Freq 9041.41 | Fixes 6557 words, but misspells Huyton (A town in England), Nuytsia (Western Australian Christmas tree)
:B0X*?:vacativ::f("vocativ") ; Web Freq 1.99 | Fixes 16 words
:B0X*?:vaccum::f("vacuum") ; Web Freq 15.91 | Fixes 6 words
:B0X*?:vaiet::f("variet") ; Web Freq 55.58 | Fixes 7 words
:B0X*?:valant::f("valent") ; Web Freq 52.68 | Fixes 41 words
:B0X*?:valbe::f("vable") ; Web Freq 23.84 | Fixes 109 words
:B0X*?:valuaton::f("valuation") ; Web Freq 61.35 | Fixes 24 words
:B0X*?:valubl::f("valuabl") ; Web Freq 20.76 | Fixes 10 words
:B0X*?:valud::f("value") ; Web Freq 261.56 | Fixes 39 words
:B0X*?:valueabl::f("valuabl") ; Web Freq 20.76 | Fixes 10 words
:B0X*?:varaab::f("variab") ; Web Freq 64.48 | Fixes 17 words
:B0X*?:varatio::f("variatio") ; Web Freq 20.85 | Fixes 6 words
:B0X*?:varien::f("varian") ; Web Freq 22.12 | Fixes 18 words
:B0X*?:varing::f("varying") ; Web Freq 6.17 | Fixes 6 words
:B0X*?:variobl::f("variabl") ; Web Freq 60.51 | Fixes 13 words
:B0X*?:varioul::f("variabl") ; Web Freq 60.51 | Fixes 13 words
:B0X*?:varous::f("various") ; Web Freq 91.63 | Fixes 4 words
:B0X*?:vasall::f("vassal") ; Web Freq 0.21 | Fixes 6 words
:B0X*?:vegat::f("veget") ; Web Freq 31.22 | Fixes 38 words
:B0X*?:vegit::f("veget") ; Web Freq 31.22 | Fixes 38 words
:B0X*?:veinen::f("venien") ; Web Freq 32.87 | Fixes 23 words
:B0X*?:velanc::f("valenc") ; Web Freq 17.04 | Fixes 47 words
:B0X*?:velant::f("valent") ; Web Freq 52.68 | Fixes 41 words
:B0X*?:velei::f("velie") ; Web Freq 0.42 | Fixes 7 words
:B0X*?:velent::f("valent") ; Web Freq 52.68 | Fixes 41 words
:B0X*?:venem::f("venom") ; Web Freq 2.36 | Fixes 27 words
:B0X*?:vereal::f("veral") ; Web Freq 188.01 | Fixes 24 words
:B0X*?:veriol::f("variol") ; Web Freq 0.06 | Fixes 24 words
:B0X*?:verioo::f("versio") ; Web Freq 298.07 | Fixes 62 words
:B0X*?:verison::f("version") ; Web Freq 298.07 | Fixes 62 words
:B0X*?:vertibra::f("vertebra") ; Web Freq 4.77 | Fixes 13 words
:B0X*?:vertion::f("version") ; Web Freq 298.07 | Fixes 62 words
:B0X*?:vetat::f("vitat") ; Web Freq 19.30 | Fixes 31 words
:B0X*?:vidoo::f("video") ; Web Freq 467.42 | Fixes 44 words
:B0X*?:vigeur::f("vigor") ; Web Freq 5.19 | Fixes 30 words
:B0X*?:vigilen::f("vigilan") ; Web Freq 2.21 | Fixes 16 words
:B0X*?:visial::f("visual") ; Web Freq 64.80 | Fixes 36 words
:B0X*?:visona::f("visiona") ; Web Freq 7.95 | Fixes 21 words 
:B0X*?:visone::f("visione") ; Web Freq 1.35 | Fixes 8 words 
:B0X*?:visoni::f("visioni") ; Web Freq 2.63 | Fixes 17 words 
:B0X*?:visons::f("visions") ; Web Freq 58.06 | Fixes 14 words 
:B0X*?:visting::f("visiting") ; Web Freq 21.41 | Fixes 4 words
:B0X*?:vition::f("vision") ; Web Freq 306.55 | Fixes 77 words
:B0X*?:viull::f("vill") ; Web Freq 230.88 | Fixes 158 words
:B0X*?:vivous::f("vious") ; Web Freq 264.55 | Fixes 39 words
:B0X*?:vlalen::f("valen") ; Web Freq 69.72 | Fixes 88 words
:B0X*?:vlel::f("vell") ; Web Freq 30.61 | Fixes 128 words
:B0X*?:vleo::f("velo") ; Web Freq 570.77 | Fixes 108 words
:B0X*?:vles::f("vels") ; Web Freq 82.23 | Fixes 35 words
:B0X*?:vley::f("vely") ; Web Freq 141.37 | Fixes 568 words
:B0X*?:vment::f("vement") ; Web Freq 140.19 | Fixes 32 words
:B0X*?:volision::f("volition") ; Web Freq 0.46 | Fixes 5 words
:B0X*?:vollu::f("volu") ; Web Freq 230.73 | Fixes 183 words
:B0X*?:volont::f("volunt") ; Web Freq 82.89 | Fixes 31 words
:B0X*?:volount::f("volunt") ; Web Freq 82.89 | Fixes 31 words
:B0X*?:volumn::f("volum") ; Web Freq 84.44 | Fixes 24 words
:B0X*?:vreit::f("variet") ; Web Freq 55.58 | Fixes 7 words
:B0X*?:vstion::f("vation") ; Web Freq 190.42 | Fixes 130 words
:B0X*?:warrent::f("warrant") ; Web Freq 57.24 | Fixes 27 words
:B0X*?:wepth::f("wept") ; Web Freq 3.37 | Fixes 15 words
:B0X*?:whant::f("want") ; Web Freq 367.45 | Fixes 28 words
:B0X*?:whcch::f("which") ; Web Freq 813.75 | Fixes 3 words
:B0X*?:whech::f("which") ; Web Freq 813.75 | Fixes 3 words
:B0X*?:wherre::f("where") ; Web Freq 463.59 | Fixes 39 words
:B0X*?:whiel::f("wheel") ; Web Freq 65.70 | Fixes 87 words
:B0X*?:wierd::f("weird") ; Web Freq 24.73 | Fixes 21 words
:B0X*?:windoes::f("windows") ; Web Freq 337.20 | Fixes 5 words
:B0X*?:wirt::f("writ") ; Web Freq 414.30 | Fixes 135 words
:B0X*?:withdrawl::f("withdrawal") ; Web Freq 9.48 | Fixes 2 words
:B0X*?:withold::f("withhold") ; Web Freq 3.57 | Fixes 9 words
:B0X*?:wiull::f("will") ; Web Freq 1514.90 | Fixes 106 words
:B0X*?:worls::f("world") ; Web Freq 520.94 | Fixes 56 words
:B0X*?:woudn::f("wound") ; Web Freq 14.42 | Fixes 25 words
:B0X*?:wriet::f("write") ; Web Freq 204.85 | Fixes 71 words
:B0X*?:wrighter::f("writer") ; Web Freq 58.45 | Fixes 39 words
:B0X*?:writen::f("written") ; Web Freq 103.35 | Fixes 13 words
:B0X*?:writting::f("writing") ; Web Freq 102.69 | Fixes 33 words
:B0X*?:wrotg::f("wrong") ; Web Freq 54.65 | Fixes 23 words
:B0X*?:wroting::f("writing") ; Web Freq 102.69 | Fixes 33 words
:B0X*?:wrrthy::f("worthy") ; Web Freq 11.41 | Fixes 23 words
:B0X*?:wrrting::f("writing") ; Web Freq 102.69 | Fixes 33 words
:B0X*?:xei::f("xie") ; Web Freq 24.89 | Fixes 76 words
:B0X*?:xicial::f("xical") ; Web Freq 2.71 | Fixes 34 words
:B0X*?:xilbe::f("xible") ; Web Freq 20.18 | Fixes 7 words
:B0X*?:xprct::f("xpect") ; Web Freq 128.71 | Fixes 39 words
:B0X*?:yanno::f("yano") ; Web Freq 0.80 | Fixes 36 words
:B0X*?:yoiu::f("you") ; Web Freq 5508.06 | Fixes 79 words
:B0X*?:youch::f("touch") ; Web Freq 58.43 | Fixes 72 words
:B0X*?:youugh::f("though") ; Web Freq 295.79 | Fixes 38 words
:B0X*?:ypresp::f("ypersp") ; Web Freq 0.27 | Fixes 4 words
:B0X*?:ysemm::f("ysem") ; Web Freq 0.78 | Fixes 13 words
:B0X*?:ysym::f("ysem") ; Web Freq 0.78 | Fixes 13 words
:B0X*?:ythim::f("ythm") ; Web Freq 12.56 | Fixes 60 words
:B0X*?:ytion::f("tion") ; Web Freq 14369.56 | Fixes 8482 words
:B0X*?:zstion::f("zation") ; Web Freq 290.07 | Fixes 1170 words
:B0X*?C:Amercia::f("America") ; Web Freq 403.10 | Fixes 28 words, Case sensitive to not misspell amerciable (Of a crime or misdemeanor)
:B0X*?C:Milissa::f("Melissa") ; Web Freq 10.42 | Fixes 1 word
:B0X*?C:acj::f("ach") ; Web Freq 1413.38 | Fixes 1348 words
:B0X*?C:acxa::f("aca") ; Web Freq 217.66 | Fixes 459 words
:B0X*?C:aech::f("each") ; Web Freq 779.37 | Fixes 212 words
:B0X*?C:aerd::f("eard") ; Web Freq 53.44 | Fixes 56 words
:B0X*?C:aern::f("earn") ; Web Freq 403.72 | Fixes 92 words
:B0X*?C:ajh::f("ah") ; Web Freq 759.27 | Fixes 1042 words
:B0X*?C:aof::f("oaf") ; Web Freq 3.48 | Fixes 18 words
:B0X*?C:aox::f("oax") ; Web Freq 5.72 | Fixes 18 words
:B0X*?C:asrb::f("aseb") ; Web Freq 37.02 | Fixes 21 words
:B0X*?C:asrd::f("ased") ; Web Freq 422.68 | Fixes 86 words
:B0X*?C:asrl::f("asel") ; Web Freq 16.54 | Fixes 51 words
:B0X*?C:asrr::f("aser") ; Web Freq 62.79 | Fixes 91 words
:B0X*?C:atgh::f("ath") ; Web Freq 1158.01 | Fixes 1574 words
:B0X*?C:athga::f("atha") ; Web Freq 29.94 | Fixes 96 words
:B0X*?C:baet::f("best") ; Web Freq 788.22 | Fixes 97 words, Case-sensitive to not misspell Baetyl (sacred stone or rock in ancient religions)
:B0X*?C:balen::f("balan") ; Web Freq 106.50 | Fixes 49 words, Case-sensitive to not misspell Balenciaga (Spanish fashion designer)
:B0X*?C:basr::f("base") ; Web Freq 531.98 | Fixes 103 words, Case-sensitive to not misspell Basra, a city in Iraq.
:B0X*?C:beht::f("beth") ; Web Freq 42.18 | Fixes 37 words
:B0X*?C:beng::f("being") ; Web Freq 250.31 | Fixes 12 words, but misspells benga (a genre of Kenyan music), Case-sensitive to not misspell Bengali.
:B0X*?C:bnad::f("band") ; Web Freq 185.08 | Fixes 219 words
:B0X*?C:boev::f("bove") ; Web Freq 142.21 | Fixes 9 words
:B0X*?C:borigen::f("borigin") ; Web Freq 15.42 | Fixes 10 words
:B0X*?C:bouy::f("buoy") ; Web Freq 2.87 | Fixes 19 words, Case-sensitive to not misspell Bouyie (a branch of Tai language)
:B0X*?C:brod::f("broad") ; Web Freq 138.67 | Fixes 67 words, but misspells brodiaea (a type of plant), flatbrod (Type of Scandinavian bread)
:B0X*?C:busn::f("busin") ; Web Freq 691.66 | Fixes 26 words
:B0X*?C:caht::f("chat") ; Web Freq 106.50 | Fixes 103 words
:B0X*?C:casr::f("case") ; Web Freq 353.47 | Fixes 134 words
:B0X*?C:ccxa::f("cca") ; Web Freq 76.07 | Fixes 191 words
:B0X*?C:chj::f("ch") ; Web Freq 14097.56 | Fixes 11979 words
:B0X*?C:cihs::f("chis") ; Web Freq 28.78 | Fixes 200 words
:B0X*?C:cinf::f("cing") ; Web Freq 314.71 | Fixes 374 words
:B0X*?C:cixt::f("cist") ; Web Freq 17.02 | Fixes 167 words
:B0X*?C:ciys::f("cies") ; Web Freq 246.74 | Fixes 480 words
:B0X*?C:cja::f("cha") ; Web Freq 2565.55 | Fixes 2173 words
:B0X*?C:cje::f("che") ; Web Freq 2075.50 | Fixes 2695 words
:B0X*?C:cjh::f("ch") ; Web Freq 14097.56 | Fixes 11979 words
:B0X*?C:cji::f("chi") ; Web Freq 1878.33 | Fixes 2327 words
:B0X*?C:cjn::f("chn") ; Web Freq 554.65 | Fixes 229 words
:B0X*?C:cjo::f("cho") ; Web Freq 1031.35 | Fixes 1381 words
:B0X*?C:cjr::f("chr") ; Web Freq 465.54 | Fixes 719 words
:B0X*?C:cju::f("chu") ; Web Freq 213.20 | Fixes 394 words
:B0X*?C:ckka::f("cka") ; Web Freq 177.54 | Fixes 202 words
:B0X*?C:ckkb::f("ckb") ; Web Freq 68.05 | Fixes 153 words
:B0X*?C:ckkd::f("ckd") ; Web Freq 6.54 | Fixes 36 words
:B0X*?C:ckkf::f("ckf") ; Web Freq 6.38 | Fixes 81 words
:B0X*?C:ckkg::f("ckg") ; Web Freq 62.36 | Fixes 19 words
:B0X*?C:ckkh::f("ckh") ; Web Freq 14.21 | Fixes 96 words
:B0X*?C:ckkj::f("ckj") ; Web Freq 17.07 | Fixes 14 words
:B0X*?C:ckkl::f("ckl") ; Web Freq 126.22 | Fixes 491 words
:B0X*?C:ckkm::f("ckm") ; Web Freq 3.66 | Fixes 57 words
:B0X*?C:ckko::f("cko") ; Web Freq 50.71 | Fixes 104 words
:B0X*?C:ckkp::f("ckp") ; Web Freq 29.42 | Fixes 70 words
:B0X*?C:ckks::f("cks") ; Web Freq 467.84 | Fixes 1029 words
:B0X*?C:ckkt::f("ckt") ; Web Freq 17.83 | Fixes 71 words
:B0X*?C:ckku::f("cku") ; Web Freq 39.16 | Fixes 32 words
:B0X*?C:ckkw::f("ckw") ; Web Freq 16.16 | Fixes 100 words
:B0X*?C:ckky::f("cky") ; Web Freq 79.87 | Fixes 115 words
:B0X*?C:clae::f("clea") ; Web Freq 328.37 | Fixes 212 words, Case-sensitive to not misspell Claes, Scandinvian name.
:B0X*?C:cmo::f("com") ; Web Freq 5656.80 | Fixes 2172 words, Case-sensitive to protect acronym.
:B0X*?C:cna::f("can") ; Web Freq 2587.58 | Fixes 1287 words, but misspells Pycnanthemum (mint), Tridacna (giant clam). Case-Sensitive to protect acronym and McNally.
:B0X*?C:cokr::f("cork") ; Web Freq 12.80 | Fixes 32 words
:B0X*?C:comt::f("cont") ; Web Freq 2191.75 | Fixes 679 words, but misspells vicomte (French nobleman), Case sensitive so not misspell Comte (founder of Positivism and type of cheese)
:B0X*?C:cpoa::f("copa") ; Web Freq 7.20 | Fixes 79 words
:B0X*?C:cpoe::f("cope") ; Web Freq 62.78 | Fixes 222 words
:B0X*?C:cpoi::f("copi") ; Web Freq 53.65 | Fixes 174 words
:B0X*?C:cpom::f("com") ; Web Freq 5656.80 | Fixes 2172 words
:B0X*?C:cpop::f("copp") ; Web Freq 16.07 | Fixes 32 words
:B0X*?C:cpot::f("copt") ; Web Freq 9.05 | Fixes 37 words
:B0X*?C:cpoy::f("copy") ; Web Freq 491.90 | Fixes 94 words
:B0X*?C:ctae::f("cate") ; Web Freq 790.48 | Fixes 665 words, but misspells Actaea (Baneberry)
:B0X*?C:cxac::f("cac") ; Web Freq 56.76 | Fixes 210 words
:B0X*?C:cxad::f("cad") ; Web Freq 206.50 | Fixes 289 words
:B0X*?C:cxaf::f("caf") ; Web Freq 31.19 | Fixes 57 words
:B0X*?C:cxai::f("cai") ; Web Freq 40.01 | Fixes 113 words
:B0X*?C:cxak::f("cak") ; Web Freq 28.25 | Fixes 84 words
:B0X*?C:cxal::f("cal") ; Web Freq 3039.20 | Fixes 4317 words
:B0X*?C:cxam::f("cam") ; Web Freq 701.35 | Fixes 413 words
:B0X*?C:cxan::f("can") ; Web Freq 2587.58 | Fixes 1287 words
:B0X*?C:cxar::f("car") ; Web Freq 2084.26 | Fixes 1936 words
:B0X*?C:cxas::f("cas") ; Web Freq 1000.10 | Fixes 798 words
:B0X*?C:cxat::f("cat") ; Web Freq 3130.41 | Fixes 2371 words
:B0X*?C:cxau::f("cau") ; Web Freq 464.46 | Fixes 220 words
:B0X*?C:cxav::f("cav") ; Web Freq 39.47 | Fixes 157 words
:B0X*?C:daer::f("dear") ; Web Freq 25.49 | Fixes 36 words
:B0X*?C:dcxa::f("dca") ; Web Freq 74.43 | Fixes 87 words
:B0X*?C:ddti::f("dditi") ; Web Freq 231.24 | Fixes 20 words
:B0X*?C:dinf::f("ding") ; Web Freq 1979.60 | Fixes 1207 words
:B0X*?C:dixt::f("dist") ; Web Freq 449.83 | Fixes 408 words
:B0X*?C:diys::f("dies") ; Web Freq 241.95 | Fixes 301 words
:B0X*?C:djh::f("dh") ; Web Freq 126.53 | Fixes 360 words
:B0X*?C:doev::f("dove") ; Web Freq 17.10 | Fixes 35 words
:B0X*?C:doimg::f("doing") ; Web Freq 82.43 | Fixes 24 words
:B0X*?C:dokr::f("dork") ; Web Freq 1.30 | Fixes 9 words
:B0X*?C:dtlak::f("dtalk") ; Web Freq 0.06 | Fixes 2 words
:B0X*?C:easr::f("ease") ; Web Freq 978.61 | Fixes 202 words
:B0X*?C:ecj::f("ech") ; Web Freq 856.19 | Fixes 770 words
:B0X*?C:eckk::f("eck") ; Web Freq 478.51 | Fixes 463 words
:B0X*?C:ecxa::f("eca") ; Web Freq 470.78 | Fixes 630 words
:B0X*?C:eeht::f("eeth") ; Web Freq 18.41 | Fixes 35 words
:B0X*?C:ehga::f("eha") ; Web Freq 122.22 | Fixes 190 words
:B0X*?C:ehta::f("etha") ; Web Freq 17.76 | Fixes 129 words
:B0X*?C:ehti::f("ethi") ; Web Freq 178.09 | Fixes 118 words
:B0X*?C:ehtn::f("ethn") ; Web Freq 24.71 | Fixes 81 words
:B0X*?C:ehto::f("etho") ; Web Freq 205.84 | Fixes 134 words
:B0X*?C:ehty::f("ethy") ; Web Freq 13.73 | Fixes 129 words
:B0X*?C:ejh::f("eh") ; Web Freq 477.65 | Fixes 964 words
:B0X*?C:elpa::f("epla") ; Web Freq 104.80 | Fixes 112 words, but misspells helpable (capable of being helped, uncommon word), semelparous (organisms that reproduce only once in their lifetime). Case sensitive to not misspell CELPA.
:B0X*?C:elyl::f("ely") ; Web Freq 691.42 | Fixes 1185 words
:B0X*?C:epulic::f("epublic") ; Web Freq 105.55 | Fixes 19 words
:B0X*?C:esab::f("essab") ; Web Freq 0.70 | Fixes 12 words
:B0X*?C:etgh::f("eth") ; Web Freq 795.33 | Fixes 902 words
:B0X*?C:ethga::f("etha") ; Web Freq 17.76 | Fixes 129 words
:B0X*?C:etih::f("eith") ; Web Freq 136.98 | Fixes 9 words
:B0X*?C:etyh::f("eth") ; Web Freq 795.33 | Fixes 902 words
:B0X*?C:evb::f("eb") ; Web Freq 2298.84 | Fixes 2131 words
:B0X*?C:eyu::f("ey") ; Web Freq 2745.71 | Fixes 1500 words
:B0X*?C:ezyn::f("ezin") ; Web Freq 8.91 | Fixes 32 words
:B0X*?C:fatc::f("fact") ; Web Freq 451.38 | Fixes 198 words
:B0X*?C:felicid::f("felicit") ; Web Freq 1.31 | Fixes 19 words
:B0X*?C:fidn::f("find") ; Web Freq 615.25 | Fixes 33 words
:B0X*?C:fiet::f("feit") ; Web Freq 5.11 | Fixes 28 words
:B0X*?C:fiil::f("fil") ; Web Freq 1165.50 | Fixes 459 words
:B0X*?C:finet::f("finit") ; Web Freq 117.65 | Fixes 62 words
:B0X*?C:firc::f("furc") ; Web Freq 0.75 | Fixes 27 words
:B0X*?C:fnat::f("fant") ; Web Freq 89.99 | Fixes 94 words
:B0X*?C:fokr::f("fork") ; Web Freq 13.90 | Fixes 35 words
:B0X*?C:frmo::f("from") ; Web Freq 2276.83 | Fixes 8 words
:B0X*?C:frod::f("ford") ; Web Freq 254.32 | Fixes 97 words
:B0X*?C:frok::f("fork") ; Web Freq 13.90 | Fixes 35 words
:B0X*?C:geht::f("geth") ; Web Freq 98.39 | Fixes 6 words
:B0X*?C:giid::f("good") ; Web Freq 446.75 | Fixes 49 words, but misspells Phalangiidae (typoe of Huntsman spider)
:B0X*?C:ginf::f("ging") ; Web Freq 344.74 | Fixes 708 words
:B0X*?C:gixt::f("gist") ; Web Freq 417.36 | Fixes 697 words
:B0X*?C:giys::f("gies") ; Web Freq 123.36 | Fixes 536 words
:B0X*?C:gjh::f("gh") ; Web Freq 4655.44 | Fixes 2186 words
:B0X*?C:glph::f("glyph") ; Web Freq 2.16 | Fixes 29 words
:B0X*?C:glua::f("gula") ; Web Freq 227.07 | Fixes 227 words
:B0X*?C:goev::f("gove") ; Web Freq 294.79 | Fixes 70 words
:B0X*?C:gowm::f("gown") ; Web Freq 5.42 | Fixes 14 words
:B0X*?C:grwo::f("grow") ; Web Freq 174.76 | Fixes 92 words
:B0X*?C:gsit::f("gist") ; Web Freq 417.36 | Fixes 697 words
:B0X*?C:gtyh::f("gth") ; Web Freq 133.34 | Fixes 43 words
:B0X*?C:gubl::f("guabl") ; Web Freq 2.14 | Fixes 8 words
:B0X*?C:hasr::f("hase") ; Web Freq 204.70 | Fixes 76 words
:B0X*?C:hcih::f("hich") ; Web Freq 815.02 | Fixes 18 words
:B0X*?C:hgad::f("had") ; Web Freq 556.79 | Fixes 232 words
:B0X*?C:hgal::f("hal") ; Web Freq 681.52 | Fixes 1270 words
:B0X*?C:hgan::f("han") ; Web Freq 2293.73 | Fixes 1481 words
:B0X*?C:hgar::f("har") ; Web Freq 1715.04 | Fixes 1488 words
:B0X*?C:hgas::f("has") ; Web Freq 1348.87 | Fixes 483 words
:B0X*?C:hgav::f("hav") ; Web Freq 1793.52 | Fixes 156 words
:B0X*?C:hgaw::f("haw") ; Web Freq 104.80 | Fixes 192 words
:B0X*?C:hixt::f("hist") ; Web Freq 353.79 | Fixes 342 words
:B0X*?C:hiys::f("hies") ; Web Freq 16.52 | Fixes 418 words
:B0X*?C:hnag::f("hang") ; Web Freq 598.16 | Fixes 217 words
:B0X*?C:hnat::f("hant") ; Web Freq 85.39 | Fixes 172 words
:B0X*?C:holf::f("hold") ; Web Freq 248.07 | Fixes 168 words
:B0X*?C:hthga::f("htha") ; Web Freq 5.16 | Fixes 67 words
:B0X*?C:hvae::f("have") ; Web Freq 1610.90 | Fixes 70 words
:B0X*?C:hvai::f("havi") ; Web Freq 176.09 | Fixes 51 words
:B0X*?C:hvea::f("have") ; Web Freq 1610.90 | Fixes 70 words
:B0X*?C:ibte::f("ibite") ; Web Freq 20.72 | Fixes 18 words, but misspells bibtex (a computer/tech term)
:B0X*?C:icj::f("ich") ; Web Freq 1226.40 | Fixes 674 words
:B0X*?C:icpo::f("icop") ; Web Freq 9.29 | Fixes 28 words
:B0X*?C:iegh::f("eigh") ; Web Freq 344.95 | Fixes 232 words
:B0X*?C:iegn::f("eign") ; Web Freq 84.12 | Fixes 79 words
:B0X*?C:ieht::f("ieth") ; Web Freq 4.52 | Fixes 32 words
:B0X*?C:ievn::f("iven") ; Web Freq 173.36 | Fixes 681 words
:B0X*?C:ihsh::f("hish") ; Web Freq 3.11 | Fixes 35 words
:B0X*?C:ihsm::f("hism") ; Web Freq 9.50 | Fixes 133 words
:B0X*?C:ihsp::f("hisp") ; Web Freq 18.10 | Fixes 30 words
:B0X*?C:ihst::f("hist") ; Web Freq 353.79 | Fixes 342 words
:B0X*?C:iht::f("ith") ; Web Freq 4130.68 | Fixes 790 words
:B0X*?C:ijh::f("ih") ; Web Freq 27.19 | Fixes 192 words
:B0X*?C:ijng::f("ing") ; Web Freq 18410.23 | Fixes 20290 words
:B0X*?C:infs::f("ings") ; Web Freq 1032.62 | Fixes 2258 words
:B0X*?C:iopn::f("ion") ; Web Freq 17490.92 | Fixes 10404 words
:B0X*?C:iosn::f("ions") ; Web Freq 3544.86 | Fixes 3687 words
:B0X*?C:ithga::f("itha") ; Web Freq 3.27 | Fixes 30 words
:B0X*?C:ixtr::f("istr") ; Web Freq 628.59 | Fixes 375 words
:B0X*?C:iyst::f("iest") ; Web Freq 38.50 | Fixes 1466 words
:B0X*?C:izyn::f("izin") ; Web Freq 67.09 | Fixes 969 words
:B0X*?C:jhi::f("hi") ; Web Freq 13181.65 | Fixes 8724 words
:B0X*?C:jhl::f("hl") ; Web Freq 311.37 | Fixes 1001 words
:B0X*?C:jho::f("ho") ; Web Freq 13733.78 | Fixes 8808 words
:B0X*?C:jhr::f("hr") ; Web Freq 1706.19 | Fixes 2169 words
:B0X*?C:jhs::f("hs") ; Web Freq 369.87 | Fixes 1128 words
:B0X*?C:jhy::f("hy") ; Web Freq 942.19 | Fixes 3601 words
:B0X*?C:juct::f("junct") ; Web Freq 26.65 | Fixes 64 words
:B0X*?C:kjh::f("kh") ; Web Freq 47.75 | Fixes 358 words
:B0X*?C:ktlak::f("ktalk") ; Web Freq 0.12 | Fixes 2 words
:B0X*?C:lasr::f("lase") ; Web Freq 48.25 | Fixes 64 words
:B0X*?C:leht::f("leth") ; Web Freq 6.36 | Fixes 70 words
:B0X*?C:leza::f("liza") ; Web Freq 98.15 | Fixes 508 words
:B0X*?C:lht::f("lth") ; Web Freq 638.11 | Fixes 102 words
:B0X*?C:linf::f("ling") ; Web Freq 1029.67 | Fixes 2284 words
:B0X*?C:lixt::f("list") ; Web Freq 1197.54 | Fixes 949 words
:B0X*?C:liys::f("lies") ; Web Freq 263.60 | Fixes 498 words
:B0X*?C:ljh::f("lh") ; Web Freq 34.59 | Fixes 192 words
:B0X*?C:lnad::f("land") ; Web Freq 1176.36 | Fixes 577 words, but misspells ulnad (Medical term)
:B0X*?C:lnat::f("lant") ; Web Freq 218.29 | Fixes 346 words
:B0X*?C:lpp::f("lp") ; Web Freq 994.00 | Fixes 675 words
:B0X*?C:lthga::f("ltha") ; Web Freq 2.93 | Fixes 13 words
:B0X*?C:ltye::f("ltie") ; Web Freq 33.01 | Fixes 65 words
:B0X*?C:ltyh::f("lth") ; Web Freq 638.11 | Fixes 102 words
:B0X*?C:mananc::f("manenc") ; Web Freq 0.86 | Fixes 16 words
:B0X*?C:mayn::f("many") ; Web Freq 411.58 | Fixes 9 words, but misspells Tremayne (A Cornish surname), Case-sensitive to not misspell Maynard
:B0X*?C:meht::f("meth") ; Web Freq 353.53 | Fixes 252 words
:B0X*?C:minf::f("ming") ; Web Freq 489.74 | Fixes 584 words
:B0X*?C:mmanan::f("mmanen") ; Web Freq 0.18 | Fixes 11 words
:B0X*?C:moev::f("move") ; Web Freq 263.21 | Fixes 51 words
:B0X*?C:mork::f("mark") ; Web Freq 840.17 | Fixes 241 words, but misspells Morkin (dead livestock unfit for human consumption). Case-sensitive to not misspell "Mork from Ork."
:B0X*?C:mrak::f("mark") ; Web Freq 840.17 | Fixes 241 words
:B0X*?C:mroe::f("more") ; Web Freq 3163.45 | Fixes 118 words
:B0X*?C:mron::f("morn") ; Web Freq 55.99 | Fixes 12 words
:B0X*?C:msot::f("most") ; Web Freq 519.62 | Fixes 98 words
:B0X*?C:mtih::f("mith") ; Web Freq 149.74 | Fixes 90 words
:B0X*?C:munb::f("numb") ; Web Freq 525.53 | Fixes 61 words
:B0X*?C:myu::f("my") ; Web Freq 1534.04 | Fixes 1294 words
:B0X*?C:nadb::f("andb") ; Web Freq 36.76 | Fixes 69 words
:B0X*?C:nadl::f("andl") ; Web Freq 131.80 | Fixes 162 words
:B0X*?C:nadw::f("andw") ; Web Freq 26.81 | Fixes 42 words
:B0X*?C:nady::f("andy") ; Web Freq 72.54 | Fixes 61 words
:B0X*?C:naty::f("anty") ; Web Freq 49.83 | Fixes 29 words
:B0X*?C:ncj::f("nch") ; Web Freq 609.16 | Fixes 1278 words
:B0X*?C:nclr::f("ncr") ; Web Freq 261.78 | Fixes 242 words
:B0X*?C:ncxa::f("nca") ; Web Freq 74.02 | Fixes 356 words
:B0X*?C:neht::f("neth") ; Web Freq 46.50 | Fixes 29 words
:B0X*?C:nght::f("ngth") ; Web Freq 133.34 | Fixes 43 words
:B0X*?C:nhga::f("nha") ; Web Freq 124.47 | Fixes 220 words
:B0X*?C:nht::f("nth") ; Web Freq 432.35 | Fixes 938 words
:B0X*?C:nisb::f("nsib") ; Web Freq 149.84 | Fixes 107 words
:B0X*?C:nixt::f("nist") ; Web Freq 356.12 | Fixes 749 words
:B0X*?C:niys::f("nies") ; Web Freq 149.33 | Fixes 319 words
:B0X*?C:njh::f("nh") ; Web Freq 262.31 | Fixes 735 words
:B0X*?C:nkow::f("know") ; Web Freq 609.38 | Fixes 81 words, but misspells Gronkowski (A Polish surname), Minkowski (German mathematician)
:B0X*?C:nlcu::f("nclu") ; Web Freq 675.90 | Fixes 46 words
:B0X*?C:nnst::f("nst") ; Web Freq 1306.17 | Fixes 915 words, but misspells Dennstaedtia (fern), Hoffmannsthal (poet)
:B0X*?C:noev::f("nove") ; Web Freq 218.86 | Fixes 60 words
:B0X*?C:nokr::f("nork") ; Web Freq 3.07 | Fixes 16 words
:B0X*?C:norigen::f("norigin") ; Web Freq 0.14 | Fixes 6 words
:B0X*?C:nrok::f("nork") ; Web Freq 3.07 | Fixes 16 words
:B0X*?C:nthga::f("ntha") ; Web Freq 4.22 | Fixes 75 words
:B0X*?C:nubm::f("numb") ; Web Freq 525.53 | Fixes 61 words
:B0X*?C:ocpo::f("ocop") ; Web Freq 4.30 | Fixes 31 words
:B0X*?C:ocup::f("occup") ; Web Freq 57.42 | Fixes 40 words
:B0X*?C:ocxa::f("oca") ; Web Freq 868.45 | Fixes 893 words
:B0X*?C:oevd::f("oved") ; Web Freq 182.01 | Fixes 52 words
:B0X*?C:oevl::f("ovel") ; Web Freq 63.25 | Fixes 115 words
:B0X*?C:oevm::f("ovem") ; Web Freq 264.90 | Fixes 14 words
:B0X*?C:oevn::f("oven") ; Web Freq 61.83 | Fixes 93 words
:B0X*?C:oevr::f("over") ; Web Freq 1621.40 | Fixes 2909 words
:B0X*?C:oht::f("oth") ; Web Freq 2156.56 | Fixes 1026 words
:B0X*?C:ojh::f("oh") ; Web Freq 893.06 | Fixes 525 words
:B0X*?C:okri::f("orki") ; Web Freq 200.39 | Fixes 68 words
:B0X*?C:okrs::f("orks") ; Web Freq 257.55 | Fixes 183 words
:B0X*?C:olpe::f("ople") ; Web Freq 502.90 | Fixes 84 words, but misspells holpen (Archaic form of the verb 'help'), olpe (An archaeology term to describe ancient Greek pottery vessel)
:B0X*?C:ooev::f("oove") ; Web Freq 16.40 | Fixes 30 words
:B0X*?C:oppen::f("open") ; Web Freq 341.84 | Fixes 123 words, Case-sensitive so not to misspell Oppenheimer.
:B0X*?C:origena::f("origina") ; Web Freq 171.96 | Fixes 32 words
:B0X*?C:otgh::f("oth") ; Web Freq 2156.56 | Fixes 1026 words
:B0X*?C:othga::f("otha") ; Web Freq 3.33 | Fixes 47 words
:B0X*?C:otyh::f("oth") ; Web Freq 2156.56 | Fixes 1026 words
:B0X*?C:ouhg::f("ough") ; Web Freq 979.80 | Fixes 324 words
:B0X*?C:ouhh::f("ough") ; Web Freq 979.80 | Fixes 324 words
:B0X*?C:oulb::f("oubl") ; Web Freq 131.08 | Fixes 75 words, but misspells Goulburn (A city in Australia), foulbrood (A bacterial disease affecting honeybee larvae)
:B0X*?C:owah::f("owha") ; Web Freq 0.59 | Fixes 14 words
:B0X*?C:owmi::f("owni") ; Web Freq 17.88 | Fixes 53 words
:B0X*?C:owml::f("ownl") ; Web Freq 351.08 | Fixes 33 words
:B0X*?C:owmt::f("ownt") ; Web Freq 25.07 | Fixes 23 words
:B0X*?C:owrk::f("work") ; Web Freq 1328.63 | Fixes 504 words
:B0X*?C:palc::f("plac") ; Web Freq 495.13 | Fixes 182 words
:B0X*?C:pbli::f("publi") ; Web Freq 821.32 | Fixes 90 words
:B0X*?C:pcik::f("pick") ; Web Freq 93.70 | Fixes 119 words
:B0X*?C:phga::f("pha") ; Web Freq 280.40 | Fixes 1196 words
:B0X*?C:pihs::f("phis") ; Web Freq 30.49 | Fixes 195 words
:B0X*?C:pixt::f("pist") ; Web Freq 28.36 | Fixes 170 words
:B0X*?C:pjh::f("ph") ; Web Freq 2734.02 | Fixes 7368 words
:B0X*?C:pld::f("ple") ; Web Freq 2257.95 | Fixes 1166 words
:B0X*?C:pligy::f("plify") ; Web Freq 6.02 | Fixes 8 words
:B0X*?C:pnad::f("pand") ; Web Freq 66.66 | Fixes 94 words
:B0X*?C:pnat::f("pant") ; Web Freq 102.41 | Fixes 117 words
:B0X*?C:poev::f("pove") ; Web Freq 21.20 | Fixes 22 words
:B0X*?C:pokr::f("pork") ; Web Freq 6.76 | Fixes 26 words
:B0X*?C:pomd::f("pond") ; Web Freq 122.69 | Fixes 129 words
:B0X*?C:porv::f("prov") ; Web Freq 1050.99 | Fixes 244 words
:B0X*?C:postit::f("posit") ; Web Freq 333.68 | Fixes 244 words
:B0X*?C:ppub::f("pub") ; Web Freq 887.00 | Fixes 131 words
:B0X*?C:provent::f("prevent") ; Web Freq 88.30 | Fixes 27 words, but misspells proventriculi (Glandular part of a bird's stomach), Case-sensitive to not misspell Proventil (A drug name)
:B0X*?C:ptlak::f("ptalk") ; Web Freq 0.11 | Fixes 10 words
:B0X*?C:pulica::f("publica") ; Web Freq 160.65 | Fixes 20 words, Case-sensitive to not misspell Pulicaria (Genus of temperate Old World herbs: fleabane)
:B0X*?C:qaur::f("quar") ; Web Freq 161.65 | Fixes 160 words
:B0X*?C:qit::f("quit") ; Web Freq 122.97 | Fixes 112 words
:B0X*?C:qtui::f("quit") ; Web Freq 122.97 | Fixes 112 words
:B0X*?C:quti::f("quit") ; Web Freq 122.97 | Fixes 112 words
:B0X*?C:raer::f("rear") ; Web Freq 35.86 | Fixes 98 words
:B0X*?C:rafic::f("rific") ; Web Freq 36.89 | Fixes 95 words, but misspells ultrafiche (Simlar to Microfiche storage media)
:B0X*?C:rafy::f("raft") ; Web Freq 152.78 | Fixes 198 words
:B0X*?C:rasr::f("rase") ; Web Freq 39.79 | Fixes 149 words
:B0X*?C:rcj::f("rch") ; Web Freq 2708.77 | Fixes 953 words
:B0X*?C:rcxa::f("rca") ; Web Freq 66.74 | Fixes 343 words
:B0X*?C:reht::f("reth") ; Web Freq 9.47 | Fixes 83 words
:B0X*?C:rht::f("rth") ; Web Freq 1282.52 | Fixes 772 words
:B0X*?C:ritm::f("rithm") ; Web Freq 31.86 | Fixes 26 words
:B0X*?C:rixt::f("rist") ; Web Freq 485.37 | Fixes 670 words, but misspells Brixton (An area in London)
:B0X*?C:riys::f("ries") ; Web Freq 1214.39 | Fixes 1343 words
:B0X*?C:rjh::f("rh") ; Web Freq 225.00 | Fixes 1003 words
:B0X*?C:rmanan::f("rmanen") ; Web Freq 34.99 | Fixes 19 words
:B0X*?C:rowm::f("rown") ; Web Freq 213.34 | Fixes 134 words
:B0X*?C:rtgh::f("rth") ; Web Freq 1282.52 | Fixes 772 words
:B0X*?C:rthga::f("rtha") ; Web Freq 17.86 | Fixes 25 words
:B0X*?C:rtih::f("rith") ; Web Freq 33.22 | Fixes 64 words
:B0X*?C:rtyh::f("rth") ; Web Freq 1282.52 | Fixes 772 words
:B0X*?C:scj::f("sch") ; Web Freq 801.62 | Fixes 763 words
:B0X*?C:scpo::f("scop") ; Web Freq 72.47 | Fixes 382 words, Case-sensitive to not misspell SCPO (a Navy rank)
:B0X*?C:scxa::f("sca") ; Web Freq 396.78 | Fixes 954 words
:B0X*?C:sesi::f("sessi") ; Web Freq 123.08 | Fixes 51 words, but misspells housesit (Take care of someone's house)
:B0X*?C:sgin::f("sign") ; Web Freq 1108.06 | Fixes 302 words
:B0X*?C:shco::f("scho") ; Web Freq 530.35 | Fixes 145 words
:B0X*?C:siad::f("said") ; Web Freq 317.47 | Fixes 15 words
:B0X*?C:sigin::f("sign") ; Web Freq 1108.06 | Fixes 302 words, Case-sensitive to not misspell SIGINT "Info from electronics telemetry intel."
:B0X*?C:sih::f("ish") ; Web Freq 1630.61 | Fixes 2481 words, but misspells Sihasapa (member of Siouan Native Americans), sihr (Arabic word meaning magic or sorcery)
:B0X*?C:sjh::f("sh") ; Web Freq 7700.57 | Fixes 8164 words
:B0X*?C:snad::f("sand") ; Web Freq 158.94 | Fixes 181 words, but misspells Whipsnade (A place in England)
:B0X*?C:socal::f("social") ; Web Freq 154.68 | Fixes 68 words, but misspells isocaloric (Dieting term for equal calories). Case-sensitive for SoCal (S. California)
:B0X*?C:spet::f("sept") ; Web Freq 181.39 | Fixes 87 words, but misspells Spetsnaz (Russian special forces)
:B0X*?C:srod::f("sord") ; Web Freq 31.58 | Fixes 30 words
:B0X*?C:sthga::f("stha") ; Web Freq 3.08 | Fixes 15 words
:B0X*?C:suph::f("soph") ; Web Freq 61.05 | Fixes 184 words
:B0X*?C:supo::f("suppo") ; Web Freq 515.32 | Fixes 63 words
:B0X*?C:tamt::f("tant") ; Web Freq 409.99 | Fixes 414 words
:B0X*?C:tcj::f("tch") ; Web Freq 854.69 | Fixes 1184 words
:B0X*?C:tecn::f("techn") ; Web Freq 521.43 | Fixes 125 words
:B0X*?C:tehr::f("ther") ; Web Freq 3581.16 | Fixes 1181 words, Case sesnsitive to not misspell Tehran (Capital and largest city of Iran)
:B0X*?C:teht::f("teth") ; Web Freq 1.85 | Fixes 28 words
:B0X*?C:tempra::f("tempora") ; Web Freq 60.62 | Fixes 53 words, Case sensitive to not misspell Tempra (type of medicine)
:B0X*?C:tgha::f("tha") ; Web Freq 4228.19 | Fixes 716 words
:B0X*?C:tghe::f("the") ; Web Freq 30399.85 | Fixes 2819 words
:B0X*?C:tgho::f("tho") ; Web Freq 1800.82 | Fixes 1321 words
:B0X*?C:tghr::f("thr") ; Web Freq 1084.45 | Fixes 839 words
:B0X*?C:tghy::f("thy") ; Web Freq 135.57 | Fixes 463 words
:B0X*?C:thgab::f("thab") ; Web Freq 1.76 | Fixes 12 words
:B0X*?C:thgac::f("thac") ; Web Freq 3.60 | Fixes 24 words
:B0X*?C:thgag::f("thag") ; Web Freq 1.77 | Fixes 5 words
:B0X*?C:thgai::f("thai") ; Web Freq 38.38 | Fixes 8 words
:B0X*?C:thgam::f("tham") ; Web Freq 24.31 | Fixes 36 words
:B0X*?C:thgap::f("thap") ; Web Freq 0.26 | Fixes 7 words
:B0X*?C:thgau::f("thau") ; Web Freq 0.21 | Fixes 16 words
:B0X*?C:thgay::f("thay") ; Web Freq 1.32 | Fixes 3 words
:B0X*?C:thgaz::f("thaz") ; Web Freq 0.34 | Fixes 5 words
:B0X*?C:thiesm::f("theism") ; Web Freq 1.69 | Fixes 19 words
:B0X*?C:thnn::f("then") ; Web Freq 440.06 | Fixes 198 words
:B0X*?C:thtt::f("that") ; Web Freq 3403.48 | Fixes 36 words
:B0X*?C:tihm::f("ithm") ; Web Freq 31.86 | Fixes 26 words
:B0X*?C:tihs::f("this") ; Web Freq 3231.35 | Fixes 68 words
:B0X*?C:tixt::f("tist") ; Web Freq 296.63 | Fixes 370 words
:B0X*?C:tiys::f("ties") ; Web Freq 956.18 | Fixes 2125 words
:B0X*?C:tizt::f("tist") ; Web Freq 296.63 | Fixes 370 words
:B0X*?C:tjh::f("th") ; Web Freq 49978.37 | Fixes 9264 words
:B0X*?C:tkae::f("take") ; Web Freq 490.25 | Fixes 105 words
:B0X*?C:tlaka::f("talka") ; Web Freq 0.30 | Fixes 14 words
:B0X*?C:tlakb::f("talkb") ; Web Freq 2.47 | Fixes 2 words
:B0X*?C:tlaki::f("talki") ; Web Freq 38.43 | Fixes 22 words
:B0X*?C:tlaks::f("talks") ; Web Freq 16.08 | Fixes 16 words
:B0X*?C:tlaky::f("talky") ; Web Freq 0.06 | Fixes 2 words
:B0X*?C:tlh::f("lth") ; Web Freq 638.11 | Fixes 102 words
:B0X*?C:tlme::f("tleme") ; Web Freq 30.38 | Fixes 27 words
:B0X*?C:tlye::f("tyle") ; Web Freq 168.46 | Fixes 111 words
:B0X*?C:tnad::f("tand") ; Web Freq 508.32 | Fixes 169 words
:B0X*?C:tned::f("nted") ; Web Freq 385.45 | Fixes 358 words
:B0X*?C:tofy::f("tify") ; Web Freq 92.06 | Fixes 91 words
:B0X*?C:tpio::f("ptio") ; Web Freq 748.60 | Fixes 245 words
:B0X*?C:trh::f("thr") ; Web Freq 1084.45 | Fixes 839 words, Case-sensitive for TRH pituitary hormone.
:B0X*?C:tuer::f("teur") ; Web Freq 51.45 | Fixes 69 words
:B0X*?C:twpo::f("two") ; Web Freq 803.58 | Fixes 153 words
:B0X*?C:tyha::f("tha") ; Web Freq 4228.19 | Fixes 716 words
:B0X*?C:tyhl::f("thl") ; Web Freq 113.82 | Fixes 152 words
:B0X*?C:tyhr::f("thr") ; Web Freq 1084.45 | Fixes 839 words
:B0X*?C:tyhs::f("ths") ; Web Freq 207.23 | Fixes 427 words
:B0X*?C:tyhu::f("thu") ; Web Freq 313.74 | Fixes 301 words
:B0X*?C:tyu::f("ty") ; Web Freq 5438.01 | Fixes 3842 words
:B0X*?C:ucj::f("uch") ; Web Freq 723.34 | Fixes 396 words
:B0X*?C:uckk::f("uck") ; Web Freq 399.43 | Fixes 627 words
:B0X*?C:ucnt::f("unct") ; Web Freq 254.36 | Fixes 218 words
:B0X*?C:ucxa::f("uca") ; Web Freq 631.72 | Fixes 176 words
:B0X*?C:ujh::f("uh") ; Web Freq 21.96 | Fixes 72 words
:B0X*?C:uoul::f("oul") ; Web Freq 1405.21 | Fixes 311 words
:B0X*?C:urgan::f("urgen") ; Web Freq 14.47 | Fixes 26 words, but misspells kurgan (Russian term for a prehistoric burial mound)
:B0X*?C:utyh::f("uth") ; Web Freq 1261.74 | Fixes 512 words
:B0X*?C:vegt::f("veget") ; Web Freq 31.22 | Fixes 38 words
:B0X*?C:veid::f("vied") ; Web Freq 1.93 | Fixes 21 words
:B0X*?C:veir::f("vier") ; Web Freq 18.28 | Fixes 48 words
:B0X*?C:veis::f("vies") ; Web Freq 194.69 | Fixes 58 words
:B0X*?C:veiw::f("view") ; Web Freq 1640.01 | Fixes 98 words
:B0X*?C:veyr::f("very") ; Web Freq 906.86 | Fixes 54 words
:B0X*?C:vinf::f("ving") ; Web Freq 678.49 | Fixes 354 words
:B0X*?C:viys::f("vies") ; Web Freq 194.69 | Fixes 58 words
:B0X*?C:vnat::f("vant") ; Web Freq 120.79 | Fixes 85 words
:B0X*?C:vrey::f("very") ; Web Freq 906.86 | Fixes 54 words
:B0X*?C:vyer::f("very") ; Web Freq 906.86 | Fixes 54 words
:B0X*?C:vyre::f("very") ; Web Freq 906.86 | Fixes 54 words
:B0X*?C:waer::f("wear") ; Web Freq 92.74 | Fixes 132 words
:B0X*?C:wahl::f("whal") ; Web Freq 10.79 | Fixes 25 words, but misspells Wahlberg (Marky Mark!)
:B0X*?C:wahm::f("wham") ; Web Freq 1.55 | Fixes 13 words
:B0X*?C:wahn::f("whan") ; Web Freq 0.60 | Fixes 14 words
:B0X*?C:wahr::f("whar") ; Web Freq 4.62 | Fixes 20 words
:B0X*?C:waht::f("what") ; Web Freq 872.18 | Fixes 45 words
:B0X*?C:waty::f("way") ; Web Freq 878.69 | Fixes 383 words
:B0X*?C:weee::f("wee") ; Web Freq 726.21 | Fixes 534 words
:B0X*?C:wehn::f("when") ; Web Freq 666.11 | Fixes 8 words
:B0X*?C:werr::f("wer") ; Web Freq 1489.91 | Fixes 576 words
:B0X*?C:whga::f("wha") ; Web Freq 892.61 | Fixes 158 words
:B0X*?C:whih::f("with") ; Web Freq 3703.67 | Fixes 82 words
:B0X*?C:whn::f("when") ; Web Freq 666.11 | Fixes 8 words
:B0X*?C:whta::f("what") ; Web Freq 872.18 | Fixes 45 words
:B0X*?C:wief::f("wife") ; Web Freq 52.04 | Fixes 39 words
:B0X*?C:wiew::f("view") ; Web Freq 1640.01 | Fixes 98 words
:B0X*?C:wihs::f("whis") ; Web Freq 24.07 | Fixes 61 words
:B0X*?C:wjh::f("wh") ; Web Freq 5472.13 | Fixes 1069 words
:B0X*?C:wnat::f("want") ; Web Freq 367.45 | Fixes 28 words
:B0X*?C:woh::f("who") ; Web Freq 1489.21 | Fixes 152 words
:B0X*?C:wokr::f("work") ; Web Freq 1328.63 | Fixes 504 words
:B0X*?C:wrod::f("word") ; Web Freq 558.57 | Fixes 127 words
:B0X*?C:wrok::f("work") ; Web Freq 1328.63 | Fixes 504 words
:B0X*?C:wtih::f("with") ; Web Freq 3703.67 | Fixes 82 words
:B0X*?C:wupp::f("supp") ; Web Freq 809.21 | Fixes 187 words
:B0X*?C:xomp::f("comp") ; Web Freq 2330.25 | Fixes 911 words, but misspells exomphalos (umbilical hernia at birth)
:B0X*?C:yaer::f("year") ; Web Freq 801.47 | Fixes 29 words
:B0X*?C:yht::f("yth") ; Web Freq 241.84 | Fixes 309 words
:B0X*?C:yinf::f("ying") ; Web Freq 490.38 | Fixes 791 words
:B0X*?C:yjh::f("yh") ; Web Freq 22.09 | Fixes 116 words
:B0X*?C:yokr::f("york") ; Web Freq 378.26 | Fixes 15 words
:B0X*?C:ythga::f("ytha") ; Web Freq 0.94 | Fixes 5 words
:B0X*?C:ytlak::f("ytalk") ; Web Freq 0.03 | Fixes 3 words
:B0X*?C:ytou::f("you") ; Web Freq 5508.06 | Fixes 79 words
:B0X*?C:ytri::f("tri") ; Web Freq 1842.05 | Fixes 3282 words, but misspells Chytridiales and Synchytrium (Simple parasitic fungi including pond scum parasites)
:B0X*?C:yui::f("yi") ; Web Freq 531.72 | Fixes 1072 words
:B0X*?C:yuo::f("you") ; Web Freq 5508.06 | Fixes 79 words
:B0X*?C:zao::f("zoa") ; Web Freq 2.45 | Fixes 94 words
:B0X*?C:zyne::f("zine") ; Web Freq 147.75 | Fixes 146 words
:B0X*?C:zyng::f("zing") ; Web Freq 116.24 | Fixes 1092 words
:B0X*?C:zzyn::f("zzin") ; Web Freq 2.60 | Fixes 36 words
:B0X*C:Philipi::f("Philippi") ; Web Freq 23.50 | Fixes 7 words
:B0X*C:aquit::f("acquit") ; Web Freq 1.08 | Fixes 10 words, Case-sensitive to not misspell Aquitaine (A region of southwestern France between Bordeaux and the Pyrenees)
:B0X*C:between I and::f("between me and") ; Fixes 1 word
:B0X*C:bnut::f("but") ; Web Freq 1163.15 | Fixes 195 words
:B0X*C:bve::f("be") ; Web Freq 9900.39 | Fixes 2436 words
:B0X*C:carmel::f("caramel") ; Web Freq 1.66 | Fixes 12 words, Case-sensitive to not misspell Carmelite (Roman Catholic friar)  
:B0X*C:coce::f("code") ; Web Freq 300.42 | Fixes 59 words
:B0X*C:ehr::f("her") ; Web Freq 1890.00 | Fixes 315 words, but misspells ehrlichiosis (A bacterial disease transmitted by ticks), Case sensitive to not misspell Ehrenberg (a Russian novelist) or Ehrlich (a German scientist)
:B0X*C:english::f("English") ; Web Freq 345.77 | Fixes 12 words
:B0X*C:exhc::f("exch") ; Web Freq 92.74 | Fixes 12 words Case-sensitive to not misspell acronyms.
:B0X*C:fwe::f("few") ; Web Freq 146.36 | Fixes 9 words Case-sensitive to not break 'Fwd'.
:B0X*C:ganes::f("games") ; Web Freq 315.06 | Fixes 13 words, Case-sensitive to protect Ganesh.
:B0X*C:hca::f("cha") ; Web Freq 1907.99 | Fixes 1054 words
:B0X*C:herat::f("heart") ; Web Freq 119.90 | Fixes 76 words, Case-sensitive to not misspell Herat (a city in Afganistan)
:B0X*C:hsi::f("his") ; Web Freq 990.71 | Fixes 136 words, Case-sensitive to not misspell Hsian (a city in China)
:B0X*C:i ::f("I ") ; Fixes 1 word
:B0X*C:ime::f("imme") ; Web Freq 70.87 | Fixes 49 words, Case-sensitive to not misspell IMEI (International Mobile Equipment Identity)
:B0X*C:lias::f("liais") ; Web Freq 6.27 | Fixes 6 words, Case-sensitive to not misspell Lias (One of the Jurrasic periods.)
:B0X*C:makb::f("mayb") ; Web Freq 52.45 | Fixes 8 words
:B0X*C:milis::f("millis") ; Web Freq 1.27 | Fixes 2 words
:B0X*C:nto::f("not") ; Web Freq 3298.07 | Fixes 146 words
:B0X*C:otu::f("out") ; Web Freq 1203.62 | Fixes 1505 words, case-sensitive to not misspell Otus (A genus of Strigidae, I.e. a bird)
:B0X*C:ragne::f("range") ; Web Freq 163.05 | Fixes 11 words
:B0X*C:thst::f("that") ; Web Freq 3403.27 | Fixes 20 words
:B0X*C:unter::f("under") ; Web Freq 591.65 | Fixes 771 words, Case-sensitive to protect Untermeyer (A famous writer)
:B0X*C:wich::f("which") ; Web Freq 813.75 | Fixes 3 words, Case-sensitive to not misspell Wichita (City in KA, USA)
:B0X*C:wsa::f("was") ; Web Freq 1706.93 | Fixes 143 words
:B0X*C:yoru::f("your") ; Web Freq 2136.38 | Fixes 5 words, Case sensitive to not misspell Yoruba (A Nigerian language)
:B0X*C?:carrer::f("career") ; Web Freq 118.68 | Fixes 11 words, Case-sensitive to not misspell Carrere (A famous architect)
:B0X*C?:daed::f("dead") ; Web Freq 75.62 | Fixes 63 words, Case-sensitive to not misspell Daedal ([Greek mythology] an Athenian inventor who built the labyrinth of Minos)
:B0X*C?:exx::f("ess") ; Web Freq 5121.43 | Fixes 12009 words
:B0X:Marine Core::f("Marine Corps") ; Fixes 1 word
:B0X:Parri::f("Patti") ; Fixes 1 word
:B0X:Rachal::f("Rachel") ; Web Freq 9.94 | Fixes 1 word
:B0X:Seartle::f("Seattle") ; Web Freq 34.43 | Fixes 1 word
:B0X:a dominate::f("a dominant") ; Fixes 1 word
:B0X:a knead for::f("a need for") ; Fixes 1 word
:B0X:a lose::f("a loss") ; Fixes 1 word
:B0X:a manufacture::f("a manufacturer") ; Fixes 1 word
:B0X:a only a::f("only a") ; Fixes 1 word
:B0X:a phenomena::f("a phenomenon") ; Fixes 1 word
:B0X:a protozoa::f("a protozoon") ; Fixes 1 word
:B0X:a renown::f("a renowned") ; Fixes 1 word
:B0X:a strata::f("a stratum") ; Fixes 1 word
:B0X:a taxa::f("a taxon") ; Fixes 1 word
:B0X:adres::f("address") ; Web Freq 261.87 | Fixes 1 word
:B0X:advocaty::f("advocacy") ; Web Freq 9.48 | Fixes 1 word
:B0X:affect on::f("effect on") ; Fixes 1 word
:B0X:affects of::f("effects of") ; Fixes 1 word
:B0X:agains::f("against") ; Web Freq 147.26 | Fixes 1 word
:B0X:against who::f("against whom") ; Fixes 1 word
:B0X:agre::f("agree") ; Web Freq 47.50 | Fixes 1 word
:B0X:ain`nt::f("ain't") ; Fixes 1 word
:B0X:air tight::f("airtight") ; Web Freq 0.41 | Fixes 1 word
:B0X:aircrafts::f("aircraft") ; Web Freq 24.75 | Fixes 1 word
:B0X:all for not::f("all for naught") ; Fixes 1 word
:B0X:all ready done::f("already done") ; Fixes 1 word
:B0X:all ready set::f("already set") ; Fixes 1 word
:B0X:all together::f("altogether") ; Web Freq 4.07 | Fixes 1 word
:B0X:allo::f("also") ; Web Freq 616.83 | Fixes 1 word
:B0X:alot::f("a lot") ; Fixes 1 word
:B0X:aloud out::f("allowed out") ; Fixes 1 word
:B0X:aloud to go::f("allowed to go") ; Fixes 1 word
:B0X:alraedy::f("already") ; Web Freq 108.32 | Fixes 1 word
:B0X:also know as::f("also known as") ; Fixes 1 word
:B0X:also know by::f("also known by") ; Fixes 1 word
:B0X:also know for::f("also known for") ; Fixes 1 word
:B0X:altar ego::f("alter ego") ; Fixes 1 word
:B0X:alway::f("always") ; Web Freq 127.63 | Fixes 1 word
:B0X:always their::f("always there") ; Fixes 1 word
:B0X:always they're::f("always there") ; Fixes 1 word
:B0X:an affect::f("an effect") ; Fixes 1 word
:B0X:ancestory::f("ancestry") ; Web Freq 3.73 | Fixes 1 word
:B0X:anchors away::f("anchors aweigh") ; Fixes 1 word
:B0X:andt he::f("and the") ; Fixes 1 word
:B0X:anothe::f("another") ; Web Freq 192.54 | Fixes 1 word
:B0X:another criteria::f("another criterion") ; Fixes 1 word
:B0X:another words::f("in other words") ; Fixes 1 word
:B0X:any more::f("anymore") ; Web Freq 10.49 | Fixes 1 word
:B0X:apiil::f("april") ; Web Freq 149.98 | Fixes 1 word
:B0X:apon::f("upon") ; Web Freq 103.92 | Fixes 1 word
:B0X:are ass::f("are as") ; Fixes 1 word
:B0X:are dominate::f("are dominant") ; Fixes 1 word
:B0X:are meet::f("are met") ; Fixes 1 word
:B0X:are renown::f("are renowned") ; Fixes 1 word
:B0X:aren`nt::f("aren't") ; Fixes 1 word
:B0X:arms length::f("arm's length") ; Fixes 1 word
:B0X:askt he::f("ask the") ; Fixes 1 word
:B0X:aslo::f("also") ; Web Freq 616.83 | Fixes 1 word
:B0X:asside::f("aside") ; Web Freq 11.77 | Fixes 1 word
:B0X:atmosphear::f("atmosphere") ; Web Freq 14.80 | Fixes 1 word
:B0X:atmospher::f("atmosphere") ; Web Freq 14.80 | Fixes 1 word
:B0X:averag::f("average") ; Web Freq 102.84 | Fixes 1 word
:B0X:averr::f("after") ; Web Freq 372.95 | Fixes 1 word
:B0X:bare in mind::f("bear in mind") ; Fixes 1 word
:B0X:bare with me::f("bear with me") ; Fixes 1 word
:B0X:bare witness::f("bear witness") ; Fixes 1 word
:B0X:be ran::f("be run") ; Fixes 1 word
:B0X:be rode::f("be ridden") ; Fixes 1 word
:B0X:be send::f("be sent") ; Fixes 1 word
:B0X:became know::f("became known") ; Fixes 1 word
:B0X:becames::f("became") ; Web Freq 37.33 | Fixes 1 word
:B0X:becaus::f("because") ; Web Freq 271.32 | Fixes 1 word
:B0X:beckon call::f("beck and call") ; Fixes 1 word
:B0X:been hear::f("been here") ; Fixes 1 word
:B0X:been know::f("been known") ; Fixes 1 word
:B0X:been ran::f("been run") ; Fixes 1 word
:B0X:been rode::f("been ridden") ; Fixes 1 word
:B0X:been send::f("been sent") ; Fixes 1 word
:B0X:beggin::f("begin") ; Web Freq 90.87 | Fixes 2 words
:B0X:being ran::f("being run") ; Fixes 1 word
:B0X:being rode::f("being ridden") ; Fixes 1 word
:B0X:beleve::f("belive") ; Web Freq 0.57 | Fixes 1 word
:B0X:belevve::f("believe") ; Web Freq 75.92 | Fixes 1 word
:B0X:bicep::f("biceps") ; Web Freq 0.36 | Fixes 1 word
:B0X:bite code::f("byte code") ; Fixes 1 word
:B0X:boildrplate::f("boilerplate") ; Web Freq 0.24 | Fixes 1 word
:B0X:born fruit::f("borne fruit") ; Fixes 1 word
:B0X:both of who::f("both of whom") ; Fixes 1 word
:B0X:brake free::f("break free") ; Fixes 1 word
:B0X:brake loose::f("break loose") ; Fixes 1 word
:B0X:broacasted::f("broadcast") ; Web Freq 18.74 | Fixes 1 word
:B0X:butause::f("because") ; Web Freq 271.32 | Fixes 1 word
:B0X:butthe::f("but the") ; Fixes 1 word
:B0X:ca nyou::f("can you") ; Fixes 1 word
:B0X:calle::f("calls") ; Web Freq 43.66 | Fixes 1 word
:B0X:can breath::f("can breathe") ; Fixes 1 word
:B0X:can't breath::f("can't breathe") ; Fixes 1 word
:B0X:can't of::f("can't have") ; Fixes 1 word
:B0X:can`nt::f("can't") ; Fixes 1 word
:B0X:cant afford::f("can't afford") ; Fixes 1 word
:B0X:cant attend::f("can't attend") ; Fixes 1 word
:B0X:cant be::f("can't be") ; Fixes 1 word
:B0X:cant believe::f("can't believe") ; Fixes 1 word
:B0X:cant do::f("can't do") ; Fixes 1 word
:B0X:cant even::f("can't even") ; Fixes 1 word
:B0X:cant find::f("can't find") ; Fixes 1 word
:B0X:cant get::f("can't get") ; Fixes 1 word
:B0X:cant go::f("can't go") ; Fixes 1 word
:B0X:cant have::f("can't have") ; Fixes 1 word
:B0X:cant help::f("can't help") ; Fixes 1 word
:B0X:cant make::f("can't make") ; Fixes 1 word
:B0X:cant remember::f("can't remember") ; Fixes 1 word
:B0X:cant say::f("can't say") ; Fixes 1 word
:B0X:cant schedule::f("can't schedule") ; Fixes 1 word
:B0X:cant see::f("can't see") ; Fixes 1 word
:B0X:cant send::f("can't send") ; Fixes 1 word
:B0X:cant stop::f("can't stop") ; Fixes 1 word
:B0X:cant take::f("can't take") ; Fixes 1 word
:B0X:cant tell::f("can't tell") ; Fixes 1 word
:B0X:cant test::f("can't test") ; Fixes 1 word
:B0X:cant think::f("can't think") ; Fixes 1 word
:B0X:cant wait::f("can't wait") ; Fixes 1 word
:B0X:carcas::f("carcass") ; Web Freq 0.81 | Fixes 1 word
:B0X:cash memory::f("cache memory") ; Fixes 1 word
:B0X:caught site of::f("caught sight of") ; Fixes 1 word
:B0X:certain extend::f("certain extent") ; Fixes 1 word
:B0X:cite license::f("site license") ; Fixes 1 word
:B0X:cite maintenance::f("site maintenance") ; Fixes 1 word
:B0X:cite reliability::f("site reliability") ; Fixes 1 word
:B0X:cite security::f("site security") ; Fixes 1 word
:B0X:cliant::f("client") ; Web Freq 69.19 | Fixes 1 word
:B0X:clrea::f("clear") ; Web Freq 88.45 | Fixes 1 word
:B0X:cluude::f("claude") ; Web Freq 4.23 | Fixes 1 word
:B0X:colling::f("calling") ; Web Freq 29.92 | Fixes 1 word
:B0X:colonel mode::f("kernel mode") ; Fixes 1 word
:B0X:colonel space::f("kernel space") ; Fixes 1 word
:B0X:colum::f("column") ; Web Freq 35.99 | Fixes 1 word
:B0X:comething::f("something") ; Web Freq 131.84 | Fixes 1 word
:B0X:complement your work::f("compliment your work") ; Fixes 1 word
:B0X:confids::f("confides") ; Web Freq 0.07 | Fixes 1 word
:B0X:consistenty::f("consistency") ; Web Freq 6.30 | Fixes 1 word
:B0X:controvery::f("controversy") ; Web Freq 5.16 | Fixes 1 word
:B0X:could breath::f("could breathe") ; Fixes 1 word
:B0X:could of::f("could have") ; Fixes 1 word
:B0X:couldn't breath::f("couldn't breathe") ; Fixes 1 word
:B0X:couldn`nt::f("couldn't") ; Fixes 1 word
:B0X:couls::f("could") ; Web Freq 302.31 | Fixes 1 word
:B0X:criterias::f("criteria") ; Web Freq 32.30 | Fixes 1 word
:B0X:daily regiment::f("daily regimen") ; Fixes 1 word
:B0X:daren`nt::f("daren't") ; Fixes 1 word
:B0X:day or the week::f("day of the week", 0) ; Fixes 1 word 
:B0X:days or the::f("days of the", 0) ; Fixes 1 word 
:B0X:deep seeded::f("deep seated") ; Fixes 1 word
:B0X:depending of::f("depending on") ; Fixes 1 word
:B0X:depends of::f("depends on") ; Fixes 1 word
:B0X:deside::f("decide") ; Web Freq 20.95 | Fixes 1 word
:B0X:despite of::f("despite") ; Web Freq 28.15 | Fixes 1 word
:B0X:devels::f("delves") ; Web Freq 0.26 | Fixes 1 word
:B0X:diamons::f("diamonds") ; Web Freq 10.37 | Fixes 1 word
:B0X:didn`nt::f("didn't") ; Fixes 1 word
:B0X:different to::f("different from") ; Fixes 1 word
:B0X:discontentment::f("discontent") ; Web Freq 0.70 | Fixes 1 word
:B0X:discreet data::f("discrete data") ; Fixes 1 word
:B0X:discreet observation::f("discrete observation") ; Fixes 1 word
:B0X:discreet trial::f("discrete trial") ; Fixes 1 word
:B0X:discrete steps::f("discreet steps") ; Fixes 1 word
:B0X:disent::f("dissent") ; Web Freq 2.07 | Fixes 1 word
:B0X:dispell::f("dispel") ; Web Freq 0.48 | Fixes 1 word
:B0X:dispells::f("dispels") ; Web Freq 0.11 | Fixes 1 word
:B0X:do to circumstances::f("due to circumstances") ; Fixes 1 word
:B0X:doesn`nt::f("doesn't") ; Fixes 1 word
:B0X:dolka::f("folks") ; Web Freq 13.76 | Fixes 1 word
:B0X:don`nt::f("don't") ; Fixes 1 word
:B0X:doub::f("doubt") ; Web Freq 20.31 | Fixes 1 word
:B0X:draf::f("drag") ; Web Freq 9.15 | Fixes 1 word
:B0X:drafty of::f("draft of") ; Fixes 1 word
:B0X:due two circumstances::f("due to circumstances") ; Fixes 1 word
:B0X:dum::f("dumb") ; Web Freq 5.41 | Fixes 1 word
:B0X:earlies::f("earliest") ; Web Freq 5.12 | Fixes 1 word
:B0X:earnt::f("earned") ; Web Freq 12.54 | Fixes 1 word
:B0X:eash::f("each") ; Web Freq 340.89 | Fixes 1 word
:B0X:eath::f("each") ; Web Freq 340.89 | Fixes 1 word
:B0X:elast::f("least") ; Web Freq 111.23 | Fixes 1 word
:B0X:eles::f("eels") ; Web Freq 0.73 | Fixes 1 word
:B0X:embarras::f("embarrass") ; Web Freq 0.42 | Fixes 1 word
:B0X:en mass::f("en masse") ; Fixes 1 word
:B0X:entrie::f("entire") ; Web Freq 56.28 | Fixes 1 word
:B0X:essag::f("essay") ; Web Freq 11.75 | Fixes 1 word
:B0X:essat::f("essay") ; Web Freq 11.75 | Fixes 1 word
:B0X:excell::f("excel") ; Web Freq 14.13 | Fixes 1 word
:B0X:experienc::f("experience") ; Web Freq 137.13 | Fixes 1 word
:B0X:extremly::f("extremely") ; Web Freq 24.10 | Fixes 1 word
:B0X:facia::f("fascia") ; Web Freq 0.71 | Fixes 1 word, but Americanizes British facia (Part of a building)
:B0X:failly::f("fairly") ; Web Freq 14.15 | Fixes 1 word
:B0X:fair well::f("fare well") ; Fixes 1 word
:B0X:faired well::f("fared well") ; Fixes 1 word
:B0X:fare enough::f("fair enough") ; Fixes 1 word
:B0X:fiercly::f("fiercely") ; Web Freq 0.75 | Fixes 1 word
:B0X:file.s::f("files.") ; Fixes 1 word
:B0X:firey::f("fiery") ; Web Freq 1.84 | Fixes 1 word
:B0X:flare for drama::f("flair for drama") ; Fixes 1 word
:B0X:folss::f("folks") ; Web Freq 13.76 | Fixes 1 word
:B0X:for all intensive purposes::f("for all intents and purposes") ; Fixes 1 word
:B0X:for he and::f("for him and") ; Fixes 1 word
:B0X:fora::f("for a") ; Fixes 1 word, but misspells fora (Uncommon for forum)
:B0X:forbad::f("forbade") ; Web Freq 0.25 | Fixes 1 word, but misspells forbad (Officially refuse)
:B0X:fore get about it::f("forget about it") ; Fixes 1 word
:B0X:formelly::f("formerly") ; Web Freq 10.18 | Fixes 1 word
:B0X:forsaw::f("foresaw") ; Web Freq 0.18 | Fixes 1 word
:B0X:fortell::f("foretell") ; Web Freq 0.10 | Fixes 1 word
:B0X:forthe::f("for the") ; Fixes 1 word
:B0X:four get about it::f("forget about it") ; Fixes 1 word
:B0X:fourth coming::f("forthcoming") ; Web Freq 5.01 | Fixes 1 word
:B0X:fourth with::f("forth with") ; Fixes 1 word
:B0X:fro::f("for") ; Web Freq 5933.32 | Fixes 1 word, but misspells to and fro (back and forth)
:B0X:frome::f("from") ; Web Freq 2275.60 | Fixes 1 word, but misspells Frome (English surname)
:B0X:fulfil::f("fulfill") ; Web Freq 4.69 | Fixes 1 word
:B0X:funguses::f("fungi") ; Web Freq 4.00 | Fixes 2 words
:B0X:gae::f("game") ; Web Freq 227.11 | Fixes 1 word
:B0X:galations::f("Galatians") ; Web Freq 1.25 | Fixes 1 word
:B0X:grading principal::f("grading principle") ; Fixes 1 word
:B0X:grat::f("great") ; Web Freq 301.49 | Fixes 1 word
:B0X:grin and bare it::f("grin and bear it") ; Fixes 1 word
:B0X:grizzly details::f("grisly details") ; Fixes 1 word
:B0X:guiding principal::f("guiding principle") ; Fixes 1 word
:B0X:gusy::f("guys") ; Web Freq 75.21 | Fixes 2 words
:B0X:had awoke::f("had awoken") ; Fixes 1 word
:B0X:had broke::f("had broken") ; Fixes 1 word
:B0X:had chose::f("had chosen") ; Fixes 1 word
:B0X:had did::f("had done") ; Fixes 1 word
:B0X:had fell::f("had fallen") ; Fixes 1 word
:B0X:had forbade::f("had forbidden") ; Fixes 1 word
:B0X:had know::f("had known") ; Fixes 1 word
:B0X:had meet::f("had met") ; Fixes 1 word
:B0X:had plead::f("had pleaded") ; Fixes 1 word
:B0X:had ran::f("had run") ; Fixes 1 word
:B0X:had rang::f("had rung") ; Fixes 1 word
:B0X:had rode::f("had ridden") ; Fixes 1 word
:B0X:had spoke::f("had spoken") ; Fixes 1 word
:B0X:had swam::f("had swum") ; Fixes 1 word
:B0X:had throve::f("had thriven") ; Fixes 1 word
:B0X:had woke::f("had woken") ; Fixes 1 word
:B0X:hadn`nt::f("hadn't") ; Fixes 1 word
:B0X:haiing::f("having") ; Web Freq 109.36 | Fixes 1 word
:B0X:happe::f("happy") ; Web Freq 63.47 | Fixes 1 word
:B0X:happend::f("happened") ; Web Freq 24.95 | Fixes 1 word
:B0X:happended::f("happened") ; Web Freq 24.95 | Fixes 1 word
:B0X:happenned::f("happened") ; Web Freq 24.95 | Fixes 1 word
:B0X:has arose::f("has arisen") ; Fixes 1 word
:B0X:has awoke::f("has awoken") ; Fixes 1 word
:B0X:has bore::f("has borne") ; Fixes 1 word
:B0X:has broke::f("has broken") ; Fixes 1 word
:B0X:has build::f("has built") ; Fixes 1 word
:B0X:has chose::f("has chosen") ; Fixes 1 word
:B0X:has drove::f("has driven") ; Fixes 1 word
:B0X:has fell::f("has fallen") ; Fixes 1 word
:B0X:has flew::f("has flown") ; Fixes 1 word
:B0X:has forbade::f("has forbidden") ; Fixes 1 word
:B0X:has meet::f("has met") ; Fixes 1 word
:B0X:has plead::f("has pleaded") ; Fixes 1 word
:B0X:has ran::f("has run") ; Fixes 1 word
:B0X:has spoke::f("has spoken") ; Fixes 1 word
:B0X:has swam::f("has swum") ; Fixes 1 word
:B0X:has trod::f("has trodden") ; Fixes 1 word
:B0X:has woke::f("has woken") ; Fixes 1 word
:B0X:hase::f("have") ; Web Freq 1564.20 | Fixes 1 word
:B0X:hasn`nt::f("hasn't") ; Fixes 1 word
:B0X:havd::f("hard") ; Web Freq 130.05 | Fixes 1 word
:B0X:have ran::f("have run") ; Fixes 1 word
:B0X:have rang::f("have rung") ; Fixes 1 word
:B0X:have swam::f("have swum") ; Fixes 1 word
:B0X:haven`nt::f("haven't") ; Fixes 1 word
:B0X:having ran::f("having run") ; Fixes 1 word
:B0X:having swam::f("having swum") ; Fixes 1 word
:B0X:he plead::f("he pleaded") ; Fixes 1 word
:B0X:hear and now::f("here and now") ; Fixes 1 word
:B0X:here to after::f("hereafter") ; Web Freq 1.72 | Fixes 1 word
:B0X:here to fore::f("heretofore") ; Web Freq 0.54 | Fixes 1 word
:B0X:herselv::f("herself") ; Web Freq 13.48 | Fixes 1 word
:B0X:herselve::f("herself") ; Web Freq 13.48 | Fixes 1 word
:B0X:hier::f("heir") ; Web Freq 1.35 | Fixes 1 word
:B0X:hierarcy::f("hierarchy") ; Web Freq 6.38 | Fixes 1 word
:B0X:high site::f("hindsight") ; Web Freq 0.72 | Fixes 1 word
:B0X:higher ups::f("higher-ups") ; Fixes 1 word
:B0X:himselv::f("himself") ; Web Freq 39.76 | Fixes 1 word
:B0X:himselve::f("himself") ; Web Freq 39.76 | Fixes 1 word
:B0X:hind site::f("hindsight") ; Web Freq 0.72 | Fixes 1 word
:B0X:hire learning::f("higher learning") ; Fixes 1 word
:B0X:hire order::f("higher order") ; Fixes 1 word
:B0X:hole approach::f("whole approach") ; Fixes 1 word
:B0X:hole life balance::f("whole life balance") ; Fixes 1 word
:B0X:hole person::f("whole person") ; Fixes 1 word
:B0X:holy different::f("wholly different") ; Fixes 1 word
:B0X:holy inappropriate::f("wholly inappropriate") ; Fixes 1 word
:B0X:holy owned::f("wholly owned") ; Fixes 1 word
:B0X:holy responsible::f("wholly responsible") ; Fixes 1 word
:B0X:hone in::f("home in") ; Fixes 1 word
:B0X:how ever::f("however") ; Web Freq 163.96 | Fixes 1 word
:B0X:howver::f("however") ; Web Freq 163.96 | Fixes 1 word
:B0X:humer::f("humor") ; Web Freq 18.09 | Fixes 1 word
:B0X:husban::f("husband") ; Web Freq 23.06 | Fixes 1 word
:B0X:hypocrit::f("hypocrite") ; Web Freq 0.41 | Fixes 1 word
:B0X:ib tge::f("on the") ; Fixes 1 word
:B0X:idol hands::f("idle hands") ; Fixes 1 word
:B0X:idol time::f("idle time") ; Fixes 1 word
:B0X:if is::f("it is") ; Fixes 1 word
:B0X:if was::f("it was") ; Fixes 1 word
:B0X:imagin::f("imagine") ; Web Freq 17.36 | Fixes 1 word
:B0X:imput::f("input") ; Web Freq 57.19 | Fixes 1 word
:B0X:in principal::f("in principle") ; Fixes 1 word
:B0X:in site::f("insight") ; Web Freq 14.07 | Fixes 1 word
:B0X:in the mist of::f("in the midst of") ; Fixes 1 word
:B0X:in too days::f("in two days") ; Fixes 1 word
:B0X:indded::f("indeed") ; Web Freq 26.94 | Fixes 1 word
:B0X:inot::f("into") ; Web Freq 445.32 | Fixes 1 word
:B0X:instrad::f("instead") ; Web Freq 56.50 | Fixes 1 word
:B0X:interbread::f("interbred") ; Web Freq 0.01 | Fixes 1 word
:B0X:intered::f("interred") ; Web Freq 0.24 | Fixes 1 word
:B0X:interm::f("interim") ; Web Freq 9.42 | Fixes 1 word
:B0X:internation::f("international") ; Web Freq 591.28 | Fixes 2 words
:B0X:intervention aid::f("intervention aide") ; Fixes 1 word
:B0X:inthe::f("in the") ; Fixes 1 word
:B0X:is also know::f("is also known") ; Fixes 1 word
:B0X:is consider::f("is considered") ; Fixes 1 word
:B0X:is know::f("is known") ; Fixes 1 word
:B0X:isn`nt::f("isn't") ; Fixes 1 word
:B0X:it self::f("itself") ; Web Freq 51.08 | Fixes 1 word
:B0X:itesm::f("items") ; Web Freq 330.51 | Fixes 1 word
:B0X:its a::f("it's a") ; Fixes 1 word
:B0X:its about time::f("it's about time") ; Fixes 1 word
:B0X:its also::f("it's also") ; Fixes 1 word
:B0X:japanes::f("Japanese") ; Web Freq 52.32 | Fixes 1 word
:B0X:juet::f("just") ; Web Freq 462.84 | Fixes 1 word
:B0X:just plane wrong::f("just plain wrong") ; Fixes 1 word
:B0X:kernal mode::f("kernel mode") ; Fixes 1 word
:B0X:kernal panic::f("kernel panic") ; Fixes 1 word
:B0X:kernal space::f("kernel space") ; Fixes 1 word
:B0X:kernal update::f("kernel update") ; Fixes 1 word
:B0X:knight light::f("night light") ; Fixes 1 word
:B0X:knot likely::f("not likely") ; Fixes 1 word
:B0X:knot sure::f("not sure") ; Fixes 1 word
:B0X:know problem::f("no problem") ; Fixes 1 word
:B0X:know way::f("no way") ; Fixes 1 word
:B0X:lagge::f("large") ; Web Freq 165.86 | Fixes 1 word
:B0X:larg::f("large") ; Web Freq 165.86 | Fixes 1 word
:B0X:lasest::f("latest") ; Web Freq 131.95 | Fixes 1 word
:B0X:last rights::f("last rites") ; Fixes 1 word
:B0X:least wise::f("leastwise") ; Fixes 1 word
:B0X:lef::f("let") ; Web Freq 286.12 | Fixes 2 words
:B0X:lefted::f("left") ; Web Freq 171.75 | Fixes 1 word
:B0X:lessen learned::f("lesson learned") ; Fixes 1 word
:B0X:lessen up::f("lesson up") ; Fixes 1 word
:B0X:let's him::f("lets him") ; Fixes 1 word
:B0X:let's it::f("lets it") ; Fixes 1 word
:B0X:limieed::f("limited") ; Web Freq 106.15 | Fixes 1 word
:B0X:lincon::f("lincoln") ; Web Freq 21.01 | Fixes 1 word
:B0X:lise::f("like") ; Web Freq 520.59 | Fixes 1 word
:B0X:loan figure::f("lone figure") ; Fixes 1 word
:B0X:loan star::f("lone star") ; Fixes 1 word
:B0X:loan survivor::f("lone survivor") ; Fixes 1 word
:B0X:loan traveler::f("lone traveler") ; Fixes 1 word
:B0X:loan voice::f("lone voice") ; Fixes 1 word
:B0X:loan wolf::f("lone wolf") ; Fixes 1 word
:B0X:lot's of::f("lots of") ; Fixes 1 word
:B0X:lsot::f("lost") ; Web Freq 74.75 | Fixes 1 word
:B0X:made it plane::f("made it plain") ; Fixes 1 word
:B0X:maid a breakthrough::f("made a breakthrough") ; Fixes 1 word
:B0X:maid a comeback::f("made a comeback") ; Fixes 1 word
:B0X:maid a deal::f("made a deal") ; Fixes 1 word
:B0X:maid a decision::f("made a decision") ; Fixes 1 word
:B0X:maid a difference::f("made a difference") ; Fixes 1 word
:B0X:maid a discovery::f("made a discovery") ; Fixes 1 word
:B0X:maid a fortune::f("made a fortune") ; Fixes 1 word
:B0X:maid a fuss::f("made a fuss") ; Fixes 1 word
:B0X:maid a mess::f("made a mess") ; Fixes 1 word
:B0X:maid a mistake::f("made a mistake") ; Fixes 1 word
:B0X:maid a point::f("made a point") ; Fixes 1 word
:B0X:maid a promise::f("made a promise") ; Fixes 1 word
:B0X:maid a scene::f("made a scene") ; Fixes 1 word
:B0X:maid a splash::f("made a splash") ; Fixes 1 word
:B0X:maid a statement::f("made a statement") ; Fixes 1 word
:B0X:maid amends::f("made amends") ; Fixes 1 word
:B0X:maid an entrance::f("made an entrance") ; Fixes 1 word
:B0X:maid an impression::f("made an impression") ; Fixes 1 word
:B0X:maid arrangements::f("made arrangements") ; Fixes 1 word
:B0X:maid enemies::f("made enemies") ; Fixes 1 word
:B0X:maid excuses::f("made excuses") ; Fixes 1 word
:B0X:maid friends::f("made friends") ; Fixes 1 word
:B0X:maid headlines::f("made headlines") ; Fixes 1 word
:B0X:maid history::f("made history") ; Fixes 1 word
:B0X:maid it big::f("made it big") ; Fixes 1 word
:B0X:maid it clear::f("made it clear") ; Fixes 1 word
:B0X:maid it count::f("made it count") ; Fixes 1 word
:B0X:maid it happen::f("made it happen") ; Fixes 1 word
:B0X:maid it official::f("made it official") ; Fixes 1 word
:B0X:maid it possible::f("made it possible") ; Fixes 1 word
:B0X:maid it through::f("made it through") ; Fixes 1 word
:B0X:maid it work::f("made it work") ; Fixes 1 word
:B0X:maid money::f("made money") ; Fixes 1 word
:B0X:maid my day::f("made my day") ; Fixes 1 word
:B0X:maid peace::f("made peace") ; Fixes 1 word
:B0X:maid plans::f("made plans") ; Fixes 1 word
:B0X:maid progress::f("made progress") ; Fixes 1 word
:B0X:maid room::f("made room") ; Fixes 1 word
:B0X:maid sense::f("made sense") ; Fixes 1 word
:B0X:maid small talk::f("made small talk") ; Fixes 1 word
:B0X:maid the best::f("made the best") ; Fixes 1 word
:B0X:maid the call::f("made the call") ; Fixes 1 word
:B0X:maid the cut::f("made the cut") ; Fixes 1 word
:B0X:maid the deadline::f("made the deadline") ; Fixes 1 word
:B0X:maid the difference::f("made the difference") ; Fixes 1 word
:B0X:maid the effort::f("made the effort") ; Fixes 1 word
:B0X:maid the grade::f("made the grade") ; Fixes 1 word
:B0X:maid the news::f("made the news") ; Fixes 1 word
:B0X:maid the payment::f("made the payment") ; Fixes 1 word
:B0X:maid the point::f("made the point") ; Fixes 1 word
:B0X:maid the rounds::f("made the rounds") ; Fixes 1 word
:B0X:maid the rules::f("made the rules") ; Fixes 1 word
:B0X:maid the team::f("made the team") ; Fixes 1 word
:B0X:maid time::f("made time") ; Fixes 1 word
:B0X:maid to order::f("made to order") ; Fixes 1 word
:B0X:maid up story::f("made up story") ; Fixes 1 word
:B0X:maid waves::f("made waves") ; Fixes 1 word
:B0X:maltesian::f("Maltese") ; Web Freq 1.83 | Fixes 1 word
:B0X:manner born::f("manor born") ; Fixes 1 word
:B0X:manu::f("menu") ; Web Freq 74.36 | Fixes 1 word
:B0X:may semm::f("may seem") ; Fixes 1 word
:B0X:maye::f("make") ; Web Freq 405.08 | Fixes 1 word
:B0X:mayelf::f("myself") ; Web Freq 37.98 | Fixes 1 word
:B0X:mear::f("mere") ; Web Freq 7.31 | Fixes 1 word
:B0X:melieux::f("milieux") ; Web Freq 0.05 | Fixes 1 word . Milieux (A person or group's social or cultural environment)
:B0X:memory cash::f("memory cache") ; Fixes 1 word
:B0X:memory leek::f("memory leak") ; Fixes 1 word
:B0X:might of::f("might have") ; Fixes 1 word
:B0X:mightn`nt::f("mightn't") ; Fixes 1 word
:B0X:monor::f("minor") ; Web Freq 29.78 | Fixes 1 word
:B0X:more resent::f("more recent") ; Fixes 1 word
:B0X:most resent::f("most recent") ; Fixes 1 word
:B0X:mourning glory::f("morning glory") ; Fixes 1 word
:B0X:munu::f("menu") ; Web Freq 74.36 | Fixes 1 word
:B0X:must exact revenge::f("must extract revenge") ; Fixes 1 word
:B0X:must of::f("must have") ; Fixes 1 word
:B0X:mustn`nt::f("mustn't") ; Fixes 1 word
:B0X:mysef::f("myself") ; Web Freq 37.98 | Fixes 1 word
:B0X:mysefl::f("myself") ; Web Freq 37.98 | Fixes 1 word
:B0X:needn`nt::f("needn't") ; Fixes 1 word
:B0X:neither criteria::f("neither criterion") ; Fixes 1 word
:B0X:neither phenomena::f("neither phenomenon") ; Fixes 1 word
:B0X:nest one::f("next one") ; Fixes 1 word
:B0X:nestin::f("nesting") ; Web Freq 2.16 | Fixes 1 word
:B0X:noone::f("no one") ; Fixes 1 word 
:B0X:nose no bounds::f("knows no bounds") ; Fixes 1 word
:B0X:occurence::f("occurrence") ; Web Freq 5.56 | Fixes 1 word
:B0X:occurences::f("occurrences") ; Web Freq 1.91 | Fixes 1 word
:B0X:of been::f("have been") ; Fixes 1 word
:B0X:of had::f("have had") ; Fixes 1 word
:B0X:oftenly::f("often") ; Web Freq 92.55 | Fixes 1 word
:B0X:onc::f("one") ; Web Freq 993.54 | Fixes 1 word
:B0X:one criteria::f("one criterion") ; Fixes 1 word
:B0X:one in the same::f("one and the same") ; Fixes 1 word
:B0X:one phenomena::f("one phenomenon") ; Fixes 1 word
:B0X:onee::f("once") ; Web Freq 111.88 | Fixes 1 word
:B0X:onthe::f("on the") ; Fixes 1 word
:B0X:opposit::f("opposite") ; Web Freq 11.97 | Fixes 1 word
:B0X:ot the::f("of the") ; Fixes 1 word
:B0X:oughtn`nt::f("oughtn't") ; Fixes 1 word
:B0X:our of::f("out of") ; Fixes 1 word
:B0X:overthe::f("over the") ; Fixes 1 word
:B0X:pail in comparison::f("pale in comparison") ; Fixes 1 word
:B0X:passerbys::f("passersby") ; Web Freq 0.12 | Fixes 1 word
:B0X:past the test::f("passed the test") ; Fixes 1 word
:B0X:pastss::f("pastes") ; Web Freq 0.26 | Fixes 1 word
:B0X:pawn off::f("palm off") ; Fixes 1 word
:B0X:payed::f("paid") ; Web Freq 60.29 | Fixes 1 word
:B0X:peace by peace::f("piece by piece") ; Fixes 1 word
:B0X:peak my interest::f("pique my interest") ; Fixes 1 word
:B0X:pears programming::f("pairs programming") ; Fixes 1 word
:B0X:peek my interest::f("pique my interest") ; Fixes 1 word
:B0X:peek season::f("peak season") ; Fixes 1 word
:B0X:per cent::f("percent") ; Web Freq 94.04 | Fixes 1 word
:B0X:per say::f("per se") ; Fixes 1 word
:B0X:perhasp::f("perhaps") ; Web Freq 42.45 | Fixes 1 word
:B0X:perphas::f("perhaps") ; Web Freq 42.45 | Fixes 1 word
:B0X:personel::f("personnel") ; Web Freq 33.28 | Fixes 1 word
:B0X:piece of mind::f("peace of mind") ; Fixes 1 word
:B0X:plane and simple::f("plain and simple") ; Fixes 1 word
:B0X:plas::f("plus") ; Web Freq 94.73 | Fixes 1 word
:B0X:poisin::f("poison") ; Web Freq 5.06 | Fixes 1 word
:B0X:poor over::f("pore over") ; Fixes 1 word
:B0X:pore planning::f("poor planning") ; Fixes 1 word
:B0X:pore reception::f("poor reception") ; Fixes 1 word
:B0X:pore results::f("poor results") ; Fixes 1 word
:B0X:pore start::f("poor start") ; Fixes 1 word
:B0X:pore timing::f("poor timing") ; Fixes 1 word
:B0X:portugues::f("Portuguese") ; Web Freq 11.16 | Fixes 1 word
:B0X:potatoe::f("potato") ; Web Freq 6.40 | Fixes 1 word
:B0X:pour company::f("poor company") ; Fixes 1 word
:B0X:pour performance::f("poor performance") ; Fixes 1 word
:B0X:pour quality::f("poor quality") ; Fixes 1 word
:B0X:pour reception::f("poor reception") ; Fixes 1 word
:B0X:pour showing::f("poor showing") ; Fixes 1 word
:B0X:pour timing::f("poor timing") ; Fixes 1 word
:B0X:powerfull::f("powerful") ; Web Freq 33.54 | Fixes 1 word
:B0X:presely::f("presley") ; Web Freq 4.09 | Fixes 1 word
:B0X:pressy::f("pretty") ; Web Freq 51.62 | Fixes 1 word
:B0X:principle believes::f("principal believes") ; Fixes 1 word
:B0X:principle leadership::f("principal leadership") ; Fixes 1 word
:B0X:proaably::f("probably") ; Web Freq 61.63 | Fixes 1 word
:B0X:protem::f("pro tem") ; Fixes 1 word
:B0X:publically::f("publicly") ; Web Freq 8.17 | Fixes 1 word
:B0X:quitted::f("quit") ; Web Freq 10.32 | Fixes 1 word
:B0X:rain supreme::f("reign supreme") ; Fixes 1 word
:B0X:rap up::f("wrap up") ; Fixes 1 word
:B0X:rapped up::f("wrapped up") ; Fixes 1 word
:B0X:readly::f("really") ; Web Freq 162.03 | Fixes 1 word ; will it break "ready"?
:B0X:recal::f("recall") ; Web Freq 12.12 | Fixes 1 word
:B0X:reel estate::f("real estate") ; Fixes 1 word
:B0X:reigned in::f("reined in") ; Fixes 1 word
:B0X:rein or shine::f("rain or shine") ; Fixes 1 word
:B0X:reined supreme::f("reigned supreme") ; Fixes 1 word
:B0X:rela::f("real") ; Web Freq 297.67 | Fixes 1 word
:B0X:repla::f("reply") ; Web Freq 184.78 | Fixes 1 word
:B0X:republi::f("republic") ; Web Freq 55.05 | Fixes 1 word
:B0X:retun::f("return") ; Web Freq 205.63 | Fixes 1 word
:B0X:rhw::f("the") ; Web Freq 23135.85 | Fixes 1 word
:B0X:right hear::f("right here") ; Fixes 1 word
:B0X:rised::f("rose") ; Web Freq 38.91 | Fixes 1 word
:B0X:rite away::f("right away") ; Fixes 1 word
:B0X:rite now::f("right now") ; Fixes 1 word
:B0X:rite off the bat::f("right off the bat") ; Fixes 1 word
:B0X:rite on time::f("right on time") ; Fixes 1 word
:B0X:rite people::f("right people") ; Fixes 1 word
:B0X:rite person::f("right person") ; Fixes 1 word
:B0X:rite way::f("right way") ; Fixes 1 word
:B0X:root configuration::f("route configuration") ; Fixes 1 word
:B0X:root management::f("route management") ; Fixes 1 word
:B0X:root traffic::f("route traffic") ; Fixes 1 word
:B0X:scene it all::f("seen it all") ; Fixes 1 word
:B0X:scientis::f("scientist") ; Web Freq 8.60 | Fixes 1 word
:B0X:seam fitting::f("seem fitting") ; Fixes 1 word
:B0X:seam reasonable::f("seem reasonable") ; Fixes 1 word
:B0X:seam right::f("seem right") ; Fixes 1 word
:B0X:seam to think::f("seem to think") ; Fixes 1 word
:B0X:seams to be::f("seems to be") ; Fixes 1 word
:B0X:seeked::f("sought") ; Web Freq 12.40 | Fixes 1 word
:B0X:seen the whole seen::f("seen the whole scene") ; Fixes 1 word
:B0X:semms::f("seems") ; Web Freq 55.28 | Fixes 1 word
:B0X:sew and sew::f("so and so") ; Fixes 1 word
:B0X:sewing discord::f("sowing discord") ; Fixes 1 word
:B0X:shan`nt::f("shan't") ; Fixes 1 word
:B0X:shear madness::f("sheer madness") ; Fixes 1 word
:B0X:sherif::f("sheriff") ; Web Freq 5.76 | Fixes 1 word
:B0X:shesaid::f("she said") ; Fixes 1 word
:B0X:should not of::f("should not have") ; Fixes 1 word
:B0X:should of::f("should have") ; Fixes 1 word
:B0X:shouldn`nt::f("shouldn't") ; Fixes 1 word
:B0X:show resent::f("show recent") ; Fixes 1 word
:B0X:shw::f("she") ; Web Freq 339.17 | Fixes 1 word
:B0X:sight hosting::f("site hosting") ; Fixes 1 word
:B0X:sight maintenance::f("site maintenance") ; Fixes 1 word
:B0X:slight of hand::f("sleight of hand") ; Fixes 1 word
:B0X:soar defeat::f("sore defeat") ; Fixes 1 word
:B0X:some how::f("somehow") ; Web Freq 9.15 | Fixes 1 word
:B0X:some one::f("someone") ; Web Freq 76.21 | Fixes 1 word
:B0X:somewne::f("someone") ; Web Freq 76.21 | Fixes 1 word
:B0X:sow and sow::f("so and so") ; Fixes 1 word
:B0X:spece::f("space") ; Web Freq 121.51 | Fixes 1 word
:B0X:spreaded::f("spread") ; Web Freq 24.52 | Fixes 1 word
:B0X:sq mi::f("mi²") ; Fixes 1 word
:B0X:stares and stripes::f("stars and stripes") ; Fixes 1 word
:B0X:statted::f("started") ; Web Freq 77.52 | Fixes 1 word
:B0X:statue of limitations::f("statute of limitations") ; Fixes 1 word
:B0X:steel the show::f("steal the show") ; Fixes 1 word
:B0X:stomache::f("stomach") ; Web Freq 7.23 | Fixes 1 word
:B0X:storise::f("stories") ; Web Freq 115.50 | Fixes 1 word
:B0X:straight away::f("straightaway") ; Web Freq 0.13 | Fixes 1 word
:B0X:straight laced::f("straitlaced") ; Fixes 1 word
:B0X:strait away::f("straight away") ; Fixes 1 word
:B0X:strait to::f("straight to") ; Fixes 1 word
:B0X:studett::f("student") ; Web Freq 143.59 | Fixes 1 word
:B0X:succede::f("succeed") ; Web Freq 7.61 | Fixes 1 word
:B0X:suite yourself::f("suit yourself") ; Fixes 1 word
:B0X:t he::f("the") ; Web Freq 23135.85 | Fixes 1 word
:B0X:take affect::f("take effect") ; Fixes 1 word
:B0X:take it's course::f("take its course") ; Fixes 1 word
:B0X:tast::f("taste") ; Web Freq 17.31 | Fixes 1 word
:B0X:tath::f("that") ; Web Freq 3400.03 | Fixes 1 word
:B0X:teached::f("taught") ; Web Freq 16.08 | Fixes 1 word
:B0X:tehy::f("they") ; Web Freq 883.22 | Fixes 1 word
:B0X:tere::f("there") ; Web Freq 701.17 | Fixes 1 word
:B0X:tham::f("them") ; Web Freq 403.00 | Fixes 1 word
:B0X:thanks@::f("thanks!") ; Fixes 1 word
:B0X:thas::f("this") ; Web Freq 3228.47 | Fixes 1 word
:B0X:thay::f("they") ; Web Freq 883.22 | Fixes 1 word
:B0X:the advise of::f("the advice of") ; Fixes 1 word
:B0X:the dominate::f("the dominant") ; Fixes 1 word
:B0X:the extend of::f("the extent of") ; Fixes 1 word
:B0X:the knead for::f("the need for") ; Fixes 1 word
:B0X:their after::f("thereafter") ; Web Freq 5.23 | Fixes 1 word
:B0X:their all set::f("they're all set") ; Fixes 1 word
:B0X:their almost done::f("they're almost done") ; Fixes 1 word
:B0X:their coming::f("they're coming") ; Fixes 1 word
:B0X:their connected::f("they're connected") ; Fixes 1 word
:B0X:their doing fine::f("they're doing fine") ; Fixes 1 word
:B0X:their done::f("they're done") ; Fixes 1 word
:B0X:their downloading::f("they're downloading") ; Fixes 1 word
:B0X:their finished now::f("they're finished now") ; Fixes 1 word
:B0X:their getting ready::f("they're getting ready") ; Fixes 1 word
:B0X:their going to::f("they're going to") ; Fixes 1 word
:B0X:their gone::f("they're gone") ; Fixes 1 word
:B0X:their improving::f("they're improving") ; Fixes 1 word
:B0X:their in trouble::f("they're in trouble") ; Fixes 1 word
:B0X:their intervening::f("they're intervening") ; Fixes 1 word
:B0X:their is::f("there is") ; Fixes 1 word
:B0X:their it is::f("there it is") ; Fixes 1 word
:B0X:their late::f("they're late") ; Fixes 1 word
:B0X:their learning::f("they're learning") ; Fixes 1 word
:B0X:their leaving now::f("they're leaving now") ; Fixes 1 word
:B0X:their moving in::f("they're moving in") ; Fixes 1 word
:B0X:their moving out::f("they're moving out") ; Fixes 1 word
:B0X:their not ready::f("they're not ready") ; Fixes 1 word
:B0X:their observing::f("they're observing") ; Fixes 1 word
:B0X:their out there::f("they're out there") ; Fixes 1 word
:B0X:their ready::f("they're ready") ; Fixes 1 word
:B0X:their staying home::f("they're staying home") ; Fixes 1 word
:B0X:their staying put::f("they're staying put") ; Fixes 1 word
:B0X:their studying::f("they're studying") ; Fixes 1 word
:B0X:their the best::f("they're the best") ; Fixes 1 word
:B0X:their up next::f("they're up next") ; Fixes 1 word
:B0X:their uploading::f("they're uploading") ; Fixes 1 word
:B0X:their working late::f("they're working late") ; Fixes 1 word
:B0X:then exact revenge::f("then extract revenge") ; Fixes 1 word
:B0X:theng::f("thing") ; Web Freq 97.45 | Fixes 1 word
:B0X:there admitted::f("they're admitted") ; Fixes 1 word
:B0X:there after::f("thereafter") ; Web Freq 5.23 | Fixes 1 word
:B0X:there aide::f("their aide") ; Fixes 1 word
:B0X:there all set::f("they're all set") ; Fixes 1 word
:B0X:there almost done::f("they're almost done") ; Fixes 1 word
:B0X:there attendance::f("their attendance") ; Fixes 1 word
:B0X:there coming::f("they're coming") ; Fixes 1 word
:B0X:there connected::f("they're connected") ; Fixes 1 word
:B0X:there doing fine::f("they're doing fine") ; Fixes 1 word
:B0X:there done::f("they're done") ; Fixes 1 word
:B0X:there downloading::f("they're downloading") ; Fixes 1 word
:B0X:there eligibility::f("their eligibility") ; Fixes 1 word
:B0X:there eligible::f("they're eligible") ; Fixes 1 word
:B0X:there enrolled::f("they're enrolled") ; Fixes 1 word
:B0X:there finished::f("they're finished") ; Fixes 1 word
:B0X:there getting ready::f("they're getting ready") ; Fixes 1 word
:B0X:there going away::f("they're going away") ; Fixes 1 word
:B0X:there going home::f("they're going home") ; Fixes 1 word
:B0X:there going to::f("they're going to") ; Fixes 1 word
:B0X:there gone::f("they're gone") ; Fixes 1 word
:B0X:there grades::f("their grades") ; Fixes 1 word
:B0X:there homework::f("their homework") ; Fixes 1 word
:B0X:there hosting::f("they're hosting") ; Fixes 1 word
:B0X:there late::f("they're late") ; Fixes 1 word
:B0X:there learning::f("they're learning") ; Fixes 1 word
:B0X:there leaving::f("they're leaving") ; Fixes 1 word
:B0X:there moving in::f("they're moving in") ; Fixes 1 word
:B0X:there moving out::f("they're moving out") ; Fixes 1 word
:B0X:there not ready::f("they're not ready") ; Fixes 1 word
:B0X:there observing::f("they're observing") ; Fixes 1 word
:B0X:there of::f("thereof") ; Web Freq 10.26 | Fixes 1 word
:B0X:there online::f("they're online") ; Fixes 1 word
:B0X:there out there::f("they're out there") ; Fixes 1 word
:B0X:there passing::f("they're passing") ; Fixes 1 word
:B0X:there processing::f("they're processing") ; Fixes 1 word
:B0X:there productivity::f("their productivity") ; Fixes 1 word
:B0X:there progress::f("their progress") ; Fixes 1 word
:B0X:there provider::f("their provider") ; Fixes 1 word
:B0X:there ready::f("they're ready") ; Fixes 1 word
:B0X:there receiving::f("they're receiving") ; Fixes 1 word
:B0X:there routine::f("their routine") ; Fixes 1 word
:B0X:there schedule::f("their schedule") ; Fixes 1 word
:B0X:there server::f("their server") ; Fixes 1 word
:B0X:there staying home::f("they're staying home") ; Fixes 1 word
:B0X:there staying put::f("they're staying put") ; Fixes 1 word
:B0X:there support::f("their support") ; Fixes 1 word
:B0X:there system::f("their system") ; Fixes 1 word
:B0X:there testing::f("they're testing") ; Fixes 1 word
:B0X:there the best::f("they're the best") ; Fixes 1 word
:B0X:there transition::f("their transition") ; Fixes 1 word
:B0X:there uploading::f("they're uploading") ; Fixes 1 word
:B0X:there working late::f("they're working late") ; Fixes 1 word
:B0X:there wrong::f("they're wrong") ; Fixes 1 word
:B0X:theri::f("their") ; Web Freq 782.85 | Fixes 1 word
:B0X:thet::f("that") ; Web Freq 3400.03 | Fixes 1 word
:B0X:they're after::f("thereafter") ; Web Freq 5.23 | Fixes 1 word
:B0X:they're aide::f("their aide") ; Fixes 1 word
:B0X:they're attendance::f("their attendance") ; Fixes 1 word
:B0X:they're it is::f("there it is") ; Fixes 1 word
:B0X:they're own accord::f("their own accord") ; Fixes 1 word
:B0X:they're progress::f("their progress") ; Fixes 1 word
:B0X:they;l::f("they'll") ; Fixes 1 word
:B0X:they;r::f("they're") ; Fixes 1 word
:B0X:they;v::f("they've") ; Fixes 1 word
:B0X:they`nre::f("they're") ; Fixes 1 word
:B0X:thie::f("this") ; Web Freq 3228.47 | Fixes 1 word
:B0X:thiee::f("these") ; Web Freq 541.00 | Fixes 1 word
:B0X:thier::f("their") ; Web Freq 782.85 | Fixes 1 word 
:B0X:thim::f("them") ; Web Freq 403.00 | Fixes 1 word
:B0X:thime::f("theme") ; Web Freq 37.22 | Fixes 1 word
:B0X:this lead to::f("this led to") ; Fixes 1 word
:B0X:throne away::f("throw away") ; Fixes 1 word
:B0X:through away::f("throw away") ; Fixes 1 word
:B0X:thss::f("this") ; Web Freq 3228.47 | Fixes 1 word
:B0X:thsse::f("these") ; Web Freq 541.00 | Fixes 1 word
:B0X:tied and true::f("tried and true") ; Fixes 1 word
:B0X:tiiks::f("tools") ; Web Freq 185.56 | Fixes 1 word
:B0X:time piece::f("timepiece") ; Web Freq 0.27 | Fixes 1 word
:B0X:to bath::f("to bathe") ; Fixes 1 word
:B0X:to breath::f("to breathe") ; Fixes 1 word . Would break "breath to breath."
:B0X:to chose::f("to choose") ; Fixes 1 word
:B0X:to cut of::f("to cut off") ; Fixes 1 word
:B0X:to good to::f("too good to") ; Fixes 1 word
:B0X:to loath::f("to loathe") ; Fixes 1 word
:B0X:to much to::f("too much to") ; Fixes 1 word
:B0X:to some extend::f("to some extent") ; Fixes 1 word
:B0X:tolled you so::f("told you so") ; Fixes 1 word
:B0X:too also::f("also") ; Web Freq 616.83 | Fixes 1 word
:B0X:too be::f("to be") ; Fixes 1 word
:B0X:tornadoe::f("tornado") ; Web Freq 2.57 | Fixes 1 word 
:B0X:tothe::f("to the") ; Fixes 1 word
:B0X:tou::f("you") ; Web Freq 2996.18 | Fixes 1 word
:B0X:touugh::f("though") ; Web Freq 91.91 | Fixes 1 word
:B0X:tow of::f("two of") ; Fixes 1 word
:B0X:tow the line::f("toe the line") ; Fixes 1 word
:B0X:troup::f("troupe") ; Web Freq 0.78 | Fixes 1 word
:B0X:trouple::f("trouble") ; Web Freq 24.52 | Fixes 1 word
:B0X:tth::f("the") ; Web Freq 23135.85 | Fixes 1 word
:B0X:two good to::f("too good to") ; Fixes 1 word
:B0X:under wear::f("underwear") ; Web Freq 10.55 | Fixes 1 word
:B0X:untill::f("until") ; Web Freq 113.09 | Fixes 1 word
:B0X:uplodded::f("uploaded") ; Web Freq 8.40 | Fixes 1 word
:B0X:upto::f("up to") ; Fixes 1 word
:B0X:vane attempt::f("vain attempt") ; Fixes 1 word
:B0X:verses time::f("versus time") ; Fixes 1 word
:B0X:vertiaal::f("vertical") ; Web Freq 16.23 | Fixes 1 word
:B0X:vice principle::f("vice principal") ; Fixes 1 word
:B0X:waist effort::f("waste effort") ; Fixes 1 word
:B0X:waist of::f("waste of") ; Fixes 1 word
:B0X:waist resources::f("waste resources") ; Fixes 1 word
:B0X:waist space::f("waste space") ; Fixes 1 word
:B0X:waist time::f("waste time") ; Fixes 1 word
:B0X:waisting energy::f("wasting energy") ; Fixes 1 word
:B0X:waisting opportunities::f("wasting opportunities") ; Fixes 1 word
:B0X:waisting time::f("wasting time") ; Fixes 1 word
:B0X:waive goodbye::f("wave goodbye") ; Fixes 1 word
:B0X:was been::f("has been") ; Fixes 1 word
:B0X:was began::f("began") ; Web Freq 38.27 | Fixes 1 word
:B0X:was cable of::f("was capable of") ; Fixes 1 word
:B0X:was establish::f("was established") ; Fixes 1 word
:B0X:was extend::f("was extended") ; Fixes 1 word
:B0X:was know::f("was known") ; Fixes 1 word
:B0X:was ran::f("was run") ; Fixes 1 word
:B0X:was rode::f("was ridden") ; Fixes 1 word
:B0X:was tore::f("was torn") ; Fixes 1 word
:B0X:was wrote::f("was written") ; Fixes 1 word
:B0X:wasn`nt::f("wasn't") ; Fixes 1 word
:B0X:waste deep in::f("waist deep in") ; Fixes 1 word
:B0X:way the odds::f("weigh the odds") ; Fixes 1 word
:B0X:wear ever::f("wherever") ; Web Freq 6.76 | Fixes 1 word
:B0X:weather backup::f("whether backup") ; Fixes 1 word
:B0X:weather balanced::f("whether balanced") ; Fixes 1 word
:B0X:weather committed::f("whether committed") ; Fixes 1 word
:B0X:weather disciplined::f("whether disciplined") ; Fixes 1 word
:B0X:weather efficient::f("whether efficient") ; Fixes 1 word
:B0X:weather eligible::f("whether eligible") ; Fixes 1 word
:B0X:weather focused::f("whether focused") ; Fixes 1 word
:B0X:weather its right::f("whether it's right") ; Fixes 1 word
:B0X:weather its true::f("whether it's true") ; Fixes 1 word
:B0X:weather or not::f("whether or not") ; Fixes 1 word
:B0X:weather organized::f("whether organized") ; Fixes 1 word
:B0X:weather prepared::f("whether prepared") ; Fixes 1 word
:B0X:weather ready::f("whether ready") ; Fixes 1 word
:B0X:weather remote::f("whether remote") ; Fixes 1 word
:B0X:weather that works::f("whether that works") ; Fixes 1 word
:B0X:weather this works::f("whether this works") ; Fixes 1 word
:B0X:weather to update::f("whether to update") ; Fixes 1 word
:B0X:weight a minute::f("wait a minute") ; Fixes 1 word
:B0X:weight and see::f("wait and see") ; Fixes 1 word
:B0X:weight around::f("wait around") ; Fixes 1 word
:B0X:weight for darkness::f("wait for darkness") ; Fixes 1 word
:B0X:weight for dawn::f("wait for dawn") ; Fixes 1 word
:B0X:weight for dinner::f("wait for dinner") ; Fixes 1 word
:B0X:weight for help::f("wait for help") ; Fixes 1 word
:B0X:weight for it::f("wait for it") ; Fixes 1 word
:B0X:weight for me::f("wait for me") ; Fixes 1 word
:B0X:weight for morning::f("wait for morning") ; Fixes 1 word
:B0X:weight for news::f("wait for news") ; Fixes 1 word
:B0X:weight for signs::f("wait for signs") ; Fixes 1 word
:B0X:weight for spring::f("wait for spring") ; Fixes 1 word
:B0X:weight for sunset::f("wait for sunset") ; Fixes 1 word
:B0X:weight in line::f("wait in line") ; Fixes 1 word
:B0X:weight in silence::f("wait in silence") ; Fixes 1 word
:B0X:weight in the balance::f("wait in the balance") ; Fixes 1 word
:B0X:weight in the wings::f("wait in the wings") ; Fixes 1 word
:B0X:weight it down::f("wait it down") ; Fixes 1 word
:B0X:weight it out::f("wait it out") ; Fixes 1 word
:B0X:weight it through::f("wait it through") ; Fixes 1 word
:B0X:weight list::f("wait list") ; Fixes 1 word
:B0X:weight loss::f("wait loss") ; Fixes 1 word
:B0X:weight your chance::f("wait your chance") ; Fixes 1 word
:B0X:weight your turn::f("wait your turn") ; Fixes 1 word
:B0X:weighting around::f("waiting around") ; Fixes 1 word
:B0X:well bred::f("well-bred") ; Fixes 1 word
:B0X:welsome::f("welcome") ; Web Freq 114.03 | Fixes 1 word
:B0X:were build::f("were built") ; Fixes 1 word
:B0X:were ran::f("were run") ; Fixes 1 word
:B0X:were rebuild::f("were rebuilt") ; Fixes 1 word
:B0X:were rode::f("were ridden") ; Fixes 1 word
:B0X:were spend::f("were spent") ; Fixes 1 word
:B0X:were tore::f("were torn") ; Fixes 1 word
:B0X:were wrote::f("were written") ; Fixes 1 word
:B0X:weren`nt::f("weren't") ; Fixes 1 word
:B0X:whan::f("when") ; Web Freq 650.62 | Fixes 1 word
:B0X:whather::f("whether") ; Web Freq 105.01 | Fixes 1 word
:B0X:wheel chair::f("wheelchair") ; Web Freq 4.44 | Fixes 1 word
:B0X:when ever::f("whenever") ; Web Freq 14.23 | Fixes 1 word
:B0X:where as::f("whereas") ; Web Freq 14.66 | Fixes 1 word
:B0X:where ever::f("wherever") ; Web Freq 6.76 | Fixes 1 word
:B0X:where with all::f("wherewithal") ; Web Freq 0.14 | Fixes 1 word
:B0X:whereas as::f("whereas") ; Web Freq 14.66 | Fixes 1 word
:B0X:wherease::f("whereas") ; Web Freq 14.66 | Fixes 1 word
:B0X:whether allows::f("weather allows") ; Fixes 1 word
:B0X:whether forecast::f("weather forecast") ; Fixes 1 word
:B0X:whether report::f("weather report") ; Fixes 1 word
:B0X:whic::f("which") ; Web Freq 810.51 | Fixes 1 word
:B0X:whil::f("will") ; Web Freq 1356.29 | Fixes 1 word
:B0X:who's book::f("whose book") ; Fixes 1 word
:B0X:who's turn::f("whose turn") ; Fixes 1 word
:B0X:whose who::f("who's who") ; Fixes 1 word
:B0X:whough::f("though") ; Web Freq 91.91 | Fixes 1 word
:B0X:wiil::f("will") ; Web Freq 1356.29 | Fixes 1 word
:B0X:will exact revenge::f("will extract revenge") ; Fixes 1 word
:B0X:will of::f("will have") ; Fixes 1 word
:B0X:with in::f("within") ; Web Freq 261.39 | Fixes 1 word
:B0X:with on of::f("with one of") ; Fixes 1 word
:B0X:with who::f("with whom") ; Fixes 1 word
:B0X:witha::f("with a") ; Fixes 1 word
:B0X:withher::f("whether") ; Web Freq 105.01 | Fixes 1 word
:B0X:withing::f("within") ; Web Freq 261.39 | Fixes 1 word
:B0X:without further ado::f("without further adieu") ; Fixes 1 word
:B0X:won way::f("one way") ; Fixes 1 word
:B0X:won`nt::f("won't") ; Fixes 1 word
:B0X:wonderfull::f("wonderful") ; Web Freq 28.80 | Fixes 1 word
:B0X:worth while::f("worthwhile") ; Web Freq 2.98 | Fixes 1 word
:B0X:worth wile::f("worthwhile") ; Web Freq 2.98 | Fixes 1 word
:B0X:would of::f("would have") ; Fixes 1 word
:B0X:wouldn`nt::f("wouldn't") ; Fixes 1 word
:B0X:wrest assured::f("rest assured") ; Fixes 1 word
:B0X:wrest in peace::f("rest in peace") ; Fixes 1 word
:B0X:write away::f("right away") ; Fixes 1 word
:B0X:write guess::f("right guess") ; Fixes 1 word
:B0X:write hear::f("right here") ; Fixes 1 word
:B0X:write now::f("right now") ; Fixes 1 word
:B0X:write off the bat::f("right off the bat") ; Fixes 1 word
:B0X:write on time::f("right on time") ; Fixes 1 word
:B0X:write path::f("right path") ; Fixes 1 word
:B0X:write person::f("right person") ; Fixes 1 word
:B0X:write place::f("right place") ; Fixes 1 word
:B0X:write time::f("right time") ; Fixes 1 word
:B0X:write timing::f("right timing") ; Fixes 1 word
:B0X:write track::f("right track") ; Fixes 1 word
:B0X:write way::f("right way") ; Fixes 1 word
:B0X:writi::f("write") ; Web Freq 126.65 | Fixes 1 word
:B0X:xisw::f("code") ; Web Freq 250.25 | Fixes 1 word
:B0X:you're call::f("your call") ; Fixes 1 word
:B0X:you're goals::f("your goals") ; Fixes 1 word
:B0X:you're journey::f("your journey") ; Fixes 1 word
:B0X:you're self::f("yourself") ; Web Freq 51.53 | Fixes 1 word
:B0X:you`nre::f("you're") ; Fixes 1 word
:B0X:your a::f("you're a") ; Fixes 1 word
:B0X:your absent::f("you're absent") ; Fixes 1 word
:B0X:your an::f("you're an") ; Fixes 1 word
:B0X:your balanced::f("you're balanced") ; Fixes 1 word
:B0X:your committed::f("you're committed") ; Fixes 1 word
:B0X:your disciplined::f("you're disciplined") ; Fixes 1 word
:B0X:your efficient::f("you're efficient") ; Fixes 1 word
:B0X:your excused::f("you're excused") ; Fixes 1 word
:B0X:your focused::f("you're focused") ; Fixes 1 word
:B0X:your her::f("you're her") ; Fixes 1 word
:B0X:your here::f("you're here") ; Fixes 1 word
:B0X:your his::f("you're his") ; Fixes 1 word
:B0X:your invited::f("you're invited") ; Fixes 1 word
:B0X:your kidding::f("you're kidding") ; Fixes 1 word
:B0X:your my::f("you're my") ; Fixes 1 word
:B0X:your organized::f("you're organized") ; Fixes 1 word
:B0X:your ready::f("you're ready") ; Fixes 1 word
:B0X:your responsible::f("you're responsible") ; Fixes 1 word
:B0X:your right about::f("you're right about") ; Fixes 1 word
:B0X:your self::f("yourself") ; Web Freq 51.53 | Fixes 1 word
:B0X:your the::f("you're the") ; Fixes 1 word
:B0X:your welcome::f("you're welcome") ; Fixes 1 word
:B0X:youv'e::f("you've") ; Fixes 1 word
:B0X:youve::f("you've") ; Fixes 1 word
:B0X?:'nt::f("n't") ; Fixes 22 words
:B0X?:;ll::f("'ll") ; Fixes 12 words
:B0X?:;re::f("'re") ; Fixes 8 words
:B0X?:;s::f("'s") ; Fixes 1 word
:B0X?:;ve::f("'ve") ; Fixes 12 words
:B0X?:abely::f("ably") ; Web Freq 115.54 | Fixes 594 words
:B0X?:abley::f("ably") ; Web Freq 115.54 | Fixes 594 words
:B0X?:aboe::f("able") ; Web Freq 1598.26 | Fixes 2125 words
:B0X?:acced::f("added") ; Web Freq 121.96 | Fixes 19 words Will it break "aced"?
:B0X?:addres::f("address") ; Web Freq 262.07 | Fixes 4 words
:B0X?:adequit::f("adequate") ; Web Freq 19.92 | Fixes 2 words
:B0X?:aelly::f("eally") ; Web Freq 166.14 | Fixes 27 words
:B0X?:aicly::f("aically") ; Fixes 12 words
:B0X?:aindre::f("ained") ; Web Freq 187.95 | Fixes 95 words
:B0X?:ainity::f("ainty") ; Web Freq 10.40 | Fixes 6 words
:B0X?:akk::f("all") ; Web Freq 3635.63 | Fixes 219 words
:B0X?:akks::f("alls") ; Web Freq 173.81 | Fixes 182 words
:B0X?:akkt::f("ally") ; Web Freq 1138.83 | Fixes 2642 words
:B0X?:akky::f("ally") ; Web Freq 1138.83 | Fixes 2642 words
:B0X?:alekd::f("alked") ; Web Freq 21.06 | Fixes 22 words
:B0X?:aliyy::f("ality") ; Web Freq 366.42 | Fixes 313 words
:B0X?:allly::f("ally") ; Web Freq 1138.83 | Fixes 2642 words
:B0X?:allty::f("alty") ; Web Freq 66.69 | Fixes 25 words
:B0X?:alowing::f("allowing") ; Web Freq 21.83 | Fixes 11 words
:B0X?:aotrs::f("ators") ; Web Freq 155.47 | Fixes 493 words
:B0X?:arrat::f("array") ; Web Freq 26.57 | Fixes 4 words
:B0X?:artice::f("article") ; Web Freq 190.63 | Fixes 8 words
:B0X?:arund::f("around") ; Web Freq 182.99 | Fixes 6 words
:B0X?:aslly::f("astly") ; Web Freq 4.14 | Fixes 7 words
:B0X?:asuing::f("ausing") ; Web Freq 11.25 | Fixes 4 words
:B0X?:ataly::f("atally") ; Web Freq 0.60 | Fixes 9 words
:B0X?:ateng::f("ating") ; Web Freq 761.47 | Fixes 1229 words
:B0X?:aticly::f("atically") ; Web Freq 46.70 | Fixes 120 words
:B0X?:ativs::f("atives") ; Web Freq 82.44 | Fixes 93 words
:B0X?:atley::f("ately") ; Web Freq 157.47 | Fixes 169 words, but misspells Wheatley (a fictional artificial intelligence from the Portal franchise)
:B0X?:attemp::f("attempt") ; Web Freq 25.25 | Fixes 2 words
:B0X?:atthe::f("athe") ; Web Freq 6.02 | Fixes 23 words
:B0X?:aunchs::f("aunches") ; Web Freq 7.56 | Fixes 11 words
:B0X?:autor::f("author") ; Web Freq 180.86 | Fixes 4 words, but misspells fautor (Latin term meaning a supporter or patron)
:B0X?:aveng::f("aving") ; Web Freq 170.29 | Fixes 58 words
:B0X?:awate::f("aware") ; Web Freq 47.24 | Fixes 7 words
:B0X?:beist::f("biest") ; Fixes 41 words
:B0X?:bilites::f("bilities") ; Web Freq 82.94 | Fixes 596 words
:B0X?:bilties::f("bilities") ; Web Freq 82.94 | Fixes 596 words
:B0X?:bilty::f("bility") ; Web Freq 495.04 | Fixes 984 words
:B0X?:blities::f("bilities") ; Web Freq 82.94 | Fixes 596 words
:B0X?:blity::f("bility") ; Web Freq 495.04 | Fixes 984 words
:B0X?:boared::f("board") ; Web Freq 293.20 | Fixes 136 words
:B0X?:borke::f("broke") ; Web Freq 12.34 | Fixes 8 words
:B0X?:busines::f("business") ; Web Freq 638.25 | Fixes 6 words
:B0X?:busineses::f("businesses") ; Web Freq 48.46 | Fixes 4 words
:B0X?:caly::f("cally") ; Web Freq 228.99 | Fixes 1596 words
:B0X?:cashe::f("cache") ; Web Freq 17.34 | Fixes 2 words
:B0X?:certaintly::f("certainly") ; Web Freq 27.05 | Fixes 3 words
:B0X?:cilites::f("cilities") ; Web Freq 70.60 | Fixes 5 words
:B0X?:cisly::f("cisely") ; Web Freq 6.59 | Fixes 4 words
:B0X?:claimes::f("claims") ; Web Freq 39.57 | Fixes 13 words
:B0X?:claming::f("claiming") ; Web Freq 6.30 | Fixes 12 words
:B0X?:comit::f("commit") ; Web Freq 17.47 | Fixes 3 words
:B0X?:commandoes::f("commandos") ; Web Freq 0.64 | Fixes 1 word
:B0X?:comming::f("coming") ; Web Freq 134.59 | Fixes 14 words
:B0X?:commiting::f("committing") ; Web Freq 2.15 | Fixes 3 words
:B0X?:committe::f("committee") ; Web Freq 129.04 | Fixes 2 words
:B0X?:commongly::f("commonly") ; Web Freq 11.79 | Fixes 2 words
:B0X?:comon::f("common") ; Web Freq 110.75 | Fixes 2 words
:B0X?:compability::f("compatibility") ; Web Freq 12.56 | Fixes 5 words
:B0X?:competely::f("completely") ; Web Freq 34.53 | Fixes 3 words
:B0X?:conly::f("cally") ; Web Freq 228.99 | Fixes 1596 words
:B0X?:controll::f("control") ; Web Freq 215.74 | Fixes 4 words
:B0X?:controlls::f("controls") ; Web Freq 29.84 | Fixes 4 words
:B0X?:criticists::f("critics") ; Web Freq 10.24 | Fixes 3 words
:B0X?:cticly::f("critically") ; Web Freq 3.33 | Fixes 8 words
:B0X?:ctino::f("ction") ; Web Freq 1716.48 | Fixes 285 words
:B0X?:ctoty::f("ctory") ; Web Freq 275.59 | Fixes 27 words
:B0X?:cually::f("cularly") ; Web Freq 42.74 | Fixes 41 words
:B0X?:cuesed::f("cussed") ; Web Freq 26.54 | Fixes 17 words
:B0X?:culem::f("culum") ; Web Freq 25.61 | Fixes 23 words
:B0X?:culti::f("culty") ; Web Freq 65.16 | Fixes 6 words
:B0X?:cumenta::f("cuments") ; Web Freq 64.44 | Fixes 2 words
:B0X?:currenly::f("currently") ; Web Freq 90.65 | Fixes 6 words
:B0X?:daly::f("dally") ; Web Freq 0.22 | Fixes 41 words, but misspells Daly (An Isish surname)
:B0X?:decidely::f("decidedly") ; Web Freq 0.86 | Fixes 2 words
:B0X?:definitlly::f("definitely") ; Web Freq 17.42 | Fixes 2 words
:B0X?:deing::f("ding") ; Web Freq 1817.83 | Fixes 860 words
:B0X?:deings::f("dings") ; Web Freq 142.21 | Fixes 188 words
:B0X?:develope::f("develop") ; Web Freq 55.77 | Fixes 6 words
:B0X?:developes::f("develops") ; Web Freq 5.96 | Fixes 6 words
:B0X?:dfull::f("dful") ; Web Freq 5.89 | Fixes 18 words
:B0X?:dfullness::f("dfulness") ; Web Freq 0.45 | Fixes 9 words
:B0X?:dfulls::f("dfuls") ; Web Freq 0.12 | Fixes 5 words
:B0X?:dicly::f("dically") ; Web Freq 11.25 | Fixes 42 words
:B0X?:doens::f("does") ; Web Freq 315.74 | Fixes 39 words
:B0X?:doese::f("does") ; Web Freq 315.74 | Fixes 39 words
:B0X?:doind::f("doing") ; Web Freq 82.02 | Fixes 19 words
:B0X?:doinds::f("doings") ; Web Freq 0.41 | Fixes 5 words
:B0X?:donly::f("dally") ; Web Freq 0.22 | Fixes 41 words
:B0X?:eamil::f("email") ; Web Freq 445.65 | Fixes 4 words
:B0X?:ecclectic::f("eclectic") ; Web Freq 2.69 | Fixes 1 word
:B0X?:ed form the ::f("ed from the") ; Fixes 1 word
:B0X?:edely::f("edly") ; Web Freq 26.54 | Fixes 688 words
:B0X?:efering::f("eferring") ; Web Freq 8.31 | Fixes 4 words
:B0X?:efullness::f("efulness") ; Web Freq 2.77 | Fixes 50 words
:B0X?:efulls::f("efuls") ; Web Freq 0.30 | Fixes 22 words
:B0X?:ellected::f("elected") ; Web Freq 75.89 | Fixes 13 words
:B0X?:emnt::f("ment") ; Web Freq 3364.26 | Fixes 731 words
:B0X?:emnts::f("ments") ; Web Freq 1132.63 | Fixes 708 words
:B0X?:endig::f("ending") ; Web Freq 178.20 | Fixes 102 words
:B0X?:endigly::f("endingly") ; Web Freq 0.03 | Fixes 12 words
:B0X?:enece::f("ence") ; Web Freq 1258.98 | Fixes 390 words
:B0X?:eneces::f("ences") ; Web Freq 242.92 | Fixes 358 words
:B0X?:engly::f("ingly") ; Web Freq 51.76 | Fixes 977 words
:B0X?:entily::f("ently") ; Web Freq 289.14 | Fixes 266 words
:B0X?:equiped::f("equipped") ; Web Freq 12.67 | Fixes 4 words
:B0X?:erntly::f("erently") ; Web Freq 8.29 | Fixes 12 words
:B0X?:ernts::f("erents") ; Web Freq 0.71 | Fixes 12 words
:B0X?:eslly::f("estly") ; Web Freq 6.22 | Fixes 12 words
:B0X?:esntly::f("esently") ; Web Freq 5.25 | Fixes 2 words
:B0X?:esnts::f("esents") ; Web Freq 41.97 | Fixes 7 words
:B0X?:essery::f("essary") ; Web Freq 78.13 | Fixes 4 words
:B0X?:essess::f("esses") ; Web Freq 174.50 | Fixes 3260 words
:B0X?:establising::f("establishing") ; Web Freq 10.79 | Fixes 4 words
:B0X?:etoin::f("etion") ; Web Freq 37.28 | Fixes 20 words
:B0X?:examinated::f("examined") ; Web Freq 10.91 | Fixes 3 words
:B0X?:existe::f("exists") ; Web Freq 18.69 | Fixes 6 words
:B0X?:expell::f("expel") ; Web Freq 0.47 | Fixes 2 words
:B0X?:explaning::f("explaining") ; Web Freq 5.79 | Fixes 3 words
:B0X?:extered::f("exerted") ; Web Freq 0.68 | Fixes 3 words
:B0X?:ferrs::f("fers") ; Web Freq 191.00 | Fixes 102 words
:B0X?:fertily::f("fertility") ; Web Freq 7.10 | Fixes 4 words
:B0X?:ficly::f("fically") ; Web Freq 27.75 | Fixes 22 words
:B0X?:fightings::f("fighting") ; Web Freq 21.16 | Fixes 12 words
:B0X?:finit::f("finite") ; Web Freq 19.34 | Fixes 6 words
:B0X?:finitly::f("finitely") ; Web Freq 19.09 | Fixes 4 words
:B0X?:fyed::f("fied") ; Web Freq 311.91 | Fixes 274 words
:B0X?:gardes::f("gards") ; Web Freq 13.23 | Fixes 8 words
:B0X?:getted::f("geted") ; Web Freq 12.46 | Fixes 11 words
:B0X?:gettin::f("getting") ; Web Freq 95.09 | Fixes 4 words
:B0X?:gfulls::f("gfuls") ; Fixes 4 words
:B0X?:gicly::f("gically") ; Web Freq 10.83 | Fixes 149 words
:B0X?:giory::f("gory") ; Web Freq 177.10 | Fixes 7 words
:B0X?:glases::f("glasses") ; Web Freq 26.44 | Fixes 14 words
:B0X?:godd::f("good") ; Web Freq 366.30 | Fixes 7 words
:B0X?:gonly::f("gally") ; Web Freq 8.77 | Fixes 16 words
:B0X?:gradded::f("graded") ; Web Freq 10.24 | Fixes 14 words
:B0X?:greae::f("grade") ; Web Freq 97.24 | Fixes 23 words
:B0X?:haee::f("have") ; Web Freq 1571.16 | Fixes 10 words
:B0X?:hanss::f("hanks") ; Web Freq 94.41 | Fixes 14 words
:B0X?:hda::f("had") ; Web Freq 501.70 | Fixes 12 words
:B0X?:helpfull::f("helpful") ; Web Freq 47.35 | Fixes 3 words
:B0X?:herad::f("heard") ; Web Freq 47.36 | Fixes 6 words
:B0X?:herefor::f("herefore") ; Web Freq 62.88 | Fixes 2 words
:B0X?:hfulls::f("hfuls") ; Web Freq 0.25 | Fixes 3 words
:B0X?:higns::f("hings") ; Web Freq 161.95 | Fixes 130 words
:B0X?:higsn::f("hings") ; Web Freq 161.95 | Fixes 130 words
:B0X?:holle::f("whole") ; Web Freq 85.25 | Fixes 2 words
:B0X?:http:\\::f("http://") ; Fixes 1 word
:B0X?:httpL::f("http:") ; Fixes 1 word
:B0X?:iaing::f("iating") ; Web Freq 12.44 | Fixes 97 words
:B0X?:iaingly::f("iatingly") ; Web Freq 0.12 | Fixes 6 words
:B0X?:iatly::f("iately") ; Web Freq 43.05 | Fixes 12 words
:B0X?:iblilties::f("ibilities") ; Web Freq 26.28 | Fixes 129 words
:B0X?:iblilty::f("ibility") ; Web Freq 156.13 | Fixes 173 words
:B0X?:iekd::f("iked") ; Web Freq 13.10 | Fixes 17 words
:B0X?:ienty::f("iently") ; Web Freq 16.99 | Fixes 37 words
:B0X?:iliyy::f("ility") ; Web Freq 587.27 | Fixes 1037 words
:B0X?:inially::f("inally") ; Web Freq 80.53 | Fixes 48 words
:B0X?:ionly::f("ially") ; Web Freq 140.38 | Fixes 254 words, but misspells lionly (Like a lion)
:B0X?:is usefully for::f("is useful for") ; Fixes 1 word
:B0X?:itess::f("items") ; Web Freq 330.55 | Fixes 2 words
:B0X?:iticing::f("iticising") ; Web Freq 0.20 | Fixes 3 words
:B0X?:itino::f("ition") ; Web Freq 700.36 | Fixes 133 words
:B0X?:itthe::f("ithe") ; Web Freq 0.79 | Fixes 11 words
:B0X?:ityes::f("ities") ; Web Freq 698.98 | Fixes 1703 words
:B0X?:ivites::f("ivities") ; Web Freq 134.82 | Fixes 98 words
:B0X?:iztion::f("ization") ; Web Freq 215.89 | Fixes 637 words
:B0X?:iztions::f("izations") ; Web Freq 62.81 | Fixes 522 words
:B0X?:kcers::f("ckers") ; Web Freq 39.85 | Fixes 142 words
:B0X?:kciness::f("ckiness") ; Web Freq 0.30 | Fixes 18 words
:B0X?:kcish::f("ckish") ; Web Freq 0.43 | Fixes 18 words
:B0X?:keing::f("king") ; Web Freq 1467.04 | Fixes 815 words
:B0X?:keings::f("kings") ; Web Freq 68.44 | Fixes 187 words
:B0X?:kfulls::f("kfuls") ; Fixes 11 words
:B0X?:knive::f("knife") ; Web Freq 11.76 | Fixes 7 words
:B0X?:l;y::f("ly") ; Web Freq 5937.82 | Fixes 9887 words
:B0X?:laion::f("lation") ; Web Freq 403.56 | Fixes 278 words
:B0X?:laions::f("lations") ; Web Freq 170.17 | Fixes 259 words
:B0X?:laity::f("ality") ; Web Freq 366.42 | Fixes 313 words, but misspells Laity (non-clergical, religious followers)
:B0X?:lalry::f("larly") ; Web Freq 71.34 | Fixes 80 words
:B0X?:laod::f("load") ; Web Freq 296.82 | Fixes 41 words
:B0X?:lasion::f("lation") ; Web Freq 403.56 | Fixes 278 words
:B0X?:lasions::f("lations") ; Web Freq 170.17 | Fixes 259 words
:B0X?:lastr::f("last") ; Web Freq 430.71 | Fixes 60 words
:B0X?:leare::f("leave") ; Web Freq 71.52 | Fixes 6 words
:B0X?:leid::f("lied") ; Web Freq 122.54 | Fixes 61 words
:B0X?:letness::f("leteness") ; Web Freq 3.97 | Fixes 5 words
:B0X?:lfull::f("lful") ; Web Freq 2.82 | Fixes 16 words
:B0X?:lieing::f("lying") ; Web Freq 72.16 | Fixes 62 words, but misspells ollieing (A skateboarding trick)
:B0X?:liek::f("like") ; Web Freq 544.08 | Fixes 630 words
:B0X?:lighly::f("lightly") ; Web Freq 33.92 | Fixes 3 words
:B0X?:likey::f("likely") ; Web Freq 64.06 | Fixes 4 words
:B0X?:lility::f("ility") ; Web Freq 587.27 | Fixes 1037 words
:B0X?:lingless::f("lingness") ; Web Freq 4.11 | Fixes 36 words
:B0X?:llete::f("lette") ; Web Freq 18.62 | Fixes 27 words, but misspells decollete (Garment with low-cut neckline), feuillete (Culinary word for a type of dough)
:B0X?:lmits::f("limits") ; Web Freq 22.00 | Fixes 4 words
:B0X?:looe::f("lose") ; Web Freq 140.84 | Fixes 65 words, but misspells Looe (A town in England)
:B0X?:lsat::f("last") ; Web Freq 430.71 | Fixes 60 words
:B0X?:lusis::f("lysis") ; Web Freq 133.66 | Fixes 61 words
:B0X?:lutly::f("lutely") ; Web Freq 21.05 | Fixes 7 words
:B0X?:lyed::f("lied") ; Web Freq 122.54 | Fixes 61 words
:B0X?:makd::f("make") ; Web Freq 406.84 | Fixes 8 words
:B0X?:maked::f("marked") ; Web Freq 23.33 | Fixes 20 words
:B0X?:maticas::f("matics") ; Web Freq 35.43 | Fixes 40 words
:B0X?:memly::f("mely") ; Web Freq 42.20 | Fixes 55 words
:B0X?:miantly::f("minately") ; Web Freq 0.57 | Fixes 6 words
:B0X?:mibly::f("mably") ; Web Freq 3.50 | Fixes 19 words
:B0X?:micly::f("mically") ; Web Freq 11.12 | Fixes 113 words
:B0X?:miliary::f("military") ; Web Freq 71.85 | Fixes 5 words, but misspells miliary (Resembling millet seeds)
:B0X?:moce::f("move") ; Web Freq 120.15 | Fixes 9 words
:B0X?:morphysis::f("morphosis") ; Web Freq 0.70 | Fixes 6 words
:B0X?:motted::f("moted") ; Web Freq 5.60 | Fixes 7 words
:B0X?:myed::f("mied") ; Web Freq 0.18 | Fixes 9 words
:B0X?:n;t::f("n't") ; Fixes 22 words
:B0X?:naly::f("nally") ; Web Freq 159.70 | Fixes 271 words
:B0X?:natly::f("nately") ; Web Freq 24.91 | Fixes 44 words
:B0X?:naturely::f("naturally") ; Web Freq 10.76 | Fixes 6 words
:B0X?:ndacies::f("ndances") ; Web Freq 0.66 | Fixes 10 words
:B0X?:nexted::f("nested") ; Web Freq 5.27 | Fixes 3 words
:B0X?:nexting::f("nesting") ; Web Freq 2.16 | Fixes 4 words
:B0X?:nfull::f("nful") ; Web Freq 7.83 | Fixes 41 words
:B0X?:nfulls::f("nfuls") ; Web Freq 0.15 | Fixes 19 words
:B0X?:ngably::f("ngeably") ; Web Freq 0.34 | Fixes 5 words
:B0X?:ngment::f("ngement") ; Web Freq 17.56 | Fixes 10 words
:B0X?:nicly::f("nically") ; Web Freq 15.32 | Fixes 147 words
:B0X?:nision::f("nisation") ; Web Freq 26.00 | Fixes 96 words
:B0X?:nkwo::f("know") ; Web Freq 306.89 | Fixes 5 words
:B0X?:nnally::f("nally") ; Web Freq 159.70 | Fixes 271 words
:B0X?:nonly::f("nally") ; Web Freq 159.70 | Fixes 271 words
:B0X?:nowe::f("now") ; Web Freq 989.56 | Fixes 17 words, but misspells Knowe (a small hill or mound)
:B0X?:ns't::f("sn't") ; Fixes 4 words
:B0X?:nuled::f("nulled") ; Web Freq 0.20 | Fixes 3 words
:B0X?:nwe::f("new") ; Web Freq 3141.67 | Fixes 12 words
:B0X?:oachs::f("oaches") ; Web Freq 25.62 | Fixes 18 words
:B0X?:occure::f("occur") ; Web Freq 24.72 | Fixes 3 words
:B0X?:occured::f("occurred") ; Web Freq 19.07 | Fixes 3 words
:B0X?:occurr::f("occur") ; Web Freq 24.72 | Fixes 3 words
:B0X?:oloty::f("ology") ; Web Freq 500.09 | Fixes 389 words
:B0X?:oslly::f("ostly") ; Web Freq 32.44 | Fixes 9 words
:B0X?:otaly::f("otally") ; Web Freq 24.40 | Fixes 7 words
:B0X?:otherw::f("others") ; Web Freq 166.43 | Fixes 17 words
:B0X?:otino::f("otion") ; Web Freq 91.43 | Fixes 13 words, but misspells photino (a hypothetical elementary particle, Physics stuff)
:B0X?:otthe::f("othe") ; Web Freq 0.98 | Fixes 8 words
:B0X?:ougly::f("oughly") ; Web Freq 13.18 | Fixes 3 words
:B0X?:ouldent::f("ouldn't") ; Fixes 3 words
:B0X?:ourary::f("orary") ; Web Freq 50.65 | Fixes 9 words
:B0X?:paide::f("paid") ; Web Freq 70.91 | Fixes 11 words
:B0X?:paln::f("plan") ; Web Freq 164.02 | Fixes 10 words
:B0X?:peist::f("piest") ; Web Freq 0.77 | Fixes 111 words
:B0X?:pfulls::f("pfuls") ; Web Freq 0.01 | Fixes 8 words
:B0X?:picly::f("pically") ; Web Freq 19.36 | Fixes 59 words
:B0X?:pleatly::f("pletely") ; Web Freq 34.53 | Fixes 4 words
:B0X?:pletly::f("pletely") ; Web Freq 34.53 | Fixes 4 words
:B0X?:polical::f("political") ; Web Freq 82.81 | Fixes 9 words
:B0X?:presente::f("presence") ; Web Freq 28.73 | Fixes 3 words
:B0X?:probless::f("problems") ; Web Freq 121.16 | Fixes 3 words
:B0X?:proces::f("process") ; Web Freq 177.09 | Fixes 5 words
:B0X?:proprietory::f("proprietary") ; Web Freq 8.32 | Fixes 2 words
:B0X?:puertorrican::f("Puerto Rican") ; Fixes 1 word
:B0X?:pyed::f("pied") ; Web Freq 19.25 | Fixes 17 words
:B0X?:quater::f("quarter") ; Web Freq 36.45 | Fixes 4 words
:B0X?:quaters::f("quarters") ; Web Freq 18.82 | Fixes 4 words
:B0X?:querd::f("quered") ; Web Freq 1.76 | Fixes 6 words
:B0X?:quete::f("quite") ; Web Freq 59.94 | Fixes 4 words
:B0X?:quetes::f("quotes") ; Web Freq 48.53 | Fixes 6 words
:B0X?:raed::f("read") ; Web Freq 543.42 | Fixes 48 words, but misspells mascaraed (wearing mascara), tiaraed (wearing a tiara)
:B0X?:ragge::f("range") ; Web Freq 233.55 | Fixes 19 words
:B0X?:rarry::f("rary") ; Web Freq 245.66 | Fixes 32 words
:B0X?:realy::f("really") ; Web Freq 162.03 | Fixes 13 words
:B0X?:reched::f("reached") ; Web Freq 24.45 | Fixes 9 words
:B0X?:reciding::f("residing") ; Web Freq 3.98 | Fixes 2 words
:B0X?:reday::f("ready") ; Web Freq 171.35 | Fixes 8 words
:B0X?:reis::f("ries") ; Web Freq 1199.27 | Fixes 1233 words, but misspells Milreis (former Portuguese currency), Hexerei (Practice of witchcraft or sorcery in German), Schwärmerei (Excessive enthusiasm or obsession in German)
:B0X?:repott::f("report") ; Web Freq 286.25 | Fixes 4 words
:B0X?:resed::f("ressed") ; Web Freq 85.40 | Fixes 61 words, but misspells electrophoresed (Moved charged particles through a medium using an electric field)
:B0X?:resing::f("ressing") ; Web Freq 33.80 | Fixes 52 words, but misspells electrophoresing (Moving charged particles through a medium using an electric field)
:B0X?:returnd::f("returned") ; Web Freq 34.16 | Fixes 2 words
:B0X?:ricly::f("rically") ; Web Freq 9.48 | Fixes 145 words
:B0X?:rithy::f("rity") ; Web Freq 487.46 | Fixes 139 words
:B0X?:ritiers::f("rities") ; Web Freq 84.71 | Fixes 127 words
:B0X?:rmaly::f("rmally") ; Web Freq 26.24 | Fixes 20 words
:B0X?:roudn::f("round") ; Web Freq 391.74 | Fixes 30 words
:B0X?:rsise::f("rwise") ; Web Freq 54.08 | Fixes 6 words
:B0X?:ruley::f("ruly") ; Web Freq 22.20 | Fixes 4 words
:B0X?:saccharid::f("saccharide") ; Web Freq 0.71 | Fixes 9 words
:B0X?:safty::f("safety") ; Web Freq 111.65 | Fixes 3 words
:B0X?:saught::f("sought") ; Web Freq 12.54 | Fixes 4 words
:B0X?:schol::f("school") ; Web Freq 350.12 | Fixes 10 words
:B0X?:scoll::f("scroll") ; Web Freq 8.74 | Fixes 4 words
:B0X?:seist::f("siest") ; Web Freq 5.22 | Fixes 84 words
:B0X?:sequentually::f("sequently") ; Web Freq 14.22 | Fixes 4 words
:B0X?:sfull::f("sful") ; Web Freq 47.15 | Fixes 40 words
:B0X?:sfulyl::f("sfully") ; Web Freq 18.71 | Fixes 5 words
:B0X?:shiped::f("shipped") ; Web Freq 17.73 | Fixes 10 words
:B0X?:shiping::f("shipping") ; Web Freq 257.23 | Fixes 10 words
:B0X?:shorly::f("shortly") ; Web Freq 8.07 | Fixes 2 words
:B0X?:showt::f("short") ; Web Freq 106.81 | Fixes 3 words
:B0X?:siary::f("sary") ; Web Freq 123.79 | Fixes 17 words
:B0X?:sicly::f("sically") ; Web Freq 21.00 | Fixes 25 words
:B0X?:sixe::f("size") ; Web Freq 226.89 | Fixes 36 words
:B0X?:smoothe::f("smooth") ; Web Freq 18.63 | Fixes 6 words
:B0X?:sorce::f("source") ; Web Freq 281.48 | Fixes 7 words
:B0X?:specif::f("specify") ; Web Freq 19.00 | Fixes 5 words
:B0X?:ssully::f("ssfully") ; Web Freq 18.71 | Fixes 5 words
:B0X?:stanly::f("stantly") ; Web Freq 21.26 | Fixes 8 words
:B0X?:statt::f("start") ; Web Freq 167.61 | Fixes 9 words
:B0X?:statts::f("starts") ; Web Freq 23.80 | Fixes 8 words
:B0X?:stiing::f("string") ; Web Freq 55.06 | Fixes 15 words
:B0X?:storicians::f("storians") ; Web Freq 2.81 | Fixes 6 words
:B0X?:stude::f("study") ; Web Freq 153.08 | Fixes 5 words
:B0X?:stuls::f("sults") ; Web Freq 269.88 | Fixes 5 words
:B0X?:suee::f("sure") ; Web Freq 384.16 | Fixes 69 words
:B0X?:syas::f("says") ; Web Freq 119.86 | Fixes 16 words, but misspells Vaisyas (A member of the mercantile and professional Hindu caste), Vaisyas (A member of the mercantile and professional Hindu caste)
:B0X?:targetting::f("targeting") ; Web Freq 4.94 | Fixes 3 words
:B0X?:tempory::f("temporary") ; Web Freq 47.94 | Fixes 6 words
:B0X?:tfull::f("tful") ; Web Freq 19.60 | Fixes 84 words
:B0X?:tfulls::f("tfuls") ; Web Freq 0.01 | Fixes 16 words
:B0X?:thei::f("this") ; Web Freq 3228.53 | Fixes 8 words
:B0X?:thisgs::f("things") ; Web Freq 149.11 | Fixes 40 words
:B0X?:thna::f("than") ; Web Freq 526.82 | Fixes 15 words
:B0X?:throught::f("through") ; Web Freq 346.41 | Fixes 4 words
:B0X?:thyness::f("thiness") ; Web Freq 1.46 | Fixes 34 words
:B0X?:timne::f("time") ; Web Freq 1007.64 | Fixes 66 words
:B0X?:tiome::f("time") ; Web Freq 1007.64 | Fixes 66 words
:B0X?:tionar::f("tionary") ; Web Freq 64.29 | Fixes 83 words
:B0X?:tlied::f("tled") ; Web Freq 50.90 | Fixes 83 words
:B0X?:tolk::f("told") ; Web Freq 58.86 | Fixes 6 words
:B0X?:topry::f("tory") ; Web Freq 814.46 | Fixes 372 words
:B0X?:tority::f("torily") ; Web Freq 1.49 | Fixes 28 words
:B0X?:traing::f("traying") ; Web Freq 0.97 | Fixes 5 words
:B0X?:tricty::f("tricity") ; Web Freq 16.20 | Fixes 18 words
:B0X?:truely::f("truly") ; Web Freq 21.69 | Fixes 2 words
:B0X?:ualy::f("ually") ; Web Freq 256.15 | Fixes 74 words
:B0X?:uarly::f("ularly") ; Web Freq 57.76 | Fixes 69 words
:B0X?:ularily::f("ularly") ; Web Freq 57.76 | Fixes 69 words
:B0X?:ultimely::f("ultimately") ; Web Freq 10.61 | Fixes 2 words
:B0X?:ultsd::f("ulted") ; Web Freq 16.39 | Fixes 17 words
:B0X?:uonly::f("ually") ; Web Freq 256.15 | Fixes 74 words
:B0X?:updn::f("upon") ; Web Freq 115.98 | Fixes 10 words
:B0X?:urchs::f("urches") ; Web Freq 13.54 | Fixes 6 words
:B0X?:usess::f("users") ; Web Freq 154.55 | Fixes 33 words
:B0X?:usionally::f("usionary") ; Web Freq 0.43 | Fixes 6 words
:B0X?:usla::f("usal") ; Web Freq 8.69 | Fixes 26 words, but misspells Gusla (Serbian/Croatian musical instrument)
:B0X?:uslas::f("usals") ; Web Freq 0.21 | Fixes 15 words
:B0X?:ustino::f("ustion") ; Web Freq 4.92 | Fixes 5 words
:B0X?:veill::f("veil") ; Web Freq 2.74 | Fixes 3 words
:B0X?:verval::f("verbal") ; Web Freq 5.67 | Fixes 4 words
:B0X?:vicss::f("vices") ; Web Freq 612.07 | Fixes 13 words
:B0X?:videntally::f("vidently") ; Web Freq 1.93 | Fixes 3 words
:B0X?:volcanoe::f("volcano") ; Web Freq 3.10 | Fixes 3 words
:B0X?:vyed::f("vied") ; Web Freq 1.52 | Fixes 17 words
:B0X?:weath::f("wealth") ; Web Freq 36.79 | Fixes 3 words
:B0X?:weist::f("wiest") ; Web Freq 0.02 | Fixes 17 words
:B0X?:wifes::f("wives") ; Web Freq 12.78 | Fixes 12 words
:B0X?:wille::f("will") ; Web Freq 1361.05 | Fixes 12 words
:B0X?:witten::f("written") ; Web Freq 103.35 | Fixes 13 words
:B0X?:wordly::f("worldly") ; Web Freq 1.30 | Fixes 3 words
:B0X?:workd::f("works") ; Web Freq 171.67 | Fixes 136 words
:B0X?:workh::f("worth") ; Web Freq 108.71 | Fixes 34 words
:B0X?:worl::f("work") ; Web Freq 718.65 | Fixes 141 words
:B0X?:wroet::f("wrote") ; Web Freq 56.76 | Fixes 12 words
:B0X?:xicly::f("xically") ; Web Freq 0.43 | Fixes 8 words
:B0X?:yersa::f("years") ; Web Freq 337.88 | Fixes 3 words
:B0X?:yied::f("ied") ; Web Freq 681.12 | Fixes 633 words
:B0X?:zeist::f("ziest") ; Web Freq 0.24 | Fixes 48 words
:B0X?C*:inmd::f("ind") ; Web Freq 2920.96 | Fixes 1541 words
:B0X?C*:inmg::f("ing") ; Web Freq 18410.23 | Fixes 20290 words
:B0X?C*:inms::f("ins") ; Web Freq 1973.14 | Fixes 2311 words
:B0X?C*:inmt::f("int") ; Web Freq 4566.71 | Fixes 2978 words
:B0X?C:abyy::f("ably") ; Web Freq 115.54 | Fixes 594 words
:B0X?C:acn::f("can") ; Web Freq 1617.29 | Fixes 81 words
:B0X?C:adn::f("and") ; Web Freq 14599.80 | Fixes 361 words
:B0X?C:aitn::f("aith") ; Web Freq 39.27 | Fixes 14 words
:B0X?C:amde::f("made") ; Web Freq 298.03 | Fixes 14 words
:B0X?C:andd::f("and") ; Web Freq 14599.80 | Fixes 361 words
:B0X?C:anim::f("anism") ; Web Freq 28.73 | Fixes 143 words, but misspells minyanim (The quorum required by Jewish law to be present for public worship)
:B0X?C:arey::f("ary") ; Web Freq 1726.13 | Fixes 556 words, but misspells Carey (An American name)
:B0X?C:arys::f("aries") ; Web Freq 114.54 | Fixes 250 words
:B0X?C:asrs::f("ases") ; Web Freq 288.43 | Fixes 384 words
:B0X?C:atn::f("ant") ; Web Freq 1290.80 | Fixes 658 words
:B0X?C:ayd::f("ady") ; Web Freq 246.79 | Fixes 36 words
:B0X?C:ayt::f("ay") ; Web Freq 5691.22 | Fixes 454 words, but misspells bayt (House or Home in Arabic or Hebrew)
:B0X?C:aywa::f("away") ; Web Freq 128.20 | Fixes 38 words
:B0X?C:blly::f("bly") ; Web Freq 186.10 | Fixes 775 words
:B0X?C:bthe::f("b the") ; Fixes 1 word
:B0X?C:btu::f("but") ; Web Freq 1008.28 | Fixes 16 words, case-sensitive for "BTU" (British Thermal Unit)
:B0X?C:bve::f("be") ; Web Freq 5143.23 | Fixes 184 words
:B0X?C:clud::f("clude") ; Web Freq 199.97 | Fixes 6 words
:B0X?C:cthe::f("c the") ; Fixes 1 word
:B0X?C:cys::f("cies") ; Web Freq 246.63 | Fixes 454 words
:B0X?C:daty::f("day") ; Web Freq 1833.75 | Fixes 49 words
:B0X?C:daye::f("date") ; Web Freq 635.09 | Fixes 73 words
:B0X?C:dind::f("ding") ; Web Freq 1817.83 | Fixes 860 words
:B0X?C:dinds::f("dings") ; Web Freq 142.21 | Fixes 188 words
:B0X?C:dng::f("ding") ; Web Freq 1817.83 | Fixes 860 words
:B0X?C:dtae::f("date") ; Web Freq 635.09 | Fixes 73 words
:B0X?C:dthe::f("d the") ; Fixes 1 word
:B0X?C:easm::f("eams") ; Web Freq 70.49 | Fixes 43 words
:B0X?C:efel::f("feel") ; Web Freq 92.05 | Fixes 5 words
:B0X?C:encs::f("ences") ; Web Freq 242.92 | Fixes 358 words
:B0X?C:entt::f("en't") ; Fixes 4 words
:B0X?C:epli::f("eply") ; Web Freq 192.69 | Fixes 3 words
:B0X?C:epyl::f("eply") ; Web Freq 192.69 | Fixes 3 words
:B0X?C:ernt::f("erent") ; Web Freq 191.09 | Fixes 26 words
:B0X?C:esnt::f("esent") ; Web Freq 127.21 | Fixes 8 words
:B0X?C:fiel::f("file") ; Web Freq 449.46 | Fixes 13 words
:B0X?C:fng::f("fing") ; Web Freq 39.11 | Fixes 142 words
:B0X?C:frp,::f("from") ; Web Freq 2276.27 | Fixes 3 words
:B0X?C:fthe::f("f the") ; Fixes 1 word
:B0X?C:fuly::f("fully") ; Web Freq 123.72 | Fixes 200 words
:B0X?C:fyes::f("fies") ; Web Freq 30.66 | Fixes 238 words
:B0X?C:fys::f("fies") ; Web Freq 30.66 | Fixes 238 words
:B0X?C:gred::f("greed") ; Web Freq 31.77 | Fixes 9 words
:B0X?C:gthe::f("g the") ; Fixes 1 word
:B0X?C:gyes::f("gies") ; Web Freq 123.33 | Fixes 441 words
:B0X?C:gys::f("gies") ; Web Freq 123.33 | Fixes 441 words
:B0X?C:hace::f("hare") ; Web Freq 124.57 | Fixes 13 words
:B0X?C:hc::f("ch") ; Web Freq 5218.67 | Fixes 688 words, case-sensitive for "THC"
:B0X?C:hfull::f("hful") ; Web Freq 9.83 | Fixes 33 words
:B0X?C:hge::f("he") ; Web Freq 25278.13 | Fixes 235 words
:B0X?C:hsa::f("has") ; Web Freq 1048.55 | Fixes 102 words
:B0X?C:hsi::f("his") ; Web Freq 3902.14 | Fixes 75 words Case-sensitive to not misspell Hsian (a city in China)
:B0X?C:hte::f("the") ; Web Freq 23146.10 | Fixes 66 words
:B0X?C:hthe::f("h the") ; Fixes 1 word
:B0X?C:ialy::f("ially") ; Web Freq 140.38 | Fixes 254 words, but misspells bialy (Flat crusty-bottomed onion roll)
:B0X?C:icm::f("ism") ; Web Freq 243.08 | Fixes 1440 words
:B0X?C:icms::f("isms") ; Web Freq 25.06 | Fixes 1087 words
:B0X?C:idty::f("dity") ; Web Freq 38.35 | Fixes 78 words
:B0X?C:ign::f("ing") ; Web Freq 16429.32 | Fixes 15383 words, but misspells a bunch (which are nullified above)
:B0X?C:ilny::f("inly") ; Web Freq 45.60 | Fixes 18 words
:B0X?C:inm::f("in") ; Web Freq 28891.45 | Fixes 1659 words
:B0X?C:ipyl::f("iply") ; Web Freq 2.87 | Fixes 4 words
:B0X?C:isio::f("ision") ; Web Freq 329.23 | Fixes 36 words
:B0X?C:itiy::f("ity") ; Web Freq 3125.75 | Fixes 2203 words
:B0X?C:itoy::f("itory") ; Web Freq 37.00 | Fixes 27 words
:B0X?C:itr::f("it") ; Web Freq 7355.44 | Fixes 528 words
:B0X?C:ixts::f("ists") ; Web Freq 324.16 | Fixes 1602 words
:B0X?C:izm::f("ism") ; Web Freq 243.08 | Fixes 1440 words
:B0X?C:izms::f("isms") ; Web Freq 25.06 | Fixes 1087 words
:B0X?C:jutt::f("just") ; Web Freq 473.30 | Fixes 9 words
:B0X?C:kc::f("ck") ; Web Freq 3675.42 | Fixes 910 words, but misspells kc (thousand per second)
:B0X?C:kcer::f("cker") ; Web Freq 95.50 | Fixes 159 words
:B0X?C:kcs::f("cks") ; Web Freq 394.56 | Fixes 741 words, but misspells kcs (thousands per second)
:B0X?C:kcy::f("cky") ; Web Freq 74.41 | Fixes 92 words
:B0X?C:kn::f("nk") ; Web Freq 1016.95 | Fixes 229 words
:B0X?C:kng::f("king") ; Web Freq 1467.04 | Fixes 815 words
:B0X?C:kthe::f("k the") ; Fixes 1 word
:B0X?C:laly::f("ally") ; Web Freq 1138.83 | Fixes 2642 words
:B0X?C:litn::f("lith") ; Web Freq 1.51 | Fixes 39 words
:B0X?C:lonly::f("lonely") ; Web Freq 7.57 | Fixes 2 words
:B0X?C:lsit::f("list") ; Web Freq 575.17 | Fixes 332 words
:B0X?C:lthe::f("l the") ; Fixes 1 word
:B0X?C:lwats::f("lways") ; Web Freq 130.69 | Fixes 9 words
:B0X?C:lyu::f("ly") ; Web Freq 5937.82 | Fixes 9887 words
:B0X?C:mitn::f("mith") ; Web Freq 137.12 | Fixes 23 words
:B0X?C:moee::f("more") ; Web Freq 3145.04 | Fixes 34 words
:B0X?C:mpley::f("mply") ; Web Freq 79.77 | Fixes 14 words
:B0X?C:mpli::f("mply") ; Web Freq 79.77 | Fixes 14 words, but misspells fait accompli (An irreversible accomplishment)
:B0X?C:mpyl::f("mply") ; Web Freq 79.77 | Fixes 14 words
:B0X?C:mthe::f("m the") ; Fixes 1 word
:B0X?C:myes::f("mies") ; Web Freq 22.21 | Fixes 261 words
:B0X?C:nig::f("ing") ; Web Freq 16429.32 | Fixes 15383 words, but misspells Koenig (A German surname), pfennig (100 pfennigs formerly equaled 1 Deutsche Mark in Germany)
:B0X?C:nsly::f("nsely") ; Web Freq 3.08 | Fixes 7 words
:B0X?C:nsof::f("ns of") ; Fixes 1 word
:B0X?C:nsur::f("nsure") ; Web Freq 70.22 | Fixes 11 words
:B0X?C:ntay::f("ntary") ; Web Freq 87.74 | Fixes 39 words
:B0X?C:nyed::f("nied") ; Web Freq 19.95 | Fixes 26 words
:B0X?C:nys::f("nies") ; Web Freq 147.51 | Fixes 249 words, but misspells Erinys (an ancient Greek goddess of vengeance)
:B0X?C:olgy::f("ology") ; Web Freq 500.09 | Fixes 389 words
:B0X?C:oloo::f("ollo") ; Web Freq 11.02 | Fixes 6 words
:B0X?C:omst::f("most") ; Web Freq 490.12 | Fixes 47 words
:B0X?C:onw::f("one") ; Web Freq 2150.54 | Fixes 476 words
:B0X?C:ooes::f("oos") ; Web Freq 10.09 | Fixes 94 words
:B0X?C:otu::f("out") ; Web Freq 2371.37 | Fixes 159 words, but misspells motu proprio (Legal term for 'of one's own accord')
:B0X?C:pich::f("pitch") ; Web Freq 9.80 | Fixes 4 words
:B0X?C:ppli::f("pply") ; Web Freq 150.15 | Fixes 11 words
:B0X?C:ppyl::f("pply") ; Web Freq 150.15 | Fixes 11 words
:B0X?C:pthe::f("p the") ; Fixes 1 word
:B0X?C:pys::f("pies") ; Web Freq 48.59 | Fixes 161 words, but misspells Pepys (17th century English diary writer)
:B0X?C:ragn::f("rang") ; Web Freq 4.08 | Fixes 18 words
:B0X?C:ragne::f("range") ; Web Freq 233.55 | Fixes 19 words
:B0X?C:raly::f("rally") ; Web Freq 81.33 | Fixes 130 words
:B0X?C:redd::f("red") ; Web Freq 1910.84 | Fixes 1461 words, but misspells Redd (noun, verb - Fish spawn area; to clean)
:B0X?C:riey::f("riety") ; Web Freq 51.47 | Fixes 9 words
:B0X?C:sasy::f("says") ; Web Freq 119.86 | Fixes 16 words
:B0X?C:sice::f("sive") ; Web Freq 269.94 | Fixes 207 words, but misspells sice (The number six at dice)
:B0X?C:sinn::f("sign") ; Web Freq 522.91 | Fixes 22 words
:B0X?C:sntt::f("sn't") ; Fixes 4 words
:B0X?C:sthe::f("s the") ; Fixes 1 word
:B0X?C:stpo::f("stop") ; Web Freq 79.83 | Fixes 13 words
:B0X?C:strat::f("start") ; Web Freq 167.61 | Fixes 9 words
:B0X?C:struced::f("structed") ; Web Freq 16.54 | Fixes 14 words
:B0X?C:sys::f("sies") ; Web Freq 12.83 | Fixes 113 words
:B0X?C:t eh::f("the") ; Web Freq 23146.10 | Fixes 66 words
:B0X?C:teh::f("the") ; Web Freq 23146.10 | Fixes 66 words
:B0X?C:theh::f("the") ; Web Freq 23146.10 | Fixes 66 words
:B0X?C:thh::f("th") ; Web Freq 6605.70 | Fixes 615 words
:B0X?C:thn::f("then") ; Web Freq 378.71 | Fixes 15 words
:B0X?C:thne::f("then") ; Web Freq 378.71 | Fixes 15 words
:B0X?C:thw::f("the") ; Web Freq 23146.10 | Fixes 66 words
:B0X?C:tiem::f("time") ; Web Freq 1007.64 | Fixes 66 words
:B0X?C:tioj::f("tion") ; Web Freq 9627.87 | Fixes 3690 words
:B0X?C:tng::f("ting") ; Web Freq 3118.58 | Fixes 3045 words
:B0X?C:toyr::f("tory") ; Web Freq 814.46 | Fixes 372 words
:B0X?C:tust::f("trust") ; Web Freq 59.35 | Fixes 8 words
:B0X?C:twon::f("town") ; Web Freq 235.49 | Fixes 45 words
:B0X?C:tyo::f("to") ; Web Freq 13157.06 | Fixes 279 words
:B0X?C:urnk::f("runk") ; Web Freq 22.86 | Fixes 9 words
:B0X?C:utino::f("ution") ; Web Freq 397.42 | Fixes 68 words
:B0X?C:verd::f("vered") ; Web Freq 94.85 | Fixes 48 words, but misspells verd (A dark green impure marble)
:B0X?C:vly::f("vely") ; Web Freq 141.26 | Fixes 567 words, but misspells vly (uncommon English word for a shallow marsh or wet meadow)
:B0X?C:vyes::f("vies") ; Web Freq 194.03 | Fixes 39 words
:B0X?C:vys::f("vies") ; Web Freq 194.03 | Fixes 39 words, but misspells Davys (Common English surname)
:B0X?C:wass::f("was") ; Web Freq 1484.45 | Fixes 25 words
:B0X?C:wasy::f("ways") ; Web Freq 224.96 | Fixes 150 words
:B0X?C:weas::f("was") ; Web Freq 1484.45 | Fixes 25 words
:B0X?C:witn::f("with") ; Web Freq 3185.45 | Fixes 8 words
:B0X?C:wthe::f("w the") ; Fixes 1 word
:B0X?C:wya::f("way") ; Web Freq 632.13 | Fixes 167 words
:B0X?C:wyas::f("ways") ; Web Freq 224.96 | Fixes 150 words
:B0X?C:xthe::f("x the") ; Fixes 1 word
:B0X?C:xys::f("xies") ; Web Freq 5.90 | Fixes 39 words
:B0X?C:ywat::f("yway") ; Web Freq 25.17 | Fixes 8 words
:B0X?C:zys::f("zies") ; Web Freq 0.33 | Fixes 21 words
:B0XC*?:asttr::f("astr") ; Web Freq 90.94 | Fixes 334 words 
:B0XC*?:bsttr::f("bstr") ; Web Freq 79.67 | Fixes 95 words 
:B0XC*?:dsttr::f("dstr") ; Web Freq 2.96 | Fixes 19 words 
:B0XC*?:eosttr::f("eostr") ; Web Freq 0.11 | Fixes 12 words
:B0XC*?:esttr::f("estr") ; Web Freq 165.39 | Fixes 438 words 
:B0XC*?:iosttr::f("iostr") ; Web Freq 0.12 | Fixes 9 words
:B0XC*?:isttr::f("istr") ; Web Freq 628.59 | Fixes 375 words 
:B0XC*?:ksttr::f("kstr") ; Web Freq 3.33 | Fixes 18 words 
:B0XC*?:loevs::f("loves") ; Web Freq 25.44 | Fixes 21 words
:B0XC*?:losttr::f("lostr") ; Web Freq 0.85 | Fixes 6 words
:B0XC*?:msttr::f("mstr") ; Web Freq 8.92 | Fixes 11 words 
:B0XC*?:nosttr::f("nostr") ; Web Freq 1.55 | Fixes 11 words
:B0XC*?:nsttr::f("nstr") ; Web Freq 436.43 | Fixes 309 words 
:B0XC*?:osttre::f("ostre") ; Web Freq 0.15 | Fixes 11 words
:B0XC*?:psttr::f("pstr") ; Web Freq 4.70 | Fixes 12 words 
:B0XC*?:rosttr::f("rostr") ; Web Freq 1.49 | Fixes 29 words
:B0XC*?:rsttr::f("rstr") ; Web Freq 2.74 | Fixes 104 words 
:B0XC*?:sttrab::f("strab") ; Web Freq 0.89 | Fixes 17 words
:B0XC*?:sttrac::f("strac") ; Web Freq 72.98 | Fixes 103 words
:B0XC*?:sttrad::f("strad") ; Web Freq 3.24 | Fixes 26 words
:B0XC*?:sttrag::f("strag") ; Web Freq 0.82 | Fixes 20 words
:B0XC*?:sttrai::f("strai") ; Web Freq 87.57 | Fixes 129 words
:B0XC*?:sttral::f("stral") ; Web Freq 168.74 | Fixes 64 words
:B0XC*?:sttrap::f("strap") ; Web Freq 21.25 | Fixes 50 words
:B0XC*?:sttrar::f("strar") ; Web Freq 9.36 | Fixes 2 words
:B0XC*?:sttras::f("stras") ; Web Freq 2.33 | Fixes 11 words
:B0XC*?:sttrat::f("strat") ; Web Freq 489.29 | Fixes 276 words
:B0XC*?:sttrav::f("strav") ; Web Freq 0.59 | Fixes 12 words
:B0XC*?:sttraw::f("straw") ; Web Freq 10.20 | Fixes 24 words
:B0XC*?:sttray::f("stray") ; Web Freq 3.39 | Fixes 11 words
:B0XC*?:sttree::f("stree") ; Web Freq 169.84 | Fixes 43 words
:B0XC*?:sttrei::f("strei") ; Web Freq 0.89 | Fixes 2 words
:B0XC*?:sttrel::f("strel") ; Web Freq 1.37 | Fixes 29 words
:B0XC*?:sttren::f("stren") ; Web Freq 52.14 | Fixes 23 words
:B0XC*?:sttrep::f("strep") ; Web Freq 2.52 | Fixes 35 words
:B0XC*?:sttres::f("stres") ; Web Freq 50.32 | Fixes 84 words
:B0XC*?:sttret::f("stret") ; Web Freq 21.96 | Fixes 45 words
:B0XC*?:sttrew::f("strew") ; Web Freq 0.54 | Fixes 23 words
:B0XC*?:sttrib::f("strib") ; Web Freq 145.31 | Fixes 45 words
:B0XC*?:sttric::f("stric") ; Web Freq 192.90 | Fixes 121 words
:B0XC*?:sttrid::f("strid") ; Web Freq 4.61 | Fixes 48 words
:B0XC*?:sttrie::f("strie") ; Web Freq 41.51 | Fixes 49 words
:B0XC*?:sttrif::f("strif") ; Web Freq 1.27 | Fixes 6 words
:B0XC*?:sttrik::f("strik") ; Web Freq 34.93 | Fixes 42 words
:B0XC*?:sttrin::f("strin") ; Web Freq 72.63 | Fixes 101 words
:B0XC*?:sttrio::f("strio") ; Web Freq 1.19 | Fixes 18 words
:B0XC*?:sttrip::f("strip") ; Web Freq 50.52 | Fixes 62 words
:B0XC*?:sttriv::f("striv") ; Web Freq 8.52 | Fixes 17 words
:B0XC*?:sttro::f("stro") ; Web Freq 218.52 | Fixes 526 words 
:B0XC*?:sttru::f("stru") ; Web Freq 582.14 | Fixes 440 words 
:B0XC*?:sttry::f("stry") ; Web Freq 264.90 | Fixes 62 words 
:B0XC*?:tosttr::f("tostr") ; Web Freq 0.10 | Fixes 10 words
:B0XC*?:tsttr::f("tstr") ; Web Freq 4.69 | Fixes 43 words 
:B0XC*?:usttr::f("ustr") ; Web Freq 516.57 | Fixes 183 words 
:B0XC*?:wsttr::f("wstr") ; Web Freq 0.79 | Fixes 7 words 
:B0XC*?:ysttr::f("ystr") ; Web Freq 2.33 | Fixes 23 words 
:B0XC:ASS::f("ADD") ; Web Freq 774.46 | Fixes 2 words, Case-sensitive to fix acronym, but not word.
:B0XC:Danial::f("Daniel") ; Web Freq 29.68 | Fixes 1 word
:B0XC:Im::f("I'm") ; Fixes 1 word
:B0XC:Ruch::f("Ruth", 0) ; Web Freq 8.56 | Fixes 2 words 
:B0XC:SVA::f("SBA") ; Web Freq 1.94 | Fixes 1 word
:B0XC:abel::f("able") ; Web Freq 109.39 | Fixes 1 word, but misspells Abel (A Norwegian mathematician)
:B0XC:alos::f("also") ; Web Freq 616.83 | Fixes 1 word
:B0XC:amin::f("main") ; Web Freq 199.62 | Fixes 1 word, Case-sensitive to not misspell Amin (A common Middle Eastern name)
:B0XC:araa::f("area") ; Web Freq 259.87 | Fixes 1 word
:B0XC:atht::f("that") ; Web Freq 3400.03 | Fixes 1 word
:B0XC:chante::f("change") ; Web Freq 210.60 | Fixes 1 word ; Case-sensitive to not misspell name.
:B0XC:copt::f("copy") ; Web Freq 79.62 | Fixes 1 word, Case-sensitive, to not misspell Copt, An ancient Egyptian descendent.
:B0XC:danial::f("denial") ; Web Freq 6.16 | Fixes 1 word
:B0XC:ect::f("etc") ; Web Freq 51.53 | Fixes 1 word, case-sensitive for protect ECT (Electroconvulsive therapy)
:B0XC:evan::f("even") ; Web Freq 245.70 | Fixes 1 word
:B0XC:eyt::f("yet") ; Web Freq 123.16 | Fixes 1 word
:B0XC:ihs::f("his") ; Web Freq 660.18 | Fixes 1 word
:B0XC:indo::f("into", 0) ; Web Freq 445.32 | Fixes 1 word 
:B0XC:iss::f("is") ; Web Freq 14117.23 | Fixes 3 words Case-sensitive to not misspell ISS (in-school suspension, international spacestation)
:B0XC:ist::f("it") ; Web Freq 5626.33 | Fixes 2 words
:B0XC:loev::f("love") ; Web Freq 201.06 | Fixes 1 word
:B0XC:may of::f("may have") ; Fixes 1 word
:B0XC:nad::f("and") ; Web Freq 12997.64 | Fixes 1 word, but misspells nad (Slang for testical)
:B0XC:noe::f("now") ; Web Freq 611.39 | Fixes 1 word
:B0XC:noth::f("north") ; Web Freq 435.62 | Fixes 2 words
:B0XC:ocur::f("occur") ; Web Freq 24.68 | Fixes 1 word
:B0XC:okat::f("okay") ; Web Freq 15.37 | Fixes 1 word
:B0XC:snf::f("and") ; Web Freq 12997.64 | Fixes 1 word
:B0XC:tepe::f("type") ; Web Freq 272.34 | Fixes 1 word
:B0XC:tha::f("the") ; Web Freq 23135.85 | Fixes 1 word
:B0XC:thes::f("this") ; Web Freq 3228.47 | Fixes 1 word ; Will it break "the" ?
:B0XC:thi::f("this") ; Web Freq 3228.47 | Fixes 1 word
:B0XC:thit::f("that") ; Web Freq 3400.03 | Fixes 1 word ; will it break "this" ?
:B0XC:thr::f("the") ; Web Freq 23135.85 | Fixes 1 word
:B0XC:thru::f("through") ; Web Freq 342.37 | Fixes 1 word, but misspells thru (Common slang)
:B0XC:ths::f("the") ; Web Freq 23135.85 | Fixes 1 word
:B0XC:tra::f("try") ; Web Freq 114.38 | Fixes 1 word
:B0XC:wou::f("you") ; Web Freq 2996.18 | Fixes 1 word

; ============== End of main list ====================
; Experimental: Turn off option (Z).  Turning it off allows a single char press 
; to simultaneously match the end of one trigger and the beginning of another. 
#Hotstring Z0

; MARK: a ---> an fixes
:B0X*:a ab::f("an ab") ; Fixes 1 word
:B0X*:a ac::f("an ac") ; Fixes 1 word
:B0X*:a ad::f("an ad") ; Fixes 1 word
:B0X*:a af::f("an af") ; Fixes 1 word
:B0X*:a ag::f("an ag") ; Fixes 1 word
:B0X*:a al::f("an al") ; Fixes 1 word
:B0X*:a am::f("an am") ; Fixes 1 word
:B0X*:a ap::f("an ap") ; Fixes 1 word
:B0X*:a as::f("an as") ; Fixes 1 word
:B0X*:a av::f("an av") ; Fixes 1 word
:B0X*:a aw::f("an aw") ; Fixes 1 word
:B0X*:a ea::f("an ea") ; Fixes 1 word
:B0X*:a ef::f("an ef") ; Fixes 1 word
:B0X*:a ei::f("an ei") ; Fixes 1 word
:B0X*:a el::f("an el") ; Fixes 1 word
:B0X*:a em::f("an em") ; Fixes 1 word
:B0X*:a en::f("an en") ; Fixes 1 word
:B0X*:a ep::f("an ep") ; Fixes 1 word
:B0X*:a eq::f("an eq") ; Fixes 1 word
:B0X*:a es::f("an es") ; Fixes 1 word
:B0X*:a et::f("an et") ; Fixes 1 word
:B0X*:a ex::f("an ex") ; Fixes 1 word
:B0X*:a ic::f("an ic") ; Fixes 1 word
:B0X*:a id::f("an id") ; Fixes 1 word
:B0X*:a ig::f("an ig") ; Fixes 1 word
:B0X*:a il::f("an il") ; Fixes 1 word
:B0X*:a im::f("an im") ; Fixes 1 word
:B0X*:a ir::f("an ir") ; Fixes 1 word
:B0X*:a is::f("an is") ; Fixes 1 word
:B0X*:a oa::f("an oa") ; Fixes 1 word
:B0X*:a ob::f("an ob") ; Fixes 1 word
:B0X*:a oi::f("an oi") ; Fixes 1 word
:B0X*:a ol::f("an ol") ; Fixes 1 word
:B0X*:a op::f("an op") ; Fixes 1 word
:B0X*:a or::f("an or") ; Fixes 1 word
:B0X*:a os::f("an os") ; Fixes 1 word
:B0X*:a ot::f("an ot") ; Fixes 1 word
:B0X*:a ov::f("an ov") ; Fixes 1 word
:B0X*:a ow::f("an ow") ; Fixes 1 word
:B0X*:a ud::f("an ud") ; Fixes 1 word
:B0X*:a ug::f("an ug") ; Fixes 1 word
:B0X*:a ul::f("an ul") ; Fixes 1 word
:B0X*:a um::f("an um") ; Fixes 1 word
:B0X*:a up::f("an up") ; Fixes 1 word
:B0X*C:a an::f("an an") ; Fixes 1 word
:B0X*C:a in::f("an in") ; Fixes 1 word

; MARK: Cap Fixes
;-------------------------------------------------------------------------------
; Strings for fixing sentence initial caps. Inspired by rkingett 2-7-2025.
; The below will automatically capitalize words at the start of sentences.  
; It is noteworthy that these are each flagged with "Fixes 1 word."  But depending
; how you look at it, you could argue that each of the below sets fixes ANY/EVERY word!
; There are 3 sets, and the current word list has 249k items, so about 747k.
;-------------------------------------------------------------------------------
:B0X*?C:!  a::f("!  A") ; Fixes 1 word
:B0X*?C:!  b::f("!  B") ; Fixes 1 word
:B0X*?C:!  c::f("!  C") ; Fixes 1 word
:B0X*?C:!  d::f("!  D") ; Fixes 1 word
:B0X*?C:!  e::f("!  E") ; Fixes 1 word
:B0X*?C:!  f::f("!  F") ; Fixes 1 word
:B0X*?C:!  h::f("!  H") ; Fixes 1 word
:B0X*?C:!  i::f("!  I") ; Fixes 1 word
:B0X*?C:!  j::f("!  J") ; Fixes 1 word
:B0X*?C:!  k::f("!  K") ; Fixes 1 word
:B0X*?C:!  l::f("!  L") ; Fixes 1 word
:B0X*?C:!  m::f("!  M") ; Fixes 1 word
:B0X*?C:!  n::f("!  N") ; Fixes 1 word
:B0X*?C:!  p::f("!  P") ; Fixes 1 word
:B0X*?C:!  q::f("!  Q") ; Fixes 1 word
:B0X*?C:!  r::f("!  R") ; Fixes 1 word
:B0X*?C:!  s::f("!  S") ; Fixes 1 word
:B0X*?C:!  t::f("!  T") ; Fixes 1 word
:B0X*?C:!  u::f("!  U") ; Fixes 1 word
:B0X*?C:!  v::f("!  V") ; Fixes 1 word
:B0X*?C:!  w::f("!  W") ; Fixes 1 word
:B0X*?C:!  x::f("!  X") ; Fixes 1 word
:B0X*?C:!  y::f("!  Y") ; Fixes 1 word
:B0X*?C:!  z::f("!  Z") ; Fixes 1 word
:B0X*?C:.  a::f(".  A") ; Fixes 1 word
:B0X*?C:.  b::f(".  B") ; Fixes 1 word
:B0X*?C:.  c::f(".  C") ; Fixes 1 word
:B0X*?C:.  f::f(".  F") ; Fixes 1 word
:B0X*?C:.  g::f(".  G") ; Fixes 1 word
:B0X*?C:.  h::f(".  H") ; Fixes 1 word
:B0X*?C:.  i::f(".  I") ; Fixes 1 word
:B0X*?C:.  j::f(".  J") ; Fixes 1 word
:B0X*?C:.  k::f(".  K") ; Fixes 1 word
:B0X*?C:.  l::f(".  L") ; Fixes 1 word
:B0X*?C:.  m::f(".  M") ; Fixes 1 word
:B0X*?C:.  n::f(".  N") ; Fixes 1 word
:B0X*?C:.  o::f(".  O") ; Fixes 1 word
:B0X*?C:.  p::f(".  P") ; Fixes 1 word
:B0X*?C:.  q::f(".  Q") ; Fixes 1 word
:B0X*?C:.  r::f(".  R") ; Fixes 1 word
:B0X*?C:.  s::f(".  S") ; Fixes 1 word
:B0X*?C:.  t::f(".  T") ; Fixes 1 word
:B0X*?C:.  u::f(".  U") ; Fixes 1 word
:B0X*?C:.  v::f(".  V") ; Fixes 1 word
:B0X*?C:.  w::f(".  W") ; Fixes 1 word
:B0X*?C:.  x::f(".  X") ; Fixes 1 word
:B0X*?C:.  y::f(".  Y") ; Fixes 1 word
:B0X*?C:.  z::f(".  Z") ; Fixes 1 word
:B0X*?C:?  a::f("?  A") ; Fixes 1 word
:B0X*?C:?  b::f("?  B") ; Fixes 1 word
:B0X*?C:?  c::f("?  C") ; Fixes 1 word
:B0X*?C:?  d::f("?  D") ; Fixes 1 word
:B0X*?C:?  e::f("?  E") ; Fixes 1 word
:B0X*?C:?  f::f("?  F") ; Fixes 1 word
:B0X*?C:?  g::f("?  G") ; Fixes 1 word
:B0X*?C:?  h::f("?  H") ; Fixes 1 word
:B0X*?C:?  i::f("?  I") ; Fixes 1 word
:B0X*?C:?  k::f("?  K") ; Fixes 1 word
:B0X*?C:?  l::f("?  L") ; Fixes 1 word
:B0X*?C:?  m::f("?  M") ; Fixes 1 word
:B0X*?C:?  o::f("?  O") ; Fixes 1 word
:B0X*?C:?  p::f("?  P") ; Fixes 1 word
:B0X*?C:?  q::f("?  Q") ; Fixes 1 word
:B0X*?C:?  r::f("?  R") ; Fixes 1 word
:B0X*?C:?  s::f("?  S") ; Fixes 1 word
:B0X*?C:?  t::f("?  T") ; Fixes 1 word
:B0X*?C:?  u::f("?  U") ; Fixes 1 word
:B0X*?C:?  v::f("?  V") ; Fixes 1 word
:B0X*?C:?  w::f("?  W") ; Fixes 1 word
:B0X*?C:?  x::f("?  X") ; Fixes 1 word
:B0X*?C:?  y::f("?  Y") ; Fixes 1 word
:B0X*?C:?  z::f("?  Z") ; Fixes 1 word

#Hotstring Z ; Turn off trigger overlap option. 

;============== Determine end line of autocorrect items ======================
; Please don't change the "ACitemsEndAt := A_LineNumber - 3" it is used by several scripts. 
ACitemsEndAt := A_LineNumber - 3 ; hh2 validity checks will skip lines after here. 

; MARK: Dates
;-------------------------------------------------------------------------------
;  Capitalize dates
;-------------------------------------------------------------------------------

:B0XC:april::f("April")
:B0XC:august::f("August")
:B0XC:december::f("December")
:B0XC:february::f("February")
:B0XC:friday::f("Friday")
:B0XC:in march::f("in March")
:B0XC:in may::f("in May")
:B0XC:january::f("January")
:B0XC:july::f("July")
:B0XC:june::f("June")
:B0XC:monday::f("Monday")
:B0XC:november::f("November")
:B0XC:october::f("October")
:B0XC:saturday::f("Saturday")
:B0XC:september::f("September")
:B0XC:sunday::f("Sunday")
:B0XC:thursday::f("Thursday")
:B0XC:tuesday::f("Tuesday")
:B0XC:until march::f("until March")
:B0XC:until may::f("until May")
:B0XC:wednesday::f("Wednesday")

; MARK: Alpha Lists
; Just some alphabetical lists of things.
:B0X:;alpha::f("Alpha`nBravo`nCharlie`nDelta`nEcho`nFoxtrot`nGolf`nHotel`nIndia`nJuliett`nKilo`nLima`nMike`nNovember`nOscar`nPapa`nQuebec`nRomeo`nSierra`nTango`nUniform`nVictor`nWhiskey`nX-ray`nYankee`nZulu", 0, 1)
:B0X:;fruits::f("Apple`nBanana`nCarrot`nDate`nEggplant`nFig`nGrape`nHoneydew`nIceberg lettuce`nJalapeno`nKiwi`nLemon`nMango`nNectarine`nOrange`nPapaya`nQuince`nRadish`nStrawberry`nTomato`nUgli fruit`nVanilla bean`nWatermelon`nXigua`nYellow pepper`nZucchini", 0, 1) 
:B0X:;animals::f("Aardvark`nButterfly`nCheetah`nDolphin`nElephant`nFrog`nGiraffe`nHippo`nIguana`nJaguar`nKangaroo`nLion`nMonkey`nNarwhal`nOwl`nPenguin`nQuail`nRabbit`nSnake`nTiger`nUmbrellabird`nVulture`nWolf`nX-ray fish`nYak`nZebra", 0, 1) 
:B0X:;colors::f("Amber`nBlue`nCrimson`nDenim`nEmerald`nFuchsia`nGold`nHarlequin`nIndigo`nJade`nKhaki`nLavender`nMagenta`nNavy`nOlive`nPink`nQuartz`nRed`nScarlet`nTurquoise`nUltramarine`nViolet`nWhite`nXanadu`nYellow`nZaffre", 0, 1)

;################################################
; MARK: Custom
;-------------------------------------------------------------------------------
; Anything below this point was added to the script by the user via the Win+H hotkey.
;-------------------------------------------------------------------------------

; This comment is the only 11-23-2026 update to this file.  Added for debugging the Updater.ahk tool. 