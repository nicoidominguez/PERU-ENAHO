*===============================================================================
*
* ENAHO
* Pooled 2004-2020
* 
* Author: 		Nicolas Dominguez (nd2324@nyu.edu)
* Last mod: 	Sep 2022
* Version: 		Stata 16.1
*
*===============================================================================

version 16.1
clear all
set more off, perm

**DB
glo db	"D:\Dropbox"
glo id	"$db\Databases\INEI\ENAHO\Met_Act"

**Databases (DB)
glo dt	"$id\Databases"

*===============================================================================
* Standardizing cross-sections 2004-2020
*===============================================================================

forvalues i=2004/2020 {
di "*--- Year `i' ---*"
*-------------------------------------------------------------------------------
* modulo 100
*-------------------------------------------------------------------------------
{
di "*--- modulo 100 ---*"
if		(`i'>=2004&`i'<=2006) | (`i'>=2018&`i'<=2019) {
qui: use mes conglome vivienda hogar factor07 p102 p103 p103a p104 p104a p110 p111* ///
		p1121-p1127 p113* p1141-p1145 result fecent ///
		using "$id\\`i'\Files\DTA\enaho01-`i'-100.dta", clear
}
else if	`i'>=2007&`i'<=2017 {
qui: use mes conglome vivienda hogar factor07 p102 p103 p103a p104 p104a p110 p111* ///
		p1121-p1127 p113* p1141-p1145 result fecent *ccpp longitud latitud ///
		using "$id\\`i'\Files\DTA\enaho01-`i'-100.dta", clear
}
qui: cap destring latitud, replace float ignore("*")
qui: cap ren ccpp codccpp
qui: destring mes conglome vivienda hogar, replace // 'int'-type for key variables
qui: gen int anho = `i' // survey-year variable
qui: compress
qui: sort anho mes conglome vivienda hogar
if `i'>=2004&`i'<=2006 {
	qui: recode p102 (4=5) (5=6) (6=7) (7=8) (8=9) 
	qui: rename (p1133 p1134 p1135 p1136 p1137) (xp1134 xp1135 xp1136 xp1137 xp1138)
	qui: rename xp113* p113*
}
else if `i'>=2007&`i'<=2020 {
	qui: recode p102 (4=3)
	qui: replace p1132=1 if p1133==1&p1132!=1
	qui: drop p1133
}
if `i'>=2004&`i'<=2011 {
	qui: recode p111 (3=4) (4=5) (5=6) (6=8)
}
else if `i'>=2012&`i'<=2020 {
	qui: rename p111a p111
}
qui: save "$dt\temp-`i'-100.dta", replace
}
*-------------------------------------------------------------------------------
* modulo 200
*-------------------------------------------------------------------------------
{
di "*--- modulo 200 ---*"
if		`i'< 2018 {
qui: use mes conglome vivienda hogar codperso facpob07 p203* p204 p205 p206 p207 ///
		p208a p208a1 p208a2 p209 p210 ubigeo dominio estrato ///
		using "$id\\`i'\Files\DTA\enaho01-`i'-200.dta", clear // pregunta sobre tipo de actividad laboral del roster (p211a-p211d) esta desde 2012
}
else if	`i'>=2018 {
qui: use mes conglome vivienda hogar codperso facpob07 p203* p204 p205 p206 p207 ///
		p208a p209 p210 ubigeo dominio estrato ///
		using "$id\\`i'\Files\DTA\enaho01-`i'-200.dta", clear // en bd 2018, no hay preguntas 208a1 208a2 (nacio en este distrito, en cual nacio)
}
qui: destring mes conglome vivienda hogar codperso, replace // 'int'-type for key variables
qui: gen int anho = `i' // survey-year variable
qui: compress
qui: sort anho mes conglome vivienda hogar codperso
qui: replace ubigeo=trim(ubigeo)
qui: replace ubigeo="0"+ubigeo if length(ubigeo)==5
if `i'>=2004&`i'<=2007 {
	qui: tostring p208a2, replace
	qui: replace p208a2="0"+p208a2 if length(p208a2)==5
}
qui: save "$dt\temp-`i'-200.dta", replace
}
*-------------------------------------------------------------------------------
* modulo 300
*-------------------------------------------------------------------------------
{
di "*--- modulo 300 ---*"
qui: use mes conglome vivienda hogar codperso codinfor p300a p301a p301b p301c ///
		p301d p303 p304* p305 p306 p307 p308a p308b p308c p308d ///
		using "$id\\`i'\Files\DTA\enaho01a-`i'-300.dta", clear // pregunta sobre percepcion en educacion (p308b*) esta desde 2012
qui: destring mes conglome vivienda hogar codperso codinfor, replace // 'int'-type for key variables
qui: gen int anho = `i' // survey-year variable
qui: compress
qui: sort anho mes conglome vivienda hogar codperso
qui: save "$dt\temp-`i'-300.dta", replace
}
*-------------------------------------------------------------------------------
* modulo 400
*-------------------------------------------------------------------------------
{
di "*--- modulo 400 ---*"
qui: use mes conglome vivienda hogar codperso codinfor p400a* p419* ///
		using "$id\\`i'\Files\DTA\enaho01a-`i'-400.dta", clear
qui: destring mes conglome vivienda hogar codperso codinfor, replace // 'int'-type for key variables
qui: gen int anho = `i' // survey-year variable
qui: compress
qui: sort anho mes conglome vivienda hogar codperso
qui: save "$dt\temp-`i'-400.dta", replace
}
*-------------------------------------------------------------------------------
* modulo 500
*-------------------------------------------------------------------------------
{
di "*--- modulo 500 ---*"
qui: use "$id\\`i'\Files\DTA\enaho01a-`i'-500.dta", clear
qui: drop a*o ubigeo dominio estrato p500n p500i p559* t559* z559* d559* i559* ///
		p59f* p560* d560* i560* p20* p301a
qui: destring mes conglome vivienda hogar codperso codinfor, replace // 'int'-type for key variables
qui: gen int anho = `i' // survey-year variable
qui: compress
qui: sort anho mes conglome vivienda hogar codperso
if		`i'>=2004&`i'<=2008 {
	foreach x in p d {
		foreach y in a b c d e {	
			qui: capture rename (`x'5566`y' `x'5567`y') (`x'5568`y' `x'5569`y') // capture neccesary b/c 'd556*i' only matches for i=c,e
		}
	}
}
else if `i'>=2009&`i'<=2013 {
	foreach x in p d {
		foreach y in a b c d e {	
			qui: capture rename (`x'5567`y' `x'5568`y') (`x'5568`y' `x'5569`y') // capture neccesary b/c 'd556*i' only matches for i=c,e
		}
	}
}
if		`i'>=2004&`i'<=2006 {
	foreach x in p d i {
		qui: rename (`x'524cc1 `x'524c1 `x'524d1) (`x'524c1 `x'524d1 `x'524e1)
		qui: rename (`x'538cc1 `x'538c1 `x'538d1) (`x'538c1 `x'538d1 `x'538e1)
	}
}
if		`i'==2007 {
	qui: destring p554r4, replace
}
if		`i'==2007 {
	qui: rename p516r4x p516r4
}
if		`i'>=2008&`i'<=2020 {
	qui: tostring p500b1 p500d1, replace
}
qui: save "$dt\temp-`i'-500.dta", replace
}
*-------------------------------------------------------------------------------
* modulo 612
*-------------------------------------------------------------------------------
{
di "*--- modulo 612 ---*"
qui: use mes conglome vivienda hogar p612n p612 using "$id\\`i'\Files\DTA\enaho01-`i'-612.dta", clear
if `i'>=2004&`i'<=2006 {
	qui: recode p612n	( 1= 1) ( 2= 3) ( 3= 2) ( 4=12) ( 5=15) ( 6= 4) ( 7= 6) ( 8=13) ///
					( 9= 8)	(10=10) (11=11) (12=14) (13= 9) (14=16) (15=17) (16=19) ///
					(17=18) (18=21) (19=20) (20= 7) (21=22) (22=23)
}
qui: order mes conglome vivienda hogar p612n
qui: reshape wide p612, i(mes conglome vivienda hogar) j(p612n) 
qui: keep mes conglome vivienda hogar p6121-p61221
qui: destring mes conglome vivienda hogar, replace // 'int'-type for key variables
qui: gen int anho = `i' // survey-year variable
qui: compress
qui: sort anho mes conglome vivienda hogar
qui: save "$dt\temp-`i'-612.dta", replace
}
*-------------------------------------------------------------------------------
* modulo 700 (programas sociales)
*-------------------------------------------------------------------------------
{
if `i'>=2012&`i'<=2020 {
	di "*--- modulo 700 ---*"
	qui: use mes conglome vivienda hogar p710_* using "$id\\`i'\Files\DTA\enaho01-`i'-700.dta", clear
	if `i'>=2012&`i'<=2013 {
		qui: drop	p710_04 // 2012-2013: DEVIDA (drogas) <- no vuelve a aparecer en la lista ever since
		qui: rename p710_03 p710_04 // juntos
	}
	qui: order mes conglome vivienda hogar p710_04 p710_05 // juntos y pension65
	qui: keep  mes conglome vivienda hogar p710_04 p710_05
	qui: destring mes conglome vivienda hogar, replace // 'int'-type for key variables
	qui: gen int anho = `i' // survey-year variable
	qui: compress
	qui: sort anho mes conglome vivienda hogar
	qui: save "$dt\temp-`i'-700.dta", replace
}
}
*-------------------------------------------------------------------------------
* sumaria
*-------------------------------------------------------------------------------
{
di "*--- sumaria ---*"
qui: use mes conglome vivienda hogar mieperho totmieho percepho ingbruhd ingnethd ///
		pagesphd ingindhd ingauthd insedthd insedlhd paesechd ingseihd isecauhd ///
		ingexthd ingtrahd ingtexhd ingtprhd ingtpuhd ingrenhd ingoexhd ingmo1hd ///
		ingmo2hd inghog1d inghog2d gashog1d gashog2d ///
		ingtpu* ingtprhd ///
		linea linpe pobreza ///
		ia01hd ig06hd ig08hd sig24 sig26 ///
		gru13hd1 gru13hd2 gru13hd3 gru23hd1 gru23hd2 gru23hd3 gru24hd ///
		gru33hd1 gru33hd2 gru33hd3 gru34hd gru43hd1 gru43hd2 gru43hd3 gru44hd ///
		gru53hd1 gru53hd2 gru53hd3 gru54hd gru63hd1 gru63hd2 gru63hd3 gru64hd ///
		gru73hd1 gru73hd2 gru73hd3 gru74hd gru83hd1 gru83hd2 gru83hd3 gru84hd ///
		gru14hd3 gru14hd4 gru14hd5 sg42d sg42d1 sg42d2 sg42d3 ///
		ga04hd ///
		using "$id\\`i'\Files\DTA\sumaria-`i'.dta", clear
qui: destring mes conglome vivienda hogar, replace // 'int'-type for key variables
qui: gen int anho = `i' // survey-year variable
qui: compress
qui: order anho mes conglome vivienda hogar
qui: sort anho mes conglome vivienda hogar
qui: save "$dt\temp-`i'-sumaria.dta", replace
}
*-------------------------------------------------------------------------------
* merging modulo 100, 200, 300, 400, 500 & 612
*-------------------------------------------------------------------------------
{
di "*--- merging... ---*"
qui: use "$dt\temp-`i'-100.dta", clear 
qui: mer 1:m anho mes conglome vivienda hogar			using "$dt\temp-`i'-200.dta", gen(_m_200)
qui: mer 1:1 anho mes conglome vivienda hogar codperso	using "$dt\temp-`i'-300.dta", gen(_m_300)
qui: mer 1:1 anho mes conglome vivienda hogar codperso	using "$dt\temp-`i'-400.dta", gen(_m_400)
qui: mer 1:1 anho mes conglome vivienda hogar codperso	using "$dt\temp-`i'-500.dta", gen(_m_500)
qui: mer m:1 anho mes conglome vivienda hogar			using "$dt\temp-`i'-612.dta", gen(_m_612)
if `i'>=2012 {
qui: mer m:1 anho mes conglome vivienda hogar			using "$dt\temp-`i'-700.dta", gen(_m_700)
}
qui: mer m:1 anho mes conglome vivienda hogar			using "$dt\temp-`i'-sumaria.dta", gen(_m_sum)
qui: save "$dt\temp-`i'.dta", replace
}
}
*-------------------------------------------------------------------------------
* appending databases (over years)
*-------------------------------------------------------------------------------
di "*--- appending... ---*"
qui: use "$dt\temp-2020.dta", clear
forvalues i=2019(-1)2004 {
	display `i'
	qui: append using "$dt\temp-`i'.dta"
}
qui: order anho mes conglome vivienda hogar codperso ubigeo dominio estrato 
qui: save "$dt\append-ENAHO0420.dta", replace
*-------------------------------------------------------------------------------
* erase 'temp' databases
*-------------------------------------------------------------------------------
local direc: dir "$dt" files "temp*.dta"
display `direc'
foreach x in `direc' {
	erase "$dt\\`x'"
}