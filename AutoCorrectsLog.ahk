; ========== AUTO CORRECTION LOG and ANALYZER === Version 2-9-2024 =============
; Determines frequency of items in below list, then sorts by f.  
; Date not factored in sort. There's no hotkey, just run the script.  
; It reports the top X hotstrings that were immediately followed by 
; 'Backspace' (<<), and how many times they were used without backspacing (--)).
; Sort one or the other. Intended for use with kunkel321's 'AutoCorrect for v2.'
;===============================================================================
#SingleInstance
#Requires AutoHotkey v2+
^Esc::ExitApp ; Ctrl+Esc to Kill/End process, if you're tired of waiting... 
; Ctrl+C on MessageBox will send report to Clipboard.  
; Note: 1300 items takes about 1 second, but 10k lines takes 44 seconds. 2310 takes ~3.

;===============================================================================
getStartLine() ; Go get line number where hotstrings start, then come back...
SortByBS := 1 ; Set to 0 to sort by OK items. Set to 1 to sort by BackSpaced item count. 
ShowX := 40 ; Show top X results. 
;===============================================================================
AllStrs := FileRead(A_ScriptName) ; ahk file... Know thyself. 
TotalLines := StrSplit(AllStrs, "`n").Length ; Determines number of lines for Prog Bar range.
pg := Gui()
pg.Opt("-MinimizeBox +alwaysOnTop +Owner")
MyProgress := pg.Add("Progress", "w400 h30 cGreen Range0-" . TotalLines, "0")
reportType := "Top " ShowX (SortByBS? " backspaced autocorrects." : " kept autocorrects.")
pg.Title := reportType "  Percent complete: 0 %." ; Starting title (immediately gets updated below.)
pg.Show()

Loop parse AllStrs, "`n`r"
{	MyProgress.Value += 1
	; pg.Title := "Lines of file remaining: " (TotalLines - MyProgress.Value) "..." ; For progress bar.
	pg.Title := reportType "  Percent complete: " Round((MyProgress.Value/TotalLines)*100) "%." ; For progress bar.
	If A_Index < startLine || InStr(A_LoopField, "Cap ") ; Skip these.
		Continue
	okTally := 0, bsTally := 0
	oStr := SubStr(A_LoopField, 15) ; o is "outter loop"
	Loop parse AllStrs, "`n`r" {
		If A_Index < startLine || InStr(A_LoopField, "Cap ") ; Skip these.
			Continue
		iStr := SubStr(A_LoopField, 15) ; i is "inner loop"
		If iStr = oStr { 
			If SubStr(A_LoopField, 12, 2) = "--" ; "--" means the item was logged, and backspace was not pressed.
				okTally++
			If SubStr(A_LoopField, 12, 2) = "<<" ; "<<" means Backspace was pressed right after autocorrection.
				bsTally++
		}
	}
	If SortByBS = 1 
		Report .=  bsTally "<< and " okTally "-- for" ((bsTally>9 or okTally>9)? "oneTab":"twoTabs") oStr "`n"
	else 
		Report .=  okTally "-- and " bsTally "<< for" ((okTally>9 or bsTally>9)? "oneTab":"twoTabs") oStr "`n"
	AllStrs := strReplace(AllStrs, oStr, "Cap fix") ; Replace it with 'cap fix' so we don't keep finding it.
}

Report := Sort(Sort(Report, "/U"), "NR") ; U is 'remove duplicates.' NR is 'numeric' and 'reverse sort.'
For idx, item in strSplit(Report, "`n")
	If idx <= ShowX ; Only use first X lines.
		trunkReport .= item "`n"
	else break
msgTrunkReport := strReplace(strReplace(trunkReport, "oneTab", "`t"), "twoTabs", "`t") ; So right colomn lines up in msgboxes.
txtTrunkReport := strReplace(strReplace(trunkReport, "oneTab", "`t"), "twoTabs", "`t`t") ; So right colomn lines up in text editors.

pg.Destroy() ; Remove progress bar.
msgbox reportType "`n=====================`n" msgTrunkReport, "Autocorrect Report"
ExitApp ; Kill script when msgbox is closed. 
#HotIf WinActive("Autocorrect Report") ; Ctrl+C sends report to clipboard, but only if msgbox is active window. 
^c::A_Clipboard := reportType "`n=====================`n" txtTrunkReport
#HotIf

getStartLine(*) {
	Global startLine := A_LineNumber + 7
}
/* 
;=====================================================================
; Log of all autocorrects sent via f(unction), or Case Corrector. 
; YYYY-MM-DD date format. "<<" indicates that Backspace was pressed right after.

2023-11-11 << :?:realy::really
2023-11-11 -- Cap fix: COr
2023-11-11 << :?*:borrom::bottom
2023-11-11 -- Cap fix: WHa
2023-11-11 -- :?:;ll::'ll
2023-11-11 -- :?*:cuas::caus
2023-11-11 -- :?*:fucnt::funct
2023-11-11 -- Cap fix: THe
2023-11-11 << :?:herefor::herefore
2023-11-11 -- :*C:ime::imme
2023-11-11 << ::fo::of
2023-11-11 << :?*:pulare::pular
2023-11-11 -- Cap fix: ISo
2023-11-11 -- ::upto::up to
2023-11-12 -- :*:english::English <made case-sensitive>
2023-11-12 -- Cap fix: SIl
2023-11-12 -- :*:licence::license
2023-11-12 -- :*:tthe::the
2023-11-12 -- :*:puch::push
2023-11-12 << :?*:durring::during
2023-11-12 -- :?*:wierd::weird
2023-11-12 -- :*:excell::excel
2023-11-12 -- :?*:inng::ing
2023-11-12 -- :?*:occuran::occurren
2023-11-13 -- Cap fix: ELs
2023-11-13 -- :?*:cheif::chief
2023-11-13 -- Cap fix: THe
2023-11-13 -- Cap fix: FLu
2023-11-13 -- Cap fix: THe
2023-11-13 -- Cap fix: FOr
2023-11-13 -- Cap fix: THi
2023-11-13 -- Cap fix: TSt
2023-11-13 -- Cap fix: COu
2023-11-13 << :*:counr::countr
2023-11-13 -- :?*:durring::during
2023-11-13 -- ::upto::up to
2023-11-13 -- :?:occured::occurred
2023-11-13 -- :?*:durring::during
2023-11-13 -- :?*:durring::during
2023-11-13 -- Cap fix: THe
2023-11-13 -- Cap fix: THe
2023-11-13 -- :?:cually::cularly
2023-11-13 -- Cap fix: HSh
2023-11-13 -- Cap fix: IDi
2023-11-13 -- ::transfered::transferred
2023-11-13 -- :*:threee::three
2023-11-13 -- :?*:durring::during
2023-11-13 << ::whic::which <removed>
2023-11-13 << :?:realy::really
2023-11-13 -- Cap fix: DIe
2023-11-13 << :?*:iht::ith
2023-11-13 -- :?*:cogntivie::cognitive
2023-11-13 << :?:rthe::r the
2023-11-13 -- ::fo::of
2023-11-13 -- Cap fix: THa
2023-11-13 -- Cap fix: SOc
2023-11-13 -- Cap fix: THe
2023-11-13 -- Cap fix: COm
2023-11-13 -- :*:dissap::disap
2023-11-13 -- Cap fix: GLo
2023-11-13 -- Cap fix: COu
2023-11-13 -- Cap fix: COu
2023-11-14 -- Cap fix: WHi
2023-11-14 -- Cap fix: THe
2023-11-14 -- Cap fix: THe
2023-11-14 -- Cap fix: THe
2023-11-14 -- Cap fix: THe
2023-11-14 << :*:if is::it is
2023-11-14 -- :?*:extention::extension
2023-11-14 -- ::to pickup::to pick up
2023-11-14 -- :*:femail::female
2023-11-14 -- :*:lable::label
2023-11-14 << :?*:admited::admitted
2023-11-14 << :*:nver::never
2023-11-14 -- :?*:durring::during
2023-11-14 -- :?*:eild::ield
2023-11-14 << :*:escta::ecsta
2023-11-14 -- :?*:nclr::ncr
2023-11-14 -- :?*:durring::during
2023-11-14 -- :?*:durring::during
2023-11-14 << ::ther::there <removed>
2023-11-14 -- :?*:durring::during
2023-11-14 -- :*:puch::push
2023-11-14 -- :*:puch::push
2023-11-14 -- :*C:ime::imme
2023-11-14 -- Cap fix: SPe
2023-11-14 << :*:enought::enough
2023-11-14 -- ::affects of::effects of
2023-11-14 -- :?*:cogntivie::cognitive
2023-11-14 -- Cap fix: THe
2023-11-14 << :*:sould::should
2023-11-14 -- Cap fix: OTh
2023-11-15 -- Cap fix: FOl
2023-11-15 -- :*:puch::push
2023-11-15 -- :*C:ime::imme
2023-11-15 -- :?:iatly::iately
2023-11-15 -- :*:english::English <made case-sensitive>
2023-11-15 -- Cap fix: OTo
2023-11-15 -- Cap fix: AAn
2023-11-15 -- :?*:iblit::ibilit
2023-11-15 -- :?*:alowe::allowe
2023-11-15 -- :*:dont::don't
2023-11-15 -- :?:eamil::email
2023-11-15 -- :*:recie::recei
2023-11-15 << :*:tyo::to
2023-11-15 -- Cap fix: IEp
2023-11-15 -- :*:sumar::summar
2023-11-16 -- :?*:exsis::exis
2023-11-16 -- :*:lable::label
2023-11-16 << :*:wih::whi <removed>
2023-11-16 -- :?*:appol::apol
2023-11-16 -- :?*:reing::ring
2023-11-16 -- :*:Karent::Karen
2023-11-16 -- :?*:follwo::follow
2023-11-17 -- :*:english::English <made case-sensitive>
2023-11-17 -- Cap fix: WOr
2023-11-17 -- :?*:oulb::oubl
2023-11-17 << :*:a ab::an ab
2023-11-17 -- :?*:pld::ple
2023-11-17 -- Cap fix: TSo
2023-11-17 -- :*:amme::ame
2023-11-17 -- :?:atn::ant
2023-11-17 -- :*:puch::push
2023-11-17 << :*:puch::push
2023-11-17 << :?*:nght::ngth
2023-11-17 << :?*:opth::ophth
2023-11-17 -- :?*:appol::apol
2023-11-17 -- :*:reliz::realiz
2023-11-17 -- Cap fix: AWe
2023-11-17 -- :?*:tje::the
2023-11-17 << :*:femail::female
2023-11-17 -- :*:retrun::return
2023-11-17 -- :*:the follow up::the follow-up
2023-11-18 -- :?*:cuas::caus
2023-11-18 -- Cap fix: THe
2023-11-18 -- :?*:nervious::nervous
2023-11-18 << :?*:daty::day <removed>
2023-11-18 << :?*:availb::availab
2023-11-18 -- Cap fix: HTh
2023-11-18 -- :*:is were::is where
2023-11-18 -- :?*:scipt::script
2023-11-18 -- :*:if is::it is
2023-11-18 -- Cap fix: GLo
2023-11-19 -- :*:english::English <made case-sensitive>
2023-11-19 -- :*:retrun::return
2023-11-19 -- :?*:boxs::boxes
2023-11-19 -- Cap fix: SHo
2023-11-20 -- :?*:pld::ple
2023-11-20 -- Cap fix: ANd
2023-11-20 -- :*:amme::ame
2023-11-20 -- :?*:entatr::entar
2023-11-20 -- :*:excell::excel
2023-11-20 -- :*:excell::excel
2023-11-20 -- Cap fix: THe
2023-11-20 << :*:hge::he
2023-11-20 -- :?*:suffician::sufficien
2023-11-20 -- Cap fix: PSp
2023-11-20 -- Cap fix: WOr
2023-11-20 -- :?:ualy::ually
2023-11-20 -- Cap fix: FTh
2023-11-20 -- :?:fthe::f the
2023-11-20 -- :?*:cuas::caus
2023-11-20 -- :?*:oportun::opportun
2023-11-20 -- Cap fix: SKi
2023-11-20 -- :?*:supriz::surpris
2023-11-20 << :*:wih::whi <removed>
2023-11-20 -- :*:recie::recei
2023-11-20 -- :?*:tradion::tradition
2023-11-20 -- :?*:sourse::source
2023-11-20 << :*:recie::recei
2023-11-20 -- :*:futhe::furthe
2023-11-20 -- :?*:cogntivie::cognitive
2023-11-20 -- :?*:aiton::ation
2023-11-20 -- Cap fix: AS 
2023-11-20 << ::ther::there <removed>
2023-11-20 -- :?*:aggree::agree
2023-11-20 << :?*:juct::junct
2023-11-20 -- :?*:durring::during
2023-11-20 -- Cap fix: CCi
2023-11-20 -- Cap fix: THi
2023-11-20 << :?*:likl::likel
2023-11-20 << ::some one::someone
2023-11-20 -- :?*:durring::during
2023-11-20 -- :*:amme::ame
2023-11-20 << ::whic::which <removed>
2023-11-21 -- :*:english::English <made case-sensitive>
2023-11-21 -- Cap fix: IT 
2023-11-21 -- Cap fix: IT 
2023-11-21 -- Cap fix: AS 
2023-11-21 -- Cap fix: AS 
2023-11-21 -- Cap fix: WOr
2023-11-21 -- Cap fix: WIl
2023-11-21 -- :?*:mtion::mation
2023-11-21 -- :*:reliz::realiz
2023-11-21 -- :?*:surpriz::surpris
2023-11-22 -- :*:healthercare::healthcare
2023-11-22 -- :*:to login::to log in
2023-11-22 -- :*:healther::health
2023-11-22 -- :?*:aggree::agree
2023-11-22 -- Cap fix: THe
2023-11-22 -- :*:superce::superse
2023-11-22 -- Cap fix: THe
2023-11-22 -- :?*:responc::respons
2023-11-22 -- :?*:surpriz::surpris
2023-11-22 -- Cap fix: THe
2023-11-22 -- Cap fix: THe
2023-11-22 << :?*:cuas::caus
2023-11-22 -- Cap fix: LIn
2023-11-22 -- :?*:cuas::caus
2023-11-23 -- :*:english::English <made case-sensitive>
2023-11-23 << :?*:allto::alto
2023-11-23 -- :?*:untion::unction
2023-11-23 -- :*:retrun::return
2023-11-23 -- :*:recie::recei
2023-11-23 -- Cap fix: FOm
2023-11-23 -- Cap fix: FOr
2023-11-23 -- :*:retrun::return
2023-11-23 -- :*:with it's::with its
2023-11-23 -- :*:explainat::explanat
2023-11-23 -- :*:lable::label
2023-11-23 -- Cap fix: FOr
2023-11-23 -- Cap fix: FOr
2023-11-23 -- :?*:nght::ngth
2023-11-23 -- :?*:quesion::question
2023-11-23 -- Cap fix: FOr
2023-11-23 -- :*:friut::fruit
2023-11-23 -- Cap fix: FOr
2023-11-23 -- :*:wih::whi <removed>
2023-11-23 -- Cap fix: FOr
2023-11-23 -- Cap fix: THi
2023-11-23 -- :?:efull::eful
2023-11-23 -- Cap fix: FOr
2023-11-23 << :?*:mtion::mation
2023-11-23 -- Cap fix: FOr
2023-11-23 -- Cap fix: FOr
2023-11-23 << :*:prepat::preparat
2023-11-23 << :?*:wirt::writ
2023-11-23 -- :?*:occuran::occurren
2023-11-23 -- Cap fix: FOr
2023-11-23 -- Cap fix: THe
2023-11-23 -- :*:sould::should
2023-11-24 -- Cap fix: THa
2023-11-24 -- :*:have went::have gone
2023-11-24 -- Cap fix: FOr
2023-11-24 -- Cap fix: FOr
2023-11-24 -- Cap fix: FOr
2023-11-24 -- Cap fix: FOr
2023-11-24 -- Cap fix: FOr
2023-11-24 << :*:puch::push
2023-11-25 -- :*:english::English <made case-sensitive>
2023-11-25 -- :?*:deffin::defin
2023-11-25 -- :*:achei::achie
2023-11-25 -- :?*:aggree::agree
2023-11-25 -- Cap fix: CFo
2023-11-25 << :?*:exampt::exempt
2023-11-25 << :?*:exsis::exis
2023-11-25 -- Cap fix: MEn
2023-11-25 -- Cap fix: FOr
2023-11-26 -- Cap fix: WIn
2023-11-26 -- :*:english::English <made case-sensitive>
2023-11-26 << :?*:tje::the
2023-11-26 << :*:wih::whi <removed>
2023-11-26 -- :?*:grama::gramma
2023-11-26 -- :?*:udnet::udent
2023-11-26 -- :*:hier::heir
2023-11-26 -- :?*:segement::segment
2023-11-26 -- Cap fix: WIn
2023-11-27 << :*:if is::it is
2023-11-27 -- Cap fix: AS 
2023-11-27 -- :?*:paralel::parallel
2023-11-27 -- :?*:copty::copy
2023-11-27 -- :*:begining::beginning
2023-11-27 << :?*:responc::respons
2023-11-27 << :?*:eccu::ecu
2023-11-27 -- :*:use to::used to
2023-11-27 << :?*:attemt::attempt
2023-11-27 -- ::t he::the
2023-11-27 -- :?*:cogntivie::cognitive
2023-11-27 -- Cap fix: THi
2023-11-27 -- :?*:nsern::ncern
2023-11-27 -- :*:wih::whi <removed>
2023-11-27 -- Cap fix: SDt
2023-11-27 -- :?:ualy::ually
2023-11-27 -- :?*:wierd::weird
2023-11-27 -- :?*:eild::ield
2023-11-27 << ::wat::way <removed>
2023-11-27 -- :?*:couraing::couraging
2023-11-27 -- :?*:sourse::source
2023-11-27 -- :?*:rixon::rison
2023-11-27 -- :?*:rtnat::rtant
2023-11-27 -- :?:itiy::ity
2023-11-27 -- :*:gaol::goal
2023-11-27 -- :*:infact::in fact
2023-11-27 -- :*:bve::be
2023-11-27 -- Cap fix: WEe
2023-11-27 -- Cap fix: AS 
2023-11-27 -- Cap fix: IHe
2023-11-27 << :?:;ll::'ll
2023-11-27 -- :*:Karent::Karen
2023-11-27 -- Cap fix: IAs
2023-11-27 -- Cap fix: DId
2023-11-28 -- Cap fix: ASe
2023-11-28 -- Cap fix: TEa
2023-11-28 -- :?*:cogntivie::cognitive
2023-11-28 -- ::aslo::also
2023-11-28 -- :*:safegard::safeguard
2023-11-28 -- :*:cansent::consent 
2023-11-28 -- Cap fix: THe
2023-11-28 -- :*:allready::already
2023-11-28 -- :?:comming::coming
2023-11-28 -- Cap fix: EMm
2023-11-28 -- :*:eyt::yet
2023-11-28 -- :*:eyt::yet
2023-11-28 -- :*:eyt::yet
2023-11-28 << ::whic::which <removed>
2023-11-28 -- :*:potatos::potatoes
2023-11-28 -- :*:lable::label
2023-11-28 << ::fro::for
2023-11-28 -- Cap fix: DOe
2023-11-28 -- Cap fix: THo
2023-11-28 -- Cap fix: ONe
2023-11-28 -- Cap fix: WIl
2023-11-28 -- :?*:pld::ple
2023-11-28 -- :?*:spyc::psyc
2023-11-29 << :*:a el::an el
2023-11-29 -- :?*:exsis::exis
2023-11-29 << :*:your a::you're a
2023-11-29 -- :?*:ssition::sition
2023-11-29 -- Cap fix: ALs
2023-11-29 -- :?*:dimention::dimension
2023-11-29 -- :?*:wierd::weird
2023-11-29 -- Cap fix: RSp
2023-11-29 -- Cap fix: ENt
2023-11-29 -- :?*:mision::mission
2023-11-29 -- :?*:efered::eferred
2023-11-29 -- Cap fix: TSh
2023-11-29 -- Cap fix: THe
2023-11-29 -- :?*:voiu::viou
2023-11-29 << :?*:tionne::tione
2023-11-29 -- :*:retrun::return
2023-11-29 -- :?*:nsern::ncern
2023-11-29 -- Cap fix: COd
2023-11-29 -- Cap fix: TRa
2023-11-29 -- Cap fix: THe
2023-11-29 -- :?:comming::coming
2023-11-29 -- Cap fix: BUt
2023-11-29 -- :?*:ssition::sition
2023-11-29 -- Cap fix: TO 
2023-11-29 -- Cap fix: THe
2023-11-29 -- :?*:efern::eferen
2023-11-29 -- Cap fix: THa
2023-11-29 -- Cap fix: THi
2023-11-29 -- Cap fix: SHi
2023-11-29 -- Cap fix: RIc
2023-11-29 -- Cap fix: THi
2023-11-29 -- Cap fix: CHe
2023-11-29 << :*:andd::and
2023-11-29 -- Cap fix: DSe
2023-11-30 -- :?:ywat::yway
2023-11-30 -- Cap fix: SOm
2023-11-30 -- :?*:osible::osable
2023-11-30 << :*:wih::whi <removed>
2023-11-30 -- Cap fix: VSc
2023-11-30 << :*:puch::push
2023-11-30 -- :?*:casue::cause
2023-11-30 -- :C:Im::I'm
2023-11-30 -- :?*:exsis::exis
2023-11-30 -- Cap fix: FOl
2023-11-30 -- Cap fix: COg
2023-11-30 << :*:wih::whi <removed>
2023-11-30 << :?*C:mnt::ment
2023-11-30 << :*C:ime::imme
2023-11-30 -- :*:Janurary::January
2023-11-30 -- :*:Janurary::January
2023-11-30 -- :?*:daty::day <removed>
2023-12-01 -- :*:english::English <made case-sensitive>
2023-12-01 -- :*:amme::ame
2023-12-01 -- Cap fix: THe
2023-12-01 -- Cap fix: OUr
2023-12-01 -- :?*:nsern::ncern
2023-12-01 -- Cap fix: THe
2023-12-01 -- Cap fix: THe
2023-12-01 -- :?*:durring::during
2023-12-01 << :?C:hc::ch
2023-12-01 -- :?*:apropri::appropri
2023-12-01 -- :*:amme::ame
2023-12-01 -- :?*:boxs::boxes
2023-12-01 -- :?*:occassi::occasi
2023-12-01 -- :?*:accro::acro
2023-12-01 -- :?*:cogntivie::cognitive
2023-12-01 -- :?*:comun::commun
2023-12-01 << :*:wih::whi <removed>
2023-12-01 -- :?*:cogntivie::cognitive
2023-12-01 -- Cap fix: LSt
2023-12-01 -- Cap fix: THe
2023-12-01 << :?*:useing::using
2023-12-01 -- Cap fix: GLo
2023-12-01 -- Cap fix: VWi
2023-12-01 -- :*:your a::you're a
2023-12-01 -- :?*:asr::ase
2023-12-02 -- Cap fix: THe
2023-12-02 -- :*:thats::that's
2023-12-02 -- Cap fix: THe
2023-12-02 -- Cap fix: CLi
2023-12-02 << ::becaus::because
2023-12-02 -- :?*:durring::during
2023-12-02 -- Cap fix: THe
2023-12-02 -- Cap fix: CLi
2023-12-02 -- :*:whould::would
2023-12-02 -- :*:recie::recei
2023-12-02 << :?*:tatn::tant
2023-12-02 << :?*:daty::day <removed>
2023-12-02 -- :*:tyo::to
2023-12-02 << :?*:pld::ple
2023-12-02 -- :*:alse::else
2023-12-02 -- :*:senc::sens
2023-12-02 -- ::ect::etc
2023-12-02 -- :*:recie::recei
2023-12-02 -- :*:recie::recei
2023-12-02 << :*:with in::within <fixed>
2023-12-02 -- :?*:efering::eferring
2023-12-02 -- :*:recie::recei
2023-12-02 -- Cap fix: WIt
2023-12-02 -- Cap fix: IWi
2023-12-02 -- Cap fix: WIn
2023-12-02 << :*:quess::guess
2023-12-02 -- :?*:casue::cause
2023-12-02 -- :?*:grama::gramma
2023-12-02 -- :?*:releven::relevan
2023-12-02 -- :*:recie::recei
2023-12-02 -- :?*:grama::gramma
2023-12-03 -- :*:english::English <made case-sensitive>
2023-12-03 -- Cap fix: UIs
2023-12-03 -- Cap fix: THe
2023-12-04 -- :*:english::English <made case-sensitive>
2023-12-04 -- :?*:aggree::agree
2023-12-04 -- Cap fix: HOm
2023-12-04 -- :*:dissap::disap
2023-12-04 -- Cap fix: ITh
2023-12-04 -- :?:kn::nk
2023-12-04 -- Cap fix: HOm
2023-12-04 -- Cap fix: THe
2023-12-04 -- Cap fix: TRe
2023-12-04 -- :?*:accro::acro
2023-12-04 -- :?*:cuas::caus
2023-12-04 -- :?*:nlcu::nclu
2023-12-04 -- :?*:ytou::you
2023-12-04 -- :?*:accro::acro
2023-12-04 -- :?*:couraing::couraging
2023-12-04 -- :?*:obelm::oblem
2023-12-04 -- Cap fix: SKi
2023-12-04 << :?*:behaio::behavio
2023-12-04 -- :*:amme::ame
2023-12-04 -- Cap fix: NKn
2023-12-04 -- :?*:durring::during
2023-12-04 << :*:lias::liais
2023-12-04 -- :?*:durring::during
2023-12-04 -- :?*:efered::eferred
2023-12-04 -- :*:tiem::time
2023-12-04 -- Cap fix: HWh
2023-12-05 -- :*:english::English <made case-sensitive>
2023-12-05 -- :?*C:mnt::ment
2023-12-05 -- :?:ngment::ngement
2023-12-05 -- :?*:durring::during
2023-12-05 -- :?*:paralel::parallel
2023-12-05 -- :*:sould::should
2023-12-05 -- :?*:accro::acro
2023-12-05 -- :?*:lcud::clud
2023-12-05 -- Cap fix: THe
2023-12-05 -- :*:there last::their last
2023-12-05 -- Cap fix: GLo
2023-12-05 -- :*:lable::label
2023-12-05 -- :?*:exsis::exis
2023-12-05 -- ::tou::you
2023-12-05 -- :?:occure::occur
2023-12-05 << :?*:nsern::ncern
2023-12-06 -- :*:english::English <made case-sensitive>
2023-12-06 -- :*:Karent::Karen
2023-12-06 -- Cap fix: WIt
2023-12-06 << :?*:grama::gramma
2023-12-06 << :?:comming::coming
2023-12-06 -- :?:itiy::ity
2023-12-06 -- :C:nad::and
2023-12-06 -- Cap fix: TWh
2023-12-06 -- :?*:exsis::exis
2023-12-06 -- :*:amme::ame
2023-12-06 -- Cap fix: THe
2023-12-06 -- :*:amme::ame
2023-12-06 << :*:alse::else
2023-12-06 << :*C:ime::imme
2023-12-06 -- :*:i"m::I'm
2023-12-06 -- :*C:ime::imme
2023-12-06 << :*:andd::and
2023-12-06 -- Cap fix: IWh
2023-12-06 -- Cap fix: HCa
2023-12-06 -- :*:i"m::I'm
2023-12-07 -- :*:thsi::this
2023-12-07 -- Cap fix: SPa
2023-12-07 -- :*:hellow::hello
2023-12-07 << :*:did attempted::did attempt
2023-12-07 -- Cap fix: WOr
2023-12-07 << :*:senc::sens
2023-12-07 -- :?:lyu::ly
2023-12-07 -- :?:occured::occurred
2023-12-07 << :*:thats::that's
2023-12-07 -- :?*:cuas::caus
2023-12-07 -- :?*:morot::motor
2023-12-07 << :*:tyo::to
2023-12-07 -- :?*:ytou::you
2023-12-07 -- Cap fix: WHa
2023-12-07 -- ::do to::due to
2023-12-08 -- Cap fix: ANo
2023-12-08 -- :*:english::English <made case-sensitive>
2023-12-08 -- :?*:cirp::crip
2023-12-08 -- :*:hellow::hello
2023-12-08 -- :*:oposi::opposi
2023-12-08 -- :?*:dminst::dminist
2023-12-08 << :?*:fisi::fissi
2023-12-08 -- :?*:durring::during
2023-12-08 -- :?*:focuss::focus
2023-12-08 -- :?*:stong::strong
2023-12-08 -- :*:counr::countr
2023-12-08 -- Cap fix: COl
2023-12-08 -- :?*:cogntivie::cognitive
2023-12-08 -- :?:itiy::ity
2023-12-08 -- :?*:cogntivie::cognitive
2023-12-08 -- :?*:paralel::parallel
2023-12-08 -- Cap fix: IEp
2023-12-08 -- :?*:nsern::ncern
2023-12-08 << :?*:whant::want
2023-12-08 -- ::apon::upon
2023-12-08 -- Cap fix: STe
2023-12-08 -- Cap fix: CLi
2023-12-09 -- Cap fix: TOt
2023-12-09 -- Cap fix: ODo
2023-12-09 -- :?*C:mnt::ment
2023-12-09 -- :?*C:mnt::ment
2023-12-09 -- :?*C:mnt::ment
2023-12-09 -- :?*C:mnt::ment
2023-12-09 -- :*:lable::label
2023-12-10 -- :*:english::English <made case-sensitive>
2023-12-11 -- :*:english::English <made case-sensitive>
2023-12-11 -- :?:sthe::s the
2023-12-11 -- :*:aquir::acquir
2023-12-11 -- :?*:efered::eferred
2023-12-11 -- :*:tyhe::they
2023-12-11 -- :*:with be::will be
2023-12-11 -- :?*:paralel::parallel
2023-12-11 -- :*:betwen::between
2023-12-11 -- :?*:accro::acro
2023-12-11 -- :?*:exsis::exis
2023-12-11 -- :?*:beei::bei
2023-12-11 << ::fo::of
2023-12-11 -- Cap fix: YWe
2023-12-11 -- :?*:durring::during
2023-12-11 -- Cap fix: YWe
2023-12-11 -- Cap fix: IS 
2023-12-11 -- Cap fix: IS 
2023-12-11 -- Cap fix: IS 
2023-12-11 -- Cap fix: THa
2023-12-11 -- :?*:addm::adm
2023-12-11 -- :*:if is::it is
2023-12-11 -- :*:hellow::hello
2023-12-11 -- :*:senc::sens
2023-12-12 -- Cap fix: EIt
2023-12-12 -- Cap fix: THa
2023-12-12 -- Cap fix: THa
2023-12-12 -- :*:amme::ame
2023-12-12 -- :?*:mtion::mation
2023-12-12 -- :?*:ommm::omm
2023-12-12 -- Cap fix: ISi
2023-12-12 -- Cap fix: CVi
2023-12-12 -- Cap fix: VCi
2023-12-12 -- :*:thats::that's
2023-12-12 -- Cap fix: THa
2023-12-12 -- Cap fix: SOu
2023-12-12 -- :?*:eild::ield
2023-12-12 -- :?:;s::'s
2023-12-12 << :*:betwen::between
2023-12-12 -- :*:try and::try to
2023-12-12 -- Cap fix: BFe
2023-12-12 -- :?*:efered::eferred
2023-12-12 -- :*:recie::recei
2023-12-13 -- Cap fix: IAr
2023-12-13 -- Cap fix: YOu
2023-12-13 -- :*:your a::you're a
2023-12-13 -- :*:your a::you're a
2023-12-13 << :*:puch::push
2023-12-13 -- :*:emial::email
2023-12-13 -- :?:occured::occurred
2023-12-13 -- :*:try and::try to
2023-12-13 -- Cap fix: TWh
2023-12-13 -- :*:recie::recei
2023-12-13 -- Cap fix: THu
2023-12-14 -- :?*:cogntivie::cognitive
2023-12-14 -- Cap fix: MBe
2023-12-14 -- Cap fix: VCi
2023-12-14 << :?*:tatn::tant
2023-12-14 -- :?*:durring::during
2023-12-14 << ::ther::there <removed>
2023-12-15 -- Cap fix: CHe
2023-12-15 -- :*:i"m::I'm
2023-12-15 -- Cap fix: CIn
2023-12-15 -- Cap fix: HHi
2023-12-15 -- Cap fix: FOl
2023-12-15 -- Cap fix: THa
2023-12-15 << :*:thats::that's
2023-12-15 -- :*:english::English <made case-sensitive>
2023-12-15 -- Cap fix: IHa
2023-12-15 -- :*:if is::it is
2023-12-15 -- :?*:scipt::script
2023-12-15 -- :*:deside::decide
2023-12-15 << :*:with in::within <fixed>
2023-12-15 << ::wat::way <removed>
2023-12-15 -- :?*:degrat::degrad
2023-12-15 -- :?*:eferan::eferen
2023-12-15 -- :?*:cuas::caus
2023-12-15 -- :?*:cuas::caus
2023-12-15 -- :?*:cuas::caus
2023-12-15 -- :*:senc::sens
2023-12-15 -- :?*:intented::intended
2023-12-15 -- :?*:cogntivie::cognitive
2023-12-15 -- Cap fix: THa
2023-12-15 -- :*:happend::happened
2023-12-15 -- :?*:cogntivie::cognitive
2023-12-15 -- :*:levle::level
2023-12-15 -- :*:resently::recently
2023-12-15 -- Cap fix: ACa
2023-12-15 -- :*:senc::sens
2023-12-15 -- :?*:durring::during
2023-12-15 -- :?*:siad::said
2023-12-15 -- :?*:efered::eferred
2023-12-15 -- :*:can checkout::can check out
2023-12-15 << :*:sentan::senten
2023-12-16 -- Cap fix: GLo
2023-12-16 -- Cap fix: CHa
2023-12-16 -- Cap fix: THe
2023-12-16 -- Cap fix: THi
2023-12-16 -- ::alway::always
2023-12-16 -- Cap fix: DOn
2023-12-16 -- :*:recomen::recommen
2023-12-16 << :*:anyother::any other
2023-12-16 -- :?*:focuss::focus
2023-12-16 -- Cap fix: IN 
2023-12-16 << ::fo::of
2023-12-16 -- Cap fix: SWi
2023-12-16 -- Cap fix: SPa
2023-12-16 -- Cap fix: WIn
2023-12-16 -- Cap fix: THe
2023-12-16 -- :?*:cuas::caus
2023-12-16 -- Cap fix: FOr
2023-12-16 -- Cap fix: THe
2023-12-16 -- Cap fix: THe
2023-12-16 -- Cap fix: IN 
2023-12-16 -- :*:recomen::recommen
2023-12-16 -- Cap fix: WIn
2023-12-16 -- Cap fix: CVa
2023-12-16 -- :?*:efered::eferred
2023-12-17 << :*:eyt::yet
2023-12-17 -- :*:bve::be
2023-12-17 -- Cap fix: THe
2023-12-17 << :?*:iopn::ion
2023-12-17 -- :?*:dipend::depend
2023-12-17 -- :?*:accessab::accessib
2023-12-17 -- :?:itiy::ity
2023-12-17 -- :?*:dependan::dependen
2023-12-17 -- :?*:releven::relevan
2023-12-17 << :?*:daty::day <removed>
2023-12-17 -- Cap fix: WIt
2023-12-17 << :?*:jist::gist
2023-12-17 -- :?*:cuas::caus
2023-12-17 -- :?*:belei::belie
2023-12-17 -- :?*:tioj::tion
2023-12-17 -- Cap fix: THi
2023-12-18 -- :*:english::English <made case-sensitive>
2023-12-18 << :*:incread::incred
2023-12-18 << :?*:daty::day <removed>
2023-12-18 -- :?*:sourse::source
2023-12-18 << :?*:ugth::ught
2023-12-18 << :?*:responc::respons
2023-12-18 -- :?*:cogntivie::cognitive
2023-12-18 << :*:a am::an am
2023-12-18 << :*:hda::had
2023-12-18 -- :*:hda::had
2023-12-18 << :*:hda::had
2023-12-18 -- :?*:responc::respons
2023-12-18 -- :*:tyo::to
2023-12-18 -- Cap fix: TCa
2023-12-18 -- Cap fix: NHo
2023-12-19 -- :?*:pld::ple
2023-12-19 -- Cap fix: THi
2023-12-19 -- :*:senc::sens
2023-12-19 -- :*:sould::should
2023-12-19 -- :?C:hc::ch
2023-12-19 -- :*:ToolTop::ToolTip
2023-12-19 -- :*:ToolTop::ToolTip
2023-12-19 -- :?*:efered::eferred
2023-12-19 -- Cap fix: COg
2023-12-19 -- :?*:mision::mission
2023-12-19 << :*:with be::will be
2023-12-19 << :?*:pld::ple
2023-12-19 -- :*:if is::it is
2023-12-19 << :?*:addm::adm
2023-12-19 -- :?*:cogntivie::cognitive
2023-12-20 -- :*:english::English <made case-sensitive>
2023-12-20 -- Cap fix: MNu
2023-12-20 -- :*:transfered::transferred
2023-12-20 -- :?*:commite::committe
2023-12-20 << :*:uise::use
2023-12-20 -- :*:everytime::every time
2023-12-20 -- :?*:woh::who
2023-12-20 -- Cap fix: FOr
2023-12-20 << ::alway::always
2023-12-20 << :*:thn::then
2023-12-20 -- ::averag::average
2023-12-20 -- :?*:strengh::strength
2023-12-20 -- Cap fix: SIm
2023-12-20 -- Cap fix: CKa
2023-12-20 -- Cap fix: TSh
2023-12-20 -- Cap fix: PRo
2023-12-20 -- Cap fix: LKa
2023-12-20 -- :*:agian::again
2023-12-20 -- Cap fix: SHe
2023-12-20 -- :?*:cuas::caus
2023-12-21 -- :*:english::English <made case-sensitive>
2023-12-21 -- :*:ToolTop::ToolTip
2023-12-21 -- Cap fix: SIn
2023-12-21 -- Cap fix: RIg
2023-12-21 -- :?:;ll::'ll
2023-12-21 -- :?:;s::'s
2023-12-21 -- :*:explainat::explanat
2023-12-21 -- :*:explainat::explanat
2023-12-22 -- Cap fix: IOn
2023-12-22 -- :?*:tiion::tion
2023-12-22 -- Cap fix: THi
2023-12-22 -- Cap fix: THi
2023-12-22 -- Cap fix: CHa
2023-12-23 -- :?*:mounth::month
2023-12-23 << :?*:nessec::necess
2023-12-23 -- Cap fix: RIg
2023-12-23 -- Cap fix: THe
2023-12-23 -- :*:tyo::to
2023-12-23 -- :?*:exsis::exis
2023-12-23 -- :*:if is::it is
2023-12-24 -- :?*:itina::itiona
2023-12-24 -- Cap fix: CHa
2023-12-24 << :*:wih::whi <removed>
2023-12-24 -- Cap fix: SUn
2023-12-25 -- :*:english::English <made case-sensitive>
2023-12-25 -- Cap fix: CHr
2023-12-25 -- :?*:eild::ield
2023-12-25 -- :*:tomorow::tomorrow
2023-12-25 -- Cap fix: THe
2023-12-25 -- Cap fix: THe
2023-12-25 -- Cap fix: THe
2023-12-25 -- Cap fix: THe
2023-12-25 -- Cap fix: THe
2023-12-25 << :?*:instu::instru
2023-12-25 -- :?*:anomo::anoma
2023-12-25 -- Cap fix: THa
2023-12-25 << :*:your a::you're a
2023-12-25 -- :?*:iopn::ion
2023-12-26 << :*:if is::it is
2023-12-26 -- :?*:exsis::exis
2023-12-26 -- :?*:assoca::associa
2023-12-27 -- :*:english::English <made case-sensitive>
2023-12-27 -- Cap fix: DOc
2023-12-27 -- Cap fix: THi
2023-12-28 << :*:hsa::has
2023-12-28 -- :?*:campain::campaign
2023-12-30 -- :*:english::English <made case-sensitive>
2023-12-30 -- :*:english::English <made case-sensitive>
2023-12-31 -- :*:wih::whi <removed>
2023-12-31 << :?*:releven::relevan
2023-12-31 -- :?*:tioj::tion
2023-12-31 -- :*:lable::label
2024-01-01 -- :*:your a::you're a
2024-01-01 -- :*:your a::you're a
2024-01-01 -- :*:try and::try to
2024-01-01 -- :*:your a::you're a
2024-01-01 << ::ther::there <removed>
2024-01 01 -- Cap fix: THe
2024-01-01 -- :?*:durring::during
2024-01-01 -- :?*:acadm::academ
2024-01-01 -- :*:if was::it was
2024-01-01 << :*:a un::an un
2024-01-01 -- :*:a un::an un
2024-01-01 -- :*:a un::an un
2024-01 01 -- Cap fix: AKa
2024-01-01 << :*:dont::don't
2024-01-01 -- :?:throught::through
2024-01-01 << :?*:iopn::ion
2024-01-01 << :?*:asr::ase
2024-01 01 -- Cap fix: WOr
2024-01-01 << ::fro::for
2024-01 01 -- Cap fix: THe
2024-01-01 << :?*:cuas::caus
2024-01 01 -- Cap fix: THi
2024-01-02 -- :?*:efering::eferring
2024-01-02 -- :*:as apposed to::as opposed to
2024-01-02 -- :?:herefor::herefore
2024-01-02 << :*:its a::it's a
2024-01-02 << :*:tyhe::they
2024-01 02 -- Cap fix: AHk
2024-01-02 -- :?*:cuas::caus
2024-01 02 -- Cap fix: TO 
2024-01-02 -- :*:a ig::an ig
2024-01 02 -- Cap fix: ANo
2024-01-02 << :?*:wtih::with
2024-01 02 -- Cap fix: COn
2024-01 02 -- Cap fix: THi
2024-01 02 -- Cap fix: CHa
2024-01-02 -- :*:mispell::misspell
2024-01 02 -- Cap fix: THe
2024-01-02 -- :?*:grama::gramma
2024-01-03 -- :*:english::English <made case-sensitive>
2024-01 03 -- Cap fix: WSe
2024-01-03 -- :?*:pld::ple
2024-01 03 -- Cap fix: LWe
2024-01-03 << :?*:inng::ing
2024-01-03 -- :*:cant::can't
2024-01-03 -- :*:english::English <made case-sensitive>
2024-01-03 -- :*:mispell::misspell
2024-01-03 -- :*:senc::sens
2024-01 03 -- Cap fix: COr
2024-01-03 -- :*:artical::article
2024-01-03 -- :*:proof read::proofread
2024-01-03 -- :*:artical::article
2024-01-03 << :?*:expalin::explain
2024-01-04 -- :*:english::English <made case-sensitive>
2024-01-04 << :?*:cogntivie::cognitive
2024-01-04 -- :?*:behaio::behavio
2024-01 04 -- Cap fix: AAs
2024-01-04 -- ::t he::the
2024-01-04 -- :?*:durring::during
2024-01-04 << :*:bve::be
2024-01-04 << :?*:daty::day <removed>
2024-01-04 -- :?*:grama::gramma
2024-01 04 -- Cap fix: COr
2024-01-04 -- :*:thier::their
2024-01-04 -- :?*:neccessar::necessar
2024-01-04 << :?*:daty::day <removed>
2024-01-05 -- :*:it's own::its own
2024-01 05 -- Cap fix: BRo
2024-01 05 -- Cap fix: BGo
2024-01 05 -- Cap fix: SPe
2024-01 05 -- Cap fix: WRe
2024-01-05 << :?*:reiv::riev
2024-01-05 -- :?*:pcial::pical
2024-01-05 << :?*:abilt::abilit
2024-01-05 -- :*:fouth::fourth
2024-01 05 -- Cap fix: THe
2024-01-05 << :*:a af::an af
2024-01-05 -- :?*:belei::belie
2024-01-05 -- :*:whould::would
2024-01-05 -- :*:is it's::is its
2024-01-05 -- :?:culem::culum
2024-01-05 -- :*:the affects of::the effects of
2024-01-05 -- :?:itiy::ity
2024-01-05 -- :?*:exsis::exis
2024-01-05 -- :?*:mrak::mark
2024-01-05 -- :?*:mrak::mark
2024-01-05 -- :?*:mrak::mark
2024-01-05 -- :?*:cuas::caus
2024-01-05 -- :*:thier::their
2024-01-05 << :*:with in::within <fixed>
2024-01-05 -- :*:beggining::beginning
2024-01-05 -- :*:beggining::beginning
2024-01-05 -- :?*:sttr::str
2024-01-05 << ::fro::for
2024-01-05 -- :?:herefor::herefore
2024-01 06 -- Cap fix: FOr
2024-01 06 -- Cap fix: SIn
2024-01 06 -- Cap fix: ZBo
2024-01 06 -- Cap fix: ANa
2024-01 06 -- Cap fix: THe
2024-01 06 -- Cap fix: THe
2024-01-06 << :*:faster then::faster than
2024-01 06 -- Cap fix: FOr
2024-01-06 -- :?*:seach::search
2024-01-06 -- :*:hellow::hello
2024-01 06 -- Cap fix: NEn
2024-01 06 -- Cap fix: HHo
2024-01-06 << :?*:asr::ase
2024-01 08 -- Cap fix: JUs
2024-01-08 -- :?*:efering::eferring
2024-01-08 -- :?*:tranf::transf
2024-01-08 << :?*:exsis::exis
2024-01-08 -- :?*:cuas::caus
2024-01-08 -- :*:femail::female
2024-01 08 -- Cap fix: SIn
2024-01 08 -- Cap fix: FOr
2024-01-08 << :?*:yuo::you
2024-01-08 -- :?*:yuo::you
2024-01 08 -- Cap fix: COn
2024-01-08 -- :?*:efering::eferring
2024-01-08 -- :?*:exsis::exis
2024-01-08 -- :*:occation::occasion
2024-01-08 -- :*?:combon::combin
2024-01-08 -- :*?:combon::combin
2024-01-08 -- :*:english::English <made case-sensitive>
2024-01-08 -- :?*:yuo::you
2024-01-08 -- :*?:combon::combin
2024-01 08 -- Cap fix: REi
2024-01-09 -- :*:english::English <made case-sensitive>
2024-01 09 -- Cap fix: WQh
2024-01-09 -- :?*:nsern::ncern
2024-01 09 -- Cap fix: DOe
2024-01-09 -- ::theri::their
2024-01-09 -- :*:has it's::has its
2024-01-09 -- :?*:inng::ing
2024-01 09 -- Cap fix: XCo
2024-01-09 -- :?*:acom::accom
2024-01-09 -- :?*:cuas::caus
2024-01-09 -- :?:herefor::herefore
2024-01 09 -- Cap fix: COr
2024-01 09 -- Cap fix: OIf
2024-01 09 -- Cap fix: HGo
2024-01 09 -- Cap fix: THe
2024-01 09 -- Cap fix: FOr
2024-01-09 << :*:tyhe::they
2024-01 09 -- Cap fix: THe
2024-01 09 -- Cap fix: ASt
2024-01 09 -- Cap fix: COr
2024-01 09 -- Cap fix: FOl
2024-01-10 -- :*:english::English <made case-sensitive>
2024-01 10 -- Cap fix: THe
2024-01-10 -- :?*:beahv::behav
2024-01-10 << :*:try and::try to
2024-01-10 << :?*:ernt::erent
2024-01-10 -- :?*:idenital::idential
2024-01-10 -- :?*:exsis::exis
2024-01-10 << ::ther::there <removed>
2024-01-10 -- :?:occured::occurred
2024-01 10 -- Cap fix: IT 
2024-01 10 -- Cap fix: THe
2024-01-10 -- :?*:orign::origin
2024-01-10 -- :?*:cogntivie::cognitive
2024-01-10 << :*:was send::was sent
2024-01-10 -- :*:recie::recei
2024-01-10 -- :*:mispell::misspell
2024-01-10 << :?:fuly::fully
2024-01-10 -- :?*:makeing::making
2024-01-10 -- :*:vise versa::vice versa
2024-01 10 -- Cap fix: RIv
2024-01 10 -- Cap fix: SMa
2024-01-11 -- :?:icaly::ically
2024-01-11 -- :?*:efered::eferred
2024-01 11 -- Cap fix: WWp
2024-01 11 -- Cap fix: WEo
2024-01-11 -- :?:occured::occurred
2024-01 11 -- Cap fix: WWp
2024-01-11 -- :?*:belei::belie
2024-01-11 -- :?:doens::does
2024-01-11 -- :*:try and::try to
2024-01-11 -- :?*:tatch::tach
2024-01-11 << :*:emial::email
2024-01 11 -- Cap fix: THa
2024-01-11 -- :*:a ap::an ap
2024-01-11 -- :*:english::English <made case-sensitive>
2024-01-11 << :*:reliz::realiz
2024-01-11 -- :*:english::English <made case-sensitive>
2024-01 12 -- Cap fix: MOs
2024-01-12 -- :*:english::English <made case-sensitive>
2024-01 12 -- Cap fix: SIn
2024-01 12 -- Cap fix: FOr
2024-01-12 << :?*:listn::listen
2024-01 12 -- Cap fix: SRe
2024-01-12 -- :?:occured::occurred
2024-01-12 -- :?*:oducab::oducib
2024-01-12 -- :?*:sourse::source
2024-01-12 -- :?*:ateing::ating
2024-01-12 -- :*:lable::label
2024-01-12 << :*:assit::assist
2024-01-12 -- :*:esle::else
2024-01 12 -- Cap fix: EEd
2024-01-12 << :?*:eceed::ecede
2024-01 12 -- Cap fix: SGr
2024-01-12 << :*:if is::it is
2024-01-12 -- :*:yera::year
2024-01-12 -- :?*:extention::extension
2024-01-12 -- :*:resently::recently
2024-01 13 -- Cap fix: WIt
2024-01 13 -- Cap fix: WIt
2024-01 13 -- Cap fix: CLi
2024-01 13 -- Cap fix: WLi
2024-01-13 -- :*:english::English <made case-sensitive>
2024-01 13 -- Cap fix: THa
2024-01 13 -- Cap fix: CLi
2024-01 13 -- Cap fix: ALs
2024-01 13 -- Cap fix: FOl
2024-01 13 -- Cap fix: FIl
2024-01-13 -- :?*:wnat::want
2024-01 13 -- Cap fix: THe
2024-01-13 << :*C:wich::which
2024-01 13 -- Cap fix: HWh
2024-01 13 -- Cap fix: COu
2024-01 13 -- Cap fix: TIm
2024-01 13 -- Cap fix: TTi
2024-01 13 -- Cap fix: CUr
2024-01 13 -- Cap fix: CUr
2024-01-14 -- :?*:cuas::caus
2024-01 14 -- Cap fix: WIt
2024-01 14 -- Cap fix: THa
2024-01-14 -- :*:there own::their own
2024-01-14 -- :*:replacment::replacement
2024-01-14 -- :?*:exsis::exis
2024-01-14 -- :?*:exsis::exis
2024-01 14 -- Cap fix: WOr
2024-01-14 -- :*:beggining::beginning
2024-01 14 -- Cap fix: WOr
2024-01-14 -- :?*:exsis::exis
2024-01-14 -- :?*:exsis::exis
2024-01-14 -- :?*:exsis::exis
2024-01-14 -- :?*:exsis::exis
2024-01-14 -- :*:superce::superse
2024-01-14 << :?*:pld::ple
2024-01-14 -- :?*:exsis::exis
2024-01-14 -- :*:esle::else
2024-01 14 -- Cap fix: OTr
2024-01-14 -- :*:hellow::hello
2024-01-14 -- :*:gusy::guys
2024-01-14 -- :?:otu::out
2024-01 14 -- Cap fix: RIl
2024-01 14 -- Cap fix: RIl
2024-01 14 -- Cap fix: FIl
2024-01 14 -- Cap fix: UAu
2024-01 14 -- Cap fix: UAu
2024-01-14 -- :?*:exsis::exis
2024-01-14 << :?*:inng::ing
2024-01 15 -- Cap fix: WIk
2024-01-15 -- :?*:grama::gramma
2024-01-15 -- :?*:acom::accom
2024-01-15 << :?*:acom::accom
2024-01-15 -- :*:hellow::hello
2024-01 15 -- Cap fix: COm
2024-01-15 -- :*:hellow::hello
2024-01-15 -- :?*C:mnt::ment
2024-01-15 -- :?*:legitamat::legitimat
2024-01-15 -- :?:teh::the
2024-01-15 -- :*:hte::the
2024-01-15 -- :?:teh::the
2024-01 15 -- Cap fix: THe
2024-01-15 -- :?*:tatn::tant
2024-01-15 -- :*:superce::superse
2024-01 15 -- Cap fix: COn
2024-01-15 -- :*:sould::should
2024-01 15 -- Cap fix: CUr
2024-01-15 -- :*:senc::sens
2024-01-15 -- :?*:concider::consider
2024-01 15 -- Cap fix: THe
2024-01-15 -- :*:wih::whi <removed>
2024-01-15 -- :*:wih::whi <removed>
2024-01 15 -- Cap fix: THe
2024-01-15 << :*:artical::article
2024-01 15 -- Cap fix: COn
2024-01-15 -- :?:itiy::ity
2024-01-15 -- :*:enought::enough
2024-01 16 -- Cap fix: THe
2024-01-16 << :*:senc::sens
2024-01-16 -- :?*:scipt::script
2024-01 16 -- Cap fix: CLi
2024-01-16 -- :*:use to::used to
2024-01-16 -- :*:proof read::proofread
2024-01-16 -- :?*:appol::apol
2024-01-16 -- :?*:lcud::clud
2024-01-16 -- :?*:cuas::caus
2024-01-16 -- :?*:exsis::exis
2024-01-16 << :*:tyhe::they
2024-01-16 -- :?*:adviced::advised
2024-01-16 -- :?:throught::through
2024-01-16 -- :?*:exsis::exis
2024-01-16 << :?*:ivle::ivel
2024-01 16 -- Cap fix: THe
2024-01-16 << :?*:daty::day <removed>
2024-01-16 << :?:lyu::ly
2024-01-16 << :*:wih::whi <removed>
2024-01 16 -- Cap fix: THe
2024-01-16 -- :?*:exsis::exis
2024-01-16 -- :?*:durring::during
2024-01-16 -- :?:lyu::ly
2024-01-16 << :*:recie::recei
2024-01-16 -- ::EDB::EBD
2024-01-16 -- :?*:cogntivie::cognitive
2024-01-16 -- :?*:strengh::strength
2024-01-16 -- :?*:cogntivie::cognitive
2024-01 16 -- Cap fix: CLa
2024-01 16 -- Cap fix: TWe
2024-01-16 -- :*:replacment::replacement
2024-01-16 -- :*:excelen::excellen
2024-01-16 -- :?*:exsis::exis
2024-01 16 -- Cap fix: THe
2024-01-16 -- :*:mispell::misspell
2024-01 16 -- Cap fix: THe
2024-01 16 -- Cap fix: COr
2024-01-16 -- :*:english::English <made case-sensitive>
2024-01-16 -- :*:english::English <made case-sensitive>
2024-01-16 -- :?:ign::ing
2024-01 16 -- Cap fix: THe
2024-01 16 -- Cap fix: FOr
2024-01 16 -- Cap fix: CSe
2024-01 16 -- Cap fix: CSe
2024-01-16 -- :?*:concider::consider
2024-01 16 -- Cap fix: THi
2024-01-16 -- :?*:belei::belie
2024-01-16 -- :*:english::English <made case-sensitive>
2024-01 17 -- Cap fix: THe
2024-01-17 -- :*C:carmel::caramel
2024-01-17 -- :?*:natly::nately
2024-01 17 -- Cap fix: THe
2024-01-17 -- :*:senc::sens
2024-01-17 -- :?:itiy::ity
2024-01-17 -- :*:english::English <made case-sensitive>
2024-01 17 -- Cap fix: HOw
2024-01 17 -- Cap fix: FIl
2024-01-17 -- :?*:affraid::afraid
2024-01-17 << :?*:eanr::earn
2024-01 17 -- Cap fix: COm
2024-01-17 << :?*:socal::social
2024-01-17 -- :*:senc::sens
2024-01 17 -- Cap fix: IGi
2024-01 17 -- Cap fix: IGi
2024-01 17 -- Cap fix: COn
2024-01-17 -- :?:occure::occur
2024-01-17 -- :?*:surpriz::surpris
2024-01-17 -- :?*:efered::eferred
2024-01-17 -- :?*:rnign::rning
2024-01-17 -- :?*:durring::during
2024-01-17 -- :?*:ineing::ining
2024-01-17 -- :*:geting::getting
2024-01-17 -- :?*:ciev::ceiv
2024-01-17 -- :?*:ciev::ceiv
2024-01-17 -- :*:willbe::will be
2024-01 17 -- Cap fix: THe
2024-01-17 -- :?*:durring::during
2024-01-17 -- :?*:durring::during
2024-01-17 -- :?*:cogntivie::cognitive
2024-01-17 -- :?*:cogntivie::cognitive
2024-01-17 -- :*:inwhich::in which
2024-01-17 -- :?:occured::occurred
2024-01 17 -- Cap fix: WIt
2024-01-17 << ::imagin::imagine
2024-01-17 -- :?*:cirp::crip
2024-01 17 -- Cap fix: THe
2024-01-17 -- :?*:guement::gument
2024-01-17 -- :*:resently::recently
2024-01 17 -- Cap fix: HOt
2024-01 17 -- Cap fix: IAu
2024-01-17 -- :*:infact::in fact
2024-01-17 -- :*:hwi::whi
2024-01-17 -- :?C:hc::ch
2024-01-17 -- :*?:combon::combin
2024-01-17 -- :X*?:combon::combin
2024-01-17 -- :X*?:combon::combin
2024-01-17 -- :X*?:combon::combin
2024-01-17 -- :?:occured::occurred
2024-01-17 << ::be send::be sent
2024-01-17 -- :*:replacment::replacement
2024-01-17 -- :?:occured::occurred
2024-01 17 -- Cap fix: IFi
2024-01 18 -- Cap fix: THe
2024-01-18 -- :?*:nouce::nounce
2024-01 18 -- Cap fix: HOw
2024-01 18 -- Cap fix: THu
2024-01 18 -- Cap fix: LPs
2024-01-18 -- :*:sould::should
2024-01 18 -- Cap fix: SHo
2024-01 18 -- Cap fix: TAn
2024-01 18 -- Cap fix: WId
2024-01-18 -- :?:occured::occurred
2024-01-18 -- :?*:ceing::cing
2024-01-18 -- :?*:exsis::exis
2024-01-18 -- :*:replacment::replacement
2024-01-18 -- :*:replacment::replacement
2024-01-18 -- :?*:exsis::exis
2024-01-18 -- :*:replacment::replacement
2024-01-18 -- :*:be setup::be set up
2024-01-18 -- :*:amme::ame
2024-01-18 << :*:interm::interim
2024-01-18 -- :?*:appol::apol
2024-01 18 -- Cap fix: IFi
2024-01-18 -- :*:puch::push
2024-01-18 -- ::fro::for
2024-01-18 -- ::agains::against
2024-01-18 -- :*:alege::allege
2024-01-18 -- :*:faster then::faster than
2024-01-19 << :*:enlish::English
2024-01-19 -- :*:english::English <made case-sensitive>
2024-01-19 -- :?*:shco::scho
2024-01 19 -- Cap fix: COl
2024-01-19 << :?:ualy::ually
2024-01-19 << :?*:pulare::pular
2024-01 19 -- Cap fix: ODe
2024-01 19 -- Cap fix: IDo
2024-01 19 -- Cap fix: IPe
2024-01-19 -- :?*:embarass::embarrass
2024-01-19 -- :?*:voiu::viou
2024-01-19 -- :?*:cuas::caus
2024-01-19 -- :*:enlish::English
2024-01 19 -- Cap fix: IHi
2024-01-19 -- :*:replacment::replacement
2024-01-19 -- :?*:durring::during
2024-01-19 -- :*C:ime::imme
2024-01 19 -- Cap fix: THe
2024-01-19 -- :?*:rixon::rison
2024-01-19 -- :*:tiem::time
2024-01-19 -- :?:occured::occurred
2024-01 19 -- Cap fix: THe
2024-01 19 -- Cap fix: COr
2024-01-19 -- :*:everytime::every time
2024-01-19 -- :?*:exsis::exis
2024-01-19 -- :*:tiem::time
2024-01-19 -- :*:replacment::replacement
2024-01-19 -- ::withing::within
2024-01-19 -- :?*:anounc::announc
2024-01 19 -- Cap fix: MBe
2024-01-19 << :*:tiem::time
2024-01-19 -- :*:with it's::with its
2024-01-19 -- :*:senc::sens
2024-01-19 << :*:doen't::doesn't
2024-01-19 -- :*:mispell::misspell
2024-01-19 -- :*:interm::interim
2024-01 19 -- Cap fix: COr
2024-01-19 -- :?*:sourse::source
2024-01-19 -- :*:use to::used to
2024-01-19 -- :*:hellow::hello
2024-01 19 -- Cap fix: THe
2024-01-19 -- :?*:neccessar::necessar
2024-01-19 -- :?*:neccessar::necessar
2024-01 19 -- Cap fix: COr
2024-01-19 -- :?*:grama::gramma
2024-01-19 -- :?*:scipt::script
2024-01 19 -- Cap fix: COn
2024-01 20 -- Cap fix: COm
2024-01-20 -- :*:hwo::who
2024-01 20 -- Cap fix: COm
2024-01 20 -- Cap fix: THe
2024-01 20 -- Cap fix: FIx
2024-01-20 -- :?*:oulb::oubl
2024-01-20 -- :*:puting::putting
2024-01-20 -- :*C:wich::which
2024-01-20 -- :?*:efered::eferred
2024-01-20 -- :?*:igous::igious
2024-01-20 -- :?*:igous::igious
2024-01-20 -- :?*:casue::cause
2024-01-20 -- :?*:appol::apol
2024-01 20 -- Cap fix: AUt
2024-01-20 -- :*:deside::decide
2024-01-20 -- :*:it's own::its own
2024-01 20 -- Cap fix: THe
2024-01 20 -- Cap fix: COr
2024-01 20 -- Cap fix: THe
2024-01 20 -- Cap fix: COr
2024-01-20 -- :*:deside::decide
2024-01 20 -- Cap fix: TYh
2024-01-20 -- :?*:tyha::tha
2024-01-20 -- :*:hte::the
2024-01-20 -- :*:proof read::proofread
2024-01-21 -- :?:icaly::ically
2024-01 21 -- Cap fix: THa
2024-01-21 -- :?*:inng::ing
2024-01 21 -- Cap fix: THe
2024-01-21 -- :*?:cment::cement
2024-01 21 -- Cap fix: THe
2024-01-21 -- :*:was send::was sent
2024-01 21 -- Cap fix: DId
2024-01-21 -- :*:if is::it is
2024-01 21 -- Cap fix: HWi
2024-01-21 -- :*:hwi::whi
2024-01 21 -- Cap fix: COr
2024-01-21 << :?*:provd::provid
2024-01-21 -- :*?:cment::cement
2024-01-21 << :?*:nsern::ncern
2024-01-21 -- :?*:breif::brief
2024-01-21 -- :?*:rafic::rific
2024-01-21 -- :*:proof read::proofread
2024-01-21 -- :?:occured::occurred
2024-01-21 -- :?:itiy::ity
2024-01-21 -- :?*:aggree::agree
2024-01-21 -- :*:in principal::in principle
2024-01 21 -- Cap fix: COr
2024-01-21 -- ::fo::of
2024-01 21 -- Cap fix: RIg
2024-01 21 -- Cap fix: THi
2024-01-22 -- :?*:tecn::techn
2024-01-22 -- :*:deside::decide
2024-01 22 -- Cap fix: PRo
2024-01 22 -- Cap fix: WEe
2024-01-22 -- :?*:igini::igni
2024-01-22 -- :*:if is::it is
2024-01-22 -- :*:transfered::transferred
2024-01-22 << :*:is were::is where
2024-01-22 -- :?:occured::occurred
2024-01-22 -- :?*:cuas::caus
2024-01-22 -- :?*:anbd::and
2024-01 22 -- Cap fix: UPd
2024-01-22 -- :?*:aggree::agree
2024-01-22 -- :?*:durring::during
2024-01-22 -- :*:recommed::recommend
2024-01-22 -- :?*:knwo::know
2024-01-22 -- :*:transfered::transferred
2024-01-22 -- :?:throught::through2024-01-22 -- :*:i"m::I'm
2024-01-22 -- :*:accidently::accidentally
2024-01-22 -- :?*:interupt::interrupt
2024-01-22 -- :*:accidently::accidentally
2024-01-22 << :*:artc::artic
2024-01-23 -- :?*:aggree::agree
2024-01 23 -- Cap fix: THe
2024-01 23 -- Cap fix: WIt
2024-01-23 -- :?*:wierd::weird
2024-01-23 -- :*:senc::sens
2024-01-23 -- :?*:cuas::caus
2024-01-23 -- :?*:tecn::techn
2024-01-23 -- :*:peom::poem
2024-01-23 -- :?*:ccce::cce
2024-01-23 << :?:sfull::sful
2024-01-23 -- :?*:ytou::you
2024-01 23 -- Cap fix: IEp
2024-01-23 -- :?*:follwo::follow
2024-01-23 -- :*:i"m::I'm
2024-01 23 -- Cap fix: WEe
2024-01 23 -- Cap fix: THa
2024-01-23 -- :*:criteria is::criteria are
2024-01-23 -- :?*:durring::during
2024-01 23 -- Cap fix: TYh
2024-01-23 -- :?*:exsis::exis
2024-01 23 -- Cap fix: AZd
2024-01-23 << :?:realy::really
2024-01-23 -- :?*:durring::during
2024-01-23 << :*:recie::recei
2024-01-23 << :?:rthe::r the
2024-01-23 -- :?*:efered::eferred
2024-01-23 -- :?*:surpriz::surpris
2024-01-23 -- :?*:efered::eferred
2024-01 23 -- Cap fix: JEn
2024-01-23 -- :?*:socre::score
2024-01 23 -- Cap fix: NOt
2024-01-23 -- :?*:durring::during
2024-01-24 << :?*:driect::direct
2024-01-24 -- :*:hellow::hello
2024-01 24 -- Cap fix: LCa
2024-01 24 -- Cap fix: THi
2024-01-24 << :*:there by::thereby
2024-01 24 -- Cap fix: FOr
2024-01 24 -- Cap fix: TEx
2024-01-24 -- :?*:casue::cause
2024-01-24 << :*:thn::then
2024-01-24 -- :?*:commini::communi
2024-01-24 -- :?:rthe::r the
2024-01 24 -- Cap fix: THe
2024-01 24 -- Cap fix: THe
2024-01-24 << ::ther::there <removed>
2024-01 24 -- Cap fix: FOl
2024-01 24 -- Cap fix: THa
2024-01 25 -- Cap fix: THa
2024-01 25 -- Cap fix: OTs
2024-01-25 -- :?*:ssition::sition
2024-01-25 -- :*:virutal::virtual
2024-01-25 -- :?*:surpriz::surpris
2024-01-25 -- :?:hthe::h the
2024-01-25 -- :*:they where::they were
2024-01-25 -- :*:thier::their
2024-01 25 -- Cap fix: FOr
2024-01 25 -- Cap fix: THe
2024-01 25 -- Cap fix: DOn
2024-01-25 -- ::lot's of::lots of
2024-01 25 -- Cap fix: THi
2024-01 25 -- Cap fix: FOl
2024-01-25 -- :?:lyu::ly
2024-01-25 -- :?*:agress::aggress
2024-01 25 -- Cap fix: THa
2024-01-25 -- :*:with be::will be
2024-01 25 -- Cap fix: THe
2024-01 25 -- Cap fix: THi
2024-01-25 << :?*:quesion::question
2024-01-25 -- :*:healther::health
2024-01-25 -- :?*:beahv::behav
2024-01-25 -- :*:are know::are known
2024-01-25 -- :?*:beahv::behav
2024-01 25 -- Cap fix: COm
2024-01 25 -- Cap fix: HIm
2024-01-26 -- :*:attroci::atroci
2024-01-26 -- :?*:cuas::caus
2024-01-26 -- :*:senc::sens
2024-01-26 -- ::ther::there <removed>
2024-01-26 -- :*:with out::without
2024-01-26 -- :?*:ommm::omm
2024-01-26 -- :?*:dependan::dependen
2024-01-26 -- :?*:iegh::eigh
2024-01-26 -- :?*:soem::some
2024-01-26 -- :?:occured::occurred
2024-01-26 -- :*:somthing::something
2024-01-26 -- :?:kn::nk
2024-01-27 -- :?*:exsis::exis
2024-01-27 -- :?*:durring::during
2024-01-27 -- :?*:guement::gument
2024-01-27 -- :?*:cuas::caus
2024-01-27 -- :?*:casue::cause
2024-01-27 -- :?*:existan::existen
2024-01 27 -- Cap fix: CHr
2024-01-27 -- :*:underat::underrat
2024-01 27 -- Cap fix: THa
2024-01-27 -- :*C:ime::imme
2024-01 27 -- Cap fix: HAn
2024-01 27 -- Cap fix: HAn
2024-01 27 -- Cap fix: ISt
2024-01 27 -- Cap fix: ITh
2024-01-27 -- :?*:consentr::concentr
2024-01-27 -- :?*:durring::during
2024-01-27 -- :?*:durring::during
2024-01-27 -- :?*:dependan::dependen
2024-01-27 -- ::ther::there <removed>
2024-01-27 -- ::ther::there <removed>
2024-01-27 -- :?*:referal::referral
2024-01-27 -- :?*:attachement::attachment
2024-01-27 -- :*:incidently::incidentally
2024-01-27 -- :*:i"m::I'm
2024-01-27 -- :?*:attachement::attachment
2024-01-27 -- :?*:aggree::agree
2024-01-27 -- :*:senc::sens
2024-01-27 << :?*:ernt::erent
2024-01-27 << :*:helf::held
2024-01-27 -- :*:tyo::to
2024-01 27 -- Cap fix: THe
2024-01-27 -- :?*:cogntivie::cognitive
2024-01-28 -- :*C:ime::imme
2024-01-28 << :?*:yuo::you
2024-01-28 -- :?:nig::ing
2024-01-28 -- :?*:responc::respons
2024-01-28 -- :*:its a::it's a
2024-01 28 -- Cap fix: DSa
2024-01-28 << ::ther::there <removed>
2024-01 28 -- Cap fix: CHr
2024-01-28 -- :?*:pld::ple
2024-01-28 << :*:wih::whi <removed>
2024-01-28 -- :?*:surpriz::surpris
2024-01-28 -- :?*:protie::protei
2024-01-28 -- :?*:protie::protei
2024-01 28 -- Cap fix: SLa
2024-01-28 -- :?*:protie::protei
2024-01-28 -- ::thr::the
2024-01-29 -- :?*:guement::gument
2024-01-29 -- :?*:exsis::exis
2024-01 29 -- Cap fix: DId
2024-01-29 << ::wat::way <removed>
2024-01-29 << :?:occure::occur
2024-01-29 -- :?:busines::business
2024-01 29 -- Cap fix: NMe
2024-01-29 << ::fro::for
2024-01-29 -- :*:a simple as::as simple as
2024-01-29 -- :*:youself::yourself
2024-01 29 -- Cap fix: THe
2024-01 29 -- Cap fix: THe
2024-01-29 -- :?*:blich::blish
2024-01 29 -- Cap fix: IWe
2024-01-29 -- :?*:iopn::ion
2024-01-29 -- :*C:wich::which
2024-01-29 -- :?*:cogntivie::cognitive
2024-01 29 -- Cap fix: DSa
2024-01-29 -- :*:amme::ame
2024-01 29 -- Cap fix: CCe
2024-01 29 -- Cap fix: CCe
2024-01-29 -- :?*:reing::ring
2024-01-29 -- :?*:cuas::caus
2024-01-29 << :?:ualy::ually
2024-01 29 -- Cap fix: VIn
2024-01-29 << :?*:asr::ase
2024-01-29 -- :*:had spend::had spent
2024-01-29 -- :*:dont::don't
2024-01-29 -- :?*:guement::gument
2024-01-29 -- :*:artical::article
2024-01-29 << :*:wih::whi <removed>
2024-01 29 -- Cap fix: NAn
2024-01 29 -- Cap fix: NAn
2024-01 29 -- Cap fix: DOn
2024-01 29 -- Cap fix: JZo
2024-01-29 -- :*:with be::will be
2024-01-30 << :?*:eanr::earn
2024-01-30 -- :?*:cuas::caus
2024-01 30 -- Cap fix: YOu
2024-01-30 -- :?:realy::really
2024-01 30 -- Cap fix: IAn
2024-01-30 -- :?*:nvien::nven
2024-01 30 -- Cap fix: DOe
2024-01-30 -- :?*:exsis::exis
2024-01 30 -- Cap fix: CHr
2024-01 30 -- Cap fix: THa
2024-01 30 -- Cap fix: GOd
2024-01 30 -- Cap fix: THe
2024-01-30 -- :?*:legitamat::legitimat
2024-01-30 -- :?*:cuas::caus
2024-01 30 -- Cap fix: ANd
2024-01 30 -- Cap fix: GGo
2024-01-30 -- :*:incidently::incidentally
2024-01 30 -- Cap fix: ASe
2024-01-30 << :?*:ugth::ught
2024-01 30 -- Cap fix: SHe
2024-01 30 -- Cap fix: WIl
2024-01-30 -- :?*:efering::eferring
2024-01-30 -- :?*:exsis::exis
2024-01-30 << :?*:opth::ophth
2024-01-30 -- ::ther::there <removed>
2024-01-30 -- :*:transfered::transferred
2024-01-30 -- :?*:acom::accom
2024-01-30 -- :?*:exsis::exis
2024-01-30 -- :?*:durring::during
2024-01 30 -- Cap fix: ASc
2024-01-30 -- :?*:nsistan::nsisten
2024-01-30 -- :?*:cogntivie::cognitive
2024-01 30 -- Cap fix: THa
2024-01 30 -- Cap fix: IHe
2024-01-31 -- :?:fuly::fully
2024-01-31 -- :?:occured::occurred
2024-01-31 -- :*C:english::English <made case-sensitive>
2024-01-31 -- :?*:breif::brief
2024-01-31 << ::ther::there <removed>
2024-01 31 -- Cap fix: COn
2024-01-31 -- :*:inperson::in-person
2024-01-31 -- :*:inperson::in-person
2024-01-31 -- :*:enought::enough
2024-01-31 << :C:Im::I'm
2024-01-31 -- :?*:belei::belie
2024-01-31 -- :*:use to::used to
2024-01-31 -- :?*:cuas::caus
2024-01 31 -- Cap fix: THo
2024-02-01 -- :*C:english::English <made case-sensitive>
2024-02 01 -- Cap fix: IYe
2024-02 01 -- Cap fix: DOn
2024-02 01 -- Cap fix: DOn
2024-02 01 -- Cap fix: CRh
2024-02 01 -- Cap fix: YOu
2024-02-01 -- :*:itis::it is
2024-02-01 -- :?*:durring::during
2024-02 01 -- Cap fix: TWh
2024-02 01 -- Cap fix: ZBo
2024-02-01 << ::ther::there <removed>
2024-02-01 << :*:wih::whi <removed>
2024-02-01 -- ::t he::the
2024-02-01 -- :?*:cogntivie::cognitive
2024-02-01 -- ::theri::their
2024-02-01 -- :?*:exsis::exis
2024-02-01 -- :*:amme::ame
2024-02 01 -- Cap fix: WIl
2024-02 01 -- Cap fix: THe
2024-02-01 -- :*:accidently::accidentally
2024-02-01 -- :?*:exsis::exis
2024-02 01 -- Cap fix: THa
2024-02 01 -- Cap fix: SOu
2024-02 01 -- Cap fix: WOr
2024-02-01 -- :?*:troling::trolling
2024-02-01 -- :?*:soica::socia
2024-02-02 -- :*C:english::English <made case-sensitive>
2024-02-03 -- :?*:exsis::exis
2024-02-03 -- :?*:exsis::exis
2024-02 03 -- Cap fix: FOr
2024-02-03 -- :?*:cuas::caus
2024-02-03 -- :*:propoga::propaga
2024-02 03 -- Cap fix: ANd
2024-02-03 -- :?*:exsis::exis
2024-02 03 -- Cap fix: THo
2024-02 03 -- Cap fix: EAn
2024-02-03 << :*:helf::held
2024-02-03 -- :?*:institue::institute
2024-02-03 -- :?*:seach::search
2024-02-03 -- :?*:patab::patib
2024-02-03 -- :*:are build::are built
2024-02-03 -- :?*:patab::patib
2024-02-03 -- :*:endevors::endeavors
2024-02-03 -- :*:see know::see now
2024-02-03 -- :?:kn::nk
2024-02-03 -- :?:kn::nk
2024-02-03 -- :?*:emmin::emin
2024-02-03 -- :?*:emmin::emin
2024-02-03 -- :?*:emmin::emin
2024-02-03 << :?*:sistend::sistent
2024-02-03 -- :?*:beei::bei
2024-02-03 -- :*:friut::fruit
2024-02 03 -- Cap fix: BVu
2024-02-03 -- :*:myown::my own
2024-02-03 << :?*:tioj::tion
2024-02-03 -- :?*:patab::patib
2024-02 03 -- Cap fix: IAs
2024-02-03 -- :*:proof read::proofread
2024-02-03 << :*:senc::sens
2024-02-03 -- :?*:appol::apol
2024-02-03 -- ::wat::way <removed>
2024-02 03 -- Cap fix: TBu
2024-02-03 -- :?*:aparen::apparen
2024-02-04 -- :?*:memt::ment
2024-02-04 -- :?:sthe::s the
2024-02-04 -- :*:esle::else
2024-02-04 -- :*:with out::without
2024-02-04 -- :?*:efered::eferred
2024-02-04 -- :*:accidently::accidentally
2024-02 04 -- Cap fix: WOr
2024-02-04 -- :?*:useing::using
2024-02-04 -- :?*:comun::commun
2024-02-04 << :*:ahjk::ahk
2024-02-04 -- :?*:privale::privile
2024-02-04 -- :?*:siad::said
2024-02 04 -- Cap fix: APa
2024-02 04 -- Cap fix: ACo
2024-02 05 -- Cap fix: THu
2024-02-05 -- :*:transfered::transferred
2024-02 05 -- Cap fix: THe
2024-02-05 -- :?*:iopn::ion
2024-02 05 -- Cap fix: UDa
2024-02 05 -- Cap fix: BGr
2024-02 05 -- Cap fix: CUr
2024-02-05 << :*:been setup::been set up
2024-02-05 << :?:cthe::c the
2024-02-05 << ::averag::average
2024-02-05 -- :*:deside::decide
2024-02 05 -- Cap fix: WIt
2024-02-05 << :*:arren::arran
2024-02-05 -- :*:tyo::to
2024-02-05 -- :*:dificult::difficult
2024-02-05 -- :*:deside::decide
2024-02 05 -- Cap fix: GSe
2024-02 05 -- Cap fix: AT 
2024-02-05 << :?*:behaio::behavio
2024-02 05 -- Cap fix: THe
2024-02-05 -- :?*:durring::during
2024-02-05 -- :?*:cogntivie::cognitive
2024-02-05 -- :*:had send::had sent
2024-02-05 -- :?*:sttr::str
2024-02 05 -- Cap fix: THe
2024-02-05 << :?*:surpriz::surpris
2024-02-05 -- :?:;s::'s
2024-02-06 -- :*:accidently::accidentally
2024-02-06 -- ::fro::for
2024-02-06 -- ::eath::each
2024-02-06 -- :*C:english::English <made case-sensitive>
2024-02 06 -- Cap fix: COm
2024-02-06 -- :*:thge::the
2024-02-06 -- :*:recie::recei
2024-02-06 -- :*:deside::decide
2024-02 06 -- Cap fix: WIl
2024-02 06 -- Cap fix: SHe
2024-02 06 -- Cap fix: SHe
2024-02 06 -- Cap fix: LSc
2024-02-06 << :?*:clae::clea
2024-02-06 -- :?*:stong::strong
2024-02-06 -- :?*:cogntivie::cognitive
2024-02-06 -- :?*:nsern::ncern
2024-02 06 -- Cap fix: THe
2024-02 06 -- Cap fix: COm
2024-02 06 -- Cap fix: SEm
2024-02 06 -- Cap fix: SEm
2024-02 06 -- Cap fix: THe
2024-02-06 << :*:with be::will be
2024-02 06 -- Cap fix: AT 
2024-02 06 -- Cap fix: THe
2024-02 06 -- Cap fix: THe
2024-02 06 -- Cap fix: OTh
2024-02-06 -- ::t he::the
2024-02 06 -- Cap fix: SOu
2024-02-06 -- :*:enought::enough
2024-02-06 -- :?*:surpriz::surpris
2024-02-06 -- :?*:tecn::techn
2024-02-06 -- :*:puch::push
2024-02-06 -- :*:doen't::doesn't
2024-02-06 -- :?*:scipt::script
2024-02-06 -- :*:whould::would
2024-02-06 -- :?*:sourse::source
2024-02-06 -- :?*:nuei::nui
2024-02-06 << :?*:mroe::more
2024-02-07 -- :?*:exampt::exempt
2024-02-07 << :*:strugl::struggl
2024-02-07 -- :?*:surpriz::surpris
2024-02-07 << :*:alse::else
2024-02-07 -- :?*:belei::belie
2024-02-07 -- :*C:wich::which
2024-02-07 << ::averag::average
2024-02-07 -- :?*:surpriz::surpris
2024-02-07 -- :*:deside::decide
2024-02-07 -- :*:deside::decide
2024-02-07 -- :?*:nuei::nui
2024-02-07 -- :?*:tatch::tach
2024-02-07 -- :?*:warrent::warrant
2024-02-07 -- :?:;s::'s
2024-02-07 -- :?*:inprov::improv
2024-02-07 -- :?*:fucnt::funct
2024-02-07 -- :?*:wierd::weird
2024-02-08 -- :?*:anounc::announc
2024-02-08 -- Cap fix: COr [in: Visual Studio Code]
2024-02-08 -- Cap fix: TWh [in: Google Chrome]
2024-02-08 -- :*:eminat::emanat
2024-02-08 << :?*:emmin::emin
2024-02-08 -- Cap fix: GLo [in: StephenK@ckschools.org]
2024-02-09 -- Cap fix: FOr [in: Visual Studio Code]
2024-02-09 -- :*:hostring::hotstring
2024-02-09 -- :?*:cuas::caus
2024-02-09 << :*:a am::an am
2024-02-09 -- :?*:veiw::view
2024-02-09 -- :?*:greee::gree
2024-02-09 << :?*:asr::ase
2024-02-09 << Cap fix: CHe [in: Word]
2024-02-09 -- :?*:extention::extension
2024-02-09 -- Cap fix: YOu [in: Message (HTML) ]
2024-02-09 << :*:aroud::around
2024-02-09 -- Cap fix: YOu [in: StephenK@nbvc.org]
2024-02-09 -- :?:comming::coming
2024-02-09 -- Cap fix: TSo [in: Message (HTML) ]
2024-02-09 -- Cap fix: SHe [in: Message (HTML) ]
2024-02-09 -- Cap fix: FIl [in: Google Chrome]
2024-02-09 -- Cap fix: SWh [in: Google Chrome]
2024-02-09 << Cap fix: DOp [in: Google Chrome]
2024-02-09 -- Cap fix: THe [in: Google Chrome]
2024-02-09 << ::whic::which <removed>
2024-02-09 -- Cap fix: FOr [in: Google Chrome]
2024-02-09 -- :*:hellow::hello
2024-02-09 -- Cap fix: FOl [in: Message (HTML) ]
2024-02-09 -- Cap fix: THa [in: Google Chrome]
2024-02-09 -- :*C:ime::imme
2024-02-09 -- Cap fix: THe [in: Word]
2024-02-09 -- :*:wasnt::wasn't
2024-02-09 -- Cap fix: THe [in: Word]
2024-02-09 -- :?*:ateing::ating
2024-02-09 -- Cap fix: IT  [in: Word]
2024-02-09 << :?:lyu::ly
2024-02-10 -- Cap fix: THe [in: Word]
2024-02-10 << Cap fix: SHi [in: Word]
2024-02-10 -- Cap fix: CLi [in: Word]
2024-02-10 << Cap fix: ERx [in: Word]
2024-02-10 -- :*:puch::push
2024-02-10 -- Cap fix: COn [in: Visual Studio Code]
2024-02-10 -- :*:hellow::hello
2024-02-11 -- Cap fix: ELe [in: Visual Studio Code]
2024-02-11 -- :*:fouth::fourth
2024-02-11 -- :?*:efering::eferring
2024-02-11 << :?:bve::be
2024-02-11 -- :?*:focuss::focus
2024-02-11 -- :?*:focuss::focus
2024-02-11 -- :?:occured::occurred
2024-02-11 -- Cap fix: THa [in: Edit post]
2024-02-11 -- :?*:focuss::focus
2024-02-11 -- Cap fix: IT  [in: Edit post]
2024-02-11 -- :?*:useing::using
2024-02-11 -- :*:femail::female
2024-02-11 -- :?*:iopn::ion
2024-02-11 -- :*:dissap::disap
2024-02-11 -- :*C:english::English <made case-sensitive>
2024-02-11 -- :*:lable::label
2024-02-12 -- :*C:english::English <made case-sensitive>
2024-02-12 -- Cap fix: AT  [in: Message (HTML) ]
2024-02-12 -- :*:anual::annual
2024-02-12 << Cap fix: GLo [in: Visual Studio Code]
2024-02-12 << :?*:sucess::success
2024-02-12 -- Cap fix: THe [in: Visual Studio Code]
2024-02-12 -- :?:wass::was
2024-02-12 << :?*:concider::consider
2024-02-12 -- :*:tyo::to
2024-02-12 -- :*:year old::year-old
2024-02-12 -- :*:year old::year-old
2024-02-12 -- :*:year old::year-old
2024-02-12 << :?*:durring::during
2024-02-12 << :?*:iht::ith
2024-02-12 -- Cap fix: WEd [in: StephenK@xbnbxx.org]
2024-02-12 -- Cap fix: THe [in: Notepad]
2024-02-12 << Cap fix: TWh [in: Google Chrome]
2024-02-13 -- Cap fix: DOw [in: Visual Studio Code]
2024-02-13 << Cap fix: AKa [in: StephenK@xnbvbn.org]
2024-02-13 -- :*:to setup::to set up
2024-02-13 -- Cap fix: THe [in: Google Chrome]
2024-02-13 -- :*:esle::else
2024-02-13 -- :?*:focuss::focus
2024-02-13 -- :?*:extention::extension
2024-02-13 << Cap fix: JUs [in: Message (HTML) ]
2024-02-13 -- Cap fix: TO  [in: Message (HTML) ]
2024-02-13 -- :*:if is::it is
2024-02-13 << :*C:ime::imme
2024-02-13 -- :?*:exsis::exis
2024-02-13 << Cap fix: IDo [in: Help & Support]
2024-02-14 -- :?*:exsis::exis
2024-02-14 -- :?*:cogntivie::cognitive
2024-02-14 -- :?*:dgement::dgment
2024-02-14 -- Cap fix: ONc [in: Google Chrome]
2024-02-14 -- :*:resturant::restaurant
2024-02-14 -- :*:femail::female
2024-02-14 -- Cap fix: THe [in: Word]
2024-02-14 -- :?*:cogntivie::cognitive
2024-02-14 -- :?*:comun::commun
2024-02-14 << :*:tyo::to
2024-02-14 -- :*:mispell::misspell
2024-02-14 -- :*C:ime::imme
2024-02-14 << :?*:tje::the
2024-02-14 -- :?*:focuss::focus
2024-02-14 -- Cap fix: THa [in: Buttons/Scripts]
2024-02-14 -- :?*:appol::apol
2024-02-14 -- :*:it's name::its name
2024-02-14 -- :*:artical::article
2024-02-14 -- :*:inwhich::in which
2024-02-14 -- :*:interm::interim
2024-02-14 -- :?*:grama::gramma
2024-02-14 -- Cap fix: THe [in: Word]
2024-02-14 -- :?*:exsis::exis
2024-02-15 -- Cap fix: PRe [in: Google Chrome]
2024-02-15 << :*:wih::whi <removed>
2024-02-15 -- :?*:surect::surrect
2024-02-15 -- Cap fix: COl [in: Help & Support]
2024-02-15 -- Cap fix: THe [in: Help & Support]
2024-02-15 << Cap fix: DOe [in: Help & Support]
2024-02-15 -- Cap fix: YOu [in: Post a reply]
2024-02-15 -- :?*:grama::gramma
2024-02-15 -- :?*:tatch::tach
2024-02-15 -- Cap fix: COr [in: Google Chrome]
2024-02-15 -- :?*:ytou::you
2024-02-15 -- :?*:ceing::cing
2024-02-15 -- :*:reliz::realiz
2024-02-15 -- :*:doen't::doesn't
2024-02-15 -- :*:deside::decide
2024-02-15 -- Cap fix: COr [in: Post a reply]
2024-02-15 -- :*:thats::that's
2024-02-15 -- :?*:appol::apol
2024-02-15 -- :*C:ime::imme
2024-02-16 -- Cap fix: THe [in: AhkHero]
2024-02-16 -- Cap fix: DAr [in: AhkHero]
2024-02-16 -- Cap fix: THe [in: AhkHero]
2024-02-16 -- :?*:accomo::accommo
2024-02-17 -- :*:because of it's::because of its
2024-02-17 -- Cap fix: THa [in: Post a reply]
2024-02-17 -- :*:myown::my own
2024-02-17 -- Cap fix: FOr [in: Visual Studio Code]
2024-02-17 << Cap fix: NOt [in: Visual Studio Code]
2024-02-17 -- :*?:cment::cement
2024-02-17 -- :?*:scipt::script
2024-02-17 -- Cap fix: IBu [in: User Control Panel]
2024-02-17 -- Cap fix: THe [in: Word]
2024-02-17 -- :*?:cment::cement
2024-02-17 -- Cap fix: SPl [in: Visual Studio Code]
2024-02-18 << :?*:asr::ase
2024-02-18 -- Cap fix: COm [in: Visual Studio Code]
2024-02-18 -- Cap fix: COm [in: Visual Studio Code]
2024-02-18 -- :*:esle::else
2024-02-18 -- :?:teh::the
2024-02-18 -- :?:teh::the
2024-02-18 -- :?:teh::the
2024-02-18 -- :?:teh::the
2024-02-18 -- :?:teh::the
2024-02-18 -- :C:nad::and
2024-02-18 -- :C:nad::and
2024-02-18 << Cap fix: WEi [in: Post a reply]
2024-02-18 << Cap fix: CVa [in: Post a reply]
2024-02-18 -- :*:try and::try to
2024-02-18 -- Cap fix: TEh [in: Notepad]
2024-02-18 -- :?:teh::the
2024-02-18 << :?C:hc::ch
2024-02-18 -- Cap fix: THe [in: Post a reply]
2024-02-18 -- :*:doen't::doesn't
2024-02-18 -- :?*:exmapl::exampl
2024-02-18 -- :?*:responc::respons
2024-02-18 -- Cap fix: THe [in: Post a reply]
2024-02-18 -- :?:teh::the
2024-02-18 -- :C:nad::and
2024-02-18 -- :C:nad::and
2024-02-18 -- :C:nad::and
2024-02-18 -- :C:nad::and
2024-02-18 -- :?*:aiton::ation
2024-02-18 -- :*:a as::an as
2024-02-18 << Cap fix: TAn [in: Edit post]
2024-02-18 -- :?*:untion::unction
2024-02-18 << Cap fix: TYh [in: TED Notepad]
2024-02-18 -- :?*:cuas::caus
2024-02-18 -- Cap fix: WOr [in: Visual Studio Code]
2024-02-18 -- Cap fix: ENd [in: Visual Studio Code]
2024-02-18 -- Cap fix: FUl [in: Visual Studio Code]
2024-02-18 -- Cap fix: LEl [in: Visual Studio Code]
2024-02-18 -- Cap fix: CLi [in: Visual Studio Code]
2024-02-18 -- Cap fix: FOu [in: Visual Studio Code]
2024-02-18 -- Cap fix: COu [in: Visual Studio Code]
2024-02-19 -- Cap fix: COn [in: Visual Studio Code]
2024-02-19 -- Cap fix: FUl [in: Visual Studio Code]
2024-02-19 << Cap fix: COd [in: Edit post]
2024-02-19 << Cap fix: SLo [in: Visual Studio Code]
2024-02-19 -- Cap fix: SLo [in: Visual Studio Code]
2024-02-19 -- :*:it's own::its own
2024-02-19 -- Cap fix: COr [in: Post a reply]
2024-02-19 -- ::agains::against
2024-02-19 << Cap fix: SKt [in: Post a reply]
2024-02-19 -- Cap fix: THe [in: Post a reply]
2024-02-19 -- :?*:scipt::script
2024-02-19 -- :?*:scipt::script
2024-02-19 -- ::sample ietm::sample item
2024-02-19 -- :?*:cuas::caus
2024-02-19 -- :?*:casue::cause
2024-02-19 << Cap fix: FUl [in: Visual Studio Code]
2024-02-19 << Cap fix: FUn [in: MasterScript]
2024-02-19 -- Cap fix: FOr [in: MasterScript]
2024-02-20 -- Cap fix: THi [in: Visual Studio Code]
2024-02-20 -- :?*:ateing::ating
2024-02-20 << Cap fix: THa [in: Edit post]
2024-02-20 << :*:tyo::to
2024-02-20 -- Cap fix: THe [in: StephenK@ckschools.org]
2024-02-20 -- Cap fix: COd [in: Edit post]
2024-02-20 -- Cap fix: CHa [in: MyLifeOrganized]
2024-02-20 -- :?*:durring::during
2024-02-20 << :?*:asss::as
2024-02-20 -- :?*:casue::cause
2024-02-20 -- :?*:appol::apol
2024-02-20 << Cap fix: CLo [in: Visual Studio Code]
2024-02-20 -- Cap fix: CLi [in: Visual Studio Code]
2024-02-20 -- ::fro::for
2024-02-20 -- ::whic::which <removed>
2024-02-21 -- Cap fix: WOl [in: Poor Man's Rich Edit]
2024-02-21 -- :*:hellow::hello
2024-02-21 -- Cap fix: CLo [in: Visual Studio Code]
2024-02-21 -- Cap fix: THe [in: StephenK@ckschools.org]
2024-02-21 << :*:standars::standards
2024-02-21 << :?*:rixon::rison
2024-02-21 << :*:lower that::lower than
2024-02-21 << :?*:ernt::erent
2024-02-21 -- Cap fix: VCo [in: Word]
2024-02-21 -- :?*:veiw::view
2024-02-21 -- :*:untill::until
2024-02-21 -- :?*:catagor::categor
2024-02-21 -- :?*:durring::during
2024-02-21 -- :?*:eild::ield
2024-02-21 -- :?*:nsern::ncern
2024-02-21 << :?:tht::th
2024-02-21 -- :?*:beahv::behav
2024-02-21 -- :?*:durring::during
2024-02-21 -- :?*:warrent::warrant
2024-02-21 -- :*:hellow::hello
2024-02-21 -- Cap fix: THa [in: Post a reply]
2024-02-21 -- Cap fix: TIp [in: Visual Studio Code]
2024-02-22 -- :?*:cuas::caus
2024-02-22 -- :*:doen't::doesn't
2024-02-22 -- :?*:concider::consider
2024-02-22 -- :?*:breif::brief
2024-02-22 -- :?*:eild::ield
2024-02-22 -- :?*:tranf::transf
2024-02-22 -- :?*:commini::communi
2024-02-22 << Cap fix: CIn [in: Word]
2024-02-22 -- Cap fix: PRe [in: Word]
2024-02-22 -- :*:peculure::peculiar
2024-02-22 -- :?*:culure::culture
2024-02-22 -- :?:ign::ing
2024-02-22 -- :*:recommed::recommend
2024-02-22 -- :?*:commed::comed
2024-02-22 -- :C:nad::and
2024-02-22 -- :*:try and::try to
2024-02-22 -- :?*:cuas::caus
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:asr::ase
2024-02-22 << :?*:asr::ase
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :*:a ea::an ea
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:blihs::blish
2024-02-22 -- :?*:ihs::his
2024-02-22 -- :?*:asr::ase
2024-02-22 -- :?*:easr::ears
2024-02-22 -- :?*:easr::ears
2024-02-22 -- :?*:blihs::blish
2024-02-22 -- :?*:ihs::his
2024-02-22 -- :?*:charecter::character
2024-02-22 -- :?*:recter::rector
2024-02-22 -- :?*:ciev::ceiv
2024-02-22 -- :?*:ciev::ceiv
2024-02-22 -- :?*:memmor::memor
2024-02-22 -- :?*:memmor::memor
2024-02-22 -- :?*:comnt::cont
2024-02-22 -- :?*C:mnt::ment
2024-02-22 -- Cap fix: THi [in: Message (HTML) ]
2024-02-22 << :*:femail::female
2024-02-22 -- Cap fix: THe [in: Message (HTML) ]
2024-02-22 -- :?*:ngiht::night
2024-02-22 -- :*:wih::whi <removed>
2024-02-22 -- :?*:iht::ith
2024-02-22 -- :*:wih::whi <removed>
2024-02-22 -- :?*:iht::ith
2024-02-22 -- :*:wih::whi <removed>
2024-02-22 -- :?*C:mnt::ment
2024-02-22 -- :*:emn::enm
2024-02-22 -- :*:emn::enm
2024-02-22 -- :?*:docuemnt::document
2024-02-22 -- :?*:eceed::ecede
2024-02-22 -- :?*:eceed::ecede
2024-02-22 -- :?*:eceed::ecede
2024-02-22 -- :?*:eild::ield
2024-02-22 -- :?*:sesi::sessi
2024-02-22 -- :?*:exsis::exis
2024-02-22 -- Cap fix: HWe [in: StephenK@ckschools.org]
2024-02-22 -- Cap fix: FOr [in: StephenK@ckschools.org]
2024-02-22 -- :*:inperson::in-person
2024-02-22 -- :?*:http:\\::http://
2024-02-22 -- :?*:httpL::http:
2024-02-22 -- :?*:ivle::ivel
2024-02-22 -- :?*:ivle::ivel
2024-02-22 -- :?*:juristiction::jurisdiction
2024-02-22 -- :?*:tiction::tinction
2024-02-22 -- :?*:mmorow::morrow
2024-02-22 -- :?*:morow::morrow
2024-02-22 -- :?*:peice::piece
2024-02-22 -- :?*:ssurect::surrect
2024-02-22 -- :?*:surect::surrect
2024-02-22 -- :?*:tioj::tion
2024-02-22 -- :?*:tioj::tion
2024-02-22 -- :?:tioj::tion
2024-02-22 -- :?*:tiojn::tion
2024-02-22 -- :*:iconclas::iconoclas
2024-02-22 -- :?:clas::class
2024-02-22 -- :*:iconclas::iconoclas
2024-02-22 -- :?:clas::class
2024-02-22 -- :*:inteh::in the
2024-02-22 -- :?:teh::the
2024-02-22 -- :*:inteh::in the
2024-02-22 -- :?:teh::the
2024-02-22 -- :*:inteh::in the
2024-02-22 -- :*:managerial reign::managerial rein
2024-02-22 -- :?:ign::ing
2024-02-22 << :?:atn::ant
2024-02-22 -- :*:minsitr::ministr
2024-02-22 -- :*:itr::it
2024-02-22 -- :*:presed::presid
2024-02-22 -- :?:resed::ressed
2024-02-22 -- :*:hge::he
2024-02-22 -- :*:thge::the
2024-02-22 -- :*:thn::then
2024-02-22 -- :*:thn::then
2024-02-22 -- :?*:referal::referral
2024-02-22 -- :*:thsi::this
2024-02-22 -- :*C:hsi::his
2024-02-22 -- :?*:abotu::about
2024-02-22 -- :?:otu::out
2024-02-22 -- :?*:allign::align
2024-02-22 -- :?:ign::ing
2024-02-22 -- :?*:arign::aring
2024-02-22 -- :?*:bakc::back
2024-02-22 -- :?:kc::ck
2024-02-22 -- :?:kc::ck
2024-02-22 -- :?*:bakc::back
2024-02-22 -- :?:kc::ck
2024-02-22 -- :?:kc::ck
2024-02-22 -- :?*:degred::degrad
2024-02-22 -- :?:gred::greed
2024-02-22 -- :?:icaly::ically
2024-02-22 -- :?:icaly::ically
2024-02-22 -- Cap fix: WIn [in: Edit post]
2024-02-23 -- Cap fix: CLi [in: Visual Studio Code]
2024-02-23 -- :?*:referal::referral
2024-02-23 << :*:a ou::an ou
2024-02-23 -- :*:use to::used to
2024-02-23 << Cap fix: IEp [in: Message (HTML) ]
2024-02-23 << :?*:postiv::positiv
2024-02-23 -- Cap fix: THe [in: Word]
2024-02-23 << :?:ualy::ually
2024-02-23 -- :?*:oportun::opportun
2024-02-23 -- :?*:acadm::academ
2024-02-23 -- Cap fix: IAl [in: Message (HTML) ]
2024-02-23 << Cap fix: JRa [in: Message (HTML) ]
2024-02-23 -- Cap fix: PRe [in: Word]
2024-02-23 -- :?*:voiu::viou
2024-02-23 << :*:raing::rating
2024-02-23 -- :?*:pcial::pical
2024-02-23 << :*:raing::rating
2024-02-23 -- :?*:inprov::improv
2024-02-23 << :?*:loev::love
2024-02-23 << :*:raed::read
2024-02-23 -- :?*:comun::commun
2024-02-23 -- ::averag::average
2024-02-23 -- :*:gaol::goal
2024-02-23 -- Cap fix: IAr [in: Message (HTML) ]
2024-02-23 << Cap fix: RSp [in: Visual Studio Code]
2024-02-23 -- :?:comon::common
2024-02-24 << :*:hellow::hello
2024-02-24 -- Cap fix: TUe [in: Visual Studio Code]
2024-02-24 -- Cap fix: VBa [in: Visual Studio Code]
2024-02-24 << :?*:eild::ield
2024-02-24 << Cap fix: IAr [in: Post a new topic]
2024-02-24 -- :*:hte::the
2024-02-24 -- :*:hte::the
2024-02-24 << Cap fix: TRe [in: Visual Studio Code]
2024-02-24 -- :*:hwo::who
2024-02-24 -- :*:hwo::who
2024-02-24 -- :*:hellow::hello
2024-02-24 -- :?*:esnt::esent
2024-02-24 -- :*:hellow::hello
2024-02-24 -- Cap fix: GLo [in: Visual Studio Code]
2024-02-24 -- Cap fix: THi [in: TED Notepad]
2024-02-24 -- :*:hellow::hello
2024-02-24 -- :*:try and::try to
2024-02-24 -- Cap fix: DOw [in: Visual Studio Code]
2024-02-24 -- :*:hellow::hello
2024-02-24 -- Cap fix: SOu [in: Visual Studio Code]
2024-02-24 << :*:hellow::hello
2024-02-24 -- :C:nad::and
2024-02-24 -- :*:hellow::hello
2024-02-24 -- :*:nwe::new
2024-02-24 -- :?:onw::one
2024-02-24 -- ::thr::the
2024-02-24 -- :C:nad::and
2024-02-24 -- :*:threee::three
2024-02-25 -- :C:nad::and
2024-02-25 << :*:with in::within <fixed>
2024-02-25 -- :?*:durring::during
2024-02-25 -- :?*:grama::gramma
2024-02-25 -- Cap fix: DOe [in: Post a new topic]
2024-02-25 -- Cap fix: ENd [in: Visual Studio Code]
2024-02-25 -- Cap fix: FOr [in: Visual Studio Code]
2024-02-25 << Cap fix: ENd [in: Visual Studio Code]
2024-02-25 -- :*:hellow::hello
2024-02-25 -- :*:esle::else
2024-02-25 -- :?:dthe::d the
2024-02-25 -- :*:hellow::hello
2024-02-25 -- :*:mispell::misspell
2024-02-25 -- :*:sneek::sneak
2024-02-25 -- :*:a as::an as
2024-02-25 -- Cap fix: COr [in: Visual Studio Code]
2024-02-25 << ::whic::which <removed>
2024-02-25 -- Cap fix: COr [in: Visual Studio Code]
2024-02-25 -- Cap fix: THa [in: Notepad]
2024-02-25 -- :?*:wierd::weird
2024-02-25 -- :?*:atoin::ation
2024-02-25 -- Cap fix: TWi [in: Post a reply]
2024-02-25 -- Cap fix: ANd [in: Google Chrome]
2024-02-25 -- Cap fix: THi [in: Post a reply]
2024-02-25 -- :?:abley::ably
2024-02-25 -- :?*:scipt::script
2024-02-25 -- :?*:atoin::ation
2024-02-25 -- :?*:atoin::ation
2024-02-25 -- :?*:atoin::ation
2024-02-25 << Cap fix: REe [in: Post a reply]
2024-02-25 -- :?*:attemt::attempt
2024-02-25 -- :*:enought::enough
2024-02-25 -- :?*:atoin::ation
2024-02-25 -- Cap fix: THi [in: Edit post]
2024-02-25 -- :*:enought::enough
2024-02-26 << Cap fix: BSs [in: Visual Studio Code]
2024-02-26 -- Cap fix: IT  [in: Edit post]
2024-02-26 -- :?*:cment::cement
2024-02-26 -- :?*:eild::ield
2024-02-26 -- :*:gaol::goal
2024-02-26 << Cap fix: DSi [in: Word]
2024-02-26 -- Cap fix: DId [in: Visual Studio Code]
2024-02-26 -- :*:accidently::accidentally
2024-02-26 -- Cap fix: THe [in: Post a reply]
2024-02-26 << Cap fix: CCe [in: StephenK@ckschools.org]
2024-02-26 -- :?*:cmo::com
2024-02-26 -- Cap fix: FIr [in: Visual Studio Code]
2024-02-26 << Cap fix: COn [in: Visual Studio Code]
2024-02-26 << :*:nto::not
2024-02-26 -- Cap fix: SHi [in: Visual Studio Code]
2024-02-26 -- Cap fix: CLo [in: Visual Studio Code]
2024-02-26 -- Cap fix: GLo [in: Visual Studio Code]
2024-02-26 -- Cap fix: GLo [in: Visual Studio Code]
2024-02-27 -- :?*:foudn::found
2024-02-27 -- :*:untill::until
2024-02-27 << Cap fix: CLi [in: Visual Studio Code]
2024-02-27 -- :*:inperson::in-person
2024-02-27 -- :?*:offical::official
2024-02-27 -- Cap fix: COr [in: Visual Studio Code]
2024-02-27 << :*:a in::an in
2024-02-27 -- :*:a in::an in
2024-02-27 -- Cap fix: BEx [in: TED Notepad]
2024-02-27 -- Cap fix: RIg [in: Visual Studio Code [Administrator]]
2024-02-27 -- Cap fix: BUt [in: Visual Studio Code [Administrator]]
2024-02-27 -- Cap fix: COu [in: Visual Studio Code [Administrator]]
2024-02-27 -- :?*:focuss::focus
2024-02-27 -- :?*:rwit::writ
2024-02-27 -- Cap fix: COn [in: Word]
2024-02-27 -- Cap fix: SKi [in: Word]
2024-02-27 -- Cap fix: SOc [in: Word]
2024-02-27 -- :*:recie::recei
2024-02-27 -- Cap fix: WHi [in: Word]
2024-02-27 -- Cap fix: DIs [in: Word]
2024-02-27 -- :?*:lyed::lied
2024-02-27 -- :*:requr::requir
2024-02-28 -- Cap fix: FOl [in: Message (HTML) ]
2024-02-28 -- :?*:tatch::tach
2024-02-28 -- Cap fix: FOr [in: Visual Studio Code]
2024-02-28 -- Cap fix: RTh [in: Visual Studio Code]
2024-02-28 -- Cap fix: PRo [in: Message (HTML) ]
2024-02-28 -- :?*:lece::lesce
2024-02-28 -- Cap fix: COx [in: Google Chrome]
2024-02-28 -- Cap fix: THe [in: Word]
2024-02-28 -- :?*:exsis::exis
2024-02-28 -- Cap fix: RBu [in: Visual Studio Code [Administrator]]
2024-02-28 -- :*:enought::enough
2024-02-28 -- :?:dquater::dquarter
2024-02-29 -- Cap fix: THe [in: Post a reply]
2024-02-29 << :*:if is::it is
2024-02-29 -- Cap fix: THe [in: Visual Studio Code [Administrator]]
2024-02-29 << :*:eyt::yet
2024-02-29 -- Cap fix: COm [in: MasterScript]
2024-02-29 -- :?*:efered::eferred
2024-02-29 << ::fro::for
2024-02-29 -- :?:teh::the
2024-02-29 -- :?:teh::the
2024-02-29 -- :?*:focuss::focus
2024-02-29 -- :?*:iht::ith
2024-02-29 -- :?*:peice::piece
2024-03-01 -- Cap fix: THe [in: Post a reply]
2024-03-01 -- Cap fix: THe [in: Post a reply]
2024-03-01 -- :?*:ernt::erent
2024-03-01 -- :?:realy::really
2024-03-01 -- :*:everytime::every time
2024-03-01 -- Cap fix: FOr [in: Edit post]
2024-03-01 << :?:ualy::ually
2024-03-01 -- Cap fix: GIt [in: Post a reply]
2024-03-01 -- :*:begining::beginning
2024-03-01 -- :?:kc::ck
2024-03-01 -- :*:esle::else
2024-03-01 -- ::when ever::whenever
2024-03-01 -- :*:accidently::accidentally
2024-03-01 << :*:tyhe::they
2024-03-01 -- Cap fix: THe [in: Post a new topic]
2024-03-01 -- :?*:exsis::exis
2024-03-01 -- :*:i"m::I'm
2024-03-01 -- :*:a in::an in
2024-03-01 -- Cap fix: CLi [in: Visual Studio Code]
2024-03-01 -- :*:lefr::left
2024-03-01 -- Cap fix: SOr [in: Post a reply]
2024-03-01 -- Cap fix: COp [in: Visual Studio Code]
2024-03-02 -- Cap fix: IMp [in: Edit post]
2024-03-02 -- Cap fix: COr [in: AutoHotkey Community]
2024-03-02 -- :*:use to::used to
2024-03-02 -- Cap fix: NBu [in: AutoHotkey Community]
2024-03-02 -- :?*:efered::eferred
2024-03-02 -- Cap fix: HCa [in: Google Chrome]
2024-03-02 -- Cap fix: COr [in: Google Chrome]
2024-03-02 -- :*:retrun::return
2024-03-02 -- :?*:focuss::focus
2024-03-02 -- Cap fix: FOn [in: Save As]
2024-03-02 -- :?*:sampel::sample
2024-03-02 -- Cap fix: OPt [in: ToolTipOptions]
2024-03-03 << Cap fix: OIp [in: New Script]
2024-03-03 << ::ther::there <removed>
2024-03-04 << :?:onw::one
2024-03-04 -- Cap fix: THe [in: Message (HTML) ]
2024-03-04 << Cap fix: PAp [in: Message (HTML) ]
2024-03-04 << :*:ened::need
2024-03-04 -- :?:occured::occurred
2024-03-04 -- :*:less that::less than
2024-03-04 -- :?*:aggree::agree
2024-03-04 -- :*:senc::sens
2024-03-05 -- :*:enought::enough
2024-03-05 -- Cap fix: ALs [in: AutoHotkey Community]
2024-03-05 -- :*:untill::until
2024-03-05 << :?*:crti::criti
2024-03-05 << Cap fix: SHa [in: Visual Studio Code [Administrator]]
2024-03-05 -- Cap fix: OUr [in: Message (HTML) ]
2024-03-05 -- :*:use to::used to
2024-03-05 -- :*:dont::don't
2024-03-05 -- Cap fix: PRi [in: Visual Studio Code]
2024-03-05 -- Cap fix: COr [in: Visual Studio Code]
2024-03-05 << Cap fix: SPr [in: Visual Studio Code]
2024-03-05 << :*:hte::the
2024-03-06 -- Cap fix: SPl [in: Visual Studio Code]
2024-03-06 -- :*:if is::it is
2024-03-06 -- :*:if is::it is
2024-03-06 << :*:tyo::to
2024-03-06 -- :?*:tecn::techn
2024-03-06 -- Cap fix: FOr [in: StephenK@ckschools.org]
2024-03-06 -- Cap fix: OTh [in: StephenK@ckschools.org]
2024-03-06 -- :*:out of state::out-of-state
2024-03-06 -- :?*:grama::gramma
2024-03-06 -- Cap fix: IHi [in: Message (HTML) ]
2024-03-06 << ::tast::taste
2024-03-06 -- :?*:cogntivie::cognitive
2024-03-06 -- :?:sthe::s the
2024-03-06 -- :*:achei::achie
2024-03-06 -- :*:recie::recei
2024-03-06 -- :?*:seach::search
2024-03-06 -- :*:andd::and
2024-03-06 -- Cap fix: YOu [in: Edit post]
2024-03-07 -- Cap fix: HSh [in: MyLifeOrganized]
2024-03-07 -- :*:whther::whether
2024-03-07 -- :*:hte::the
2024-03-07 -- :?*:nsern::ncern
2024-03-07 -- Cap fix: TSh [in: Message (HTML) ]
2024-03-07 << :?*:tecn::techn
2024-03-07 << ::ther::there <removed>
2024-03-07 -- :*:tiome::time
2024-03-07 -- :?:blly::bly
2024-03-07 -- Cap fix: BUt [in: Google Chrome]
2024-03-07 -- ::t he::the
2024-03-07 -- :?:daty::day
2024-03-07 -- Cap fix: GUy [in: StephenK@ckschools.org]
2024-03-07 -- :?*:safte::safet
2024-03-07 -- :?:safty::safety
2024-03-08 -- :?*:eild::ield
2024-03-08 -- :*:transfered::transferred
2024-03-08 -- :?*:spesial::special
2024-03-08 -- :*:ToolTop::ToolTip
2024-03-08 -- Cap fix: TIp [in: Save As]
2024-03-08 -- Cap fix: DIt [in: TED Notepad]
2024-03-08 << :?*:grama::gramma
2024-03-08 -- :*:russion::Russian
2024-03-08 -- :*:hotsring::hotstring
2024-03-08 -- Cap fix: FOr [in: Edit post]
2024-03-08 -- :*:russion::Russian
2024-03-08 -- :*:russion::Russian
2024-03-08 -- :*:russion::Russian
2024-03-08 -- :?*:ceing::cing
2024-03-08 -- Cap fix: THi [in: Edit post]
2024-03-08 -- Cap fix: ALs [in: Edit post]
2024-03-08 -- :*:russion::Russian
2024-03-08 -- :*:russion::Russian
2024-03-08 -- :?*:asss::as
2024-03-08 -- :?:controll::control
2024-03-09 -- :*:senc::sens
2024-03-09 -- Cap fix: COu [in: AutoHotkey Toolkit [W]]
2024-03-09 -- ::tou::you
2024-03-09 << Cap fix: FIn [in: Post a reply]
2024-03-10 -- Cap fix: COl [in: Visual Studio Code]
2024-03-10 -- Cap fix: WHi [in: Visual Studio Code]
2024-03-10 << :?*:folow::follow
2024-03-10 -- Cap fix: USu [in: Visual Studio Code]
2024-03-10 -- :?:throught::through
2024-03-10 -- Cap fix: THe [in: Edit post]
2024-03-11 -- :?*:desided::decided
2024-03-11 -- :?*:exsis::exis
2024-03-11 -- :?*:surpriz::surpris
2024-03-11 << :*:tyo::to
2024-03-11 -- Cap fix: JOs [in: StephenK@ckschools.org]
2024-03-11 -- :*:enought::enough
2024-03-11 -- :?*:velent::valent
2024-03-11 -- :?*:sttr::str
2024-03-11 -- :?*:mialr::milar
2024-03-11 -- Cap fix: HOm [in: Excel]
2024-03-11 -- :?*:exsis::exis
2024-03-11 -- :?*:accro::acro
2024-03-11 << ::ther::there <removed>
2024-03-11 -- :?*:fucnt::funct
2024-03-11 -- :?:occured::occurred
2024-03-11 -- :*:asside::aside
2024-03-11 -- Cap fix: COl [in: AutoHotkey Toolkit [W]]
2024-03-12 -- Cap fix: THa [in: StephenK@ckschools.org]
2024-03-12 -- :?*:wnat::want
2024-03-12 -- Cap fix: AT  [in: Message (HTML) ]
2024-03-12 -- Cap fix: THe [in: Word]
2024-03-12 -- :?*:concider::consider
2024-03-12 -- Cap fix: THe [in: Word]
2024-03-12 -- :?*:responc::respons
2024-03-12 -- :?*:concider::consider
2024-03-12 -- :*:as apposed to::as opposed to
2024-03-12 -- :*:hte::the
2024-03-12 << Cap fix: DSi [in: Word]
2024-03-12 -- :?*:posess::possess
2024-03-12 << :?*:oulb::oubl
2024-03-13 -- :*:threee::three
2024-03-13 -- ::thr::the
2024-03-13 -- :?*:cogntivie::cognitive
2024-03-13 -- :*:enought::enough
2024-03-13 -- Cap fix: WIl [in: Word]
2024-03-13 -- ::;ils::Intensive Learning Services (ILS)
2024-03-13 -- Cap fix: SKi [in: Word]
2024-03-13 << :?:onw::one
2024-03-13 -- ::averag::average
2024-03-13 << :?*:acadm::academ
2024-03-13 -- :?*:focuss::focus
2024-03-13 -- :?:itiy::ity
2024-03-13 -- :?*:durring::during
2024-03-13 -- :*:i"m::I'm
2024-03-13 -- :?*:cuas::caus
2024-03-13 -- :*:exection::execution
2024-03-13 -- Cap fix: THi [in: Meeting  ]
2024-03-13 -- Cap fix: THi [in: Meeting  ]
2024-03-13 -- Cap fix: VIn [in: StephenK@ckschools.org]
2024-03-14 -- :?*:annn::ann
2024-03-14 -- :?*:annn::ann
2024-03-14 -- :?*:annn::ann
2024-03-14 -- :?*:iopn::ion
2024-03-14 -- :*:Karent::Karen
2024-03-14 -- Cap fix: THe [in: Google Chrome]
2024-03-14 -- :*:amme::ame
2024-03-14 -- :?*:responc::respons
2024-03-14 -- Cap fix: THe [in: Google Chrome]
2024-03-14 -- :*:amme::ame
2024-03-14 -- Cap fix: CUr [in: Google Chrome]
2024-03-14 -- :*:sould::should
2024-03-14 -- Cap fix: CCe [in: StephenK@ckschools.org]
2024-03-14 -- :?*:acom::accom
2024-03-14 -- :?*:offical::official
2024-03-14 -- :?*:iblit::ibilit
2024-03-14 -- :?*:eild::ield
2024-03-14 << ::wat::way <removed>
2024-03-14 -- ::thru::through
2024-03-14 -- Cap fix: SUm [in: Message (HTML) ]
2024-03-14 -- :?*:myu::my
2024-03-14 << :*:dont::don't
2024-03-14 -- Cap fix: NCl [in: Visual Studio Code]
2024-03-14 -- :*:retrun::return
2024-03-15 -- Cap fix: HDi [in: @highlight | Facebook]
2024-03-15 -- :?*:appol::apol
2024-03-15 -- Cap fix: THi [in: Google Chrome]
2024-03-15 -- :*:resently::recently
2024-03-15 -- ::t he::the
2024-03-15 << ::wat::way <removed>
2024-03-15 -- :?*:scipt::script
2024-03-15 -- :?*:oducab::oducib
2024-03-15 -- :*:i"m::I'm
2024-03-15 -- :?*:referal::referral
2024-03-15 -- :*:sudent::student
2024-03-15 -- :?*:referal::referral
2024-03-15 -- :?*:efered::eferred
2024-03-15 -- Cap fix: WIl [in: StephenK@ckschools.org]
2024-03-15 -- :?*:lyed::lied
2024-03-15 -- :*:untill::until
2024-03-15 -- :*:sneek::sneak
2024-03-15 -- Cap fix: TIp [in: Visual Studio Code]
2024-03-15 -- Cap fix: COl [in: Visual Studio Code]
2024-03-15 -- Cap fix: COl [in: Visual Studio Code]
2024-03-15 -- Cap fix: THe [in: Visual Studio Code]
2024-03-16 -- Cap fix: COr [in: Visual Studio Code]
2024-03-16 -- :?*:lyed::lied
2024-03-16 << Cap fix: TYh [in: Message (HTML) ]
2024-03-16 -- Cap fix: COl [in: Visual Studio Code]
2024-03-16 << :?*:guement::gument
2024-03-16 -- Cap fix: CLi [in: Visual Studio Code]
2024-03-16 -- Cap fix: FIn [in: Visual Studio Code]
2024-03-16 -- :*:hellow::hello
2024-03-16 -- :*:hellow::hello
2024-03-16 -- :?*C:mnt::ment
2024-03-16 -- :?*C:mnt::ment
2024-03-16 -- :?*C:mnt::ment
2024-03-16 -- :?*C:mnt::ment
2024-03-16 -- Cap fix: SHo [in: Post a new topic]
2024-03-17 -- Cap fix: THe [in: Post a reply]
2024-03-17 << Cap fix: OIn [in: Post a reply]
2024-03-17 -- Cap fix: CLi [in: Visual Studio Code]
2024-03-17 -- Cap fix: COm [in: WayText]
2024-03-18 -- Cap fix: IHi [in: Message (HTML) ]
2024-03-18 << :?*:tranf::transf
2024-03-18 -- :*:had send::had sent
2024-03-18 -- :*:there by::thereby
2024-03-18 -- ::ther::there <removed>
2024-03-18 -- :*:try and::try to
2024-03-18 << ::thr::the
2024-03-18 -- :*:dissap::disap
2024-03-18 -- :?*:orht::orth
2024-03-18 << :?*:signit::signat
2024-03-18 -- Cap fix: THe [in: Word]
2024-03-18 -- :?*:exsis::exis
2024-03-18 -- Cap fix: IHe [in: MyLifeOrganized]
2024-03-18 << Cap fix: REu [in: Google Chrome]
2024-03-18 -- Cap fix: WOr [in: Google Chrome]
2024-03-18 -- Cap fix: GLo [in: Visual Studio Code]
2024-03-18 -- Cap fix: GLo [in: Visual Studio Code]
2024-03-18 -- Cap fix: GLo [in: Visual Studio Code]
2024-03-19 -- :*:had send::had sent
2024-03-19 -- :?*:durring::during
2024-03-19 -- :?:fthe::f the
2024-03-19 << Cap fix: NJa [in: Word]
2024-03-19 << Cap fix: KJa [in: Word]
2024-03-19 -- :?*:grama::gramma
2024-03-19 -- Cap fix: SAr [in: Google Chrome]
2024-03-19 -- :*:the follow up::the follow-up
2024-03-19 -- :*:enought::enough
2024-03-19 << :?*:crti::criti
2024-03-19 << :*:eral::real
2024-03-19 -- Cap fix: PRe [in: MyLifeOrganized]
2024-03-19 -- Cap fix: RWr [in: MyLifeOrganized]
2024-03-19 -- :?*:guement::gument
2024-03-19 << Cap fix: EDr [in: Message (HTML) ]
2024-03-19 -- :*:be build::be built
2024-03-19 -- :?*:anounc::announc
2024-03-19 -- :?*:efered::eferred
2024-03-19 -- ::fo::of
2024-03-20 -- :*:transfered::transferred
2024-03-20 -- :*:transfered::transferred
2024-03-20 -- :?*:iblit::ibilit
2024-03-20 -- :?:herefor::herefore
2024-03-20 -- Cap fix: THe [in: Word]
2024-03-20 << :?*:allth::alth
2024-03-20 -- :*:Karent::Karen
2024-03-20 -- Cap fix: TCa [in: StephenK@ckschools.org]
2024-03-20 -- Cap fix: DSt [in: Visual Studio Code]
2024-03-20 -- :?*:aggree::agree
2024-03-20 -- Cap fix: THa [in: StephenK@ckschools.org]
2024-03-21 -- Cap fix: GLo [in: Visual Studio Code]
2024-03-21 -- :*:ToolTop::ToolTip
2024-03-21 -- Cap fix: GLo [in: Visual Studio Code]
2024-03-21 << Cap fix: NSt [in: Visual Studio Code]
2024-03-21 -- :*:less that::less than
2024-03-21 -- :*:less that::less than
2024-03-21 -- :*:hge::he
2024-03-21 -- :?*:fomr::form
2024-03-21 -- :*:note worthy::noteworthy
2024-03-21 -- :?*:mialr::milar
2024-03-21 -- Cap fix: THe [in: Word]
2024-03-21 << :?*:grama::gramma
2024-03-21 -- :?*:inital::initial
2024-03-21 -- Cap fix: DMa [in: Visual Studio Code]
2024-03-21 << Cap fix: SDa [in: Visual Studio Code]
2024-03-21 -- :*:recommed::recommend
2024-03-21 -- :*:recomen::recommen
2024-03-21 << Cap fix: CVa [in: Google Chrome]
2024-03-21 << :*:lastr::last
2024-03-22 -- Cap fix: THe [in: StephenK@ckschools.org]
2024-03-22 -- :*:artical::article
2024-03-22 -- :*:try and::try to
2024-03-22 -- :?*:perfom::perform
2024-03-22 -- ::averag::average
2024-03-22 -- Cap fix: PRo [in: Word]
2024-03-22 -- :?*:strengh::strength
2024-03-22 -- :?*:referal::referral
2024-03-22 -- :?*:nsern::ncern
2024-03-22 -- :?*:cogntivie::cognitive
2024-03-22 -- Cap fix: PHo [in: Google Chrome]
2024-03-22 -- Cap fix: PHo [in: Google Chrome]
2024-03-22 -- :*:recie::recei
2024-03-23 << Cap fix: HSh [in: Post a reply]
2024-03-23 -- :*:i"m::I'm
2024-03-23 << :?:ualy::ually
2024-03-23 << :?:lwats::lways
2024-03-23 -- :*:doen't::doesn't
2024-03-23 -- Cap fix: WHi [in: Visual Studio Code]
2024-03-23 -- Cap fix: ENd [in: Visual Studio Code]
2024-03-23 -- Cap fix: CCh [in: Visual Studio Code]
2024-03-23 -- Cap fix: FUn [in: Visual Studio Code]
2024-03-23 << Cap fix: WIt [in: Edit post]
2024-03-23 -- :*:senc::sens
2024-03-23 -- :?*:exsis::exis
2024-03-23 -- :*:sucide::suicide
2024-03-23 << Cap fix: THi [in: StephenK@ckschools.org]
2024-03-23 -- :?*:extention::extension
2024-03-23 -- Cap fix: ELs [in: Visual Studio Code]
2024-03-23 -- Cap fix: FOr [in: Visual Studio Code]
2024-03-23 -- :?*:metn::ment
2024-03-23 << :*:retun::return
2024-03-23 -- :?*:wrok::work
2024-03-23 -- :?*:focuss::focus
2024-03-25 -- Cap fix: THe [in: Meeting  ]
2024-03-25 -- :*C:english::English <made case-sensitive>
2024-03-25 -- Cap fix: HOm [in:  Compatibility Mode]
2024-03-25 -- :?*:appol::apol
2024-03-25 -- :?:lyu::ly
2024-03-25 << :?*:aplic::applic
2024-03-25 -- :?*:extention::extension
2024-03-25 -- :?:itiy::ity
2024-03-25 -- :?*:extention::extension
2024-03-25 -- Cap fix: OTh [in: StephenK@ckschools.org]
2024-03-25 -- :?*:extention::extension
2024-03-25 -- :*:everytime::every time
2024-03-25 -- :?*:ssition::sition
2024-03-25 << Cap fix: MCo [in: Visual Studio Code]
2024-03-25 << Cap fix: MCo [in: Visual Studio Code]
2024-03-25 -- Cap fix: THe [in: Google Chrome]
2024-03-25 -- Cap fix: SHi [in: Visual Studio Code]
2024-03-26 -- :*C:english::English <made case-sensitive>
2024-03-26 -- :?:occured::occurred
2024-03-26 -- Cap fix: THe [in: Post a reply]
2024-03-26 -- :?*:patab::patib
2024-03-26 -- :?*:osible::osable
2024-03-26 << :?*:tatn::tant
2024-03-26 << :?*:fomr::form
2024-03-26 -- :*:mispell::misspell
2024-03-27 -- :*:sould::should
2024-03-27 -- ::fro::for
2024-03-27 -- :?*:fomr::form
2024-03-27 -- :?*:combon::combin
2024-03-27 << :*:helf::held
2024-03-27 -- :?*:aggree::agree
2024-03-27 -- :?*:exsis::exis
2024-03-27 -- Cap fix: ALl [in: Visual Studio Code]
2024-03-27 -- Cap fix: TOt [in: Visual Studio Code]
2024-03-27 -- Cap fix: CVx [in: Notepad]
2024-03-27 -- Cap fix: KJh [in: Notepad]
2024-03-28 -- :?*:reing::ring
2024-03-28 -- :?*:acom::accom
2024-03-28 -- :*:medievel::medieval
2024-03-28 -- :*:by it's::by its
2024-03-28 -- :?:itiy::ity
2024-03-28 -- :*:it's own::its own
2024-03-28 -- Cap fix: SOm [in: AutoHotkey Community]
2024-03-28 -- Cap fix: OTh [in: AutoHotkey Community]
2024-03-28 -- :?*:ytou::you
2024-03-28 -- :*:to setup::to set up
2024-03-28 -- :?*:cogntivie::cognitive
2024-03-28 -- :?*:nlcu::nclu
2024-03-28 << Cap fix: BUt [in: Visual Studio Code]
2024-03-28 -- :?*:edabl::edibl
2024-03-28 << Cap fix: BUt [in: Post a reply]
2024-03-28 -- :?*:cuas::caus
2024-03-28 -- ::orif::ORIF
2024-03-28 -- ::orif::ORIF
2024-03-28 << :*?:uyt::ut
2024-03-28 -- :*:hte::the
2024-03-28 -- :*:untill::until
2024-03-28 -- ::inprocess::in process
2024-03-28 -- :*:transfered::transferred
2024-03-28 -- ::inprocess::in process
2024-03-28 -- Cap fix: THe [in: StephenK@ckschools.org]
2024-03-28 -- :*:senc::sens
2024-03-28 << :*:accidently::accidentally
2024-03-28 -- :?*:cuas::caus
2024-03-28 -- :*?:uyt::ut
2024-03-28 -- :?:occure::occur
2024-03-28 -- :?*:durring::during
2024-03-28 -- :?*:durring::during
2024-03-28 -- Cap fix: WIn [in: Visual Studio Code]
2024-03-28 << :*:aroud::around
2024-03-28 -- :*?:uyt::ut
2024-03-28 -- Cap fix: BLu [in: Visual Studio Code]
2024-03-28 -- :?*:explanit::explanat
2024-03-28 -- Cap fix: RBu [in: Visual Studio Code]
2024-03-28 -- Cap fix: MBu [in: Visual Studio Code]
2024-03-28 -- Cap fix: BPu [in: Edit post]
2024-03-28 -- :?:occured::occurred
2024-03-28 -- :C:orif::ORIF
2024-03-28 -- :?:occured::occurred
2024-03-28 << :*:compair::compare
2024-03-28 -- :C:advil::Advil
2024-03-29 << Cap fix: SAs [in: Visual Studio Code]
2024-03-29 -- Cap fix: PRe [in: Visual Studio Code]
2024-03-29 -- Cap fix: CLo [in: Visual Studio Code]
2024-03-29 << Cap fix: TWe [in: Visual Studio Code]
2024-03-29 -- :?*:descus::discus
2024-03-29 << ::fro::for
2024-03-29 -- :?*:ceing::cing
2024-03-29 -- :*:accidently::accidentally
2024-03-29 -- :?*:durring::during
2024-03-29 -- :*:retun::return
2024-03-29 -- :*:i"m::I'm
2024-03-29 -- Cap fix: PRe [in: Post a new topic]
2024-03-29 -- Cap fix: WHa [in: Post a new topic]
2024-03-30 -- :?:ign::ing
2024-03-30 << Cap fix: THa [in: Post a reply]
2024-03-30 -- :*:senc::sens
2024-03-30 -- :?*:seach::search
2024-03-30 -- Cap fix: THa [in: Post a reply]
2024-03-30 -- Cap fix: THa [in: AhkHero]
2024-03-30 << Cap fix: DSo [in: AhkHero]
2024-03-30 << Cap fix: TCh [in: AhkHero]
2024-03-30 -- :*?:seee::see
2024-03-30 << :*:afair::affair
2024-03-30 -- :?*:inng::ing
2024-03-30 -- :?:lyu::ly
2024-03-30 -- :?*:entgh::ength
2024-03-30 -- :*:ahjk::ahk
2024-03-30 << Cap fix: ERl [in: Visual Studio Code]
2024-03-30 -- :?*:durring::during
2024-03-31 -- :*:this data::these data
2024-03-31 << :*:reult::result
2024-03-31 << :*:ubli::publi
2024-03-31 -- :*:ubli::publi
2024-03-31 -- Cap fix: ICa [in: TED Notepad]
2024-03-31 -- :*:artical::article
2024-03-31 << :*:a ap::an ap
2024-03-31 -- :*:a ap::an ap
2024-03-31 -- :*:year old::year-old
2024-03-31 -- :*:everytime::every time
2024-03-31 -- :*:ubli::publi
2024-03-31 -- Cap fix: GLo [in: Visual Studio Code]
2024-03-31 << :?*:exsis::exis
2024-03-31 -- :*:friut::fruit
2024-03-31 -- Cap fix: DOn [in: Visual Studio Code]
2024-04-02 -- :?*:extention::extension
2024-04-02 -- Cap fix: AUt [in: Post a reply]
2024-04-02 << :*:rre::re
2024-04-02 -- Cap fix: COr [in: Post a reply]
2024-04-02 -- :*:rre::re
2024-04-02 -- :*:rre::re
2024-04-02 -- Cap fix: COr [in: Post a reply]
