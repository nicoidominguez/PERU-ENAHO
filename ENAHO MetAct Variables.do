*===============================================================================
*
* ENAHO (metodologia actualizada)
* Pooled Panel 2004-2016
* 
* RA: 			Nicolas Dominguez
* Ultima mod.: 	04 junio 2018
* Version: 		Stata 13.1
*
*===============================================================================

clear all
set more off
version 13.1

**RA (DB)
glo id	"C:\Users\ndominguez\Dropbox\Databases\INEI\ENAHO\Met_Act"

**Databases (DB)
glo dt	"$id\Databases"

*===============================================================================
* Standardizing cross-sections 2004-2016
*===============================================================================
forvalues i=2004/2016 {
*-------------------------------------------------------------------------------
* modulo 100
*-------------------------------------------------------------------------------
use		mes conglome vivienda hogar factor07 p102 p103 p103a p104 p104a p110 p111* ///
		p1121-p1127 p113* p1141-p1145 result fecent ///
		using "$id\\`i'\Files\DTA\enaho01-`i'-100.dta", clear
desc
destring mes conglome vivienda hogar, replace // 'int'-type for key variables
gen int anho = `i' // survey-year variable
qui compress
sort	anho mes conglome vivienda hogar
if `i'>=2004&`i'<=2006 {
	recode p102 (4=5) (5=6) (6=7) (7=8) (8=9) 
	rename (p1133 p1134 p1135 p1136 p1137) (xp1134 xp1135 xp1136 xp1137 xp1138)
	rename xp113* p113*
}
else if `i'>=2007&`i'<=2016 {
	recode p102 (4=3)
	replace p1132=1 if p1133==1&p1132!=1
	drop p1133
}
if `i'>=2004&`i'<=2011 {
	recode p111 (3=4) (4=5) (5=6) (6=8)
}
else if `i'>=2012&`i'<=2016 {
	rename p111a p111
}
save	"$dt\temp-`i'-100.dta", replace
*-------------------------------------------------------------------------------
* modulo 200
*-------------------------------------------------------------------------------
use		mes conglome vivienda hogar codperso facpob07 p203* p204 p205 p206 p207 ///
		p208a p208a1 p208a2 p209 p210 ubigeo dominio estrato ///
		using "$id\\`i'\Files\DTA\enaho01-`i'-200.dta", clear // pregunta sobre tipo de actividad laboral del roster (p211a-p211d) esta desde 2012
desc
destring mes conglome vivienda hogar codperso, replace // 'int'-type for key variables
gen int anho = `i' // survey-year variable
qui compress
sort	anho mes conglome vivienda hogar codperso
replace ubigeo=trim(ubigeo)
replace ubigeo="0"+ubigeo if length(ubigeo)==5
if `i'>=2004&`i'<=2007 {
	tostring p208a2, replace
	replace p208a2="0"+p208a2 if length(p208a2)==5
}
desc
save	"$dt\temp-`i'-200.dta", replace
*-------------------------------------------------------------------------------
* modulo 300
*-------------------------------------------------------------------------------
use		mes conglome vivienda hogar codperso codinfor p300a p301a p301b p301c ///
		p301d p303 p304* p305 p306 p307 p308a p308b p308c p308d ///
		using "$id\\`i'\Files\DTA\enaho01a-`i'-300.dta", clear // pregunta sobre percepcion en educacion (p308b*) esta desde 2012
desc
destring mes conglome vivienda hogar codperso codinfor, replace // 'int'-type for key variables
gen int anho = `i' // survey-year variable
qui compress
sort	anho mes conglome vivienda hogar codperso
save	"$dt\temp-`i'-300.dta", replace
*-------------------------------------------------------------------------------
* modulo 400
*-------------------------------------------------------------------------------
use		mes conglome vivienda hogar codperso codinfor p400a* p419* ///
		using "$id\\`i'\Files\DTA\enaho01a-`i'-400.dta", clear
desc
destring mes conglome vivienda hogar codperso codinfor, replace // 'int'-type for key variables
gen int anho = `i' // survey-year variable
qui compress
sort	anho mes conglome vivienda hogar codperso
save	"$dt\temp-`i'-400.dta", replace
*-------------------------------------------------------------------------------
* modulo 500
*-------------------------------------------------------------------------------
use		"$id\\`i'\Files\DTA\enaho01a-`i'-500.dta", clear
drop	a*o ubigeo dominio estrato p500n p500i p559* t559* z559* d559* i559* ///
		p59f* p560* d560* i560* p20* p301a
desc
destring mes conglome vivienda hogar codperso codinfor, replace // 'int'-type for key variables
gen int anho = `i' // survey-year variable
qui compress
sort	anho mes conglome vivienda hogar codperso
if		`i'>=2004&`i'<=2008 {
	foreach x in p d {
		foreach y in a b c d e {	
			capture rename (`x'5566`y' `x'5567`y') (`x'5568`y' `x'5569`y') // capture neccesary b/c 'd556*i' only matches for i=c,e
		}
	}
}
else if `i'>=2009&`i'<=2013 {
	foreach x in p d {
		foreach y in a b c d e {	
			capture rename (`x'5567`y' `x'5568`y') (`x'5568`y' `x'5569`y') // capture neccesary b/c 'd556*i' only matches for i=c,e
		}
	}
}
if		`i'>=2004&`i'<=2006 {
	foreach x in p d i {
		rename (`x'524cc1 `x'524c1 `x'524d1) (`x'524c1 `x'524d1 `x'524e1)
		rename (`x'538cc1 `x'538c1 `x'538d1) (`x'538c1 `x'538d1 `x'538e1)
	}
}
if		`i'==2007 {
	destring p554r4, replace
}
if		`i'>=2008&`i'<=2016 {
	tostring p500b1 p500d1, replace
}
save	"$dt\temp-`i'-500.dta", replace
*-------------------------------------------------------------------------------
* modulo 612
*-------------------------------------------------------------------------------
use		mes conglome vivienda hogar p612n p612 using "$id\\`i'\Files\DTA\enaho01-`i'-612.dta", clear
desc
if `i'>=2004&`i'<=2006 {
	recode p612n	( 1= 1) ( 2= 3) ( 3= 2) ( 4=12) ( 5=15) ( 6= 4) ( 7= 6) ( 8=13) ///
					( 9= 8)	(10=10) (11=11) (12=14) (13= 9) (14=16) (15=17) (16=19) ///
					(17=18) (18=21) (19=20) (20= 7) (21=22) (22=23)
}
order	mes conglome vivienda hogar p612n
noisily reshape wide p612, i(mes conglome vivienda hogar) j(p612n) 
noisily keep mes conglome vivienda hogar p6121-p61221
destring mes conglome vivienda hogar, replace // 'int'-type for key variables
gen int anho = `i' // survey-year variable
qui compress
sort	anho mes conglome vivienda hogar
save	"$dt\temp-`i'-612.dta", replace
*-------------------------------------------------------------------------------
* sumaria
*-------------------------------------------------------------------------------
use		mes conglome vivienda hogar mieperho totmieho percepho ingbruhd ingnethd ///
		pagesphd ingindhd ingauthd insedthd insedlhd paesechd ingseihd isecauhd ///
		ingexthd ingtrahd ingtexhd ingtprhd ingtpuhd ingrenhd ingoexhd ingmo1hd ///
		ingmo2hd inghog1d inghog2d gashog1d gashog2d ///
		ingtpuhd ingtprhd ///
		linea linpe pobreza ///
		ia01hd ig06hd ig08hd sig24 sig26 ///
		gru13hd1 gru13hd2 gru13hd3 gru23hd1 gru23hd2 gru23hd3 gru24hd ///
		gru33hd1 gru33hd2 gru33hd3 gru34hd gru43hd1 gru43hd2 gru43hd3 gru44hd ///
		gru53hd1 gru53hd2 gru53hd3 gru54hd gru63hd1 gru63hd2 gru63hd3 gru64hd ///
		gru73hd1 gru73hd2 gru73hd3 gru74hd gru83hd1 gru83hd2 gru83hd3 gru84hd ///
		gru14hd3 gru14hd4 gru14hd5 sg42d sg42d1 sg42d2 sg42d3 ///
		ga04hd ///
		using "$id\\`i'\Files\DTA\sumaria-`i'.dta", clear
desc
destring mes conglome vivienda hogar, replace // 'int'-type for key variables
gen int anho = `i' // survey-year variable
qui compress
order	anho mes conglome vivienda hogar
sort	anho mes conglome vivienda hogar
save	"$dt\temp-`i'-sumaria.dta", replace
*-------------------------------------------------------------------------------
* merging modulo 100, 200, 300, 400, 500 & 612
*-------------------------------------------------------------------------------
use		"$dt\temp-`i'-100.dta", clear 
mer 1:m anho mes conglome vivienda hogar			using "$dt\temp-`i'-200.dta"
rename  _merge _m_100_200
mer 1:1 anho mes conglome vivienda hogar codperso	using "$dt\temp-`i'-300.dta"
rename  _merge _m_100_200_300
mer 1:1 anho mes conglome vivienda hogar codperso	using "$dt\temp-`i'-400.dta"
rename  _merge _m_100_200_300_400
mer 1:1 anho mes conglome vivienda hogar codperso	using "$dt\temp-`i'-500.dta"
rename  _merge _m_100_200_300_400_500
* NOTA: los _merge==1 vienen de m200 y no estan en m300. OK -> m300 lo responden los 'miembros presentes' y 'mayores de 3anhos'
mer m:1 anho mes conglome vivienda hogar			using "$dt\temp-`i'-612.dta"
rename  _merge _m_100_200_300_400_500_612
mer m:1 anho mes conglome vivienda hogar			using "$dt\temp-`i'-sumaria.dta"
rename  _merge _m_100_200_300_400_500_612_sum
save	"$dt\temp-`i'.dta", replace
}
*-------------------------------------------------------------------------------
* appending databases (over years)
*-------------------------------------------------------------------------------
use		"$dt\temp-2016.dta", clear
forvalues i=2015(-1)2004 {
	display `i'
	append using "$dt\temp-`i'.dta"
}
order	anho mes conglome vivienda hogar codperso ubigeo dominio estrato 
save	"$dt\append.dta", replace
*-------------------------------------------------------------------------------
* erase 'temp' databases
*-------------------------------------------------------------------------------
local direc: dir "$dt" files "temp*.dta"
display `direc'
foreach x in `direc' {
	erase "$dt\\`x'"
}

*===============================================================================
* Working on the Cross-Section Database
*===============================================================================
*-------------------------------------------------------------------------------
* 0. Sample Delimitation
*-------------------------------------------------------------------------------
use		"$dt\append.dta", clear

********Control tipo miembros
gen int cntrl  =1 if p204==1&p205==2	/* miembro presente -residente habitual */
recode  cntrl .=2 if p204==1&p205==1	/* miembro ausente -residente habitual */
recode  cntrl .=3 if p204==2&p206==1	/* no-miembro presente -residente habitual */
recode  cntrl .=4 if p204==2&p206==2	/* no-miembro ausente */
recode  cntrl .=5 if p203==0			/* persona panel no presente */
lab val	cntrl cntrl
lab def	cntrl 1"miembro presente" 2"miembro ausente" 3"no-miembro presente" ///
			  4"no-miembro ausente" 5"persona panel no-presente"
lab var cntrl "tipos de miembros"

********Revision de factores de expansion
tabmiss factor07 facpob07 fac500a fac500a7 if (result!=1&result!=2) /* no hay encuesta -> missing en todos los factores, salvo 'factor07' */
tabmiss factor07 facpob07 fac500a fac500a7 if (result==1|result==2)
tabmiss factor07 facpob07 fac500a fac500a7 if (result==1|result==2)&(cntrl==1|cntrl==2|cntrl==3)
tabmiss factor07 facpob07 fac500a fac500a7 if (result==1|result==2)&(cntrl==4|cntrl==5)

********Delimitacion de muestra
keep if result==1|result==2				/* Se mantiene: Hogares "completos" e "incompletos" */
keep if cntrl==1|cntrl==2|cntrl==3		/* Se mantiene: Residentes Habituales ("Miembros de Hogar" y "No-Miembros presentes") */
*keep if cntrl==1|cntrl==2				/* Se mantiene: Miembros de Hogar */

*-------------------------------------------------------------------------------
* 1. Variables Demográficas / Control
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* 1.1 De la vivienda/hogar
*-------------------------------------------------------------------------------
********Urbano y Rural
gen		urb=1 if estrato>=1&estrato<=5
replace	urb=0 if estrato>=6&estrato<=8
lab val	urb urb
lab def	urb 1"urbano" 0"rural"
lab var urb "=1 si hogar es urbano"
********Departamento de residencia
gen		dpto=substr(ubigeo,1,2)
destring dpto, replace
tab		dpto
recode	dpto (7=15)
lab val dpto dpto
lab def dpto 1"amazonas" 2"ancash" 3"apurimac" 4"arequipa" 5"ayacucho" ///
			 6"cajamarca" 8"cusco" 9"huancavelica" 10"huanuco" 11"ica" ///
			12"junin" 13"la libertad" 14"lambayeque" 15"lima" 16"loreto" ///
			17"madre de Dios" 18"moquegua" 19"pasco" 20"piura" 21"puno" ///
			22"san artin" 23"tacna" 24"tumbes" 25"ucayali"
lab var dpto "region de residencia"
********Región de residencia
gen 	region=1 if dominio>=1&dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4&dominio<=6 
replace region=3 if dominio==7
lab val	region region
lab def	region	1"costa" 2"sierra" 3"selva"
********Dominio (var. para cruzar deflactores espaciales)
gen     dominioA= 1	if dominio==1&urb==1
replace dominioA= 2	if dominio==1&urb==0
replace dominioA= 3	if dominio==2&urb==1
replace dominioA= 4	if dominio==2&urb==0
replace dominioA= 5	if dominio==3&urb==1
replace dominioA= 6	if dominio==3&urb==0
replace dominioA= 7	if dominio==4&urb==1
replace dominioA= 8	if dominio==4&urb==0
replace dominioA= 9	if dominio==5&urb==1
replace dominioA=10	if dominio==5&urb==0
replace dominioA=11	if dominio==6&urb==1
replace dominioA=12	if dominio==6&urb==0
replace dominioA=13	if dominio==7&urb==1
replace dominioA=14	if dominio==7&urb==0
replace dominioA=15	if dominio==7&urb==1&(dpto==16|dpto==17|dpto==25)
replace dominioA=16	if dominio==7&urb==0&(dpto==16|dpto==17|dpto==25)
replace dominioA=17	if dominio==8&urb==1
replace dominioA=17	if dominio==8&urb==0
lab def	dominioA 1"costa norte urbana" 2"costa norte rural" 3"costa centro urbana" 4"costa centro rural" ///
				 5"costa sur urbana" 6"costa sur rural"	7"sierra norte urbana"	8"sierra norte rural" 9"sierra centro urbana" /// 
				10"sierra centro rural"	11"sierra sur urbana" 12"sierra sur rural" 13"selva alta urbana" 14"selva alta rural" ///
				15"selva baja urbana" 16"selva baja rural" 17"lima metropolitana"
lab val dominioA dominioA
/*
NOTA: para núcleos familiares
------------------------------
Registre el código 0, cuando la relación de parentesco es diferente a padres e 
hijos, es decir, suegro(a) solo(a), otros parientes solos (sobrinos, hermanos,
etc.), trabajadora del hogar sin hijos, pensionista solo, etc., y en la pregunta
203-B registre 1.
Para los niños menores que están a cargo de algún pariente, no forman parte de 
un núcleo familiar por no ser hijos (no viven con sus padres), registre el 
código 0 y en la pregunta 203-B, registre 1.
*/
********ID de hogares y de nucleos familiares
sort	anho conglome vivienda hogar codperso
egen	idhogar=group(anho conglome vivienda hogar)			/* ID para el hogar */
egen	idnf   =group(anho conglome vivienda hogar p203a)	/* ID para el nucleo familiar (incluye nucleos de 1 persona - p203a==0) */																	
order	idhogar idnf
sort	anho idhogar codperso
summ	idhogar /* 198,156 hogares */
summ	idnf	/* 202,284 nucleos familiares (no incluye nucleos de una persona) */
lab var	idhogar	"id de hogar"
lab var	idnf	"id de núcleo familiar"
/*
DEFINICIONES INEI
*-------------------
Total de personas en el hogar	[totmieho]	->	Miembro del Hogar (p204==1) | (No Miembro del Hogar (p204==2) & Estar presente 30 días o más (p206==1))
Total de miembros del hogar		[mieperho]	->	Miembro del Hogar (p204==1) & No Trabajador del Hogar, No Pensionista (p203!=8&p203!=9)
Total de perceptores de ingresos[percepho]	->	Miembro del Hogar (p204==1) & No Trabajador del Hogar, No Pensionista (p203!=8&p203!=9) & Mayor de 14 (p208a>=14) & (Ing. por trabajo>0 | Ing. Transferencias>0 | Ing. Rentas>0 | Otros Ing. Extra.>0)
*/
********Número de Miembros del Hogar (MH)
gen		n	=(p204==1)
egen	N	=sum(n), by(idhogar)
lab var	N	"n° de miembros del hogar"
lab var	n	"=1 si es miembro del hogar"
********Número de Adultos MH (+14 años)
gen		nA	=(p204==1)&(p208a>=14)
egen	NA	=sum(nA), by(idhogar)
lab var	NA	"n° de adultos (+14) miembros del hogar"
lab var	nA	"=1 si es adulto (+14) miembro del hogar"
********Número de Ocupados MH (+14 años & ocu500==1)
gen		nO	=(p204==1)&(p208a>=14)&(ocu500==1)
egen	NO	=sum(nO), by(idhogar)
lab var	NO	"n° de ocupados miembros del hogar"
lab var	nO	"=1 si es ocupado y miembro del hogar"
********Número de Ocupados MH (+14 años & ingresos laborales>0)
gen		nOI	=(p204==1)&(p208a>=14)&((i524e1>0&i524e1!=999999&i524e1!=.)|	///
									(i530a >0&i530a !=999999&i530a !=.)|	///
									(d529t >0&d529t !=999999&d529t !=.)|	///
									(d536  >0&d536  !=999999&d536  !=.)|	///
									(i538e1>0&i538e1!=999999&i538e1!=.)|	///
									(i541a >0&i541a !=999999&i541a !=.)|	///
									(d540t >0&d540t !=999999&d540t !=.)|	///
									(d543  >0&d543  !=999999&d543  !=.)|	///
									(d544t >0&d544t !=999999&d544t !=.))
egen	NOI	=sum(nOI), by(idhogar)
lab var	NOI	"n° de ocupados con ingresos miembros del hogar"
lab var	nOI	"=1 si es ocupado que genera ingresos y es miembro del hogar"
********Número de Perceptores de Ingresos (+14 años & ingresos laborales | no laborales>0)
gen		nP	=(p204==1)&(p208a>=14)&((i524e1>0&i524e1!=999999&i524e1!=.)|	///
									(i530a >0&i530a !=999999&i530a !=.)|	///
									(d529t >0&d529t !=999999&d529t !=.)|	///
									(d536  >0&d536  !=999999&d536  !=.)|	///
									(i538e1>0&i538e1!=999999&i538e1!=.)|	///
									(i541a >0&i541a !=999999&i541a !=.)|	///
									(d540t >0&d540t !=999999&d540t !=.)|	///
									(d543  >0&d543  !=999999&d543  !=.)|	///
									(d544t >0&d544t !=999999&d544t !=.)|	///
									(d556t1>0&d556t1!=999999&d556t1!=.)|	///
									(d556t2>0&d556t2!=999999&d556t2!=.)|	///
									(d557t >0&d557t !=999999&d557t !=.)|	///
									(d558t >0&d558t !=999999&d558t !=.))
egen	NP	=sum(nP), by(idhogar)
lab var	NP	"n° de perceptores de ingresos miembros del hogar (+14)"
lab var	nP	"=1 si es perceptor de ingresos y miembro del hogar"

*-------------------------------------------------------------------------------
* 1.2 Del individuo
*-------------------------------------------------------------------------------
********Sexo
gen		sexo=1 if p207==2
replace	sexo=0 if p207==1
lab val	sexo sexo
lab def	sexo 1"mujer" 0"hombre"
lab var sexo "=1 si es mujer"
********Edad
gen		edad=p208a
lab var edad "edad"
********Nacio en el distrito en que vive
gen		nac_distrito_vive=p208a1
lab var nac_distrito_vive "=1 si nació en el distrito en que vive"
********Distrito de Nacimiento
gen		nac_distrito=p208a2
replace	nac_distrito=ubigeo if nac_distrito_vive==1&(ubigeo!=p208a2) /* 127 casos (2004 y 2005) */
lab var nac_distrito "distrito de nacimiento (recodificado)"
gen		nac_distrito_original=nac_distrito
lab var	nac_distrito_original "distrito de nacimiento (original)"
tempvar len dep pro dis
gen		`len'=length(nac_distrito)
gen		`dep'=substr(nac_distrito,1,2) if `len'==6
gen		`pro'=substr(nac_distrito,3,2) if `len'==6
gen		`dis'=substr(nac_distrito,5,2) if `len'==6
count if nac_distrito==""
replace	nac_distrito="" if `len'!=6																/*   729 : extranjeros y registros raros (2004-2007) */
replace	nac_distrito="" if `dep'=="00"															/* 2,087 : extranjeros (2008-2016) */
replace	nac_distrito="" if `pro'=="00"&`dep'!="00"												/*     1 : sabe region, no sabe provincia (2005) */
replace	nac_distrito="" if (`dis'=="00")&`pro'!="00"&`dep'!="00"								/*    14 : sabe provincia, no sabe distrito (2004-2006) */
replace	nac_distrito="" if nac_distrito=="015010"|nac_distrito=="015033"|nac_distrito=="806001"	/*     4 : registros raros (2009 y 2012) */
replace	nac_distrito="" if nac_distrito=="999999"												/*    30 : missings (2010-2015) */
/* total missings: 2,511 */
replace	nac_distrito="" if nac_distrito=="010901"												/*     1 : error de registro (2004) */
replace	nac_distrito="" if nac_distrito=="020806"												/*     1 : error de registro (2006) */
replace	nac_distrito="" if nac_distrito=="031806"												/*     1 : error de registro (2006) */
replace	nac_distrito="" if nac_distrito=="201301"												/*     1 : error de registro (2004) */
replace	nac_distrito="" if nac_distrito=="210412"												/*     1 : error de registro (2004) */
/* total missings: 2,511 + 6 = 2,517 */
replace	nac_distrito="090119" if nac_distrito=="090708"											/*    71 : "HUANDO" se anexa a otra provincia */
replace	nac_distrito="101002" if nac_distrito=="100303"											/*     1 : "BAÑOS" se anexa a otra provincia */
replace	nac_distrito="160511" if nac_distrito=="160111"											/*    18 : "YAQUERANA" se anexa a otra provincia */
replace	nac_distrito="160701" if nac_distrito=="160203"											/*   209 : "BARRANCA" se anexa a otra provincia */
replace	nac_distrito="160702" if nac_distrito=="160204"											/*    97 : "CAHUAPANAS" se anexa a otra provincia */
replace	nac_distrito="160703" if nac_distrito=="160207"											/*   275 : "MANSERICHE" se anexa a otra provincia */
replace	nac_distrito="160704" if nac_distrito=="160208"											/*    31 : "MORONA" se anexa a otra provincia */
replace	nac_distrito="160705" if nac_distrito=="160209"											/*    16 : "PASTAZA" se anexa a otra provincia */
replace	nac_distrito="050101" if nac_distrito=="050116"											/*    29 : "050116" se crea, antes era parte de "050101" */
replace	nac_distrito="050408" if nac_distrito=="050409"											/*    18 : "050409" se crea, antes era parte de "050408" */
replace	nac_distrito="050501" if nac_distrito=="050509"											/*    93 : "050509" se crea, antes era parte de "050501" */
replace	nac_distrito="070106" if nac_distrito=="070107"											/*    11 : "MI PERU" se crea, antes era parte de "VENTANILLA" */
replace	nac_distrito="100105" if nac_distrito=="100112"											/*    44 : "100112" se crea, antes era parte de "100105" */
replace	nac_distrito="190306" if nac_distrito=="190308"											/*   112 : "190308" se crea, antes era parte de "190306" */
replace	nac_distrito="200101" if nac_distrito=="200115"											/*   355 : "200115" se crea, antes era parte de "200115" */
tempvar ran
set seed 555000 //randomly chosen number
gen `ran'=runiform() if nac_distrito=="120699"
replace nac_distrito="120604" if nac_distrito=="120699"&`ran'>=.5								/*   500 : "120699" se crea, antes era la union de "120604" y "120606" ("MAZAMARI" y "PANGOA")*/
replace nac_distrito="120606" if nac_distrito=="120699"&`ran'< .5								/*   500 : "120699" se crea, antes era la union de "120604" y "120606" ("MAZAMARI" y "PANGOA")*/
/* total corrections: 2,380 */
replace ubigeo=nac_distrito	  if nac_distrito_vive==1&ubigeo!=nac_distrito						/* 2,088 : despues de todas las correcciones */
drop	__*
********Lengua Materna
recode	p300a (4=1) (1=2) (2 3 5 6 7 8 9=3), gen(len_mat)
lab val len_mat len_mat
lab def len_mat 1"castellano" 2"quechua" 3"otro"
lab var len_mat "lengua materna"
recode	len_mat (1=1) (2 3=0), gen(castellano)
lab val castellano cast
lab def cast	1"castellano" 0"otro"
lab var	castellano "=1 si lengua materna es castellano"
********Fecha de Entrevista
tostring fecent, replace
gen		ent_anho=substr(fecent,1,4)
gen		ent_mes =substr(fecent,5,2)
gen		ent_dia =substr(fecent,7,2)
destring ent_*, replace
********Fecha de Nacimiento
gen		nac_anho=p400a3
gen		nac_mes =p400a2
gen		nac_dia =p400a1
lab var nac_anho "fecha de nacimiento: anho"
lab var nac_mes  "fecha de nacimiento: mes"
lab var nac_dia  "fecha de nacimiento: dia"

*-------------------------------------------------------------------------------
* 2. Variables de Trabajo
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* 2.1 Características/Situación del Trabajo y el Trabajador
*-------------------------------------------------------------------------------
********Situación del trabajador
gen		situac_pet	=.
replace	situac_pet	=1 if ocu500==1
replace	situac_pet	=2 if ocu500==2|ocu500==3
replace	situac_pet	=3 if ocu500==4
lab def	situac_pet	1"ocupado" 2"desocupado" 3"inactivo" 
lab val	situac_pet	situac_pet
lab var	situac_pet	"situación de la población en edad de trabajar (pet)"
********Tipo de inserción
gen		tipoinsercion=.
replace	tipoinsercion=1 if nO==1&(p507==3|p507==4)&(p510==4|p510==5|p510==6|p510==7) 
replace	tipoinsercion=2 if nO==1&(p507==3|p507==4)&(p510==2|p510==3) 
replace	tipoinsercion=3 if nO==1& p507==5
replace	tipoinsercion=4 if nO==1&(p507==1|p507==2)& p509==1
replace	tipoinsercion=5 if nO==1&(p507==1|p507==2)& p509==2
replace	tipoinsercion=6 if nO==1& p507==6
replace	tipoinsercion=7 if nO==1&(p507==7|p507==3|p507==4)&(p510==1)
lab def	tipoinsercion 1"asalariado privado" 2"asalariado público" 3"tfnr" ///
					  4"empleador o indep. con trabajadores" 5"indep. sin trabajadores" ///
					  6"trabajador del hogar" 7"otros" 
lab val	tipoinsercion tipoinsercion
********Tipo de inserción: asalariado o independiente
gen     asalariado	=.
replace asalariado	=1 if tipoinsercion<=3|tipoinsercion==6|tipoinsercion==7
replace asalariado	=0 if tipoinsercion==4|tipoinsercion==5
********Ocupación remunerada, ocupación no remunerada
gen     ocup_remun	=.
replace ocup_remun	=1 if nO==1&tipoinsercion!=5
replace ocup_remun	=1 if nO==0&tipoinsercion==5
********Sector de actividad, código original
gen		cod_activ	=p506
********Sector de actividad
gen		sec_activ	=1 if nO==1 &  111<=p506&p506<=500
replace	sec_activ	=2 if nO==1 & 1010<=p506&p506<=1429 
replace	sec_activ	=3 if nO==1 & 1511<=p506&p506<=3720 
replace	sec_activ	=4 if nO==1 & 4010<=p506&p506<=4100 
replace	sec_activ	=5 if nO==1 & 4510<=p506&p506<=4550 
replace	sec_activ	=6 if nO==1 & 5010<=p506&p506<=5260  
replace	sec_activ	=7 if nO==1 & 6010<=p506&p506<=6420
replace	sec_activ	=8 if nO==1 & (6511<=p506&p506< 9999)|(5510<=p506& p506<=5520)
lab def	sec_activ	1"agricultura, caza, pesca" 2"minería e hidrocarburos" 3"manufactura" ///
					4"electricidad, gas, agua" 5"construcc." 6"comercio" 7"transportes" 8"servicios" 
lab val	sec_activ sec_activ
********Ocupación, código original
gen		cod_ocupac	=p505
********Empleo formal o informal (pasar programa a Efra)
gen		cise   =2	if p507==1   /* Empleador o patrono.*/
recode	cise (.=1)	if p507==2   /* Trabajador independiente.*/
recode	cise (.=4)	if p507==3   /* Empleado.*/
recode	cise (.=4)	if p507==4   /* Obrero.*/
recode	cise (.=3)	if p507==5   /* Trabajador familiar.*/
recode	cise (.=4)	if p507==6   /* Trabajador del hogar.*/
recode	cise (.=4)	if p507==7   /* Otros.*/
recode	cise (.=9)               /* No declarado.*/
replace	cise   =.	if nO!=1 
********
gen		sec_siu   =1	if (p507==3|p507==4|p507==7)&(p510==1|p510==2|p510==3)												/* SECTOR FORMAL.*/
recode	sec_siu (.=3)	if (p507==6)																						/* SECTOR DE HOGARES.*/
recode	sec_siu (.=2)	if (p507==1|p507==2)						  		  &(p510a==2&p510b==2&p512a==1&p512b>0&p512b<6)	/* SECTOR INFORMAL.*/
recode	sec_siu (.=2)	if (p507==5)															 &p512a==1&p512b>0&p512b<6	/* SECTOR INFORMAL.*/
recode	sec_siu (.=2)	if (p507==3|p507==4|p507==7)&(p510==4|p510==5|p510==6)&(p510a==2&p510b==2&p512a==1&p512b>0&p512b<6) /* SECTOR INFORMAL.*/
recode	sec_siu (.=1)																										/* SECTOR FORMAL.*/
replace	sec_siu   =.	if nO!=1 
/*
*===========================================================================
  CLASIFICANDO EN EMPLEO FORMAL E INFORMAL: Definición aplicada

    Se consideran con empleo informal asalariado los que no estan
    afiliados actualmente a ningún de los siguientes sistemas de
    prestaciones de salud:
      i) ESSALUD
     ii) Seguro Privado de Salud
    iii) Entidad Prestadora de Salud
     iv) Seguro de FFAA / Policiales.

*---------------------------------------------------------------------------
  RECODIFICANDO AFILIACION A SEGURO MEDICO:
 
  Afiliación a seguro médico (segmed)
     1) Afiliado
     2) No afiliado
          1) ESSALUD                          (p4191=1)
          2) Seguro privado de salud          (p4192=1)
          3) Entidad prestadora de salud      (p4193=1)
          4) Seguro de las FFAA / Policiales  (p4194=1)
          5) Seguro integral de salud
          6) Seguro universitario
          7) Seguro escolar privado
          8) Otros
          9) No esta afiliado.
*/
********Afiliación a sistema de prestaciones de salud
gen     segmed=2												/* No afiliado a un sistema de prestaciones de salud.*/
replace segmed=1	if (p4191==1|p4192==1|p4193==1|p4194==1)	/* Afiliados a seguro médico.*/
replace segmed=.	if nO!=1
********Determinando el código final para emp_siu
gen		emp_siu	  =1	if (p507==2&sec_siu==2)   /* Trabajadores independientes del sector informal --Por definición tiene empleo informal. */
recode	emp_siu (.=2)	if (p507==2&sec_siu==1)   /* Trabajadores independientes del sector formal --Por definición tienen empleo formal. */
recode	emp_siu (.=3)	if (p507==1&sec_siu==2)   /* Empleadores del sector informal --Por definición tienen empleo informal. */
recode	emp_siu (.=4)	if (p507==1&sec_siu==1)   /* Empleadores del sector formal --Por definición tienen empleo formal. */
recode	emp_siu (.=5)	if (p507==5)              /* Trabajadores familiares auxiliares --Por definición tienen empleo informal. */
recode	emp_siu (.=7)	if (p507==3&segmed==2)    /* Empleados sin seguro médico en salud --Tienen empleo asalariado informal. */
recode	emp_siu (.=7)	if (p507==4&segmed==2)    /* Obreros sin seguro médico en salud --Tienen empleo asalariado informal. */
recode	emp_siu (.=7)	if (p507==6&segmed==2)    /* Trabajador del hogar sin seguro médico en salud --Tienen empleo asalariado informal. */
recode	emp_siu (.=7)	if (p507==7&segmed==2)    /* Otros trabajadores sin seguro médico en salud --Tienen empleo asalariado informal. */
recode	emp_siu (.=8)	if (p507==3&segmed==1)    /* Empleados con seguro médico en salud --Tienen empleo asalariado formal. */
recode	emp_siu (.=8)	if (p507==4&segmed==1)    /* Obreros con seguro médico en salud --Tienen empleo asalariado formal. */
recode	emp_siu (.=8)	if (p507==6&segmed==1)    /* Trabajador del hogar con seguro médico en salud --Tienen empleo asalariado formal. */
recode	emp_siu (.=8)	if (p507==7&segmed==1)    /* Otros trabajadores con seguro médico en salud --Tienen empleo asalariado formal. */
replace	emp_siu	  =.	if nO!=1 
********Determinando el código final para emp_siu 2
gen		remp_siu=1	if emp_siu==1|emp_siu==3|emp_siu==5|emp_siu==7
replace	remp_siu=2	if emp_siu==2|emp_siu==4|emp_siu==8
replace	remp_siu=.	if nO!=1 
/*
* VARIABLE LABELS
lab var segmed  "Afiliado a sistema de prestaciones de salud"
lab var cise    "Empleos según situación en el empleo"
lab var sec_siu "Tipo de unidad de producción"
lab var emp_siu "Empleo Formal e Informal"
lab var remp_siu "Empleo Formal e Informal"
* VALUE LABELS
#delimit;
lab def segmed 
  1 "Afiliado" 
  2 "No afiliado";
lab val segmed segmed;
lab def cise 
  1 "Cuenta propia" 
  2 "Empleador" 
  3 "Trabajador familiar auxiliar" 
  4 "Empleado" 
  9 "Desconocida";
lab val cise cise;
lab def sec_siu 
  1 "Sector Formal" 
  2 "Sector Informal" 
  3 "Sector de Hogares" 
  4 "Sector no determinado";
lab val sec_siu sec_siu;
lab def emp_siu 
  1 "Independiente Informal" 
  2 "Independiente Formal" 
  3 "Empleador Informal" 
  4 "Empleador Formal" 
  5 "TFNR Informal" 
  7 "Asalariado Informal" 
  8 "Asalariado Formal";
lab val emp_siu emp_siu;
lab def remp_siu 
  1 "Informal" 
  2 "Formal";
lab val remp_siu remp_siu;
#delimit cr
*/
********Empleo en el sector formal o el sector informal (pasar programa a Efra)
********Tamaño de empresa
gen		tamanho_prin=1	if nO==1&tipoinsercion==5
replace	tamanho_prin=2	if nO==1&p512b<=  5
replace	tamanho_prin=3	if nO==1&p512b>=  6&p512b<=49
replace	tamanho_prin=4	if nO==1&p512b>= 50&p512b<=99
replace	tamanho_prin=5	if nO==1&p512b>=100&p512b<  .
replace	tamanho_prin=6	if nO==1&tipoinsercion==2
lab var	tamanho_prin	"tamaño de empresa de la ocupación principal"
lab def	taman			1"indep. sin trabajadores" 2"micro (2-5)" 3"pequeña (6 a 49)" ///
						4"mediana (50 a 99)" 5"grande (100 o más)" 6"sector público"
lab val tamanho_prin	taman
********Tiene contrato (asalariados) y tipo
gen		contrato=p511a	if asalariado==1
********Tiene seguro de salud y cuál
gen		ssal_tot		=p4191==1|p4192==1|p4193==1|p4194==1|p4195==1|p4196==1|p4197==1|p4198==1|p4199==1
gen		ssal_esssalud	=p4191==1 
gen		ssal_privado	=p4192==1
gen		ssal_eps		=p4193==1
gen		ssal_ffaapol	=p4194==1
/*	
********Tiene pensión de jubilación y cuál
********Para empleadores e independientes con trabajadores
	a.	Lleva sistema de contabilidad
	b.	Lleva registros exigidos por SUNAT
********Razón para iniciar un negocio
*/
********Reemplazamos como missings aquellas dummies cuyo valor es cero en los individuos que no respondieron a la pregunta

*-------------------------------------------------------------------------------
* 2.2 Ingreso Anual Total
*-------------------------------------------------------------------------------
/*
Ocupacion Principal
--------------------
p507== 1 o 2	-> Independiente
p507== 3, 4 o 6	-> Dependiente
p507== 5 o 7	-> TFNR u Otro (no responden módulo de ingresos)
*/
********Ingresos laborales
********Ocupación principal
gen		ipd_m	=. 
replace ipd_m	=i524e1	if (i524e1>0&i524e1!=999999&i524e1!=.) 
lab var ipd_m	"ing anual ocup ppal.-monetario (dep)" 
gen		ipi_m	=. 
replace ipi_m	=i530a	if (i530a >0&i530a !=999999&i530a !=.) 
lab var ipi_m	"ing anual ocup ppal.-monetario (indep)" 
gen		ipd_e	=. 
replace ipd_e	=d529t	if (d529t >0&d529t !=999999&d529t !=.) 
lab var ipd_e	"ing anual ocup ppal.-especie (dep)" 
gen		ipi_e	=. 
replace ipi_e	=d536	if (d536  >0&d536  !=999999&d536  !=.) 
lab var ipi_e	"ing anual ocup ppal.-especie (autocon) (indep)" 
********Ocupación secundaria
gen		isd_m	=.
replace isd_m	=i538e1	if (i538e1>0&i538e1!=999999&i538e1!=.)
lab var isd_m	"ing anual ocup sec.-monetario (dep)"
gen		isi_m	=.
replace isi_m	=i541a	if (i541a >0&i541a !=999999&i541a !=.)
lab var isi_m	"ing anual ocup sec.-monetario (indep)"
gen		isd_e	=.
replace isd_e	=d540t	if (d540t >0&d540t !=999999&d540t !=.)
lab var isd_e	"ing anual ocup sec.-especie (dep)"
gen		isi_e	=.
replace isi_e	=d543	if (d543  >0&d543  !=999999&d543  !=.)
lab var isi_e	"ing anual ocup sec.-especie (indep)"
********Ingresos extraordinarios laborales (gratificaciones, bonos, cts, etc.)
gen		ie		=d544t	if (d544t >0&d544t !=999999&d544t !=.)  
lab var ie		"ing anual extraordinario"
********Ingresos no laborales
********Transferencias corrientes
********Definición #1
gen		itr_p	=.
replace	itr_p	=d556t1	if d556t1>0&d556t1!=999999
lab var itr_p	"ing transferencias corr. monetarias- país"
gen		itr_e	=.
replace	itr_e	=d556t2	if d556t2>0&d556t2!=999999
lab var itr_e	"ing transferencias corr. monetarias- exterior"
egen	itr		=rowtotal(itr_p itr_e)
replace	itr		=.		if itr_p==.&itr_e==.
lab var itr		"ing transferencias corr. monetarias- total"
/*
egen	itr_pri_rem	=rowtotal(d5563c d5563e)
replace	itr_pri_rem	=.	if d5563c==.&d5563e==.
lab var itr_pri_rem	"ing transferencias corr. monetarias- privadas, remesas"
egen	itr_pri_otr	=rowtotal(d5561c d5561e d5562c d5562e d5569c d5569e)
replace	itr_pri_otr	=.	if d5561c==.&d5561e==.&d5562c==.&d5562e==.&d5569c==.&d5569e==.
lab var itr_pri_otr	"ing transferencias corr. monetarias- privadas, otros"
egen	itr_pri		=rowtotal(itr_pri_rem itr_pri_otr)		// PUEDE QUE ESTA SUMATORIA ESTÉ INCOMPLETA, POR ESO NO SUMA LO MISMO QUE D556T3
replace	itr_pri		=.	if itr_pri_rem==.&itr_pri_otr==.
lab var itr_pri		"ing transferencias corr. monetarias- privadas"
egen	itr_pub_jun	=rowtotal(d5566c d5566e)
replace	itr_pub_jun	=. if d5566c==.&d5566e==.
lab var itr_pub_jun	"ing transferencias corr. monetarias- públicas, juntos"
egen	itr_pub_p65	=rowtotal(d5567c d5567e)
replace	itr_pub_p65	=. if d5567c==.&d5567e==.
lab var itr_pub_p65	"ing transferencias corr. monetarias- públicas, pensión 65"
egen	itr_pub_otr	=rowtotal(d5564c d5564e d5565c d5565e d5568c d5568e)
replace	itr_pub_otr	=. if d5564c==.&d5564e==.&d5562c==.&d5562e==.&d5568c==.&d5568e==.
lab var itr_pub_otr	"ing transferencias corr. monetarias- públicas, otros"
egen	itr_pub		=rowtotal(itr_pub_jun itr_pub_p65 itr_pub_otr)		// PUEDE QUE ESTA SUMATORIA ESTÉ INCOMPLETA, POR ESO NO SUMA LO MISMO QUE D556T3
replace	itr_pub		=. if itr_pub_jun==.&itr_pub_p65==.&itr_pub_otr==.
lab var itr_pub		"ing transferencias corr. monetarias- públicas"
*/
/*
tabstat d5566c d5566e d5567c d5567e	, by(anho) s(mean)	// por construcción, 6 y 7 son missings en 2004-2008, 7 es missing en 2009-2013 | JUNTOS & PENSION 65
tabstat d556t3						, by(anho) s(mean)	// OJO*: No hay d556t3 para todos los años | TRANSF. PRIVADAS
tabstat d5563c d5563e				, by(anho) s(mean)	// | REMESAS
*/
********Rentas de la propiedad
gen		iren	=.
replace	iren	=d557t	if d557t>0&d557t!=999999
lab var iren	"ing rentas de propiedad monetaria (intereses, utilidades)"
********Transferencias corrientes
gen		ioex	=.
replace	ioex	=d558t	if d558t>0&d558t!=999999
lab var ioex	"otros ing extraordinarios (herencia, seguro, indemnización)"
********Estableciendo correcciones -consistencia con sumaria
********Ocupación principal es independiente			->	Ingresos Principales Dependientes ==.
********Ocupación principal es dependiente				->	Ingresos Principales Independientes ==.
********Ocupación principal/secundaria es independiente	->	Ingresos Extraodinarios Dependientes ==.
for var ipd_*: replace X=. if (p507==1|p507==2)						/* Ocu. Ppal. Dependiente */
for var ipi_*: replace X=. if (p507==3|p507==4|p507==6)				/* Ocu. Ppal. Independiente */
for var ie	 : replace X=. if (p507==1|p507==2)&(p517==1|p517==2)	/* Extraordinario Dependiente|Independiente */
********Agregando los ingresos
egen	ip_m	=rsum(ipd_m ipi_m)
replace ip_m	=.		if (ipd_m==.&ipi_m==.) 
lab var ip_m	"ing anual ocup ppal.-monetario" 
egen	ip		=rsum(ip_m ipd_e ipi_e)  
replace ip		=.		if (ip_m==.&ipd_e==.&ipi_e==.) 
lab var ip		"ing anual ocup ppal." 
egen	is   	= rsum(isd_m isi_m isd_e isi_e)
replace is   	=.		if (isd_m==.&isi_m==.&isd_e==.&isi_e==.)
lab var is	 	"ing anual ocup sec."
egen	ila_m	=rsum(ip_m isd_m isi_m ie)
replace ila_m	=.		if (ip_m==.&isd_m==.&isi_m==.&ie==.)
lab var ila_m	"ing laboral anual -monetario"
egen	ila_e	=rsum(ipd_e ipi_e isd_e isi_e)
replace ila_e	=.		if (ipd_e==.&ipi_e==.&isd_e==.&isi_e==.) 
lab var ila_e	"ing laboral anual -especie"  
egen	ila  	=rsum(ila_m ila_e)
replace ila  	=.		if (ila_m==.&ila_e==.) 
lab var ila	 	"ing laboral anual"
egen    inla	=rsum(itr iren ioex)
replace inla  	=.		if (itr==.&iren==.&ioex==.) 
lab var inla	"ing no laboral anual"
egen	it		=rsum(ila inla)
replace it		=. if (ila==.&inla==.)
lab var it		"ing total anual"
/*
check 4 consistency between sumaria and modulo 500
gen	sep=.
glo x	it ipd_m ipi_m isd_m isi_m ie ipd_e ipi_e isd_e isi_e itr_p itr_e iren ioex
for var $x : egen	xX = sum(X) if cntrl==1|cntrl==2, by(idhogar)
for var $x : egen	IX = max(xX), by(idhogar)

format	Iit sep Iipd_m Iipi_m Iisd_m Iisi_m Iie sep Iipd_e Iipi_e Iisd_e Iisi_e sep Iitr_p Iitr_e Iiren Iioex %9.1f
format	inghog2d sep ingnethd ingindhd insedlhd ingseihd ingexthd sep pagesphd ingauthd paesechd isecauhd sep ingtrahd ingtexhd ingrenhd ingoexhd %9.1f

summ	Iit sep Iipd_m Iipi_m Iisd_m Iisi_m Iie sep Iipd_e Iipi_e Iisd_e Iisi_e sep Iitr_p Iitr_e Iiren Iioex, sep(0) format
summ	inghog2d sep ingnethd ingindhd insedlhd ingseihd ingexthd sep pagesphd ingauthd paesechd isecauhd sep ingtrahd ingtexhd ingrenhd ingoexhd, sep(0) format
*/
********Creamos logaritmos
/*
gen		ln_ila=ln(ila)
lab var ln_ila "ing laboral anual (en logaritmo)"
gen		ln_it=ln(it)
lab var ln_it "ing total anual (en logaritmo)"
for var ipd_m ipi_m ipd_e ipi_e isd_m isi_m isd_e isi_e ie inla it: gen x_X=X/it 
summ	x_*
*/

*-------------------------------------------------------------------------------
* 2.3 Ingreso Total x hora
*-------------------------------------------------------------------------------
********Horas trabajadas por semana
gen		horasp=p513t	if nO==1
gen		horass=p518		if nO==1
gen		horasn=p520		if nO==1
egen	horast=rsum(horasp horass) if nO==1
gen		horastrab=horasn	if nO==1
replace	horastrab=horast	if nO==1&horastrab==.

*-------------------------------------------------------------------------------
* 3. Variables de Educación
*-------------------------------------------------------------------------------
tabmiss p301* if edad>=3
summ	p301*, sep(0)
tab		p301a p301b, m
tab		p301a p301c, m
tab		p301c p301b if p301a==3, m
tab		p301c p301b if p301a==4, m
/* En 1969 el sistema educativo primaria pasa de años a grados */

*-------------------------------------------------------------------------------
* 3.1. Nivel Educativo
*-------------------------------------------------------------------------------
********Probabilidad de tener Primaria completa
gen		epri=.
replace epri=1	if p301a>=4&p301a< .
replace epri=0	if p301a<=3
replace	epri=.m	if p301a==.&edad>=3
lab var epri	"=1 si tiene primaria completa"
********Probabilidad de tener Secundaria completa
gen		esec=.
replace esec=1	if p301a>=6&p301a< .
replace esec=0	if p301a<=5
replace	esec=.m	if p301a==.&edad>=3
lab var esec	"=1 si tiene secundaria completa"

*-------------------------------------------------------------------------------
* 3.2. Anhos de Educacion
*-------------------------------------------------------------------------------
********Anhos de educacion
gen		educ= .
replace educ= 0 if  p301a== 1
replace educ= 0 if  p301a== 2
replace educ= 0 if  p301a== 3&(p301b== .&p301c== .)
replace educ= 1 if  p301a== 3&(p301c== 0|p301c== 1)
replace educ= 2 if  p301a== 3&(p301b== 1|p301c== 2)
replace educ= 3 if  p301a== 3&(p301b== 2|p301c== 3)
replace educ= 4 if  p301a== 3&(p301b== 3|p301c== 4)
replace educ= 5 if  p301a== 3&(p301b== 4|p301c== 5)
replace educ= 6 if  p301a== 4
replace educ= 7 if (p301a== 5& p301b== 1)
replace educ= 8 if (p301a== 5& p301b== 2)
replace educ= 9 if (p301a== 5& p301b== 3)
replace educ=10 if (p301a== 5& p301b== 4)
replace educ=11 if  p301a== 6
replace educ=12 if (p301a== 7& p301b== 1)                                              |(p301a== 9& p301b== 1)
replace educ=13 if (p301a== 7& p301b== 2)|(p301a== 7& p301b== 3)|(p301a== 7& p301b== 4)|(p301a== 9& p301b== 2) 
replace educ=14 if (p301a== 8& p301b== 3)|(p301a== 8& p301b== 4)|(p301a== 8& p301b== 5)|(p301a== 9& p301b== 3)
replace educ=15 if                                                                      (p301a== 9& p301b== 4)|(p301a==10&p301b== 4)
replace educ=16 if                                                                      (p301a== 9& p301b== 5)|(p301a==10&p301b== 5)
replace educ=17 if                                                                      (p301a== 9& p301b== 6)|(p301a==10&p301b== 6)
replace educ=18 if                                                                                             (p301a==10&p301b== 7)
replace educ=17 if (p301a==11& p301b== 1)
replace educ=18 if (p301a==11& p301b== 2)
replace	educ=.m	if  p301a==.&edad>=3
lab var educ "anhos de educacion"
********Anhos de educacion (en logaritmos)
summ	educ epri esec
gen		ln_educ=ln(educ+1)
lab var ln_educ "anhos de educacion (en logaritmo)"

compress
save	"$dt\ENAHO_CS0416.dta", replace
