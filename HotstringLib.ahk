#SingleInstance
#Requires AutoHotkey v2+
; Library of HotStrings for AutoCorrect2.
; Library updated 11-28-2024

;###############################################
; ; Two hotstrings for testing keyboard input buffering (or lack thereof).
;:B0X*?:po::f("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
;:B0X*?:iu::f("ooooooooooooooooooooooooooooooooooooooooooooooooo")

; ===== Trigger strings to nullify the potential misspellings that are indicated. ======
; Used the word "corrects" in place of fix to avoid double-counting these as potential fixes. 
:B0*:horror:: ; Here for :?*:orror::error, whitch corrects 56 words.
:B0:Savitr:: ; (Important Hindu god) Here for :?:itr::it, which corrects 366 words.
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
:B0:feign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:indign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:kc:: ; (thousand per second). Here for :?:kc::ck, which corrects 610 words.
:B0:malign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:miliary:: ; Here for :?:miliary::military, which corrects 4 words.
:B0:minyanim:: ; (The quorum required by Jewish law to be present for public worship) Here for :?:anim::anism, which corrects 123 words.
:B0:pfennig:: ; (100 pfennigs formerly equaled 1 DeutscheÂ Mark in Germany). Here for :?:nig::ing, which corrects 11414 words.
:B0:reign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:sice:: ; (The number six at dice) Here for :?:sice::sive, which corrects 166 words.
:B0:sign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0:verisign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:align:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:assign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:benign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:campaign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:design:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:foreign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:resign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0?:sovereign:: ; Here for :?:ign::ing, which corrects 11384 words.
:B0C:AutoCorrect:: ; Here for :B0X*:rre::f("re") ; which correct 8199 words. But... Is is needed?  

/*
Unfortunately, it doesn't work if the multi-fix item has :*: in the options.  So these can't be nullified.  
If you hope to ever type any of these words, locate the corresponding autocorrect item and delete it. 
:B0:Ahvenanmaa:: ; also :Jahvey:, :Wahvey:, :Yahve:, :Yahveh: (Hebrew names for God.) Here for :?*:ahve::have, which corrects 47 words.
:B0:Basra:: ; (An oil city in Iraq) Here for :?*:asr::ase, which corrects 698 words.
:B0:Datapoint:: ; For username Datapoint. Here for :?*:apoint::appoint, which corrects 30 words.
:B0:Dennstaedtia:: ; (fern), Hoffmannsthal, (poet) Here for :?*:nnst::nst, which corrects 729 words.
:B0:Gadiformes:: ; (Cods, haddocks, grenadiers) Here for :?*:adif::atif, which corrects 50 words.
:B0:Illecebrum:: ; (Species of plan in Europe) Here for :?*:lece::lesce, which corrects 52 words.
:B0:Mephitinae:: ; (skunk), also :neritina: (snail) Here for :?*:itina::itiona, which corrects 79 words.
:B0:Minkowski:: ; (German mathematician) Here for :?*:nkow::know, which corrects 66 words.
:B0:Mulloidichthys:: ; a genus of Mullidae. Here for :*:dicht::dichot, which corrects 18 words.
:B0:Ondaatje:: ; (Canadian writer) Here for :?*:tje::the, which corrects 2176 words.
:B0:Phalangiidae:: ; (type of Huntsman spider) Here for :?*:giid::good, which corrects 31 words.
:B0:Prosecco:: ; (Italian wine) and recco (abbrev. for Reconnaissance) Here for :?*:ecco::eco, which corrects 994 words.
:B0:Pycnanthemum:: ; (mint), and Tridacna (giant clam).+ Here for :?*:cna::can, which corrects 1019 words.
:B0:Scincella:: ; (A reptile genus of Scincidae) Here for :?*:scince::science, which corrects 25 words.
:B0:Scirpus:: ; (Rhizomatous perennial grasslike herbs) Here for :?*:cirp::crip, which corrects 126 words.
:B0:Taoiseach:: ; (The prime minister of the Irish Republic) Here for :?*:seach::search, which corrects 25 words.
:B0:accroides:: ; (An alcohol-soluble resin) Here for :?*:accro::acro, which corrects 145 words.
:B0:ammeter:: ; (electrician's tool). Here for :*:amme::ame, which corrects 341 words.
:B0:braaivleis:: ; (Type of S. Affrican BBQ) Here for :?*:ivle::ivel, which corrects 589 words.
:B0:brodiaea:: ; (a type of plant) Here for :?*:brod::broad, which corrects 55 words.
:B0:ceviche:: ; (South American seafood dish) Here for :?*:cev::ceiv, which corrects 82 words.
:B0:darshan:: ; ((Hinduism - being in the presence of the divine or holy person or image) Here for :?*:rshan::rtion, which corrects 84 words.
:B0:emcee:: ; (host at formal occasion) Here for :?*:emce::ence, which corrects 775 words.
:B0:gaol:: ; British spelling of jail Here for :*:gaol::goal, which corrects 22 words.
:B0:grama:: ; (Pasture grass of plains of South America and western North America) Here for :?*:grama::gramma, which corrects 72 words.
:B0:indite:: ; (Produce a literaryÂ work) Here for :?*:indite::indict, which corrects 22 words.
:B0:itraconazole:: ; (Antifungal drug). Here for :*:itr::it, which corrects 101 words.
:B0:lisente:: ; (100 lisente equal 1 loti in Lesotho, S. Afterica) Here for :?*:lisen::licen, which corrects 34 words.
:B0:pemphigous:: ; (a skin disease) Here for :?*:igous::igious, which corrects 23 words.
:B0:seviche:: ; (South American dish of raw fish) Here for :?*:sevic::servic, which corrects 25 words.
:B0:spritual:: ; (A light spar that crosses a fore-and-aft sail diagonally) Here for :?*:spritual::spiritual, which corrects 31 words.Ne
:B0:spycatcher:: ; (secret spy stuff) Here for :?*:spyc::psyc, which corrects 192 words.
:B0:unfeasable:: ; (archaic, no longer used) Here for :?*:feasable::feasible, which corrects 11 words.
:B0:vicomte:: ; (French nobleman) Here for :?*C:comt::cont, which corrects 587 words.
*/
{	return  ; This makes the above hotstrings do nothing so that they override the indicated rules below.
} ; ===== End of nullifier strings ==================

#Hotstring Z ; The Z causes the end char to be reset after each activation and helps prevent a zombie outbreak. 

;===============================================================================
; When considering "conflicting" hotstrings, remember that sometimes conflicting
; autocorrect items can peacefully coexist... Read more in pdf manual, here
; https://github.com/kunkel321/AutoCorrect2
; The below "Don't Sort Items" Are "word beginning" matches to items in the main
; list and are supersets of the main list items.  Therefore, they must appear before
; the corresponding items in the main list.  It is okay to sort this sublist, but 
; do NOT combine these items with the main list.
; ===== Beginning of Don't Sort items ==========
:B0X*:eyte::f("eye") ; Fixes 109 words
:B0X*:inteh::f("in the") ; Fixes 1 word
:B0X*:ireleven::f("irrelevan") ; Fixes 6 words
:B0X*:managerial reign::f("managerial rein") ; Fixes 2 word
:B0X*:minsitr::f("ministr") ; Fixes 6 words
:B0X*:peculure::f("peculiar") ; Fixes 5 words
:B0X*:presed::f("presid") ; Fixes 18 words
:B0X*:recommed::f("recommend") ; Fixes 12 words
:B0X*:thge::f("the") ; Fixes 402 words
:B0X*:thsi::f("this") ; Fixes 7 words
:B0X*:unkow::f("unknow") ; Fixes 14 words
:B0X*?:abotu::f("about") ; Fixes 37 words
:B0X*?:allign::f("align") ; Fixes 41 words
:B0X*?:arign::f("aring") ; Fixes 140 words
:B0X*?:asign::f("assign") ; Fixes 27
:B0X*?:awya::f("away") ; Fixes 46 words
:B0X*?:bakc::f("back") ; Fixes 410 words
:B0X*?:blihs::f("blish") ; Fixes 56 words
:B0X*?:charecter::f("character") ; Fixes 38 words
:B0X*?:comnt::f("cont") ; Fixes 587 words
:B0X*?:degred::f("degrad") ; Fixes 31 words
:B0X*?:dessign::f("design") ; Fixes 51 words
:B0X*?:disign::f("design") ; Fixes 51 words
:B0X*?:dquater::f("dquarter") ; Fixes 6 words 
:B0X*?:easr::f("ears") ; Fixes 102 words
:B0X*?:ecomon::f("econom") ; Fixes 50 words
:B0X*?:esorce::f("esource") ; Fixes 11 words
:B0X*C:i)::f("i)") ; Fixes 1 word
:B0X*?:juristiction::f("jurisdiction") ; Fixes 4 words
:B0X*?:konw::f("know") ; Fixes 66 words
:B0X*?:mmorow::f("morrow") ; Fixes 4 words
:B0X*?:ngiht::f("night") ; Fixes 103 words
:B0X*?:orign::f("origin") ; Fixes 37 words
:B0X*?:rnign::f("rning") ; Fixes 77 words
:B0X*?:sensur::f("censur") ; Fixes 12 words
:B0X*?:soverign::f("sovereign") ; Fixes 10 words
:B0X*?:ssurect::f("surrect") ; Fixes 15 words
:B0X*?:tatn::f("tant") ; Fixes 530 words
:B0X*?:thakn::f("thank") ; Fixes 19 words 
:B0X*?:thnig::f("thing") ; Fixes 103 words
:B0X*?:threatn::f("threaten") ; Fixes 10 words
:B0X*?:tihkn::f("think") ; Fixes 43 words
:B0X*?:tiojn::f("tion") ; Fixes 7052 words
:B0X*:trafic::f("traffic") ; Fixes 13 words 
:B0X*?:visiosn::f("vision") ; Fixes 51 words
:B0X:doesnt::f("doesn't") ; Fixes 1 word
:B0X:inprocess::f("in process") ; Fixes 1 word
:B0X?:adresing::f("addressing") ; Fixes 3 words
:B0X?:clas::f("class") ; Fixes 8 words
:B0X?:efull::f("eful") ; Fixes 74 words
:B0X?:ficaly::f("fically") ; Fixes 20 words
; ---- Items from accented list, but must be in no-sort section ----
::decollete::décolleté ; adj. (of a garment) having a low-cut neckline
::manana::mañana ; Spanish: Tomorrow. 
; ===== End of Don't Sort items ===========

;============== Determine start line of autocorrect items ======================
; If this variable name or assignment gets changed, also change it in the Conflicting String Locator script.
ACitemsStartAt := A_LineNumber + 3 ; hh2 validity checks will skip lines until it gets to here. 

; ===== Main List ==========================
:B0X*:Buddist::f("Buddhist") ; Fixes 3 words
:B0X*:Feburary::f("February") ; Fixes 1 word
:B0X*:Hatian::f("Haitian") ; Fixes 2 words
:B0X*:Isaax ::f("Isaac") ; Fixes 1 word
:B0X*:Israelies::f("Israelis") ; Fixes 1 word
:B0X*:Janurary::f("January") ; Fixes 1 word
:B0X*:Januray::f("January") ; Fixes 1 word
:B0X*:Karent::f("Karen") ; Fixes 1 word
:B0X*:Montnana::f("Montana") ; Fixes 1 word
:B0X*:Naploeon::f("Napoleon") ; Fixes 6 words
:B0X*:Napolean::f("Napoleon") ; Fixes 6 words
:B0X*:Novermber::f("November") ; Fixes 1 word
:B0X*:Pennyslvania::f("Pennsylvania") ; Fixes 3 words
:B0X*:Queenland::f("Queensland") ; Fixes 3 words
:B0X*:Sacremento::f("Sacramento") ; Fixes 1 word
:B0X*:Straight of::f("Strait of") ; geography ; Fixes 1 word
:B0X*:ToolTop::f("ToolTip") ; Fixes 1 word
:B0X*:a FM::f("an FM") ; Fixes 1 word
:B0X*:a MRI::f("an MRI") ; Fixes 1 word
:B0X*:a ab::f("an ab") ; Fixes 1 word
:B0X*:a ac::f("an ac") ; Fixes 1 word
:B0X*:a ad::f("an ad") ; Fixes 1 word
:B0X*:a af::f("an af") ; Fixes 1 word
:B0X*:a ag::f("an ag") ; Fixes 1 word
:B0X*:a al::f("an al") ; Fixes 1 word
:B0X*:a am::f("an am") ; Fixes 1 word
:B0X*:a an::f("an an") ; Fixes 1 word
:B0X*:a ap::f("an ap") ; Fixes 1 word
:B0X*:a as::f("an as") ; Fixes 1 word
:B0X*:a av::f("an av") ; Fixes 1 word
:B0X*:a aw::f("an aw") ; Fixes 1 word
:B0X*:a businessmen::f("a businessman") ; Fixes 1 word
:B0X*:a businesswomen::f("a businesswoman") ; Fixes 1 word
:B0X*:a consortia::f("a consortium") ; Fixes 1 word
:B0X*:a criteria::f("a criterion") ; Fixes 1 word
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
:B0X*:a ic::f("an ic") ; Fixes 1 word
:B0X*:a id::f("an id") ; Fixes 1 word
:B0X*:a ig::f("an ig") ; Fixes 1 word
:B0X*:a il::f("an il") ; Fixes 1 word
:B0X*:a im::f("an im") ; Fixes 1 word
:B0X*:a in::f("an in") ; Fixes 1 word
:B0X*:a ir::f("an ir") ; Fixes 1 word
:B0X*:a is::f("an is") ; Fixes 1 word
:B0X*:a larvae::f("a larva") ; Fixes 1 word
:B0X*:a lock up::f("a lockup") ; Fixes 1 word
:B0X*:a nuclei::f("a nucleus") ; Fixes 1 word
:B0X*:a numbers of::f("a number of") ; Fixes 1 word
:B0X*:a oa::f("an oa") ; Fixes 1 word
:B0X*:a ob::f("an ob") ; Fixes 1 word
:B0X*:a ocean::f("an ocean") ; Fixes 1 word
:B0X*:a offen::f("an offen; Fixes 1 word") 
:B0X*:a offic::f("an offic") ; Fixes 1 word
:B0X*:a oi::f("an oi") ; Fixes 1 word
:B0X*:a ol::f("an ol") ; Fixes 1 word
:B0X*:a one of the::f("one of the") ; Fixes 1 word
:B0X*:a op::f("an op") ; Fixes 1 word
:B0X*:a or::f("an or") ; Fixes 1 word
:B0X*:a os::f("an os") ; Fixes 1 word
:B0X*:a ot::f("an ot") ; Fixes 1 word
:B0X*:a ou::f("an ou") ; Fixes 1 word
:B0X*:a ov::f("an ov") ; Fixes 1 word
:B0X*:a ow::f("an ow") ; Fixes 1 word
:B0X*:a parentheses::f("a parenthesis") ; Fixes 1 word
:B0X*:a pupae::f("a pupa") ; Fixes 1 word
:B0X*:a radii::f("a radius") ; Fixes 1 word
:B0X*:a regular bases::f("a regular basis") ; Fixes 1 word
:B0X*:a resent::f("a recent") ; Fixes 1 word
:B0X*:a run in::f("a run-in") ; Fixes 1 word
:B0X*:a set back::f("a set-back") ; Fixes 1 word
:B0X*:a set up::f("a setup") ; Fixes 1 word
:B0X*:a several::f("several") ; Fixes 1 word
:B0X*:a simple as::f("as simple as") ; Fixes 1 word
:B0X*:a spermatozoa::f("a spermatozoon") ; Fixes 1 word
:B0X*:a statesmen::f("a statesman") ; Fixes 1 word
:B0X*:a two months::f("a two-month") ; Fixes 1 word
:B0X*:a ud::f("an ud") ; Fixes 1 word
:B0X*:a ug::f("an ug") ; Fixes 1 word
:B0X*:a ul::f("an ul") ; Fixes 1 word
:B0X*:a um::f("an um") ; Fixes 1 word
:B0X*:a up::f("an up") ; Fixes 1 word
:B0X*:a urban::f("an urban") ; Fixes 1 word
:B0X*:a vertebrae::f("a vertebra") ; Fixes 1 word
:B0X*:a women::f("a woman") ; Fixes 1 word
:B0X*:a work out::f("a workout") ; Fixes 1 word
:B0X*:abandonned::f("abandoned") ; Fixes 2 words
:B0X*:abcense::f("absence") ; Fixes 2 words
:B0X*:abera::f("aberra") ; Fixes 15 words
:B0X*:abondon::f("abandon") ; Fixes 8 words
:B0X*:about it's::f("about its") ; Fixes 1 word
:B0X*:about they're::f("about their") ; Fixes 1 word
:B0X*:about who to::f("about whom to") ; Fixes 1 word
:B0X*:about who's::f("about whose") ; Fixes 1 word
:B0X*:abouta::f("about a") ; Fixes 1 word
:B0X*:aboutit::f("about it") ; Fixes 1 word
:B0X*:above it's::f("above its") ; Fixes 1 word
:B0X*:abreviat::f("abbreviat") ; Fixes 9 words
:B0X*:absail::f("abseil") ; Fixes 6 words
:B0X*:abscen::f("absen") ; Fixes 16 words
:B0X*:absense::f("absence") ; Fixes 2 words
:B0X*:abutts::f("abuts") ; Fixes 1 word
:B0X*:accidently::f("accidentally") ; Fixes 1 word
:B0X*:acclimit::f("acclimat") ; Fixes 18 words
:B0X*:accomd::f("accommod") ; Fixes 16 words
:B0X*:accordeon::f("accordion") ; Fixes 4 words
:B0X*:accordian::f("accordion") ; Fixes 4 words
:B0X*:according a::f("according to a") ; Fixes 1 word
:B0X*:accordingto::f("according to") ; Fixes 1 word
:B0X*:achei::f("achie") ; Fixes 12 words
:B0X*:achiv::f("achiev") ; Fixes 10 words
:B0X*:aciden::f("acciden") ; Fixes 8 words
:B0X*:ackward::f("awkward") ; Fixes 5 words
:B0X*:acord::f("accord") ; Fixes 15 words
:B0X*:acquite::f("acquitte") ; Fixes 3 words
:B0X*:across it's::f("across its") ; Fixes 1 word
:B0X*:acuse::f("accuse") ; Fixes 6 words
:B0X*:adbandon::f("abandon") ; Fixes 8 words
:B0X*:adhear::f("adher") ; Fixes 9 words
:B0X*:adheran::f("adheren") ; Fixes 5 words
:B0X*:adresa::f("addressa") ; Fixes 3 words
:B0X*:adress::f("address") ; Fixes 13 words
:B0X*:adves::f("advers") ; Fixes 11 words
:B0X*:afair::f("affair") ; Fixes 4 words
:B0X*:affect upon::f("effect upon") ; Fixes 1 word
:B0X*:afficianado::f("aficionado") ; Fixes 2 words
:B0X*:afficionado::f("aficionado") ; Fixes 2 words
:B0X*:after along time::f("after a long time") ; Fixes 1 word
:B0X*:after awhile::f("after a while") ; Fixes 1 word
:B0X*:after been::f("after being") ; Fixes 1 word
:B0X*:after it's::f("after its") ; Fixes 1 word
:B0X*:after quite awhile::f("after quite a while") ; Fixes 1 word
:B0X*:against it's::f("against its") ; Fixes 1 word
:B0X*:againstt he::f("against the") ; Fixes 1 word
:B0X*:agani::f("again") ; Fixes 2 words
:B0X*:aggregious::f("egregious") ; Fixes 3 words
:B0X*:agian::f("again") ; Fixes 2 words
:B0X*:agina::f("again") ; Fixes 2 words
:B0X*:aginst::f("against") ; Fixes 1 word
:B0X*:agriev::f("aggriev") ; Fixes 5 words
:B0X*:ahjk::f("ahk") ; Fixes 1 word
:B0X*:aiport::f("airport") ; Fixes 2 words
:B0X*:airbourne::f("airborne") ; Fixes 1 word
:B0X*:airplane hanger::f("airplane hangar") ; Fixes 1 word
:B0X*:airporta::f("airports") ; Fixes 1 word
:B0X*:airrcraft::f("aircraft") ; Fixes 1 word
:B0X*:akk::f("all") ; Fixes 1 word 
:B0X*:albiet::f("albeit") ; Fixes 1 word
:B0X*:aledg::f("alleg") ; Fixes 46 words
:B0X*:alege::f("allege") ; Fixes 6 words
:B0X*:alegien::f("allegian") ; Fixes 5 words
:B0X*:algebraical::f("algebraic") ; Fixes 3 words
:B0X*:alientat::f("alienat") ; Fixes 8 words
:B0X*:all it's::f("all its") ; Fixes 1 word
:B0X*:all tolled::f("all told") ; Fixes 1 word
:B0X*:alledg::f("alleg") ; Fixes 46 words
:B0X*:allegedy::f("allegedly") ; Fixes 1 word
:B0X*:allegely::f("allegedly") ; Fixes 1 word
:B0X*:allivia::f("allevia") ; Fixes 12 words
:B0X*:allopon::f("allophon") ; Fixes 4 words
:B0X*:allot of::f("a lot of") ; Fixes 1 word
:B0X*:allready::f("already") ; Fixes 1 word
:B0X*:alltime::f("all-time") ; Fixes 1 word
:B0X*:alma matter::f("alma mater") ; Fixes 1 word
:B0X*:almots::f("almost") ; Fixes 1 word
:B0X*:along it's::f("along its") ; Fixes 1 word
:B0X*:along side::f("alongside") ; Fixes 1 word
:B0X*:along time::f("a long time") ; Fixes 1 word
:B0X*:alongside it's::f("alongside its") ; Fixes 1 word
:B0X*:alter boy::f("altar boy") ; Fixes 1 word
:B0X*:alter server::f("altar server") ; Fixes 1 word
:B0X*:alterior::f("ulterior") ; Fixes 4 words
:B0X*:alternit::f("alternat") ; Fixes 15 words
:B0X*:althought::f("although") ; Fixes 1 word
:B0X*:altoug::f("althoug") ; Fixes 1 word
:B0X*:alusi::f("allusi") ; Fixes 5 words
:B0X*:am loathe to::f("am loath to") ; Fixes 1 word
:B0X*:amalgom::f("amalgam") ; Fixes 11 words
:B0X*:amature::f("amateur") ; Fixes 7 words
:B0X*:amid it's::f("amid its") ; Fixes 1 word
:B0X*:amidst it's::f("amidst its") ; Fixes 1 word
:B0X*:amme::f("ame") ; Fixes 341 words, Misspells ammeter (electrician's tool).
:B0X*:ammuse::f("amuse") ; Fixes 6 words.
:B0X*:among it's::f("among it") ; Fixes 1 word
:B0X*:among others things::f("among other things") ; Fixes 1 word
:B0X*:amongst it's::f("amongst its") ; Fixes 1 word
:B0X*:amongst one of the::f("amongst the") ; Fixes 1 word
:B0X*:amongst others things::f("amongst other things") ; Fixes 1 word
:B0X*:amung::f("among") ; Fixes 2 words
:B0X*:amunition::f("ammunition") ; Fixes 2 words
:B0X*:an USB::f("a USB") ; Fixes 1 word
:B0X*:an Unix::f("a Unix") ; Fixes 1 word
:B0X*:an another::f("another") ; Fixes 1 word
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
:B0X*:an sec::f("a sec") ; Fixes 199 word
:B0X*:an ser::f("a ser") ; Fixes 293 word
:B0X*:an seven::f("a seven") ; Fixes 1 word
:B0X*:an six::f("a six") ; Fixes 1 word
:B0X*:an song::f("a song") ; Fixes 1 word
:B0X*:an spec::f("a spec") ; Fixes 1 word
:B0X*:an stat::f("a stat") ; Fixes 1 word
:B0X*:an ten::f("a ten") ; Fixes 1 word
:B0X*:an union::f("a union") ; Fixes 1 word
:B0X*:an unit::f("a unit") ; Fixes 1 word
:B0X*:analag::f("analog") ; Fixes 23 words
:B0X*:anarchim::f("anarchism") ; Fixes 2 words
:B0X*:anarchistm::f("anarchism") ; Fixes 1 word
:B0X*:and so fourth::f("and so forth") ; Fixes 1 word
:B0X*:andd::f("and") ; Fixes 73 words
:B0X*:andone::f("and one") ; Fixes 1 word
:B0X*:androgenous::f("androgynous") ; Fixes 3 words
:B0X*:androgeny::f("androgyny") ; Fixes 1 word
:B0X*:anih::f("annih") ; Fixes 9 words
:B0X*:aniv::f("anniv") ; Fixes 2 words
:B0X*:anonim::f("anonym") ; Fixes 19 words
:B0X*:anoyance::f("annoyance") ; Fixes 2 words
:B0X*:ansal::f("nasal") ; Fixes 20 words
:B0X*:ansest::f("ancest") ; Fixes 8 words
:B0X*:antartic::f("antarctic") ; Fixes 2 words
:B0X*:anthrom::f("anthropom") ; Fixes 27 words
:B0X*:anti-semetic::f("anti-Semitic") ; Fixes 1 word
:B0X*:antiapartheid::f("anti-apartheid") ; Fixes 1 word
:B0X*:anual::f("annual") ; Fixes 15 words
:B0X*:anul::f("annul") ; Fixes 17 words
:B0X*:any another::f("another") ; Fixes 1 word
:B0X*:any resent::f("any recent") ; Fixes 1 word
:B0X*:any where::f("anywhere") ; Fixes 1 word
:B0X*:anyother::f("any other") ; Fixes 1 word
:B0X*:anytying::f("anything") ; Fixes 1 word
:B0X*:aoubt::f("about") ; Fixes 2 words 
:B0X*:apart form::f("apart from") ; Fixes 1 word
:B0X*:aproxim::f("approxim") ; Fixes 14 words
:B0X*:aquaduct::f("aqueduct") ; Fixes 2 words
:B0X*:aquir::f("acquir") ; Fixes 12 words
:B0X*:arbouret::f("arboret") ; Fixes 3 words
:B0X*:archiac::f("archaic") ; Fixes 6 words
:B0X*:archimedian::f("Archimedean") ; Fixes 1 word
:B0X*:archtyp::f("archetyp") ; Fixes 6 words
:B0X*:are aloud to::f("are allowed to") ; Fixes 1 word
:B0X*:are build::f("are built") ; Fixes 1 word
:B0X*:are drew::f("are drawn") ; Fixes 1 word
:B0X*:are it's::f("are its") ; Fixes 1 word
:B0X*:are know::f("are known") ; Fixes 1 word
:B0X*:are lain::f("are laid") ; Fixes 1 word
:B0X*:are lead by::f("are led by") ; Fixes 1 word
:B0X*:are loathe to::f("are loath to") ; Fixes 1 word
:B0X*:are ran by::f("are run by") ; Fixes 1 word
:B0X*:are set-up::f("are set up") ; Fixes 1 word
:B0X*:are setup::f("are set up") ; Fixes 1 word
:B0X*:are shutdown::f("are shut down") ; Fixes 1 word
:B0X*:are shutout::f("are shut out") ; Fixes 1 word
:B0X*:are suppose to::f("are supposed to") ; Fixes 1 word
:B0X*:are use to::f("are used to") ; Fixes 1 word
:B0X*:aready::f("already") ; Fixes 1 word
:B0X*:areod::f("aerod") ; Fixes 10 words
:B0X*:arised::f("arose") ; Fixes 1 word
:B0X*:ariv::f("arriv") ; Fixes 11 words
:B0X*:armistace::f("armistice") ; Fixes 2 words
:B0X*:arn't::f("aren't") ; Fixes 1 word
:B0X*:arogan::f("arrogan") ; Fixes 6 words
:B0X*:arond::f("around") ; Fixes 1 word
:B0X*:aroud::f("around") ; Fixes 1 word
:B0X*:around it's::f("around its") ; Fixes 1 word
:B0X*:arren::f("arran") ; Fixes 12 words
:B0X*:arrou::f("arou") ; Fixes 11 words
:B0X*:artc::f("artic") ; Fixes 26 words
:B0X*:artical::f("article") ; Fixes 3 words
:B0X*:artifical::f("artificial") ; Fixes 6 words
:B0X*:artillar::f("artiller") ; Fixes 6 words
:B0X*:as a resulted::f("as a result") ; Fixes 1 word
:B0X*:as apposed to::f("as opposed to") ; Fixes 1 word
:B0X*:as back up::f("as backup") ; Fixes 1 word
:B0X*:as oppose to::f("as opposed to") ; Fixes 1 word
:B0X*:asetic::f("ascetic") ; Fixes 6 words
:B0X*:asfar::f("as far") ; Fixes 1 word
:B0X*:aside form::f("aside from") ; Fixes 1 word
:B0X*:aside it's::f("aside its") ; Fixes 1 word
:B0X*:aspect ration::f("aspect ratio") ; Fixes 1 word
:B0X*:asphyxa::f("asphyxia") ; Fixes 13 words
:B0X*:assasin::f("assassin") ; Fixes 10 words
:B0X*:assesment::f("assessment") ; Fixes 4 words
:B0X*:asside::f("aside") ; Fixes 2 words
:B0X*:assignement::f("assignment") ; Fixes 2 words 
:B0X*:assisnat::f("assassinat") ; Fixes 8 words
:B0X*:assistent::f("assistant") ; Fixes 4 words
:B0X*:assit::f("assist") ; Fixes 14 words
:B0X*:assualt::f("assault") ; Fixes 10 words
:B0X*:assume the reigns::f("assume the reins") ; Fixes 1 word
:B0X*:assume the roll::f("assume the role") ; Fixes 1 word
:B0X*:asum::f("assum") ; Fixes 19 words
:B0X*:aswell::f("as well") ; Fixes 1 word
:B0X*:at it's::f("at its") ; Fixes 1 word
:B0X*:at of::f("at or") ; Fixes 1 word
:B0X*:at the alter::f("at the altar") ; Fixes 1 word
:B0X*:at the reigns::f("at the reins") ; Fixes 1 word
:B0X*:at then end::f("at the end") ; Fixes 1 word
:B0X*:at-rist::f("at-risk ") ; Fixes 1 word
:B0X*:atheistical::f("atheistic") ; Fixes 1 word
:B0X*:athenean::f("Athenian") ; Fixes 2 words
:B0X*:atleast::f("at least") ; Fixes 1 word
:B0X*:atn::f("ant") ; Fixes 704 words
:B0X*:atorne::f("attorne") ; Fixes 5 words
:B0X*:attened::f("attended") ; Fixes 1 word
:B0X*:attourne::f("attorne") ; Fixes 5 words
:B0X*:attroci::f("atroci") ; Fixes 5 words
:B0X*:auot::f("auto") ; Fixes 1 word
:B0X*:auromat::f("automat") ; Fixes 36 words
:B0X*:austrailia::f("Australia") ; Fixes 14 words
:B0X*:authorative::f("authoritative") ; Fixes 3 words
:B0X*:authorites::f("authorities") ; Fixes 1 word
:B0X*:authoritive::f("authoritative") ; Fixes 3 words
:B0X*:autochtonous::f("autochthonous") ; Fixes 3 words
:B0X*:autocton::f("autochthon") ; Fixes 10 words
:B0X*:autorit::f("authorit") ; Fixes 9 words
:B0X*:autsim::f("autism") ; Fixes 2 words
:B0X*:auxilar::f("auxiliar") ; Fixes 2 words
:B0X*:auxillar::f("auxiliar") ; Fixes 2 words
:B0X*:auxilliar::f("auxiliar") ; Fixes 2 words
:B0X*:avalance::f("avalanche") ; Fixes 3 words
:B0X*:avati::f("aviati") ; Fixes 3 words
:B0X*:avengence::f("a vengeance") ; Fixes 1 word
:B0X*:averagee::f("average") ; Fixes 5 words
:B0X*:away form::f("away from") ; Fixes 1 word
:B0X*:aywa::f("away") ; Fixes 4 words
:B0X*:baceause::f("because") ; Fixes 1 word
:B0X*:back and fourth::f("back and forth") ; Fixes 1 word
:B0X*:back drop::f("backdrop") ; Fixes 1 word
:B0X*:back fire::f("backfire") ; Fixes 1 word
:B0X*:back peddle::f("backpedal") ; Fixes 1 word
:B0X*:back round::f("background") ; Fixes 1 word
:B0X*:badly effected::f("badly affected") ; Fixes 1 word
:B0X*:baited breath::f("bated breath") ; Fixes 1 word
:B0X*:baled out::f("bailed out") ; Fixes 1 word
:B0X*:baling out::f("bailing out") ; Fixes 1 word
:B0X*:bananna::f("banana") ; Fixes 2 words
:B0X*:bandonn::f("abandon") ; Fixes 8 words
:B0X*:bandwith::f("bandwidth") ; Fixes 2 words
:B0X*:bankrupc::f("bankruptc") ; Fixes 2 words
:B0X*:banrupt::f("bankrupt") ; Fixes 7 words
:B0X*:barb wire::f("barbed wire") ; Fixes 2 words
:B0X*:bare in mind::f("bear in mind") ; Fixes 1 word
:B0X*:barily::f("barely") ; Fixes 1 word
:B0X*:basic principal::f("basic principle") ; Fixes 1 word
:B0X*:be apart of::f("be a part of") ; Fixes 1 word
:B0X*:be build::f("be built") ; Fixes 1 word
:B0X*:be cause::f("because") ; Fixes 1 word
:B0X*:be drew::f("be drawn") ; Fixes 1 word
:B0X*:be it's::f("be its") ; Fixes 1 word
:B0X*:be know as::f("be known as") ; Fixes 1 word
:B0X*:be lain::f("be laid") ; Fixes 1 word
:B0X*:be lead by::f("be led by") ; Fixes 1 word
:B0X*:be loathe to::f("be loath to") ; Fixes 1 word
:B0X*:be rebuild::f("be rebuilt") ; Fixes 1 word
:B0X*:be set-up::f("be set up") ; Fixes 1 word
:B0X*:be setup::f("be set up") ; Fixes 1 word
:B0X*:be shutdown::f("be shut down") ; Fixes 1 word
:B0X*:be use to::f("be used to") ; Fixes 1 word
:B0X*:be ware::f("beware") ; Fixes 1 word
:B0X*:beachead::f("beachhead") ; Fixes 2 words
:B0X*:beacuse::f("because") ; Fixes 1 word
:B0X*:beastia::f("bestia") ; Fixes 14 words
:B0X*:became it's::f("became its") ; Fixes 1 word
:B0X*:because of it's::f("because of its") ; Fixes 1 word
:B0X*:becausea::f("because a") ; Fixes 1 word
:B0X*:becauseof::f("because of") ; Fixes 1 word
:B0X*:becausethe::f("because the") ; Fixes 1 word
:B0X*:becauseyou::f("because you") ; Fixes 1 word
:B0X*:beccause::f("because") ; Fixes 1 word
:B0X*:becouse::f("because") ; Fixes 1 word
:B0X*:becuse::f("because") ; Fixes 1 word
:B0X*:been accustom to::f("been accustomed to") ; Fixes 1 word
:B0X*:been build::f("been built") ; Fixes 1 word
:B0X*:been it's::f("been its") ; Fixes 1 word
:B0X*:been lain::f("been laid") ; Fixes 1 word
:B0X*:been lead by::f("been led by") ; Fixes 1 word
:B0X*:been loathe to::f("been loath to") ; Fixes 1 word
:B0X*:been mislead::f("been misled") ; Fixes 1 word
:B0X*:been rebuild::f("been rebuilt") ; Fixes 1 word
:B0X*:been set-up::f("been set up") ; Fixes 1 word
:B0X*:been setup::f("been set up") ; Fixes 1 word
:B0X*:been show on::f("been shown on") ; Fixes 1 word
:B0X*:been shutdown::f("been shut down") ; Fixes 1 word
:B0X*:been use to::f("been used to") ; Fixes 1 word
:B0X*:before hand::f("beforehand") ; Fixes 1 word
:B0X*:began it's::f("began its") ; Fixes 1 word
:B0X*:begginer::f("beginner") ; Fixes 2 words
:B0X*:beggining::f("beginning") ; Fixes 3 words
:B0X*:beggins::f("begins") ; Fixes 1 word
:B0X*:begining::f("beginning") ; Fixes 3 words
:B0X*:behind it's::f("behind its") ; Fixes 1 word
:B0X*:being build::f("being built") ; Fixes 1 word
:B0X*:being it's::f("being its") ; Fixes 1 word
:B0X*:being lain::f("being laid") ; Fixes 1 word
:B0X*:being lead by::f("being led by") ; Fixes 1 word
:B0X*:being loathe to::f("being loath to") ; Fixes 1 word
:B0X*:being set-up::f("being set up") ; Fixes 1 word
:B0X*:being setup::f("being set up") ; Fixes 1 word
:B0X*:being show on::f("being shown on") ; Fixes 1 word
:B0X*:being shutdown::f("being shut down") ; Fixes 1 word
:B0X*:being use to::f("being used to") ; Fixes 1 word
:B0X*:beligum::f("Belgium") ; Fixes 1 word
:B0X*:belived::f("believed") ; Fixes 1 word
:B0X*:belives::f("believes") ; Fixes 1 word
:B0X*:bellweather::f("bellwether") ; Fixes 2 words
:B0X*:below it's::f("below its") ; Fixes 1 word
:B0X*:beneath it's::f("beneath its") ; Fixes 1 word
:B0X*:bergamont::f("bergamot") ; Fixes 2 words
:B0X*:beseig::f("besieg") ; Fixes 9 words
:B0X*:beside it's::f("beside its") ; Fixes 1 word
:B0X*:besides it's::f("besides its") ; Fixes 1 word
:B0X*:beteen::f("between") ; Fixes 3 words
:B0X*:better know as::f("better known as") ; Fixes 1 word
:B0X*:better know for::f("better known for") ; Fixes 1 word
:B0X*:better then::f("better than") ; Fixes 1 word
:B0X*:between I and::f("between me and") ; Fixes 1 word
:B0X*:between he and::f("between him and") ; Fixes 1 word
:B0X*:between it's::f("between its") ; Fixes 1 word
:B0X*:between they and::f("between them and") ; Fixes 1 word
:B0X*:betwen::f("between") ; Fixes 3 words
:B0X*:beut::f("beaut") ; Fixes 20 words
:B0X*:beween::f("between") ; Fixes 3 words
:B0X*:bewteen::f("between") ; Fixes 3 words
:B0X*:bewwe::f("betwe") ; Fixes 7 words 
:B0X*:beyond it's::f("beyond its") ; Fixes 1 word
:B0X*:biginning::f("beginning") ; Fixes 3 words
:B0X*:billingual::f("bilingual") ; Fixes 7 words
:B0X*:bizzare::f("bizarre") ; Fixes 3 words
:B0X*:blaim::f("blame") ; Fixes 14 words
:B0X*:blitzkreig::f("Blitzkrieg") ; Fixes 4 words
:B0X*:bodydbuilder::f("bodybuilder") ; Fixes 2 words
:B0X*:bonifide::f("bonafide") ; Fixes 1 word 
:B0X*:bonofide::f("bonafide") ; Fixes 1 word 
:B0X*:both it's::f("both its") ; Fixes 1 word
:B0X*:both of it's::f("both of its") ; Fixes 1 word
:B0X*:both of them is::f("both of them are") ; Fixes 1 word
:B0X*:boyan::f("buoyan") ; Fixes 5 words
:B0X*:brake away::f("break away") ; Fixes 1 word
:B0X*:brasillian::f("Brazilian") ; Fixes 2 words
:B0X*:breakthough::f("breakthrough") ; Fixes 2 words
:B0X*:breakthroughts::f("breakthroughs") ; Fixes 1 word
:B0X*:breath fire::f("breathe fire") ; Fixes 1 word
:B0X*:brethen::f("brethren") ; Fixes 1 word
:B0X*:bretheren::f("brethren") ; Fixes 1 word
:B0X*:brew haha::f("brouhaha") ; Fixes 1 word
:B0X*:brillan::f("brillian") ; Fixes 9 words
:B0X*:brimestone::f("brimstone") ; Fixes 1 word
:B0X*:britian::f("Britain") ; Fixes 1 word
:B0X*:brittish::f("British") ; Fixes 1 word
:B0X*:broacasted::f("broadcast") ; Fixes 1 word
:B0X*:broady::f("broadly") ; Fixes 1 word
:B0X*:brocolli::f("broccoli") ; Fixes 2 words
:B0X*:buddah::f("Buddha") ; Fixes 2 words
:B0X*:buoan::f("buoyan") ; Fixes 5 words
:B0X*:bve::f("be") ; Fixes 1565 words
:B0X*:by it's::f("by its") ; Fixes 1 word
:B0X*:by who's::f("by whose") ; Fixes 1 word
:B0X*:byt he::f("by the") ; Fixes 1 word
:B0X*:cacus::f("caucus") ; Fixes 4 words
:B0X*:calaber::f("caliber") ; Fixes 2 words
:B0X*:calander::f("calendar") ; Fixes 4 words
:B0X*:calender::f("calendar") ; Fixes 4 words
:B0X*:califronia::f("California") ; Fixes 3 words
:B0X*:caligra::f("calligra") ; Fixes 15 words
:B0X*:callipigian::f("callipygian") ; Fixes 1 word
:B0X*:cambrige::f("Cambridge") ; Fixes 2 words
:B0X*:camoflag::f("camouflag") ; Fixes 4 words
:B0X*:can backup::f("can back up") ; Fixes 1 word
:B0X*:can been::f("can be") ; Fixes 1 word
:B0X*:can blackout::f("can black out") ; Fixes 1 word
:B0X*:can checkout::f("can check out") ; Fixes 1 word
:B0X*:can playback::f("can play back") ; Fixes 1 word
:B0X*:can setup::f("can set up") ; Fixes 1 word
:B0X*:can tryout::f("can try out") ; Fixes 1 word
:B0X*:can workout::f("can work out") ; Fixes 1 word
:B0X*:candidiat::f("candidat") ; Fixes 4 words
:B0X*:cannota::f("connota") ; Fixes 5 words
:B0X*:cansel::f("cancel") ; Fixes 21 words
:B0X*:cansent::f("consent ") ; Fixes 1 word
:B0X*:cantalop::f("cantaloup") ; Fixes 4 words
:B0X*:capetown::f("Cape Town") ; Fixes 1 word
:B0X*:carnege::f("Carnegie") ; Fixes 1 word
:B0X*:carnige::f("Carnegie") ; Fixes 1 word
:B0X*:carniver::f("carnivor") ; Fixes 7 words
:B0X*:carree::f("caree") ; Fixes 12 words
:B0X*:carrib::f("Carib") ; Fixes 8 words
:B0X*:carthogr::f("cartogr") ; Fixes 9 words
:B0X*:casion::f("caisson") ; Fixes 2 words
:B0X*:cassawor::f("cassowar") ; Fixes 2 words
:B0X*:cassowarr::f("cassowar") ; Fixes 2 words
:B0X*:casulat::f("casualt") ; Fixes 2 words
:B0X*:catapillar::f("caterpillar") ; Fixes 2 words
:B0X*:catapiller::f("caterpillar") ; Fixes 2 words
:B0X*:catepillar::f("caterpillar") ; Fixes 2 words
:B0X*:caterpilar::f("caterpillar") ; Fixes 2 words
:B0X*:caterpiller::f("caterpillar") ; Fixes 2 words
:B0X*:catterpilar::f("caterpillar") ; Fixes 2 words
:B0X*:catterpillar::f("caterpillar") ; Fixes 2 words
:B0X*:caucasion::f("Caucasian") ; Fixes 2 words
:B0X*:ceasa::f("Caesa") ; Fixes 14 words
:B0X*:celcius::f("Celsius") ; Fixes 1 word
:B0X*:cementary::f("cemetery") ; Fixes 1 word
:B0X*:cemetar::f("cemeter") ; Fixes 3 words
:B0X*:centruy::f("century") ; Fixes 1 word
:B0X*:centuties::f("centuries") ; Fixes 1 word
:B0X*:centuty::f("century") ; Fixes 1 word
:B0X*:cervial::f("cervical") ; Fixes 1 word
:B0X*:chalk full::f("chock-full") ; Fixes 1 word
:B0X*:champang::f("champagn") ; Fixes 5 words
:B0X*:changed it's::f("changed its") ; Fixes 1 word
:B0X*:charistics::f("characteristics") ; Fixes 1 word
:B0X*:chauffer::f("chauffeur") ; Fixes 4 words
:B0X*:childrens::f("children's") ; Fixes 1 word
:B0X*:chock it up::f("chalk it up") ; Fixes 1 word
:B0X*:chocked full::f("chock-full") ; Fixes 1 word
:B0X*:choclat::f("chocolat") ; Fixes 7 words
:B0X*:chomping at the bit::f("champing at the bit") ; Fixes 1 word
:B0X*:choosen::f("chosen") ; Fixes 1 word
:B0X*:chuch::f("church") ; Fixes 30 words
:B0X*:ciel::f("ceil") ; Fixes 10 words
:B0X*:cilind::f("cylind") ; Fixes 8 words
:B0X*:cincinatti::f("Cincinnati") ; Fixes 1 word
:B0X*:cincinnatti::f("Cincinnati") ; Fixes 1 word
:B0X*:cirtu::f("citru") ; Fixes 7 words
:B0X*:clera::f("clear") ; Fixes 27 words
:B0X*:closed it's::f("closed its") ; Fixes 1 word
:B0X*:closer then::f("closer than") ; Fixes 1 word
:B0X*:co-incided::f("coincided") ; Fixes 1 word
:B0X*:colate::f("collate") ; Fixes 19 words
:B0X*:colea::f("collea") ; Fixes 2 words
:B0X*:collaber::f("collabor") ; Fixes 15 words
:B0X*:collos::f("coloss") ; Fixes 9 words
:B0X*:comande::f("commande") ; Fixes 11 words
:B0X*:comando::f("commando") ; Fixes 2 words
:B0X*:comback::f("comeback") ; Fixes 2 words
:B0X*:comdem::f("condem") ; Fixes 12 words
:B0X*:commadn::f("command") ; Fixes 22 words
:B0X*:commandoes::f("commandos") ; Fixes 1 word
:B0X*:commemerat::f("commemorat") ; Fixes 12 words
:B0X*:commerorat::f("commemorat") ; Fixes 12 words
:B0X*:commonly know as::f("commonly known as") ; Fixes 1 word
:B0X*:commonly know for::f("commonly known for") ; Fixes 1 word
:B0X*:compair::f("compare") ; Fixes 3 words
:B0X*:comparit::f("comparat") ; Fixes 6 words
:B0X*:compona::f("compone") ; Fixes 5 words
:B0X*:compulsar::f("compulsor") ; Fixes 3 words
:B0X*:compulser::f("compulsor") ; Fixes 3 words
:B0X*:concensu::f("consensu") ; Fixes 4 words
:B0X*:conciet::f("conceit") ; Fixes 5 words
:B0X*:condamn::f("condemn") ; Fixes 12 words
:B0X*:condemm::f("condemn") ; Fixes 12 words
:B0X*:conesencu::f("consensu") ; Fixes 4 words
:B0X*:confidental::f("confidential") ; Fixes 5 words
:B0X*:confids::f("confides") ; Fixes 1 word
:B0X*:congradulat::f("congratulat") ; Fixes 9 words
:B0X*:coniv::f("conniv") ; Fixes 11 words
:B0X*:conneticut::f("Connecticut") ; Fixes 2 words
:B0X*:conot::f("connot") ; Fixes 9 words
:B0X*:conquerer::f("conqueror") ; Fixes 2 words
:B0X*:consorci::f("consorti") ; Fixes 4 words
:B0X*:construction sight::f("construction site") ; Fixes 1 word
:B0X*:consulan::f("consultan") ; Fixes 4 words
:B0X*:consulten::f("consultan") ; Fixes 4 words
:B0X*:controvercy::f("controversy") ; Fixes 1 word
:B0X*:controvery::f("controversy") ; Fixes 1 word
:B0X*:copy or report::f("copy of report") 
:B0X*:copy or signed::f("copy of signed") 
:B0X*:corosi::f("corrosi") ; Fixes 6 words
:B0X*:correpond::f("correspond") ; Fixes 12 words
:B0X*:corridoor::f("corridor") ; Fixes 2 words
:B0X*:coucil::f("council") ; Fixes 14 words
:B0X*:coudl::f("could") 
:B0X*:coudn't::f("couldn't") ; Fixes 1 word
:B0X*:could backup::f("could back up") ; Fixes 1 word
:B0X*:could setup::f("could set up") ; Fixes 1 word
:B0X*:could workout::f("could work out") ; Fixes 1 word
:B0X*:councellor::f("counselor") ; Fixes 4 words
:B0X*:counr::f("countr") ; Fixes 18 words
:B0X*:countires::f("countries") ; Fixes 1 word
:B0X*:creeden::f("creden") ; Fixes 10 words
:B0X*:critere::f("criteri") ; Fixes 6 words
:B0X*:criteria is::f("criteria are") ; Fixes 1 word
:B0X*:criteria was::f("criteria were") ; Fixes 1 word
:B0X*:criterias::f("criteria") ; Fixes 1 word
:B0X*:critiz::f("criticiz") ; Fixes 7 words
:B0X*:crucifiction::f("crucifixion") ; Fixes 2 words
:B0X*:culimi::f("culmi") ; Fixes 8 words
:B0X*:curriculm::f("curriculum") ; Fixes 2 words
:B0X*:cyclind::f("cylind") ; Fixes 8 words
:B0X*:dacquiri::f("daiquiri") ; Fixes 2 words
:B0X*:dael::f("deal") ; Fixes 31 words
:B0X*:dakiri::f("daiquiri") ; Fixes 2 words
:B0X*:dalmation::f("dalmatian") ; Fixes 2 words
:B0X*:dardenelles::f("Dardanelles") ; Fixes 1 word
:B0X*:darker then::f("darker than") ; Fixes 1 word
:B0X*:daty::f("day") ; Fixes 72 words 
:B0X*:daye::f("date") ; Fixes 23 words, exists as beginning and end.
:B0X*:deafult::f("default") ; Fixes 6 words
:B0X*:decathalon::f("decathlon") ; Fixes 2 words
:B0X*:deciding on how::f("deciding how") ; Fixes 1 word
:B0X*:decomposited::f("decomposed") ; Fixes 1 word
:B0X*:decompositing::f("decomposing") ; Fixes 1 word
:B0X*:decomposits::f("decomposes") ; Fixes 1 word
:B0X*:decress::f("decrees") ; Fixes 1 word
:B0X*:deep-seeded::f("deep-seated") ; Fixes 1 word
:B0X*:definan::f("defian") ; Fixes 5 words
:B0X*:delapidat::f("dilapidat") ; Fixes 6 words
:B0X*:deleri::f("deliri") ; Fixes 7 words
:B0X*:delima::f("dilemma") ; Fixes 3 words 
:B0X*:delusionally::f("delusionary") ; Fixes 1 word
:B0X*:demographical::f("demographic") ; Fixes 1 word
:B0X*:derogit::f("derogat") ; Fixes 11 words
:B0X*:descripter::f("descriptor") ; Fixes 2 words
:B0X*:desease::f("disease") ; Fixes 5 words.
:B0X*:desica::f("desicca") ; Fixes 11 words
:B0X*:desinte::f("disinte") ; Fixes 24 words.
:B0X*:desktiop::f("desktop") ; Fixes 2 words
:B0X*:desorder::f("disorder") ; Fixes 8 words.
:B0X*:desorient::f("disorient") ; Fixes 10 words.
:B0X*:desparat::f("desperat") ; Fixes 6 words.
:B0X*:despite of::f("despite") ; Fixes 1 word
:B0X*:dessicat::f("desiccat") ; Fixes 9 words.
:B0X*:deteoriat::f("deteriorat") ; Fixes 6 words.
:B0X*:deteriat::f("deteriorat") ; Fixes 6 words.
:B0X*:deterioriat::f("deteriorat") ; Fixes 6 words.
:B0X*:detrement::f("detriment") ; Fixes 5 words.
:B0X*:devaste::f("devastate") ; Fixes 3 words
:B0X*:devestat::f("devastat") ; Fixes 9 words.
:B0X*:devistat::f("devastat") ; Fixes 9 words.
:B0X*:diablic::f("diabolic") ; Fixes 4 words.
:B0X*:diamons::f("diamonds") ; Fixes 1 word
:B0X*:diast::f("disast") ; Fixes 5 words.
:B0X*:dicht::f("dichot") ; Fixes 18 words.  Misspells "Mulloidichthys" a genus of Mullidae (goatfishes or red mullets).
:B0X*:diconnect::f("disconnect") ; Fixes 9 words.
:B0X*:did attempted::f("did attempt") ; Fixes 1 word
:B0X*:didint::f("didn't") ; Fixes 1 word
:B0X*:didn't fair::f("didn't fare") ; Fixes 1 word
:B0X*:didnot::f("did not") ; Fixes 1 word
:B0X*:didnt::f("didn't") ; Fixes 1 word
:B0X*:dieties::f("deities") ; Fixes 1 word
:B0X*:diety::f("deity") ; Fixes 1 word
:B0X*:diffcult::f("difficult") ; Fixes 5 words
:B0X*:different tact::f("different tack") ; Fixes 1 word
:B0X*:different to::f("different from") ; Fixes 1 word
:B0X*:difficulity::f("difficulty") ; Fixes 1 word
:B0X*:diffuse the::f("defuse the") ; Fixes 1 word
:B0X*:dificult::f("difficult") ; Fixes 5 words
:B0X*:diminuit::f("diminut") ; Fixes 6 words
:B0X*:dimunit::f("diminut") ; Fixes 6 words
:B0X*:diphtong::f("diphthong") ; Fixes 14 words
:B0X*:diplomanc::f("diplomac") ; Fixes 2 words
:B0X*:diptheria::f("diphtheria") ; Fixes 3 words
:B0X*:dipthong::f("diphthong") ; Fixes 14 words
:B0X*:direct affect::f("direct effect") ; Fixes 1 word
:B0X*:disasterous::f("disastrous") ; Fixes 3 words
:B0X*:disatisf::f("dissatisf") ; Fixes 11 words
:B0X*:disatrous::f("disastrous") ; Fixes 3 words
:B0X*:discontentment::f("discontent") ; Fixes 1 word
:B0X*:discus a::f("discuss a") ; Fixes 1 word
:B0X*:discus the::f("discuss the") ; Fixes 1 word
:B0X*:discus this::f("discuss this") ; Fixes 1 word
:B0X*:diseminat::f("disseminat") ; Fixes 9 words
:B0X*:disente::f("dissente") ; Fixes 3 words 
:B0X*:dispair::f("despair") ; Fixes 6 words
:B0X*:disparingly::f("disparagingly") ; Fixes 1 word
:B0X*:dispele::f("dispelle") ; Fixes 3 words
:B0X*:dispicab::f("despicab") ; Fixes 5 words
:B0X*:dispite::f("despite") ; Fixes 5 words
:B0X*:disproportiate::f("disproportionate") ; Fixes 6 words
:B0X*:dissag::f("disag") ; Fixes 16 words
:B0X*:dissap::f("disap") ; Fixes 37 words
:B0X*:dissar::f("disar") ; Fixes 25 words
:B0X*:dissob::f("disob") ; Fixes 15 words
:B0X*:divinition::f("divination") ; Fixes 2 words
:B0X*:docrines::f("doctrines") ; Fixes 1 word
:B0X*:doe snot::f("does not") ; *could* be legitimate... but very unlikely! ; Fixes 1 word
:B0X*:doen't::f("doesn't") ; Fixes 1 word
:B0X*:dolling out::f("doling out") ; Fixes 1 word
:B0X*:dominate player::f("dominant player") ; Fixes 1 word
:B0X*:dominate role::f("dominant role") ; Fixes 1 word
:B0X*:don't no::f("don't know") ; Fixes 1 word
:B0X*:dont::f("don't") ; Fixes 1 word
:B0X*:door jam::f("doorjamb") ; Fixes 1 word
:B0X*:dosen't::f("doesn't") ; Fixes 1 word
:B0X*:dosn't::f("doesn't") ; Fixes 1 word
:B0X*:double header::f("doubleheader") ; Fixes 2 words
:B0X*:down it's::f("down its") ; Fixes 1 word
:B0X*:down side::f("downside") ; Fixes 1 word
:B0X*:draughtm::f("draughtsm") ; Fixes 4 words
:B0X*:drunkeness::f("drunkenness") ; Fixes 1 word
:B0X*:due to it's::f("due to its") ; Fixes 1 word
:B0X*:dukeship::f("dukedom") ; Fixes 1 word
:B0X*:dumbell::f("dumbbell") ; Fixes 1 word
:B0X*:during it's::f("during its") ; Fixes 1 word
:B0X*:during they're::f("during their") ; Fixes 1 word
:B0X*:each phenomena::f("each phenomenon") ; Fixes 1 word
:B0X*:ealier::f("earlier") ; Fixes 1 word
:B0X*:earnt::f("earned") ; Fixes 1 word
:B0X*:effecting::f("affecting") ; Fixes 1 word 
:B0X*:eiter::f("either") ; Fixes 1 word
:B0X*:eles::f("eels") ; Fixes 1 word
:B0X*:elphant::f("elephant") ; Fixes 6 words
:B0X*:eluded to::f("alluded to") ; Fixes 1 word
:B0X*:emane::f("ename") ; Fixes 15 words 
:B0X*:embargos::f("embargoes") ; Fixes 1 word
:B0X*:embezell::f("embezzl") ; Fixes 8 words
:B0X*:emblamatic::f("emblematic") ; Fixes 4 words
:B0X*:emial::f("email") ; Fixes 6 words
:B0X*:eminat::f("emanat") ; Fixes 6 words
:B0X*:emite::f("emitte") ; Fixes 3 words
:B0X*:emne::f("enme") ; Fixes 7 words
:B0X*:emphysyma::f("emphysema") ; Fixes 3 words
:B0X*:empirial::f("imperial") ; Fixes 18 words
:B0X*:emporer::f("emperor") ; Fixes 4 words
:B0X*:enameld::f("enamelled") ; Fixes 1 word
:B0X*:enchanc::f("enhanc") ; Fixes 9 words
:B0X*:encylop::f("encyclop") ; Fixes 16 word
:B0X*:endevors::f("endeavors") ; Fixes 8 words
:B0X*:endire::f("entire") ; Fixes 7 words 
:B0X*:endolithe::f("endolith") ; Fixes 2 words
:B0X*:ened::f("need") ; Fixes 44 words
:B0X*:enlargment::f("enlargement") ; Fixes 2 words
:B0X*:enlish::f("English") ; Fixes 8 words
:B0X*:enought::f("enough") ; Fixes 1 word
:B0X*:enourmous::f("enormous") ; Fixes 3 words
:B0X*:enscons::f("ensconc") ; Fixes 4 words
:B0X*:enteratin::f("entertain") ; Fixes 10 words
:B0X*:entrepeneur::f("entrepreneur") ; Fixes 7 words
:B0X*:enviorment::f("environment") ; Fixes 8 words
:B0X*:enviorn::f("environ") ; Fixes 12 words
:B0X*:envirom::f("environm") ; Fixes 8 words
:B0X*:envrion::f("environ") ; Fixes 8 words
:B0X*:epidsod::f("episod") ; Fixes 6 words
:B0X*:epsiod::f("episod") ; Fixes 6 words
:B0X*:equitor::f("equator") ; Fixes 5 words
:B0X*:eral::f("real") ; Fixes 74 words
:B0X*:eratic::f("erratic") ; Fixes 4 words
:B0X*:erest::f("arrest") ; Fixes 14 words
:B0X*:errupt::f("erupt") ; Fixes 6 words
:B0X*:escta::f("ecsta") ; Fixes 5 words
:B0X*:esle::f("else") ; Fixes 3 words
:B0X*:europian::f("European") ; Fixes 15 words
:B0X*:eurpean::f("European") ; Fixes 15 words
:B0X*:eurpoean::f("European") ; Fixes 15 words
:B0X*:evental::f("eventual") ; Fixes 4 words
:B0X*:eventhough::f("even though") ; Fixes 1 word
:B0X*:evential::f("eventual") ; Fixes 4 words
:B0X*:everthing::f("everything") ; Fixes 1 word
:B0X*:everytime::f("every time") ; Fixes 1 word
:B0X*:everyting::f("everything") ; Fixes 1 word
:B0X*:evesdrop::f("eavesdrop") ; Fixes 6 words 
:B0X*:excede::f("exceed") ; Fixes 8 words
:B0X*:excelen::f("excellen") ; Fixes 9 words
:B0X*:excellan::f("excellen") ; Fixes 9 words
:B0X*:excells::f("excels") ; Fixes 1 word
:B0X*:exection::f("execution") ; Fixes 5 words
:B0X*:exectued::f("executed") ; Fixes 1 word
:B0X*:exelen::f("excellen") ; Fixes 9 words
:B0X*:exellen::f("excellen") ; Fixes 9 words
:B0X*:exemple::f("example") ; Fixes 1 word
:B0X*:exerbat::f("exacerbat") ; Fixes 7 words
:B0X*:exerciese::f("exercises") ; Fixes 1 word
:B0X*:exerpt::f("excerpt") ; Fixes 6 words
:B0X*:exerternal::f("external") ; Fixes 22 words
:B0X*:exhalt::f("exalt") ; Fixes 10 words
:B0X*:exhibt::f("exhibit") ; Fixes 20 words
:B0X*:exibit::f("exhibit") ; Fixes 20 words
:B0X*:exilera::f("exhilara") ; Fixes 9 words
:B0X*:existince::f("existence") ; Fixes 1 word
:B0X*:exlud::f("exclud") ; Fixes 7 words
:B0X*:exonorat::f("exonerat") ; Fixes 7 words
:B0X*:expatriot::f("expatriate") ; Fixes 1 word
:B0X*:expeditonary::f("expeditionary") ; Fixes 1 word
:B0X*:expeiment::f("experiment") ; Fixes 14 words
:B0X*:explainat::f("explanat") ; Fixes 7 words
:B0X*:explaning::f("explaining") ; Fixes 1 word
:B0X*:exteme::f("extreme") ; Fixes 6 words
:B0X*:extered::f("exerted") ; Fixes 1 word
:B0X*:extermist::f("extremist") ; Fixes 1 word
:B0X*:extract punishment::f("exact punishment") ; Fixes 1 word
:B0X*:extract revenge::f("exact revenge") ; Fixes 1 word
:B0X*:extradiction::f("extradition") ; Fixes 1 word
:B0X*:extravagent::f("extravagant") ; Fixes 3 words
:B0X*:extrememly::f("extremely") ; Fixes 1 word
:B0X*:extremeophile::f("extremophile") ; Fixes 1 word
:B0X*:extremly::f("extremely") ; Fixes 1 word
:B0X*:extrordinar::f("extraordinar") ; Fixes 3 words
:B0X*:eyar::f("year") ; Fixes 17 words
:B0X*:eye brow::f("eyebrow") ; Fixes 1 word
:B0X*:eye lash::f("eyelash") ; Fixes 1 word
:B0X*:eye lid::f("eyelid") ; Fixes 1 word
:B0X*:eye sight::f("eyesight") ; Fixes 1 word
:B0X*:eye sore::f("eyesore") ; Fixes 1 word
:B0X*:faciliat::f("facilitat") ; Fixes 10 words
:B0X*:facilites::f("facilities") ; Fixes 1 word
:B0X*:facillitat::f("facilitat") ; Fixes 10 words
:B0X*:facinat::f("fascinat") ; Fixes 10 words
:B0X*:faetur::f("featur") ; Fixes 6 words
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
:B0X*:faired well::f("fared well") ; Fixes 1 word
:B0X*:faired worse::f("fared worse") ; Fixes 1 word
:B0X*:familes::f("families") ; Fixes 1 word
:B0X*:fanatism::f("fanaticism") ; Fixes 1 word
:B0X*:farenheit::f("Fahrenheit") ; Fixes 1 word
:B0X*:farther then::f("farther than") ; Fixes 1 word
:B0X*:faster then::f("faster than") ; Fixes 1 word
:B0X*:febuary::f("February") ; Fixes 1 word
:B0X*:femail::f("female") ; Fixes 1 word
:B0X*:feromone::f("pheromone") ; Fixes 1 word
:B0X*:fianlly::f("finally") ; Fixes 1 word
:B0X*:ficed::f("fixed") ; Fixes 1 word
:B0X*:fiercly::f("fiercely") ; Fixes 1 word
:B0X*:fightings::f("fighting") ; Fixes 1 word
:B0X*:figure head::f("figurehead") ; Fixes 1 word
:B0X*:filled a lawsuit::f("filed a lawsuit") ; Fixes 1 word
:B0X*:finaly::f("finally") ; Fixes 1 word
:B0X*:firey::f("fiery") ; Fixes 1 word
:B0X*:flag ship::f("flagship") ; Fixes 1 word
:B0X*:fleed::f("freed") ; Fixes 4 words
:B0X*:florescent::f("fluorescent") ; Fixes 1 word
:B0X*:flourescent::f("fluorescent") ; Fixes 1 word
:B0X*:follow suite::f("follow suit") ; Fixes 1 word
:B0X*:following it's::f("following its") ; Fixes 1 word
:B0X*:for all intensive purposes::f("for all intents and purposes") ; Fixes 1 word
:B0X*:for along time::f("for a long time") ; Fixes 1 word
:B0X*:for awhile::f("for a while") ; Fixes 1 word
:B0X*:for quite awhile::f("for quite a while") ; Fixes 1 word
:B0X*:for way it's::f("for what it's") ; Fixes 1 word
:B0X*:fore ground::f("foreground") ; Fixes 1 word
:B0X*:forego her::f("forgo her") ; Fixes 1 word
:B0X*:forego his::f("forgo his") ; Fixes 1 word
:B0X*:forego their::f("forgo their") ; Fixes 1 word
:B0X*:foreward::f("foreword") ; Fixes 1 word
:B0X*:forgone conclusion::f("foregone conclusion") ; Fixes 1 word
:B0X*:forhe::f("forehe") ; Fixes 5 words
:B0X*:formalhaut::f("Fomalhaut") ; Fixes 1 word
:B0X*:formelly::f("formerly") ; Fixes 1 word
:B0X*:forsaw::f("foresaw") ; Fixes 1 word
:B0X*:fortell::f("foretell") ; Fixes 5 words
:B0X*:forunner::f("forerunner") ; Fixes 1 word
:B0X*:foundar::f("foundr") ; Fixes 5 words
:B0X*:fouth::f("fourth") ; Fixes 3 words
:B0X*:fransiscan::f("Franciscan") ; Fixes 3 words
:B0X*:friut::f("fruit") ; Fixes 32 words
:B0X*:fromt he::f("from the") ; Fixes 1 word
:B0X*:froniter::f("frontier") ; Fixes 6 words
:B0X*:fued::f("feud") ; Fixes 28 words
:B0X*:fuhrer::f("Führer") ; Fixes 2 words
:B0X*:fulfiled::f("fulfilled") ; Fixes 1 word
:B0X*:full compliment of::f("full complement of") ; Fixes 1 word
:B0X*:funguses::f("fungi") ; Fixes 1 word
:B0X*:furner::f("funer") ; Fixes 6 words
:B0X*:futhe::f("furthe") ; Fixes 10 words
:B0X*:fwe::f("few") ; Fixes 5 words
:B0X*:galatic::f("galactic") ; Fixes 1 word
:B0X*:galations::f("Galatians") ; Fixes 1 word
:B0X*:gameboy::f("Game Boy") ; Fixes 1 word
:B0X*:ganes::f("games") ; Fixes 1 word
:B0X*:ganst::f("gangst") ; Fixes 6 words
:B0X*:gaol::f("goal") ; Fixes 22 words ; Misspells British spelling of "jail"
:B0X*:gauarana::f("guarana") ; Fixes 1 word
:B0X*:gauren::f("guaran") ; Fixes 15 words
:B0X*:gave advise::f("gave advice") ; Fixes 1 word
:B0X*:geneer::f("gender") ; Fixes 10 words 
:B0X*:geneolog::f("genealog") ; Fixes 7 words
:B0X*:genialia::f("genitalia") ; Fixes 1 word
:B0X*:gentlemens::f("gentlemen's") ; Fixes 1 word
:B0X*:gerat::f("great") ; Fixes 12 words
:B0X*:get setup::f("get set up") ; Fixes 1 word
:B0X*:get use to::f("get used to") ; Fixes 1 word
:B0X*:geting::f("getting") ; Fixes 1 word
:B0X*:gets it's::f("gets its") ; Fixes 1 word
:B0X*:getting use to::f("getting used to") ; Fixes 1 word
:B0X*:ghandi::f("Gandhi") ; Fixes 1 word
:B0X*:girat::f("gyrat") ; Fixes 9 words
:B0X*:give advise::f("give advice") ; Fixes 1 word
:B0X*:gives advise::f("gives advice") ; Fixes 1 word
:B0X*:glamourous::f("glamorous") ; Fixes 1 word
:B0X*:gloabl::f("global") ; Fixes 18 words
:B0X*:gnaww::f("gnaw") ; Fixes 8 words
:B0X*:going threw::f("going through") ; Fixes 1 word
:B0X*:got ran::f("got run") ; Fixes 1 word
:B0X*:got setup::f("got set up") ; Fixes 1 word
:B0X*:got shutdown::f("got shut down") ; Fixes 1 word
:B0X*:got shutout::f("got shut out") ; Fixes 1 word
:B0X*:gouvener::f("governor") ; Fixes 6 words
:B0X*:governer::f("governor") ; Fixes 6 words
:B0X*:graet::f("great") ; Fixes 12 words
:B0X*:grafitti::f("graffiti") ; Fixes 5 words
:B0X*:grammer::f("grammar") ; Fixes 1 word
:B0X*:greater then::f("greater than") ; Fixes 1 word
:B0X*:greif::f("grief") ; Fixes 1 word
:B0X*:gridle::f("griddle") ; Fixes 5 words
:B0X*:ground work::f("groundwork") ; Fixes 1 word
:B0X*:guadulupe::f("Guadalupe") ; Fixes 1 word
:B0X*:guage::f("gauge") ; Fixes 6 words
:B0X*:guatamala::f("Guatemala") ; Fixes 1 word
:B0X*:guerrila::f("guerrilla") ; Fixes 2 words
:B0X*:guest stared::f("guest-starred") ; Fixes 1 word
:B0X*:guidlin::f("guidelin") ; Fixes 2 words
:B0X*:guiliani::f("Giuliani") ; Fixes 1 word
:B0X*:guilio::f("Giulio") ; Fixes 1 word
:B0X*:guiness::f("Guinness") ; Fixes 1 word
:B0X*:guiseppe::f("Giuseppe") ; Fixes 1 word
:B0X*:gunanine::f("guanine") ; Fixes 1 word ; It's in bat poop. LOL 
:B0X*:gusy::f("guys") ; Fixes 1 word
:B0X*:gutteral::f("guttural") ; Fixes 4 words
:B0X*:habaeus::f("habeas") ; Fixes 1 word
:B0X*:habbit::f("habit") ; Fixes 31 words
:B0X*:habeus::f("habeas") ; Fixes 1 word
:B0X*:habsbourg::f("Habsburg") ; Fixes 1 word
:B0X*:had arose::f("had arisen") ; Fixes 1 word
:B0X*:had became::f("had become") ; Fixes 1 word
:B0X*:had began::f("had begun") ; Fixes 1 word
:B0X*:had being::f("had been") ; Fixes 1 word
:B0X*:had brung::f("had brought") ; Fixes 1 word
:B0X*:had came::f("had come") ; Fixes 1 word
:B0X*:had comeback::f("had come back") ; Fixes 1 word
:B0X*:had cut-off::f("had cut off") ; Fixes 1 word
:B0X*:had did::f("had done") ; Fixes 1 word
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
:B0X*:had meet::f("had met") ; Fixes 1 word
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
:B0X*:hadn't went::f("hadn't gone") ; Fixes 1 word
:B0X*:haemorrage::f("haemorrhage") ; Fixes 3 words
:B0X*:haev::f("have") ; Fixes 1 word
:B0X*:halarious::f("hilarious") ; Fixes 3 words
:B0X*:half and hour::f("half an hour") ; Fixes 1 word
:B0X*:hallowean::f("Halloween") ; Fixes 1 word
:B0X*:halp::f("help") ; Fixes 21 words
:B0X*:hand the reigns::f("hand the reins") ; Fixes 1 word
:B0X*:hapen::f("happen") ; Fixes 7 words
:B0X*:harases::f("harasses") ; Fixes 1 word
:B0X*:harasm::f("harassm") ; Fixes 2 words
:B0X*:harassement::f("harassment") ; Fixes 2 words
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
:B0X*:has meet::f("has met") ; Fixes 1 word
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
:B0X*:have rang::f("have rung") ; Fixes 1 word
:B0X*:have sang::f("have sung") ; Fixes 1 word
:B0X*:have setup::f("have set up") ; Fixes 1 word
:B0X*:have sprang::f("have sprung") ; Fixes 1 word
:B0X*:have took::f("have taken") ; Fixes 1 word
:B0X*:have underwent::f("have undergone") ; Fixes 1 word
:B0X*:have went::f("have gone") ; Fixes 1 word
:B0X*:havebeen::f("have been") ; Fixes 1 word
:B0X*:haviest::f("heaviest") ; Fixes 1 word
:B0X*:having became::f("having become") ; Fixes 1 word
:B0X*:having began::f("having begun") ; Fixes 1 word
:B0X*:having being::f("having been") ; Fixes 1 word
:B0X*:having it's::f("having its") ; Fixes 1 word
:B0X*:having sang::f("having sung") ; Fixes 1 word
:B0X*:having setup::f("having set up") ; Fixes 1 word
:B0X*:having took::f("having taken") ; Fixes 1 word
:B0X*:having underwent::f("having undergone") ; Fixes 1 word
:B0X*:having went::f("having gone") ; Fixes 1 word
:B0X*:hay day::f("heyday") ; Fixes 1 word
:B0X*:hda::f("had") ; Fixes 28 words
:B0X*:he begun::f("he began") ; Fixes 1 word
:B0X*:he let's::f("he lets") ; Fixes 1 word
:B0X*:he seen::f("he saw") ; Fixes 1 word
:B0X*:he use to::f("he used to") ; Fixes 1 word
:B0X*:he's drank::f("he drank") ; Fixes 1 word
:B0X*:head gear::f("headgear") ; Fixes 1 word
:B0X*:head quarters::f("headquarters") ; Fixes 1 word
:B0X*:head stone::f("headstone") ; Fixes 1 word
:B0X*:head wear::f("headwear") ; Fixes 1 word
:B0X*:headquarer::f("headquarter") ; Fixes 4 words
:B0X*:healther::f("health") ; Fixes 11 words
:B0X*:heared::f("heard") ; Fixes 1 word
:B0X*:heathy::f("healthy") ; Fixes 1 word
:B0X*:heidelburg::f("Heidelberg") ; Fixes 1 word
:B0X*:heigher::f("higher") ; Fixes 1 word
:B0X*:held the reigns::f("held the reins") ; Fixes 1 word
:B0X*:helf::f("held") ; Fixes 1 word
:B0X*:hellow::f("hello") ; Fixes 1 word
:B0X*:helment::f("helmet") ; Fixes 5 words
:B0X*:help and make::f("help to make") ; Fixes 1 word
:B0X*:helpfull::f("helpful") ; Fixes 1 word
:B0X*:hemmorhage::f("hemorrhage") ; Fixes 3 words
:B0X*:herf::f("href") ; Fixes 1 word
:B0X*:heroe::f("hero") ; Fixes 1 word
:B0X*:heros::f("heroes") ; Fixes 1 word
:B0X*:hersuit::f("hirsute") ; Fixes 1 word
:B0X*:hesaid::f("he said") ; Fixes 1 word
:B0X*:hesista::f("hesita") ; Fixes 19 words
:B0X*:heterogenous::f("heterogeneous") ; Fixes 1 word
:B0X*:hewas::f("he was") ; Fixes 1 word
:B0X*:hge::f("he") ; Fixes 1607 words
:B0X*:higer::f("higher") ; Fixes 1 word
:B0X*:higest::f("highest") ; Fixes 1 word
:B0X*:higher then::f("higher than") ; Fixes 1 word
:B0X*:himselv::f("himself") ; Fixes 1 word
:B0X*:hinderance::f("hindrance") ; Fixes 1 word
:B0X*:hinderence::f("hindrance") ; Fixes 1 word
:B0X*:hindrence::f("hindrance") ; Fixes 1 word
:B0X*:hipopotamus::f("hippopotamus") ; Fixes 1 word
:B0X*:his resent::f("his recent") ; Fixes 1 word ; not good for 'her' 
:B0X*:hismelf::f("himself") ; Fixes 1 word
:B0X*:hit the breaks::f("hit the brakes") ; Fixes 1 word
:B0X*:hitsingles::f("hit singles") ; Fixes 1 word
:B0X*:hlep::f("help") ; Fixes 21 words
:B0X*:hold onto::f("hold on to") ; Fixes 1 word
:B0X*:hold the reigns::f("hold the reins") ; Fixes 1 word
:B0X*:holding the reigns::f("holding the reins") ; Fixes 1 word
:B0X*:holds the reigns::f("holds the reins") ; Fixes 1 word
:B0X*:holliday::f("holiday") ; Fixes 6 words
:B0X*:homestate::f("home state") ; Fixes 1 word
:B0X*:hone in on::f("home in on") ; Fixes 1 word
:B0X*:honed in::f("homed in") ; Fixes 1 word
:B0X*:honory::f("honorary") ; Fixes 1 word
:B0X*:honourarium::f("honorarium") ; Fixes 1 word
:B0X*:honourific::f("honorific") ; Fixes 1 word
:B0X*:hosit::f("hoist") ; Fixes 6 words
:B0X*:hostring::f("hotstring")
:B0X*:hotring::f("hotstring") ; Fixes 2 words
:B0X*:hotsring::f("hotstring")
:B0X*:hotter then::f("hotter than") ; Fixes 1 word
:B0X*:house hold::f("household") ; Fixes 1 word
:B0X*:housr::f("hours") ; Fixes 1 word
:B0X*:hsa::f("has") ; Fixes 64 words
:B0X*:hte::f("the") ; Fixes 402 words
:B0X*:hti::f("thi") ; Fixes 186 words
:B0X*:huminoid::f("humanoid") ; Fixes 1 word
:B0X*:humoural::f("humoral") ; Fixes 1 word
:B0X*:hwi::f("whi") ; Fixes 310 words
:B0X*:hwo::f("who") ; Fixes 76 words
:B0X*:hydropile::f("hydrophile") ; Fixes 1 word
:B0X*:hydropilic::f("hydrophilic") ; Fixes 1 word
:B0X*:hydropobe::f("hydrophobe") ; Fixes 1 word
:B0X*:hydropobic::f("hydrophobic") ; Fixes 1 word
:B0X*:hygein::f("hygien") ; Fixes 18 words
:B0X*:hyjack::f("hijack") ; Fixes 7 words
:B0X*:hypocracy::f("hypocrisy") ; Fixes 1 word
:B0X*:hypocrasy::f("hypocrisy") ; Fixes 1 word
:B0X*:hypocricy::f("hypocrisy") ; Fixes 1 word
:B0X*:hypocrits::f("hypocrites") ; Fixes 1 word
:B0X*:i snot::f("is not") ; Fixes 1 word
:B0X*:i"m::f("I'm") ; Fixes 1 word
:B0X*:i;d::f("I'd") ; Fixes 1 word
:B0X*:iconclas::f("iconoclas") ; Fixes 6 words
:B0X*:idae::f("idea") ; Fixes 40 words
:B0X*:idealogi::f("ideologi") ; Fixes 7 words
:B0X*:idealogy::f("ideology") ; Fixes 1 word
:B0X*:identifer::f("identifier") ; Fixes 2 words
:B0X*:ideosyncratic::f("idiosyncratic") ; Fixes 1 word
:B0X*:idesa::f("ideas") ; Fixes 1 word
:B0X*:idiosyncracy::f("idiosyncrasy") ; Fixes 1 word
:B0X*:ifb y::f("if by") ; Fixes 1 word
:B0X*:ifi t::f("if it") ; Fixes 1 word
:B0X*:ift he::f("if the") ; Fixes 1 word
:B0X*:ignorence::f("ignorance") ; Fixes 1 word
:B0X*:ihaca::f("Ithaca") ; Fixes 1 word
:B0X*:iits the::f("it's the") ; Fixes 1 word
:B0X*:illegim::f("illegitim") ; Fixes 6 words
:B0X*:illess::f("illness") ; Fixes 1 word
:B0X*:illicited::f("elicited") ; Fixes 1 word
:B0X*:illieg::f("illeg") ; Fixes 27 words
:B0X*:ilness::f("illness") ; Fixes 1 word
:B0X*:ilog::f("illog") ; Fixes 7 words
:B0X*:ilu::f("illu") ; Fixes 61 words
:B0X*:imaginery::f("imaginary") ; Fixes 1 word
:B0X*:iman::f("immin") ; Fixes 11 words
:B0X*:imcom::f("incom") ; Fixes 78 words
:B0X*:imigra::f("immigra") ; Fixes 8 words
:B0X*:immida::f("immedia") ; Fixes 5 words
:B0X*:immidia::f("immedia") ; Fixes 5 words
:B0X*:imminent domain::f("eminent domain") ; Fixes 1 word
:B0X*:impecab::f("impecca") ; Fixes 6 words
:B0X*:impedence::f("impedance") ; Fixes 2 words
:B0X*:impressa::f("impresa") ; Fixes 4 words
:B0X*:improvision::f("improvisation") ; Fixes 4 words
:B0X*:in along time::f("in a long time") ; Fixes 1 word
:B0X*:in anyway::f("in any way") ; Fixes 1 word
:B0X*:in awhile::f("in a while") ; Fixes 1 word
:B0X*:in edition to::f("in addition to") ; Fixes 1 word
:B0X*:in lu of::f("in lieu of") ; Fixes 1 word
:B0X*:in masse::f("en masse") ; Fixes 1 word
:B0X*:in parenthesis::f("in parentheses") ; Fixes 1 word
:B0X*:in placed::f("in place") ; Fixes 1 word
:B0X*:in principal::f("in principle") ; Fixes 1 word
:B0X*:in quite awhile::f("in quite a while") ; Fixes 1 word
:B0X*:in regards to::f("in regard to") ; Fixes 1 word
:B0X*:in stead of::f("instead of") ; Fixes 1 word
:B0X*:in tact::f("intact") ; Fixes 1 word
:B0X*:in the long-term::f("in the long term") ; Fixes 1 word
:B0X*:in the short-term::f("in the short term") ; Fixes 1 word
:B0X*:in titled::f("entitled") ; Fixes 1 word
:B0X*:in vein::f("in vain") ; Fixes 1 word
:B0X*:inagura::f("inaugura") ; Fixes 11 words
:B0X*:inate::f("innate") ; Fixes 3 words
:B0X*:inaugure::f("inaugurate") ; Fixes 3 words
:B0X*:inbalance::f("imbalance") ; Fixes 3 words
:B0X*:inbetween::f("between") ; Fixes 1 word
:B0X*:incase of::f("in case of") ; Fixes 1 word
:B0X*:incidently::f("incidentally") ; Fixes 1 word
:B0X*:incread::f("incred") ; Fixes 10 words
:B0X*:incuding::f("including") ; Fixes 1 word
:B0X*:indefineab::f("undefinab") ; Fixes 4 words
:B0X*:indentical::f("identical") ; Fixes 1 word
:B0X*:indesp::f("indisp") ; Fixes 16 words
:B0X*:indictement::f("indictment") ; Fixes 1 word
:B0X*:indigine::f("indigen") ; Fixes 24 words
:B0X*:inevatibl::f("inevitabl") ; Fixes 4 words
:B0X*:inevitib::f("inevitab") ; Fixes 6 words
:B0X*:inevititab::f("inevitab") ; Fixes 6 words
:B0X*:infact::f("in fact") ; Fixes 1 word
:B0X*:infered::f("inferred") ; Fixes 1 word
:B0X*:influented::f("influenced") ; Fixes 1 word
:B0X*:ingreediants::f("ingredients") ; Fixes 1 word
:B0X*:inmigra::f("immigra") ; Fixes 8 words
:B0X*:inocenc::f("innocenc") ; Fixes 4 words
:B0X*:inofficial::f("unofficial") ; Fixes 3 words
:B0X*:inot::f("into") ; Fixes 36 words
:B0X*:inpen::f("impen") ; Fixes 22 words
:B0X*:inperson::f("in-person") ; Fixes 1 word
:B0X*:inspite::f("in spite") ; Fixes 1 word
:B0X*:int he::f("in the") ; Fixes 1 word
:B0X*:interbread::f("interbred") ; Fixes 1 word
:B0X*:intered::f("interred") ; Fixes 1 word
:B0X*:interelat::f("interrelat") ; Fixes 10 words
:B0X*:interm::f("interim") ; Fixes 1 word
:B0X*:interrim::f("interim") ; Fixes 1 word
:B0X*:interrugum::f("interregnum") ; Fixes 1 word
:B0X*:intertain::f("entertain") ; Fixes 10 words
:B0X*:interum::f("interim") ; Fixes 1 word
:B0X*:intervines::f("intervenes") ; Fixes 1 word
:B0X*:intial::f("initial") ; Fixes 25 words
:B0X*:into affect::f("into effect") ; Fixes 1 word
:B0X*:into it's::f("into its") ; Fixes 1 word
:B0X*:introdued::f("introduced") ; Fixes 1 word
:B0X*:intrument::f("instrument") ; Fixes 19 words
:B0X*:intrust::f("entrust") ; Fixes 4 words
:B0X*:inumer::f("innumer") ; Fixes 8 words
:B0X*:inventer::f("inventor") ; Fixes 6 words
:B0X*:invision::f("envision") ; Fixes 4 words 
:B0X*:inwhich::f("in which") ; Fixes 1 word
:B0X*:iresis::f("irresis") ; Fixes 9 words 
:B0X*:iritab::f("irritab") ; Fixes 5 words
:B0X*:iritat::f("irritat") ; Fixes 12 words
:B0X*:irregardless::f("regardless") ; Fixes 1 word
:B0X*:is front of::f("in front of") ; Fixes 1 word
:B0X*:is it's::f("is its") ; Fixes 1 word
:B0X*:is lead by::f("is led by") ; Fixes 1 word
:B0X*:is loathe to::f("is loath to") ; Fixes 1 word
:B0X*:is ran by::f("is run by") ; Fixes 1 word
:B0X*:is renown for::f("is renowned for") ; Fixes 1 word
:B0X*:is schedule to::f("is scheduled to") ; Fixes 1 word
:B0X*:is set-up::f("is set up") ; Fixes 1 word
:B0X*:is setup::f("is set up") ; Fixes 1 word
:B0X*:is use to::f("is used to") ; Fixes 1 word
:B0X*:is were::f("is where") ; Fixes 1 word
:B0X*:isnt::f("isn't") ; Fixes 1 word
:B0X*:it begun::f("it began") ; Fixes 1 word
:B0X*:it lead to::f("it led to") ; Fixes 1 word
:B0X*:it set-up::f("it set up") ; Fixes 1 word
:B0X*:it setup::f("it set up") ; Fixes 1 word
:B0X*:it snot::f("it's not") ; Fixes 1 word
:B0X*:it spend::f("it spent") ; Fixes 1 word
:B0X*:it use to::f("it used to") ; Fixes 1 word
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
:B0X*:itr::f("it") ; Fixes 101 words, but misspells itraconazole (Antifungal drug). 
:B0X*:its a::f("it's a") ; Fixes 1 word
:B0X*:its the::f("it's the") ; Fixes 1 word
:B0X*:itwas::f("it was") ; Fixes 1 word
:B0X*:iunior::f("junior") ; Fixes 1 word
:B0X*:jeapard::f("jeopard") ; Fixes 13 words
:B0X*:jewelery::f("jewelry") ; Fixes 1 word
:B0X*:jive with::f("jibe with") ; Fixes 1 word
:B0X*:johanine::f("Johannine") ; Fixes 1 word
:B0X*:jorunal::f("journal") ; Fixes 1 word
:B0X*:jospeh::f("Joseph") ; Fixes 1 word
:B0X*:jouney::f("journey") ; Fixes 9 words
:B0X*:journied::f("journeyed") ; Fixes 1 word
:B0X*:journies::f("journeys") ; Fixes 1 word
:B0X*:juadaism::f("Judaism") ; Fixes 1 word
:B0X*:juadism::f("Judaism") ; Fixes 1 word
:B0X*:key note::f("keynote") ; Fixes 1 word
:B0X*:klenex::f("kleenex") ; Fixes 1 word
:B0X*:knifes::f("knives") ; Fixes 1 word
:B0X*:knive::f("knife") ; Fixes 1 word
:B0X*:kwwp::f("keep") ; Fixes 1 word 
:B0X*:lable::f("label") ; Fixes 12 words
:B0X*:labratory::f("laboratory") ; Fixes 1 word
:B0X*:lack there of::f("lack thereof") ; Fixes 1 word
:B0X*:laid ahead::f("lay ahead") ; Fixes 1 word
:B0X*:laid dormant::f("lay dormant") ; Fixes 1 word
:B0X*:laid empty::f("lay empty") ; Fixes 1 word
:B0X*:larger then::f("larger than") ; Fixes 1 word
:B0X*:largley::f("largely") ; Fixes 1 word
:B0X*:largst::f("largest") ; Fixes 1 word
:B0X*:lasoo::f("lasso") ; Fixes 8 words
:B0X*:lastr::f("last") ; Fixes 1 word
:B0X*:lastyear::f("last year") ; Fixes 1 word
:B0X*:laughing stock::f("laughingstock") ; Fixes 1 word
:B0X*:lavae::f("larvae") ; Fixes 1 word
:B0X*:law suite::f("lawsuit") ; Fixes 1 word
:B0X*:lay low::f("lie low") ; Fixes 1 word
:B0X*:layed::f("laid") ; Fixes 1 word
:B0X*:laying around::f("lying around") ; Fixes 1 word
:B0X*:laying awake::f("lying awake") ; Fixes 1 word
:B0X*:laying low::f("lying low") ; Fixes 1 word
:B0X*:lays atop::f("lies atop") ; Fixes 1 word
:B0X*:lays beside::f("lies beside") ; Fixes 1 word
:B0X*:lays in::f("lies in") ; Fixes 1 word
:B0X*:lays low::f("lies low") ; Fixes 1 word
:B0X*:lays near::f("lies near") ; Fixes 1 word
:B0X*:lays on::f("lies on") ; Fixes 1 word
:B0X*:lazer::f("laser") ; Fixes 4 words
:B0X*:lead by::f("led by") ; Fixes 1 word
:B0X*:lead roll::f("lead role") ; Fixes 1 word
:B0X*:leading roll::f("leading role") ; Fixes 1 word
:B0X*:leage::f("league") ; Fixes 7 words
:B0X*:lefr::f("left") ; Fixes 22 words
:B0X*:lefted::f("left") ; Fixes 1 word
:B0X*:leran::f("learn") ; Fixes 13 words
:B0X*:less dominate::f("less dominant") ; Fixes 1 word
:B0X*:less that::f("less than") ; Fixes 1 word
:B0X*:less then::f("less than") ; Fixes 1 word
:B0X*:lesser then::f("less than") ; Fixes 1 word
:B0X*:leutenan::f("lieutenan") ; Fixes 4 words
:B0X*:levle::f("level") ; Fixes 24 words
:B0X*:lias::f("liais") ; Fixes 6 words, Case-sensitive to not misspell Lias (One of the Jurrasic periods.)
:B0X*:libary::f("library") ; Fixes 1 word
:B0X*:libell::f("libel") ; Fixes 18 words
:B0X*:libitarianisn::f("libertarianism") ; Fixes 1 word
:B0X*:lible::f("libel") ; Fixes 18 words
:B0X*:librer::f("librar") ; Fixes 6 words
:B0X*:licence::f("license") ; Fixes 1 word
:B0X*:liesure::f("leisure") ; Fixes 5 words
:B0X*:liev::f("live") ; Fixes 58 words
:B0X*:life time::f("lifetime") ; Fixes 1 word
:B0X*:liftime::f("lifetime") ; Fixes 1 word
:B0X*:lighter then::f("lighter than") ; Fixes 1 word
:B0X*:lightyear::f("light year") ; Fixes 1 word
:B0X*:line of site::f("line of sight") ; Fixes 1 word
:B0X*:line-of-site::f("line-of-sight") ; Fixes 1 word
:B0X*:linnaena::f("Linnaean") ; Fixes 1 word
:B0X*:lions share::f("lion's share") ; Fixes 1 word
:B0X*:liquif::f("liquef") ; Fixes 11 words
:B0X*:litature::f("literature") ; Fixes 1 word
:B0X*:lonelyness::f("loneliness") ; Fixes 1 word
:B0X*:loosing effort::f("losing effort") ; Fixes 1 word
:B0X*:loosing record::f("losing record") ; Fixes 1 word
:B0X*:loosing season::f("losing season") ; Fixes 1 word
:B0X*:loosing streak::f("losing streak") ; Fixes 1 word
:B0X*:loosing team::f("losing team") ; Fixes 1 word
:B0X*:loosing to::f("losing to") ; Fixes 1 word
:B0X*:lower that::f("lower than") ; Fixes 1 word
:B0X*:lower then::f("lower than") ; Fixes 1 word
:B0X*:lsat::f("last") ; Fixes 11 words
:B0X*:lsit::f("list") ; Fixes 30 words
:B0X*:lveo::f("love") ; Fixes 42 words
:B0X*:lvoe::f("love") ; Fixes 42 words
:B0X*:lybia::f("Libya") ; Fixes 3 words
:B0X*:machinary::f("machinery") ; Fixes 1 word
:B0X*:maching::f("matching") ; Fixes 1 word
:B0X*:mackeral::f("mackerel") ; Fixes 1 word
:B0X*:made it's::f("made its") ; Fixes 1 word
:B0X*:magasine::f("magazine") ; Fixes 1 word
:B0X*:maginc::f("magic") ; Fixes 9 words
:B0X*:magizine::f("magazine") ; Fixes 1 word
:B0X*:magnificien::f("magnificen") ; Fixes 5 words
:B0X*:magol::f("magnol") ; Fixes 7 words
:B0X*:maintance::f("maintenance") ; Fixes 1 word
:B0X*:major roll::f("major role") ; Fixes 1 word
:B0X*:make due::f("make do") ; Fixes 1 word
:B0X*:make it's::f("make its") ; Fixes 1 word
:B0X*:malcom::f("Malcolm") ; Fixes 1 word
:B0X*:manisf::f("manif") ; Fixes 17 words
:B0X*:marrtyr::f("martyr") ; Fixes 23 words
:B0X*:massachussets::f("Massachusetts") ; Fixes 1 word
:B0X*:massachussetts::f("Massachusetts") ; Fixes 1 word
:B0X*:massmedia::f("mass media") ; Fixes 1 word
:B0X*:masterbat::f("masturbat") ; Fixes 9 words
:B0X*:mataph::f("metaph") ; Fixes 18 words
:B0X*:materalist::f("materialist") ; Fixes 2 word
:B0X*:mathematican::f("mathematician") ; Fixes 2 word
:B0X*:mathetician::f("mathematician") ; Fixes 2 word
:B0X*:mean while::f("meanwhile") ; Fixes 1 word
:B0X*:mechandi::f("merchandi") ; Fixes 12 words
:B0X*:medievel::f("medieval") ; Fixes 1 word
:B0X*:mediteranean::f("Mediterranean") ; Fixes 1 word
:B0X*:meerkrat::f("meerkat") ; Fixes 1 word
:B0X*:melieux::f("milieux") ; Fixes 1 word
:B0X*:membranaphone::f("membranophone") ; Fixes 1 word
:B0X*:menally::f("mentally") ; Fixes 1 word
:B0X*:mercentil::f("mercantil") ; Fixes 7 words
:B0X*:mesag::f("messag") ; Fixes 5 words
:B0X*:messenging::f("messaging") ; Fixes 1 word
:B0X*:meterolog::f("meteorolog") ; Fixes 7 words
:B0X*:michagan::f("Michigan") ; Fixes 1 word
:B0X*:micheal::f("Michael") ; Fixes 1 word
:B0X*:micos::f("micros") ; Fixes 40 words
:B0X*:miligram::f("milligram") ; Fixes 1 word
:B0X*:milion::f("million") ; Fixes 9 words
:B0X*:milleni::f("millenni") ; Fixes 9 words
:B0X*:millepede::f("millipede") ; Fixes 1 word
:B0X*:miniscule::f("minuscule") ; Fixes 1 word
:B0X*:ministery::f("ministry") ; Fixes 1 word
:B0X*:minor roll::f("minor role") ; Fixes 1 word
:B0X*:minstries::f("ministries") ; Fixes 1 word
:B0X*:minstry::f("ministry") ; Fixes 1 word
:B0X*:minumum::f("minimum") ; Fixes 1 word
:B0X*:mirrorr::f("mirror") ; Fixes 6 words
:B0X*:miscellanious::f("miscellaneous") ; Fixes 3 words
:B0X*:miscellanous::f("miscellaneous") ; Fixes 3 words
:B0X*:mischevious::f("mischievous") ; Fixes 3 words
:B0X*:mischievious::f("mischievous") ; Fixes 3 words
:B0X*:misdameanor::f("misdemeanor") ; Fixes 2 words
:B0X*:misouri::f("Missouri") ; Fixes 5 words
:B0X*:mispell::f("misspell") ; Fixes 5 words
:B0X*:missle::f("missile") ; Fixes 1 word
:B0X*:misteri::f("mysteri") ; Fixes 4 words
:B0X*:mistery::f("mystery") ; Fixes 1 word
:B0X*:mohammedans::f("muslims") ; Fixes 1 word
:B0X*:moil::f("mohel") ; Fixes 1 word
:B0X*:momento::f("memento") ; Fixes 1 word
:B0X*:monestar::f("monaster") ; Fixes 2 words
:B0X*:monicker::f("moniker") ; Fixes 3 words
:B0X*:monkie::f("monkey") ; Fixes 10 words
:B0X*:montain::f("mountain") ; Fixes 17 words
:B0X*:montyp::f("monotyp") ; Fixes 3 words
:B0X*:more dominate::f("more dominant") ; Fixes 1 word
:B0X*:more of less::f("more or less") ; Fixes 1 word
:B0X*:more often then::f("more often than") ; Fixes 1 word
:B0X*:most populace::f("most populous") ; Fixes 1 word
:B0X*:movei::f("movie") ; Fixes 6 words
:B0X*:muhammadan::f("muslim") ; Fixes 1 word
:B0X*:multipled::f("multiplied") ; Fixes 1 word
:B0X*:multiplers::f("multipliers") ; Fixes 1 word
:B0X*:muncipal::f("municipal") ; Fixes 16 words
:B0X*:munnicipal::f("municipal") ; Fixes 16 words
:B0X*:muscician::f("musician") ; Fixes 5 words
:B0X*:mute point::f("moot point") ; Fixes 1 word
:B0X*:myown::f("my own")
:B0X*:myraid::f("myriad") ; Fixes 3 words
:B0X*:mysogyn::f("misogyn") ; Fixes 10 words
:B0X*:mysterous::f("mysterious") ; Fixes 3 words
:B0X*:naieve::f("naive") ; Fixes 9 words
:B0X*:napoleonian::f("Napoleonic") ; Fixes 1 word
:B0X*:nation wide::f("nationwide") ; Fixes 1 word
:B0X*:nazereth::f("Nazareth") ; Fixes 1 word
:B0X*:near by::f("nearby") ; Fixes 1 word
:B0X*:necessiat::f("necessitat") ; Fixes 6 words
:B0X*:neglib::f("negligib") ; Fixes 4 words
:B0X*:negligab::f("negligib") ; Fixes 4 words
:B0X*:negociab::f("negotiab") ; Fixes 4 words
:B0X*:neverthless::f("nevertheless") ; Fixes 1 word
:B0X*:new comer::f("newcomer") ; Fixes 1 word
:B0X*:newletter::f("newsletter") ; Fixes 2 word
:B0X*:newyorker::f("New Yorker") ; Fixes 1 word
:B0X*:niether::f("neither") ; Fixes 1 word
:B0X*:nightime::f("nighttime") ; Fixes 1 word
:B0X*:nineth::f("ninth") ; Fixes 1 word
:B0X*:ninteenth::f("nineteenth") ; Fixes 1 word
:B0X*:ninties::f("nineties") ; fixed from "1990s": could refer to temperatures too. ; Fixes 1 word
:B0X*:ninty::f("ninety") ; Fixes 1 word
:B0X*:nkwo::f("know") ; Fixes 24 words
:B0X*:no where to::f("nowhere to") ; Fixes 1 word
:B0X*:nontheless::f("nonetheless") ; Fixes 1 word
:B0X*:noone::f("no one") ; Fixes 1 word
:B0X*:norhe::f("northe") ; Fixes 24 words
:B0X*:northen::f("northern") ; Fixes 8 words
:B0X*:northereast::f("northeast") ; Fixes 11 words
:B0X*:note worthy::f("noteworthy") ; Fixes 1 word
:B0X*:noteri::f("notori") ; Fixes 5 words
:B0X*:nothern::f("northern") ; Fixes 8 words
:B0X*:noticable::f("noticeable") ; Fixes 1 word
:B0X*:noticably::f("noticeably") ; Fixes 1 word
:B0X*:notise::f("notice") ; Fixes 10 words 
:B0X*:notive::f("notice") ; Fixes 10 words
:B0X*:notwhithstanding::f("notwithstanding") ; Fixes 1 word
:B0X*:noveau::f("nouveau") ; Fixes 1 word
:B0X*:nowdays::f("nowadays") ; Fixes 1 word
:B0X*:nowe::f("now") ; Fixes 17 words
:B0X*:nuisanse::f("nuisance") ; Fixes 1 word
:B0X*:numbero::f("numero") ; Fixes 11 words
:B0X*:nusance::f("nuisance") ; Fixes 1 word
:B0X*:nutur::f("nurtur") ; Fixes 10 words
:B0X*:nver::f("never") ; Fixes 3 words
:B0X*:nwe::f("new") ; Fixes 123 words
:B0X*:nwo::f("now") ; Fixes 17 words
:B0X*:obess::f("obsess") ; Fixes 14 words
:B0X*:obssess::f("obsess") ; Fixes 14 words
:B0X*:obstacal::f("obstacle") ; Fixes 1 word
:B0X*:ocasion::f("occasion") ; Fixes 12 words
:B0X*:ocass::f("occas") ; Fixes 12 words
:B0X*:occaison::f("occasion") ; Fixes 12 words
:B0X*:occation::f("occasion") ; Fixes 12 words
:B0X*:octohedr::f("octahedr") ; Fixes 5 words
:B0X*:ocuntr::f("countr") ; Fixes 18 words
:B0X*:of it's kind::f("of its kind") ; Fixes 1 word
:B0X*:of it's own::f("of its own") ; Fixes 1 word
:B0X*:offce::f("office") ; Fixes 11 words
:B0X*:ofits::f("of its") ; Fixes 1 word
:B0X*:oft he::f("of the") ; Could be legitimate in poetry, but usually a typo. ; Fixes 1 word
:B0X*:oftenly::f("often") ; Fixes 1 word
:B0X*:oging::f("going") ; Fixes 1 word
:B0X*:oil barron::f("oil baron") ; Fixes 1 word
:B0X*:omited::f("omitted") ; Fixes 1 word
:B0X*:omiting::f("omitting") ; Fixes 1 word
:B0X*:omlette::f("omelette") ; Fixes 1 word
:B0X*:ommited::f("omitted") ; Fixes 1 word
:B0X*:ommiting::f("omitting") ; Fixes 1 word
:B0X*:ommitted::f("omitted") ; Fixes 1 word
:B0X*:ommitting::f("omitting") ; Fixes 1 word
:B0X*:on accident::f("by accident") ; Fixes 1 word
:B0X*:on going::f("ongoing") ; Fixes 1 word
:B0X*:on it's own::f("on its own") ; Fixes 1 word
:B0X*:on-going::f("ongoing") ; Fixes 1 word
:B0X*:oncs::f("ones") ; Fixes 4 words 
:B0X*:onee::f("once") ; Fixes 4 words 
:B0X*:oneof::f("one of") ; Fixes 1 word
:B0X*:ongoing bases::f("ongoing basis") ; Fixes 1 word
:B0X*:onomatopeia::f("onomatopoeia") ; Fixes 1 word
:B0X*:onot::f("not") ; Fixes 116 words
:B0X*:onpar::f("on par") ; Fixes 1 word
:B0X*:ont he::f("on the") ; Fixes 1 word
:B0X*:onyl::f("only") ; Fixes 1 word
:B0X*:openess::f("openness") ; Fixes 1 word
:B0X*:oponen::f("opponen") ; Fixes 4 words
:B0X*:opose::f("oppose") ; Fixes 6 words
:B0X*:oposi::f("opposi") ; Fixes 17 words
:B0X*:oppositit::f("opposit") ; Fixes 15 words
:B0X*:opre::f("oppre") ; Fixes 11 words
:B0X*:optmiz::f("optimiz") ; Fixes 8 words
:B0X*:optomi::f("optimi") ; Fixes 22 words
:B0X*:orded::f("ordered") ; Fixes 1 word
:B0X*:orthag::f("orthog") ; Fixes 23 words
:B0X*:other then::f("other than") ; Fixes 1 word
:B0X*:oublish::f("publish") ; Fixes 9 words
:B0X*:our resent::f("our recent") ; Fixes 1 word
:B0X*:oustanding::f("outstanding") ; Fixes 3 words
:B0X*:out grow::f("outgrow") ; Fixes 1 word
:B0X*:out of sink::f("out of sync") ; Fixes 1 word
:B0X*:out of state::f("out-of-state") ; Fixes 1 word
:B0X*:out side::f("outside") ; Fixes 1 word
:B0X*:outof::f("out of") ; Fixes 1 word
:B0X*:over hear::f("overhear") ; Fixes 1 word
:B0X*:over look::f("overlook") ; Fixes 1 word
:B0X*:over rate::f("overrate") ; Fixes 2 words
:B0X*:over saw::f("oversaw") ; Fixes 1 word
:B0X*:over see::f("oversee") ; Fixes 1 word
:B0X*:overthere::f("over there") ; Fixes 1 word
:B0X*:overwelm::f("overwhelm") ; Fixes 6 words
:B0X*:owudl::f("would") ; Fixes 5 words
:B0X*:owuld::f("would") ; Fixes 5 words
:B0X*:oximoron::f("oxymoron") ; Fixes 3 words
:B0X*:paleolitic::f("paleolithic") ; Fixes 1 word
:B0X*:palist::f("Palest") ; Fixes 7 words
:B0X*:pamflet::f("pamphlet") ; Fixes 6 words
:B0X*:pamplet::f("pamphlet") ; Fixes 6 words
:B0X*:pantomine::f("pantomime") ; Fixes 5 words
:B0X*:paranthe::f("parenthe") ; Fixes 15 words
:B0X*:paraphenalia::f("paraphernalia") ; Fixes 1 word
:B0X*:parrakeet::f("parakeet") ; Fixes 2 words
:B0X*:particulary::f("particularly") ; Fixes 1 word
:B0X*:partof::f("part of") ; Fixes 1 word
:B0X*:pasenger::f("passenger") ; Fixes 2 words
:B0X*:passerbys::f("passersby") ; Fixes 1 word
:B0X*:past away::f("passed away") ; Fixes 1 word
:B0X*:past down::f("passed down") ; Fixes 1 word
:B0X*:pasttime::f("pastime") ; Fixes 1 word
:B0X*:pastural::f("pastoral") ; Fixes 11 words
:B0X*:pavillion::f("pavilion") ; Fixes 1 word
:B0X*:payed::f("paid") ; Fixes 1 word
:B0X*:peacefuland::f("peaceful and") ; Fixes 1 word
:B0X*:peageant::f("pageant") ; Fixes 4 words
:B0X*:peak her interest::f("pique her interest") ; Fixes 1 word
:B0X*:peak his interest::f("pique his interest") ; Fixes 1 word
:B0X*:peaked my interest::f("piqued my interest") ; Fixes 1 word
:B0X*:pedestrain::f("pedestrian") ; Fixes 15 words
:B0X*:pensle::f("pencil") ; Fixes 10 words
:B0X*:peom::f("poem") ; Fixes 2 words
:B0X*:peotry::f("poetry") ; Fixes 1 word
:B0X*:perade::f("parade") ; Fixes 5 words
:B0X*:percentof::f("percent of") ; Fixes 1 word
:B0X*:percentto::f("percent to") ; Fixes 1 word
:B0X*:peretrat::f("perpetrat") ; Fixes 8 words
:B0X*:perheaps::f("perhaps") ; Fixes 1 word
:B0X*:perhpas::f("perhaps") ; Fixes 1 word
:B0X*:peripathetic::f("peripatetic") ; Fixes 7 words
:B0X*:peristen::f("persisten") ; Fixes 6 words
:B0X*:perjer::f("perjur") ; Fixes 9 words
:B0X*:perjorative::f("pejorative") ; Fixes 3 words
:B0X*:perogative::f("prerogative") ; Fixes 1 word
:B0X*:perpindicular::f("perpendicular") ; Fixes 6 words
:B0X*:persan::f("person") ; Fixes 55 words
:B0X*:perseveren::f("perseveran") ; Fixes 4 words
:B0X*:personell::f("personnel") ; Fixes 1 word
:B0X*:personnell::f("personnel") ; Fixes 1 word
:B0X*:persue::f("pursue") ; Fixes 5 words
:B0X*:persui::f("pursui") ; Fixes 6 words
:B0X*:pharoah::f("Pharaoh") ; Fixes 1 word
:B0X*:phenomenonly::f("phenomenally") ; Fixes 1 word
:B0X*:pheonix::f("phoenix") ; Not forcing caps, as it could be the bird ; Fixes 1 word
:B0X*:philipi::f("Philippi") ; Fixes 7 words
:B0X*:pilgrimm::f("pilgrim") ; Fixes 8 words
:B0X*:pinapple::f("pineapple") ; Fixes 1 word
:B0X*:pinnaple::f("pineapple") ; Fixes 1 word
:B0X*:plagar::f("plagiar") ; Fixes 23 words
:B0X*:planation::f("plantation") ; Fixes 1 word
:B0X*:plantiff::f("plaintiff") ; Fixes 1 word
:B0X*:plateu::f("plateau") ; Fixes 5 words
:B0X*:playright::f("playwright") ; Fixes 3 words
:B0X*:playwrite::f("playwright") ; Fixes 3 words
:B0X*:plebicit::f("plebiscit") ; Fixes 3 words
:B0X*:poety::f("poetry") ; Fixes 1 word
:B0X*:pomegranite::f("pomegranate") ; Fixes 1 word
:B0X*:pomot::f("promot") ; Fixes 14 words
:B0X*:portayed::f("portrayed") ; Fixes 1 word
:B0X*:portugese::f("Portuguese") ; Fixes 1 word
:B0X*:portuguease::f("Portuguese") ; Fixes 1 word
:B0X*:portugues::f("Portuguese") ; Fixes 1 word
:B0X*:possit::f("posit") ; Fixes 34 words 
:B0X*:posthomous::f("posthumous") ; Fixes 3 words
:B0X*:potatoe::f("potato") ; Fixes 1 word
:B0X*:potatos::f("potatoes") ; Fixes 1 word
:B0X*:potra::f("portra") ; Fixes 15 words
:B0X*:powerfull::f("powerful") ; Fixes 1 word
:B0X*:practioner::f("practitioner") ; Fixes 2 words
:B0X*:prairy::f("prairie") ; Fixes 2 words
:B0X*:prarie::f("prairie") ; Fixes 2 words
:B0X*:pre-Colombian::f("pre-Columbian") ; Fixes 1 word
:B0X*:preample::f("preamble") ; Fixes 3 words
:B0X*:precedessor::f("predecessor") ; Fixes 1 word
:B0X*:precentage::f("percentage") ; Fixes 1 word
:B0X*:precurser::f("precursor") ; Fixes 3 words
:B0X*:preferra::f("prefera") ; Fixes 5 words
:B0X*:premei::f("premie") ; Fixes 10 words
:B0X*:premillenial::f("premillennial") ; Fixes 6 words
:B0X*:preminen::f("preeminen") ; Fixes 4 words
:B0X*:premissio::f("permissio") ; Fixes 3 words
:B0X*:prepart::f("preparat") ; Fixes 5 words
:B0X*:prepat::f("preparat") ; Fixes 5 words, but misspells prepatent. 
:B0X*:prepera::f("prepara") ; Fixes 5 words
:B0X*:presitg::f("prestig") ; Fixes 5 words
:B0X*:prevers::f("pervers") ; Fixes 10 words
:B0X*:primarly::f("primarily") ; Fixes 1 word
:B0X*:primativ::f("primitiv") ; Fixes 8 words
:B0X*:primordal::f("primordial") ; Fixes 4 words
:B0X*:principaly::f("principality") ; Fixes 1 word
:B0X*:principial::f("principal") ; Fixes 8 words
:B0X*:principlaity::f("principality") ; Fixes 1 word
:B0X*:principle advantage::f("principal advantage") ; Fixes 2 words
:B0X*:principle cause::f("principal cause") ; Fixes 2 words
:B0X*:principle character::f("principal character") ; Fixes 2 words
:B0X*:principle component::f("principal component") ; Fixes 2 words
:B0X*:principle goal::f("principal goal") ; Fixes 2 words
:B0X*:principle group::f("principal group") ; Fixes 2 words
:B0X*:principle method::f("principal method") ; Fixes 2 words
:B0X*:principle owner::f("principal owner") ; Fixes 2 words
:B0X*:principle source::f("principal source") ; Fixes 2 words
:B0X*:principle student::f("principal student") ; Fixes 2 words
:B0X*:principly::f("principally") ; Fixes 1 word
:B0X*:prinici::f("princi") ; Fixes 17 words
:B0X*:privt::f("privat") ; Fixes 35 words
:B0X*:procede::f("proceed") ; Fixes 5 words
:B0X*:procedger::f("procedure") ; Fixes 1 word
:B0X*:proceding::f("proceeding") ; Fixes 2 words
:B0X*:proceedur::f("procedur") ; Fixes 4 words
:B0X*:profesor::f("professor") ; Fixes 10 words
:B0X*:profilic::f("prolific") ; Fixes 5 words
:B0X*:progid::f("prodig") ; Fixes 10 words
:B0X*:prologomena::f("prolegomena") ; Fixes 1 word
:B0X*:promiscous::f("promiscuous") ; Fixes 3 words
:B0X*:pronomial::f("pronominal") ; Fixes 3 words
:B0X*:proof read::f("proofread") ; Fixes 5 words
:B0X*:prophacy::f("prophecy") ; Fixes 1 word
:B0X*:propoga::f("propaga") ; Fixes 25 words
:B0X*:proseletyz::f("proselytiz") ; Fixes 8 words
:B0X*:protocal::f("protocol") ; Fixes 2 words
:B0X*:protruberanc::f("protuberanc") ; Fixes 4 words
:B0X*:provious::f("previous") ; Fixes 4 words 
:B0X*:proximty::f("proximity") ; Fixes 1 word
:B0X*:pseudonyn::f("pseudonym") ; Fixes 9 words
:B0X*:publically::f("publicly") ; Fixes 1 word
:B0X*:puch::f("push") ; Fixes 34 words
:B0X*:pumkin::f("pumpkin") ; Fixes 4 words
:B0X*:puritannic::f("puritanic") ; Fixes 4 words
:B0X*:purposedly::f("purposely") ; Fixes 1 word
:B0X*:purpot::f("purport") ; Fixes 5 words
:B0X*:puting::f("putting") ; Fixes 1 word
:B0X*:pysci::f("psychi") ; Fixes 12 words
:B0X*:quantat::f("quantit") ; Fixes 14 words
:B0X*:quess::f("guess") ; Fixes 14 words 
:B0X*:quinessen::f("quintessen") ; Fixes 4 words
:B0X*:quitted::f("quit") ; Fixes 1 word
:B0X*:quize::f("quizze") ; Fixes 4 words
:B0X*:racaus::f("raucous") ; Fixes 3 words
:B0X*:raed::f("read") ; Fixes 63 words
:B0X*:raing::f("rating") ; Fixes 1 word 
:B0X*:rasberr::f("raspberr") ; Fixes 2 words
:B0X*:rather then::f("rather than") ; Fixes 1 word
:B0X*:reasea::f("resea") ; Fixes 18 words
:B0X*:rebounce::f("rebound") ; Fixes 1 word
:B0X*:receivedfrom::f("received from") ; Fixes 1 word
:B0X*:recie::f("recei") ; Fixes 17 words
:B0X*:reciv::f("receiv") ; Fixes 13 words
:B0X*:recomen::f("recommen") ; Fixes 18 words
:B0X*:reconaissance::f("reconnaissance") ; Fixes 2 words
:B0X*:reconize::f("recognize") ; Fixes 6 words
:B0X*:recuit::f("recruit") ; Fixes 9 words
:B0X*:recurran::f("recurren") ; Fixes 4 words
:B0X*:redicu::f("ridicu") ; Fixes 9 words
:B0X*:reek havoc::f("wreak havoc") ; Fixes 1 word
:B0X*:refedend::f("referend") ; Fixes 3 words
:B0X*:refridgera::f("refrigera") ; Fixes 11 words
:B0X*:refusla::f("refusal") ; Fixes 2 words
:B0X*:reher::f("rehear") ; Fixes 13 words
:B0X*:reica::f("reinca") ; Fixes 9 words
:B0X*:reign in::f("rein in") ; Fixes 1 word
:B0X*:reigns of power::f("reins of power") ; Fixes 1 word
:B0X*:reknown::f("renown") ; Fixes 5 words
:B0X*:relected::f("reelected") ; Fixes 1 word
:B0X*:reliz::f("realiz") ; Fixes 12 words
:B0X*:remaing::f("remaining") ; Fixes 1 word
:B0X*:rememberable::f("memorable") ; Fixes 1 word
:B0X*:remenant::f("remnant") ; Fixes 2 words
:B0X*:remenic::f("reminisc") ; Fixes 12 words
:B0X*:reminent::f("remnant") ; Fixes 2 words
:B0X*:remines::f("reminis") ; Fixes 12 words
:B0X*:reminsc::f("reminisc") ; Fixes 12 words
:B0X*:reminsic::f("reminisc") ; Fixes 12 words
:B0X*:rendevous::f("rendezvous") ; Fixes 4 words
:B0X*:rendezous::f("rendezvous") ; Fixes 4 words
:B0X*:renewl::f("renewal") ; Fixes 2 words
:B0X*:repid::f("rapid") ; Fixes 8 words
:B0X*:repon::f("respon") ; Fixes 22 words
:B0X*:reprtoire::f("repertoire") ; Fixes 2 words
:B0X*:repubi::f("republi") ; Fixes 15 words
:B0X*:requr::f("requir") ; Fixes 9 words
:B0X*:resaura::f("restaura") ; Fixes 8 words
:B0X*:resembe::f("resemble") ; Fixes 5 words
:B0X*:resently::f("recently") ; Fixes 1 word
:B0X*:resevoir::f("reservoir") ; Fixes 2 words
:B0X*:resignement::f("resignation") ; Fixes 2 words
:B0X*:resignment::f("resignation") ; Fixes 2 words
:B0X*:resse::f("rese") ; Fixes 98 words
:B0X*:ressurrect::f("resurrect") ; Fixes 7 words
:B0X*:restara::f("restaura") ; Fixes 8 words
:B0X*:restaurati::f("restorati") ; Fixes 9 words
:B0X*:resteraunt::f("restaurant") ; Fixes 6 words
:B0X*:restraunt::f("restaurant") ; Fixes 6 words
:B0X*:resturant::f("restaurant") ; Fixes 6 words
:B0X*:retalitat::f("retaliat") ; Fixes 10 words
:B0X*:retrun::f("return") ; Fixes 10 words 
:B0X*:retun::f("return") ; Fixes 1 word
:B0X*:reult::f("result") ; Fixes 7 words
:B0X*:revaluat::f("reevaluat") ; Fixes 6 words
:B0X*:reveral::f("reversal") ; Fixes 2 words
:B0X*:rfere::f("refere") ; Fixes 20 words
:B0X*:rised::f("rose") ; Fixes 1 word
:B0X*:rockerfeller::f("Rockefeller") ; Fixes 2 words
:B0X*:rococco::f("rococo") ; Fixes 2 words
:B0X*:role call::f("roll call") ; Fixes 4 words
:B0X*:roll play::f("role play") ; Fixes 4 words
:B0X*:roomate::f("roommate") ; Fixes 2 words
:B0X*:rre::f("re") ; Fixes 8199 words 
:B0X*:rucupera::f("recupera") ; Fixes 11 words
:B0X*:rulle::f("rule") ; Fixes 9 words
:B0X*:rumer::f("rumor") ; Fixes 6 words
:B0X*:runner up::f("runner-up") ; Fixes 1 word
:B0X*:russina::f("Russian") ; Fixes 13 words
:B0X*:russion::f("Russian") ; Fixes 13 words
:B0X*:rythem::f("rhythm") ; Fixes 8 words
:B0X*:rythm::f("rhythm") ; Fixes 8 words
:B0X*:sacrelig::f("sacrileg") ; Fixes 5 words
:B0X*:sacrifical::f("sacrificial") ; Fixes 2 words
:B0X*:saddle up to::f("sidle up to") ; Fixes 1 word
:B0X*:safegard::f("safeguard") ; added by steve
:B0X*:saidhe::f("said he") ; Fixes 1 word
:B0X*:saidt he::f("said the") ; Fixes 1 word
:B0X*:salery::f("salary") ; Fixes 3 words
:B0X*:sandess::f("sadness") ; Fixes 1 word
:B0X*:sandwhich::f("sandwich") ; Fixes 6 words
:B0X*:sargan::f("sergean") ; Fixes 6 words
:B0X*:sargean::f("sergean") ; Fixes 6 words
:B0X*:saterday::f("Saturday") ; Fixes 2 words
:B0X*:saxaphon::f("saxophon") ; Fixes 5 words
:B0X*:say la v::f("c'est la vie") ; Fixes 1 word
:B0X*:scandanavia::f("Scandinavia") ; Fixes 3 words
:B0X*:scaricit::f("scarcit") ; Fixes 2 words
:B0X*:scavang::f("scaveng") ; Fixes 6 words
:B0X*:scrutinit::f("scrutin") ; Fixes 18 words
:B0X*:scuptur::f("sculptur") ; Fixes 11 words
:B0X*:secceed::f("seced") ; Fixes 4 words
:B0X*:secrata::f("secreta") ; Fixes 14 words
:B0X*:see know::f("see now") ; Fixes 1 word 
:B0X*:seguoy::f("segue") ; Fixes 4 words
:B0X*:seh::f("she") ; Fixes 236 words
:B0X*:seinor::f("senior") ; Fixes 5 words
:B0X*:selett::f("select") ; Fixes 32 words 
:B0X*:senari::f("scenari") ; Fixes 4 words
:B0X*:senc::f("sens") ; Fixes 107 words
:B0X*:sentan::f("senten") ; Fixes 9 words
:B0X*:sepina::f("subpoena") ; Fixes 4 words
:B0X*:sergent::f("sergeant") ; Fixes 4 words
:B0X*:set back::f("setback") ; Fixes 2 words
:B0X*:severley::f("severely") ; Fixes 1 word
:B0X*:severly::f("severely") ; Fixes 1 word
:B0X*:shamen::f("shaman") ; Fixes 15 words
:B0X*:she begun::f("she began") ; Fixes 1 word
:B0X*:she let's::f("she lets") ; Fixes 1 word
:B0X*:she seen::f("she saw") ; Fixes 1 word
:B0X*:shiped::f("shipped") ; Fixes 1 word
:B0X*:short coming::f("shortcoming") ; Fixes 2 words
:B0X*:shorter then::f("shorter than") ; Fixes 1 word
:B0X*:shortly there after::f("shortly thereafter") ; Fixes 1 word
:B0X*:shortwhile::f("short while") ; Fixes 1 word
:B0X*:shoudl::f("should") ; Fixes 8 words
:B0X*:should backup::f("should back up") ; Fixes 1 word
:B0X*:should've went::f("should have gone") ; Fixes 1 word
:B0X*:shreak::f("shriek") ; Fixes 8 words
:B0X*:shrinked::f("shrunk") ; Fixes 1 word
:B0X*:side affect::f("side effect") ; Fixes 2 words
:B0X*:side kick::f("sidekick") ; Fixes 2 words
:B0X*:sideral::f("sidereal") ; Fixes 2 words
:B0X*:siez::f("seiz") ; Fixes 12 words
:B0X*:silicone chip::f("silicon chip") ; Fixes 1 word
:B0X*:simetr::f("symmetr") ; Fixes 18 words 
:B0X*:simplier::f("simpler") ; Fixes 1 word
:B0X*:single handily::f("single-handedly") ; Fixes 1 word
:B0X*:singsog::f("singsong") ; Fixes 1 word
:B0X*:site line::f("sight line") ; Fixes 2 words
:B0X*:slight of hand::f("sleight of hand") ; Fixes 1 word
:B0X*:slue of::f("slew of") ; Fixes 1 word
:B0X*:smaller then::f("smaller than") ; Fixes 1 word
:B0X*:smarter then::f("smarter than") ; Fixes 1 word
:B0X*:sneak peak::f("sneak peek") ; Fixes 1 word
:B0X*:sneek::f("sneak") ; Fixes 13 words
:B0X*:so it you::f("so if you") ; Fixes 35 words 
:B0X*:socit::f("societ") ; Fixes 4 words
:B0X*:sofware::f("software") ; Fixes 2 words
:B0X*:soilder::f("soldier") ; Fixes 15 words
:B0X*:solatar::f("solitar") ; Fixes 4 words
:B0X*:soley::f("solely") ; Fixes 1 word
:B0X*:soliders::f("soldiers") ; Fixes 3 words
:B0X*:soliliqu::f("soliloqu") ; Fixes 12 words
:B0X*:some what::f("somewhat") ; Fixes 1 word
:B0X*:some where::f("somewhere") ; Fixes 1 word
:B0X*:somene::f("someone") ; Fixes 1 word
:B0X*:someting::f("something") ; Fixes 1 word
:B0X*:somthing::f("something") ; Fixes 1 word
:B0X*:somtime::f("sometime") ; Fixes 2 words
:B0X*:somwhere::f("somewhere") ; Fixes 1 word
:B0X*:soon there after::f("soon thereafter") ; Fixes 1 word
:B0X*:sooner then::f("sooner than") ; Fixes 1 word
:B0X*:sophmore::f("sophomore") ; Fixes 2 words
:B0X*:sorceror::f("sorcerer") ; Fixes 2 words
:B0X*:sorround::f("surround") ; Fixes 6 words
:B0X*:sot hat::f("so that") ; Fixes 1 word
:B0X*:sotyr::f("story") ; Fixes 1 word
:B0X*:sould::f("should") ; Fixes 8 words
:B0X*:sountrack::f("soundtrack") ; Fixes 2 words
:B0X*:sourth::f("south") ; Fixes 59 words
:B0X*:souvenier::f("souvenir") ; Fixes 2 words
:B0X*:soveit::f("soviet") ; Fixes 19 words
:B0X*:sovereignit::f("sovereignt") ; Fixes 4 words
:B0X*:spainish::f("Spanish") ; Fixes 1 word
:B0X*:speach::f("speech") ; Fixes 1 word
:B0X*:speciman::f("specimen") ; Fixes 2 words
:B0X*:speecj::f("speech") ; Fixes 19 words 
:B0X*:spendour::f("splendour") ; Fixes 2 words
:B0X*:spilt among::f("split among") ; Fixes 1 word
:B0X*:spilt between::f("split between") ; Fixes 1 word
:B0X*:spilt into::f("split into") ; Fixes 1 word
:B0X*:spilt up::f("split up") ; Fixes 1 word
:B0X*:spinal chord::f("spinal cord") ; Fixes 1 word
:B0X*:split in to::f("split into") ; Fixes 1 word
:B0X*:sportscar::f("sports car") ; Fixes 2 words
:B0X*:sppech::f("speech") ; Fixes 18 words
:B0X*:spreaded::f("spread") ; Fixes 1 word
:B0X*:sprech::f("speech") ; Fixes 1 word
:B0X*:sq ft::f("ft²") ; Fixes 1 word
:B0X*:sq in::f("in²") ; Fixes 1 word
:B0X*:sq km::f("km²") ; Fixes 1 word
:B0X*:squared feet::f("square feet") ; Fixes 1 word
:B0X*:squared inch::f("square inch") ; Fixes 2 words
:B0X*:squared kilometer::f("square kilometer") ; Fixes 2 words
:B0X*:squared meter::f("square meter") ; Fixes 2 words
:B0X*:squared mile::f("square mile") ; Fixes 2 words
:B0X*:stale mat::f("stalemat") ; Fixes 4 words
:B0X*:standars::f("standards") ; Fixes 1 word
:B0X*:staring role::f("starring role") ; Fixes 2 words
:B0X*:starring roll::f("starring role") ; Fixes 2 words
:B0X*:stay a while::f("stay awhile") ; Fixes 1 word
:B0X*:stilus::f("stylus") ; Fixes 2 words
:B0X*:stomache::f("stomach") ; Fixes 1 word
:B0X*:storise::f("stories") ; Fixes 1 word
:B0X*:stornegst::f("strongest") ; Fixes 1 word
:B0X*:stpo::f("stop") ; Fixes 33 words
:B0X*:strenous::f("strenuous") ; Fixes 3 words
:B0X*:strictist::f("strictest") ; Fixes 1 word
:B0X*:strike out::f("strikeout") ; Fixes 2 words
:B0X*:strikely::f("strikingly") ; Fixes 1 word
:B0X*:strnad::f("strand") ; Fixes 6 words
:B0X*:stronger then::f("stronger than") ; Fixes 1 word
:B0X*:stroy::f("story") ; Fixes 12 words
:B0X*:struggel::f("struggle") ; Fixes 5 words
:B0X*:strugl::f("struggl") ; Fixes 7 words
:B0X*:stubborness::f("stubbornness") ; Fixes 1 word
:B0X*:student's that::f("students that") ; Fixes 1 word
:B0X*:stuggl::f("struggl") ; Fixes 7 words
:B0X*:subjudgation::f("subjugation") ; Fixes 2 words
:B0X*:subpecies::f("subspecies") ; Fixes 1 word
:B0X*:subsidar::f("subsidiar") ; Fixes 6 words
:B0X*:subsiduar::f("subsidiar") ; Fixes 6 words
:B0X*:subsquen::f("subsequen") ; Fixes 5 words
:B0X*:substace::f("substance") ; Fixes 2 words
:B0X*:substatia::f("substantia") ; Fixes 22 words
:B0X*:substitud::f("substitut") ; Fixes 14 words
:B0X*:substract::f("subtract") ; Fixes 12 words
:B0X*:subtance::f("substance") ; Fixes 2 words
:B0X*:suburburban::f("suburban") ; Fixes 16 words
:B0X*:succedd::f("succeed") ; Fixes 7 words
:B0X*:succede::f("succeede") ; Fixes 3 words
:B0X*:succeds::f("succeeds") ; Fixes 1 word
:B0X*:suceed::f("succeed") ; Fixes 7 words
:B0X*:sucide::f("suicide") ; Fixes 3 words
:B0X*:sucidial::f("suicidal") ; Fixes 4 words
:B0X*:sudent::f("student") ; Fixes 7 words
:B0X*:sufferag::f("suffrag") ; Fixes 10 words
:B0X*:sumar::f("summar") ; Fixes 22 words
:B0X*:suop::f("soup") ; Fixes 14 words
:B0X*:superce::f("superse") ; Fixes 17 words
:B0X*:supliment::f("supplement") ; Fixes 10 words
:B0X*:suppliment::f("supplement") ; Fixes 10 words
:B0X*:suppose to::f("supposed to") ; Fixes 1 word
:B0X*:supposingly::f("supposedly") ; Fixes 1 word
:B0X*:surplant::f("supplant") ; Fixes 6 words
:B0X*:surrended::f("surrendered") ; Fixes 1 word
:B0X*:surrepetitious::f("surreptitious") ; Fixes 3 words
:B0X*:surreptious::f("surreptitious") ; Fixes 3 words
:B0X*:surrond::f("surround") ; Fixes 6 words
:B0X*:surroud::f("surround") ; Fixes 6 words
:B0X*:surrunder::f("surrender") ; Fixes 6 words
:B0X*:surveilen::f("surveillan") ; Fixes 3 words
:B0X*:surviver::f("survivor") ; Fixes 1 word
:B0X*:survivied::f("survived") ; Fixes 1 word
:B0X*:swiming::f("swimming") ; Fixes 3 words
:B0X*:synagouge::f("synagogue") ; Fixes 2 words
:B0X*:synph::f("symph") ; Fixes 30 words
:B0X*:syrap::f("syrup") ; Fixes 4 words
:B0X*:tabacco::f("tobacco") ; Fixes 4 words
:B0X*:take affect::f("take effect") ; Fixes 1 word
:B0X*:take over the reigns::f("take over the reins") ; Fixes 1 word
:B0X*:take the reigns::f("take the reins") ; Fixes 1 word
:B0X*:taken the reigns::f("taken the reins") ; Fixes 1 word
:B0X*:taking the reigns::f("taking the reins") ; Fixes 1 word
:B0X*:tatoo::f("tattoo") ; Fixes 8 words
:B0X*:teacg::f("teach") ; Fixes 15 words
:B0X*:teached::f("taught") ; Fixes 1 word
:B0X*:telelev::f("telev") ; Fixes 14 words
:B0X*:televiz::f("televis") ; Fixes 10 words
:B0X*:televsion::f("television") ; Fixes 2 words
:B0X*:tellt he::f("tell the") ; Fixes 1 word
:B0X*:temerature::f("temperature") ; Fixes 2 words
:B0X*:temperment::f("temperament") ; Fixes 5 words
:B0X*:temperture::f("temperature") ; Fixes 2 words
:B0X*:tenacle::f("tentacle") ; Fixes 3 words
:B0X*:termoil::f("turmoil") ; Fixes 2 words
:B0X*:testomon::f("testimon") ; Fixes 4 words
:B0X*:thansk::f("thanks") ; Fixes 6 words
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
:B0X*:thegovernment::f("the government") ; Fixes 4 words
:B0X*:theif::f("thief") ; Fixes 1 word
:B0X*:their are::f("there are") ; Fixes 1 word
:B0X*:their had::f("there had") ; Fixes 1 word
:B0X*:their may be::f("there may be") ; Fixes 1 word
:B0X*:their was::f("there was") ; Fixes 1 word
:B0X*:their were::f("there were") ; Fixes 1 word
:B0X*:their would::f("there would") ; Fixes 1 word
:B0X*:them selves::f("themselves") ; Fixes 1 word
:B0X*:themselfs::f("themselves") ; Fixes 1 word
:B0X*:themslves::f("themselves") ; Fixes 1 word
:B0X*:thenew::f("the new") ; Fixes 1 word
:B0X*:therafter::f("thereafter") ; Fixes 1 word
:B0X*:therby::f("thereby") ; Fixes 1 word
:B0X*:there after::f("thereafter") ; Fixes 1 word
:B0X*:there best::f("their best") ; Fixes 1 word
:B0X*:there final::f("their final") ; Fixes 2 words
:B0X*:there first::f("their first") ; Fixes 1 word
:B0X*:there last::f("their last") ; Fixes 1 word
:B0X*:there new::f("their new") ; Fixes 1 word
:B0X*:there own::f("their own") ; Fixes 1 word
:B0X*:there where::f("there were") ; Fixes 1 word
:B0X*:there's is::f("theirs is") ; Fixes 1 word
:B0X*:there's three::f("there are three") ; Fixes 1 word
:B0X*:there's two::f("there are two") ; Fixes 1 word
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
:B0X*:they're is::f("there is") ; Fixes 1 word
:B0X*:theyll::f("they'll") ; Fixes 1 word
:B0X*:theyre::f("they're") ; Fixes 1 word
:B0X*:theyve::f("they've") ; Fixes 1 word
:B0X*:thier::f("their") ; Fixes 2 words
:B0X*:this data::f("these data") ; Fixes 1 word
:B0X*:this gut::f("this guy") ; Fixes 1 word
:B0X*:this maybe::f("this may be") ; Fixes 1 word
:B0X*:this resent::f("this recent") ; Fixes 1 word
:B0X*:thisyear::f("this year") ; Fixes 2 words
:B0X*:thna::f("than") ; Fixes 35 words
:B0X*:those includes::f("those include") ; Fixes 1 word
:B0X*:those maybe::f("those may be") ; Fixes 1 word
:B0X*:thoughout::f("throughout") ; Fixes 1 word
:B0X*:thousend::f("thousand") ; Fixes 5 words 
:B0X*:threatend::f("threatened") ; Fixes 1 word
:B0X*:threshhold::f("threshold") ; Fixes 4 words
:B0X*:thrid::f("third") ; Fixes 5 words
:B0X*:thror::f("thor") ; Fixes 57 words
:B0X*:through it's::f("through its") ; Fixes 1 word
:B0X*:through the ringer::f("through the wringer") ; Fixes 1 word
:B0X*:throughly::f("thoroughly") ; Fixes 1 word
:B0X*:throughout it's::f("throughout its") ; Fixes 1 word
:B0X*:througout::f("throughout") ; Fixes 1 word
:B0X*:throws of passion::f("throes of passion") ; Fixes 1 word
:B0X*:thta::f("that") ; Fixes 14 words
:B0X*:tiem::f("time") ; Fixes 49 words
:B0X*:time out::f("timeout") ; Fixes 2 words
:B0X*:timeschedule::f("time schedule") ; Fixes 2 words
:B0X*:timne::f("time") ; Fixes 49 words
:B0X*:tiome::f("time") ; Fixes 49 words
:B0X*:to back fire::f("to backfire") ; Fixes 1 word
:B0X*:to back-off::f("to back off") ; Fixes 1 word
:B0X*:to back-out::f("to back out") ; Fixes 1 word
:B0X*:to back-up::f("to back up") ; Fixes 1 word
:B0X*:to backoff::f("to back off") ; Fixes 1 word
:B0X*:to backout::f("to back out") ; Fixes 1 word
:B0X*:to backup::f("to back up") ; Fixes 1 word
:B0X*:to bailout::f("to bail out") ; Fixes 1 word
:B0X*:to be setup::f("to be set up") ; Fixes 1 word
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
:B0X*:to have lead to::f("to have led to") ; Fixes 1 word
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
:B0X*:tobbaco::f("tobacco") ; Fixes 4 words
:B0X*:today of::f("today or") ; Fixes 1 word
:B0X*:todays::f("today's") ; Fixes 1 word
:B0X*:todya::f("today") ; Fixes 2 words
:B0X*:toldt he::f("told the") ; Fixes 1 word
:B0X*:tolkein::f("Tolkien") ; Fixes 2 words
:B0X*:tomatos::f("tomatoes") ; Fixes 1 word
:B0X*:tommorrow::f("tomorrow") ; Fixes 2 words
:B0X*:tomottow::f("tomorrow") ; Fixes 2 words 
:B0X*:too also::f("also") ; Fixes 1 word
:B0X*:too be::f("to be") ; Fixes 1 word
:B0X*:took affect::f("took effect") ; Fixes 1 word
:B0X*:took and interest::f("took an interest") ; Fixes 1 word
:B0X*:took awhile::f("took a while") ; Fixes 1 word
:B0X*:took over the reigns::f("took over the reins") ; Fixes 1 word
:B0X*:took the reigns::f("took the reins") ; Fixes 1 word
:B0X*:toolket::f("toolkit") ; Fixes 1 word
:B0X*:tornadoe::f("tornado") ; Fixes 1 word
:B0X*:torpeados::f("torpedoes") ; Fixes 1 word
:B0X*:torpedos::f("torpedoes") ; Fixes 1 word
:B0X*:tortise::f("tortoise") ; Fixes 4 words
:B0X*:tot he::f("to the") ; Fixes 1 word
:B0X*:tothe::f("to the") ; Fixes 1 word
:B0X*:traffice::f("trafficke") ; Fixes 3 words
:B0X*:trafficing::f("trafficking") ; Fixes 1 word
:B0X*:trancend::f("transcend") ; Fixes 17 words
:B0X*:transcendan::f("transcenden") ; Fixes 13 words
:B0X*:transcripting::f("transcribing") ; Fixes 1 word
:B0X*:transend::f("transcend") ; Fixes 17 words
:B0X*:transfered::f("transferred") ; Fixes 1 word
:B0X*:transferin::f("transferrin") ; Fixes 3 words
:B0X*:translater::f("translator") ; Fixes 2 words
:B0X*:transpora::f("transporta") ; Fixes 8 words
:B0X*:tremelo::f("tremolo") ; Fixes 2 words
:B0X*:triathalon::f("triathlon") ; Fixes 2 words
:B0X*:tried to used::f("tried to use") ; Fixes 1 word
:B0X*:triguer::f("trigger") ; Fixes 8 words
:B0X*:triolog::f("trilog") ; Fixes 2 words
:B0X*:try and::f("try to") ; Fixes 1 word
:B0X*:tthe::f("the") ; Fixes 402 words
:B0X*:turn for the worst::f("turn for the worse") ; Fixes 1 word
:B0X*:tuscon::f("Tucson") ; Fixes 1 word
:B0X*:tust::f("trust") ; Fixes 33 words
:B0X*:tution::f("tuition") ; Fixes 3 words
:B0X*:twelth::f("twelfth") ; Fixes 4 words
:B0X*:twelve month's::f("twelve months") ; Fixes 1 word
:B0X*:twice as much than::f("twice as much as") ; Fixes 1 word
:B0X*:two in a half::f("two and a half") ; Fixes 1 word
:B0X*:tyo::f("to") ; Fixes 1110 words
:B0X*:tyrany::f("tyranny") ; Fixes 1 word
:B0X*:tyrrani::f("tyranni") ; Fixes 20 words
:B0X*:tyrrany::f("tyranny") ; Fixes 1 word
:B0X*:ubli::f("publi") ; Fixes 37 words
:B0X*:uise::f("use") ; Fixes 20 words
:B0X*:ukran::f("Ukrain") ; Fixes 3 words
:B0X*:ulser::f("ulcer") ; Fixes 12 words 
:B0X*:unanym::f("unanim") ; Fixes 8 words
:B0X*:unbeknowst::f("unbeknownst") ; Fixes 1 word
:B0X*:under go::f("undergo") ; Fixes 4 words
:B0X*:under it's::f("under its") ; Fixes 1 word
:B0X*:under rate::f("underrate") ; Fixes 3 words
:B0X*:under take::f("undertake") ; Fixes 5 words
:B0X*:under wear::f("underwear") ; Fixes 1 word
:B0X*:under went::f("underwent") ; Fixes 1 word
:B0X*:underat::f("underrat") ; Fixes 4 words 
:B0X*:undert he::f("under the") ; Fixes 1 word
:B0X*:undoubtely::f("undoubtedly") ; Fixes 1 word
:B0X*:undreground::f("underground") ; Fixes 3 words
:B0X*:unecessar::f("unnecessar") ; Fixes 3 words
:B0X*:unequalit::f("inequalit") ; Fixes 2 words
:B0X*:unihabit::f("uninhabit") ; Fixes 6 words
:B0X*:unitedstates::f("United States") ; Fixes 1 word
:B0X*:unitesstates::f("United States") ; Fixes 1 word
:B0X*:univeral::f("universal") ; Fixes 22 words
:B0X*:univerist::f("universit") ; Fixes 2 words
:B0X*:univerit::f("universit") ; Fixes 2 words
:B0X*:universti::f("universit") ; Fixes 2 words
:B0X*:univesit::f("universit") ; Fixes 2 words
:B0X*:unoperational::f("nonoperational") ; Fixes 1 word
:B0X*:unotice::f("unnotice") ; Fixes 4 words
:B0X*:unplease::f("displease") ; Fixes 5 words
:B0X*:unsed::f("unused") ; Fixes 1 word
:B0X*:untill::f("until") ; Fixes 1 word
:B0X*:unuseable::f("unusable") ; Fixes 2 words
:B0X*:up field::f("upfield") ; Fixes 1 word
:B0X*:up it's::f("up its") ; Fixes 1 word
:B0X*:up side::f("upside") ; Fixes 1 word
:B0X*:uploda::f("upload") ; Fixes 4 words 
:B0X*:upon it's::f("upon its") ; Fixes 1 word
:B0X*:upto::f("up to") ; Fixes 1 word
:B0X*:usally::f("usually") ; Fixes 1 word
:B0X*:use to::f("used to") ; Fixes 1 word
:B0X*:vaccum::f("vacuum") ; Fixes 4 words
:B0X*:vacinit::f("vicinit") ; Fixes 2 words
:B0X*:vaguar::f("vagar") ; Fixes 4 words
:B0X*:vaiet::f("variet") ; Fixes 5 words
:B0X*:vanella::f("vanilla") ; Fixes 2 words 
:B0X*:varit::f("variet") ; Fixes 5 words
:B0X*:vasall::f("vassal") ; Fixes 4 words
:B0X*:vehicule::f("vehicle") ; Fixes 2 words
:B0X*:vengance::f("vengeance") ; Fixes 2 words
:B0X*:vengence::f("vengeance") ; Fixes 2 words
:B0X*:verfication::f("verification") ; Fixes 4 words
:B0X*:vermillion::f("vermilion") ; Fixes 4 words
:B0X*:versitilat::f("versatilit") ; Fixes 2 words
:B0X*:versitlit::f("versatilit") ; Fixes 2 words
:B0X*:vetween::f("between") ; Fixes 3 words
:B0X*:via it's::f("via its") ; Fixes 1 word
:B0X*:viathe::f("via the") ; Fixes 1 word
:B0X*:vigour::f("vigor") ; Fixes 9 words
:B0X*:villian::f("villain") ; Fixes 11 words
:B0X*:villifi::f("vilifi") ; Fixes 6 words
:B0X*:villify::f("vilify") ; Fixes 2 words
:B0X*:villin::f("villain") ; Fixes 11 words
:B0X*:vincinit::f("vicinit") ; Fixes 2 words
:B0X*:virutal::f("virtual") ; Fixes 16 words
:B0X*:visabl::f("visibl") ; Fixes 3 words
:B0X*:vise versa::f("vice versa") ; Fixes 1 word
:B0X*:vistor::f("visitor") ; Fixes 2 words
:B0X*:vitor::f("victor") ; Fixes 15 words
:B0X*:vocal chord::f("vocal cord") ; Fixes 2 words
:B0X*:volcanoe::f("volcano") ; Fixes 8 words
:B0X*:voley::f("volley") ; Fixes 8 words
:B0X*:volkswagon::f("Volkswagen") ; Fixes 1 word
:B0X*:vreity::f("variety") ; Fixes 1 word
:B0X*:vriet::f("variet") ; Fixes 5 words
:B0X*:vulnerablilit::f("vulnerabilit") ; Fixes 2 words
:B0X*:wa snot::f("was not") ; Fixes 1 word
:B0X*:waived off::f("waved off") ; Fixes 1 word
:B0X*:wan tit::f("want it") ; Fixes 1 word
:B0X*:wanna::f("want to") ; Fixes 1 word
:B0X*:warantee::f("warranty") ; Fixes 1 word
:B0X*:wardobe::f("wardrobe") ; Fixes 2 words
:B0X*:warn away::f("worn away") ; Fixes 1 word
:B0X*:warn down::f("worn down") ; Fixes 1 word
:B0X*:warn out::f("worn out") ; Fixes 1 word
:B0X*:was apart of::f("was a part of") ; Fixes 1 word
:B0X*:was began::f("began") ; Fixes 1 word
:B0X*:was build::f("was built") ; Fixes 1 word
:B0X*:was cutoff::f("was cut off") ; Fixes 1 word
:B0X*:was do to::f("was due to") ; Fixes 1 word
:B0X*:was drank::f("was drunk") ; Fixes 1 word
:B0X*:was it's::f("was its") ; Fixes 1 word
:B0X*:was knew::f("was known") ; Fixes 1 word
:B0X*:was lain::f("was laid") ; Fixes 1 word
:B0X*:was laying on::f("was lying on") ; Fixes 1 word
:B0X*:was lead by::f("was led by") ; Fixes 1 word
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
:B0X*:was suppose to::f("was supposed to") ; Fixes 1 word
:B0X*:was though that::f("was thought that") ; Fixes 1 word
:B0X*:was use to::f("was used to") ; Fixes 1 word
:B0X*:wasnt::f("wasn't") ; Fixes 1 word
:B0X*:way side::f("wayside") ; Fixes 1 word
:B0X*:wayword::f("wayward") ; Fixes 1 word
:B0X*:we;d::f("we'd") ; Fixes 1 word
:B0X*:weaponary::f("weaponry") ; Fixes 1 word
:B0X*:weather or not::f("whether or not") ; Fixes 1 word
:B0X*:weekness::f("weakness") ; Fixes 2 words 
:B0X*:well know::f("well known") ; Fixes 1 word
:B0X*:wendsay::f("Wednesday") ; Fixes 1 word
:B0X*:wensday::f("Wednesday") ; Fixes 1 word
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
:B0X*:were lead by::f("were led by") ; Fixes 1 word
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
:B0X*:were suppose to::f("were supposed to") ; Fixes 1 word
:B0X*:were took::f("were taken") ; Fixes 1 word
:B0X*:were use to::f("were used to") ; Fixes 1 word
:B0X*:wereabouts::f("whereabouts") ; Fixes 1 word
:B0X*:wern't::f("weren't") ; Fixes 1 word
:B0X*:wet your::f("whet your") ; Fixes 1 word
:B0X*:wether or not::f("whether or not") ; Fixes 1 word
:B0X*:what lead to::f("what led to") ; Fixes 1 word
:B0X*:what lied::f("what lay") ; Fixes 1 word
:B0X*:whent he::f("when the") ; Fixes 1 word
:B0X*:wheras::f("whereas") ; Fixes 1 word
:B0X*:where abouts::f("whereabouts") ; Fixes 1 word
:B0X*:where being::f("were being") ; Fixes 1 word
:B0X*:where by::f("whereby") ; Fixes 1 word
:B0X*:where him::f("where he") ; Fixes 1 word
:B0X*:where made::f("were made") ; Fixes 1 word
:B0X*:where taken::f("were taken") ; Fixes 1 word
:B0X*:where upon::f("whereupon") ; Fixes 1 word
:B0X*:where won::f("were won") ; Fixes 1 word
:B0X*:wherease::f("whereas") ; Fixes 1 word
:B0X*:whereever::f("wherever") ; Fixes 1 word
:B0X*:which had lead::f("which had led") ; Fixes 1 word
:B0X*:which has lead::f("which has led") ; Fixes 1 word
:B0X*:which have lead::f("which have led") ; Fixes 1 word
:B0X*:which where::f("which were") ; Fixes 1 word
:B0X*:whicht he::f("which the") ; Fixes 1 word
:B0X*:while him::f("while he") ; Fixes 1 word
:B0X*:whn::f("when") ; Fixes 5 words
:B0X*:who had lead::f("who had led") ; Fixes 1 word
:B0X*:who has lead::f("who has led") ; Fixes 1 word
:B0X*:who have lead::f("who have led") ; Fixes 1 word
:B0X*:who setup::f("who set up") ; Fixes 1 word
:B0X*:who use to::f("who used to") ; Fixes 1 word
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
:B0X*:wholey::f("wholly") ; Fixes 1 word
:B0X*:wholy::f("wholly") ; Fixes 1 word
:B0X*:whould::f("would") ; Fixes 5 words
:B0X*:whther::f("whether") ; Fixes 1 word
:B0X*:widesread::f("widespread") ; Fixes 3 words
:B0X*:wihh::f("withh") ; Fixes 7 words 
:B0X*:will backup::f("will back up") ; Fixes 1 word
:B0X*:will buyout::f("will buy out") ; Fixes 1 word
:B0X*:will shutdown::f("will shut down") ; Fixes 1 word
:B0X*:will shutoff::f("will shut off") ; Fixes 1 word
:B0X*:willbe::f("will be") ; Fixes 1 word
:B0X*:winther::f("winter") ; Fixes 33 words
:B0X*:with be::f("will be") ; Fixes 1 word
:B0X*:with it's::f("with its") ; Fixes 1 word
:B0X*:with out::f("without") ; Fixes 1 word
:B0X*:with regards to::f("with regard to") ; Fixes 1 word
:B0X*:withdrawl::f("withdrawal") ; Fixes 2 words
:B0X*:witheld::f("withheld") ; Fixes 1 word
:B0X*:withi t::f("with it") ; Fixes 1 word
:B0X*:within it's::f("within its") ; Fixes 1 word
:B0X*:within site of::f("within sight of") ; Fixes 1 word
:B0X*:withold::f("withhold") ; Fixes 6 words
:B0X*:witht he::f("with the") ; Fixes 1 word
:B0X*:wno::f("sno") ; Fixes 241 words 
:B0X*:won it's::f("won its") ; Fixes 1 word
:B0X*:wordlwide::f("worldwide") ; Fixes 1 word
:B0X*:working progress::f("work in progress") ; Fixes 1 word
:B0X*:world wide::f("worldwide") ; Fixes 1 word
:B0X*:worse comes to worse::f("worse comes to worst") ; Fixes 1 word
:B0X*:worse then::f("worse than") ; Fixes 1 word
:B0X*:worse-case scenario::f("worst-case scenario") ; Fixes 1 word
:B0X*:worst comes to worst::f("worse comes to worst") ; Fixes 1 word
:B0X*:worst than::f("worse than") ; Fixes 1 word
:B0X*:worsten::f("worsen") ; Fixes 5 words
:B0X*:worth it's::f("worth its") ; Fixes 1 word
:B0X*:worth while::f("worthwhile") ; Fixes 1 word
:B0X*:woudl::f("would") ; Fixes 5 words
:B0X*:would backup::f("would back up") ; Fixes 1 word
:B0X*:would comeback::f("would come back") ; Fixes 1 word
:B0X*:would fair::f("would fare") ; Fixes 1 word
:B0X*:would forego::f("would forgo") ; Fixes 1 word
:B0X*:would setup::f("would set up") ; Fixes 1 word
:B0X*:wouldbe::f("would be") ; Fixes 1 word
:B0X*:wreck havoc::f("wreak havoc") ; Fixes 1 word
:B0X*:wreckless::f("reckless") ; Fixes 3 words 
:B0X*:writers block::f("writer's block") ; Fixes 1 word
:B0X*:xoom::f("zoom") ; Fixes 15 words
:B0X*:yatch::f("yacht") ; Fixes 9 words
:B0X*:year old::f("year-old") ; Fixes 1 word
:B0X*:yelow::f("yellow") ; Fixes 28 words
:B0X*:yera::f("year") ; Fixes 17 words
:B0X*:yotube::f("youtube") ; Fixes 4 words
:B0X*:you're own::f("your own") ; Fixes 1 word
:B0X*:you;d::f("you'd") ; Fixes 1 word
:B0X*:youare::f("you are") ; Fixes 1 word
:B0X*:yould::f("would") ; Fixes 7 words 
:B0X*:your their::f("you're their") ; Fixes 1 word
:B0X*:your your::f("you're your") ; Fixes 1 word
:B0X*:youseff::f("yousef") ; Fixes 1 word
:B0X*:youself::f("yourself") ; Fixes 1 word
:B0X*:yrea::f("year") ; Fixes 17 words
:B0X*:yri::f("tri") ; Fixes 911 words
:B0X*:yuo::f("you") ; Fixes 51 words 
:B0X*?:0n0::f("-n-") ; For this-n-that
:B0X*?:a;;::f("all") ; Fixes 5025 words 
:B0X*?:aall::f("all") ; Fixes 4186 words
:B0X*?:abaptiv::f("adaptiv") ; Fixes 8 words
:B0X*?:abberr::f("aberr") ; Fixes 21 words
:B0X*?:abbout::f("about") ; Fixes 37 words
:B0X*?:abck::f("back") ; Fixes 410 words
:B0X*?:abilt::f("abilit") ; Fixes 1110 words
:B0X*?:ablit::f("abilit") ; Fixes 1110 words
:B0X*?:abrit::f("arbit") ; Fixes 53 words
:B0X*?:abser::f("obser") ; Fixes 53 words 
:B0X*?:abuda::f("abunda") ; Fixes 15 words
:B0X*?:acadm::f("academ") ; Fixes 32 words
:B0X*?:accadem::f("academ") ; Fixes 32 words
:B0X*?:acccus::f("accus") ; Fixes 37 words
:B0X*?:acceller::f("acceler") ; Fixes 23 words
:B0X*?:accensi::f("ascensi") ; Fixes 7 words
:B0X*?:acceptib::f("acceptab") ; Fixes 10 words
:B0X*?:accessab::f("accessib") ; Fixes 14 words
:B0X*?:accoc::f("assoc") ; Fixes 54 words 
:B0X*?:accomadat::f("accommodat") ; Fixes 23 words
:B0X*?:accomo::f("accommo") ; Fixes 23 words
:B0X*?:accoring::f("according") ; Fixes 3 words
:B0X*?:accous::f("acous") ; Fixes 10 words
:B0X*?:accqu::f("acqu") ; Fixes 89 words
:B0X*?:accro::f("acro") ; Fixes 145 words, but misspells accroides (An alcohol-soluble resin from Australian trees; used in varnishes and in manufacturing paper) 
:B0X*?:accuss::f("accus") ; Fixes 37 words
:B0X*?:acede::f("acade") ; Fixes 36 words
:B0X*?:acocu::f("accou") ; Fixes 40 words
:B0X*?:acom::f("accom") ; Fixes 49 words
:B0X*?:acquaintence::f("acquaintance") ; Fixes 6 words
:B0X*?:acquiantence::f("acquaintance") ; Fixes 6 words
:B0X*?:actial::f("actical") ; Fixes 29 words
:B0X*?:acurac::f("accurac") ; Fixes 4 words
:B0X*?:acustom::f("accustom") ; Fixes 17 words
:B0X*?:acys::f("acies") ; Fixes 101 words
:B0X*?:adantag::f("advantag") ; Fixes 15 words
:B0X*?:adaption::f("adaptation") ; Fixes 8 words
:B0X*?:adavan::f("advan") ; Fixes 30 words
:B0X*?:addion::f("addition") ; Fixes 7 words
:B0X*?:additon::f("addition") ; Fixes 7 words
:B0X*?:addm::f("adm") ; Fixes 144 words
:B0X*?:addop::f("adop") ; Fixes 35 words
:B0X*?:addow::f("adow") ; Fixes 43 words
:B0X*?:adequite::f("adequate") ; Fixes 6 words
:B0X*?:adif::f("atif") ; Fixes 50 words, but misspells Gadiformes (Cods, haddocks, grenadiers; in some classifications considered equivalent to the order Anacanthini)
:B0X*?:adiquate::f("adequate") ; Fixes 6 words
:B0X*?:admend::f("amend") ; Fixes 15 words
:B0X*?:admissab::f("admissib") ; Fixes 9 words
:B0X*?:admited::f("admitted") ; Fixes 3 words
:B0X*?:adquate::f("adequate") ; Fixes 6 words
:B0X*?:adquir::f("acquir") ; Fixes 16 words
:B0X*?:advanag::f("advantag") ; Fixes 15 words
:B0X*?:adventr::f("adventur") ; Fixes 29 words
:B0X*?:advertant::f("advertent") ; Fixes 4 words
:B0X*?:adviced::f("advised") ; Fixes 8 words
:B0X*?:aelog::f("aeolog") ; Fixes 12 words
:B0X*?:aeriel::f("aerial") ; Fixes 9 words
:B0X*?:affilat::f("affiliat") ; Fixes 16 words
:B0X*?:affilliat::f("affiliat") ; Fixes 16 words
:B0X*?:affort::f("afford") ; Fixes 13 words
:B0X*?:affraid::f("afraid") ; Fixes 4 words
:B0X*?:agail::f("avail") ; Fixes 38 words 
:B0X*?:aggree::f("agree") ; Fixes 28 words
:B0X*?:agrava::f("aggrava") ; Fixes 9 words
:B0X*?:agreg::f("aggreg") ; Fixes 19 words
:B0X*?:agress::f("aggress") ; Fixes 25 words
:B0X*?:ahev::f("have") ; Fixes 47 words
:B0X*?:ahpp::f("happ") ; Fixes 34 words
:B0X*?:ahve::f("have") ; Fixes 47 words, but misspells Ahvenanmaa, Jahvey, Wahvey, Yahve, Yahveh (All are different Hebrew names for God.) 
:B0X*?:aible::f("able") ; Fixes 2387 words
:B0X*?:aicraft::f("aircraft") ; Fixes 7 words
:B0X*?:ailabe::f("ailable") ; Fixes 12 words
:B0X*?:ailiab::f("ailab") ; Fixes 23 words
:B0X*?:ailib::f("ailab") ; Fixes 23 words
:B0X*?:ainity::f("ainty") ; Fixes 4 words
:B0X*?:aiotn::f("ation") ; Fixes 6184 words 
:B0X*?:aisian::f("Asian") ; Fixes 16 words
:B0X*?:aiton::f("ation") ; Fixes 5205 words
:B0X*?:alchohol::f("alcohol") ; Fixes 28 words
:B0X*?:alchol::f("alcohol") ;fixes 28 words
:B0X*?:alcohal::f("alcohol") ; Fixes 28 words
:B0X*?:alell::f("allel") ; Fixes 57 words
:B0X*?:aliab::f("ailab") ; Fixes 23 words
:B0X*?:alibit::f("abilit") ; Fixes 1110 words
:B0X*?:alitv::f("lativ") ; Fixes 97 words
:B0X*?:allth::f("alth") ; Fixes 56 words
:B0X*?:allto::f("alto") ; Fixes 32 words
:B0X*?:alochol::f("alcohol") ; Fixes 28 words
:B0X*?:alott::f("allott") ; Fixes 8 words
:B0X*?:alowe::f("allowe") ; Fixes 24 words
:B0X*?:alsay::f("alway") ; Fixes 4 words 
:B0X*?:alsitic::f("alistic") ; Fixes 98 words
:B0X*?:altion::f("lation") ; Fixes 448 words
:B0X*?:ameria::f("America") ; Fixes 28 words
:B0X*?:amerli::f("ameli") ; Fixes 41 words
:B0X*?:ametal::f("amental") ; Fixes 31 words
:B0X*?:aminter::f("aminer") ; Fixes 5 words
:B0X*?:amke::f("make") ; Fixes 122 words
:B0X*?:amking::f("making") ; Fixes 45 words
:B0X*?:ammn::f("amen") ; Fixes 246 words 
:B0X*?:ammou::f("amou") ; Fixes 99 words
:B0X*?:amny::f("many") ; Fixes 8 words
:B0X*?:analitic::f("analytic") ; Fixes 15 words
:B0X*?:anbd::f("and") ; Fixes 2083 words
:B0X*?:angabl::f("angeabl") ; Fixes 16 words
:B0X*?:angeing::f("anging") ; Fixes 38 words
:B0X*?:anmd::f("and") ; Fixes 2083 words
:B0X*?:annn::f("ann") ; Fixes 650 words
:B0X*?:annoi::f("anoi") ; Fixes 40 words
:B0X*?:annuled::f("annulled") ; Fixes 2 words
:B0X*?:anomo::f("anoma") ; Fixes 19 words
:B0X*?:anounc::f("announc") ; Fixes 9 words
:B0X*?:antaine::f("antine") ; Fixes 31 words
:B0X*?:anwser::f("answer") ; Fixes 20 words
:B0X*?:aost::f("oast") ; Fixes 75 words
:B0X*?:aparen::f("apparen") ; Fixes 8 words
:B0X*?:apear::f("appear") ; Fixes 22 words
:B0X*?:aplic::f("applic") ; Fixes 23 words
:B0X*?:aplie::f("applie") ; Fixes 11 words
:B0X*?:apoint::f("appoint") ; Fixes 30 words ; Misspells username Datapoint.
:B0X*?:appand::f("append") ; Fixes 25 words 
:B0X*?:apparan::f("apparen") ; Fixes 8 words
:B0X*?:appart::f("apart") ; Fixes 12 words
:B0X*?:appeares::f("appears") ; Fixes 3 words
:B0X*?:apperance::f("appearance") ; Fixes 8 words
:B0X*?:appol::f("apol") ; Fixes 64 words
:B0X*?:apprearance::f("appearance") ; Fixes 8 words
:B0X*?:apreh::f("appreh") ; Fixes 26 words
:B0X*?:apropri::f("appropri") ; Fixes 34 words
:B0X*?:aprov::f("approv") ; Fixes 23 words
:B0X*?:aptue::f("apture") ; Fixes 15 words
:B0X*?:apuur::f("aptur") ; Fixes 26 words 
:B0X*?:aquain::f("acquain") ; Fixes 22 words
:B0X*?:aquiant::f("acquaint") ; Fixes 22 words
:B0X*?:aquisi::f("acquisi") ; Fixes 10 words
:B0X*?:arange::f("arrange") ; Fixes 27 words
:B0X*?:arbitar::f("arbitrar") ; Fixes 7 words
:B0X*?:archao::f("archeo") ; Fixes 12 words
:B0X*?:archetect::f("architect") ; Fixes 20 words
:B0X*?:architectual::f("architectural") ; Fixes 4 words
:B0X*?:areat::f("arat") ; Fixes 136 words
:B0X*?:arhip::f("arship") ; Fixes 10 words
:B0X*?:ariage::f("arriage") ; Fixes 24 words
:B0X*?:ariman::f("airman") ; Fixes 10 words
:B0X*?:arogen::f("arrogan") ; Fixes 6 words
:B0X*?:arrern::f("attern") ; Fixes 21 words 
:B0X*?:arrri::f("arri") ; Fixes 159 words
:B0X*?:artdridge::f("artridge") ; Fixes 6 words
:B0X*?:articel::f("article") ; Fixes 11 words
:B0X*?:artrige::f("artridge") ; Fixes 6 words
:B0X*?:asdver::f("adver") ; Fixes 67 words
:B0X*?:asnd::f("and") ; Fixes 2083 words
:B0X*?:asociat::f("associat") ; Fixes 34 words
:B0X*?:asorb::f("absorb") ; Fixes 31 words
:B0X*?:asr::f("ase") ; Fixes 698 words, but misspells Basra (An oil city in Iraq) 
:B0X*?:assempl::f("assembl") ; Fixes 33 words
:B0X*?:assertation::f("assertion") ; Fixes 4 words
:B0X*?:assoca::f("associa") ; Fixes 38 words
:B0X*?:asss::f("as") ; Fixes 9311 words
:B0X*?:assym::f("asym") ; Fixes 17 words
:B0X*?:asthet::f("aesthet") ; Fixes 48 words
:B0X*?:asuing::f("ausing") ; Fixes 2 words
:B0X*?:atain::f("attain") ; Fixes 28 words
:B0X*?:ateing::f("ating") ; Fixes 1117 words
:B0X*?:atempt::f("attempt") ; Fixes 11 words
:B0X*?:atention::f("attention") ; Fixes 5 words
:B0X*?:athori::f("authori") ; Fixes 45 words
:B0X*?:aticula::f("articula") ; Fixes 69 words
:B0X*?:atoin::f("ation") ; Fixes 5229 words
:B0X*?:atribut::f("attribut") ; Fixes 31 words
:B0X*?:attachement::f("attachment") ; Fixes 4 words
:B0X*?:attemt::f("attempt") ; Fixes 11 words
:B0X*?:attenden::f("attendan") ; Fixes 7 words
:B0X*?:attensi::f("attenti") ; Fixes 16 words
:B0X*?:attentioin::f("attention") ; Fixes 5 words
:B0X*?:auclar::f("acular") ; Fixes 32 words
:B0X*?:audiance::f("audience") ; Fixes 4 words
:B0X*?:auther::f("author") ; Fixes 56 words
:B0X*?:authobiograph::f("autobiograph") ; Fixes 8 words
:B0X*?:authror::f("author") ; Fixes 56 words
:B0X*?:autit::f("audit") ; Fixes 33 words 
:B0X*?:automonom::f("autonom") ; Fixes 13 words
:B0X*?:avaialb::f("availab") ; Fixes 13 words
:B0X*?:availb::f("availab") ; Fixes 13 words
:B0X*?:avalab::f("availab") ; Fixes 13 words
:B0X*?:avalib::f("availab") ; Fixes 13 words
:B0X*?:aveing::f("aving") ; Fixes 60 words
:B0X*?:avila::f("availa") ; Fixes 13 words
:B0X*?:awess::f("awless") ; Fixes 12 words
:B0X*?:babilat::f("babilit") ; Fixes 19 words
:B0X*?:ballan::f("balan") ; Fixes 45 words
:B0X*?:baout::f("about") ; Fixes 37 words
:B0X*?:bateabl::f("batabl") ; Fixes 5 words
:B0X*?:bcak::f("back") ; Fixes 410 words
:B0X*?:beahv::f("behav") ; Fixes 33 words
:B0X*?:beatiful::f("beautiful") ; Fixes 5 words
:B0X*?:beaurocra::f("bureaucra") ; Fixes 22 words
:B0X*?:becoe::f("become") ; Fixes 4 words
:B0X*?:becomm::f("becom") ; Fixes 11 words
:B0X*?:bedore::f("before") ; Fixes 4 words
:B0X*?:beei::f("bei") ; Fixes 40 words
:B0X*?:behaio::f("behavio") ; Fixes 25 words
:B0X*?:behaiv::f("behavi") ; Fixes 33 words 
:B0X*?:belan::f("blan") ; Fixes 60 words
:B0X*?:belei::f("belie") ; Fixes 49 words
:B0X*?:belligeran::f("belligeren") ; Fixes 9 words
:B0X*?:benif::f("benef") ; Fixes 41 words
:B0X*?:bilsh::f("blish") ; Fixes 56 words
:B0X*?:biul::f("buil") ; Fixes 46 words
:B0X*?:blence::f("blance") ; Fixes 7 words
:B0X*?:bliah::f("blish") ; Fixes 56 words
:B0X*?:blich::f("blish") ; Fixes 56 words
:B0X*?:blisg::f("blish") ; Fixes 56 words
:B0X*?:bllish::f("blish") ; Fixes 56 words
:B0X*?:boaut::f("about") ; Fixes 37 words
:B0X*?:boder-line::f("border-line")
:B0X*?:bombardement::f("bombardment") ; Fixes 4 words
:B0X*?:bombarment::f("bombardment") ; Fixes 4 words
:B0X*?:bondary::f("boundary") ; Fixes 2 words
:B0X*?:borrom::f("bottom") ; Fixes 14 words
:B0X*?:botton::f("button") ; Fixes 42 words 
:B0X*?:boundr::f("boundar") ; Fixes 3 words
:B0X*?:bouth::f("bout") ; Fixes 53 words
:B0X*?:boxs::f("boxes") ; Fixes 44 words
:B0X*?:bradcast::f("broadcast") ; Fixes 13 words
:B0X*?:breif::f("brief") ; Fixes 22 words.
:B0X*?:brenc::f("branc") ; Fixes 70 words
:B0X*?:broadacast::f("broadcast") ; Fixes 13 words
:B0X*?:brod::f("broad") ; Fixes 55 words. Misspells brodiaea (a type of plant)
:B0X*?:buisn::f("busin") ; Fixes 17 words
:B0X*?:buring::f("burying") ; Fixes 4 words
:B0X*?:burrie::f("burie") ; Fixes 7 words
:B0X*?:busness::f("business") ; Fixes 14 words
:B0X*?:bussiness::f("business") ; Fixes 14 words
:B0X*?:caculater::f("calculator") ; Fixes 3 words
:B0X*?:caffin::f("caffein") ; Fixes 12 words
:B0X*?:caharcter::f("character") ; Fixes 38 words
:B0X*?:cahrac::f("charac") ; Fixes 45 words
:B0X*?:calculater::f("calculator") ; Fixes 3 words
:B0X*?:calculla::f("calcula") ; Fixes 41 words
:B0X*?:calculs::f("calculus") ; Fixes 3 words
:B0X*?:caluclat::f("calculat") ; Fixes 31 words
:B0X*?:caluculat::f("calculat") ; Fixes 31 words
:B0X*?:calulat::f("calculat") ; Fixes 31 words
:B0X*?:camae::f("came") ; Fixes 57 words
:B0X*?:campagin::f("campaign") ; Fixes 6 words
:B0X*?:campain::f("campaign") ; Fixes 6 words
:B0X*?:candad::f("candid") ; Fixes 15 words
:B0X*?:candiat::f("candidat") ; Fixes 6 words
:B0X*?:candidta::f("candidat") ; Fixes 6 words
:B0X*?:cannonic::f("canonic") ; Fixes 8 words
:B0X*?:caperbi::f("capabi") ; Fixes 5 words
:B0X*?:capibl::f("capabl") ; Fixes 10 words
:B0X*?:captia::f("capita") ; Fixes 69 words
:B0X*?:caracht::f("charact") ; Fixes 38 words
:B0X*?:caract::f("charact") ; Fixes 38 words
:B0X*?:carcirat::f("carcerat") ; Fixes 14 words
:B0X*?:carism::f("charism") ; Fixes 7 words
:B0X*?:cartileg::f("cartilag") ; Fixes 7 words
:B0X*?:cartilidg::f("cartilag") ; Fixes 7 words
:B0X*?:casette::f("cassette") ; Fixes 6 words
:B0X*?:casue::f("cause") ; Fixes 18 words
:B0X*?:catagor::f("categor") ; Fixes 52 words
:B0X*?:catergor::f("categor") ; Fixes 52 words
:B0X*?:cathlic::f("catholic") ; Fixes 28 words
:B0X*?:catholoc::f("catholic") ; Fixes 28 words
:B0X*?:catre::f("cater") ; Fixes 23 words.  Misspells fornicatress
:B0X*?:ccce::f("cce") ; Fixes 175 words
:B0X*?:ccesi::f("ccessi") ; Fixes 31 words
:B0X*?:ceiev::f("ceiv") ; Fixes 82 words
:B0X*?:ceing::f("cing") ; Fixes 275 words
:B0X*?:cencu::f("censu") ; Fixes 18 words
:B0X*?:centente::f("centen") ; Fixes 35 words
:B0X*?:cerimo::f("ceremo") ; Fixes 18 words
:B0X*?:ceromo::f("ceremo") ; Fixes 18 words
:B0X*?:certian::f("certain") ; Fixes 25 words
:B0X*?:cesion::f("cession") ; Fixes 51 words
:B0X*?:cesor::f("cessor") ; Fixes 33 words
:B0X*?:cesser::f("cessor") ; Fixes 33 words
:B0X*?:cev::f("ceiv") ; Fixes 82 words, but misspells ceviche (South American seafood dish)
:B0X*?:chack::f("check") ; Fixes 113 words , but misspells chack (Sound a bird makes). 
:B0X*?:chagne::f("change") ; Fixes 58 words
:B0X*?:chaleng::f("challeng") ; Fixes 17 words
:B0X*?:challang::f("challeng") ; Fixes 17 words
:B0X*?:challengabl::f("challengeabl") ; Fixes 4 words
:B0X*?:changab::f("changeab") ; Fixes 25 words
:B0X*?:charasma::f("charisma") ; Fixes 6 words
:B0X*?:charater::f("character") ; Fixes 38 words
:B0X*?:charector::f("character") ; Fixes 38 words
:B0X*?:chargab::f("chargeab") ; Fixes 7 words
:B0X*?:chartiab::f("charitab") ; Fixes 6 words
:B0X*?:cheif::f("chief") ; Fixes 24 words
:B0X*?:chemcial::f("chemical") ; Fixes 34 words
:B0X*?:chemestr::f("chemistr") ; Fixes 31 words
:B0X*?:chict::f("chit") ; Fixes 72 words
:B0X*?:childen::f("children") ; Fixes 6 words
:B0X*?:chracter::f("character") ; Fixes 38 words
:B0X*?:chter::f("cter") ; Fixes 221 words
:B0X*?:cidan::f("ciden") ; Fixes 46 words
:B0X*?:ciencio::f("cientio") ; Fixes 8 words
:B0X*?:ciepen::f("cipien") ; Fixes 18 words
:B0X*?:ciev::f("ceiv") ; Fixes 82 words
:B0X*?:cigic::f("cific") ; Fixes 44 words
:B0X*?:cilation::f("ciliation") ; Fixes 8 words
:B0X*?:cilliar::f("cillar") ; Fixes 8 words
:B0X*?:circut::f("circuit") ; Fixes 14 words
:B0X*?:ciricu::f("circu") ; Fixes 168 words
:B0X*?:cirp::f("crip") ; Fixes 126 words, but misspells Scirpus (Rhizomatous perennial grasslike herbs)
:B0X*?:cison::f("cision") ; Fixes 22 words
:B0X*?:citment::f("citement") ; Fixes 5 words
:B0X*?:civilli::f("civili") ; Fixes 44 words
:B0X*?:clae::f("clea") ; Fixes 151 words
:B0X*?:clasic::f("classic") ; Fixes 38 words
:B0X*?:clincial::f("clinical") ; Fixes 7 words
:B0X*?:clomation::f("clamation") ; Fixes 10 words
:B0X*?:cment::f("cement") ; Fixes 88 words 
:B0X*?:cmo::f("com") ; Fixes 1749 words
:B0X*?:cna::f("can") ; Fixes 1019 words.  Misspells Pycnanthemum (mint), and Tridacna (giant clam).+
:B0X*?:coee::f("code") ; Fixes 115 words 
:B0X*?:coform::f("conform") ; Fixes 46 words
:B0X*?:cogis::f("cognis") ; Fixes 36 words
:B0X*?:cogiz::f("cogniz") ; Fixes 42 words
:B0X*?:cogntivie::f("cognitive") ; Fixes 4 words
:B0X*?:colaborat::f("collaborat") ; Fixes 15 words
:B0X*?:colecti::f("collecti") ; Fixes 49 words
:B0X*?:colelct::f("collect") ; Fixes 69 words
:B0X*?:collon::f("colon") ; Fixes 89 words
:B0X*?:colomn::f("column") ; Fixes 20 words 
:B0X*?:comanie::f("companie") ; Fixes 5 words
:B0X*?:comany::f("company") ; Fixes 6 words
:B0X*?:comapan::f("compan") ; Fixes 39 words
:B0X*?:comapn::f("compan") ; Fixes 39 words
:B0X*?:comban::f("combin") ; Fixes 40 words
:B0X*?:combatent::f("combatant") ; Fixes 4 words
:B0X*?:combinatin::f("combination") ; Fixes 5 words
:B0X*?:combon::f("combin") ; Fixes 46 words 
:B0X*?:combusi::f("combusti") ; Fixes 17 words
:B0X*?:comemorat::f("commemorat") ; Fixes 12 words
:B0X*?:comiss::f("commiss") ; Fixes 33 words
:B0X*?:comitt::f("committ") ; Fixes 27 words
:B0X*?:commed::f("comed") ; Fixes 18 words
:B0X*?:commerical::f("commercial") ; Fixes 33 words
:B0X*?:commericial::f("commercial") ; Fixes 33 words
:B0X*?:commini::f("communi") ; Fixes 117 words
:B0X*?:commite::f("committe") ; Fixes 16 words
:B0X*?:commongly::f("commonly") ; Fixes 2 words
:B0X*?:commuica::f("communica") ; Fixes 72 words
:B0X*?:commuinica::f("communica") ; Fixes 72 words
:B0X*?:communcia::f("communica") ; Fixes 72 words
:B0X*?:communia::f("communica") ; Fixes 72 words
:B0X*?:compatiab::f("compatib") ; Fixes 16 words
:B0X*?:compeit::f("competit") ; Fixes 17 words
:B0X*?:compenc::f("compens") ; Fixes 29 words
:B0X*?:competan::f("competen") ; Fixes 21 words
:B0X*?:competati::f("competiti") ; Fixes 14 words
:B0X*?:competens::f("competenc") ; Fixes 12 words
:B0X*?:comphr::f("compr") ; Fixes 106 words
:B0X*?:compleate::f("complete") ; Fixes 17 words
:B0X*?:compleatness::f("completeness") ; Fixes 3 words
:B0X*?:comprab::f("comparab") ; Fixes 13 words
:B0X*?:comprimis::f("compromis") ; Fixes 12 words
:B0X*?:comun::f("commun") ; Fixes 140 words
:B0X*?:concider::f("consider") ; Fixes 31 words
:B0X*?:concious::f("conscious") ; Fixes 25 words
:B0X*?:condidt::f("condit") ; Fixes 36 words
:B0X*?:conect::f("connect") ; Fixes 52 words
:B0X*?:conferanc::f("conferenc") ; Fixes 12 words
:B0X*?:configurea::f("configura") ; Fixes 15 words
:B0X*?:confort::f("comfort") ; Fixes 21 words
:B0X*?:conllict::f("conflict") ; Fixes 17 words 
:B0X*?:conqur::f("conquer") ; Fixes 16 words
:B0X*?:conscen::f("consen") ; Fixes 17 words
:B0X*?:consectu::f("consecu") ; Fixes 4 words
:B0X*?:consentr::f("concentr") ; Fixes 32 words
:B0X*?:consept::f("concept") ; Fixes 46 words
:B0X*?:conservit::f("conservat") ; Fixes 41 words
:B0X*?:consici::f("consci") ; Fixes 45 words
:B0X*?:consico::f("conscio") ; Fixes 32 words
:B0X*?:considerd::f("considered") ; Fixes 5 words
:B0X*?:considerit::f("considerat") ; Fixes 12 words
:B0X*?:consio::f("conscio") ; Fixes 32 words
:B0X*?:constain::f("constrain") ; Fixes 15 words
:B0X*?:constin::f("contin") ; Fixes 86 words
:B0X*?:consumate::f("consummate") ; Fixes 6 words
:B0X*?:consumbe::f("consume") ; Fixes 15 words
:B0X*?:contect::f("context") ; Fixes 37 words 
:B0X*?:contian::f("contain") ; Fixes 28 words
:B0X*?:contien::f("conscien") ; Fixes 13 words
:B0X*?:contigen::f("contingen") ; Fixes 8 words
:B0X*?:contined::f("continued") ; Fixes 4 words
:B0X*?:continential::f("continental") ; Fixes 10 words
:B0X*?:continetal::f("continental") ; Fixes 10 words
:B0X*?:contino::f("continuo") ; Fixes 11 words
:B0X*?:contitut::f("constitut") ; Fixes 40 words
:B0X*?:contravers::f("controvers") ; Fixes 10 words
:B0X*?:contributer::f("contributor") ; Fixes 4 words
:B0X*?:controle::f("controlle") ; Fixes 10 words
:B0X*?:controveri::f("controversi") ; Fixes 9 words
:B0X*?:controversal::f("controversial") ; Fixes 8 words
:B0X*?:controvertial::f("controversial") ; Fixes 8 words
:B0X*?:contru::f("constru") ; Fixes 73 words
:B0X*?:convenant::f("covenant") ; Fixes 10 words
:B0X*?:convential::f("conventional") ; Fixes 23 words
:B0X*?:convere::f("confere") ; Fixes 19 words 
:B0X*?:convice::f("convince") ; Fixes 10 words
:B0X*?:coopor::f("cooper") ; Fixes 26 words
:B0X*?:coorper::f("cooper") ; Fixes 26 words
:B0X*?:copm::f("comp") ; Fixes 729 words
:B0X*?:copty::f("copy") ; Fixes 78 words
:B0X*?:coput::f("comput") ; Fixes 46 words
:B0X*?:copywrite::f("copyright") ; Fixes 6 words
:B0X*?:coropor::f("corpor") ; Fixes 74 words
:B0X*?:corpar::f("corpor") ; Fixes 74 words
:B0X*?:corpera::f("corpora") ; Fixes 59 words
:B0X*?:corporta::f("corporat") ; Fixes 53 words
:B0X*?:corprat::f("corporat") ; Fixes 53 words
:B0X*?:corpro::f("corpor") ; Fixes 74 words
:B0X*?:corrispond::f("correspond") ; Fixes 12 words
:B0X*?:costit::f("constit") ; Fixes 45 words
:B0X*?:cotten::f("cotton") ; Fixes 21 words
:B0X*?:countain::f("contain") ; Fixes 28 words
:B0X*?:couraing::f("couraging") ; Fixes 7 words
:B0X*?:couro::f("coro") ; Fixes 53 words
:B0X*?:courur::f("cour") ; Fixes 144 words
:B0X*?:cpom::f("com") ; Fixes 1749 words
:B0X*?:cpoy::f("copy") ; Fixes 78 words
:B0X*?:creaet::f("creat") ; Fixes 75 words
:B0X*?:credia::f("credita") ; Fixes 13 words
:B0X*?:credida::f("credita") ; Fixes 13 words
:B0X*?:criib::f("crib") ; Fixes 119 words
:B0X*?:crti::f("criti") ; Fixes 59 words
:B0X*?:crusie::f("cruise") ; Fixes 9 words
:B0X*?:crutia::f("crucia") ; Fixes 22 words
:B0X*?:crystalisa::f("crystallisa") ; Fixes 5 words
:B0X*?:ctaegor::f("categor") ; Fixes 52 words
:B0X*?:ctail::f("cktail") ; Fixes 6 words
:B0X*?:ctent::f("ctant") ; Fixes 30 words
:B0X*?:ctinos::f("ctions") ; Fixes 214 words
:B0X*?:ctoin::f("ction") ; Fixes 717 words
:B0X*?:cualr::f("cular") ; Fixes 256 words
:B0X*?:cuas::f("caus") ; Fixes 55 words
:B0X*?:cultral::f("cultural") ; Fixes 43 words
:B0X*?:cultue::f("culture") ; Fixes 48 words
:B0X*?:culure::f("culture") ; Fixes 48 words
:B0X*?:curcuit::f("circuit") ; Fixes 14 words
:B0X*?:cusotm::f("custom") ; Fixes 43 words
:B0X*?:cutsom::f("custom") ; Fixes 43 words
:B0X*?:cuture::f("culture") ; Fixes 48 words
:B0X*?:cxan::f("can") ; Fixes 1015 words
:B0X*?:damenor::f("demeanor") ; Fixes 4 words
:B0X*?:damenour::f("demeanour") ; Fixes 4 words
:B0X*?:dammag::f("damag") ; Fixes 11 words
:B0X*?:damy::f("demy") ; Fixes 28 words
:B0X*?:daugher::f("daughter") ; Fixes 12 words
:B0X*?:dcument::f("document") ; Fixes 26 words
:B0X*?:ddti::f("dditi") ; Fixes 14 words
:B0X*?:deatil::f("detail") ; Fixes 11 words
:B0X*?:decend::f("descend") ; Fixes 26 words
:B0X*?:decideab::f("decidab") ; Fixes 4 words
:B0X*?:decrib::f("describ") ; Fixes 19 words
:B0X*?:dectect::f("detect") ; Fixes 20 words
:B0X*?:defendent::f("defendant") ; Fixes 4 words
:B0X*?:deffens::f("defens") ; Fixes 26 words
:B0X*?:deffin::f("defin") ; Fixes 54 words
:B0X*?:defintion::f("definition") ; Fixes 5 words
:B0X*?:degrat::f("degrad") ; Fixes 31 words
:B0X*?:deinc::f("dienc") ; Fixes 20 words
:B0X*?:delag::f("deleg") ; Fixes 42 words
:B0X*?:delevop::f("develop") ; Fixes 44 words
:B0X*?:demeno::f("demeano") ; Fixes 8 words
:B0X*?:demmin::f("demin") ; Fixes 21 words 
:B0X*?:demorcr::f("democr") ; Fixes 27 words
:B0X*?:denegrat::f("denigrat") ; Fixes 10 words
:B0X*?:denpen::f("depen") ; Fixes 50 words
:B0X*?:dentational::f("dental") ; Fixes 46 words
:B0X*?:depedant::f("dependent") ; Fixes 11 words
:B0X*?:depeden::f("dependen") ; Fixes 29 words
:B0X*?:dependan::f("dependen") ; Fixes 29 words
:B0X*?:deptart::f("depart") ; Fixes 27 words
:B0X*?:deram::f("dream") ; Fixes 40 words
:B0X*?:deriviate::f("derive") ; Fixes 9 words
:B0X*?:derivit::f("derivat") ; Fixes 13 words
:B0X*?:descib::f("describ") ; Fixes 19 words
:B0X*?:descision::f("decision") ; Fixes 5 words
:B0X*?:descus::f("discus") ; Fixes 14 words.
:B0X*?:desided::f("decided") ; Fixes 7 words.
:B0X*?:desinat::f("destinat") ; Fixes 11 words.
:B0X*?:desireab::f("desirab") ; Fixes 11 words
:B0X*?:desision::f("decision") ; Fixes 5 words.
:B0X*?:desitn::f("destin") ; Fixes 30 words
:B0X*?:despatch::f("dispatch") ; Fixes 7 words.
:B0X*?:despensib::f("dispensab") ; Fixes 10 words
:B0X*?:despict::f("depict") ; Fixes 10 words.
:B0X*?:despira::f("despera") ; Fixes 9 words.
:B0X*?:destory::f("destroy") ; Fixes 8 words.
:B0X*?:detecab::f("detectab") ; Fixes 7 words
:B0X*?:develeopr::f("developer") ; Fixes 6 words.
:B0X*?:devellop::f("develop") ; Fixes 44 words.
:B0X*?:developor::f("developer") ; Fixes 6 words
:B0X*?:developpe::f("develope") ; Fixes 13 words
:B0X*?:develp::f("develop") ; Fixes 44 words.
:B0X*?:devid::f("divid") ; Fixes 61 words.
:B0X*?:devolop::f("develop") ; Fixes 44 words.
:B0X*?:dgeing::f("dging") ; Fixes 50 words
:B0X*?:dgement::f("dgment") ; Fixes 20 words
:B0X*?:diabnos::f("diagnos") ; Fixes 41 words 
:B0X*?:diapl::f("displ") ; Fixes 33 words.
:B0X*?:diarhe::f("diarrhoe") ; Fixes 7 words
:B0X*?:dicatb::f("dictab") ; Fixes 14 words
:B0X*?:diciplin::f("disciplin") ; Fixes 22 words
:B0X*?:dicover::f("discover") ; Fixes 26 words
:B0X*?:dicus::f("discus") ; Fixes 14 words
:B0X*?:difef::f("diffe") ; Fixes 48 words
:B0X*?:diferre::f("differe") ; Fixes 41 words
:B0X*?:differan::f("differen") ; Fixes 40 words
:B0X*?:diffren::f("differen") ; Fixes 40 words
:B0X*?:dilema::f("dilemma") ; Fixes 3 words 
:B0X*?:dimenion::f("dimension") ; Fixes 17 words
:B0X*?:dimention::f("dimension") ; Fixes 17 words
:B0X*?:dimesnion::f("dimension") ; Fixes 17 words
:B0X*?:diosese::f("diocese") ; Fixes 4 words
:B0X*?:dipend::f("depend") ; Fixes 50 words
:B0X*?:diriv::f("deriv") ; Fixes 26 words
:B0X*?:discrib::f("describ") ; Fixes 19 words
:B0X*?:disenting::f("dissenting") ; Fixes 2 words 
:B0X*?:disgno::f("diagno") ; Fixes 41 words 
:B0X*?:disipl::f("discipl") ; Fixes 26 words
:B0X*?:disolved::f("dissolved") ; Fixes 19 words
:B0X*?:dispaly::f("display") ; Fixes 11 words
:B0X*?:dispenc::f("dispens") ; Fixes 23 words
:B0X*?:dispensib::f("dispensab") ; Fixes 10 words
:B0X*?:disrict::f("district") ; Fixes 10 words
:B0X*?:distruct::f("destruct") ; Fixes 21 words
:B0X*?:ditonal::f("ditional") ; Fixes 25 words
:B0X*?:ditribut::f("distribut") ; Fixes 37 words
:B0X*?:divice::f("device") ; Fixes 4 words
:B0X*?:divsi::f("divisi") ; Fixes 24 words
:B0X*?:dmant::f("dment") ; Fixes 28 words
:B0X*?:dminst::f("dminist") ; Fixes 27 words
:B0X*?:doccu::f("docu") ; Fixes 32 words
:B0X*?:doctin::f("doctrin") ; Fixes 14 words
:B0X*?:docuement::f("document") ; Fixes 26 words
:B0X*?:doind::f("doing") ; Fixes 21 words
:B0X*?:dolan::f("dolen") ; Fixes 12 words
:B0X*?:doller::f("dollar") ; Fixes 14 words
:B0X*?:dominent::f("dominant") ; Fixes 9 words
:B0X*?:dowloads::f("download") ; Fixes 9 words
:B0X*?:dpend::f("depend") ; Fixes 50 words
:B0X*?:dramtic::f("dramatic") ; Fixes 11 words
:B0X*?:driect::f("direct") ; Fixes 71 words
:B0X*?:drnik::f("drink") ; Fixes 23 words
:B0X*?:duec::f("duce") ; Fixes 118 words, but misspells duecento (Literally "two hundred." Word for the Italian culture of the 13th century).
:B0X*?:dulgue::f("dulge") ; Fixes 23 words
:B0X*?:dupicat::f("duplicat") ; Fixes 26 words
:B0X*?:durig::f("during") ; Fixes 5 words
:B0X*?:durring::f("during") ; Fixes 5 words
:B0X*?:duting::f("during") ; Fixes 5 words
:B0X*?:eacll::f("ecall") ; Fixes 8 words
:B0X*?:eanr::f("earn") ; Fixes 60 words
:B0X*?:eaolog::f("eolog") ; Fixes 134 words
:B0X*?:eareance::f("earance") ; Fixes 12 words
:B0X*?:earence::f("earance") ; Fixes 12 words
:B0X*?:easen::f("easan") ; Fixes 33 words
:B0X*?:ecco::f("eco") ; Fixes 994 words, but misspells Prosecco (Italian wine) and recco (abbrev. for Reconnaissance)
:B0X*?:eccu::f("ecu") ; Fixes 353 words
:B0X*?:eceed::f("ecede") ; Fixes 35 words
:B0X*?:eceonom::f("econom") ; Fixes 50 words
:B0X*?:ecepi::f("ecipi") ; Fixes 28 words
:B0X*?:eckk::f("eck") ; Fixes 443 words 
:B0X*?:ecuat::f("equat") ; Fixes 22 words
:B0X*?:ecyl::f("ecycl") ; Fixes 15 words
:B0X*?:edabl::f("edibl") ; Fixes 11 words
:B0X*?:eearl::f("earl") ; Fixes 66 words
:B0X*?:eeen::f("een") ; Fixes 452 words
:B0X*?:eeep::f("eep") ; Fixes 316 words
:B0X*?:eesag::f("essag") ; Fixes 9 words 
:B0X*?:eferan::f("eferen") ; Fixes 35 words 
:B0X*?:efered::f("eferred") ; Fixes 5 words
:B0X*?:efering::f("eferring") ; Fixes 3 words
:B0X*?:efern::f("eferen") ; Fixes 35 words
:B0X*?:effecien::f("efficien") ; Fixes 10 words
:B0X*?:egth::f("ength") ; Fixes 33 words
:B0X*?:ehter::f("ether") ; Fixes 84 words
:B0X*?:eild::f("ield") ; Fixes 147 words
:B0X*?:eizm::f("eism") ; Fixes 96 words , but misspells Weizmann (First president of Israel). 
:B0X*?:elavan::f("elevan") ; Fixes 16 words
:B0X*?:elction::f("election") ; Fixes 20 words
:B0X*?:electic::f("electric") ; Fixes 40 words
:B0X*?:electrial::f("electrical") ; Fixes 13 words
:B0X*?:elemin::f("elimin") ; Fixes 14 words
:B0X*?:eletric::f("electric") ; Fixes 40 words
:B0X*?:elien::f("elian") ; Fixes 27 words
:B0X*?:eligab::f("eligib") ; Fixes 10 words
:B0X*?:eligo::f("eligio") ; Fixes 30 words
:B0X*?:eliment::f("element") ; Fixes 12 words
:B0X*?:ellected::f("elected") ; Fixes 11 words
:B0X*?:elyhood::f("elihood") ; Fixes 6 words
:B0X*?:embarass::f("embarrass") ; Fixes 17 words
:B0X*?:emce::f("ence") ; Fixes 775 words, but misspells emcee (host at formal occasion)
:B0X*?:emiting::f("emitting") ; Fixes 6 words
:B0X*?:emmediate::f("immediate") ; Fixes 3 words
:B0X*?:emmigr::f("emigr") ; Fixes 21 words
:B0X*?:emmis::f("emis") ; Fixes 214 words
:B0X*?:emmit::f("emitt") ; Fixes 28 words
:B0X*?:emnt::f("ment") ; Fixes 2167 words 
:B0X*?:emostr::f("emonstr") ; Fixes 45 words
:B0X*?:empahs::f("emphas") ; Fixes 42 words
:B0X*?:emperic::f("empiric") ; Fixes 10 words
:B0X*?:emphais::f("emphasis") ; Fixes 21 words
:B0X*?:emphsis::f("emphasis") ; Fixes 21 words
:B0X*?:emprison::f("imprison") ; Fixes 11 words
:B0X*?:enchang::f("enchant") ; Fixes 27 words
:B0X*?:encial::f("ential") ; Fixes 244 words
:B0X*?:endand::f("endant") ; Fixes 19 words
:B0X*?:endig::f("ending") ; Fixes 109 words
:B0X*?:enduc::f("induc") ; Fixes 33 words
:B0X*?:enece::f("ence") ; Fixes 775 words
:B0X*?:enence::f("enance") ; Fixes 18 words
:B0X*?:enflam::f("inflam") ; Fixes 22 words
:B0X*?:engagment::f("engagement") ; Fixes 6 words
:B0X*?:engeneer::f("engineer") ; Fixes 17 words
:B0X*?:engieneer::f("engineer") ; Fixes 17 words
:B0X*?:engten::f("engthen") ; Fixes 17 words
:B0X*?:entagl::f("entangl") ; Fixes 19 words
:B0X*?:entaly::f("entally") ; Fixes 46 words
:B0X*?:entatr::f("entar") ; Fixes 81 words
:B0X*?:entce::f("ence") ; Fixes 775 words
:B0X*?:entgh::f("ength") ; Fixes 33 words
:B0X*?:enthusiatic::f("enthusiastic") ; Fixes 6 words
:B0X*?:entiatiation::f("entiation") ; Fixes 8 words
:B0X*?:entily::f("ently") ; Fixes 261 wordsuently
:B0X*?:envolu::f("evolu") ; Fixes 50 words
:B0X*?:enxt::f("next") ; Fixes 23 words
:B0X*?:eperat::f("eparat") ; Fixes 33 words
:B0X*?:equalibr::f("equilibr") ; Fixes 20 words
:B0X*?:equelibr::f("equilibr") ; Fixes 20 words
:B0X*?:equialent::f("equivalent") ; Fixes 8 words
:B0X*?:equilibium::f("equilibrium") ; Fixes 4 words
:B0X*?:equilibrum::f("equilibrium") ; Fixes 4 words
:B0X*?:equivilant::f("equivalent") ; Fixes 8 words
:B0X*?:equivilent::f("equivalent") ; Fixes 8 words
:B0X*?:erchen::f("erchan") ; Fixes 42 words
:B0X*?:ereance::f("earance") ; Fixes 12 words
:B0X*?:eremt::f("erent") ; Fixes 96 words
:B0X*?:erionn::f("ersion") ; Fixes 74 words 
:B0X*?:ernece::f("erence") ; Fixes 54 words
:B0X*?:erruped::f("errupted") ; Fixes 6 words
:B0X*?:esab::f("essab") ; Fixes 9 words
:B0X*?:esential::f("essential") ; Fixes 8 words
:B0X*?:esisten::f("esistan") ; Fixes 11 words
:B0X*?:esitmat::f("estimat") ; Fixes 15 words
:B0X*?:essense::f("essence") ; Fixes 4 words
:B0X*?:essentail::f("essential") ; Fixes 18 words
:B0X*?:essentual::f("essential") ; Fixes 18 words
:B0X*?:estabish::f("establish") ; Fixes 34 words
:B0X*?:esxual::f("sexual") ; Fixes 91 words
:B0X*?:etanc::f("etenc") ; Fixes 20 words
:B0X*?:etead::f("eated") ; Fixes 50 words
:B0X*?:ethime::f("etime") ; Fixes 20 words 
:B0X*?:exagerat::f("exaggerat") ; Fixes 15 words
:B0X*?:exagerrat::f("exaggerat") ; Fixes 15 words
:B0X*?:exampt::f("exempt") ; Fixes 7 words
:B0X*?:exapan::f("expan") ; Fixes 42 words
:B0X*?:excact::f("exact") ; Fixes 25 words
:B0X*?:excang::f("exchang") ; Fixes 13 words
:B0X*?:excecut::f("execut") ; Fixes 27 words
:B0X*?:excedd::f("exceed") ; Fixes 9 words
:B0X*?:excercis::f("exercis") ; Fixes 15 words
:B0X*?:exchanch::f("exchang") ; Fixes 12 words
:B0X*?:excist::f("exist") ; Fixes 38 words
:B0X*?:execis::f("exercis") ; Fixes 15 words
:B0X*?:exeed::f("exceed") ; Fixes 9 words
:B0X*?:exept::f("except") ; Fixes 25 words
:B0X*?:exersize::f("exercise") ; Fixes 11 words
:B0X*?:exict::f("excit") ; Fixes 39 words
:B0X*?:exinct::f("extinct") ; Fixes 4 words
:B0X*?:exisit::f("exist") ; Fixes 38 words
:B0X*?:existan::f("existen") ; Fixes 22 words
:B0X*?:exlile::f("exile") ; Fixes 5 words
:B0X*?:exmapl::f("exampl") ; Fixes 7 words
:B0X*?:expalin::f("explain") ; Fixes 20 words
:B0X*?:expeced::f("expected") ; Fixes 6 words
:B0X*?:expecial::f("especial") ; Fixes 5 words
:B0X*?:experianc::f("experienc") ; Fixes 11 words
:B0X*?:expidi::f("expedi") ; Fixes 32 words
:B0X*?:expierenc::f("experienc") ; Fixes 11 words
:B0X*?:expirien::f("experien") ; Fixes 15 words
:B0X*?:explanit::f("explanat") ; Fixes 8 words 
:B0X*?:explict::f("explicit") ; Fixes 7 words
:B0X*?:exploitit::f("exploitat") ; Fixes 9 words
:B0X*?:explotat::f("exploitat") ; Fixes 9 words
:B0X*?:exprienc::f("experienc") ; Fixes 11 words
:B0X*?:exressed::f("expressed") ; Fixes 52 words
:B0X*?:exsis::f("exis") ; Fixes 48 words
:B0X*?:extention::f("extension") ; Fixes 10 words
:B0X*?:extint::f("extinct") ; Fixes 4 words
:B0X*?:facist::f("fascist") ; Fixes 7 words
:B0X*?:fagia::f("phagia") ; Fixes 18 words
:B0X*?:falab::f("fallib") ; Fixes 10 words
:B0X*?:fallab::f("fallib") ; Fixes 10 words
:B0X*?:familar::f("familiar") ; Fixes 36 words
:B0X*?:familli::f("famili") ; Fixes 37 words
:B0X*?:fammi::f("fami") ; Fixes 57 words
:B0X*?:fascit::f("facet") ; Fixes 14 words
:B0X*?:fasia::f("phasia") ; Fixes 10 words
:B0X*?:fatc::f("fact") ; Fixes 200 words
:B0X*?:fature::f("facture") ; Fixes 10 words
:B0X*?:faught::f("fought") ; Fixes 7 words
:B0X*?:feasable::f("feasible") ; Fixes 11 words, but misspells unfeasable (archaic, no longer used)
:B0X*?:fedre::f("feder") ; Fixes 45 words
:B0X*?:femmi::f("femi") ; Fixes 82 words 
:B0X*?:fencive::f("fensive") ; Fixes 15 words
:B0X*?:ferec::f("ferenc") ; Fixes 45 words
:B0X*?:ferente::f("ference") ; Fixes 43 words 
:B0X*?:feriang::f("ferring") ; Fixes 6 words
:B0X*?:ferren::f("feren") ; Fixes 113 words
:B0X*?:fertily::f("fertility") ; Fixes 7 words
:B0X*?:fesion::f("fession") ; Fixes 40 words
:B0X*?:fesser::f("fessor") ; Fixes 12 words
:B0X*?:festion::f("festation") ; Fixes 8 words
:B0X*?:ffese::f("fesse") ; Fixes 10 words
:B0X*?:fficen::f("fficien") ; Fixes 20 words
:B0X*?:fianit::f("finit") ; Fixes 79 words
:B0X*?:fictious::f("fictitious") ; Fixes 4 words
:B0X*?:fidn::f("find") ; Fixes 22 words
:B0X*?:fiet::f("feit") ; Fixes 23 words
:B0X*?:filiament::f("filament") ; Fixes 16 words
:B0X*?:filitrat::f("filtrat") ; Fixes 21 words
:B0X*?:fimil::f("famil") ; Fixes 43 words
:B0X*?:finac::f("financ") ; Fixes 14 words
:B0X*?:finat::f("finit") ; Fixes 43 words
:B0X*?:finet::f("finit") ; Fixes 43 words
:B0X*?:finining::f("fining") ; Fixes 12 words
:B0X*?:firend::f("friend") ; Fixes 30 words
:B0X*?:firmm::f("firm") ; Fixes 85 words
:B0X*?:fisi::f("fissi") ; Fixes 35 words
:B0X*?:flama::f("flamma") ; Fixes 17 words
:B0X*?:flourid::f("fluorid") ; Fixes 25 words
:B0X*?:flourin::f("fluorin") ; Fixes 5 words
:B0X*?:fluan::f("fluen") ; Fixes 48 words
:B0X*?:fluorish::f("flourish") ; Fixes 13 words
:B0X*?:focuss::f("focus") ; Fixes 6 words 
:B0X*?:foer::f("fore") ; Fixes 340 words
:B0X*?:follwo::f("follow") ; Fixes 10 words
:B0X*?:folow::f("follow") ; Fixes 10 words
:B0X*?:fomat::f("format") ; Fixes 72 words
:B0X*?:fomed::f("formed") ; Fixes 37 words
:B0X*?:fomr::f("form") ; Fixes 1269 words
:B0X*?:foneti::f("phoneti") ; Fixes 24 words
:B0X*?:fontrier::f("frontier") ; Fixes 6 words
:B0X*?:fooot::f("foot") ; Fixes 176 words
:B0X*?:forbiden::f("forbidden") ; Fixes 7 words
:B0X*?:foretun::f("fortun") ; Fixes 18 words
:B0X*?:forgetab::f("forgettab") ; Fixes 7 words
:B0X*?:forgiveabl::f("forgivabl") ; Fixes 6 words
:B0X*?:formidible::f("formidable") ; Fixes 5 words
:B0X*?:formost::f("foremost") ; Fixes 5 words
:B0X*?:forsee::f("foresee") ; Fixes 16 words
:B0X*?:forwrd::f("forward") ; Fixes 16 words
:B0X*?:foucs::f("focus") ; Fixes 28 words
:B0X*?:foudn::f("found") ; Fixes 62 words
:B0X*?:fourti::f("forti") ; Fixes 31 words
:B0X*?:fourtun::f("fortun") ; Fixes 18 words
:B0X*?:foward::f("forward") ; Fixes 16 words
:B0X*?:freind::f("friend") ; Fixes 44 words
:B0X*?:frence::f("ference") ; Fixes 37 words
:B0X*?:fromed::f("formed") ; Fixes 34 words
:B0X*?:fromi::f("formi") ; Fixes 84 words
:B0X*?:fucnt::f("funct") ; Fixes 60 words
:B0X*?:fufill::f("fulfill") ; Fixes 16 words
:B0X*?:fugure::f("figure") ; Fixes 36 words
:B0X*?:fulen::f("fluen") ; Fixes 64 words
:B0X*?:fullfill::f("fulfill") ; Fixes 16 words
:B0X*?:furut::f("furt") ; Fixes 16 words
:B0X*?:fuult::f("fault") ; Fixes 32 words 
:B0X*?:gallax::f("galax") ; Fixes 4 words
:B0X*?:galvin::f("galvan") ; Fixes 27 words
:B0X*?:ganaly::f("ginally") ; Fixes 8 words
:B0X*?:ganera::f("genera") ; Fixes 124 words
:B0X*?:garant::f("guarant") ; Fixes 9 words
:B0X*?:garav::f("grav") ; Fixes 128 words
:B0X*?:garnison::f("garrison") ; Fixes 5 words
:B0X*?:gaurant::f("guarant") ; Fixes 9 words
:B0X*?:gaurd::f("guard") ; Fixes 57 words
:B0X*?:gemer::f("gener") ; Fixes 151 words
:B0X*?:generatt::f("generat") ; Fixes 58 words
:B0X*?:gestab::f("gestib") ; Fixes 19 words
:B0X*?:giid::f("good") ; Fixes 31 words, but misspells Phalangiidae (typoe of Huntsman spider)
:B0X*?:glight::f("flight") ; Fixes 16 words
:B0X*?:glph::f("glyph") ; Fixes 27 words
:B0X*?:glua::f("gula") ; Fixes 174 words
:B0X*?:gnficia::f("gnifica") ; Fixes 29 words
:B0X*?:gnizen::f("gnizan") ; Fixes 9 words
:B0X*?:godess::f("goddess") ; Fixes 5 words
:B0X*?:gorund::f("ground") ; Fixes 80 words
:B0X*?:gourp::f("group") ; Fixes 28 words 
:B0X*?:govement::f("government") ; Fixes 10 words
:B0X*?:govenment::f("government") ; Fixes 10 words
:B0X*?:govenrment::f("government") ; Fixes 10 words
:B0X*?:govera::f("governa") ; Fixes 11 words
:B0X*?:goverment::f("government") ; Fixes 10 words
:B0X*?:govor::f("govern") ; Fixes 46 words
:B0X*?:gradded::f("graded") ; Fixes 13 words
:B0X*?:graffitti::f("graffiti") ; Fixes 6 words
:B0X*?:grama::f("gramma") ; Fixes 72 words, but misspells grama (Pasture grass of plains of South America and western North America)
:B0X*?:grammma::f("gramma") ; Fixes 72 words
:B0X*?:greatful::f("grateful") ; Fixes 8 words
:B0X*?:gresion::f("gression") ; Fixes 27 words
:B0X*?:gropu::f("group") ; Fixes 28 words
:B0X*?:gruop::f("group") ; Fixes 28 words
:B0X*?:grwo::f("grow") ; Fixes 67 words
:B0X*?:gsit::f("gist") ; Fixes 585 words
:B0X*?:gubl::f("guabl") ; Fixes 8 words
:B0X*?:guement::f("gument") ; Fixes 21 words
:B0X*?:guidence::f("guidance") ; Fixes 4 words
:B0X*?:gurantee::f("guarantee") ; Fixes 5 words
:B0X*?:habitans::f("habitants") ; Fixes 3 words
:B0X*?:habition::f("hibition") ; Fixes 21 words
:B0X*?:haneg::f("hange") ; Fixes 69 words
:B0X*?:harased::f("harassed") ; Fixes 3 words
:B0X*?:havour::f("havior") ; Fixes 13 words
:B0X*?:hcange::f("change") ; Fixes 58 words
:B0X*?:hcih::f("hich") ; Fixes 15 words
:B0X*?:heee::f("hee") ; Fixes 494 words 
:B0X*?:heirarch::f("hierarch") ; Fixes 14 words
:B0X*?:heiroglyph::f("hieroglyph") ; Fixes 6 words
:B0X*?:heiv::f("hiev") ; Fixes 49 words
:B0X*?:herant::f("herent") ; Fixes 10 words
:B0X*?:heridit::f("heredit") ; Fixes 19 words
:B0X*?:hertia::f("herita") ; Fixes 23 words
:B0X*?:hertzs::f("hertz") ; Fixes 12 words
:B0X*?:hicial::f("hical") ; Fixes 170 words
:B0X*?:hierach::f("hierarch") ; Fixes 14 words
:B0X*?:hierarcic::f("hierarchic") ; Fixes 6 words
:B0X*?:higway::f("highway") ; Fixes 6 words
:B0X*?:hnag::f("hang") ; Fixes 150 words
:B0X*?:holf::f("hold") ; Fixes 120 words
:B0X*?:hospiti::f("hospita") ; Fixes 27 words
:B0X*?:houno::f("hono") ; Fixes 99 words
:B0X*?:hstor::f("histor") ; Fixes 56 words
:B0X*?:humerous::f("humorous") ; Fixes 6 words
:B0X*?:humur::f("humour") ; Fixes 12 words
:B0X*?:hvae::f("have") ; Fixes 47 words
:B0X*?:hvai::f("havi") ; Fixes 37 words
:B0X*?:hvea::f("have") ; Fixes 47 words
:B0X*?:hwere::f("where") ; Fixes 27 words
:B0X*?:hydog::f("hydrog") ; Fixes 50 words
:B0X*?:hymm::f("hym") ; Fixes 125 words
:B0X*?:ibile::f("ible") ; Fixes 367 words
:B0X*?:ibilt::f("ibilit") ; Fixes 281 words
:B0X*?:iblit::f("ibilit") ; Fixes 281 words
:B0X*?:icibl::f("iceabl") ; Fixes 14 words
:B0X*?:iciton::f("iction") ; Fixes 89 words
:B0X*?:idenital::f("idential") ; Fixes 18 words
:B0X*?:iegh::f("eigh") ; Fixes 186 words
:B0X*?:iegn::f("eign") ; Fixes 83 words
:B0X*?:ievn::f("iven") ; Fixes 440 words
:B0X*?:igeou::f("igiou") ; Fixes 23 words
:B0X*?:igini::f("igni") ; Fixes 127 words
:B0X*?:ignf::f("ignif") ; Fixes 50 words
:B0X*?:ignot::f("ignor") ; Fixes 51 words 
:B0X*?:igous::f("igious") ; Fixes 23 words, but misspells pemphigous (a skin disease)
:B0X*?:igth::f("ight") ; Jack's fixes 315 words
:B0X*?:ihs::f("his") ; Fixes 618 words
:B0X*?:iht::f("ith") ; Fixes 560 words
:B0X*?:ijng::f("ing") ; Fixes 15158 words
:B0X*?:ilair::f("iliar") ; Fixes 46 words
:B0X*?:illution::f("illusion") ; Fixes 16 words
:B0X*?:imagen::f("imagin") ; Fixes 40 words
:B0X*?:immita::f("imita") ; Fixes 41 words
:B0X*?:impliment::f("implement") ; Fixes 17 words
:B0X*?:imploy::f("employ") ; Fixes 38 words
:B0X*?:importen::f("importan") ; Fixes 10 words
:B0X*?:imprion::f("imprison") ; Fixes 11 words
:B0X*?:incede::f("incide") ; Fixes 21 words
:B0X*?:incidential::f("incidental") ; Fixes 6 words
:B0X*?:incra::f("incre") ; Fixes 28 words
:B0X*?:inctro::f("intro") ; Fixes 68 words
:B0X*?:indeca::f("indica") ; Fixes 40 words
:B0X*?:indite::f("indict") ; Fixes 22 words, but misspells indite (Produce a literaryÂ work)
:B0X*?:indutr::f("industr") ; Fixes 59 words
:B0X*?:indvidua::f("individua") ; Fixes 32 words
:B0X*?:inece::f("ience") ; Fixes 101 words
:B0X*?:ineing::f("ining") ; Fixes 193 words
:B0X*?:infectuo::f("infectio") ; Fixes 15 words
:B0X*?:infite::f("invite") ; Fixes 19 words 
:B0X*?:infrant::f("infant") ; Fixes 31 words
:B0X*?:infrige::f("infringe") ; Fixes 7 words
:B0X*?:ingenius::f("ingenious") ; Fixes 4 words
:B0X*?:inheritage::f("inheritance") ; Fixes 4 words
:B0X*?:inheritence::f("inheritance") ; Fixes 4 words
:B0X*?:inially::f("inally") ; Fixes 46 words
:B0X*?:ininis::f("inis") ; Fixes 388 words
:B0X*?:inital::f("initial") ; Fixes 25 words
:B0X*?:inng::f("ing") ; Fixes 15158 words
:B0X*?:innocula::f("inocula") ; Fixes 16 words
:B0X*?:inpeach::f("impeach") ; Fixes 15 words
:B0X*?:inpolit::f("impolit") ; Fixes 7 words
:B0X*?:inprison::f("imprison") ; Fixes 11 words
:B0X*?:inprov::f("improv") ; Fixes 41 words
:B0X*?:institue::f("institute") ; Fixes 8 words
:B0X*?:instu::f("instru") ; Fixes 44 words
:B0X*?:intelect::f("intellect") ; Fixes 42 words
:B0X*?:intelig::f("intellig") ; Fixes 27 words
:B0X*?:intenational::f("international") ; Fixes 27 words
:B0X*?:intented::f("intended") ; Fixes 7 words
:B0X*?:intepret::f("interpret") ; Fixes 39 words
:B0X*?:interational::f("international") ; Fixes 27 words
:B0X*?:interferance::f("interference") ; Fixes 4 words
:B0X*?:intergrat::f("integrat") ; Fixes 35 words
:B0X*?:interpet::f("interpret") ; Fixes 39 words
:B0X*?:interupt::f("interrupt") ; Fixes 15 words
:B0X*?:inteven::f("interven") ; Fixes 20 words
:B0X*?:intrduc::f("introduc") ; Fixes 16 words
:B0X*?:intrest::f("interest") ; Fixes 19 words
:B0X*?:intruduc::f("introduc") ; Fixes 16 words
:B0X*?:intut::f("intuit") ; Fixes 19 words
:B0X*?:inudstr::f("industr") ; Fixes 59 words
:B0X*?:investingat::f("investigat") ; Fixes 17 words
:B0X*?:iopn::f("ion") ; Fixes 8515 words
:B0X*?:iouness::f("iousness") ; Fixes 220 words
:B0X*?:iousit::f("iosit") ; Fixes 15 words
:B0X*?:irts::f("irst") ; Fixes 41 words
:B0X*?:isherr::f("isher") ; Fixes 71 words
:B0X*?:ishor::f("isher") ; Fixes 71 words
:B0X*?:ishre::f("isher") ; Fixes 71 words
:B0X*?:isile::f("issile") ; Fixes 6 words
:B0X*?:issence::f("issance") ; Fixes 11 words
:B0X*?:iticing::f("iticising") ; Fixes 3 words
:B0X*?:itina::f("itiona") ; Fixes 79 words, misspells Mephitinae (skunk), neritina (snail)
:B0X*?:ititia::f("initia") ; Fixes 41 words
:B0X*?:itition::f("ition") ; Fixes 389 words
:B0X*?:itnere::f("intere") ; Fixes 25 words
:B0X*?:itnroduc::f("introduc") ; Fixes 16 words
:B0X*?:itoin::f("ition") ; Fixes 389 words
:B0X*?:itttle::f("ittle") ; Fixes 49 words
:B0X*?:iveing::f("iving") ; Fixes 75 words
:B0X*?:iverous::f("ivorous") ; Fixes 17 words
:B0X*?:ivle::f("ivel") ; Fixes 589 words, but misspells braaivleis (Type of S. Affrican BBQ)
:B0X*?:iwll::f("will") ; Fixes 64 words
:B0X*?:iwth::f("with") ; Fixes 56 words
:B0X*?:jecutr::f("jectur") ; Fixes 8 words
:B0X*?:jist::f("gist") ; Fixes 587 words
:B0X*?:jstu::f("just") ; Fixes 83 words
:B0X*?:jsut::f("just") ; Fixes 83 words
:B0X*?:juct::f("junct") ; Fixes 58 words
:B0X*?:judgment::f("judgement") ; Fixes 11 words
:B0X*?:judical::f("judicial") ; Fixes 9 words
:B0X*?:judisua::f("judicia") ; Fixes 11 words
:B0X*?:juduci::f("judici") ; Fixes 20 words
:B0X*?:jugment::f("judgment") ; Fixes 12 words
:B0X*?:kindergarden::f("kindergarten") ; Fixes 4 words
:B0X*?:knowldeg::f("knowledg") ; Fixes 32 words
:B0X*?:knowldg::f("knowledg") ; Fixes 32 words
:B0X*?:knowleg::f("knowledg") ; Fixes 32 words
:B0X*?:knwo::f("know") ; Fixes 66 words
:B0X*?:kwno::f("know") ; Fixes 66 words
:B0X*?:labat::f("laborat") ; Fixes 39 words
:B0X*?:laeg::f("leag") ; Fixes 21 words
:B0X*?:laguage::f("language") ; Fixes 12 words
:B0X*?:laimation::f("lamation") ; Fixes 10 words
:B0X*?:laion::f("lation") ; Fixes 448 words
:B0X*?:lalbe::f("lable") ; Fixes 122 words
:B0X*?:laraty::f("larity") ; Fixes 41 words
:B0X*?:lastes::f("lates") ; Fixes 212 words
:B0X*?:lateab::f("latab") ; Fixes 29 words
:B0X*?:latrea::f("latera") ; Fixes 70 words
:B0X*?:lattitude::f("latitude") ; Fixes 5 words
:B0X*?:launhe::f("launche") ; Fixes 6 words
:B0X*?:lcud::f("clud") ; Fixes 33 words
:B0X*?:leagur::f("leaguer") ; Fixes 8 words
:B0X*?:leathal::f("lethal") ; Fixes 7 words
:B0X*?:lece::f("lesce") ; Fixes 52 words, but misspells Illecebrum (contains the single species Illecebrum verticillatum, which is a trailing annual plant native to Europe)
:B0X*?:lecton::f("lection") ; Fixes 52 words
:B0X*?:leee::f("lee") ; Fixes 309 words 
:B0X*?:legitamat::f("legitimat") ; Fixes 35 words
:B0X*?:legitm::f("legitim") ; Fixes 67 words
:B0X*?:legue::f("league") ; Fixes 13 words
:B0X*?:leiv::f("liev") ; Fixes 52 words
:B0X*?:libgui::f("lingui") ; Fixes 34 words
:B0X*?:liek::f("like") ; Fixes 405 words
:B0X*?:liement::f("lement") ; Fixes 128 words
:B0X*?:lieuenan::f("lieutenan") ; Fixes 6 words
:B0X*?:lieutenen::f("lieutenan") ; Fixes 6 words
:B0X*?:ligrar::f("librar") ; Fixes 13 words 
:B0X*?:likl::f("likel") ; Fixes 14 words
:B0X*?:lility::f("ility") ; Fixes 956 words
:B0X*?:liscen::f("licen") ; Fixes 34 words
:B0X*?:lisehr::f("lisher") ; Fixes 14 words
:B0X*?:lisen::f("licen") ; Fixes 34 words, but misspells lisente (100 lisente equal 1 loti in Lesotho, S. Afterica)
:B0X*?:lisheed::f("lished") ; Fixes 27 words
:B0X*?:lishh::f("lish") ; Fixes 211 words
:B0X*?:lissh::f("lish") ; Fixes 211 words
:B0X*?:listn::f("listen") ; Fixes 19 words
:B0X*?:litav::f("lativ") ; Fixes 97 words
:B0X*?:litert::f("literat") ; Fixes 49 words
:B0X*?:littel::f("little") ; Fixes 15 words
:B0X*?:litteral::f("literal") ; Fixes 27 words
:B0X*?:littoe::f("little") ; Fixes 15 words
:B0X*?:liuke::f("like") ; Fixes 405 words
:B0X*?:llarious::f("larious") ; Fixes 6 words
:B0X*?:llegen::f("llegian") ; Fixes 7 words
:B0X*?:llegien::f("llegian") ; Fixes 7 words
:B0X*?:lloct::f("llect") ; Fixes 133 words 
:B0X*?:lmits::f("limits") ; Fixes 3 words
:B0X*?:loev::f("love") ; Fixes 111 words
:B0X*?:lonle::f("lonel") ; Fixes 9 words
:B0X*?:lpp::f("lp") ; Fixes 509 words
:B0X*?:lsih::f("lish") ; Fixes 211 words
:B0X*?:lsot::f("lso") ; Fixes 42 words
:B0X*?:lusis::f("lysis") ; Fixes 63 words 
:B0X*?:lutly::f("lutely") ; Fixes 7 words
:B0X*?:lyed::f("lied") ; Fixes 50 words
:B0X*?:machne::f("machine") ; Fixes 8 words
:B0X*?:maintina::f("maintain") ; Fixes 14 words
:B0X*?:maintion::f("mention") ; Fixes 15 words
:B0X*?:majorot::f("majorit") ; Fixes 7 words
:B0X*?:makeing::f("making") ; Fixes 45 words
:B0X*?:making it's::f("making its") 
:B0X*?:makse::f("makes") ; Fixes 7 words
:B0X*?:mallise::f("malize") ; Fixes 17 words ; Ambiguous
:B0X*?:mallize::f("malize") ; Fixes 17 words
:B0X*?:mamal::f("mammal") ; Fixes 13 words
:B0X*?:mamant::f("mament") ; Fixes 11 words
:B0X*?:managab::f("manageab") ; Fixes 9 words
:B0X*?:managment::f("management") ; Fixes 6 words
:B0X*?:mandito::f("mandato") ; Fixes 7 words
:B0X*?:maneouv::f("manoeuv") ; Fixes 17 words
:B0X*?:manoeuver::f("maneuver") ; Fixes 13 words
:B0X*?:manouver::f("maneuver") ; Fixes 13 words
:B0X*?:mantain::f("maintain") ; Fixes 14 words
:B0X*?:manuever::f("maneuver") ; Fixes 13 words
:B0X*?:manuver::f("maneuver") ; Fixes 13 words
:B0X*?:marjorit::f("majorit") ; Fixes 7 words
:B0X*?:markes::f("marks") ; Fixes 32 words
:B0X*?:markett::f("market") ; Fixes 49 words
:B0X*?:marrage::f("marriage") ; Fixes 13 words
:B0X*?:mathamati::f("mathemati") ; Fixes 17 words
:B0X*?:mathmati::f("mathemati") ; Fixes 17 words
:B0X*?:mberan::f("mbran") ; Fixes 26 words
:B0X*?:mbintat::f("mbinat") ; Fixes 18 words
:B0X*?:mchan::f("mechan") ; Fixes 54 words
:B0X*?:meber::f("member") ; Fixes 32 words
:B0X*?:medac::f("medic") ; Fixes 76 words
:B0X*?:medeival::f("medieval") ; Fixes 6 words
:B0X*?:medevial::f("medieval") ; Fixes 6 words
:B0X*?:meent::f("ment") ; Fixes 1763 words
:B0X*?:meing::f("ming") ; Fixes 410 words
:B0X*?:melad::f("malad") ; Fixes 21 words
:B0X*?:memmor::f("memor") ; Fixes 70 words
:B0X*?:memt::f("ment") ; Fixes 1763 words
:B0X*?:menat::f("menta") ; Fixes 434 words , but misspells catechumenate (A new convert being taught the principles of Christianity by a catechist). 
:B0X*?:metalic::f("metallic") ; Fixes 9 words
:B0X*?:metn::f("ment") ; Fixes 1763 words
:B0X*?:mialr::f("milar") ; Fixes 14 words
:B0X*?:mibil::f("mobil") ; Fixes 78 words
:B0X*?:mileau::f("milieu") ; Fixes 3 words
:B0X*?:milen::f("millen") ; Fixes 33 words
:B0X*?:mileu::f("milieu") ; Fixes 3 words
:B0X*?:milirat::f("militar") ; Fixes 54 words
:B0X*?:millit::f("milit") ; Fixes 85 words
:B0X*?:millon::f("million") ; Fixes 13 words
:B0X*?:milta::f("milita") ; Fixes 70 words
:B0X*?:minatur::f("miniatur") ; Fixes 27 words
:B0X*?:minining::f("mining") ; Fixes 15 words.
:B0X*?:miscelane::f("miscellane") ; Fixes 4 words
:B0X*?:mision::f("mission") ; Fixes 63 words
:B0X*?:missabi::f("missibi") ; Fixes 13 words
:B0X*?:misson::f("mission") ; Fixes 63 words
:B0X*?:mition::f("mission") ; Fixes 63 words
:B0X*?:mittm::f("mitm") ; Fixes 8 words
:B0X*?:mitty::f("mittee") ; Fixes 12 words
:B0X*?:mkae::f("make") ; Fixes 122 words
:B0X*?:mkaing::f("making") ; Fixes 45 words
:B0X*?:mkea::f("make") ; Fixes 122 words
:B0X*?:mnet::f("ment") ; Fixes 1763 words
:B0X*?:modle::f("model") ; Fixes 29 words
:B0X*?:moent::f("moment") ; Fixes 15 words
:B0X*?:moleclue::f("molecule") ; Fixes 7 words
:B0X*?:morgag::f("mortgag") ; Fixes 18 words
:B0X*?:mornal::f("normal") ; Fixes 66 words 
:B0X*?:morot::f("motor") ; Fixes 72 words  
:B0X*?:morow::f("morrow") ; Fixes 4 words
:B0X*?:mortag::f("mortgag") ; Fixes 18 words
:B0X*?:mostur::f("moistur") ; Fixes 16 words
:B0X*?:moung::f("mong") ; Fixes 89 words
:B0X*?:mounth::f("month") ; Fixes 13 words
:B0X*?:mpossa::f("mpossi") ; Fixes 7 words
:B0X*?:mrak::f("mark") ; Fixes 175 words
:B0X*?:mroe::f("more") ; Fixes 72 words
:B0X*?:mron::f("morn") ; Fixes 12 words 
:B0X*?:msot::f("most") ; Fixes 73 words
:B0X*?:mtion::f("mation") ; Fixes 119 words
:B0X*?:mucuous::f("mucous") ; Fixes 3 words
:B0X*?:muder::f("murder") ; Fixes 13 words
:B0X*?:mulatat::f("mulat") ; Fixes 110 words
:B0X*?:munber::f("number") ; Fixes 28 words
:B0X*?:munites::f("munities") ; Fixes 3 words
:B0X*?:muscel::f("muscle") ; Fixes 11 words
:B0X*?:muscial::f("musical") ; Fixes 15 words
:B0X*?:mutiliat::f("mutilat") ; Fixes 9 words
:B0X*?:myu::f("my") ; Fixes 950 words
:B0X*?:naisance::f("naissance") ; Fixes 5 words
:B0X*?:natly::f("nately") ; Fixes 42 words
:B0X*?:naton::f("nation") ; Fixes 451 words but misspells Akhenaton (Early ruler of Egypt who regected old gods and replaced with sun worship, died 1358 BC).
:B0X*?:naturely::f("naturally") ; Fixes 6 words
:B0X*?:naturual::f("natural") ; Fixes 54 words
:B0X*?:nclr::f("ncr") ; Fixes 193 words
:B0X*?:ndunt::f("ndant") ; Fixes 34 words
:B0X*?:necass::f("necess") ; Fixes 24 words
:B0X*?:neccesar::f("necessar") ; Fixes 9 words
:B0X*?:neccessar::f("necessar") ; Fixes 9 words
:B0X*?:necesar::f("necessar") ; Fixes 9 words
:B0X*?:nefica::f("neficia") ; Fixes 12 words
:B0X*?:negociat::f("negotiat") ; Fixes 19 words
:B0X*?:negota::f("negotia") ; Fixes 26 words
:B0X*?:neice::f("niece") ; Fixes 4 words
:B0X*?:neigbor::f("neighbor") ; Fixes 11 words
:B0X*?:neigbour::f("neighbor") ; Fixes 11 words
:B0X*?:neize::f("nize") ; Fixes 475 words
:B0X*?:neolitic::f("neolithic") ; Fixes 5 words
:B0X*?:nerial::f("neral") ; Fixes 103 words
:B0X*?:neribl::f("nerabl") ; Fixes 11 words
:B0X*?:nervious::f("nervous") ; Fixes 3 words
:B0X*?:nessasar::f("necessar") ; Fixes 9 words
:B0X*?:nessec::f("necess") ; Fixes 24 words
:B0X*?:nght::f("ngth") ; Jack's fixes 33 words
:B0X*?:ngng::f("nging") ; Fixes 126 words
:B0X*?:nht::f("nth") ; Jack's fixes 769 words
:B0X*?:niant::f("nant") ; Fixes 147 words
:B0X*?:niare::f("naire") ; Fixes 30 words
:B0X*?:nickle::f("nickel") ; Fixes 14 words
:B0X*?:nifiga::f("nifica") ; Fixes 55 words
:B0X*?:nihgt::f("night") ; Fixes 103 words
:B0X*?:nilog::f("nolog") ; Fixes 223 words
:B0X*?:nisator::f("niser") ; Fixes 43 words
:B0X*?:nisb::f("nsib") ; Fixes 88 words
:B0X*?:nistion::f("nisation") ; Fixes 140 words
:B0X*?:nitian::f("nician") ; Fixes 8 words
:B0X*?:niton::f("nition") ; Fixes 37 words
:B0X*?:nizator::f("nizer") ; Fixes 44 words
:B0X*?:nizm::f("nism") ; Fixes 510 words 
:B0X*?:niztion::f("nization") ; Fixes 154 words
:B0X*?:nkow::f("know") ; Fixes 66 words, but misspells Minkowski (German mathematician)
:B0X*?:nlcu::f("nclu") ; Fixes 34 words
:B0X*?:nlees::f("nless") ; Fixes 89 words
:B0X*?:nmae::f("name") ; Fixes 100 words
:B0X*?:nnst::f("nst") ; Fixes 729 words, misspells Dennstaedtia (fern), Hoffmannsthal, (poet)
:B0X*?:nnung::f("nning") ; Fixes 107 words
:B0X*?:nominclat::f("nomenclat") ; Fixes 8 words 
:B0X*?:nonom::f("nonym") ; Fixes 40 words
:B0X*?:notwwo::f("notewo") ; Fixes 6 words 
:B0X*?:nouce::f("nounce") ; Fixes 47 words
:B0X*?:nounch::f("nounc") ; Fixes 54 words
:B0X*?:nouncia::f("nuncia") ; Fixes 47 words
:B0X*?:nsern::f("ncern") ; Fixes 17 words
:B0X*?:nsistan::f("nsisten") ; Fixes 17 words
:B0X*?:nsitu::f("nstitu") ; Fixes 87 words
:B0X*?:nsnet::f("nsent") ; Fixes 19 words
:B0X*?:nstade::f("nstead") ; Fixes 6 words
:B0X*?:nstatan::f("nstan") ; Fixes 44 words
:B0X*?:nsted::f("nstead") ; Fixes 6 words
:B0X*?:nstiv::f("nsitiv") ; Fixes 62 words
:B0X*?:ntaines::f("ntains") ; Fixes 9 words
:B0X*?:ntamp::f("ntemp") ; Fixes 52 words
:B0X*?:ntfic::f("ntific") ; Fixes 28 words
:B0X*?:ntifc::f("ntific") ; Fixes 28 words
:B0X*?:ntrui::f("nturi") ; Fixes 21 words
:B0X*?:nucular::f("nuclear") ; Fixes 17 words
:B0X*?:nuculear::f("nuclear") ; Fixes 17 words
:B0X*?:nuei::f("nui") ; Fixes 37 words
:B0X*?:nuptual::f("nuptial") ; Fixes 7 words
:B0X*?:nvien::f("nven") ; Fixes 101 words
:B0X*?:obedian::f("obedien") ; Fixes 11 words
:B0X*?:obelm::f("oblem") ; Fixes 28 words
:B0X*?:obram::f("ogram") ; Fixes 298 words , but misspells "tobramycin" (An antibiotic--trade name Nebcin).
:B0X*?:occassi::f("occasi") ; Fixes 14 words
:B0X*?:occasti::f("occasi") ; Fixes 14 words
:B0X*?:occour::f("occur") ; Fixes 20 words
:B0X*?:occuran::f("occurren") ; Fixes 8 words
:B0X*?:occurran::f("occurren") ; Fixes 8 words
:B0X*?:ocup::f("occup") ; Fixes 39 words
:B0X*?:ocurran::f("occurren") ; Fixes 8 words
:B0X*?:odouriferous::f("odoriferous") ; Fixes 3 words
:B0X*?:odourous::f("odorous") ; Fixes 9 words
:B0X*?:oducab::f("oducib") ; Fixes 13 words
:B0X*?:oeny::f("oney") ; Fixes 83 words
:B0X*?:oeopl::f("eopl") ; Fixes 53 words
:B0X*?:oeprat::f("operat") ; Fixes 58 words
:B0X*?:offesi::f("ofessi") ; Fixes 34 words
:B0X*?:offical::f("official") ; Fixes 24 words
:B0X*?:offred::f("offered") ; Fixes 4 words
:B0X*?:ogeous::f("ogous") ; Fixes 13 words
:B0X*?:ogess::f("ogress") ; Fixes 38 words
:B0X*?:ohter::f("other") ; Fixes 229 words
:B0X*?:ointiment::f("ointment") ; Fixes 10 words
:B0X*?:olgist::f("ologist") ; Fixes 445 words
:B0X*?:olision::f("olition") ; Fixes 16 words
:B0X*?:ollum::f("olum") ; Fixes 69 words
:B0X*?:oloda::f("olida") ; Fixes 46 words 
:B0X*?:olpe::f("ople") ; Fixes 62 words
:B0X*?:olther::f("other") ; Fixes 229 words
:B0X*?:omenom::f("omenon") ; Fixes 7 words
:B0X*?:ommm::f("omm") ; Fixes 606 words
:B0X*?:omnio::f("omino") ; Fixes 18 words
:B0X*?:omptabl::f("ompatibl") ; Fixes 7 words
:B0X*?:omre::f("more") ; Fixes 72 words
:B0X*?:omse::f("onse") ; Fixes 159 words
:B0X*?:ongraph::f("onograph") ; Fixes 31 words
:B0X*?:onnal::f("onal") ; Fixes 1038 words
:B0X*?:ononent::f("onent") ; Fixes 18 words
:B0X*?:ononym::f("onym") ; Fixes 137 words
:B0X*?:onsenc::f("onsens") ; Fixes 19 words
:B0X*?:ontruc::f("onstruc") ; Fixes 63 words
:B0X*?:ontstr::f("onstr") ; Fixes 165 words
:B0X*?:onvertab::f("onvertib") ; Fixes 18 words
:B0X*?:onyic::f("onic") ; Fixes 353 words
:B0X*?:onymn::f("onym") ; Fixes 137 words
:B0X*?:ooksd::f("ooked") ; Fixes 33 words 
:B0X*?:oook::f("ook") ; Fixes 427 words
:B0X*?:oparate::f("operate") ; Fixes 10 words
:B0X*?:oportun::f("opportun") ; Fixes 14 words
:B0X*?:opperat::f("operat") ; Fixes 58 words
:B0X*?:oppertun::f("opportun") ; Fixes 14 words
:B0X*?:oppini::f("opini") ; Fixes 12 words
:B0X*?:opprotun::f("opportun") ; Fixes 14 words
:B0X*?:opth::f("ophth") ; Fixes 47 words
:B0X*?:ordianti::f("ordinati") ; Fixes 21 words
:B0X*?:orginis::f("organiz") ; Fixes 34 words
:B0X*?:orginiz::f("organiz") ; Fixes 34 words
:B0X*?:orht::f("orth") ; Fixes 275 words
:B0X*?:oridal::f("ordial") ; Fixes 15 words
:B0X*?:oridina::f("ordina") ; Fixes 63 words
:B0X*?:origion::f("origin") ; Fixes 37 words
:B0X*?:ormenc::f("ormanc") ; Fixes 11 words
:B0X*?:oroow::f("orrow") ; Fixes 26 words 
:B0X*?:osible::f("osable") ; Fixes 23 words
:B0X*?:oteab::f("otab") ; Fixes 22 words
:B0X*?:ouevre::f("oeuvre") ; Fixes 10 words
:B0X*?:ougnble::f("ouble") ; Fixes 48 words
:B0X*?:ouhg::f("ough") ; Fixes 230 words
:B0X*?:oulb::f("oubl") ; Fixes 63 words
:B0X*?:ouldnt::f("ouldn't") ; Fixes 3 words
:B0X*?:ountian::f("ountain") ; Fixes 25 words
:B0X*?:ourious::f("orious") ; Fixes 30 words
:B0X*?:owinf::f("owing") ; Fixes 133 words
:B0X*?:owrk::f("work") ; Fixes 338 words
:B0X*?:oxident::f("oxidant") ; Fixes 4 words
:B0X*?:oxigen::f("oxygen") ; Fixes 40 words
:B0X*?:paiti::f("pati") ; Fixes 157 words
:B0X*?:palce::f("place") ; Fixes 94 words
:B0X*?:paliament::f("parliament") ; Fixes 11 words
:B0X*?:papaer::f("paper") ; Fixes 69 words
:B0X*?:paralel::f("parallel") ; Fixes 41 words
:B0X*?:pareed::f("pared") ; Fixes 14 words 
:B0X*?:parellel::f("parallel") ; Fixes 41 words
:B0X*?:parision::f("parison") ; Fixes 6 words
:B0X*?:parisit::f("parasit") ; Fixes 57 words
:B0X*?:paritucla::f("particula") ; Fixes 29 words
:B0X*?:parliment::f("parliament") ; Fixes 11 words
:B0X*?:parment::f("partment") ; Fixes 41 words
:B0X*?:parralel::f("parallel") ; Fixes 41 words
:B0X*?:parrall::f("parall") ; Fixes 44 words
:B0X*?:parren::f("paren") ; Fixes 65 words
:B0X*?:pased::f("passed") ; Fixes 10 words
:B0X*?:patab::f("patib") ; Fixes 16 words
:B0X*?:pattent::f("patent") ; Fixes 16 words
:B0X*?:pbli::f("publi") ; Fixes 67 words
:B0X*?:pbuli::f("publi") ; Fixes 67 words
:B0X*?:pcial::f("pical") ; Fixes 102 words
:B0X*?:pcitur::f("pictur") ; Fixes 25 words
:B0X*?:peall::f("peal") ; Fixes 31 words
:B0X*?:peapl::f("peopl") ; Fixes 38 words
:B0X*?:pefor::f("perfor") ; Fixes 43 words
:B0X*?:peice::f("piece") ; Fixes 60 words
:B0X*?:peiti::f("petiti") ; Fixes 34 words
:B0X*?:pendece::f("pendence") ; Fixes 12 words
:B0X*?:pendendet::f("pendent") ; Fixes 17 words
:B0X*?:penerat::f("penetrat") ; Fixes 19 words
:B0X*?:penisula::f("peninsula") ; Fixes 3 words
:B0X*?:penninsula::f("peninsula") ; Fixes 3 words
:B0X*?:pennisula::f("peninsula") ; Fixes 3 words
:B0X*?:pensanti::f("pensati") ; Fixes 13 words
:B0X*?:pensinula::f("peninsula") ; Fixes 3 words
:B0X*?:penten::f("pentan") ; Fixes 12 words
:B0X*?:pention::f("pension") ; Fixes 15 words
:B0X*?:peopel::f("people") ; Fixes 32 words
:B0X*?:percepted::f("perceived") ; Fixes 7 words
:B0X*?:perfom::f("perform") ; Fixes 31 words
:B0X*?:performes::f("performs") ; Fixes 3 words
:B0X*?:permenan::f("permanen") ; Fixes 17 words
:B0X*?:perminen::f("permanen") ; Fixes 17 words
:B0X*?:permissab::f("permissib") ; Fixes 9 words
:B0X*?:peronal::f("personal") ; Fixes 49 words
:B0X*?:perosn::f("person") ; Fixes 130 words
:B0X*?:persistan::f("persisten") ; Fixes 6 words
:B0X*?:persud::f("persuad") ; Fixes 20 words
:B0X*?:pertrat::f("petrat") ; Fixes 14 words
:B0X*?:pertuba::f("perturba") ; Fixes 12 words
:B0X*?:peteti::f("petiti") ; Fixes 34 words
:B0X*?:petion::f("petition") ; Fixes 11 words
:B0X*?:petive::f("petitive") ; Fixes 19 words
:B0X*?:phenomenonal::f("phenomenal") ; Fixes 11 words
:B0X*?:phenomon::f("phenomen") ; Fixes 21 words
:B0X*?:phenonmen::f("phenomen") ; Fixes 21 words
:B0X*?:philisoph::f("philosoph") ; Fixes 28 words
:B0X*?:phillipi::f("Philippi") ; Fixes 7 words
:B0X*?:phillo::f("philo") ; Fixes 61 words
:B0X*?:philosph::f("philosoph") ; Fixes 28 words
:B0X*?:phoricial::f("phorical") ; Fixes 6 words
:B0X*?:phyllis::f("philis") ; Fixes 33 words
:B0X*?:phylosoph::f("philosoph") ; Fixes 28 words
:B0X*?:piant::f("pient") ; Fixes 16 words
:B0X*?:piblish::f("publish") ; Fixes 17 words
:B0X*?:pinon::f("pion") ; Fixes 44 words
:B0X*?:piten::f("peten") ; Fixes 29 words
:B0X*?:plament::f("plement") ; Fixes 42 words
:B0X*?:plausab::f("plausib") ; Fixes 10 words
:B0X*?:pld::f("ple") ; Fixes 843 words
:B0X*?:plesan::f("pleasan") ; Fixes 14 words
:B0X*?:pleseant::f("pleasant") ; Fixes 11 words
:B0X*?:pletetion::f("pletion") ; Fixes 8 words
:B0X*?:pmant::f("pment") ; Fixes 38 words
:B0X*?:poenis::f("penis") ; Fixes 4 words
:B0X*?:poepl::f("peopl") ; Fixes 38 words
:B0X*?:poleg::f("polog") ; Fixes 59 words
:B0X*?:polina::f("pollina") ; Fixes 11 words
:B0X*?:politican::f("politician") ; Fixes 4 words
:B0X*?:polti::f("politi") ; Fixes 61 words
:B0X*?:polut::f("pollut") ; Fixes 20 words
:B0X*?:pomd::f("pond") ; Fixes 109 words
:B0X*?:ponan::f("ponen") ; Fixes 17 words
:B0X*?:ponsab::f("ponsib") ; Fixes 10 words
:B0X*?:poportion::f("proportion") ; Fixes 25 words
:B0X*?:popoul::f("popul") ; Fixes 71 words
:B0X*?:porblem::f("problem") ; Fixes 22 words
:B0X*?:portad::f("ported") ; Fixes 26 words
:B0X*?:porv::f("prov") ; Fixes 213 words
:B0X*?:posat::f("posit") ; Fixes 215 words
:B0X*?:posess::f("possess") ; Fixes 41 words
:B0X*?:posion::f("poison") ; Fixes 17 words
:B0X*?:possab::f("possib") ; Fixes 13 words
:B0X*?:postion::f("position") ; Fixes 103 words
:B0X*?:postit::f("posit") ; Fixes 215 words
:B0X*?:postiv::f("positiv") ; Fixes 36 words
:B0X*?:potunit::f("portunit") ; Fixes 4 words
:B0X*?:poulat::f("populat") ; Fixes 29 words
:B0X*?:poverful::f("powerful") ; Fixes 5 words
:B0X*?:poweful::f("powerful") ; Fixes 5 words
:B0X*?:ppment::f("pment") ; Fixes 38 words
:B0X*?:ppore::f("ppose") ; Fixes 29 words 
:B0X*?:pposs::f("ppos") ; Fixes 90 words
:B0X*?:ppub::f("pub") ; Fixes 96 words
:B0X*?:prait::f("priat") ; Fixes 39 words
:B0X*?:pratic::f("practic") ; Fixes 42 words
:B0X*?:precendent::f("precedent") ; Fixes 11 words
:B0X*?:precic::f("precis") ; Fixes 20 words
:B0X*?:precid::f("preced") ; Fixes 18 words
:B0X*?:prega::f("pregna") ; Fixes 25 words
:B0X*?:pregne::f("pregna") ; Fixes 25 words
:B0X*?:preiod::f("period") ; Fixes 30 words
:B0X*?:prelifer::f("prolifer") ; Fixes 13 words
:B0X*?:prepair::f("prepare") ; Fixes 10 words
:B0X*?:prerio::f("perio") ; Fixes 46 words
:B0X*?:presan::f("presen") ; Fixes 90 words
:B0X*?:presp::f("persp") ; Fixes 33 words
:B0X*?:pretect::f("protect") ; Fixes 43 words
:B0X*?:pricip::f("princip") ; Fixes 20 words
:B0X*?:priestood::f("priesthood") ; Fixes 3 words
:B0X*?:prisonn::f("prison") ; Fixes 21 words
:B0X*?:privale::f("privile") ; Fixes 7 words
:B0X*?:privele::f("privile") ; Fixes 7 words
:B0X*?:privelig::f("privileg") ; Fixes 7 words
:B0X*?:privelle::f("privile") ; Fixes 7 words
:B0X*?:privilag::f("privileg") ; Fixes 7 words
:B0X*?:priviledg::f("privileg") ; Fixes 7 words
:B0X*?:probabli::f("probabili") ; Fixes 12 words
:B0X*?:probal::f("probabl") ; Fixes 9 words
:B0X*?:procce::f("proce") ; Fixes 49 words
:B0X*?:proclame::f("proclaime") ; Fixes 4 words
:B0X*?:proffession::f("profession") ; Fixes 33 words
:B0X*?:progrom::f("program") ; Fixes 46 words
:B0X*?:prohabit::f("prohibit") ; Fixes 17 words
:B0X*?:promar::f("primar") ; Fixes 9 words 
:B0X*?:prominan::f("prominen") ; Fixes 8 words
:B0X*?:prominate::f("prominent")  ; Fixes 4 words
:B0X*?:promona::f("promine") ; Fixes 12 words 
:B0X*?:proov::f("prov") ; Fixes 213 words
:B0X*?:propiet::f("propriet") ; Fixes 17 words
:B0X*?:propmt::f("prompt") ; Fixes 19 words
:B0X*?:propotion::f("proportion")  ; Fixes 25 words
:B0X*?:propper::f("proper") ; Fixes 15 words
:B0X*?:propro::f("pro") ; Fixes 2311 words
:B0X*?:prorp::f("propr") ; Fixes 68 words
:B0X*?:protie::f("protei") ; Fixes 44 words
:B0X*?:protray::f("portray") ; Fixes 14 words
:B0X*?:prounc::f("pronounc") ; Fixes 24 words
:B0X*?:provd::f("provid") ; Fixes 21 words
:B0X*?:provicial::f("provincial") ; Fixes 10 words
:B0X*?:provinicial::f("provincial") ; Fixes 10 words
:B0X*?:proxia::f("proxima") ; Fixes 22 words
:B0X*?:psect::f("spect") ; Fixes 177 words
:B0X*?:psoiti::f("positi") ; Fixes 155 words
:B0X*?:psuedo::f("pseudo") ; Fixes 70 words
:B0X*?:psyco::f("psycho") ; Fixes 161 words
:B0X*?:psyh::f("psych") ; Fixes 192 words, but misspells gypsyhood.
:B0X*?:ptenc::f("ptanc") ; Fixes 9 words
:B0X*?:ptete::f("pete") ; Fixes 61 words
:B0X*?:ptition::f("petition") ; Fixes 11 words
:B0X*?:ptogress::f("progress") ; Fixes 24 words
:B0X*?:ptoin::f("ption") ; Fixes 183 words
:B0X*?:pturd::f("ptured") ; Fixes 6 words
:B0X*?:pubish::f("publish") ; Fixes 17 words
:B0X*?:publian::f("publican") ; Fixes 9 words
:B0X*?:publise::f("publishe") ; Fixes 7 words
:B0X*?:publush::f("publish") ; Fixes 17 words
:B0X*?:pulare::f("pular") ; Fixes 40 words
:B0X*?:puler::f("pular") ; Fixes 40 words
:B0X*?:pulishe::f("publishe") ; Fixes 7 words
:B0X*?:puplish::f("publish") ; Fixes 17 words
:B0X*?:pursuad::f("persuad") ; Fixes 20 words
:B0X*?:purtun::f("portun") ; Fixes 25 words
:B0X*?:pususad::f("persuad") ; Fixes 20 words
:B0X*?:putar::f("puter") ; Fixes 24 words
:B0X*?:putib::f("putab") ; Fixes 34 words
:B0X*?:pwoer::f("power") ; Fixes 67 words
:B0X*?:pysch::f("psych") ; Fixes 192 words
:B0X*?:qtuie::f("quite") ; Fixes 11 words
:B0X*?:quesece::f("quence") ; Fixes 21 words
:B0X*?:quesion::f("question") ; Fixes 26 words
:B0X*?:questiom::f("question") ; Fixes 26 words
:B0X*?:queston::f("question") ; Fixes 26 words
:B0X*?:quetion::f("question") ; Fixes 26 words
:B0X*?:quirment::f("quirement") ; Fixes 4 words
:B0X*?:qush::f("quish") ; Fixes 27 words
:B0X*?:quti::f("quit") ; Fixes 86 words
:B0X*?:rabinn::f("rabbin") ; Fixes 9 words
:B0X*?:radiactiv::f("radioactiv") ; Fixes 5 words
:B0X*?:raell::f("reall") ; Fixes 24 words
:B0X*?:rafic::f("rific") ; Fixes 85 words
:B0X*?:rafy::f("raft") ; Fixes 195 words 
:B0X*?:ranie::f("rannie") ; Fixes 8 words
:B0X*?:ratly::f("rately") ; Fixes 30 words
:B0X*?:raverci::f("roversi") ; Fixes 19 words
:B0X*?:rcaft::f("rcraft") ; Fixes 11 words
:B0X*?:reaccurr::f("recurr") ; Fixes 8 words
:B0X*?:reaci::f("reachi") ; Fixes 18 words
:B0X*?:rebll::f("rebell") ; Fixes 17 words
:B0X*?:recide::f("reside") ; Fixes 34 words
:B0X*?:recomment::f("recommend") ; Fixes 13 words 
:B0X*?:recqu::f("requ") ; Fixes 96 words
:B0X*?:recration::f("recreation") ; Fixes 5 words
:B0X*?:recrod::f("record") ; Fixes 26 words
:B0X*?:recter::f("rector") ; Fixes 26 words
:B0X*?:recuring::f("recurring") ; Fixes 3 words
:B0X*?:reedem::f("redeem") ; Fixes 22 words
:B0X*?:reee::f("ree") ; Fixes 1327 words 
:B0X*?:reenfo::f("reinfo") ; Fixes 9 words
:B0X*?:referal::f("referral") ; Fixes 2 words
:B0X*?:reffer::f("refer") ; Fixes 58 words
:B0X*?:refrer::f("refer") ; Fixes 58 words
:B0X*?:reigin::f("reign") ; Fixes 25 words
:B0X*?:reing::f("ring") ; Fixes 1481 words
:B0X*?:reiv::f("riev") ; Fixes 44 words
:B0X*?:relese::f("release") ; Fixes 13 words
:B0X*?:releven::f("relevan") ; Fixes 12 words
:B0X*?:remmi::f("remi") ; Fixes 222 words , but misspells gremmie (Alt of gremmy [“a young or inexperienced surfer or skateboarder”]). 
:B0X*?:renial::f("rennial") ; Fixes 6 words
:B0X*?:renno::f("reno") ; Fixes 85 words
:B0X*?:rentee::f("rantee") ; Fixes 9 words
:B0X*?:rentor::f("renter") ; Fixes 4 words
:B0X*?:renuw::f("renew") ; Fixes 20 words 
:B0X*?:reomm::f("recomm") ; Fixes 31 words
:B0X*?:repatiti::f("repetiti") ; Fixes 10 words
:B0X*?:repb::f("repub") ; Fixes 23 words
:B0X*?:repetant::f("repentant") ; Fixes 5 words
:B0X*?:repetent::f("repentant") ; Fixes 5 words
:B0X*?:replacab::f("replaceab") ; Fixes 8 words
:B0X*?:reposd::f("respond") ; Fixes 22 words
:B0X*?:resense::f("resence") ; Fixes 6 words
:B0X*?:resistab::f("resistib") ; Fixes 10 words
:B0X*?:resiv::f("ressiv") ; Fixes 80 words
:B0X*?:responc::f("respons") ; Fixes 25 words
:B0X*?:respondan::f("responden") ; Fixes 11 words
:B0X*?:restict::f("restrict") ; Fixes 25 words
:B0X*?:revelan::f("relevan") ; Fixes 12 words 
:B0X*?:reversab::f("reversib") ; Fixes 15 words
:B0X*?:rhitm::f("rithm") ; Fixes 20 words
:B0X*?:rhythem::f("rhythm") ; Fixes 34 words
:B0X*?:rhytm::f("rhythm") ; Fixes 34 words
:B0X*?:ributred::f("ributed") ; Fixes 10 words
:B0X*?:ridgid::f("rigid") ; Fixes 25 words 
:B0X*?:rieciat::f("reciat") ; Fixes 32 words
:B0X*?:rifing::f("rifying") ; Fixes 31 words
:B0X*?:rigeur::f("rigor") ; Fixes 13 words
:B0X*?:rigourous::f("rigorous") ; Fixes 6 words
:B0X*?:rilia::f("rillia") ; Fixes 11 words
:B0X*?:rimetal::f("rimental") ; Fixes 9 words
:B0X*?:rininging::f("ringing") ; Fixes 21 words
:B0X*?:riodal::f("roidal") ; Fixes 14 words
:B0X*?:ritent::f("rient") ; Fixes 74 words
:B0X*?:ritm::f("rithm") ; Fixes 20 words
:B0X*?:rixon::f("rison") ; Fixes 39 words
:B0X*?:rmaly::f("rmally") ; Fixes 11 words
:B0X*?:rmaton::f("rmation") ; Fixes 46 words
:B0X*?:rocord::f("record") ; Fixes 26 words
:B0X*?:rograss::f("rogress") ; Fixes 44 words 
:B0X*?:ropiat::f("ropriat") ; Fixes 39 words
:B0X*?:rowm::f("rown") ; Fixes 85 words
:B0X*?:roximite::f("roximate") ; Fixes 8 words
:B0X*?:rraige::f("rriage") ; Fixes 26 words
:B0X*?:rshan::f("rtion") ; Fixes 84 words, but misspells darshan (Hinduism)
:B0X*?:rshon::f("rtion") ; Fixes 84 words
:B0X*?:rshun::f("rtion") ; Fixes 84 words
:B0X*?:rtaure::f("rature") ; Fixes 8 words
:B0X*?:rtiing::f("riting") ; Fixes 46 words 
:B0X*?:rtnat::f("rtant") ; Fixes 7 words
:B0X*?:ruming::f("rumming") ; Fixes 5 words
:B0X*?:ruptab::f("ruptib") ; Fixes 11 words
:B0X*?:rwit::f("writ") ; Fixes 88 words
:B0X*?:ryed::f("ried") ; Fixes 98 words
:B0X*?:rythym::f("rhythm") ; Fixes 34 words
:B0X*?:saccari::f("sacchari") ; Fixes 31 words
:B0X*?:safte::f("safet") ; Fixes 5 words
:B0X*?:saidit::f("said it") ; Fixes 1 word
:B0X*?:saidth::f("said th") ; Fixes 1 word
:B0X*?:sampel::f("sample") ; Fixes 20 words 
:B0X*?:santion::f("sanction") ; Fixes 7 words
:B0X*?:sassan::f("sassin") ; Fixes 12 words
:B0X*?:satelite::f("satellite") ; Fixes 4 words
:B0X*?:satric::f("satiric") ; Fixes 4 words
:B0X*?:sattelite::f("satellite") ; Fixes 4 words
:B0X*?:scaleable::f("scalable") ; Fixes 4 words
:B0X*?:scedul::f("schedul") ; Fixes 12 words
:B0X*?:schedual::f("schedule") ; Fixes 9 words
:B0X*?:schg::f("sch") ; Fixes 744 words 
:B0X*?:scholarstic::f("scholastic") ; Fixes 9 words
:B0X*?:sciipt::f("script") ; Fixes 127 words 
:B0X*?:scince::f("science") ; Fixes 25 words, but misspells Scincella (A reptile genus of Scincidae)
:B0X*?:scipt::f("script") ; Fixes 113 words
:B0X*?:scje::f("sche") ; Fixes 108 words
:B0X*?:scoool::f("school") ; Fixes 100 words 
:B0X*?:scripton::f("scription") ; Fixes 32 words
:B0X*?:scrite::f("scribe") ; Fixes 79 words 
:B0X*?:sctic::f("stric") ; Fixes 120 words 
:B0X*?:sctipt::f("script") ; Fixes 127 words 
:B0X*?:sctruct::f("struct") ; Fixes 171 words
:B0X*?:sdide::f("side") ; Fixes 317 words
:B0X*?:sdier::f("sider") ; Fixes 74 words
:B0X*?:seach::f("search") ; Fixes 25 words, but misspells Taoiseach (The prime minister of the Irish Republic)
:B0X*?:secretery::f("secretary") ; Fixes 4 words
:B0X*?:sedere::f("sidere") ; Fixes 7 words
:B0X*?:seee::f("see") ; Fixes 309 words 
:B0X*?:seeked::f("sought") ; Fixes 3 words
:B0X*?:segement::f("segment") ; Fixes 14 words
:B0X*?:seige::f("siege") ; Fixes 10 words
:B0X*?:semm::f("sem") ; Fixes 715 words 
:B0X*?:senqu::f("sequ") ; Fixes 91 words
:B0X*?:sensativ::f("sensitiv") ; Fixes 32 words
:B0X*?:sentive::f("sentative") ; Fixes 15 words
:B0X*?:seper::f("separ") ; Fixes 36 words
:B0X*?:sepulchure::f("sepulcher") ; Fixes 7 words
:B0X*?:sepulcre::f("sepulcher") ; Fixes 7 words
:B0X*?:sequentually::f("sequently") ; Fixes 4 words
:B0X*?:serach::f("search") ; Fixes 25 words
:B0X*?:sercu::f("circu") ; Fixes 168 words
:B0X*?:sertain::f("certain") ; Fixes 28 words 
:B0X*?:sesi::f("sessi") ; Fixes 41 words
:B0X*?:sevic::f("servic") ; Fixes 25 words, but misspells seviche (South American dish of raw fish)
:B0X*?:sgin::f("sign") ; Fixes 243 words.
:B0X*?:shco::f("scho") ; Fixes 117 words
:B0X*?:shoose::f("choose") ; Fixes 11 words 
:B0X*?:siad::f("said") ; Fixes 9 words
:B0X*?:sicion::f("cision") ; Fixes 22 words
:B0X*?:sicne::f("since") ; Fixes 22 words
:B0X*?:sidenta::f("sidentia") ; Fixes 9 words
:B0X*?:signifa::f("significa") ; Fixes 20 words
:B0X*?:significe::f("significa") ; Fixes 20 words
:B0X*?:signit::f("signat") ; Fixes 35 words
:B0X*?:simala::f("simila") ; Fixes 38 words
:B0X*?:similia::f("simila") ; Fixes 38 words
:B0X*?:simmi::f("simi") ; Fixes 64 words
:B0X*?:simpt::f("sympt") ; Fixes 15 words
:B0X*?:sincerley::f("sincerely") ; Fixes 2 words
:B0X*?:sincerly::f("sincerely") ; Fixes 2 words
:B0X*?:sinse::f("since") ; Fixes 22 words
:B0X*?:sistend::f("sistent") ; Fixes 10 words
:B0X*?:sistion::f("sition") ; Fixes 135 words
:B0X*?:sitll::f("still") ; Fixes 62 words
:B0X*?:siton::f("sition") ; Fixes 135 words
:B0X*?:skelaton::f("skeleton") ; Fixes 19 words
:B0X*?:slowy::f("slowly") ; Fixes 2 words
:B0X*?:smae::f("same") ; Fixes 19 words
:B0X*?:smealt::f("smelt") ; Fixes 10 words
:B0X*?:smoe::f("some") ; Fixes 260 words
:B0X*?:snese::f("sense") ; Fixes 17 words
:B0X*?:socal::f("social") ; Fixes 47 words
:B0X*?:socre::f("score") ; Fixes 34 words 
:B0X*?:soem::f("some") ; Fixes 260 words
:B0X*?:sohw::f("show") ; Fixes 79 words
:B0X*?:soica::f("socia") ; Fixes 115 words
:B0X*?:sollut::f("solut") ; Fixes 42 words
:B0X*?:soluab::f("solub") ; Fixes 26 words
:B0X*?:sonent::f("sonant") ; Fixes 20 words
:B0X*?:sophicat::f("sophisticat") ; Fixes 13 words
:B0X*?:sorbsi::f("sorpti") ; Fixes 32 words
:B0X*?:sorbti::f("sorpti") ; Fixes 32 words
:B0X*?:sosica::f("socia") ; Fixes 115 words
:B0X*?:sotry::f("story") ; Fixes 23 words
:B0X*?:soudn::f("sound") ; Fixes 51 words
:B0X*?:sourse::f("source") ; Fixes 24 words
:B0X*?:specal::f("special") ; Fixes 24 words
:B0X*?:specfic::f("specific") ; Fixes 20 words
:B0X*?:specialliz::f("specializ") ; Fixes 15 words
:B0X*?:specifiy::f("specify") ; Fixes 8 words
:B0X*?:spectaular::f("spectacular") ; Fixes 5 words
:B0X*?:spectum::f("spectrum") ; Fixes 4 words
:B0X*?:speedh::f("speech") ; Fixes 20 words 
:B0X*?:speling::f("spelling") ; Fixes 9 words
:B0X*?:spesial::f("special") ; Fixes 48 words
:B0X*?:spiria::f("spira") ; Fixes 70 words
:B0X*?:spoac::f("spac") ; Fixes 83 words
:B0X*?:sponib::f("sponsib") ; Fixes 10 words
:B0X*?:sponser::f("sponsor") ; Fixes 12 words
:B0X*?:spred::f("spread") ; Fixes 37 words
:B0X*?:spririt::f("spirit") ; Fixes 70 words
:B0X*?:spritual::f("spiritual") ; Fixes 31 words, but misspells spritual (A light spar that crosses a fore-and-aft sail diagonally) 
:B0X*?:spyc::f("psyc") ; Fixes 192 words, but misspells spycatcher (secret spy stuff) 
:B0X*?:sqaur::f("squar") ; Fixes 22 words
:B0X*?:ssanger::f("ssenger") ; Fixes 6 words
:B0X*?:ssese::f("ssesse") ; Fixes 17 words
:B0X*?:ssition::f("sition") ; Fixes 135 words
:B0X*?:stablise::f("stabilise") ; Fixes 10 words
:B0X*?:staleld::f("stalled") ; Fixes 6 words
:B0X*?:stancial::f("stantial") ; Fixes 40 words
:B0X*?:stange::f("strange") ; Fixes 12 words
:B0X*?:starna::f("sterna") ; Fixes 13 words
:B0X*?:starteg::f("strateg") ; Fixes 21 words
:B0X*?:stateman::f("statesman") ; Fixes 6 words
:B0X*?:statment::f("statement") ; Fixes 14 words
:B0X*?:sterotype::f("stereotype") ; Fixes 5 words
:B0X*?:stingent::f("stringent") ; Fixes 9 words
:B0X*?:stiring::f("stirring") ; Fixes 4 words
:B0X*?:stirrs::f("stirs") ; Fixes 2 words
:B0X*?:stituan::f("stituen") ; Fixes 7 words
:B0X*?:stnad::f("stand") ; Fixes 119 words
:B0X*?:stoin::f("stion") ; Fixes 53 words, but misspells histoincompatibility.
:B0X*?:stong::f("strong") ; Fixes 22 words
:B0X*?:stradeg::f("strateg") ; Fixes 21 words
:B0X*?:stratagic::f("strategic") ; Fixes 5 words
:B0X*?:streem::f("stream") ; Fixes 45 words
:B0X*?:strengh::f("strength") ; Fixes 15 words
:B0X*?:structual::f("structural") ; Fixes 12 words
:B0X*?:sttr::f("str") ; Fixes 2295 words
:B0X*?:stuct::f("struct") ; Fixes 171 words
:B0X*?:studdy::f("study") ; Fixes 8 words
:B0X*?:studing::f("studying") ; Fixes 4 words
:B0X*?:sturctur::f("structur") ; Fixes 39 words
:B0X*?:stutionaliz::f("stitutionaliz") ; Fixes 16 words
:B0X*?:substancia::f("substantia") ; Fixes 55 words
:B0X*?:succesful::f("successful") ; Fixes 6 words
:B0X*?:succsess::f("success") ; Fixes 19 words
:B0X*?:sucess::f("success") ; Fixes 19 words
:B0X*?:sueing::f("suing") ; Fixes 9 words
:B0X*?:suffc::f("suffic") ; Fixes 14 words
:B0X*?:sufferr::f("suffer") ; Fixes 19 words
:B0X*?:suffician::f("sufficien") ; Fixes 10 words
:B0X*?:superintendan::f("superintenden") ; Fixes 6 words
:B0X*?:suph::f("soph") ; Fixes 153 words
:B0X*?:supos::f("suppos") ; Fixes 30 words
:B0X*?:suppoed::f("supposed") ; Fixes 3 words
:B0X*?:suppy::f("supply") ; Fixes 8 words
:B0X*?:suprass::f("surpass") ; Fixes 14 words
:B0X*?:supress::f("suppress") ; Fixes 31 words
:B0X*?:supris::f("surpris") ; Fixes 16 words
:B0X*?:supriz::f("surpris") ; Fixes 16 words
:B0X*?:surect::f("surrect") ; Fixes 15 words
:B0X*?:surence::f("surance") ; Fixes 12 words
:B0X*?:surfce::f("surface") ; Fixes 15 words
:B0X*?:surle::f("surel") ; Fixes 11 words
:B0X*?:suro::f("surro") ; Fixes 13 words
:B0X*?:surpress::f("suppress") ; Fixes 31 words
:B0X*?:surpriz::f("surpris") ; Fixes 16 words
:B0X*?:susept::f("suscept") ; Fixes 21 words
:B0X*?:svae::f("save") ; Fixes 15 words
:B0X*?:swepth::f("swept") ; Fixes 7 words
:B0X*?:symetr::f("symmetr") ; Fixes 36 words
:B0X*?:symettr::f("symmetr") ; Fixes 36 words
:B0X*?:symmetral::f("symmetric") ; Fixes 16 words
:B0X*?:syncro::f("synchro") ; Fixes 72 words
:B0X*?:sypmtom::f("symptom") ; Fixes 11 words
:B0X*?:sysmatic::f("systematic") ; Fixes 11 words
:B0X*?:sytem::f("system") ; Fixes 62 words
:B0X*?:sytl::f("styl") ; Fixes 100 words
:B0X*?:tagan::f("tagon") ; Fixes 40 words
:B0X*?:tahn::f("than") ; Fixes 135 words
:B0X*?:taht::f("that") ; Fixes 26 words
:B0X*?:tailled::f("tailed") ; Fixes 16 words.
:B0X*?:taimina::f("tamina") ; Fixes 26 words
:B0X*?:tainence::f("tenance") ; Fixes 12 words
:B0X*?:taion::f("tation") ; Fixes 490 words
:B0X*?:tait::f("trait") ; Fixes 32 words
:B0X*?:tamt::f("tant") ; Fixes 330 words
:B0X*?:tanous::f("taneous") ; Fixes 29 words
:B0X*?:taral::f("tural") ; Fixes 140 words
:B0X*?:tarey::f("tary") ; Fixes 86 words
:B0X*?:tartet::f("target") ; Fixes 14 words 
:B0X*?:tatch::f("tach") ; Fixes 105 words
:B0X*?:taxan::f("taxon") ; Fixes 10 words
:B0X*?:techic::f("technic") ; Fixes 39 words
:B0X*?:techini::f("techni") ; Fixes 44 words
:B0X*?:techt::f("tect") ; Fixes 102 words
:B0X*?:tecn::f("techn") ; Fixes 87 words
:B0X*?:telpho::f("telepho") ; Fixes 23 words
:B0X*?:tempalt::f("templat") ; Fixes 14 words
:B0X*?:tempara::f("tempera") ; Fixes 22 words
:B0X*?:temperar::f("temporar") ; Fixes 11 words
:B0X*?:tempoa::f("tempora") ; Fixes 35 words
:B0X*?:temporaneus::f("temporaneous") ; Fixes 6 words
:B0X*?:tendac::f("tendenc") ; Fixes 7 words
:B0X*?:tendor::f("tender") ; Fixes 54 words
:B0X*?:tepmor::f("tempor") ; Fixes 73 words
:B0X*?:teriod::f("teroid") ; Fixes 21 words
:B0X*?:terranian::f("terranean") ; Fixes 4 words
:B0X*?:terrestial::f("terrestrial") ; Fixes 9 words
:B0X*?:terrior::f("territor") ; Fixes 28 words
:B0X*?:territorist::f("terrorist") ; Fixes 11 words
:B0X*?:terroist::f("terrorist") ; Fixes 11 words
:B0X*?:tghe::f("the") ; Fixes 2176 words
:B0X*?:tghi::f("thi") ; Fixes 827 words
:B0X*?:thaph::f("taph") ; Fixes 60 words
:B0X*?:theather::f("theater") ; Fixes 7 words
:B0X*?:theese::f("these") ; Fixes 13 words
:B0X*?:thgat::f("that") ; Fixes 26 words
:B0X*?:thiun::f("thin") ; Fixes 212 words
:B0X*?:thsoe::f("those") ; Fixes 8 words
:B0X*?:thyat::f("that") ; Fixes 26 words
:B0X*?:tiait::f("tiat") ; Fixes 139 words
:B0X*?:tibut::f("tribut") ; Fixes 92 words
:B0X*?:ticial::f("tical") ; Fixes 863 words
:B0X*?:ticio::f("titio") ; Fixes 68 words
:B0X*?:ticlular::f("ticular") ; Fixes 36 words
:B0X*?:tiction::f("tinction") ; Fixes 8 words
:B0X*?:tiget::f("tiger") ; Fixes 11 words
:B0X*?:tiion::f("tion") ; Fixes 7052 words
:B0X*?:tingish::f("tinguish") ; Fixes 38 words
:B0X*?:tioge::f("toge") ; Fixes 74 words
:B0X*?:tionnab::f("tionab") ; Fixes 42 words
:B0X*?:tionne::f("tione") ; Fixes 108 words
:B0X*?:tionni::f("tioni") ; Fixes 265 words
:B0X*?:tisment::f("tisement") ; Fixes 4 words
:B0X*?:titid::f("titud") ; Fixes 88 words
:B0X*?:titity::f("tity") ; Fixes 14 words
:B0X*?:titui::f("tituti") ; Fixes 83 words
:B0X*?:tiviat::f("tivat") ; Fixes 100 words
:B0X*?:tje::f("the") ; Fixes 2176 words, but misspells Ondaatje (Canadian writer (born in Sri Lanka in 1943)) 
:B0X*?:tjhe::f("the") ; Fixes 2176 words
:B0X*?:tkae::f("take") ; Fixes 83 words
:B0X*?:tkaing::f("taking") ; Fixes 23 words
:B0X*?:tlak::f("talk") ; Fixes 74 words
:B0X*?:tlh::f("lth") ; Fixes 96 words 
:B0X*?:tlied::f("tled") ; Fixes 18 words
:B0X*?:tlme::f("tleme") ; Fixes 21 words
:B0X*?:tlye::f("tyle") ; Fixes 81 words
:B0X*?:tned::f("nted") ; Fixes 288 words
:B0X*?:tofy::f("tify") ; Fixes 73 words
:B0X*?:togani::f("tagoni") ; Fixes 25 words
:B0X*?:toghether::f("together") ; Fixes 4 words
:B0X*?:toleren::f("toleran") ; Fixes 11 words
:B0X*?:tority::f("torily") ; Fixes 15 words
:B0X*?:touble::f("trouble") ; Fixes 25 words
:B0X*?:tounge::f("tongue") ; Fixes 15 words
:B0X*?:tourch::f("torch") ; Fixes 20 words
:B0X*?:toword::f("toward") ; Fixes 5 words
:B0X*?:towrad::f("toward") ; Fixes 5 words
:B0X*?:tradion::f("tradition") ; Fixes 19 words
:B0X*?:tradtion::f("tradition") ; Fixes 19 words
:B0X*?:tranf::f("transf") ; Fixes 72 words
:B0X*?:transmissab::f("transmissib") ; Fixes 5 words
:B0X*?:tribusion::f("tribution") ; Fixes 20 words
:B0X*?:triger::f("trigger") ; Fixes 10 words
:B0X*?:tritian::f("trician") ; Fixes 27 words
:B0X*?:tritut::f("tribut") ; Fixes 92 words
:B0X*?:troling::f("trolling") ; Fixes 8 words
:B0X*?:troverci::f("troversi") ; Fixes 19 words
:B0X*?:trubution::f("tribution") ; Fixes 20 words
:B0X*?:tstion::f("tation") ; Fixes 490 words
:B0X*?:ttele::f("ttle") ; Fixes 237 words
:B0X*?:tuara::f("taura") ; Fixes 12 words
:B0X*?:tudonal::f("tudinal") ; Fixes 12 words
:B0X*?:tuer::f("teur") ; Fixes 53 words
:B0X*?:twpo::f("two") ; Fixes 92 words
:B0X*?:tyfull::f("tiful") ; Fixes 20 words
:B0X*?:tyha::f("tha") ; Fixes 512 words
:B0X*?:tyhi::f("thi") ; Fixes 1129 words 
:B0X*?:udner::f("under") ; Fixes 803 words
:B0X*?:udnet::f("udent") ; Fixes 23 words
:B0X*?:ugth::f("ught") ; Jack's fixes 146 words
:B0X*?:uitious::f("uitous") ; Fixes 15 words
:B0X*?:ulaton::f("ulation") ; Fixes 192 words
:B0X*?:umetal::f("umental") ; Fixes 27 words
:B0X*?:understoon::f("understood") ; Fixes 4 words
:B0X*?:untion::f("unction") ; Fixes 79 words
:B0X*?:unviers::f("univers") ; Fixes 26 words
:B0X*?:uoul::f("oul") ; Fixes 207 words
:B0X*?:uraunt::f("urant") ; Fixes 34 words
:B0X*?:uredd::f("ured") ; Fixes 196 words
:B0X*?:urgan::f("urgen") ; Fixes 21 words
:B0X*?:urveyer::f("urveyor") ; Fixes 4 words
:B0X*?:useage::f("usage") ; Fixes 9 words
:B0X*?:useing::f("using") ; Fixes 78 words
:B0X*?:usuab::f("usab") ; Fixes 31 words
:B0X*?:ususal::f("usual") ; Fixes 7 words
:B0X*?:utrab::f("urab") ; Fixes 138 words
:B0X*?:uttoo::f("utto") ; Fixes 83 words 
:B0X*?:uyt::f("ut") ; Fixes 6440 words , but misspells Nuytsia (A genus containing the species Nuytsia floribunda, also known as the Western Australian Christmas tree).
:B0X*?:vacative::f("vocative") ; Fixes 12 words
:B0X*?:valant::f("valent") ; Fixes 31 words
:B0X*?:valubl::f("valuabl") ; Fixes 7 words
:B0X*?:valueabl::f("valuabl") ; Fixes 7 words
:B0X*?:varaab::f("variab") ; Fixes 15 words 
:B0X*?:varation::f("variation") ; Fixes 5 words
:B0X*?:varien::f("varian") ; Fixes 17 words
:B0X*?:varing::f("varying") ; Fixes 5 words
:B0X*?:varous::f("various") ; Fixes 3 words
:B0X*?:vegat::f("veget") ; Fixes 31 words
:B0X*?:vegit::f("veget") ; Fixes 31 words
:B0X*?:vegt::f("veget") ; Fixes 31 words
:B0X*?:veinen::f("venien") ; Fixes 19 words
:B0X*?:veiw::f("view") ; Fixes 52 words
:B0X*?:velant::f("valent") ; Fixes 31 words
:B0X*?:velent::f("valent") ; Fixes 31 words
:B0X*?:venem::f("venom") ; Fixes 15 words
:B0X*?:vereal::f("veral") ; Fixes 20 words
:B0X*?:verison::f("version") ; Fixes 52 words
:B0X*?:vertibrat::f("vertebrat") ; Fixes 6 words
:B0X*?:vertion::f("version") ; Fixes 52 words
:B0X*?:vetat::f("vitat") ; Fixes 27 words
:B0X*?:veyr::f("very") ; Fixes 42 words
:B0X*?:vigeur::f("vigor") ; Fixes 26 words
:B0X*?:vigilen::f("vigilan") ; Fixes 13 words
:B0X*?:visial::f("visual") ; Fixes 36 words 
:B0X*?:vison::f("vision") ; Fixes 51 words
:B0X*?:visting::f("visiting") ; Fixes 3 words
:B0X*?:vition::f("vision") ; Fixes 76 words 
:B0X*?:vivous::f("vious") ; Fixes 28 words
:B0X*?:vlalent::f("valent") ; Fixes 31 words
:B0X*?:vment::f("vement") ; Fixes 26 words
:B0X*?:voiu::f("viou") ; Fixes 45 words 
:B0X*?:volont::f("volunt") ; Fixes 26 words
:B0X*?:volount::f("volunt") ; Fixes 26 words
:B0X*?:volumn::f("volum") ; Fixes 13 words
:B0X*?:vrey::f("very") ; Fixes 42 words
:B0X*?:vyer::f("very") ; Fixes 42 words
:B0X*?:vyre::f("very") ; Fixes 42 words
:B0X*?:waer::f("wear") ; Fixes 99 words
:B0X*?:waht::f("what") ; Fixes 34 words
:B0X*?:warrent::f("warrant") ; Fixes 24 words
:B0X*?:waty::f("way") ; Fixes 372 words 
:B0X*?:weee::f("wee") ; Fixes 524 words 
:B0X*?:wehn::f("when") ; Fixes 6 words
:B0X*?:werre::f("were") ; Fixes 31 words
:B0X*?:whant::f("want") ; Fixes 20 words
:B0X*?:wherre::f("where") ; Fixes 27 words
:B0X*?:whta::f("what") ; Fixes 34 words
:B0X*?:wief::f("wife") ; Fixes 28 words
:B0X*?:wieldl::f("wield") ; Fixes 15 words
:B0X*?:wierd::f("weird") ; Fixes 16 words
:B0X*?:wiew::f("view") ; Fixes 52 words
:B0X*?:willk::f("will") ; Fixes 64 words
:B0X*?:windoes::f("windows") ; Fixes 5 words
:B0X*?:wirt::f("writ") ; Fixes 88 words
:B0X*?:witten::f("written") ; Fixes 9 words
:B0X*?:wiull::f("will") ; Fixes 64 words
:B0X*?:wnat::f("want") ; Fixes 20 words
:B0X*?:woh::f("who") ; Fixes 92 words
:B0X*?:wokr::f("work") ; Fixes 338 words
:B0X*?:worls::f("world") ; Fixes 31 words
:B0X*?:wriet::f("write") ; Fixes 48 words
:B0X*?:wrighter::f("writer") ; Fixes 31 words
:B0X*?:writen::f("written") ; Fixes 9 words
:B0X*?:writting::f("writing") ; Fixes 18 words
:B0X*?:wrod::f("word") ; Fixes 92 words
:B0X*?:wrok::f("work") ; Fixes 338 words
:B0X*?:wtih::f("with") ; Fixes 56 words
:B0X*?:wupp::f("supp") ; Fixes 168 words
:B0X*?:yaer::f("year") ; Fixes 24 words
:B0X*?:yearm::f("year") ; Fixes 24 words
:B0X*?:yoiu::f("you") ; Fixes 51 words
:B0X*?:youch::f("touch") ; Fixes 69 words 
:B0X*?:ythim::f("ythm") ; Fixes 38 words
:B0X*?:ytion::f("tion") ; Fixes 8455 words 
:B0X*?:ytou::f("you") ; Fixes 51 words
:B0X*?:ytri::f("tri") ; Fixes 3250 words, but misspells Chytridiales and Synchytrium (Simple parasitic fungi including pond scum parasites).
:B0X*?:zyne::f("zine") ; Fixes 89 words
:B0X*?C:Amercia::f("America") ; Fixes 28 words, Case sensitive to not misspell amerciable (Of a crime or misdemeanor) 
:B0X*?C:balen::f("balan") ; Fixes 45 words.  Case-sensitive to not misspell Balenciaga (Spanish fashion designer). 
:B0X*?C:beng::f("being") ; Fixes 7 words. Case-sensitive to not misspell, Bengali. 
:B0X*?C:bouy::f("buoy") ; Fixes 13 words.  Case-sensitive to not misspell Bouyie (a branch of Tai language).
:B0X*?C:comt::f("cont") ; Fixes 587 words.  Misspells vicomte (French nobleman), Case sensitive so not misspell Comte (founder of Positivism and type of cheese)
:B0X*?C:doimg::f("doing") ; Fixes 21 words but might be a variable name(??)
:B0X*?C:elicid::f("elicit") ; Fixes 26 words, :C: so not to misspell Lelicidae (snail).
:B0X*?C:elpa::f("epla") ; Fixes 92 words.  Case sensitive to not misspell CELPA.
:B0X*?C:firc::f("furc") ; Fixes 33 words, Case-sensitive to not misspell FIRCA (sustainable funding mechanism for agricultural development)
:B0X*?C:hiesm::f("theism") ; Fixes 19 words
:B0X*?C:manan::f("manen") ; Fixes 27 words.  Case sensitive, so not to misspell Manannan (Celtic god of the sea; son of Ler)
:B0X*?C:mnt::f("ment") ; Fixes 1763 words.  Case-sensitive, to not misspell TMNT (Teenage Mutant Ninja Turtles)
:B0X*?C:moust::f("mous") ; Fixes 445 words, Case-sensitive to not Mousterian (archaeological culture, Neanderthal, before 70,000â€“32,000 BC)
:B0X*?C:oppen::f("open") ; Fixes 91 words.  Case-sensitive so not to misspell "Oppenheimer."
:B0X*?C:origen::f("origin") ; Fixes 37 words, Case sensitive to not misspell Origen (Greek philosopher and theologian).
:B0X*?C:pulic::f("public") ; Fixes 50 words, Case-sensitive to not misspell Pulicaria (Genus of temperate Old World herbs: fleabane)
:B0X*?C:sigin::f("sign") ; Fixes 243 words. Case-sensitive to not misspell SIGINT "Info from electronics telemetry intel."
:B0X*?C:tehr::f("ther") ; Fixes 921 words. Case sesnsitive to not misspell Tehran (capital and largest city of Iran).
:B0X*?C:tempra::f("tempora") ; Fixes 35 words. Case sensitive to not misspell Tempra (type of medicine).
:B0X*C:aquit::f("acquit") ; Fixes 10 words.  Case-sensitive to not misspell Aquitaine (A region of southwestern France between Bordeaux and the Pyrenees)
:B0X*C:carmel::f("caramel") ; Fixes 12 words.  Case-sensitive to not misspell Carmelite (Roman Catholic friar)
:B0X*C:carrer::f("career") ; Fixes 8 words.  Case-sensitive to not misspell Carrere (A famous architect) 
:B0X*C:daed::f("dead") ; Fixes 46 words, Case-sensitive to not misspell Daedal ([Greek mythology] an Athenian inventor who built the labyrinth of Minos)
:B0X*C:ehr::f("her") ; Fixes 233 words, Made case sensitive so not to misspell Ehrenberg (a Russian novelist) or Ehrlich (a German scientist)
:B0X*C:english::f("English") ; Fixes 8 words
:B0X*C:herat::f("heart") ; Fixes 63 words, Case-sensitive to not misspell Herat (a city in Afganistan).
:B0X*C:hsi::f("his") ; Fixes 95 words, Case-sensitive to not misspell Hsian (a city in China)
:B0X*C:ime::f("imme") ; Fixes 35 words, Case-sensitive to not misspell IMEI (International Mobile Equipment Identity)
:B0X*C:uber::f("über") ; Fixes 1 word
:B0X*C:wich::f("which") ; Fixes 3 words, Case-sensitive to not misspell Wichita.
:B0X*C:yoru::f("your") ; Fixes 4 words, case sensitive to not misspell Yoruba (A Nigerian langue) 
:B0X:*more that::f("more than") ; Fixes 1 word
:B0X:*more then::f("more than") ; Fixes 1 word
:B0X:*moreso::f("more so") ; Fixes 1 word
:B0X:*their has::f("there has") ; Fixes 1 word
:B0X:*their have::f("there have") ; Fixes 1 word
:B0X:;ils::f("Intensive Learning Services (ILS)")
:B0X:EDB::f("EBD") ; Fixes 1 word
:B0X:I thing::f("I think") ; Fixes 1 word
:B0X:Parri::f("Patti") ; Fixes 1 word
:B0X:a dominate::f("a dominant") ; Fixes 1 word
:B0X:a lose::f("a loss") ; Fixes 1 word
:B0X:a manufacture::f("a manufacturer") ; Fixes 1 word
:B0X:a only a::f("only a") ; Fixes 1 word
:B0X:a phenomena::f("a phenomenon") ; Fixes 1 word
:B0X:a protozoa::f("a protozoon") ; Fixes 1 word
:B0X:a renown::f("a renowned") ; Fixes 1 word
:B0X:a strata::f("a stratum") ; Fixes 1 word
:B0X:a taxa::f("a taxon") ; Fixes 1 word
:B0X:adres::f("address") ; Fixes 1 word
:B0X:affect on::f("effect on") ; Fixes 1 word
:B0X:affects of::f("effects of") ; Fixes 1 word
:B0X:agains::f("against") ; Fixes 1 word
:B0X:against who::f("against whom") ; Fixes 1 word
:B0X:agre::f("agree") ; Fixes 1 word
:B0X:aircrafts'::f("aircraft's") ; Fixes 1 word
:B0X:aircrafts::f("aircraft") ; Fixes 1 word
:B0X:all for not::f("all for naught") ; Fixes 1 word
:B0X:alot::f("a lot") ; Fixes 1 word
:B0X:also know as::f("also known as") ; Fixes 1 word
:B0X:also know by::f("also known by") ; Fixes 1 word
:B0X:also know for::f("also known for") ; Fixes 1 word
:B0X:alway::f("always") ; Fixes 1 word
:B0X:amin::f("main") ; Fixes 1 word
:B0X:an affect::f("an effect") ; Fixes 1 word
:B0X:andt he::f("and the") ; Fixes 1 word
:B0X:anothe::f("another") ; Fixes 1 word
:B0X:another criteria::f("another criterion") ; Fixes 1 word
:B0X:another words::f("in other words") ; Fixes 1 word
:B0X:apon::f("upon") ; Fixes 1 word
:B0X:are ass::f("are as") ; Fixes 1 word 
:B0X:are dominate::f("are dominant") ; Fixes 1 word
:B0X:are meet::f("are met") ; Fixes 1 word
:B0X:are renown::f("are renowned") ; Fixes 1 word
:B0X:are the dominate::f("are the dominant") ; Fixes 1 word
:B0X:aslo::f("also") ; Fixes 1 word
:B0X:atmospher::f("atmosphere") ; Fixes 1 word
:B0X:averag::f("average") ; Fixes 1 word
:B0X:be ran::f("be run") ; Fixes 1 word
:B0X:be rode::f("be ridden") ; Fixes 1 word
:B0X:be send::f("be sent") ; Fixes 1 word
:B0X:became know::f("became known") ; Fixes 1 word
:B0X:becames::f("became") ; Fixes 1 word
:B0X:becaus::f("because") ; Fixes 1 word
:B0X:been know::f("been known") ; Fixes 1 word
:B0X:been ran::f("been run") ; Fixes 1 word
:B0X:been rode::f("been ridden") ; Fixes 1 word
:B0X:been send::f("been sent") ; Fixes 1 word
:B0X:beggin::f("begin") ; Fixes 1 word
:B0X:being ran::f("being run") ; Fixes 1 word
:B0X:being rode::f("being ridden") ; Fixes 1 word
:B0X:bicep::f("biceps") ; Fixes 1 word
:B0X:boildrplate::f("boilerplate") ; Fixes 1 word 
:B0X:both of who::f("both of whom") ; Fixes 1 word
:B0X:butause::f("because") ; Fixes 1 word 
:B0X:ca nyou::f("can you")
:B0X:cafe::f("café") ; Fixes 1 word
:B0X:cafes::f("cafés") ; Fixes 1 word
:B0X:can breath::f("can breathe") ; Fixes 1 word
:B0X:can't breath::f("can't breathe") ; Fixes 1 word
:B0X:can't of::f("can't have") ; Fixes 1 word
:B0X:cant::f("can't") ; Fixes 1 word
:B0X:carcas::f("carcass") ; Fixes 1 word
:B0X:certain extend::f("certain extent") ; Fixes 1 word
:B0X:cliant::f("client") ; Fixes 1 word
:B0X:colum::f("column") ; Fixes 1 word
:B0X:could breath::f("could breathe") ; Fixes 1 word
:B0X:couldn't breath::f("couldn't breathe") ; Fixes 1 word
:B0X:daily regiment::f("daily regimen") ; Fixes 1 word
:B0X:depending of::f("depending on") ; Fixes 1 word
:B0X:depends of::f("depends on") ; Fixes 1 word
:B0X:devels::f("delves") ; Fixes 1 word
:B0X:disent::f("dissent") ; Fixes 1 word 
:B0X:dispell::f("dispel") ; Fixes 1 word
:B0X:dispells::f("dispels") ; Fixes 1 word
:B0X:do to::f("due to") ; Fixes 1 word
:B0X:dolka::f("folks") ; Fixes 1 word 
:B0X:doub::f("doubt") ; Fixes 1 word
:B0X:drafty of::f("draft of")
:B0X:dum::f("dumb") ; Fixes 1 word
:B0X:earlies::f("earliest") ; Fixes 1 word
:B0X:eash::f("each") ; Fixes 1 word 
:B0X:eath::f("each") ; Fixes 1 word
:B0X:ect::f("etc") ; Fixes 1 word
:B0X:elast::f("least") ; Fixes 1 word
:B0X:embarras::f("embarrass") ; Fixes 1 word
:B0X:en mass::f("en masse") ; Fixes 1 word
:B0X:entrie::f("entire") ; Fixes 1 word 
:B0X:excell::f("excel") ; Fixes 1 word
:B0X:experienc::f("experience") ; Fixes 1 word
:B0X:eyt::f("yet") ; Fixes 1 word
:B0X:facia::f("fascia") ; Fixes 1 word
:B0X:for he and::f("for him and") ; Fixes 1 word
:B0X:fora::f("for a") ; Fixes 1 word
:B0X:forbad::f("forbade") ; Fixes 1 word
:B0X:fro::f("for") ; Fixes 1 word
:B0X:frome::f("from") ; Fixes 1 word
:B0X:fulfil::f("fulfill") ; Fixes 1 word
:B0X:gae::f("game") ; Fixes 1 word
:B0X:grat::f("great") ; Fixes 1 word
:B0X:had awoke::f("had awoken") ; Fixes 1 word
:B0X:had broke::f("had broken") ; Fixes 1 word
:B0X:had chose::f("had chosen") ; Fixes 1 word
:B0X:had fell::f("had fallen") ; Fixes 1 word
:B0X:had forbad::f("had forbidden") ; Fixes 1 word
:B0X:had forbade::f("had forbidden") ; Fixes 1 word
:B0X:had know::f("had known") ; Fixes 1 word
:B0X:had plead::f("had pleaded") ; Fixes 1 word
:B0X:had ran::f("had run") ; Fixes 1 word
:B0X:had rang::f("had rung") ; Fixes 1 word
:B0X:had rode::f("had ridden") ; Fixes 1 word
:B0X:had spoke::f("had spoken") ; Fixes 1 word
:B0X:had swam::f("had swum") ; Fixes 1 word
:B0X:had throve::f("had thriven") ; Fixes 1 word
:B0X:had woke::f("had woken") ; Fixes 1 word
:B0X:happend::f("happened") ; Fixes 1 word
:B0X:happended::f("happened") ; Fixes 1 word
:B0X:happenned::f("happened") ; Fixes 1 word
:B0X:has arose::f("has arisen") ; Fixes 1 word
:B0X:has awoke::f("has awoken") ; Fixes 1 word
:B0X:has bore::f("has borne") ; Fixes 1 word
:B0X:has broke::f("has broken") ; Fixes 1 word
:B0X:has build::f("has built") ; Fixes 1 word
:B0X:has chose::f("has chosen") ; Fixes 1 word
:B0X:has drove::f("has driven") ; Fixes 1 word
:B0X:has fell::f("has fallen") ; Fixes 1 word
:B0X:has flew::f("has flown") ; Fixes 1 word
:B0X:has forbad::f("has forbidden") ; Fixes 1 word
:B0X:has forbade::f("has forbidden") ; Fixes 1 word
:B0X:has plead::f("has pleaded") ; Fixes 1 word
:B0X:has ran::f("has run") ; Fixes 1 word
:B0X:has spoke::f("has spoken") ; Fixes 1 word
:B0X:has swam::f("has swum") ; Fixes 1 word
:B0X:has trod::f("has trodden") ; Fixes 1 word
:B0X:has woke::f("has woken") ; Fixes 1 word
:B0X:hav::f("had") ; Fixes 1 word 
:B0X:have ran::f("have run") ; Fixes 1 word
:B0X:have swam::f("have swum") ; Fixes 1 word
:B0X:having ran::f("having run") ; Fixes 1 word
:B0X:having swam::f("having swum") ; Fixes 1 word
:B0X:he plead::f("he pleaded") ; Fixes 1 word
:B0X:hier::f("heir") ; Fixes 1 word
:B0X:how ever::f("however") ; Fixes 1 word
:B0X:howver::f("however") ; Fixes 1 word
:B0X:humer::f("humor") ; Fixes 1 word
:B0X:husban::f("husband") ; Fixes 1 word
:B0X:hypocrit::f("hypocrite") ; Fixes 1 word
:B0X:if is::f("it is") ; Fixes 1 word
:B0X:if was::f("it was") ; Fixes 1 word
:B0X:imagin::f("imagine") ; Fixes 1 word
:B0X:ineeed::f("indeed") ; Fixes 1 word 
:B0X:internation::f("international") ; Fixes 1 word
:B0X:is also know::f("is also known") ; Fixes 1 word
:B0X:is consider::f("is considered") ; Fixes 1 word
:B0X:is know::f("is known") ; Fixes 1 word
:B0X:it self::f("itself") ; Fixes 1 word
:B0X:japanes::f("Japanese") ; Fixes 1 word
:B0X:larg::f("large") ; Fixes 1 word
:B0X:lise::f("like") ; Fixes 1 word 
:B0X:lot's of::f("lots of") ; Fixes 1 word
:B0X:maltesian::f("Maltese") ; Fixes 1 word
:B0X:mear::f("mere") ; Fixes 1 word
:B0X:might of::f("might have") ; Fixes 1 word
:B0X:more resent::f("more recent") ; Fixes 1 word
:B0X:most resent::f("most recent") ; Fixes 1 word
:B0X:must of::f("must have") ; Fixes 1 word
:B0X:mysef::f("myself") ; Fixes 1 word
:B0X:mysefl::f("myself") ; Fixes 1 word
:B0X:neither criteria::f("neither criterion") ; Fixes 1 word
:B0X:neither phenomena::f("neither phenomenon") ; Fixes 1 word
:B0X:nestin::f("nesting") ; Fixes 1 word
:B0X:noth::f("north") ; Fixes 1 word
:B0X:nto::f("not") ; Fixes 1 word 
:B0X:ocur::f("occur") ; Fixes 1 word
:B0X:one criteria::f("one criterion") ; Fixes 1 word
:B0X:one phenomena::f("one phenomenon") ; Fixes 1 word
:B0X:opposit::f("opposite") ; Fixes 1 word
:B0X:our of::f("out of") ; Fixes 1 word
:B0X:per say::f("per se") ; Fixes 1 word
:B0X:perhasp::f("perhaps") ; Fixes 1 word
:B0X:perphas::f("perhaps") ; Fixes 1 word
:B0X:personel::f("personnel") ; Fixes 1 word
:B0X:poisin::f("poison") ; Fixes 1 word
:B0X:protem::f("pro tem") ; Fixes 1 word
:B0X:recal::f("recall") ; Fixes 1 word
:B0X:rela::f("real") ; Fixes 1 word
:B0X:repla::f("reply") ; Fixes 1 word 
:B0X:republi::f("republic") ; Fixes 1 word
:B0X:scientis::f("scientist") ; Fixes 1 word
:B0X:sherif::f("sheriff") ; Fixes 1 word
:B0X:should not of::f("should not have") ; Fixes 1 word
:B0X:should of::f("should have") ; Fixes 1 word
:B0X:show resent::f("show recent") ; Fixes 1 word
:B0X:some how::f("somehow") ; Fixes 1 word
:B0X:some one::f("someone") ; Fixes 1 word
:B0X:sq mi::f("mi²") ; Fixes 1 word
:B0X:t he::f("the") ; Fixes 1 word
:B0X:tast::f("taste") ; Fixes 1 word
:B0X:tath::f("that") ; Fixes 1 word
:B0X:thanks@!::f("thanks!") ; Fixes 1 word
:B0X:thanks@::f("thanks!") ; Fixes 1 word
:B0X:thay::f("they") ; Fixes 1 word 
:B0X:the advise of::f("the advice of") ; Fixes 1 word
:B0X:the dominate::f("the dominant") ; Fixes 1 word
:B0X:the extend of::f("the extent of") ; Fixes 1 word
:B0X:their is::f("there is") ; Fixes 1 word
:B0X:there of::f("thereof") ; Fixes 1 word
:B0X:theri::f("their") ; Fixes 1 word
:B0X:thes::f("this") ; Fixes 1 word 
:B0X:thet::f("that") ; Fixes 1 word 
:B0X:they;l::f("they'll") ; Fixes 1 word
:B0X:they;r::f("they're") ; Fixes 1 word
:B0X:they;v::f("they've") ; Fixes 1 word
:B0X:thi::f("the") ; Fixes 1 word 
:B0X:thie::f("this") ; Fixes 1 word 
:B0X:this lead to::f("this led to") ; Fixes 1 word
:B0X:thit::f("that") ; Fixes 1 word 
:B0X:thr::f("the") ; Fixes 1 word 
:B0X:thru::f("through") ; Fixes 1 word
:B0X:ths::f("the") ; Fixes 1 word 
:B0X:to bath::f("to bathe") ; Fixes 1 word
:B0X:to be build::f("to be built") ; Fixes 1 word
:B0X:to breath::f("to breathe") ; Fixes 1 word. Would break "breath to breath."
:B0X:to chose::f("to choose") ; Fixes 1 word
:B0X:to cut of::f("to cut off") ; Fixes 1 word
:B0X:to loath::f("to loathe") ; Fixes 1 word
:B0X:to some extend::f("to some extent") ; Fixes 1 word
:B0X:to try and::f("to try to") ; Fixes 1 word
:B0X:tou::f("you") ; Fixes 1 word
:B0X:troup::f("troupe") ; Fixes 1 word
:B0X:tyhe::f("they") ; Fixes 1 word
:B0X:was cable of::f("was capable of") ; Fixes 1 word
:B0X:was establish::f("was established") ; Fixes 1 word
:B0X:was extend::f("was extended") ; Fixes 1 word
:B0X:was know::f("was known") ; Fixes 1 word
:B0X:was ran::f("was run") ; Fixes 1 word
:B0X:was rode::f("was ridden") ; Fixes 1 word
:B0X:was the dominate::f("was the dominant") ; Fixes 1 word
:B0X:was tore::f("was torn") ; Fixes 1 word
:B0X:was wrote::f("was written") ; Fixes 1 word
:B0X:were build::f("were built") ; Fixes 1 word
:B0X:were ran::f("were run") ; Fixes 1 word
:B0X:were rebuild::f("were rebuilt") ; Fixes 1 word
:B0X:were rode::f("were ridden") ; Fixes 1 word
:B0X:were spend::f("were spent") ; Fixes 1 word
:B0X:were the dominate::f("were the dominant") ; Fixes 1 word
:B0X:were tore::f("were torn") ; Fixes 1 word
:B0X:were wrote::f("were written") ; Fixes 1 word
:B0X:whan::f("when") ; Fixes 1 word 
:B0X:when ever::f("whenever") ; Fixes 1 word
:B0X:where as::f("whereas") ; Fixes 1 word
:B0X:whereas as::f("whereas") ; Fixes 1 word
:B0X:whi::f("who") ; Fixes 2 words 
:B0X:will of::f("will have") ; Fixes 1 word
:B0X:with in::f("within") ; Fixes 1 word
:B0X:with on of::f("with one of") ; Fixes 1 word
:B0X:with who::f("with whom") ; Fixes 1 word
:B0X:witha::f("with a") ; Fixes 1 word
:B0X:withing::f("within") ; Fixes 1 word
:B0X:wonderfull::f("wonderful") ; Fixes 1 word
:B0X:would of::f("would have") ; Fixes 1 word
:B0X:your a::f("you're a") ; Fixes 1 word
:B0X:your an::f("you're an") ; Fixes 1 word
:B0X:your her::f("you're her") ; Fixes 1 word
:B0X:your here::f("you're here") ; Fixes 1 word
:B0X:your his::f("you're his") ; Fixes 1 word
:B0X:your my::f("you're my") ; Fixes 1 word
:B0X:your the::f("you're the") ; Fixes 1 word
:B0X:youv'e::f("you've") ; Fixes 1 word 
:B0X:youve::f("you've") ; Fixes 1 word
:B0X?*:actaul::f("actual") ; Fixes 40 words 
:B0X?*:alyl::f("ally") ; Fixes 2691 words 
:B0X?*:delimma::f("dilemma") ; Fixes 3 words 
:B0X?*:discrict::f("district") ; Fixes 13 words 
:B0X?*:elyl::f("ely") ; Fixes 1183 words 
:B0X?*:folor::f("color") ; Fixes 147 words 
:B0X?*:iosn::f("ions") ; Fixes 3682 words 
:B0X?*:ligy::f("lify") ; Fixes 37 words 
:B0X?*:orror::f("error") ; Fixes 56 words , but misspells horror, added to protective word list, above. 
:B0X?*:qit::f("quit") ; Fixes 112 words 
:B0X?*:sxh::f("sch") ; Fixes 744 words 
:B0X?:'nt::f("n't") ; Fixes 24 words
:B0X?:;ll::f("'ll") ; Fixes 1 word
:B0X?:;re::f("'re") ; Fixes 1 word
:B0X?:;s::f("'s") ; Fixes 1 word
:B0X?:;ve::f("'ve") ; Fixes 1 word
:B0X?:Spet::f("Sept") ; Fixes 2 words 
:B0X?:abely::f("ably") ; Fixes 568 words
:B0X?:abley::f("ably") ; Fixes 568 words
:B0X?:acn::f("can") ; Fixes 64 words
:B0X?:addres::f("address") ; Fixes 4 words
:B0X?:aelly::f("eally") ; Fixes 23 words
:B0X?:aindre::f("ained") ; Fixes 81 words
:B0X?:alekd::f("alked") ; Fixes 16 words
:B0X?:allly::f("ally") ; Fixes 2436 words
:B0X?:alowing::f("allowing") ; Fixes 8 words
:B0X?:amde::f("made") ; Fixes 6 words
:B0X?:ancestory::f("ancestry") 
:B0X?:ancles::f("acles") ; Fixes 21 words
:B0X?:andd::f("and") ; Fixes 251 words
:B0X?:anim::f("anism") ; Fixes 123 words, but misspells minyanim (The quorum required by Jewish law to be present for public worship)
:B0X?:aotrs::f("ators") ; Fixes 414 words
:B0X?:appearred::f("appeared") ; Fixes 3 words
:B0X?:artice::f("article") ; Fixes 5 words
:B0X?:arund::f("around") ; Fixes 1 word
:B0X?:aticly::f("atically") ; Fixes 113 words
:B0X?:ativs::f("atives") ; Fixes 63 words
:B0X?:atley::f("ately") ; Fixes 162 words, but misspells Wheatley (a fictional artificial intelligence from the Portal franchise)
:B0X?:atn::f("ant") ; Fixes 506 words
:B0X?:attemp::f("attempt") ; Fixes 2 words
:B0X?:aunchs::f("aunches") ; Fixes 9 words
:B0X?:autor::f("author") ; Fixes 2 words
:B0X?:ayd::f("ady") ; Fixes 24 words
:B0X?:ayt::f("ay") ; Fixes 429 words
:B0X?:aywa::f("away") ; Fixes 24 words
:B0X?:bilites::f("bilities") ; Fixes 487 words
:B0X?:bilties::f("bilities") ; Fixes 487 words
:B0X?:bilty::f("bility") ; Fixes 915 words
:B0X?:blities::f("bilities") ; Fixes 487 words
:B0X?:blity::f("bility") ; Fixes 915 words
:B0X?:blly::f("bly") ; Fixes 735 words
:B0X?:boared::f("board") ; Fixes 1 word
:B0X?:borke::f("broke") ; Fixes 5 words
:B0X?:bth::f("beth") ; Fixes 5 words 
:B0X?:bthe::f("b the") ; Fixes 1 word
:B0X?:busines::f("business") ; Fixes 3 words
:B0X?:busineses::f("businesses") ; Fixes 2 words
:B0X?:bve::f("be") ; Fixes 127 words
:B0X?:caht::f("chat") ; Fixes 8 words
:B0X?:certaintly::f("certainly") ; Fixes 3 words
:B0X?:cisly::f("cisely") ; Fixes 4 words
:B0X?:claimes::f("claims") ; Fixes 10 words
:B0X?:claming::f("claiming") ; Fixes 9 words
:B0X?:clud::f("clude") ; Fixes 6 words
:B0X?:comit::f("commit") ; Fixes 3 words
:B0X?:comming::f("coming") ; Fixes 14 words
:B0X?:commiting::f("committing") ; Fixes 3 words
:B0X?:committe::f("committee") ; Fixes 2 words
:B0X?:comon::f("common") ; Fixes 33 words
:B0X?:compability::f("compatibility") ; Fixes 5 words
:B0X?:competely::f("completely") ; Fixes 3 words
:B0X?:controll::f("control") ; Fixes 3 words
:B0X?:controlls::f("controls") ; Fixes 3 words
:B0X?:criticists::f("critics") ; Fixes 2 words
:B0X?:cthe::f("c the") ; Fixes 1 word
:B0X?:cticly::f("ctically") ; Fixes 23 words
:B0X?:ctino::f("ction") ; Fixes 226 words
:B0X?:ctoty::f("ctory") ; Fixes 23 words
:B0X?:cually::f("cularly") ; Fixes 38 words
:B0X?:culem::f("culum") ; Fixes 19 words
:B0X?:cumenta::f("cuments") ; Fixes 2 words 
:B0X?:currenly::f("currently") ; Fixes 5 words
:B0X?:daty::f("day") ; Fixes 48 words 
:B0X?:daye::f("date") ; Fixes 73 words, exists as beginning and end.
:B0X?:decidely::f("decidedly") ; Fixes 2 words
:B0X?:develope::f("develop") ; Fixes 5 words
:B0X?:developes::f("develops") ; Fixes 5 words
:B0X?:dfull::f("dful") ; Fixes 14 words
:B0X?:difere::f("differe") ; Fixes 41 words
:B0X?:disctinct::f("distinct") ; Fixes 18 words
:B0X?:dng::f("ding") ; Fixes 618 words
:B0X?:doens::f("does") ; Fixes 23 words
:B0X?:doese::f("does") ; Fixes 23 words
:B0X?:dreasm::f("dreams") ; Fixes 2 words
:B0X?:dtae::f("date") ; Fixes 59 words
:B0X?:dthe::f("d the") ; Fixes 1 word
:B0X?:eamil::f("email") ; Fixes 6 words
:B0X?:ecclectic::f("eclectic") ; Fixes 6 words
:B0X?:eclisp::f("eclips") ; Fixes 6 words
:B0X?:ed form the ::f("ed from the")
:B0X?:edely::f("edly") ; Fixes 674 words
:B0X?:efel::f("feel") ; Fixes 8 words
:B0X?:efort::f("effort") ; Fixes 8 words
:B0X?:efulls::f("efuls") ; Fixes 18 words
:B0X?:encs::f("ences") ; Fixes 301 words
:B0X?:equiped::f("equipped") ; Fixes 4 words
:B0X?:ernt::f("erent") ; Fixes 26 words 
:B0X?:esnt::f("esent") ; Fixes 8 words
:B0X?:essery::f("essary") ; Fixes 4 words Fixes 9
:B0X?:essess::f("esses") ; Fixes 200 words
:B0X?:establising::f("establishing") ; Fixes 4 words
:B0X?:examinated::f("examined") ; Fixes 3 words
:B0X?:expell::f("expel") ; Fixes 2 words
:B0X?:ferrs::f("fers") ; Fixes 72 words
:B0X?:fiel::f("file") ; Fixes 9 words
:B0X?:finit::f("finite") ; Fixes 6 words
:B0X?:finitly::f("finitely") ; Fixes 4 words
:B0X?:fng::f("fing") ; Fixes 141 words 
:B0X?:frmo::f("from") ; Fixes 3 words
:B0X?:frp,::f("from") ; Fixes 3 words
:B0X?:fthe::f("f the") ; Fixes 1 word
:B0X?:fuly::f("fully") ; Fixes 191 words
:B0X?:gardes::f("gards") ; Fixes 5 words
:B0X?:getted::f("geted") ; Fixes 8 words
:B0X?:gettin::f("getting") ; Fixes 4 words
:B0X?:gfulls::f("gfuls") ; Fixes 4 words
:B0X?:ginaly::f("ginally") ; Fixes 8 words
:B0X?:giory::f("gory") ; Fixes 7 words
:B0X?:glases::f("glasses") ; Fixes 11 words
:B0X?:gratefull::f("grateful") ; Fixes 3 words
:B0X?:gred::f("greed") ; Fixes 6 words
:B0X?:gthe::f("g the") ; Fixes 1 word
:B0X?:hace::f("hare") ; Fixes 9 words
:B0X?:herad::f("heard") ; Fixes 5 words
:B0X?:herefor::f("herefore") ; Fixes 2 words
:B0X?:hfull::f("hful") ; Fixes 30 words
:B0X?:hge::f("he") ; Fixes 147 words
:B0X?:higns::f("hings") ; Fixes 79 words
:B0X?:higsn::f("hings") ; Fixes 79 words
:B0X?:hsa::f("has") ; Fixes 62 words
:B0X?:hsi::f("his") ; Fixes 59 words
:B0X?:hte::f("the") ; Fixes 44 words
:B0X?:hthe::f("h the") ; Fixes 1 word
:B0X?:http:\\::f("http://") ; Fixes 1 word
:B0X?:httpL::f("http:") ; Fixes 1 word
:B0X?:iaing::f("iating") ; Fixes 84 words
:B0X?:ialy::f("ially") ; Fixes 244 words, but misspells bialy (Flat crusty-bottomed onion roll) 
:B0X?:iatly::f("iately") ; Fixes 12 words
:B0X?:iblilty::f("ibility") ; Fixes 168 words
:B0X?:icaly::f("ically") ; Fixes 1432 words
:B0X?:icm::f("ism") ; Fixes 1075 words
:B0X?:icms::f("isms") ; Fixes 717 words
:B0X?:idty::f("dity") ; Fixes 67 words
:B0X?:ienty::f("iently") ; Fixes 36 words
:B0X?:ign::f("ing") ; Fixes 11384 words, but misspells a bunch (which are nullified above)
:B0X?:ilarily::f("ilarly") ; Fixes 5 words
:B0X?:ilny::f("inly") ; Fixes 18 words
:B0X?:inm::f("in") ; Fixes 1595 words 
:B0X?:isio::f("ision") ; Fixes 27 words
:B0X?:itino::f("ition") ; Fixes 113 words
:B0X?:itiy::f("ity") ; Fixes 1890 words
:B0X?:itoy::f("itory") ; Fixes 23 words
:B0X?:itr::f("it") ; Fixes 366 words, but misspells Savitr (Important Hindu god) 
:B0X?:ityes::f("ities") ; Fixes 1347 words
:B0X?:ivites::f("ivities") ; Fixes 73 words
:B0X?:jutt::f("just") ; Fixes 9 words 
:B0X?:kc::f("ck") ; Fixes 610 words.  Misspells kc (thousand per second).
:B0X?:kfulls::f("kfuls") ; Fixes 7 words
:B0X?:kn::f("nk") ; Fixes 168 words
:B0X?:kng::f("king") ; Fixes 798 words 
:B0X?:kthe::f("k the") ; Fixes 1 word
:B0X?:l;y::f("ly") ; Fixes 10464 words
:B0X?:laly::f("ally") ; Fixes 2436 words
:B0X?:letness::f("leteness") ; Fixes 5 words
:B0X?:lfull::f("lful") ; Fixes 13 words
:B0X?:lieing::f("lying") ; Fixes 46 words
:B0X?:lighly::f("lightly") ; Fixes 3 words
:B0X?:likey::f("likely") ; Fixes 4 words
:B0X?:llete::f("lette") ; Fixes 17 words
:B0X?:lsit::f("list") ; Fixes 244 words
:B0X?:lthe::f("l the") ; Fixes 1 word
:B0X?:lwats::f("lways") ; Fixes 6 words
:B0X?:lyu::f("ly") ; Fixes 9123 words
:B0X?:maked::f("marked") ; Fixes 15 words
:B0X?:maticas::f("matics") ; Fixes 26 words
:B0X?:miantly::f("minately") ; Fixes 6 words
:B0X?:mibly::f("mably") ; Fixes 16 words
:B0X?:miliary::f("military") ; Fixes 4 words, but misspells miliary ()
:B0X?:morphysis::f("morphosis") ; Fixes 4 words
:B0X?:motted::f("moted") ; Fixes 5 words
:B0X?:mpley::f("mply") ; Fixes 13 words
:B0X?:mpyl::f("mply") ; Fixes 13 words
:B0X?:mthe::f("m the") ; Fixes 1 word
:B0X?:n;t::f("n't") 
:B0X?:narys::f("naries") ; Fixes 47 words
:B0X?:ndacies::f("ndances") ; Fixes 8 words
:B0X?:nfull::f("nful") ; Fixes 36 words
:B0X?:nfulls::f("nfuls") ; Fixes 17 words
:B0X?:ngment::f("ngement") ; Fixes 18 words
:B0X?:nicly::f("nically") ; Fixes 136 words
:B0X?:nig::f("ing") ; Fixes 11414 words.  Misspells pfennig (100 pfennigs formerly equaled 1 DeutscheÂ Mark in Germany).
:B0X?:nision::f("nisation") ; Fixes 93 words
:B0X?:nnally::f("nally") ; Fixes 249 words
:B0X?:nnology::f("nology") ; Fixes 43 words
:B0X?:ns't::f("sn't") ; Fixes 4 words
:B0X?:nsly::f("nsely") ; Fixes 6 words
:B0X?:nsof::f("ns of") ; Fixes 1 word
:B0X?:nsur::f("nsure") ; Fixes 10 words
:B0X?:ntay::f("ntary") ; Fixes 34 words
:B0X?:nyed::f("nied") ; Fixes 15 words
:B0X?:oachs::f("oaches") ; Fixes 13 words
:B0X?:occure::f("occur") ; Fixes 3 words
:B0X?:occured::f("occurred") ; Fixes 3 words
:B0X?:occurr::f("occur") ; Fixes 3 words
:B0X?:olgy::f("ology") ; Fixes 316 words
:B0X?:oloo::f("ollo") ; Fixes 6 words 
:B0X?:omst::f("most") ; Fixes 39 words
:B0X?:onaly::f("onally") ; Fixes 174 words
:B0X?:onw::f("one") ; Fixes 341 words
:B0X?:otaly::f("otally") ; Fixes 6 words
:B0X?:otherw::f("others") ; Fixes 16 words
:B0X?:otino::f("otion") ; Fixes 12 words
:B0X?:otu::f("out") ; Fixes 97 words
:B0X?:ougly::f("oughly") ; Fixes 3 words
:B0X?:ouldent::f("ouldn't") ; Fixes 3 words
:B0X?:ourary::f("orary") ; Fixes 6 words
:B0X?:paide::f("paid") ; Fixes 7 words
:B0X?:pich::f("pitch") ; Fixes 3 words
:B0X?:pleatly::f("pletely") ; Fixes 4 words
:B0X?:pletly::f("pletely") ; Fixes 4 words
:B0X?:polical::f("political") ; Fixes 7 words
:B0X?:proces::f("process") ; Fixes 3 words
:B0X?:proprietory::f("proprietary") ; Fixes 2 words
:B0X?:pthe::f("p the") ; Fixes 1 word
:B0X?:publis::f("publics") ; Fixes 2 words
:B0X?:puertorrican::f("Puerto Rican") ; Fixes 2 words
:B0X?:quater::f("quarter") ; Fixes 4 words
:B0X?:quaters::f("quarters") ; Fixes 4 words
:B0X?:querd::f("quered") ; Fixes 5 words
:B0X?:raly::f("rally") ; Fixes 120 words
:B0X?:rarry::f("rary") ; Fixes 23 words
:B0X?:realy::f("really") ; Fixes 12 words
:B0X?:reched::f("reached") ; Fixes 6 words
:B0X?:reciding::f("residing") ; Fixes 2 words
:B0X?:reday::f("ready") ; Fixes 7 words
:B0X?:resed::f("ressed") ; Fixes 50 words
:B0X?:resing::f("ressing") ; Fixes 40 words
:B0X?:returnd::f("returned") ; Fixes 2 words
:B0X?:riey::f("riety") ; Fixes 8 words
:B0X?:rithy::f("rity") ; Fixes 120 words
:B0X?:ritiers::f("rities") ; Fixes 105 words
:B0X?:rsise::f("rwise") ; Fixes 5 words 
:B0X?:ruley::f("ruly") ; Fixes 4 words
:B0X?:ryied::f("ried") ; Fixes 70 words
:B0X?:saccharid::f("saccharide") ; Fixes 8 words
:B0X?:safty::f("safety") ; Fixes 2 words
:B0X?:sasy::f("says") ; Fixes 12 words
:B0X?:saught::f("sought") ; Fixes 3 words
:B0X?:schol::f("school") ; Fixes 5 words
:B0X?:scoll::f("scroll") ; Fixes 2 words
:B0X?:seses::f("sesses") ; Fixes 8 words
:B0X?:sfull::f("sful") ; Fixes 7 words
:B0X?:sfulyl::f("sfully") ; Fixes 5 words
:B0X?:shiping::f("shipping") ; Fixes 8 words
:B0X?:shorly::f("shortly") ; Fixes 2 words
:B0X?:siary::f("sary") ; Fixes 16 words
:B0X?:sice::f("sive") ; Fixes 166 words, but misspells sice (The number six at dice)
:B0X?:sicly::f("sically") ; Fixes 24 words
:B0X?:sinn::f("sign") ; Fixes 21 words 
:B0X?:smoothe::f("smooth") ; Fixes 2 words
:B0X?:sorce::f("source") ; Fixes 5 words
:B0X?:specif::f("specify") ; Fixes 4 words
:B0X?:ssully::f("ssfully") ; Fixes 5 words
:B0X?:stanly::f("stantly") ; Fixes 8 words
:B0X?:sthe::f("s the") ; Fixes 1 word
:B0X?:stino::f("stion") ; Fixes 14 words
:B0X?:storicians::f("storians") ; Fixes 4 words
:B0X?:stpo::f("stop") ; Fixes 8 words
:B0X?:strat::f("start") ; Fixes 5 words
:B0X?:struced::f("structed") ; Fixes 11 words
:B0X?:stude::f("study") ; Fixes 5 words 
:B0X?:stuls::f("sults") ; Fixes 4 words
:B0X?:syas::f("says") ; Fixes 12 words, but misspells Vaisyas (A member of the mercantile and professional Hindu caste.) 
:B0X?:t eh::f("the") ; Fixes 44 words ; Made case sensitive for 'at EH.'
:B0X?:targetting::f("targeting") ; Fixes 3 words
:B0X?:teh::f("the") ; Fixes 44 words
:B0X?:tempory::f("temporary") ; Fixes 3 words
:B0X?:tfull::f("tful") ; Fixes 64 words
:B0X?:theh::f("the") ; Fixes 44 words
:B0X?:thh::f("th") ; Fixes 408 words
:B0X?:thn::f("then") ; Fixes 15 words 
:B0X?:thne::f("then") ; Fixes 11 words
:B0X?:throught::f("through") ; Fixes 3 words
:B0X?:thw::f("the") ; Fixes 44 words
:B0X?:thyness::f("thiness") ; Fixes 32 words
:B0X?:tiem::f("time") ; Fixes 44 words
:B0X?:timne::f("time") ; Fixes 44 words
:B0X?:tioj::f("tion") ; Fixes 3671 words
:B0X?:tionar::f("tionary") ; Fixes 68 words
:B0X?:tng::f("ting") ; Fixes 3023 words 
:B0X?:tooes::f("toos") ; Fixes 4 words
:B0X?:topry::f("tory") ; Fixes 317 words
:B0X?:toreis::f("tories") ; Fixes 62 words
:B0X?:toyr::f("tory") ; Fixes 317 words
:B0X?:traing::f("traying") ; Fixes 4 words
:B0X?:tricly::f("trically") ; Fixes 72 words
:B0X?:tricty::f("tricity") ; Fixes 13 words
:B0X?:truely::f("truly") ; Fixes 2 words
:B0X?:tthe::f("the") ; Fixes 66 words 
:B0X?:tust::f("trust") ; Fixes 8 words 
:B0X?:twon::f("town") ; Fixes 32 words
:B0X?:tyo::f("to") ; Fixes 185 words
:B0X?:uarly::f("ularly") ; Fixes 66 words
:B0X?:ularily::f("ularly") ; Fixes 66 words
:B0X?:ultimely::f("ultimately") ; Fixes 2 words
:B0X?:urchs::f("urches") ; Fixes 4 words
:B0X?:urnk::f("runk") ; Fixes 8 words
:B0X?:utino::f("ution") ; Fixes 55 words
:B0X?:veill::f("veil") ; Fixes 3 words
:B0X?:verd::f("vered") ; Fixes 39 words
:B0X?:videntally::f("vidently") ; Fixes 3 words
:B0X?:vly::f("vely") ; Fixes 547 words
:B0X?:wass::f("was") ; Fixes 13 words
:B0X?:wasy::f("ways") ; Fixes 106 words
:B0X?:weas::f("was") ; Fixes 13 words
:B0X?:weath::f("wealth") ; Fixes 3 words
:B0X?:wifes::f("wives") ; Fixes 7 words
:B0X?:wille::f("will") ; Fixes 10 words
:B0X?:willingless::f("willingness") ; Fixes 2 words
:B0X?:wordly::f("worldly") ; Fixes 3 words
:B0X?:wroet::f("wrote") ; Fixes 7 words
:B0X?:wthe::f("w the") ; Fixes 1 word
:B0X?:wya::f("way") ; Fixes 113 words
:B0X?:wyas::f("ways") ; Fixes 106 words
:B0X?:xthe::f("x the") ; Fixes 1 word
:B0X?:yng::f("ying") ; Fixes 514 words
:B0X?:yuo::f("you") ; Fixes 3 words 
:B0X?:ywat::f("yway") ; Fixes 6 words
:B0X?C:btu::f("but") ; Fixes 1 word ; Not just replacing "btu", as that is a unit of heat.
:B0X?C:hc::f("ch") ; Fixes 446 words ; :C: so not to break THC or LHC
:B0X?C:itn::f("ith") ; Fixes 70 words, Case sensitive, to not misspell ITN (Independent Television News) 
:B0XC*:i'd::f("I'd")
:B0XC:ASS::f("ADD") ; Case-sensitive to fix acronym, but not word.
:B0XC:Im::f("I'm") ; Fixes 1 word
:B0XC:copt::f("copy") ; Fixes 1 word, Case-sensitive, to not misspell Copt, An ancient Egyptian descendent.
:B0XC:i::f("I") ; Fixes 1 word 
:B0XC:may of::f("may have") ; Fixes 1 word
:B0XC:nad::f("and") ; Fixes 1 word, Case-sensitive to not misspell NAD (A coenzyme present in most living cells)
:B0XC:tou::f("you") ; Fixes 1 word Case sensitive because 'Time Of Use' acronym.
; ===== End of Main List ==========================
;------------------------------------------------------------------------------
; Accented English words, from, amongst others,
; http://en.wikipedia.org/wiki/List_of_English_words_with_diacritics
; Most of the definitions are from https://www.easydefine.com/ or from the WordWeb application.
;------------------------------------------------------------------------------
:*:angstrom::Ångström ; noun a metric unit of length equal to one ten billionth of a meter (or 0.0001 micron); used to specify wavelengths of electromagnetic radiation
:*:anime::animé ; noun any of various resins or oleoresins; a hard copal derived from an African tree
:*:apertif::apértif ; noun an alcoholic drink that is taken as an appetizer before a meal
:*:applique::appliqué ; noun a decorative design made of one material sewn over another; verb sew on as a decoration
:*:boite::boîte ; French: "Box."  a small restaurant or nightclub.
:*:canape::canapé  ; noun an appetizer consisting usually of a thin slice of bread or toast spread with caviar or cheese or other savory food
:*:celebre::célèbre ; Cause célèbre An incident that attracts great public attention.
:*:chaine::chaîné ; / (ballet) noun A series of small fast turns, often with the arms extended, used to cross a floor or stage.
:*:chateau::château ; noun an impressive country house (or castle) in France
:*:cinema verite::cinéma vérité ; noun a movie that shows ordinary people in actual activities without being controlled by a director
:*:cliche::cliché ; noun a trite or obvious remark; clichéd adj. repeated regularly without thought or originality
:*:communique::communiqué ; noun an official report (usually sent in haste)
:*:confrere::confrère ; noun a person who is member of your class or profession
:*:consomme::consommé ; noun clear soup usually of beef or veal or chicken
:*:cortege::cortège ; noun the group following and attending to some important person; a funeral procession
:*:coulee::coulée ; A stream of lava.  A deep gulch or ravine, frequently dry in summer.
:*:coup d'etat::coup d'état ; noun a sudden and decisive change of government illegally or by force
:*:coup de grace::coup de grâce ; noun the blow that kills (usually mercifully)
:*:coup de tat::coup d'état ; noun a sudden and decisive change of government illegally or by force
:*:creche::crèche ; noun a hospital where foundlings (infant children of unknown parents) are taken in and cared for; a representation of Christ's nativity in the stable at Bethlehem
:*:creme caramel::crème caramel ; noun baked custard topped with caramel
:*:crepe::crêpe ; noun a soft thin light fabric with a crinkled surface; paper with a crinkled texture; usually colored and used for decorations; small very thin pancake; verb cover or drape with crape
:*:crouton::croûton ; noun a small piece of toasted or fried bread; served in soup or salads
:*:dais::daïs ; noun a platform raised above the surrounding level to give prominence to the person on it
:*:debacle::débâcle ; noun a sudden and violent collapse; flooding caused by a tumultuous breakup of ice in a river during the spring or summer; a sound defeat
:*:debutante::débutant ; noun a sudden and violent collapse; flooding caused by a tumultuous breakup of ice in a river during the spring or summer; a sound defeat
:*:decor::décor ; noun decoration consisting of the layout and furnishings of a livable interior
:*:derriere::derrière ; noun the fleshy part of the human body that you sit on
:*:discotheque::discothèque ; noun a public dance hall for dancing to recorded popular music
:*:divorcee::divorcée ; noun a divorced woman or a woman who is separated from her husband
:*:doppelganger::doppelgänger ; noun a ghostly double of a living person that haunts its living counterpart
:*:eclair::éclair ; noun oblong cream puff
:*:emigre::émigré ; noun someone who leaves one country to settle in another
:*:entree::entrée ; noun the act of entering; the right to enter; the principal dish of a meal; something that provides access (to get in or get out)
:*:epee::épée ; noun a fencing sword similar to a foil but with a heavier blade
:*:facade::façade ; noun the face or front of a building; a showy misrepresentation intended to conceal something unpleasant
:*:fete::fête ; noun an elaborate party (often outdoors); an organized series of acts and performances (usually in one place); verb have a celebration
:*:fiance::fiancé ; noun a man who is engaged to be married. fiancee ; noun a woman who is engaged to be married
:*:flambe::flambé ; verb pour liquor over and ignite (a dish)
:*:frappe::frappé ; noun thick milkshake containing ice cream; liqueur poured over shaved ice; a frozen dessert with fruit flavoring (especially one containing no milk)
:*:fraulein::fräulein ; noun a German courtesy title or form of address for an unmarried woman
:*:garcon::garçon ; A waiter, esp. at a French restaurant
:*:gateau::gâteau ; noun any of various rich and elaborate cakes
:*:habitue::habitué ; noun a regular patron
:*:jalapeno::jalapeño ; noun hot green or red pepper of southwestern United States and Mexico; plant bearing very hot and finely tapering long peppers; usually red
:*:matinee::matinée ; noun a theatrical performance held during the daytime (especially in the afternoon)
:*:melee::mêlée ; noun a noisy riotous fight
:*:moire::moiré ; A textile technique that creates a wavy or "watered" effect in fabric.
:*:naif::naïf ; adj. marked by or showing unaffected simplicity and lack of guile or worldly experience; noun a naive or inexperienced person
:*:negligee::negligée ; noun a loose dressing gown for women
:*:noel::Noël ; French:  Christmas.
:*:ombre::ombré ;  (literally "shaded" in French) is the blending of one color hue to another.  A card game.
:*:pina colada::Piña Colada ; noun a mixed drink made of pineapple juice and coconut cream and rum
:*:pinata::piñata ; noun plaything consisting of a container filled with toys and candy; suspended from a height for blindfolded children to break with sticks
; :*:pinon::piñon ; noun any of several low-growing pines of western North America ; commented out: Is nullified by :*?:pinon::pion
:*:protege::protégé ; noun a person who receives support and protection from an influential patron who furthers the protege's career.  protegee ; noun a woman protege
:*:puree::purée ; noun food prepared by cooking and straining or processed in a blender; verb rub through a strainer or process in an electric blender
:*:saute::sauté ; adj. fried quickly in a little fat; noun a dish of sauteed food; verb fry briefly over high heat
:*:seance::séance ; noun a meeting of spiritualists
:*:senor::señor ; noun a Spanish title or form of address for a man; similar to the English `Mr' or `sir'. senora/señorita ; noun a Spanish title or form of address for a married woman; similar to the English `Mrs' or `madam'
:*:smorgasbord::smörgåsbord ; noun served as a buffet meal; a collection containing a variety of sorts of things
:*:soiree::soirée ; noun a party of people assembled in the evening (usually at a private house)
:*:souffle::soufflé ; noun light fluffy dish of egg yolks and stiffly beaten egg whites mixed with e.g. cheese or fish or fruit
:*:soupcon::soupçon ; noun a slight but appreciable addition
:*:tete-a-tete::tête-à-tête ; adj. involving two persons; intimately private; noun a private conversation between two people; small sofa that seats two people
::Bjorn::Bjørn ; An old norse name.  Means "Bear."
::Fohn wind::Föhn wind ; A type of dry, relatively warm, downslope wind that occurs in the lee (downwind side) of a mountain range.
::Quebecois::Québécois ; adj. of or relating to Quebec
::a bas::à bas ; French: Down with -- To the bottom.  A type of clothing.
::a la::à la ; In the manner of...
::aesop::Æsop ; noun Greek author of fables (circa 620-560 BC)
::ancien regime::Ancien Régime ; noun a political and social system that no longer governs (especially the system that existed in France before the French Revolution)
::ao dai::ào dái  ; noun the traditional dress of Vietnamese women consisting of a tunic with long sleeves and panels front and back; the tunic is worn over trousers
::apres::après ; French:  Too late.  After the event.
::arete::arête ; noun a sharp narrow ridge found in rugged mountains
::attache::attaché ; noun a specialist assigned to the staff of a diplomatic mission; a shallow and rectangular briefcase
::auto-da-fe::auto-da-fé ; noun the burning to death of heretics (as during the Spanish Inquisition)
::belle epoque::belle époque ; French: Fine period.   noun the period of settled and comfortable life preceding World War I
::bete noire::bête noire ; noun a detested person
::betise::bêtise ; noun a stupid mistake
::blase::blasé ; adj. nonchalantly unconcerned; uninterested because of frequent exposure or indulgence; very sophisticated especially because of surfeit; versed in the ways of the world
::boutonniere::boutonnière ; noun a flower that is worn in a buttonhole.
::champs-elysees::Champs-Élysées ; noun a major avenue in Paris famous for elegant shops and cafes
::charge d'affaires::chargé d'affaires ; noun the official temporarily in charge of a diplomatic mission in the absence of the ambassador
::cinemas verite::cinémas vérit ; noun a movie that shows ordinary people in actual activities without being controlled by a directoré
::cloisonne::cloisonné ; adj. (for metals) having areas separated by metal and filled with colored enamel and fired; noun enamelware in which colored areas are separated by thin metal strips
::creme brulee::crème brûlée ; noun custard sprinkled with sugar and broiled
::creme de cacao::crème de cacao ; noun sweet liqueur flavored with vanilla and cacao beans
::creme de menthe::crème de menthe ; noun sweet green or white mint-flavored liqueur
::creusa::Creüsa ; In Greek mythology, Creusa was the daughter of Priam and Hecuba.
::crudites::crudités ; noun raw vegetables cut into bite-sized strips and served with a dip
::curacao::curaçao ; noun flavored with sour orange peel; a popular island resort in the Netherlands Antilles
::declasse::déclassé ; Fallen or lowered in class, rank, or social position; lacking high station or birth; of inferior status
::decolletage::décolletage ; noun a low-cut neckline on a woman's dress
::decoupage::découpage ; noun the art of decorating a surface with shapes or pictures and then coating it with vanish or lacquer; art produced by decorating a surface with cutouts and then coating it with several layers of varnish or lacquer
::degage::dégagé ; adj. showing lack of emotional involvement; free and relaxed in manner
::deja vu::déjà vu ; noun the experience of thinking that a new situation had occurred before
::demode::démodé ; adj. out of fashion
::denoument::dénoument ; Narrative structure.  (Not in most dictionaries)
::derailleur::dérailleur ; (cycling) the mechanism on a bicycle used to move the chain from one sprocket (gear) to another
::deshabille::déshabillé ; noun the state of being carelessly or partially dressed
::detente::détente ; noun the easing of tensions or strained relations (especially between nations)
::diamante::diamanté ; noun adornment consisting of a small piece of shiny material used to decorate clothing
::eclat::éclat ; noun brilliant or conspicuous success or effect; ceremonial elegance and splendor; enthusiastic approval
::el nino::El Niño ; noun the Christ child; (oceanography) a warm ocean current that flows along the equator from the date line and south off the coast of Ecuador at Christmas time
::elan::élan ; noun enthusiastic and assured vigor and liveliness; distinctive and stylish elegance; a feeling of strong eagerness (usually in favor of a person or cause)
::entrecote::entrecôte ; Cut of meat taken from between the ribs
::entrepot::entrepôt ; noun a port where merchandise can be imported and then exported without paying import duties; a depository for goods
::etouffee::étouffée ; A Cajun shellfish dish.
::faience::faïence ; noun an elaborate party (often outdoors); an organized series of acts and performances (usually in one place); verb have a celebration
::filmjolk::filmjölk ; Nordic milk product.
::fin de siecle::fin de siècle ; adj. relating to or characteristic of the end of a century (especially the end of the 19th century)
::fleche::flèche ; a type of church spire; a team cycling competition; an aggressive offensive fencing technique; a defensive fortification; ships of the Royal Navy
::folie a deux::folie à deux ; noun the simultaneous occurrence of symptoms of a mental disorder (as delusions) in two persons who are closely related (as siblings or man and wife)
::folies a deux::folies à deux
::fouette::fouetté ; From Ballet: The working leg is extended and whipped around
::gardai::gardaí ; Policeman or policewoman
::gemutlichkeit::gemütlichkeit ; Friendliness.
::gewurztraminer::Gewürztraminer ; An aromatic white wine grape variety that grows best in cooler climates
::glace::glacé ; adj. (used especially of fruits) preserved by coating with or allowing to absorb sugar
::glogg::glögg ; noun Scandinavian punch made of claret and aquavit with spices and raisins and orange peel and sugar
::gotterdammerung::Götterdämmerung ; noun myth about the ultimate destruction of the gods in a battle with evil
::grafenberg spot::Gräfenberg spot ;  An erogenous area of the vagina.
::ingenue::ingénue ; noun an actress who specializes in playing the role of an artless innocent young girl
::jager::jäger ; A German or Austrian hunter, rifleman, or sharpshooter
::jardiniere::jardinière ; A preparation of mixed vegetables stewed in a sauce.  An arrangement of flowers.
::kaldolmar::kåldolmar ; Swedish cabbage rolls filled with rice and minced meat.
::krouzek::kroužek ; A ring-shaped diacritical mark (°), whose use is largely restricted to Å, å and U, u.
::kummel::kümmel ; noun liqueur flavored with caraway seed or cumin
::la nina::La Niña ; Spanish:'The Girl' is an oceanic and atmospheric phenomenon that is the colder counterpart of El Niño.
::landler::ländler ; noun a moderately slow Austrian country dance in triple time; involves spinning and clapping; music in triple time for dancing the landler
::langue d'oil::langue d'oïl ; noun medieval provincial dialects of French spoken in central and northern France
::litterateur::littérateur ; noun a writer of literary works
::lycee::lycée ; noun a school for students intermediate between elementary school and college; usually grades 9 to 12
::macedoine::macédoine ; noun mixed diced fruits or vegetables; hot or cold
::macrame::macramé ; noun a coarse lace; made by weaving and knotting cords; verb make knotted patterns
::maitre d'hotel::maître d'hôtel ; noun a dining-room attendant who is in charge of the waiters and the seating of customers
::malaguena::malagueña ; A Spanish dance or folk tune resembling the fandango.
::manege::manège ; The art of horsemanship or of training horses.
::manque::manqué ; adj. unfulfilled or frustrated in realizing an ambition
::materiel::matériel ; noun equipment and supplies of a military force
::melange::mélange ; noun a motley assortment of things
::menage a trois::ménage à trois ; noun household for three; an arrangement where a married couple and a lover of one of them live together while sharing sexual relations
::menages a trois::ménages à trois
::mesalliance::mésalliance ; noun a marriage with a person of inferior social status
::metier::métier ; noun an occupation for which you are especially well suited; an asset of special worth or utility
::minaudiere::minaudière ; A small, decorative handbag without handles or a strap.
::mobius::Möbius ; noun a continuous closed surface with only one side; formed from a rectangular strip by rotating one end 180 degrees and joining it with the other end
::motley crue::Mötley Crüe ; American heavy metal band formed in Hollywood, California in 1981.
::motorhead::Motörhead ; English rock band formed in London in 1975.
::naive::naïve ; adj. inexperienced; marked by or showing unaffected simplicity and lack of guile or worldly experience
::naiver::naïver ; See above.
::naives::naïves ; See above.
::naivete::naïveté ; See above.
::nee::née ; adj. (meaning literally `born') used to indicate the maiden or family name of a married woman
::neufchatel::Neufchâtel ; a cheese
::nez perce::Nez Percé ; noun the Shahaptian language spoken by the Nez Perce; a member of a tribe of the Shahaptian people living on the pacific coast
::número uno::número uno ; Number one
::objet trouve::objet trouvé ; An object found or picked up at random and considered aesthetically pleasing.
::objets trouve::objets trouvé ; See above.
::omerta::omertà ; noun a code of silence practiced by the Mafia; a refusal to give evidence to the police about criminal activities
::opera bouffe::opéra bouffe ; noun opera with a happy ending and in which some of the text is spoken
::opera comique::opéra comique ; noun opera with a happy ending and in which some of the text is spoken
::operas bouffe::opéras bouffe ; see above.
::operas comique::opéras comique ; See above.
::outre::outré ; adj. conspicuously or grossly unconventional or unusual
::papier-mache::papier-mâché ; noun a substance made from paper pulp that can be molded when wet and painted when dry
::passe::passé ; adj. out of fashion
::piece de resistance::pièce de résistance ; noun the most important dish of a meal; the outstanding item (the prize piece or main exhibit) in a collection
::pied-a-terre::pied-à-terre ; noun lodging for occasional or secondary use
::pique::piqué ; noun tightly woven fabric with raised cords; a sudden outburst of anger; verb cause to feel resentment or indignation
::piqued::piquéd ;noun Animosity or ill-feeling, Offence taken. transitive verb To wound the pride of To arouse, stir, provoke.
::pirana::piraña ; noun small voraciously carnivorous freshwater fishes of South America that attack and destroy living animals
::più::più ; Move.
::plie::plié ; A movement in ballet, in which the knees are bent while the body remains upright
::plisse::plissé ; (Of a fabric) chemically treated to produce a shirred or puckered effect.
::polsa::pölsa ; A traditional northern Swedish dish which has been compared to hash
::precis::précis ; noun a sketchy summary of the main points of an argument or theory; verb make a summary (of)
::pret-a-porter::prêt-à-porter ; Ready-to-wear / Off-the-rack.
::raison d'etre::raison d'être ; noun the purpose that justifies a thing's existence; reason for being
::recherche::recherché ; adj. lavishly elegant and refined
::retrousse::retroussé ; adjective (of a person's nose) turned up at the tip in an attractive way.
::risque::risqué ; adjective slightly indecent and liable to shock, especially by being sexually suggestive.
::riviere::rivière ; noun a necklace of gems that increase in size toward a large central stone, typically consisting of more than one string.
::roman a clef::roman à clef ; noun a novel in which actual persons and events are disguised as fictional characters
::roue::roué ; noun a dissolute man in fashionable society
::sinn fein::Sinn Féin ; noun an Irish republican political movement founded in 1905 to promote independence from England
::smorgastarta::smörgåstårta ; "sandwich-cake" or "sandwich-torte" is a dish of Swedish origin
::soigne::soigné ; adj. polished and well-groomed; showing sophisticated elegance
::sprachgefühl::sprachgefuhl ; The essential character of a language.
::surstromming::surströmming ; Lightly salted fermented Baltic Sea herring.
::touche::touché ; Acknowledgement of a hit in fencing or a point made at one's expense.
::tourtiere::tourtière ; A meat pie that is usually eaten at Christmas in Québec
::ventre a terre::ventre à terre ; (French) At high speed (literally, belly to the ground.)
::vicuna::vicuña ; noun small wild cud-chewing Andean animal similar to the guanaco but smaller; valued for its fleecy undercoat; a soft wool fabric made from the fleece of the vicuna; the wool of the vicuna
::vin rose::vin rosé ; White wine.
::vins rose::vins rosé ; See above
::vis a vis::vis à vis ; adv. face-to-face
::vis-a-vis::vis-à-vis ; See above
::voila::voilà ; Behold.  There you are.

;-------------------------------------------------------------------------------
;  Capitalize dates ; Doesn't include "may" or "march."
;-------------------------------------------------------------------------------

:C:april::April
:C:august::August
:C:december::December
:C:february::February
:C:friday::Friday
:C:january::January
:C:july::July
:C:june::June
:C:monday::Monday
:C:november::November
:C:october::October
:C:saturday::Saturday
:C:september::September
:C:sunday::Sunday
:C:thursday::Thursday
:C:tuesday::Tuesday
:C:wednesday::Wednesday

; Just some alphabetical lists of things.
::;fruits::Apple`nBanana`nCarrot`nDate`nEggplant`nFig`nGrape`nHoneydew`nIceberg lettuce`nJalapeno`nKiwi`nLemon`nMango`nNectarine`nOrange`nPapaya`nQuince`nRadish`nStrawberry`nTomato`nUgli fruit`nVanilla bean`nWatermelon`nXigua (Chinese watermelon)`nYellow pepper`nZucchini
::;animals::Aardvark`nButterfly`nCheetah`nDolphin`nElephant`nFrog`nGiraffe`nHippo`nIguana`nJaguar`nKangaroo`nLion`nMonkey`nNarwhal`nOwl`nPenguin`nQuail`nRabbit`nSnake`nTiger`nUmbrellabird`nVulture`nWolf`nX-ray fish`nYak`nZebra
::;colors::Amber`nBlue`nCrimson`nDenim`nEmerald`nFuchsia`nGold`nHarlequin`nIndigo`nJade`nKhaki`nLavender`nMagenta`nNavy`nOlive`nPink`nQuartz`nRed`nScarlet`nTurquoise`nUltramarine`nViolet`nWhite`nXanadu`nYellow`nZaffre
::;colorhex::Red := {#}FF0000`nOrange := {#}FF7F00`nYellow := {#}FFFF00`nGreen := {#}00FF00`nBlue := {#}0000FF`nIndigo := {#}4B0082`nViolet := {#}8F00FF
;################################################

;-------------------------------------------------------------------------------
; Anything below this point was added to the script by the user via the Win+H hotkey.
;-------------------------------------------------------------------------------


:B0X*?:ateng::f("ating") ; Fixes 1338 words 
