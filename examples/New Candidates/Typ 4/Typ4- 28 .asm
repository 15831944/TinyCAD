
  ;Achtung beim Brennen: Der Sprut-Brenner 5 erkennt den 16F628A manchmal nicht. Das liegt an der Codeprotection
	;Die entfernt der Brenner durch etwas geringe Spannung nicht zuverl�ssig.
		;Wenn garnichts mehr geht: "Paten-Chip" in die DIL-Fassung einsetzen also einen unbenutzten jedenfalls korrekt gel�schten 16F628
		; Dann die Erkennung durchf�hren. Dann "heimlich" den Paten-Chip  gegen den ICSP  Stecker austauschen und 5 bis 10 mal die Code Protection entfernen.
		;Danach gehts dann wieder zu programmieren.
	
 LIST P=PIC16F628A 
 #include P16F628A.inc

__config B'11110100010000' 


  ;EINSTELLUNGEN						EINSTELLUNGEN						EINSTELLUNGEN
  ;EINSTELLUNGEN						EINSTELLUNGEN						EINSTELLUNGEN
  ;EINSTELLUNGEN						EINSTELLUNGEN						EINSTELLUNGEN
  ;EINSTELLUNGEN						EINSTELLUNGEN						EINSTELLUNGEN
		;Variablen:


;Achtung:!!!  Wenn hier von Sekunden die Rede ist, dann handelt es sich um ein Zeitintervall, das im Laufe der Programmierung 
			; immer l�nger wurde, je mehr Befehle  und Interrupts dazukamen.  Man k�nnte die 200ms Zeitschleife verk�rzen um zu korrigieren,
			;das w�rde aber auch andere Einstellungen beeinflu�en. Deshalb lasse ich es so. Der Einschleichtimer geht nach korrekter Zeit (nur 1Prozent ungenau)

							;        1 sec  =    fast  2 sec
							;        1 sec  =    fast  2 sec   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
							;        1 sec  =    fast  2 sec    !!!!!!!!!!!!!!!!!!!!!!!!
							;        1 sec  =    fast  2 sec
		


			;  empfohlene Einstellungen mit drei Ausrufezeichen gekennzeichnet. Die anderen lieber nicht ver�ndern. 
 ;												!!!



 ;Spannungswandler f�r Betriebsspannung:
PWMPeriode  EQU D'11' ;!!!	;hier PWM-Periodendauer einstellen um bei h�herer UB den Wirkungsgrad etwas zu heben, 
								;oder Regelschwingungen durch zuviel Power-Angebot zu verhindern. (Knattern bei h�herer UB)
							;mit 7 l�ufts  ab 2,8V  mit Periode 11 erst ab 3,3 . Darf nicht kleiner als 7, sonst Kurzschlu� = Hardwarebesch�digung !!!!!!!!!!!
 ;betr. Brummen				; Werte �ber 80 kommen in den Tonfrequenzbereich runter. �ber 20bis 30 d�rfte nicht ben�tigt werden.
							; Die erzielbare Leistungsersparnis oberhalb von PR=11 ist sowieso unter  10Prozent. 
  

	;Lautst�rkeregelung und Ausschaltung 
VRLevel1	EQU  B'11100001'       ;die vier Grenzwerte f�r die NF-Pegelmessung  standardm��ig 1/24, 2/24, 4/24, 8/24 von VDD (max m�glich 15/24)
VRLevel2	EQU  B'11100010'			; VDD in diesem Ger�t = 4,8V Die Spannungen werden in VRCON eingetragen und von der Spannugsreferenz erzeugt und mit
VRLevel3	EQU  B'11100100'			;Komparator verglichen Pegel 1 ist dann unter Level 1 und Pegel 5 �ber Level 4
VRLevel4	EQU  B'11101000'			; die drei Einsen vorne dran m�ssen nat�rlich bleiben, damit macht VRCON was anderes.
										;normalerweise w�rde ich an den Leveln nicht �ndern, die sind schon ziemlich sophisticated
										;vor allem h�ngt fast alles andere dann mit drin.

	;Lautst�rkeregelung:
SekProUe    EQU  D'2' ;!!! ;Anzahl der Sekunden pro denen eine Ueberst bei vorhandenem Signal erlaubt wird (will man absolut garkeine �bersteuerungen,
							; dann wird dadurch die Modulationslautst�rke so gering, dass man mehr Verst�ndlichkeit verliert, als gewinnt.) 3sec ist hier Standardwert.
							;Also senken wenn man's lauter will heben wenn man weniger �bersteuerungen will.
							
UeGeduldEnde  EQU  D'80'      ;Anzahl der �bersteuerungen nach denen Ueauswert beschlie�t,die Regelzahlen, dh die langfristigen Normallautst�rkevergleichszahlen 
								;(Regelzahlen werden andernorts verglichen mit Klassensumme) lieber etwas zu senken.Es wird auf und ab gez�hlt.Null ist die 60
MehrUeWagen  EQU  D'41'		;Anzahl +1 der erlaubten aber ausgebliebenen �bersteuerungen nach denen Ueauswert beschlie�t,die Regelzahlen,  
								;dh die Normallautst�rkevergleichszahlen(Regelzahlen werden andernorts verglichen mit Klassensumme) lieber etwas zu heben.
									;Es wird auf und ab gez�hlt.Neutralstellung ist die 60
						;KLASSENSUMMen liegen zwischen 65 und 80  (vorbehaltlich inc Vergabe f�r �st) f�r eine gute Vollaussteuerung mit Sprache u.�. sch�tze ich Summe = 72 als Idealwert.(ohne Sprechpausen)
        				; Die Klassensumme ist sozusagen der �ber eine Sekunde integrierte Lautst�rke-Wert falls nicht gleich wegen �berst abgebrochen wurde.
						;Entfernt sich der obere Wert weiter von 60 ist die Schaltung etwas geduldiger, bevor sie aber letztenendes die Normallautst�rke 
						;genauso senkt.Die Untergrenze wirkt umgekehrt, und mu� mindestens 10 sein.(gesch�tzt)(Unterlaufvermeidung)
						;eigentlich machen die beiden Variablen nicht viel. Am besten lassen
						;Die Klassensumme dr�ckt die aktuelle Modulationsst�rke aus und wird entsprechend der Regelzahl eingestellt, indem die VU vergr��ert oder 
						;verkleinert wird. Bei vollem VU Regel-Umfang hat sie also mit der am Empf�nger geh�rten Lautst�rke zu tun, aber wenig mit der Lautst�rke am Abh�rort.


RegelZOG    EQU D'73';!!!   ;Regelzahl Obergrenze Standard 74  Begrenzt die langfristige automatische Modulationsst�rke-Regelung die sonst der eingestellten �bersterungs
						;H�ufigkeit folgt. Standard ist 74   (Versucht dann also die Modulationsst�rke aufzudrehen, wenn weniger �bersteuerungen sind als 
						;erlaubt, indem die Zielmarge f�r die Klassenzahl heraufgesetzt wird. Aber bei 74 ist dann eben Schlu�.) Setzt man diese Zahl auf 
						; einen niedrigen Wert z.B.71 hat man garantiert immer eine so niedrige Modulation, dass auch z.B. Trommelschl�ge (kurz und wesentlich lauter als Gespr�ch u.�.)
						; sauber vor dem Hintergrund geh�rt werden. Daf�r mu� man aber die Ohren spitzen um die Hintergrundgespr�che zu h�ren.

RegelZUG	EQU D'71';!!!	;Regelzahl Untergrenze  Wenn es einen nervt, dass die Modulation auf Dauer immer leiser wird, dadnn kann man entweder SEKproUe
						; senken also mehr �'s erlauben, oder ganz rabiat hier die Untergrenze f�r die Regelzahl anheben.
						;die Untergrenze sollte nicht gr��er sein als die Obergrenze.
					
						;macht man Unter und Obergrenze der Regelzahl gleich, also meinetwegen beide gleich 72, dann  versucht sich die Modulationsst�rke -bei Signal-
						;immer auf diesen Wert einzuregeln. Je nach Ger�uschart, kann es bischen leise werden, oder �bersteuern, daf�r wei� man aber ,
						; was man kriegt.
						;Ganz rabiat w�re dann die Festlegung der VU-Stufe selber mit VUMinBegr und VUMaxBegr s.u. dann passt sich garnichts mehr an.

PrimstartRegelZahl  EQU D'72' ;!!! ;Mit dieser Regelzahl startet das Ger�t beim ersten Einschalten nach dem Batterieanschlie�en.
								;Sinnvollerweise innerhalb Ober oder Untergrenze weil sonst nach einer Sekunde sowieso unwirksam.


SprechPaZ7     EQU D'7'   ;Sprechpausenabwarte-Z�hler Erst nach sovielen (Standard 7) Sekunden ganz leise(nur unterste Klasse, einmal zweite K-Summe unter 67) wird das Leise-sein
							; als nicht vorhandensein oder ganz leise sein von Signal gewertet und die Verst�rkung trotzdem aufgedreht. Und Abschalten �berhaupt erm�glicht.
							;sonst ist ein gewisses Minimum an Lautst�rke und L-Varianz erforderlich, damit die Regelung �berhaupt reagiert. (Aber auch abw�rts)
SprechPaZ11    EQU D'11'  ;Sprechpausenabwarte-Z�hler Nach sovielen (Standard 11) Sekunden ziemlich leise keine Pegel gr��er als zwei erfolgt alternativ dasselbe,
							; wie bei Z�hler 7
							;Wenn einen st�rt, dass jedesmal wenn mal einer nen Moment nichts sagt, die VU raufgeht und das erste Wort vom Satz 
							;furchtbar klirrt,kann man die Zahlen etwas erh�hen.
							;St�rt einen aber, dass wenn einer was gesagt hat, es furchtbart lange dauert, bis die VU soweit aufgedreht ist, dass man 
							;die leise Antwort verstehen kann, kann man die Zahlen auch etwas senken.
							;Durchaus relevante Einstellung.

VUMinBegr   EQU		D'60';!!!;Werte von 60 bis 66 (beide inclusive ) f�r die beiden Begrenzungen sind m�glich. Dar�ber und darunter keine Wirkung 								
VUMaxBegr   EQU		D'66';!!! ;schlimmstenfalls Absturz (nicht �berpr�ft)  Legt man beide Werte auf 60, ist die Verst�rkung minimal und das Ger�t kann
							; auch von gro�em Krach nicht �bersteuert werden, egal, was die Regelung gerne machen w�rde. Leises ist dann nicht mehr 
						;zu h�ren.VUMaxBegr darf nicht kleiner sein als VUmin Begr. Im Intervall zwischen beiden Werten entscheidet die VURegelung.
						; stellt man beide Werte auf 66 gibt das Ger�t alle Fl�sterger�usche perfekt wieder ohne eines zu verpassen, �bersteuert aber gnadenlos
						; bei auch nur etwas gr��eren Lautst�rken. Durch �bersteuerungen kann der Funk-St�rpegel etwas ansteigen.
						;stellt man Min auf 60 und Max auf 66 hat man vollen Regelumfang, die Anpassung dauert aber eventuell einige Sekunden.
						; Max auf 66 stellen darf man ev. nur in einem sehr leisen Raum (Keller) weil die Lautst�rkeauswertung 
						;(soweit man es auf sie ankommen l�sst)sonst das Ausschalten nicht mehr erlaubt da st�ndig "�bertragenswertes" Fl�he-Husten geh�rt wird.
						;�u�erst relevante Einstellung.
						;f�r 7 VU-Stufen 0bis 6 entspr 6 Widerst�nden an 6 Ports und einmal kein Port
						;niedrigste vVUistStufe = niedrigste VU  =Krachtolerant
						;Stufe 66 ist sehr empfindlich, man h�rt sogar das leise Ticken einer 2 Meter entfernten Wand-uhr.

		;Ausschaltung:
		;Lichtbewertung:
LichtBewNenn   EQU  D'2' ;!!! ;Alle soviel Sekunden flie�t die Beleuchtungsauswertung  in den Ausschalt-Auf/Ab-Z�hler ein. Als Bruchnenner der Ausschaltgewichtung sozusagen.
							;Hier lasssen sich verschiedene Verh�ltnisse einstellen um das gew�nschte timing einzustellen. Standard ist 3
							; Bruchzt�hler sind sozusagen die folgenden Bonusse und Malusse (Ich wei�, man schreibt das eigentlich mit Apostroph und ohne Pluralendung):
							;Der Nenner gilt auch f�r die Kompensation

LichtanBonus   EQU  D'5' ;!!!  ;Um soviel wird der Ausschaltz�hler heraufgez�hlt wenn Licht an ist also die Einschaltdauer verl�ngert.
							;(das findet statt bei jedem LichtBewNenn =0 also standardm��ig alle drei sec)
							;tr�gt man hier 4 ein, schaltet sich das Ding wohl garnicht mehr aus, solange es hell ist.(Helligkeitsschwelle =ca Kellerfunzel indirekt gilt grade noch als hell)

LichtanMalus   EQU  D'0' ;!!!   ;Um soviel wird der Ausschaltz�hler heruntergez�hlt wenn Licht an ist also die Einschaltdauer verk�rzt.
							;Falls das Ding schreckhaft sein soll, um bei Licht nicht angepeilt werden zu k�nnen, oder nur das Dunkelgefl�ster 
							;interessant genug ist um daf�r Batteriestrom zu vrschwenden.

LichtKompensMalus  EQU  D'3';!!! ;hiermit kann man eigentlich alles kompensieren, egal,warum es nicht schnell genug ausschaltet. Nicht nur Licht.
							 ;Wenn man alle drei (oder n)Sekunden bei Licht  den Ausschaltz�hler heraufz�hlt, empfiehlt es sich, ihn kompensatorisch 
							;in gleichen Intervallen herunter zu z�hlen, damit im Dunkeln das Ausschaltverhalten gleich bleibt, und nur im Hellen l�nger an.
							;vergr��ert man den Malus, schaltet es schneller aus.

LichtKompensBonus  EQU  D'0';!!!  ; hiermit kann man eigentlich alles kompensieren.Bonus vergr��ern =es bleibt l�nger an.  Entweder Bonus oder Malus sollte gleich Null.
								;alles andere ist albern, weil ein Bonus hier  genau einen Malus hier kompensiert.
			;Das obige gilt umgekehrt f�r Liebhaber der Dunkelheit: soviel wie hier drin steht, wird alle n Sekunden heraufgez�hlt= Ein-Zeit verl�ngert.
					;Frustauswertung f�r die Ausschaltung :
					;Frust-Steuerung: Wenn die Maschine selbst ein Frustrationsverhalten zeigt, werden dem Zuh�rer Frustrationen erspart.
FrustBer�ckNenn    EQU  D'3';!!!  ;(Standard 3)Alle soviel Sekunden flie�t die Frustber�cksichtigung In die Ausschaltbewertung ein. Das hei�t, wenn eine Frustsituation
								;festgestellt wurde, wird der Ausschaltz�hler jedesmal noch eins extra runtergez�hlt, oder sogar zwei.
							;Eine Frustsituation ist, wenn sich das Ger�t schon oft eingeschaltet hat, ohne dass hohe oder stark wechselnde Pegel gemessen 
							;wurden.Das regelt ein langfristiger Auf/Ab-Z�hler. D.h. beim Empf�nger geht der Squelch auf und dann ist nichts lohnendes zu h�ren
			;Achtung: Nicht auf einen zu hohen Wert stellen, weil auch die Anpassung der Vox - Empfindlichkeit bei dieser Gelegenheit erfolgt.
			; (Mindestens einmal pro Einschaltung.)
			;Denn es ist nat�rlich auch frustrierend, wenn das Ding dauernd umsonst anspringt, selbst wenn es sich dank anderer Einstellungen vielleicht schnell wieder ausschaltet.
FrustBerueckZaehler  EQU  D'1';!!!;(Standard 1)Der entsprechende Z�hler. ( je nach Vox-Stufe wird er zweimal einmal oder garnicht vergeben.)
							;Wenn Frust fetsgestellt wurde, oder eine hohe Voxstufe festgelegt, schaltet es sich dadurch schneller aus.
							; Wieviel schneller, entscheidet diese Zahl. Gro�e Zahl = in dem Fall noch schneller aus.


		;weiter mit Ausschaltung:
	;Ber�cksichtigung der absoluten Lautst�rke f�r die Ausschaltung:


AbsolautNenn   EQU  D'3';!!!   ;Alle soviel Sekunden werden Bonus'  f�r absolute Lautst�rke Pegel vergeben. 
                            ;(Diese Bewertung konkurriert mit der Bewertung f�r mehrfachen Lautst�rkewechsel innerhalb einer Sekunde (der Klassenzahl))
							; Will man den "nervigen Quatsch" mit der Ber�cksichtigung sprach�hnlicher Lauts�rkerythmen nicht, dann w�hlt man hier einen 
							;kleineren Nenner mindestens =1  f�r die Bonusse gr��eren Z�hler.
AbsolautLo    EQU   D'67';!!!  ; F�r Klassensummen  (also Lautst�rkebewertende Zahlen zwischen 65 und80) wenn gr��er/= dieser Zahl, (Standard 68) werden 
AbsoLoBonus   EQU   D'3' ;!!!   ; soviele Bonus vergeben, wie -hier- steht. Das hei�t, wenn's bei Ger�uschen l�nger an bleiben soll,
								 ;mu� man hier (untere Zeile) wenigstens "1" reinschreiben

							
				;Wenn man absolaut stark oder ausschlie�lich ber�cksichtigt, dann bedeuten niedrige Grenzwerte, dass es nur bei sehr leise ausschaltet.
				;hohe, dasses nur bei sehr laut anbleibt.
AbsolautHi    EQU   D'71';!!!  ; F�r Klassensummen  (also Lautst�rkebewertende Zahlen zwischen 65 und80) �ber dieser Zahl, (Standard 72) werden
AbsoHiBonus   EQU   D'3' ;!!!  ; soviele zus�tzliche Bonus vergeben, wie -hier- steht. Also einer f�r �ber 68 und noch einer f�r �ber 72.
							;wenn's bei Krach l�nger an bleiben soll, mu� man hier wenigstens "1" reinschreiben
							;Die Absolaut-Bewertung ist aber relativ zur Lautst�rkeregelung. Solange noch die Verst�rkung hoch ist, 
							;werden hier auch leisere Ger�usche bewertet.Aber gegen Ende wird ja die VU durch die Lautst�rkeregelung aufgedreht, soweit erlaubt.
							;Und wenn dann immer noch keine hohen Pegel sind, dann verl�ngert auch Absolaut nicht mehr die Einschaltzeit.
							;Will man Absolaut verwenden (Bei anderen Ger�ten das einzige was es gibt) mu� man also uU die Maximalverst�rkug begrenzen s.o.

UestVerlaengerung  EQU D'1'  ; wenn es bei �bersteuerungen grade zu schnell abschaltet oder l�nger laufen soll.



;Auswertung der Klassenzahl also der Lautst�rkevarianz innerhalb einer Sekunde f�r die Ausschaltung:
EinklassenMalus  EQU D'2';!!!  ; Wenn bei den f�nf Messungen in der ganzen Sekunde nur eine Lautst�rkeklasse vorgekommen ist(also immer dieselbe) spricht das
							;daf�r, dass ein St�rger�usch vorliegt (irgendwas brummt oder rauscht) Das spricht eher f�r ausschalten Also wird der Auf/Ab
							;Z�hler f�r die Ausschaltung soviel runtergez�hlt wie hier steht.  (Standard =1)
							; Achtung, die Zahlen fallen mehr ins Gewicht, weil die Auswertung jede Sekunde erfolgt.
							  ; Bei Zwei Klassen passiert garnichts
DreiklassenBonus EQU D'4' ;!!! ;Bei Drei Klassen was selten ist, aber stark f�r interessante Ger�usche z.B.Sprache spricht, gibt es Bonusse (Standard=2)

VierklassenBonus EQU D'6' ;!!! ;Bei Vier Klassen (echt ziemlich selten, aber interessant) standardm��ig drei Bonusse.(Addiert sich nicht mit dem dreiKlassen Bonus.Entweder oder.Also keine f�nf zusammen)
							;F�nf Klassen kommen nicht vor, da die f�nfte Klasse als �bersteuerung gewertet wird und sofort VU runterschaltet und deshalb nicht in der Klassensumme enthalten sein kann.
		
		;Grenzen des Ausschalt-Bonus (also Geduld sozusagen)
OfenausZahl   EQU D'40'    ; (Standard 40) Unterschreitet der AusschaltBonus bei sek�ndlicher Auswertung diese Zahl, dann wird das Ger�t ausgeschaltet. (Sofort und �berhaupt)
							;Die Zahl sollte mindestend zwanzig betragen, da mehrere Herabsetzungen des Ausschaltbonus durch verschiedene Module 
							;erfolgen k�nnen, ehe der Bonus ausgewertet und gedeckelt wird. Nat�rlich mu� eine Unterschreitung von Null unbedingt vermieden werden.
OfenheissZahl  EQU D'70'   ;Der maximal m�gliche Wert f�r  den Ausschaltbonus. Denn: auch wenn die �bertragung noch so sch�n:Wenn sie zuende ist, soll
							;es ja auch noch mal vor morgen ausschalten.  Standardm��ig 70  Mu� unbedingt unter 230 (Das ist aber auch ne Ewigkeit)
							;Startwert f�r den AusschaltBonus (nach dem Aufwachen durch ein Ger�usch) ist 60

StartBonus    EQU D'70'     ;StartBonus wird nach dem Erwachen als AusschaltBonus geladen. Daf�r dass es sich �berhaupt eingeschaltet hat, wird eine 
							;gewisse Zeit bedingungslos vorgegeben, ohne dass die Bewertungscharakteristik bei l�ngerem Laufen dadurch ver�ndert wird.
							;StartBonus mu� ungef�hr  �ber Ofenaus liegen und ungef�hr unter Ofenheiss. Ein paar mehr oder weniger k�nnen noch Sinn
							; machen, also soviel wie bis zur ersten Bewertung nach 1 "Sekunde" ge�ndert worden sein kann.Also normalerweise so +/- 4
							;Standard f�r StartBonus ist 60
Voxoffset   EQU   D'3' ;!!!   ;(Standard=1)  Voxoffset=0 d.h. immer unempfindlich beide empf. Stufen deaktiviert. Vermeidet Nerverei 
				;1=empfindlichste Stufe deaktiviert.(Standard.Geht in normalen R�umen kaum anders da die Weckschaltung wirklich fl�sterempfindlich ist.)							
 					;2= voller Regelumfang alle drei Stufen m�glich. Nur wo es wenigstens manchmal ganz ganz leise ist.
							; 3= unempfindlichste Stufe deaktiviert. 
					;4= beide unempfindlichen Stufen deaktiviert.Um immer jedes Fl�sterger�usch mitzukriegen.Geht aber jedesmal los, wenn in der 
						;Wohnung dr�ber ein Kind rumrennt,oder was vom Tisch f�llt.
				;Der Voxoffset hat keinen Einflu� auf vVoxist Sufe, (den von der Regelung gew�nschten Wert) 
				;weil er erst danach wirkt und diese nicht verstellt.Die Ausschaltbeschleunigung durch Frust bleibt also unbeeinflu�t.



MeldeIntervall  EQU  D'27';!!!  ; Alle soviel Sekunden wird, --- falls --- das Ger�t grade sendet, ein Meldeton gesendet, der Auskunft gibt, 
					    	;ob es im �berwachten Raum hell ist.
							; Null hei�t, es werden keine Meldet�ne gesendet.  =  Feature deaktiviert.    
							; Ein BIP-Ton bedeutet, es ist hell,  zwei T�ne: es ist dunkel. Merken:dunkel = zweisilbig. Hell = einsilbig.
							; Falls das Feature �berhaupt aktiviert ist, kommt der erste Ton 4 sec nach  Erwachen. 254 = alle 8 Minuten weitere T�ne.
							;Meldet�ne haben ein etwas gr��eres St�rspektrum und etwas gr��ere Reichweite, darum nicht zu kurze Intervalle w�hlen!
ErstMeldung		EQU  D'4'   ;soviele  "Sekunden" nach dem Erwachen wird der erste Meldeton gesendet. (Falls �berhaupt.)  4 "Sek" sind ungef�hr 7 Sekunden.
							;nicht zu schnell nach dem Einschalten, da der Lichtsensor sehr hochohmig ist und mehrere Sekunden Anpasszeit hat.

Einschleichzeit EQU D'10';!!!  ;(Standard = 0h bzw.Trottelsperre 10min) Erst nach soviel  Minuten/Stunden wie hier steht macht sich das Ger�t sendebereit. bis dahin wartet es relativ stromsparend ohne Aktion
							;ist also bis dahin auch nicht ortbar.0 bis 254

Einschleichmassstab  EQU D'1';!!! ; 1 hei�t hier, dass die Einschleichzeit in Minuten gemessen wird also bis 4Stunden ca. 2hei�t in Stunden also bis ca 10 Tage.
								;ACHTUNG ACHTUNG:  Andere Werte als 1 oder zwei sind hier nicht vorgesehen und f�hren zum Absturz!
								;Langfristigere Verz�gerungen z.B. 254 Tage machen sowieso keinen Spass. Und bei noch l�ngeren ist sowieso die Batterie leer.



 ;RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR

												;REGISTER-LISTE:
												;REGISTER-LISTE:
												;REGISTER-LISTE:
												;REGISTER-LISTE:
	;Register:

vCopyRota EQU  0x22
vPWMCon  EQU  0x23
;XXXleer9 EQU  0x24 
;XXvRech1   EQU  0x25 
vPegel1  EQU  0x26
vPegel2  EQU  0x27
vPegel3  EQU	0x28
vPegel4  EQU	0x29
vPegel5  EQU	0x2A
    ;Zeitschleife
Kor1MReg   	EQU     0x2B		;plus Konstante-Register  f�r Schl1M
Inn1MReg   	EQU     0x2C		;innere Schleifenzahl mal
Auss1MReg	EQU     0x2D		;aeussere Schleifenzahl-Reg
SupAuss1M   EQU		0x2E		;ganz �ussere SchlZahl-Register

Schl20Reg  EQU   0x2F

vMyFlags  EQU   0x30   
						; MyFlags,0   Set = Ausschaltung nach sleep ist vorgesehen Abschluss einstellungen vornehmen
						; MyFlags,1 gesetzt: In letzter Sekunde waren nur 1oder2 Lautst�rkeklassen
						; MyFlags,2  gesetzt: 1n letzter Sekunde war ein VU-Stufen-Wechsel
						; MyFlags,3 nur f�r Testzwecke in fertigem Programm unben�tzt
						; MyFlags,4  RelevanzBit:gesetzt: Es wurde k�rzlich eine Ger�uschkulisse im Aussteuerungsbereich wahrgenommen
						; MyFlags,5  set =letzter Durchgang  war 3oder 4 Klassen  (ab Ausschaltbewertung)
						; MyFlags,6   ;Es wird bis zur n�chsten Klassensumme gespeichert ob ein oder mehr �bersteuerungen vorkamen.
						; MyFlags,7   ;Es wird bis zur n�chsten Klassensumme gespeichert ob ein oder mehr �bersteuerungen vorkamen.

					
v5Runden        EQU  0x31
Kor100Reg       EQU  0x32		;plus Konstante   f�r Schl100
Inn100Reg       EQU  0x33		;innere Schleifenzahl mal
Auss100Reg	    EQU  0x34		;aeussere Schleifenzahl
vAusschaltBonus EQU  0x35
vEreignis       EQU  0x36
vBeschleuniger   EQU  0x37
vKlassenZahl    EQU  0x38
;XXXleer6		EQU  0x39
;XXXleer7       EQU  0x3A
vUebersteuerung EQU  0x3B
vZaehl60  		EQU  0x3C
vVoreinstellVU  EQU  0x3D
vVUistStufe     EQU  0x3E
vVUistBank1		EQU   0x74         ; Register in Bank 1 damit ich nicht dauernd wechseln mu� beim VUports Trisa-Stellen ge�ndert:Allbank
vVoxIstStufe    EQU   0x72      ;Allbankadresse
WTemp           EQU   0x70     ; Als Interrupt Sicherungsregister in allen B�nken addressierbar.(Bereich 70 bis7F)
StatusTemp      EQU   0x71      ; StatusTemp d�rfte aber �berall in Bank 0 liegen da nur von dort aus addressiert
;xxxleer4		EQU  0x3F
vKlassenSumme   EQU  0x40
vRegelZahl      EQU  0x41
vZ�hler7		EQU  0x42
vZ�hler11    	EQU  0x43
vRegelZahlSum   EQU  0x44
vUeErlaubt      EQU  0x45
vFrust  		EQU  0x46
vAbsoZaehl      EQU  0x47
vFrustBer�cksi  EQU  0x48
vInn			EQU  0x49
vAuss			EQU  0x4A
vSupAuss		EQU  0x4B
vXh3			EQU  0x4C
vStart1			EQU  0x4D
vMeldeIntervall EQU  0x4E
vTonADauer		EQU  0x4F
vTonAFreq		EQU  0x50
vMyFlagsB       EQU  0x73
vLimitCounterA  EQU  0x51
vLimitCounterB  EQU  0x52
vFeierSignal    EQU  0x53   
vProoftemp1	    EQU  0xA4		;RAM Adr    BANK1 f�r EEPROM-Bearbeitung
vProoftemp2	    EQU  0xA5		;RAM Adr    BANK1 f�r EEPROM-Bearbeitung	
vLoBysav    	EQU  0xA6		;RAM Adr    BANK1 f�r EEPROM-Bearbeitung		
vUpBysav   	    EQU  0xA7		;RAM Adr    BANK1 f�r EEPROM-Bearbeitung


  ;EEPROM-Adressen:

eInitproof1	 EQU    0x01        ;EEprom Adresse
eInitproof2  EQU    0x02		;EEPROM Adr
eUpEEP		 EQU	0x03		;EEPROM Adr
eLoEEP    	 EQU    0x04		;EEPROM Adr



			; HAUPT PROGRAMM  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
				; HAUPT PROGRAMM  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
					; HAUPT PROGRAMM  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
						; HAUPT PROGRAMM  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
							; HAUPT PROGRAMM  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
								; HAUPT PROGRAMM  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


	CALL Startverz�gerung
	CALL PrimInit
Ruf1 CALL WInit
	GOTO Maerchen
Vector4 NOP
    BTFSS INTCON,2    ;Interrupt-Check (TMR0-Flag betr Nachregelungsroutine PWM Spannungswandler)
	GOTO  Ruf0
	GOTO PWMStart
	NOP

    ;Schlafvorbereitung
Maerchen BSF   STATUS,RP0      ;PWM aus
	BCF  VRCON,7
	BSF  TRISB,0
	BCF STATUS,RP0
	MOVLW   B'00000111'
	MOVWF   CMCON
    BCF INTCON,5         ;timer0 disablen (PWM Stellzyklus-Timer)
	CLRF CCP1CON       ;PWM aus mit output low
	BCF T2CON,2
	BCF PORTA,3    ;Sendestufe ausschalten
	BCF PORTB,3			;da P6 jetzt normaler inout-Pin den lieber auch nochmal low, sonst ist Der PWM-SchaltFet im Kurzschluss
	CALL Schl1M   ;P�uschen, damit garantiert Ruhe an der Vox eintritt (ev verk�rzen)

	BCF INTCON,1      ;RB0 Interrupt scharf machen FLAG
	BSF INTCON,4		;enable
	BSF INTCON,7		; GIE
	SLEEP
Stop	NOP
	;	GOTO  Stop       ; Nur zum Testen damit's nicht gleich wieder einschl�ft mu� wieder deaktiviert !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	GOTO Maerchen
	NOP
;-----------------------------------

Ruf0 BTFSC INTCON,4  ;Interrupt-Check  RB0 (Vox aufwachen) enable. Dann kann es ja nur noch ein Aufwachbefehl sein.
	GOTO Ruf2
	BCF INTCON,1      ;RB0 FLAG zur�ck darf eigentlich garnicht vorkommen
	RETFIE

							;WACH		   WACH			   WACH
							  ;WACH		  WACH	WACH     WACH
							    ;WACH	WACH	  WACH WACH
							      ;WACH			    WACH			


        ;LAUTS�RKEBEDINGTE EINSTELLUNGEN 	-----XXXLAUTS�RKEBEDINGTE EINSTELLUNGEN 	-----XXXLAUTS�RKEBEDINGTE EINSTELLUNGEN 	-----XXX
 ;LAUTS�RKEBEDINGTE EINSTELLUNGEN 	-----XXXLAUTS�RKEBEDINGTE EINSTELLUNGEN 	-----XXXLAUTS�RKEBEDINGTE EINSTELLUNGEN 	-----XXX

 ; 1.Lautst�rkeErfassung mit Comparator
    
        ;grade aufgewacht
Ruf2	CLRF  PORTB
		CALL WInit		;durch das Schlafen wurden die Einstellungen f�r PWM zerst�rt.Also nochmal
		BCF STATUS,RP0     ;sicher ist sicher
		MOVF vVoreinstellVU,W			;erst mal Verst�rkungsfaktor auf gespeicherten Wert voreinstellen
		MOVWF vVUistStufe
		CALL VUAusgabe	
		CALL Schl200                     ;grade aufgewacht erst mal warten, bis sich Verst�rker eingeregelt hat.
		MOVLW StartBonus				;alle Register vor Unterlauf sch�tzen
		MOVWF    vAusschaltBonus 
		MOVWF   vUebersteuerung 
		MOVWF		vZaehl60
				MOVLW  D'1'     
				MOVWF  vAbsoZaehl
			BCF  vMyFlags,0              ;Nur bei Aufwachen clearen und bei Ausschalten setten
				BSF   PORTA,3      ;Die Sendestufe wird bei der Gelegenheit eingeschaltet YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY


	
				CLRW				; der Programmabschnitt sorgt daf�r, dass ca 4 sec nach Anspringen der Erste Meldeton gesendet wird,falls gew�hlt.
				ADDLW MeldeIntervall  ;(Null-Pr�fung)
				BTFSC STATUS,Z
				GOTO  Messen
				MOVLW  ErstMeldung    
				MOVWF  vMeldeIntervall

				


Messen	BCF STATUS,RP0         
	MOVLW B'00000101'
	 MOVWF  CMCON
	BSF STATUS,RP0
	BCF PIE1,6
	BSF TRISA,1		;ComparatorTrisa
	BSF TRISA,2
			BSF TRISA,4    ;Trisa f�r Lichtmessung einstellen

	MOVLW VRLevel1   ;Level 1/24           ;Level m��en ev praxisangeglichen werden OK. VDD= 4,8V
	MOVWF  VRCON			;ReferenzSpannung wird auf 1/24 VDD eingestellt, anschlie�end mit Spannung an Pin 18 verglichen
	BCF STATUS,RP0			;  War VPin18 niedriger  wird das Register f�r die Pegelstufe 1 incrementiert und die Messung damit erfolgreich abgebrochen
    CALL  zehnMue			; War V Pin 18 h�her erfolgt kein Eintrag und es geht zum n�chsten Test mit h�herer VRef
	BTFSS CMCON,7
	GOTO  Messen2
    INCF vPegel1,F  ;Eintrag in Pegelstufe 1   unter1/24 xVdd  
	Goto  MessenFertig

Messen2	BSF STATUS,RP0
	MOVLW  VRLevel2    ;Level 2/24
	MOVWF  VRCON
	BCF STATUS,RP0
    CALL  zehnMue
	BTFSS CMCON,7
	GOTO  Messen3
    INCF vPegel2,F  ;Eintrag in Pegelstufe 2    1bis2  /24 xVdd
	Goto  MessenFertig

Messen3	BSF STATUS,RP0
	MOVLW  VRLevel3     ;Level 4/24
	MOVWF  VRCON
	BCF STATUS,RP0
    CALL  zehnMue
	BTFSS CMCON,7
	GOTO  Messen4
    INCF vPegel3,F  ;Eintrag in Pegelstufe 3  2bis4  /24 xVdd
	Goto  MessenFertig

Messen4	BSF STATUS,RP0
	MOVLW  VRLevel4     ;Level 8/24
	MOVWF  VRCON
	BCF STATUS,RP0
    CALL  zehnMue
	BTFSS CMCON,7
	GOTO  Messen5
    INCF vPegel4,F  ;Eintrag in Pegelstufe 4 = 4bis10  /24  xVdd
	Goto  MessenFertig

Messen5	incf vPegel5,F     ;Eintrag in Pegelstufe 5 f�r �ber 8/24  xVdd  reduziert auf 8

        MOVLW   D'1'       ;Instant - Reaktion auf �bersteuerungen  setzt ein ab zwei �'s reduziertauf1
		SUBWF   vPegel5,W
		BTFSS   STATUS,C
		GOTO    MessenFertig  
		MOVLW   D'60'    		;wenns schon auf h�chster Stufe ist, soll Dauer�bersteuerung nicht das ganze sek�ndliche Programm zum Erliegen bringen.
		SUBWF    vVUistBank1,W
		BTFSC    STATUS,Z
		GOTO    MessenFertig
		DECF    vVUistStufe,F    ;sofortige VU-Stellung (???) -eigentlich bew�hrt-.
		CLRF v5Runden				;wenn ich die Stufe runtersetze messe ich sinvollerweise anschlie�end neu
		 		MOVLW UestVerlaengerung   ;Da bei �st Bonus' ausfallen,kann hier ausgeglichen werden.
				ADDWF  vAusschaltBonus,F
		BTFSC   vMyFlags,6			;Es wird bis zur n�chsten Klassensumme gespeichert ob ein oder mehr �bersteuerungen vorkamen.
		BSF     vMyFlags,7
        BSF     vMyFlags,6		
		CALL    UeAuswert
		GOTO    VUStell3a
		

	;Zahlen in den Pegelregistern vPegel 1-5 liegen zwischen 0 und 5 je nachdem wie oft der betreffende Pegel bei 5 Messungen vorkam.Zusammen also immer 5.
	; Die Pegel entstammen der Gleichrichtung  der Signalspannung am Ausgang der Regelstufe.

     
			
MessenFertig	CALL Schl200	;diesmal war's offensichtlich keine �bersteuerung oder wir sind schon auf h�chster Stufe.	; 1/5 sec Pause
			incf v5Runden,F		; Jede 5. Messrunde erfassen um einmal pro sec auszuwerten
			MOVLW D'5'
			SUBWF v5Runden,W
			BTFSS STATUS,C
			GOTO Messen
			CLRF v5Runden
			GOTO Auswertung
			

; Auswertung der Peg		el 	  nur alle		     5 Mess       ungen also ca 1 mal/sec        --------------------XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX------------------------------------------------
; Auswer		tung		der Pegel    n		   ur alle 5 Me     ssungen also ca 1 mal/sec 
; Auswer		tung 		der 				Pegel         nur        alle 5 Messungen also ca 1 mal/sec 
; Auswert	ung der 		Peg					l nur         alle      5 Messungen also ca 1 mal/sec 
; Auswertung der 			Pegel    nur a		lle 5                    essungen also ca 1 mal/sec 
; Auswer					tung der Pegel       nur al    le 5 Mess    ungen also ca 1 mal/sec 
; Auswer					tung 				  der P    egel    nu    r alle 5 Messungen also ca 1 mal/sec 
; Auswer					tung 				  der Pe        gel    nur alle 5 Messungen also ca 1 mal/sec 
; Auswer					tung der Pegel          nur al   le 5 M    essungen also ca 1 mal/sec 
; Auswer					tung der Pegel             nur alle 5      Messungen also ca 1 mal/sec 

 ;Ermittlung der KLASSENZAHL:

Auswertung  CLRF  vKlassenZahl     ;ermitteln wieviele verschiedene Lautst�rkeklassen in der letzten Sekunde vorgekommen sind. steht dann in vKlassenZahl.
	  	MOVLW D'1'
		SUBWF  vPegel1,W
		BTFSC  STATUS,C
		INCF vKlassenZahl,F

	  	MOVLW D'1'
		SUBWF  vPegel2,W
		BTFSC  STATUS,C
		INCF vKlassenZahl,F

	  	MOVLW D'1'
		SUBWF  vPegel3,W
		BTFSC  STATUS,C
		INCF vKlassenZahl,F

	  	MOVLW D'1'
		SUBWF  vPegel4,W
		BTFSC  STATUS,C
		INCF vKlassenZahl,F
	
	  	MOVLW D'1'
		SUBWF  vPegel5,W
		BTFSC  STATUS,C
		INCF vKlassenZahl,F
		
			;Klassenzahlen liegen zwischen 1 und 5  voll ausgesteuerte Sprache liegt bei ca. 2-4  (ohne Sprechpausen)

  ;Ermittlung der KLASSENSUMME:

		MOVLW  D'60'
		MOVWF  vKlassenSumme       ; Vor-Ladung mit 60 zur Vermeidung von Carry-Problemen CLEART automatisch die Klassensumme 

		MOVF vPegel1,W
		ADDWF  vKlassenSumme,F     
		
		MOVF vPegel2,W
		ADDWF vKlassenSumme,F
		ADDWF vKlassenSumme,F

		MOVF vPegel3,W
		ADDWF vKlassenSumme,F	
		ADDWF vKlassenSumme,F
		ADDWF vKlassenSumme,F

		MOVF vPegel4,W
		ADDWF vKlassenSumme,F	
		ADDWF vKlassenSumme,F
		ADDWF vKlassenSumme,F
		ADDWF vKlassenSumme,F

		MOVF vPegel5,W          
		ADDWF vKlassenSumme,F	
		ADDWF vKlassenSumme,F
		ADDWF vKlassenSumme,F
		ADDWF vKlassenSumme,F


		BTFSS vMyFlags,6   			;seit Pegel 5 eine Instant-Reaktion hervorruft (�nderung 4-9/5)
		GOTO  UeMuClr       			;kann er ja in der Klassensumme nicht mehr vorkommen.! ge�ndert:Kann er wieder, aber nur bei h�chster VU-Stufe.
		INCF  vKlassenSumme,F			;Zum Ausgleich k�nnen hier beim n�chsten regul�ren Durchgang incs vergeben werden, um nach �bersteuerungen VU erstmal bischen unten zu halten.
		BTFSS vMyFlags,7				; seit in allen Versionen der 5-Messrundenz�hler (oben)nach �st gecleart wird aber ev. gar nicht mehr n�tig.
		GOTO  UeMuClr
		INCF  vKlassenSumme,F		;  (sozusagen das D in der PID Regelung durch Uest)
UeMuClr	BCF   vMyFlags,7
		BCF   vMyFlags,6
		

		;KLASSENSUMMen liegen zwischen 65 und 80  (vorbehaltlich inc Vergabe f�r �st) f�r eine gute Vollaussteuerung mit Sprache u.�. rechne ich Summe = 72 als Idealwert.(ohne Sprechpausen)
        ; Die Klassensumme ist sozusagen der �ber eine Sekunde integrierte Lautst�rke-Wert falls nicht gleich wegen �berst abgebrochen wurde.
  ; 3. ---VU- Regelung		---VU- Regelung---VU- Regelung---VU- Regelung------------XXXXXXXXXXXXXXXX----------------------------------------
  ; 3. ---VU- Regelung		---VU- Regelung---VU- Regelung---VU- Regelung------------XXXXXXXXXXXXXXXX----------------------------------------
  ; 3. ---VU- Regelung		---VU- Regelung---VU- Regelung---VU- Regelung------------XXXXXXXXXXXXXXXX----------------------------------------
  ; 3. ---VU- Regelung		---VU- Regelung---VU- Regelung---VU- Regelung------------XXXXXXXXXXXXXXXX----------------------------------------
  ; 3. ---VU- Regelung		---VU- Regelung---VU- Regelung---VU- Regelung------------XXXXXXXXXXXXXXXX----------------------------------------
	

		; Ermittlung der Regelzahlen aus der �bersteuerungsh�ufigkeit
				
				;regelm��iges Decrementieren des �bersteuerungsspeichers  bei Signal:
				
Uedecr			MOVLW  D'79'
				SUBWF  vKlassenSumme,W
				BTFSC  STATUS,C
				Goto UeAuswert1
				MOVF    vRegelZahlSum,W
				SUBWF  vKlassenSumme,W
				BTFSS  STATUS,C
				Goto UeAuswert1
				DECFSZ vUeErlaubt,F   ;hier kommt man also hin bei Klassensummen zwischen vRegelzahlSum und 78  d.h. Signal
				GOTO  UeAuswert1
				DECF  vUebersteuerung,F    ; In diesem Register kummulieren sich die vorgekommenen �bersteuerungen - 
												;oder auch nicht. F�r die Langzeitregelung
				MOVLW SekProUe      ;Anzahl der Sekunden in denen eine Ueberst bei vorhandenem Signal erlaubt wird !!!!!!!!
				MOVWF vUeErlaubt

				;Auswerten des �bersteuerugsspeichers - Stellen der Regelzahlen

UeAuswert1				CALL  UeAuswert




		;Relevanz�berpr�fung der Messwerte anhand KlassenSumme

Relevanz	    MOVLW  D'67'				;MyFlags,4 R�cksetzroutine 7 mal Klassensumme unter 67?
				SUBWF	vKlassenSumme,W		;ohne MyFlags,4 beginnt eine unbedingte Verst�rkungsstufensuche also Vu immer weiter erh�hen.	
				BTFSC   STATUS,C
				GOTO   Kl1u2
				DECFSZ  vZ�hler7,F
				GOTO   Kl1u2
				BCF    vMyFlags,4

Kl1u2			MOVF  vPegel5,W		;MyFlags,4 R�cksetzroutine:  alternativ 11 mal	keine Pegel gr��er als 2?
				BTFSS  STATUS,Z		;ohne MyFlags,4 beginnt eine unbedingte Verst�rkungsstufensuche also Vu immer weiter erh�hen.
				GOTO  Relevanz1

				MOVF  vPegel4,W
				BTFSS  STATUS,Z
				GOTO  Relevanz1

				MOVF  vPegel3,W
				BTFSS  STATUS,Z
				GOTO  Relevanz1	
			
				DECFSZ  vZ�hler11,F
				GOTO   Relevanz1
				BCF    vMyFlags,4
				DECF  vUebersteuerung,F   ; geh�rt eigentlich ordentlicherweise nicht hierher, aber ich wollte f�r diesen Kompensationsmechanismus nicht schon wieder 
											;einen extra Z�hler schreiben.Es k�nnte ohne den Befehl eine Art logischer latch down der VU auftreten.!!!!!!!!!

		;Relevanz�berpr�fung der Messwerte anhand KlassenZahl:

Relevanz1		MOVLW D'2'						; Wenn Sprache ist und keine Sprechpause, dann wohl K-Zahl>=2 und  K-Summe >=70 dann wird MyFlags,4 gesetzt
				SUBWF  vKlassenZahl,W			;und die Sprechpausenz�hler 7 und 11 zur�ckgesetzt. Wenn die Z�hler von zu vielen Pausen auf Null 
				BTFSS  STATUS,C					;runter sind wird MyFlags,4 gecleart  und nicht nur "Sprach"signale  ausgewertet, sondern auch die niedrigen 
				GOTO   Relevanz2				; Level und die Klassenzahl 1 mit der Regelzahl verglichen. Es wird dann angenommen, dass die Lautst�rke geringer geworden ist.
												;und die VU Stufe ohne Erh�hung keine auswertbaren Signale mehr gibt. (Mit vielleicht auch nicht.)

				MOVF    vRegelZahlSum,W ;also 70+/-2  nachgeregelt nach �bersteuerungsh�ufigkeit
				SUBWF	vKlassenSumme,W
				BTFSS   STATUS,C
				GOTO    Relevanz2

		        BSF   vMyFlags,4      ;Das "sprach"-Flag MyFlags,4 wird gesetzt

				INCF 	vAusschaltBonus,F
Relevanz3		MOVLW  SprechPaZ11			; Die Sprachpausen-Abwarte-Z�hler werden wieder auf Startwerte gesetzt 
				MOVWF  vZ�hler11

				MOVLW  SprechPaZ7   		;dto.
				MOVWF  vZ�hler7
				GOTO Vergleicher

Relevanz2		BTFSC  vMyFlags,4		;wer hir ankommt wird nur ausgewertet, wenn in letzter Zeit keine "Sprache" erkannt wurde.
				GOTO   VUFertig

		;Regelung   (unter Verwendung der oben ermittelten Relevanz und Regelzahlen):

Vergleicher		INCF    vRegelZahl,W				;in einer Neutralzone zwischen Regelzahl +1 und Regelzahl -1 passiert keine Regel�nderung
				SUBWF   vKlassenSumme,W						
				BTFSC   STATUS,Z
				GOTO  VUFertig	
				DECF    vRegelZahl,W
				SUBWF   vKlassenSumme,W						
				BTFSC   STATUS,Z
				GOTO  VUFertig			
				MOVF    vRegelZahl,W		;also 73+/-2 Vergleich von Regelzahl und Klassensumme um zu ermitteln ob VU gesenkt erh�ht oder garnichts wird.
				SUBWF   vKlassenSumme,W						;Regelzahl nachgeregelt nach �bersteuerungsh�ufigkeit
				BTFSC   STATUS,Z
				GOTO  VUFertig
				BTFSC   STATUS,C
				GOTO    runter
rauf			INCF    vVUistStufe,F       ;HIER einzige Stell-Stelle!   Es gibt jetzt noch die Instant-Regelung oben Messen5
				GOTO    VUStell3a
runter			DECF    vVUistStufe,F		;HIER einzige Stell-Stelle!



		; Bei VUStell3a kommen die Sofort Calls von �bersteuerungen an. Bei Dauer�bersteuerung werden die folgenden Befehle also in sehr schneller Folge bearbeitet.

VUStell3a		MOVLW  VUMinBegr				;Unterlaufschutz  VUist-Stufe   Vu ist-Stufe geht von inclusive 60 bis inclusive 66 !!!!!!!!
				SUBWF vVUistStufe,W             ;f�r 7 VU-Stufen 0bis 6 entspr 6 Widerst�nden an 6 Ports und einmal kein Port
				BTFSC STATUS,C						;niedrigste vVUistStufe = niedrigste VU
				Goto  VuStell4
				MOVLW VUMinBegr				
				MOVWF  vVUistStufe
				GOTO  VUFertig

VuStell4		MOVLW  VUMaxBegr				;�berlaufschutz  VUist-Stufe   VuistStufe geht von inclusive 60 bis inclusive 66
				ADDLW  D'1'
				SUBWF vVUistStufe,W              ;f�r 7 VU-Stufen 0bis 6 entspr 6 Widerst�nden an 6 Ports und einmal kein Port
				BTFSS STATUS,C
				Goto  VuStell5
				MOVLW VUMaxBegr
				MOVWF  vVUistStufe
				GOTO  VUFertig

VuStell5			CALL VUAusgabe     			;call zum Ports-Stellen



			BSF   vMyFlags,2   ;Das Vu-Stufen-�nderungsFlag
			GOTO Voreinstell			

VUFertig    BCF  vMyFlags,2


	;Abschlie�endes:
  ;-Voreinstellung VU nach Aufwachen  entsprechend den zuletzt erfolgreichen Werten.
	  

Voreinstell		BTFSC vMyFlags,2
				GOTO  ClearPeg

				BTFSS vMyFlags,4
				GOTO  ClearPeg

				BTFSS vMyFlags,5
				GOTO  ClearPeg

					; Wenn ich hier angekommen bin sind Klasse5 unbesetzt, und 3oder4 verschiedene besetzt es wurde Sprache erkannt und die Vu nicht gerade gewechselt
					; das sollte Grund sein, die VU- Einstellung als Starteinstellung zu speichern:
					MOVF vVUistStufe,W
					MOVWF vVoreinstellVU



;jetzt kommt erstmal alles restliche was einmal pro (nomineller) Sekunde stattfinden soll.
;-----------------Pegel clearen ------------
ClearPeg				CLRF vPegel1      ;die Pegelspeicher f�r die n�chsten 5 Erfassungen clearen alle 5x200ms
				CLRF vPegel2
				CLRF vPegel3
				CLRF vPegel4
				CLRF vPegel5

; erst mal verhindern, dass bei Dauer�bersteuerung der Rest der Programmschleife dank Instantreaktion im Dzug Tempo abl�uft, statt im Sekundenrhythmus.

				BTFSC  vMyFlags,6
				GOTO   Messen

 ;LichtMeldung---------------------------------------------

			CALL  	Meldeton  ;  Einmal pro Sekunde Das MeldetonModul rufen, um den Meldeintervallz�hler weiterzusetzen
								;	oder ggf einen Meldeton zu senden.
 ;Betriebsstunden-Limitierung ---------------------------------------------------------

			CALL  Limit

   ; Ausschaltung/Entscheidung: XXXXXXXXXXXXXX-----------Ausschaltung: XXXXXXXXXXXXXX-----------Ausschaltung: XXXXXXXXXXXXXX-----------
   ; Ausschaltung/Entscheidung: XXXXXXXXXXXXXX-----------Ausschaltung: XXXXXXXXXXXXXX-----------Ausschaltung: XXXXXXXXXXXXXX-----------
   ; Ausschaltung/Entscheidung: XXXXXXXXXXXXXX-----------Ausschaltung: XXXXXXXXXXXXXX-----------Ausschaltung: XXXXXXXXXXXXXX-----------

Licht1				DECFSZ  vBeschleuniger,F
					GOTO  AbsoLaut
					MOVLW  LichtBewNenn             ;Hier lasssen sich verschiedene Verh�ltnisse einstellen um das gew�nschte timing einzustellen Standard=3!!!!!!!!!!!!!!!!!
					MOVWF  vBeschleuniger			; also alle wieviel Sekunden die Licht und Kompensationsbonusvergabe durchlaufen wird und wieviele dann jeweils vergeben.
Licht2				BTFSC PORTA,4					; LichtBonus    Pin3 /RA4 =Low  d.h. es ist hell am Lichtsensor
					GOTO  Licht3
					MOVLW  LichtanBonus        ;Was nur passiert, wenn es hell ist:
					ADDWF  vAusschaltBonus,F
					MOVLW  LichtanMalus
					SUBWF  vAusschaltBonus,F
				          
Licht3				MOVLW  LichtKompensBonus  ;Was jedesmal passiert, wenn die Helligkeit ausgewertet wird:
					ADDWF  vAusschaltBonus,F
					MOVLW  LichtKompensMalus  ;Standard=2 f�r Zimmer u.�. schaltet es sonst einfach zu bummelig ab. Schon ohne Licht.Also jede 3. Sekunde noch zwei runter.
					SUBWF  vAusschaltBonus,F

					DECFSZ vFrustBer�cksi,F
					GOTO  AbsoLaut
					MOVLW  FrustBer�ckNenn
					MOVWF  vFrustBer�cksi
					CALL  FrustBonus	; hier flie�t die Frustauswertung in die Ausschaltung ein  (sehr langfristig)bis zu zwei extra decf s werden vergeben.


AbsoLaut       	DECFSZ  vAbsoZaehl,F   ; in diesem Absatz kann man einstellen, 
			 	GOTO  Klassen11          ;wieviel die absolute Lautst�rke zur Erhaltung des Einschaltzustandes beitragen soll:
				MOVLW  AbsolautNenn     ;wie oft
				MOVWF  vAbsoZaehl
				MovlW  AbsolautLo     ;f�r welche Pegel
				Subwf  vKlassenSumme,W
				BTFSS  STATUS,C
				Goto   Klassen11

				MOVLW  AbsoLoBonus
				ADDWF  vAusschaltBonus,F   ;wieviele Bonusse vergeben werden.

				MovlW  AbsolautHi  ;f�r welche Pegel
				Subwf  vKlassenSumme,W
				BTFSS  STATUS,C
				Goto   Klassen11
				MOVLW  AbsoHiBonus
				ADDWF  vAusschaltBonus,F   ;wieviele Bonusse vergeben werden.				


Klassen11	BCF   vMyFlags,5
	DecFSZ vKlassenZahl,F          ;Auswertung der Klassenzahl also der Lautst�rkevarianz innerhalb einer Sekunde
	GOTO  Klassen2
		MOVLW EinklassenMalus
		SUBWF vAusschaltBonus,F        ;wenn nur eine Lautst�rkeklasse war, dann war das typisch f�r St�rger�usche wie Presslufth�mmer etc.Oder ganz leise. 


Klassen7	BSF vMyFlags,1
	Goto KlassenFertig

Klassen2 DECFSZ vKlassenZahl,F     ; zwei Klassen vertreten: Unentschieden keine Aktion
		GOTO Klassen3
		BSF vMyFlags,1
		GOTO  KlassenFertig
		
Klassen3    BCF vMyFlags,1
			BSF  vMyFlags,5
			DECFSZ vKlassenZahl,F
			GOTO  Klassen4
			MOVLW DreiklassenBonus   ;Drei Lautst�rkeklassen vertreten: K�nnte Sprache sein.  Bonus
			ADDWF vAusschaltBonus,F

			GOTO  KlassenFertig

Klassen4   MOVLW VierklassenBonus
			ADDWF   vAusschaltBonus,F   ; vier  Lautst�rkeklassen:  Dreifach bonusse (Standard)


KlassenFertig  	MOVLW OfenausZahl                 ;Entscheidung ob ausgeschaltet wird f�llt hier.
				SUBWF   vAusschaltBonus,W
				BTFSS  STATUS,C
				GOTO  Abschluss
	
				MOVLW OfenheissZahl					;�berlaufschutz Ausschaltbonus  Unterlauf er�brigt sich da dann Ausschaltung
				ADDLW   D'1'
				SUBWF   vAusschaltBonus,W
				BTFSS	STATUS,C
				GOTO neueRunde
				MOVLW OfenheissZahl  
				MOVWF vAusschaltBonus
neueRunde		CALL EreignisZaehler
				GOTO Messen
			

Abschluss   BSF  vMyFlags,0
				CALL EreignisZaehler
				RETFIE				;Geht an die Stelle nach dem Interrupt-Aufwachen also zum Befehl nach sleep (und von da direkt wieder schlafen.)

                              ;!    !  ! Das Ausschalten !

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
			;Frust-Steuerung: Wenn die Maschine selbst ein Frustrationsverhalten zeigt, werden dem Zuh�rer Frustrationen erspart:
EreignisZaehler  	BTFSS   vMyFlags,5
					GOTO   Zaehler60
					INCF   vEreignis,F     ;Wenn 3 oder 4 Lautst�rkeklassen im letzten Durchgang waren
Zaehler60				DECFSZ  vZaehl60,F
						Goto AusschaltFrage
						CALL   EreignisAuswert      ;alle 60 Sekunden, oder...      
						return
AusschaltFrage		 	BTFSS   vMyFlags,0			;... wenn ausgeschaltet werden soll.
						return
						CALL   EreignisAuswert							
						return       


 ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
EreignisAuswert  	MOVLW   D'1'								;hier gehen Calls ein !
						SUBWF		 vEreignis,W				 ;Es hat sich erwiesen, dass solche 3/4 Klassen - Ereignisse seltener sind, als gedacht.
						BTFSC  STATUS,C							; deshalb Grenzen reduziert.
						Goto    Ereignis4
						decf    vFrust,F						;Je nachdem wie oft f�r diese Einschaltung bzw. in den letzten 60Sekunden die 
						decf    vFrust,F						; dreiodervierKlassen-Ereignisse waren wird vFrust runter oder rauf gez�hlt.
						GOTO    EreignisClr
Ereignis4			MOVLW   D'3'
						SUBWF		 vEreignis,W				 
						BTFSC  STATUS,C
						Goto    Ereignis10
						decf    vFrust,F
						GOTO    EreignisClr
Ereignis10			MOVLW   D'7'
						SUBWF		 vEreignis,W				 
						BTFSS  STATUS,C
						GOTO    EreignisClr
						incf    vFrust,F						
					MOVLW   D'14'
						SUBWF		 vEreignis,W				 
						BTFSS  STATUS,C
						GOTO    EreignisClr
						incf    vFrust,F

EreignisClr				CLRF  vEreignis
						MOVLW  D'60'
						MOVWF		vZaehl60


FrustProbe				MOVLW   D'40'           ; und wenn vFrust dann 40 unter oder 80�berschreitet, dann hat das Folgen.
						SUBWF		 vFrust,W				 ;(Die VoxEmpfindlichkeit und danach auch Ausschaltgeduld wird verstellt.)
						BTFSC  STATUS,C
						Goto    Frust80
						DECF		vVoxIstStufe,F
						MOVLW  D'60'
						MOVWF		vFrust
						GOTO		VoxStell
Frust80				MOVLW   D'80'
						SUBWF		 vFrust,W				 
						BTFSS  STATUS,C
						Goto    VoxStell
						INCF		vVoxIstStufe,F
						MOVLW  D'60'
						MOVWF		vFrust
						

			org D'420'
VoxStell	BSF STATUS,RP0                 ; Es gibt drei Voxstufen Entspr 59, 60 ,61  hier werden die Ausg�nge entsprechend eingestellt und 
			MOVLW D'1'						;  das zugeh�rige Register begrenzt:    61= empfindlich 59=une.
			MOVWF PCLATH
			MOVLW D'60'
			SUBWF 	vVoxIstStufe,W
			BTFSC   STATUS,C
			GOTO   Vox60
			MOVLW D'0'
			CALL  VoxStu  ;dieser Programmteil stellt dann die �berschneidung mit den Voreinstellungen f�r die Abh�rumgebung her.und stellt die Ausg�nge ein.

			MOVLW D'59'
			MOVWF vVoxIstStufe
			GOTO	VoxStellEnde
Vox60		MOVLW D'60'
			SUBWF 	vVoxIstStufe,W
			BTFSS   STATUS,Z
			GOTO  Vox61
			MOVLW D'1'
			CALL  VoxStu  ;dieser Programmteil stellt dann die �berschneidung mit den Voreinstellungen f�r die Abh�rumgebung her.und stellt die Ausg�nge ein.
			GOTO	VoxStellEnde
Vox61		MOVLW D'2'          ;hier angekommen, dh gr��er 60
			CALL  VoxStu ;dieser Programmteil stellt dann die �berschneidung mit den Voreinstellungen f�r die Abh�rumgebung her.und stellt die Ausg�nge ein.
		
			MOVLW D'61'
			MOVWF vVoxIstStufe

VoxStellEnde		BCF STATUS,RP0
					
  			 return       

									;ENDE DER HAUPTSCHLEIFE!
									;ENDE DER HAUPTSCHLEIFE!
									;ENDE DER HAUPTSCHLEIFE!


  ;Hier wird die Vox variabel eingestellt. Je nach dem oben im EQU-Teil angegebenen Stufe 1bis 5 werden die empfindlichsten oder unempfindlichsten Vox-Stufen deaktiviert.
	      ;damit das nicht grade auf einer Memory-Bereichsgrenze liegt. Genauer Wert m��te bestimmt werden wenn Memory knapp w�re.
						;denn nat�rlich ist hier wesentlich weniger als der 768 ste Befehl.(ca500?)Aber garantiert nicht mehr.
						;Ziemlich viel Aufwand, nur um die Einstellung in den Kopf-Teil zu verlagern.
VoxStu  ADDWF PCL,F	
		GOTO VoxStulau    ;Die Vox will sich auf unempfindlich schalten,weil es laut ist. je nach voxoffset wird ihr das auch erlaubt.
		GOTO VoxStuMitt   ;die Vox will mittel...s.o.
		GOTO VoxStuleis		;s.o.

VoxStulau   MOVLW Voxoffset
			ADDWF PCL,F
		GOTO  Voxunempf
		GOTO  Voxunempf
		GOTO  Voxunempf
		GOTO  Voxmittel
		GOTO  Voxempfind

VoxStuMitt   MOVLW Voxoffset
			ADDWF PCL,F
		GOTO  Voxunempf
		GOTO  Voxmittel
		GOTO  Voxmittel
		GOTO  Voxmittel
		GOTO  Voxempfind

VoxStuleis   MOVLW Voxoffset
			ADDWF PCL,F
		GOTO  Voxunempf
		GOTO  Voxmittel
		GOTO  Voxempfind
		GOTO  Voxempfind
		GOTO  Voxempfind
			

Voxunempf			BSF TRISA,6
					BSF TRISA,7
				return

Voxmittel  			BSF TRISA,6
					BCF TRISA,7
				return

Voxempfind  		BCF TRISA,6
					BSF TRISA,7
				return












LilaLaune     EQU    D'100'     



;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----

;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----

;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----

;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
;SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----SPANNGSWANDLER----
  ;SPANNGSWANDLER Einschalten -----------------XXXXXXXXXXX --UND ANDERE VOREINSTELLUNGEN----- ;SPANNGSWANDLER Einschalten -----------------XXXXXXXXXXX --UND ANDERE VOREINSTELLUNGEN-----
          ;UND ANDERE VOREINSTELLUNGEN----- ;SPANNGSWANDLER Einschalten ----------
WInit NOP
TmrInit Movlw B'00100000'        ;Timer 0 in Gang setzen f�r regelm��ige Nachregelung der PWM (im 100 Hertz Takt oder so)
		MOVWF INTCON

   BSF STATUS,RP0
	MOVLW B'10001010'         ;Timer 0 prescaler, keine Pull up's, neg Flanke f�r RB0-Interrupt 
								; Bit 3 gesetted = Kein Prescaler =8xschneller als urspr�ngl  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	MOVWF OPTION_REG			;mit diesen Einstellungen blo� keinen Mist machen, weil der Schalttransistor sonst ev Kurzschlu� macht 
								;und Rauch und kaputt. Wahrsch Spule. dann keine 10 V mehr f�r NF und Sender !!!!!!!!!!!!!!!!!!!!!!!!!!		
	BCF STATUS,RP0

		BCF PORTA,6  ;Vox-Vu RegelPins sicherstellen, dass beide gleiches Potential vermeidet Strom
		BCF PORTA,7


PWMInit NOP
	BSF STATUS,RP0
	MOVLW PWMPeriode               
	MOVWF PR2
	BCF TRISB,3

	BCF STATUS,RP0
   	MOVLW B'00001100'
	MOVWF CCP1CON
	MOVLW B'00000100'
	MOVWF CCPR1L
	BSF T2CON,2


RegelInit	MOVLW B'00000111'      ;Blo� keinen Mist machen! mu� immer ein Drittel gr��er als CCPR1L.Manual nachlesen! !!!!!!!!!!!!!!!!!!!!!!!!!
	MOVWF CMCON
	BSF STATUS,RP0
	BCF TRISA,3     ;(Bei Gelegenheit auch gleich den Ausgang f�r die Sendestufen-Einschaltung konfigurieren)
	BSF TRISA,0		;PWM Regeleingang
	BCF STATUS,RP0

	RETFIE


      
 ; INTERRUPT ROUTINE F�R SPANNUNGSWANDLER REGELUNG  XXXXX------XXXXX------XXXXX------XXXXX------
 ;-------PWM-RegelungXXXXX---------PWM-RegelungXXXXX---------PWM-RegelungXXXXX---------PWM-RegelungXXXXX---------PWM-RegelungXXXXX------


PWMStart    movwf   WTemp                 ; Status und Arbeitsspeicher sichern
    		swapf   STATUS,W 
    		bcf     STATUS, RP0       ; status_temp in Bank 0 
    		movwf   StatusTemp 



	BCF PORTB,3         ;gegen inout-Falle durch Tt

		
Regel MOVF CCPR1L,W
	MOVWF vPWMCon
	RLF vPWMCon,F
	RLF vPWMCon,F

kopieren6	BTFSC CCP1CON,4   
		GOTO kopieren7
		BCF vPWMCon,0      
		GOTO kopieren8
kopieren7 BSF vPWMCon,0

kopieren8	BTFSC CCP1CON,5   
		GOTO kopieren9
		BCF vPWMCon,1      
		GOTO kopieren10
kopieren9 BSF vPWMCon,1


kopieren10	 BTFSC PORTA,0  ;Spanngswandler auf �berspannung pr�fen
		GOTO RegelDown

RegelUp	INCF vPWMCon,F   ;Power hochschalten
	MOVF vPWMCon,W
	SUBLW  B'00001000'         ;Hier PWM max Impulsdauer einstellen ACHTUNG: Max 10000. !!!!!!!!!!!!!!!!!!!!!!!!!!!
	BTFSC STATUS,C				;10000 entspricht eigentlich 100,00 in CCPR1L    Blo� keinen Mist machen hier! Hardware in Gefahr !!!!!!!!!!
	GOTO kopieren1
	DECF vPWMCon,F
	GOTO kopieren1

  	  ;Power runterschalten
RegelDown	MOVLW 0x01
	SUBWF vPWMCon,F
	BTFSC STATUS,C
	GOTO kopieren1
	INCF vPWMCon,F
	GOTO kopieren1


  
kopieren1	BTFSC vPWMCon,0   ;Bits in die PWM-Steuer-Register kopieren
		GOTO kopieren2
		BCF CCP1CON,4      ;Least sign. Bit von CCPR1L
		GOTO kopieren3
kopieren2 BSF CCP1CON,4

kopieren3	BTFSC vPWMCon,1   ;2.Bit in die PWM-Steuer-Register kopieren
		GOTO kopieren4
		BCF CCP1CON,5      ;Least sign. Bit von CCPR1L
		GOTO kopieren5
kopieren4 BSF CCP1CON,5

kopieren5 MOVF vPWMCon,W
		MOVWF vCopyRota
		RRF vCopyRota,F
		RRF vCopyRota,F
		BCF vCopyRota,7
		BCF vCopyRota,6
		MOVF vCopyRota,W
		MOVWF CCPR1L


 ;------------------------------------------------
	
	 BCF INTCON,2     ;Interrupt reaktivieren keine Eile, da doch grade erst gestartet.
    swapf   StatusTemp,W    ;Status und Arbeitsspeicher wiederherstellen
    movwf   STATUS 
    swapf   WTemp,F 
    swapf   WTemp,W 

    retfie 


;XXXXXX XXXXXX XXXXxxxx xxxxxxx XXXXXX XXXXX XXXxxxxxxxxxx xxxxxxxX  XXXXXXXX XXXXX
 ;--------ENDE PWM RegelungXXXXX--------ENDE PWM RegelungXXXXX;--------ENDE PWM RegelungXXXXX--------ENDE PWM RegelungXXXXX
 ;--ENDE PWM RegelungXXXXX--------ENDE PWM RegelungXXXXX;--------ENDE PWM RegelungXXXXX--------ENDE PWM RegelungXXXXX--------






     ;Zeitschleifen�������������Zeitschleifen�������������Zeitschleifen�������������Zeitschleifen�������������Zeitschleifen�������������
;Zeitschleifen�������������Zeitschleifen�������������Zeitschleifen�������������Zeitschleifen�������������Zeitschleifen�������������

;Schl20Reg  EQU   0xxxxx
Schl20     Movlw D'5'    ;20-Sekunden-Schleife
	Movwf Schl20Reg
Schl201	Call Schl1M
    DECFSZ Schl20Reg,F
  	Goto Schl201   
	return	


	


;Kor1MReg   	EQU     0xxxx		;plus Konstante-Register
;Inn1MReg   	EQU     0xxxx		;innere Schleifenzahl mal
;Auss1MReg	EQU     0xxxx		;aeussere Schleifenzahl-Reg
;SupAuss1M   EQU		0xxxx		;ganz �ussere SchlZahl-Register
Schl1M		MOVLW   0x7F		;Korrekturschleife laden
			MOVWF   Kor1MReg
Schl1MKorr	DECFSZ  Kor1MReg,1
			GOTO    Schl1MKorr	
			MOVLW   0x8C		;Superaeussere Schl laden
			MOVWF   SupAuss1M	
load1Mauss	MOVLW 	0x2B		;Schl auss laden
 			MOVWF 	Auss1MReg 
load1Minn	MOVLW	0x51		;Schl  inn laden
 			MOVWF 	Inn1MReg
Schl1Minn	DECFSZ	Inn1MReg,1
			GOTO    Schl1Minn
            NOP
			DECFSZ 	Auss1MReg,1
			GOTO    load1Minn
			DECFSZ  SupAuss1M,F
			GOTO    load1Mauss
			Return


zehnMue NOP
		NOP
		NOP
		NOP
		NOP
		NOP
	RETURN


Schl200    	CALL Schl100
			CALL Schl100
			RETURN


 ;Kor100Reg   EQU     0x1B		;plus Konstante
 ;Inn100Reg   EQU     0x1A		;innere Schleifenzahl mal
 ;Auss100Reg	EQU     0x19		;aeussere Schleifenzahl
Schl100		MOVLW   0x2F		;Korrekturschleife laden
			MOVWF   Kor100Reg
Schl100Korr	DECFSZ  Kor100Reg,1                              ;Korrektur/ Schleifenl�nge um Mess und Auswertezeit verk�rzen
			GOTO    Schl100Korr		
			MOVLW 	0xDE		;Schl auss laden
 			MOVWF 	Auss100Reg 
load100inn	MOVLW	0xDF		;Schl  inn laden
 			MOVWF 	Inn100Reg
Schl100inn	DECFSZ	Inn100Reg,1
			GOTO    Schl100inn
            CLRWDT
			DECFSZ 	Auss100Reg,1
			GOTO    load100inn
			Return

;-------------------------------------------------------------------
;----------------------------------------------------------------
				org D'790'
Startverz�gerung CALL Schl1M


							

				BSF STATUS,RP0
				BCF  PCON,3      ;auf stromsparende 37khz umschalten
				BCF STATUS,RP0

				MOVLW Einschleichzeit      ;Startverz�gerungszeit in Stunden/Minuten  0-254
				MOVWF vStart1
				INCF vStart1,F
StartVerz1		DECFSZ		vStart1,F
				GOTO StartVerz2
				GOTO WiederVier
StartVerz2      Call MiStuSchleife
				GOTO  StartVerz1
				

MiStuSchleife   MOVLW D'3'
				MOVWF PCLATH
				MOVLW 	Einschleichmassstab					
				ADDWF  PCL,F                 
				RETURN
				GOTO  Minutenschleife
				Goto  Stundenschleife
				RETURN				;nur zur Sicherheit, falls doch mal versucht wird, 3oder 4 einzutragen.Eigentlich kommt man hier nie vorbei.
				Return					; so merkt man's gleich.

				
Stundenschleife MOVLW D'5'         ; die beiden Stu/Mi Schleifen sind nicht ganz exact auf den richtigen Wert eingestellt, da die 
				MOVWF vXh3			;Quarzlosen internen Oszillatoren sowieso nur ungef�hr ein Prozent genau sind. 
				CLRF  vSupAuss		; Mithilfe einer Stoppuhr hab ich die 10 Minuten und 1Stunde auf etwa eine Sekunde genau bei Zimmertemperatur eingestellt
				CLRF  vAuss			; Man sollte aber lieber mit 15 Sek Abweichung pro Stunde rechnen 1Prozent w�re 36.
				CLRF  vInn			;Im Einschleichbetrieb verbraucht die Schaltung ca 250 bis 300 uA bei UB=3V - 3,6V  Dar�ber noch etwas mehr.Aber unter 1mA
Stuinn			MOVLW  D'40'		;Im Sleep Betrieb mit Vox wake - up nur etwa 110uA  (90uA bei 2,8V)
				MOVWF  vInn
Stuinn0		    DECFSZ vInn,F
				GOTO  Stuinn0
			DecFSZ vAuss,F
				GOTO  Stuinn
          DECFSZ vSupAuss,F
				GOTO  Stuinn
				DECFSZ vXh3,F
				GOTO  Stuinn

Stuinn3      	MOVLW D'102'
				MOVWF  vInn

Stuinn1			DECFSZ vInn,F
				GOTO  Stuinn1
		DecFSZ vAuss,F
				GOTO  Stuinn3
          DECFSZ vSupAuss,F
				GOTO  Stuinn3

				return


Minutenschleife  MOVLW D'1'
				MOVWF vXh3
				CLRF  vSupAuss
				CLRF  vAuss
				CLRF  vInn
Stuinn4			MOVLW  D'1'
				MOVWF  vInn
Stuinn5		    DECFSZ vInn,F
				GOTO  Stuinn5
				DecFSZ vAuss,F
				GOTO  Stuinn4
        		DECFSZ vSupAuss,F
				GOTO  Stuinn4
				DECFSZ vXh3,F
				GOTO  Stuinn4

				MOVLW D'81'
				MOVWF  vSupAuss
Stuinn8      	MOVLW D'7'
				MOVWF  vInn


Stuinn9			DECFSZ vInn,F
				GOTO  Stuinn9
				DecFSZ vAuss,F
				GOTO  Stuinn8
          		DECFSZ vSupAuss,F
				GOTO  Stuinn8

				return




WiederVier		BSF STATUS,RP0
				BSF  PCON,3      ;von 37kHz wieder auf die f�r das Hauptprogramm verwendeten 4MHZ zur�ckschalten.
				BCF STATUS,RP0
				RETURN                     ;Ende des Startverz�gerungsprogrammes---------

  ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

 ;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

Meldeton  	CLRW
			ADDLW     MeldeIntervall
			BTFSC    STATUS,Z
			RETURN

		 	DECFSZ vMeldeIntervall,F
			RETURN

			BCF  vMyFlagsB,1  ;MultibankAdresse! My-Flag's Register2
			BSF  STATUS,RP0
			BTFSC  TRISB,7
			BSF  vMyFlagsB,1   ;Das Flag, dass der Toneinspieleingang aus Gr�nden der Verst�rkungsregelung gesettet war, bzw. nicht.
			BCF  TRISB,7			;(f�r das Einspielen des Tons.)
			BCF  STATUS,RP0

			MOVLW   MeldeIntervall
			MOVWF	vMeldeIntervall
			BTFSC   PORTA,4				;LichtPort pr�fen
			CALL    EinTon      ;dunkel = zwei T�ne
			CALL    kEinTon       ;hell = ein Ton 
			CALL    EinTon

			BTFSS  vMyFlagsB,1  ;Gesicherten Zustand des TRISB Ausgangs wiederherstellen.
			RETURN
			BSF  STATUS,RP0
			BSF  TRISB,7			;(f�r das Einspielen des Tons.)
			BCF  STATUS,RP0
			CALL    kEinTon
			RETURN

			
EinTon		BCF  INTCON,7
			Movlw D'254'      ;ACHTUNG!!! Mu� unbedingt eine grade Zahl sein, damit der Sendepower Ausgang hinterher denselben Wert hat, wie zuvor.
			Movwf  vTonADauer		

EinTon2		MOVLW D'60'
			MOVWF  vTonAFreq   ;  Vonwegen A ! Bei dem Grad an �bersteuerung latcht sich der OP fest und kommt mit Ton A garnicht mit.
EinTon1			NOP


			DECFSZ	vTonAFreq,F
			GOTO	EinTon1
			MOVLW  B'10000000'  ;PortB,7 umschalten
			XORWF  PORTB,F
			DECFSZ  vTonADauer,F
			GOTO	EinTon2
			BSF  INTCON,7
			RETURN

kEinTon		Movlw D'176'
			Movwf  vTonADauer

kEinTon2		MOVLW D'188'
			MOVWF  vTonAFreq
kEinTon1			NOP
			DECFSZ	vTonAFreq,F
			GOTO	kEinTon1
			MOVLW  B'00000000'  ;PortB,7 --- nicht --- umschalten
			XORWF  PORTB,F
			DECFSZ  vTonADauer,F
			GOTO	kEinTon2
			RETURN
  ;LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
Limit   DECFSZ vLimitCounterA,F
		Return
		CALL  Pruefen
		DECFSZ vLimitCounterB,F
		Return
		MOVLW  D'7'       			;hier kommt man nur noch ungef�hr einmal pro Sendestunde hin. (+/- 30Prozent also sehr ungenau)
		MOVWF  vLimitCounterB
		CALL  EEPROMEintrag
		Return
				        
		 
Pruefen		CALL Lesen
			SUBLW LilaLaune
			BTFSC STATUS,C
			RETURN

Feierabend   BSF   STATUS,RP0      ;PWM aus
	BCF  VRCON,7      ;alle Stromverbraucher abschalten
	CLRF TRISB
	BSF  TRISB,0
	BCF STATUS,RP0

	MOVLW   B'00000111'
	MOVWF   CMCON
    BCF INTCON,5         ;timer0 disablen (PWM Stellzyklus-Timer)
	CLRF CCP1CON       ;PWM aus mit output low
	BCF T2CON,2
	BCF PORTA,3    ;Sendestufe ausschalten
	BCF PORTB,3			;da P6 jetzt normaler inout-Pin den lieber auch nochmal low, sonst ist Der PWM-SchaltFet im Kurzschluss
	BCF INTCON,4		;Disable VOX Interrupt
	BCF INTCON,7		; GIE
	
  				BSF STATUS,RP0
				BCF  PCON,3      ;auf stromsparende 37khz umschalten
				BCF STATUS,RP0	
Wait        CALL  Minutenschleife
			DECFSZ vFeierSignal,F  
			GOTO  Wait
			MOVLW D'15'
			MOVWF  vFeierSignal
				


				BSF STATUS,RP0
				BSF  PCON,3      ;von stromsparenden 37khz zur�ckschalten
				BCF STATUS,RP0	

		CALL  WInit
		CALL  Schl1M
	   BSF PORTA,3        ;Sendestufe einschalten
		CALL  Schl1M
	   BCF PORTA,3    ;Sendestufe ausschalten
		CALL Schl1M
	   BSF PORTA,3        ;Sendestufe einschalten
		CALL  Schl1M
	   BCF PORTA,3        ;Sendestufe ausschalten
	
		GOTO Feierabend
;-------------------------------------------------

Lesen		BSF STATUS,RP0  ;EEPROM lesen
			MOVLW eLoEEP
			MOVWF  EEADR
			BSF  EECON1,0
			MOVF EEDATA,W
			BCF STATUS,RP0
			RETURN
;-----------------------------------------------------------------


;-------------------------------------------------------------------------------------------------------------------------------
							  

		; BetriebszeitZ�hler              Incrementiert das EEprom Betriebszeitregister bei jedem Aufruf  also ca jede Stunde
		
		;BetriebszeitZ�hlerEEPROMS updaten
;vLoBysav    	EQU   0x22		;RAM Adr	BANK1	
;vUpBysav   	EQU   0x23 		;RAM Adr    BANK1
;eUpEEP		EQU	  0x03		;EEPROM Adr
;eLoEEP    	EQU   0x04		;EEPROM Adr

		;EEprom auslesen low Byte
  
EEPROMEintrag	BSF  STATUS,RP0
 				MOVLW  eUpEEP 			;EEprom auslesen Up Byte
		 		MOVWF  EEADR
				BSF    EECON1,RD
				MOVF   EEDATA,W
				MOVWF  vUpBysav     ;zu sp�terer Verwendung

            MOVLW  eLoEEP 		;Low Byte lesen	
		 	MOVWF  EEADR
			BSF    EECON1,RD
			MOVF   EEDATA,W
			MOVWF  vLoBysav
			MOVLW  D'1'
			ADDWF  vLoBysav,F
			BTFSC  STATUS,C
            CALL   upByte       ; Bedingter Aufruf des Upbyte-Updatings
									   ;und weiter...
		;geupdatetes LoByte ins EEPROM
			MOVLW	eLoEEP			;Adresse und Daten laden low Byte
			MOVWF   EEADR
			MOVF	vLoBysav,W
			MOVWF	EEDATA


	BCF    INTCON,GIE      ;Interrupts sperren			;Schreibroutine Start
			BSF    EECON1,WREN
			MOVLW  0x55
			MOVWF  EECON2
			MOVLW  0xAA
			MOVWF  EECON2
			BSF    EECON1,WR
PollEE5		BTFSC  EECON1,WR      ;Schreibabwarten
			GOTO   PollEE5
	BsF    INTCON,GIE      ;Interrupts erlauben


			BCF    EECON1,WREN
			BCF    STATUS,RP0
			RETURN		
		;SchreibRoutine Ende

upByte			MOVLW  D'1'
				ADDWF  vUpBysav,F

			MOVLW	eUpEEP			;EEprom Schreiben- Adresse und Daten laden Up Byte
			MOVWF   EEADR
			MOVF	vUpBysav,W
			MOVWF	EEDATA

			BSF    EECON1,WREN									
				BCF    INTCON,GIE      ;Interrupts sperren		;Schreibroutine Start
			MOVLW  0x55
			MOVWF  EECON2
			MOVLW  0xAA
			MOVWF  EECON2
			BSF    EECON1,WR
PollEE6		BTFSC  EECON1,WR      ;Schreibabwarten
			GOTO   PollEE6
				BSF    INTCON,GIE      ;Interrupts sperren		;SchreibRoutine END
			RETURN

			;Ende des BetrZ�hl - ZeitSchleifen als Schleifen einsortiert


;PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP

 ;PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR
  
PrimInit 
		 MOVLW  D'62'                ;Diese Einstellungen werden nur beim ersten Einschalten nach dem Batterieanschlu� geladen.
		MOVWF  vVoreinstellVU
		BCF  PORTA,3
		MOVLW  PrimstartRegelZahl
		MOVWF   vRegelZahl
		MOVLW  PrimstartRegelZahl
		ADDLW  D'253'         ;Komplementaddition = minus 3
		MOVWF  vRegelZahlSum

		CALL  InitBetr  ;�berpr�fung des EEProm



			BSF STATUS,RP0
			MOVLW  B'01111111'
			MOVWF  TRISB 
			MOVLW  B'01110111'
			MOVWF  TRISA			
			BCF STATUS,RP0
			CLRF  PORTB 
			MOVLW B'00000010'
			MOVWF  vMyFlags
			MOVLW  D'61'   
			MOVWF vVoxIstStufe
						;MOVLW  D'60'
			MOVWF		vFrust
					MOVLW  D'2'                 
					MOVWF  vBeschleuniger

				MOVLW  D'35'
				MOVWF vLimitCounterA
				MOVLW  D'8'
				MOVWF vLimitCounterB
		MOVLW D'5'
		MOVWF vFeierSignal



				CLRF vPegel1      
				CLRF vPegel2
				CLRF vPegel3
				CLRF vPegel4
				CLRF vPegel5
		
		RETURN

;--------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------

;URINBETRIEBNAHME  NACH DEM PROGRAMMIEREN EINMALIG

;F�R BETRIEBSSTUNDENZ�HLER
;Cleart das Betriebsstunden EEprom, was danach nat�rlich keinesfalls mehr vorkommen darf.
;wird nur beim Anlegen der Betriebsspannung �berpr�ft.

   							;von Priminit gecallt


		;eInitproof1	EQU    0x01   ;EEprom Adresse
		;eInitproof2  EQU    0x02		;EEPROM Adr
		;vProoftemp1	EQU   jhlz 0x24	hz	;RAM Adresse   BANK1 Adressen
		;vProoftemp2	EQU   ftz 0x25	gh	;RAM Adr
InitBetr  	BSF    STATUS,RP0
 			BCF    INTCON,GIE   ;EEprom auslesen  L�schbest�tigung1
            MOVLW  eInitproof1 			 
		 	MOVWF  EEADR

			BSF    EECON1,RD
			MOVF   EEDATA,W
			MOVWF  vProoftemp1
			
            MOVLW  eInitproof2 	;EEPROM auslesen	L�schbest�tigung2 
		 	MOVWF  EEADR
			BSF    EECON1,RD
			MOVF   EEDATA,W
			MOVWF  vProoftemp2

			MOVLW  0x5B				;L�sch 1 pr�fen  (nur das letzte Bit mu�und darf vershieden sein, und das wird dann decrementiert.)
			XORWF  vProoftemp1,F    
			DECFSZ vProoftemp1,F
			GOTO   Goon1
			BCF    STATUS,RP0
            RETURN
            	
Goon1		MOVLW  0x5A				;L�sch 2 pr�fen
			XORWF  vProoftemp2,F    
			DECFSZ vProoftemp2,F
			GOTO   Goon2
			BCF    STATUS,RP0
            RETURN

 			;InitialSetzung EEprom BetrZ�hler  auf 1
Goon2		MOVLW	eLoEEP			;Adresse und Daten laden low Byte
			MOVWF   EEADR
			MOVLW	D'1'
			MOVWF	EEDATA
										;Schreibroutine Start
			BSF    EECON1,WREN
			MOVLW  0x55
			MOVWF  EECON2
			MOVLW  0xAA
			MOVWF  EECON2
			BSF    EECON1,WR	
PollEE1		BTFSC  EECON1,WR      ;Schreibabwarten
			GOTO   PollEE1
										
   			MOVLW	eUpEEP			;Adresse und Daten laden UP Byte
			MOVWF   EEADR
			MOVLW	D'0'
			MOVWF	EEDATA
										;Schreibroutine Start
			MOVLW  0x55
			MOVWF  EECON2
			MOVLW  0xAA
			MOVWF  EECON2
			BSF    EECON1,WR						
PollEE2		BTFSC  EECON1,WR      ;Schreibabwarten
			GOTO   PollEE2				

			;InitBest�tigung1 schreiben
   			MOVLW	eInitproof1			;Adresse und Daten laden 
			MOVWF   EEADR
			MOVLW	0x5A
			MOVWF	EEDATA
								;Schreibroutine Start
			MOVLW  0x55
			MOVWF  EECON2
			MOVLW  0xAA
			MOVWF  EECON2
			BSF    EECON1,WR		
PollEE3		BTFSC  EECON1,WR      ;Schreibabwarten
			GOTO   PollEE3

  			MOVLW	eInitproof2			;Adresse und Daten laden 
			MOVWF   EEADR
			MOVLW	0x5B
			MOVWF	EEDATA
								;Schreibroutine Start
			MOVLW  0x55
			MOVWF  EECON2
			MOVLW  0xAA
			MOVWF  EECON2
			BSF    EECON1,WR	
PollEE4		BTFSC  EECON1,WR      ;Schreibabwarten
			GOTO   PollEE4

			BCF    EECON1,WREN
			BCF   STATUS,RP0
			RETURN
	    ; ENDE DER INITIALISIERUNG desBetrZ�hlers

     ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
     ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


	 ; Einschub Frust
FrustBonus	MOVLW 		D'61'		; gecalled. hier flie�t die Frustauswertung in die Ausschaltung ein  (sehr langfristig)
			SUBWF 		vVoxIstStufe,W				
			BTFSC  		STATUS,C													
			RETURN
			MOVLW    FrustBerueckZaehler
			SUBWF  	vAusschaltBonus,F

 	
			MOVLW 		D'60'
			SUBWF 		vVoxIstStufe,W
			BTFSC		STATUS,C
			RETURN
			MOVLW    FrustBerueckZaehler
			SUBWF  	vAusschaltBonus,F
			return
	; Ende Einschub Frust





     ;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

				;Auswerten des �bersteuerugsspeichers - Stellen der Regelzahlen
UeAuswert		MOVF vPegel5,W
				ADDWF vUebersteuerung,F
				MOVLW  UeGeduldEnde        
				SUBWF vUebersteuerung,W
				BTFSS  STATUS,C
				GOTO   Untergrenze
				DECF  vRegelZahl,F
				DECF  vRegelZahlSum,F
				MOVLW  D'60'				;(zur�cksetzen wichtig, damit eine �nderung der Regelzahlen nicht zu schnell weitere nach sich zieht.)
				MOVWF  vUebersteuerung						;ausserdem damit automatisch �berlaufschutz.

Untergrenze		MOVLW  MehrUeWagen   
				SUBWF vUebersteuerung,W
				BTFSC  STATUS,C
				GOTO   RegelZUeber
				INCF  vRegelZahl,F
				INCF  vRegelZahlSum,F
				MOVLW  D'60'				;dto
				MOVWF  vUebersteuerung
				
RegelZUeber		MOVLW  RegelZOG
				ADDLW  D'1'
				SUBWF  vRegelZahl,W
				BTFSS	STATUS,C
				GOTO	RegelZUnt
				MOVLW  RegelZOG			;(Die beiden Zahlen haben immer konstanten Abstand)
				MOVWF  vRegelZahl
				MOVLW  RegelZOG
				ADDLW   D'253'     ;Komplementaddition, also minus3
				MOVWF  vRegelZahlSum

RegelZUnt		MOVLW  RegelZUG
				SUBWF  vRegelZahl,W
				BTFSC	STATUS,C
				GOTO	Relevanz9
				MOVLW  RegelZUG
				MOVWF  vRegelZahl
				MOVLW  RegelZUG
				ADDLW   D'253'     ;Komplementaddition, also minus3
				MOVWF  vRegelZahlSum
Relevanz9				Return


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	      
	

  
VUAusgabe		MOVF vVUistStufe,W
			BSF STATUS,RP0
			MOVWF 	vVUistBank1    ;Hat auch Datenpufferwirkung f�r untiges Auswertverfahren 
									;das die urspr�nglichen Daten verdirbt nicht nur wegen B�nken


			MOVLW D'60'						
			SUBWF  vVUistBank1,F		; WerteBereich 60-66
			BTFSS  STATUS,Z
			GOTO   AusgTest2
			BsF TRISB,7			;gr��ter R  also VU zweitniedrigste Stufe nach gar-kein-Port-gecleared
			BsF TRISB,6						;(jedesmal die Speicher einzeln stellen umst�ndlich, aber vermeidet knacks effekt)
			BsF TRISB,5
			BsF TRISB,4
								;Trisb, 3 steht f�r vu nicht zur Verf�gung  (PWM-Ausgsang f�r Spannungswandler)
			BsF TRISB,2
			BsF TRISB,1      ;kleinster R also h�chste VU
			GOTO	VUAusFertig		

AusgTest2	DECF   vVUistBank1,F
			BTFSS  STATUS,Z
			GOTO   AusgTest3
			BCF TRISB,7	

			BsF TRISB,6						
			BsF TRISB,5
			BsF TRISB,4
			BsF TRISB,2
			BsF TRISB,1      		
			GOTO	VUAusFertig
			
AusgTest3	DECF   vVUistBank1,F
			BTFSS  STATUS,Z
			GOTO   AusgTest4
			BCF TRISB,6

			BsF TRISB,7						
			BsF TRISB,5
			BsF TRISB,4
			BsF TRISB,2
			BsF TRISB,1
			GOTO	VUAusFertig

AusgTest4	DECF   vVUistBank1,F
			BTFSS  STATUS,Z
			GOTO   AusgTest5
			BCF TRISB,5

			BsF TRISB,6						
			BsF TRISB,4
			BsF TRISB,7
			BsF TRISB,2
			BsF TRISB,1
			GOTO	VUAusFertig

AusgTest5	DECF   vVUistBank1,F
			BTFSS  STATUS,Z
			GOTO   AusgTest6
			BCF TRISB,4

			BsF TRISB,5						
			BsF TRISB,2
			BsF TRISB,6
			BsF TRISB,1
			BsF TRISB,7
			GOTO	VUAusFertig

AusgTest6	DECF   vVUistBank1,F
			BTFSS  STATUS,Z
			GOTO   AusgTest7
			BCF TRISB,2

			BsF TRISB,4						
			BsF TRISB,1
			BsF TRISB,5
			BsF TRISB,6
			BsF TRISB,7
			GOTO	VUAusFertig

AusgTest7	BCF TRISB,1

			BsF TRISB,2						
			BsF TRISB,4
			BsF TRISB,5
			BsF TRISB,6
			BsF TRISB,7
			
			
VUAusFertig		BCF  STATUS,RP0
			CALL Schl100   ; damit die �nderung Zeit hat wirksam zu werden und nicht automatisch als zwei Pegelklassen registriert wird
								;soll �berfl�ssiges Hin und Her-Regeln reduzieren
   RETURN

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;Testprogramm f�r Led an RA3:     (Einfach CALL TestBlk an der entsprechenden Programmstelle einf�gen LED an Diagnoseausgang (oder Sendestufe h�ren)
								  ;(  Semikolons entfernen und schon kann man am Toggeln feststellen ob das Programm an der Stelle auch vorbeikommt und wann.)
		
;TestBlk	BTFSS vMyFlags,3   ;nur zum TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	GOTO Mu3Set     ; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	BCF vMyFlags,3    ;nur zum TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	BCF  PORTA,3			; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	GOTO BlinkFert	; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;Mu3Set	BsF vMyFlags,3	; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;		BSF PORTA,3		; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;BlinkFert RETURN        ;nur zum TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


;TestBlk1 BCF STATUS,RP0          ;Variante bestimmt zur Einf�gung an Bank-1-Stellen.)
;	BTFSS vMyFlags,3   ;nur zum TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	GOTO Mu3Set1     ; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	BCF vMyFlags,3    ;nur zum TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	BCF  PORTA,3			; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;	GOTO BlinkFert1	; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;Mu3Set1	BsF vMyFlags,3	; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;		BSF PORTA,3		; wieder entfernen !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;BlinkFert1		BSF STATUS,RP0
; RETURN        ;nur zum TEST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



        END



