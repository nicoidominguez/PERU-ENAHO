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
* Working on the Cross-Section Database
*===============================================================================

*-------------------------------------------------------------------------------
* 0. Sample Delimitation
*-------------------------------------------------------------------------------
use		"$dt\append-ENAHO0420.dta", clear

********Control -types of hh members
gen int cntrl  =1 if p204==1&p205==2	/* miembro presente -residente habitual */
recode  cntrl .=2 if p204==1&p205==1	/* miembro ausente -residente habitual */
recode  cntrl .=3 if p204==2&p206==1	/* no-miembro presente -residente habitual */
recode  cntrl .=4 if p204==2&p206==2	/* no-miembro ausente */
recode  cntrl .=5 if p203==0			/* persona panel no presente */
lab val	cntrl cntrl
lab def	cntrl 1"miembro presente" 2"miembro ausente" 3"no-miembro presente" ///
			  4"no-miembro ausente" 5"persona panel no-presente"
lab var cntrl "tipos de miembros"

********Sample filter: for most labor variables
keep if result==1|result==2				/* Se mantiene: Hogares "completos" e "incompletos" */
keep if cntrl==1|cntrl==2|cntrl==3		/* Se mantiene: Residentes Habituales ("Miembros de Hogar" y "No-Miembros presentes") */

*-------------------------------------------------------------------------------
* 1. Variables Demográficas / Control
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
* 1.1 De la vivienda/hogar
*-------------------------------------------------------------------------------
********Urbano y Rural
replace estrato=1 if dominio==8 
gen		urb=1 if estrato>=1&estrato<=5
replace	urb=0 if estrato>=6&estrato<=8
lab val	urb urb
lab def	urb 1"urbano" 0"rural"
lab var urb "=1 hogar urbano"
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
********ID de hogares y de nucleos familiares
sort	anho conglome vivienda hogar codperso
egen	idhogar=group(anho conglome vivienda hogar)			/* ID para el hogar */
egen	idnf   =group(anho conglome vivienda hogar p203a)	/* ID para el nucleo familiar */
order	idhogar idnf
sort	anho idhogar codperso
summ	idhogar /* 198,156 hogares */
summ	idnf	/* 202,284 nucleos familiares (no incluye nucleos de una persona) */
lab var	idhogar	"id de hogar"
lab var	idnf	"id de nucleo familiar"

*-------------------------------------------------------------------------------
* 1.2 Del individuo
*-------------------------------------------------------------------------------
********Sexo
gen		sexo=1 if p207==2
replace	sexo=0 if p207==1
lab val	sexo sexo
lab def	sexo 1"mujer" 0"hombre"
lab var sexo "=1 mujer"
********Edad
gen		edad=p208a
lab var edad "edad"
********Lengua Materna
recode	p300a (4=1) (1=2) (2 3 5 6 7 8 9=3), gen(len_mat)
lab val len_mat len_mat
lab def len_mat 1"castellano" 2"quechua" 3"otro"
lab var len_mat "lengua materna"
recode	len_mat (1=1) (2 3=0), gen(castellano)
lab val castellano cast
lab def cast	1"castellano" 0"otro"
lab var	castellano "=1 lengua materna castellano"
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
* 2.1 Caracteristicas/Situacion del Trabajo y el Trabajador
*-------------------------------------------------------------------------------
********Situación del trabajador
gen		situac_pet	=.
replace	situac_pet	=1 if ocu500==1
replace	situac_pet	=2 if ocu500==2|ocu500==3
replace	situac_pet	=3 if ocu500==4
lab def	situac_pet	1"ocupado" 2"desocupado" 3"inactivo" 
lab val	situac_pet	situac_pet
lab var	situac_pet	"situacion de la poblacion en edad de trabajar (pet)"
********Tipo de inserción
gen		tipoinsercion=.
replace	tipoinsercion=1 if ocu500==1&(p507==3|p507==4)&(p510==4|p510==5|p510==6|p510==7) 
replace	tipoinsercion=2 if ocu500==1&(p507==3|p507==4)&(p510==2|p510==3) 
replace	tipoinsercion=3 if ocu500==1& p507==5
replace	tipoinsercion=4 if ocu500==1&(p507==1|p507==2)& p509==1
replace	tipoinsercion=5 if ocu500==1&(p507==1|p507==2)& p509==2
replace	tipoinsercion=6 if ocu500==1& p507==6
replace	tipoinsercion=7 if ocu500==1&(p507==7|p507==3|p507==4)&(p510==1)
lab def	tipoinsercion 1"asalariado privado" 2"asalariado publico" 3"tfnr" ///
					  4"empleador o indep. con trabajadores" 5"indep. sin trabajadores" ///
					  6"trabajador del hogar" 7"otros" 
lab val	tipoinsercion tipoinsercion
********Tipo de insercion: asalariado o independiente
gen     asalariado	=.
replace asalariado	=1 if tipoinsercion<=3|tipoinsercion==6|tipoinsercion==7
replace asalariado	=0 if tipoinsercion==4|tipoinsercion==5
********Ocupación remunerada, ocupación no remunerada
gen     ocup_remun	=.
replace ocup_remun	=1 if ocu500==1&tipoinsercion!=5
replace ocup_remun	=1 if ocu500==0&tipoinsercion==5
********Sector de actividad, codigo original
gen		cod_activr3	=p506
gen		cod_activr4	=p506r4
********Sector de actividad - ocupacion principal
********revision 4
gen     s_ciiur4 =  .
replace s_ciiur4 =  1 if p506r4 >=  111 & p506r4 <=  322 // A. Agricultura, Ganaderia, Pesca y Silvicultura
replace s_ciiur4 =  2 if p506r4 >=  510 & p506r4 <=  990 // B. Mineria
replace s_ciiur4 =  3 if p506r4 >= 1010 & p506r4 <= 3320 // C. Industrias Manufactureras
replace s_ciiur4 =  4 if p506r4 >= 3510 & p506r4 <= 3530 // D. Electricidad y gas
replace s_ciiur4 =  5 if p506r4 >= 3600 & p506r4 <= 3900 // E. Agua y Saneamiento
replace s_ciiur4 =  6 if p506r4 >= 4100 & p506r4 <= 4390 // F. Construccion
replace s_ciiur4 =  7 if p506r4 >= 4510 & p506r4 <= 4799 // G. Comercio
replace s_ciiur4 =  8 if p506r4 >= 4911 & p506r4 <= 5320 // H. Transporte y Almacenamiento
replace s_ciiur4 =  9 if p506r4 >= 5510 & p506r4 <= 5630 // I. Alojamiento y Gastronomia
replace s_ciiur4 = 10 if p506r4 >= 5811 & p506r4 <= 6399 // J. Informacion y comunicaciones
replace s_ciiur4 = 11 if p506r4 >= 6411 & p506r4 <= 6630 // K. Finanzas
replace s_ciiur4 = 12 if p506r4 >= 6810 & p506r4 <= 6820 // L. Inmobiliarias
replace s_ciiur4 = 13 if p506r4 >= 6910 & p506r4 <= 7500 // M. Profesionales, Cientificos y Tecnicos
replace s_ciiur4 = 14 if p506r4 >= 7710 & p506r4 <= 8299 // N. Administracion Privada
replace s_ciiur4 = 15 if p506r4 >= 8411 & p506r4 <= 8430 // O. Administracion Publica
replace s_ciiur4 = 16 if p506r4 >= 8510 & p506r4 <= 8550 // P. Ensenianza
replace s_ciiur4 = 17 if p506r4 >= 8610 & p506r4 <= 8890 // Q. Salud
replace s_ciiur4 = 18 if p506r4 >= 9000 & p506r4 <= 9329 // R. Artistas
replace s_ciiur4 = 19 if p506r4 >= 9411 & p506r4 <= 9609 // S. Otros Servicios
replace s_ciiur4 = 20 if p506r4 >= 9700 & p506r4 <= 9820 // T. Actividades de los hogares como empleadores; actividades no diferenciadas de los hogares como productores de bienes y servicios para uso propio
replace s_ciiur4 = 21 if p506r4 == 9900                  // U. Actividades de organizaciones y ó²§¡nos extraterritoriales
lab def s_ciiur4	 1 "A. Agricultura, Ganaderia y Silvicultura" ///
					 2 "B. Mineria" ///
					 3 "C. Industrias Manufactureras" ///
					 4 "D. Electricidad y gas" ///
					 5 "E. Agua y Saneamiento" ///
					 6 "F. Construccion" ///
					 7 "G. Comercio" ///
					 8 "H. Transporte y Almacenamiento" ///
					 9 "I. Alojamiento y Gastronomia" ///
					10 "J. Informacion y comunicaciones" ///
					11 "K. Finanzas" ///
					12 "L. Inmobiliarias" ///
					13 "M. Profesionales, Cientificos y Tecnicos" ///
					14 "N. Administracion Privada" ///
					15 "O. Administracion Publica" ///
					16 "P. Ensenianza" ///
					17 "Q. Salud" ///
					18 "R. Artistas" ///
					19 "S. Otros Servicios" ///
					20 "T. Actividades de hogares empleadores" ///
					21 "U. Organizaciones Extraterritoriales"
lab val	s_ciiur4 s_ciiur4
********revision 3
gen		s_ciiur3	=1 if ocu500==1 &  111<=p506&p506<=500
replace	s_ciiur3	=2 if ocu500==1 & 1010<=p506&p506<=1429 
replace	s_ciiur3	=3 if ocu500==1 & 1511<=p506&p506<=3720 
replace	s_ciiur3	=4 if ocu500==1 & 4010<=p506&p506<=4100 
replace	s_ciiur3	=5 if ocu500==1 & 4510<=p506&p506<=4550 
replace	s_ciiur3	=6 if ocu500==1 & 5010<=p506&p506<=5260  
replace	s_ciiur3	=7 if ocu500==1 & 6010<=p506&p506<=6420
replace	s_ciiur3	=8 if ocu500==1 & ((6511<=p506&p506< 9999)|(5510<=p506& p506<=5520))
lab def	s_ciiur3	1"agricult., caza, pesca" 2"mineria e hidrocarburos" 3"manufactura" ///
					4"electric., gas, agua" 5"construcc." 6"comercio" 7"transportes" 8"servicios" 
lab val	s_ciiur3 s_ciiur3
********Sector de actividad - ocupacion secundaria
********revision 4
gen     s_ciiur42 =  .
replace s_ciiur42 =  1 if p516r4 >=  111 & p516r4 <=  322 // A. Agricultura, Ganaderia, Pesca y Silvicultura
replace s_ciiur42 =  2 if p516r4 >=  510 & p516r4 <=  990 // B. Mineria
replace s_ciiur42 =  3 if p516r4 >= 1010 & p516r4 <= 3320 // C. Industrias Manufactureras
replace s_ciiur42 =  4 if p516r4 >= 3510 & p516r4 <= 3530 // D. Electricidad y gas
replace s_ciiur42 =  5 if p516r4 >= 3600 & p516r4 <= 3900 // E. Agua y Saneamiento
replace s_ciiur42 =  6 if p516r4 >= 4100 & p516r4 <= 4390 // F. Construccion
replace s_ciiur42 =  7 if p516r4 >= 4510 & p516r4 <= 4799 // G. Comercio
replace s_ciiur42 =  8 if p516r4 >= 4911 & p516r4 <= 5320 // H. Transporte y Almacenamiento
replace s_ciiur42 =  9 if p516r4 >= 5510 & p516r4 <= 5630 // I. Alojamiento y Gastronomia
replace s_ciiur42 = 10 if p516r4 >= 5811 & p516r4 <= 6399 // J. Informacion y comunicaciones
replace s_ciiur42 = 11 if p516r4 >= 6411 & p516r4 <= 6630 // K. Finanzas
replace s_ciiur42 = 12 if p516r4 >= 6810 & p516r4 <= 6820 // L. Inmobiliarias
replace s_ciiur42 = 13 if p516r4 >= 6910 & p516r4 <= 7500 // M. Profesionales, Cientificos y Tecnicos
replace s_ciiur42 = 14 if p516r4 >= 7710 & p516r4 <= 8299 // N. Administracion Privada
replace s_ciiur42 = 15 if p516r4 >= 8411 & p516r4 <= 8430 // O. Administracion Publica
replace s_ciiur42 = 16 if p516r4 >= 8510 & p516r4 <= 8550 // P. Ensenianza
replace s_ciiur42 = 17 if p516r4 >= 8610 & p516r4 <= 8890 // Q. Salud
replace s_ciiur42 = 18 if p516r4 >= 9000 & p516r4 <= 9329 // R. Artistas
replace s_ciiur42 = 19 if p516r4 >= 9411 & p516r4 <= 9609 // S. Otros Servicios
replace s_ciiur42 = 20 if p516r4 >= 9700 & p516r4 <= 9820 // T. Actividades de los hogares como empleadores; actividades no diferenciadas de los hogares como productores de bienes y servicios para uso propio
replace s_ciiur42 = 21 if p516r4 == 9900                  // U. Actividades de organizaciones y ó²§¡nos extraterritoriales
lab val	s_ciiur42 s_ciiur4
********revision 3
gen		s_ciiur32	=1 if ocu500==1 &  111<=p516&p516<=500
replace	s_ciiur32	=2 if ocu500==1 & 1010<=p516&p516<=1429 
replace	s_ciiur32	=3 if ocu500==1 & 1511<=p516&p516<=3720 
replace	s_ciiur32	=4 if ocu500==1 & 4010<=p516&p516<=4100 
replace	s_ciiur32	=5 if ocu500==1 & 4510<=p516&p516<=4550 
replace	s_ciiur32	=6 if ocu500==1 & 5010<=p516&p516<=5260  
replace	s_ciiur32	=7 if ocu500==1 & 6010<=p516&p516<=6420
replace	s_ciiur32	=8 if ocu500==1 & ((6511<=p516&p516< 9999)|(5510<=p516&p516<=5520))
lab val	s_ciiur32 s_ciiur3
********Ocupación, código original
gen		cod_ocupac	=p505
********Empleo formal o informal
tab		ocupinf, nol 
tab		anho ocupinf /* desde el 2012 */
tab		emplpsec
tab		emplpsec if ocupinf==1
tab		anho emplpsec

********Empleo en el sector formal o el sector informal (pasar programa a Efra)
********Tamaño de empresa
gen		tamanho_prin=1	if ocu500==1&tipoinsercion==5
replace	tamanho_prin=2	if ocu500==1&p512b<=  5
replace	tamanho_prin=3	if ocu500==1&p512b>=  6&p512b<=49
replace	tamanho_prin=4	if ocu500==1&p512b>= 50&p512b<=99
replace	tamanho_prin=5	if ocu500==1&p512b>=100&p512b<  .
replace	tamanho_prin=6	if ocu500==1&tipoinsercion==2
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

*-------------------------------------------------------------------------------
* 2.2 Ingreso Anual Total
*-------------------------------------------------------------------------------
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
********Ingresos extraordinarios laborales (gratificaciones, bonos, cts, etc.) para dependiente en ocup. principal o secundaria
gen		ie		=d544t	if (d544t >0&d544t !=999999&d544t !=.)  
lab var ie		"ing anual extraordinario"
********Ingresos no laborales
********Transferencias corrientes
********Definición #1
gen		itr_p	=.
replace	itr_p	=d556t1	if d556t1>0&d556t1!=999999
lab var itr_p	"ing transferencias corr. monetarias- país "
gen		itr_e	=.
replace	itr_e	=d556t2	if d556t2>0&d556t2!=999999
lab var itr_e	"ing transferencias corr. monetarias- exterior"
egen	itr		=rowtotal(itr_p itr_e)
replace	itr		=.		if itr_p==.&itr_e==.
lab var itr		"ing transferencias corr. monetarias- total"
********Rentas de la propiedad
gen		iren	=.
replace	iren	=d557t	if d557t>0&d557t!=999999
lab var iren	"ing rentas de propiedad monetaria (intereses, utilidades)"
********Transferencias corrientes
gen		ioex	=.
replace	ioex	=d558t	if d558t>0&d558t!=999999
lab var ioex	"otros ing extraordinarios (herencia, seguro, indemnizacion)"
********Estableciendo correcciones -consistencia con sumaria
********Ocupación principal es independiente			->	Ingresos Principales Dependientes ==.
********Ocupación principal es dependiente				->	Ingresos Principales Independientes ==.
********Ocupación principal/secundaria es independiente	->	Ingresos Extraodinarios Dependientes ==.
for var ipd_*: replace X=. if (p507==1|p507==2)						/* Ocu. Ppal. Dependiente */
for var ipi_*: replace X=. if (p507==3|p507==4|p507==6)				/* Ocu. Ppal. Independiente */
for var ie	 : replace X=. if (p507==1|p507==2)&(p517==1|p517==2)	/* Extraordinario Dependiente */
********Agregando los ingresos
egen	ip_m	=rsum(ipd_m ipi_m)
replace ip_m	=.		if (ipd_m==.&ipi_m==.) 
lab var ip_m	"ing anual ocup ppal.-monetario" 
egen	ip		=rsum(ip_m ipd_e ipi_e)  
replace ip		=.		if (ip_m==.&ipd_e==.&ipi_e==.) 
lab var ip		"ing anual ocup ppal." 
egen	is   	=rsum(isd_m isi_m isd_e isi_e)
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
********Ingresos de pareja jefe de hogar
********Ocupación Principal
egen	mip=rowtotal(ip ie) if (p203>=1&p203<=2)&p207==2	/* mujer jefe o cónyuge */
egen	hip=rowtotal(ip ie) if (p203>=1&p203<=2)&p207==1	/* hombre jefe o cónyuge */
egen	rip=rowtotal(ip ie) if (p203!=1&p203!=2)			/* resto del hogar */
egen	aip=rowtotal(ip ie) if (p203==1|p203==2)			/* ambos jefe y cónyuge */
egen	m_ip=sum(mip), by(idhogar) /* mujer jefe o cónyuge */
egen	h_ip=sum(hip), by(idhogar) /* hombre jefe o cónyuge */
egen	r_ip=sum(rip), by(idhogar) /* resto del hogar */
egen	a_ip=sum(aip), by(idhogar) /* ambos jefe y cónyuge */
********Ocupación Secundaria
egen	mis=rowtotal(is) if (p203>=1&p203<=2)&p207==2	/* mujer jefe o cónyuge */
egen	his=rowtotal(is) if (p203>=1&p203<=2)&p207==1	/* hombre jefe o cónyuge */
egen	ris=rowtotal(is) if (p203!=1&p203!=2)			/* resto del hogar */
egen	ais=rowtotal(is) if (p203==1|p203==2)			/* ambos jefe y cónyuge */
egen	m_is=sum(mis), by(idhogar) /* mujer jefe o cónyuge */
egen	h_is=sum(his), by(idhogar) /* hombre jefe o cónyuge */
egen	r_is=sum(ris), by(idhogar) /* resto del hogar */
egen	a_is=sum(ais), by(idhogar) /* ambos jefe y cónyuge */
lab var m_ip	"ing laboral ocup ppal. mujer jefe o conyuge"
lab var h_ip	"ing laboral ocup ppal. hombre jefe o conyuge"
lab var r_ip	"ing laboral ocup ppal. resto del hogar"
lab var a_ip	"ing laboral ocup ppal. mujer y hombre jefes"
drop	mip hip rip aip mis his ris ais

*-------------------------------------------------------------------------------
* 2.3 Ingreso Total x hora
*-------------------------------------------------------------------------------
********Horas trabajadas por semana
gen		horasp=p513t	if ocu500==1
gen		horass=p518		if ocu500==1
gen		horasn=p520		if ocu500==1
egen	horast=rsum(horasp horass) if ocu500==1
gen		horastrab=horasn	if ocu500==1
replace	horastrab=horast	if ocu500==1&horastrab==.

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

*-------------------------------------------------------------------------------
* 4. Deflactores
*-------------------------------------------------------------------------------
glo	def	"$id\2020\Gasto2020\Bases"
rename	anho aniorec
sort 	aniorec dpto
mer m:1	aniorec dpto using "$def\deflactores_base2020_new.dta", nogen keep(3)	/* deflactor temporal: i00 (ipc general) */
mer m:1	dominioA using "$def\despacial_ldnew.dta", nogen						/* deflactor espacial: ld  */
rename	aniorec anho

*-------------------------------------------------------------------------------
* WRAPPING UP
*-------------------------------------------------------------------------------
sort	anho dpto dominioA urb conglome vivienda hogar idhogar
compress
save	"$dt\ENAHO_CS0420.dta", replace
