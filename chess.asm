[BITS 16]
%include exebin.mac
EXE_begin
[SEGMENT .text]

mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
mov si,init				;Willkommen...
call AfficheText	

;Startaufstellung und Schachbrett in den Speicher schreiben
;Figuren:
;leer: 0
;König w: 6
;Dame w: 5
;Turm w: 4
;Läufer w: 3
;Pferd w: 2
;Bauer w: 1
;				absteigend nach Wert
;König s: 12
;Dame s: 11
;Turm s: 10
;Läufer s: 9
;Pferd s: 8
;Bauer s: 7


;struktur von brett:
;  ABCDEFGH
;8 01234567
;7 89012345	0=10	schwarz
;6 67890123	0=20
;5 45678901 0=30   (dezimal)
;4 23456789
;3 01234567 0=40
;2 89012345 0=50
;1 67890123 0=60	weiß

mov ah, 08h				;warten auf Tastendruck
int 21h
mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
mov si,removeinit
call AfficheText
mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
call Display			;Grafikanzeige

;weiï¿½(Mensch) beginnt
readline
mov ah,02h		;int 10h/ah=02h, Cursor auf dem Bildschirm positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,4		;Zeile		
mov dl,12		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
mov si,prompt
call AfficheText
mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,4		;Zeile		
mov dl,14		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
mov bx,0		;Anzahl der eingegebenen Zeichen auf 0 setzen

;W> erwartet Eingabe:
;nur Enter = Hilfe
;[1-8][1-8] [1-8][1-8] Figur ziehen
;9 = Beenden

promptwait:
mov ah,10h		;wartet, bis etwas eingegeben wurde
int 16h
mov ah,0eh
int 10h			;eingabe anzeigen
cmp al,'0'
je jumpshowhelp		;wenn Enter eingegeben wurde, Hilfe, danach Prompt anzeigen
jmp nohelp
jumpshowhelp
jmp showhelp
nohelp
cmp al,'9'
je jmpende
jmp jmpweiter			
jmpende
jmp	ende	
jmpweiter
cmp al,'1'      
je eins
cmp al,'2'
je zwei
cmp al,'3'
je drei
cmp al,'4'
je vier
cmp al,'5'
je fuenf
cmp al,'6'
je sechs
cmp al,'7'
je sieben
cmp al,'8'
je acht
jmp readline		;wenn keine Zahl eingeben wurde, Eingabe ignorieren
eins
mov al,1
jmp zahlverarbeiten
zwei
mov al,2
jmp zahlverarbeiten
drei
mov al,3
jmp zahlverarbeiten
vier
mov al,4
jmp zahlverarbeiten
fuenf
mov al,5
jmp zahlverarbeiten
sechs
mov al,6
jmp zahlverarbeiten
sieben
mov al,7
jmp zahlverarbeiten
acht
mov al,8
zahlverarbeiten
inc bx
cmp bx,1
je erstezahl
cmp bx,2
je zweitezahl
cmp bx,3
je drittezahl
cmp bx,4		;sonst
je move			;Figur kann bewegt werden (kein Enter erforderlich)
erstezahl
mov [ds:horizontal], al
jmp promptwait
zweitezahl
mov [ds:vertikal], al
jmp promptwait
drittezahl
mov [ds:horizontal+1], al
jmp promptwait
showhelp	;Hilfetext anzeigen
mov dx,0
mov ah,0eh
help_for
mov al, 0xA
int 10h
mov al,0xD
int 10h
inc dx
cmp dx,25
je help_for_end
jmp help_for
help_for_end
mov ah,02h		;int 10h/ah=02h, Cursor auf dem Bildschirm positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
mov si,help
call AfficheText
mov ah,08h
int 21h
mov ah,02h		;int 10h/ah=02h, Cursor auf dem Bildschirm positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
mov si,removehelp
call AfficheText
mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts neben dem Schachbrett
int 10h
call Display
jmp readline

move
mov [ds:vertikal+1], al		;Letzte Zahl verarbeiten
mov al,[byte ds:vertikal]
dec al						;siehe Formel...					
mov dl,8
mul dl						;vertikal mal 8
add al,[byte ds:horizontal]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]	;Figur auf der Startposition in cl zwischenspeichern
mov [figur],cl


mov al,[byte ds:vertikal+1]
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]
mov [zielfeld],cl				;Inhalt des Zielfeldes (eigene Figur || gegnerische Figur || leer)

;zielfeld untersuchen
cmp cl,0
je zielfeld_leer
cmp cl,7
jl zielfeld_eigene
jmp zielfeld_gegner
zielfeld_leer
mov [zielfeld], byte 0
jmp move_control
zielfeld_eigene
mov [zielfeld], byte 1
jmp move_control
zielfeld_gegner
mov [zielfeld], byte 2
jmp move_control

;kontrollieren, ob der Zug erlaubt ist


move_control
;eigene Figur? oder: andere Figur, leer
mov cl,[figur]
cmp cl,1							
je move_bauer
cmp cl,2
je move_springer
cmp cl,3
je move_laeufer
cmp cl,4
je move_turm
cmp cl,5
je move_dame
cmp cl,6
je move_koenig
jmp readline					;else: Bewegung ist nicht zulässig, erneut Befehl einlesen

;ist die Bewegung erlaubt --> Bewegungs-Subprogramme
move_bauer
call bauer_weiss		;Zug erlaubt?
cmp ax,1
je move_bauer_true
jmp readline			;Zug nicht erlaubt!!!
move_bauer_true
jmp move_move			;Zug erlaubt!!!
move_springer
call Springerzug
cmp ax,1
je move_springer_true
jmp readline
move_springer_true
jmp move_move
move_laeufer
call Diagonal
cmp ax,1
je move_laeufer_true
jmp readline
move_laeufer_true
jmp move_move
move_turm
call Gerade
cmp ax,1
je move_turm_true
jmp readline
move_turm_true
jmp move_move
move_dame
call Gerade
push ax
call Diagonal
mov bx,ax
pop ax
or ax,bx				;eins von beiden muss stimmen, damit der Zug erlaubt ist (Gerade OR Diagonal)
cmp ax,1
je move_dame_true
jmp readline
move_dame_true
jmp move_move
move_koenig
call Koenig
cmp ax,1
je move_koenig_true
jmp readline
move_koenig_true
jmp move_move

move_move					;Bewegung ausfhren (ist also erlaubt)
mov al,[byte ds:vertikal]
dec al						;siehe Formel...					
mov dl,8
mul dl						;vertikal mal 8
add al,[byte ds:horizontal]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)

mov bx,ax
dec bx
mov [ds:brett+bx], byte 0	;Startposition ist jetzt leer

mov al,[byte ds:vertikal+1]
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)

mov cl,[figur]
mov bx,ax
dec bx
mov [ds:brett+bx], cl	;Zielposition erhï¿½t jetzt den Wert von Startposition


mov ah,0eh
mov al,0xA
int 10h
mov al,0xD
int 10h
mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
call Display

;schwarz (CPU) setzt, reagiert nur, kein Eröffnungsbuch (es bleiben 8 Mhz, 256KB (!) RAM und 1MB Flash-Speicher)
;fixed-depth = 1
;erst nach killer-moves suchen!

mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,4		;Zeile		
mov dl,14		;Spalte		-->rechts neben dem Schachbrett
int 10h
mov si,think
call AfficheText

;Koordinaten vorher zurücksetzen (wird bei searchtype = 3 nicht vom Subprogramm erledigt)
mov [ds:horizontal], byte 1
mov [ds:vertikal], byte 1
mov [ds:horizontal+1], byte 1
mov [ds:vertikal+1], byte 1

ai_searchkills
mov al,[ds:horizontal]   ;Horizontal-Start
mov ah,[ds:horizontal+1] ;Horizontal-Ziel
mov bl,[ds:vertikal] 	 ;Vertikal-Start
mov bh,[ds:vertikal+1]   ;Vertikal-Ziel			-->Stellenwertsystem: al:bl:ah:bh
inc bh
cmp bh,9
je ai_bh_9
jmp ai_continue_search
ai_bh_9
mov bh,1
inc ah
cmp ah,9
je ai_ah_9
jmp ai_continue_search
ai_ah_9
mov ah,1
inc bl
cmp bl,9
je ai_bl_9
jmp ai_continue_search
ai_bl_9
mov bl,1
inc al
cmp al,9
je ai_nokillermove		;Suche ist zuende

ai_continue_search
mov [ds:horizontal],al
mov [ds:horizontal+1],ah
mov [ds:vertikal],bl
mov [ds:vertikal+1],bh

mov ax,0			;movesblack und brettwert auf 0 setzen
mov [movesblack],ax
mov [brettwert],ax	;ax ist immer noch = 0

mov [searchtype],byte 3
call makemovesblack	;nach Killermoves suchen
cmp ax,1
je ai_jumpdokillermove

jmp ai_nokillermove
ai_jumpdokillermove
jmp ai_dokillermove

ai_nokillermove
mov ax,0			;movesblack und brettwert auf 0 setzen
mov [movesblack],ax
mov [brettwert],ax	;ax ist immer noch = 0

mov [searchtype],byte 0			;nicht mehr nach Killermove suchen
call makemovesblack	;Liste mit möglichen Zügen erstellen und gleichzeitig den Brettwert ermitteln
mov al,[ds:maxmoves_black+1]
mov [ds:best_h],al
inc bx
mov al,[ds:maxmoves_black+2]
mov [ds:best_v],al
inc bx
mov al,[ds:maxmoves_black+3]
mov [ds:best_h+1],al
inc bx
mov al,[ds:maxmoves_black+4]
mov [ds:best_v+1],al
inc bx
mov al,[ds:maxmoves_black+5]
mov [best_figur],al
inc bx


mov [searchtype],byte 1	;Liste ist schon erstellt, jetzt NUR noch den Brettwert berechnen

mov [brettwert],word 0		;Brettwert zurücksetzen, muss sein, weil schwarz setzen MUSS (vielleicht ist die alte
mov [bestbrettwert],word 0	;Position nämlich sowieso am besten)

mov bx,1			;bx ist der Index für maxmoves_black

ai_for				;den Zug ermitteln, der den Brettwert am meisten erhöht

mov al,[ds:maxmoves_black+bx]
mov [ds:horizontal],al
inc bx
mov al,[ds:maxmoves_black+bx]
mov [ds:vertikal],al
inc bx
mov al,[ds:maxmoves_black+bx]
mov [ds:horizontal+1],al
inc bx
mov al,[ds:maxmoves_black+bx]
mov [ds:vertikal+1],al
inc bx
mov al,[ds:maxmoves_black+bx]
mov [figur],al
inc bx

push bx					;den Index bx im Stack speichern 
						;(spar'n mer uns 'ne Variable, hehe, wat'n blödsinn, mer sin einfach zu faul eine zu deklarieren)						
call domove				;Figur setzen

call makemovesblack		;Brettwert berechnen

mov ax,[bestbrettwert]
mov bx,[brettwert]

cmp ax,bx
jg ai_newsbetter
je ai_newsbetter
jmp ai_continueloop						;die neue Position ist nicht besser als die beste (verstehste?)

ai_newsbetter			;die neue Position ist (bisher) die beste
mov [bestbrettwert],bx	;neuen Brettwert in bestbrettwert kopieren

mov al,[ds:old_horizontal]	;neuen Zug in best_ kopieren
mov [ds:best_h],al

mov al,[ds:old_vertikal]
mov [ds:best_v],al

mov al,[ds:old_horizontal+1]
mov [ds:best_h+1],al

mov al,[ds:old_vertikal+1]
mov [ds:best_v+1],al

mov al,[ds:old_figur]
mov [best_figur],al

ai_continueloop
call undomove			;Zug (fr's erste) rckgängig machen


pop bx

mov ax,[movesblack]
cmp bx,ax				;ist bx = ax?   ist der letzte Zug getestet worden?
jg ai_makethemove
jmp ai_for

ai_makethemove
mov al,[ds:best_h]		;den besten Zug in die Koordinaten-Variablen kopieren
mov [ds:horizontal],al

mov al,[ds:best_v]
mov [ds:vertikal],al

mov al,[ds:best_h+1]
mov [ds:horizontal+1],al

mov al,[ds:best_v+1]
mov [ds:vertikal+1],al

mov al,[ds:best_figur]
mov [figur],al
call domove					;bestmöglichen Zug machen (bestmöglich ist hier, wie alles andere auch, relativ!)
jmp ai_finished				;killermove überspringen


ai_dokillermove
mov al,[byte ds:vertikal+1]
dec al						;siehe Formel...					
mov dl,8
mul dl						;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)

mov bx,ax
dec bx
mov al,[ds:brett+bx]	;Figur auf dem Zielfeld nach _al_ kopieren
mov ah,[figur]			;eigene Figur nach _ah_ kopieren
add al,6				;Figur von weiß ist jetzt "schwarz" (höhere Werte)

cmp al,ah
jg ai_kill_really		;lohnt sich!
je ai_kill_really		;ok, immerhin ein Abtausch!
jmp ai_searchkills		;zu gefährlich, lohnt sich nicht!

ai_kill_really
call domove

ai_finished
mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,4		;Zeile		
mov dl,14		;Spalte		-->rechts nebenneben dem Schachbrett
int 10h
mov si,removethink
call AfficheText

mov ah,02h		;Cursor neben W> (Prompt) positionieren
mov bh,0		;Seite 0 (gibt nur eine beim aktuellen Bildschirmmodus)
mov dh,0		;Zeile		
mov dl,0		;Spalte		-->rechts neben dem Schachbrett
int 10h
call Display

jmp readline

ende
mov ax,0x4C00
int 21h				;Programm beenden


Display:					;Sub: Schachbrett anzeigen, passt genau auf den Taschenrechner-Bildschirm
mov si,brett
mov cl,'1'					;Nummerierung an der Seite des Bretts

mov bx,0
mov [es:anzeige+bx], byte '1'
inc bx
mov [es:anzeige+bx], byte ' '
inc bx
mov dx,1 					;Anzahl der Zeichen
.for
mov al,[ds:si]				;al ist das zeichen bzw. die Figur
cmp al,1
je .wbauer
cmp al,2
je .wpferd
cmp al,3
je .wlaeufer
cmp al,4
je .wturm
cmp al,5
je .wdame
cmp al,6
je .wkoenig
cmp al,7
je .sbauer
cmp al,8
je .spferd
cmp al,9
je .slaeufer
cmp al,10
je .sturm
cmp al,11
je .sdame
cmp al,12
je .skoenig
mov al, '*'  		;Leertaste einfügen, wenn keine das Feld keine Figur enthält
jmp .write
.wbauer
mov al, 'b'
jmp .write
.wpferd
mov al, 's'			;s = Springer entspricht Pferd
jmp .write
.wlaeufer
mov al, 'l'
jmp .write
.wturm
mov al, 't'
jmp .write
.wdame
mov al, 'd'
jmp .write
.wkoenig
mov al, 'k'
jmp .write
.sbauer
mov al, 'B'
jmp .write
.spferd
mov al, 'S'			;s = Springer
jmp .write
.slaeufer
mov al, 'L'
jmp .write
.sturm
mov al, 'T'
jmp .write
.sdame
mov al, 'D'
jmp .write
.skoenig
mov al, 'K'
.write
mov [es:anzeige+bx], al
inc bx
inc si
mov ax,dx
push dx			;dx in stack
mov dl,8
div dl
pop dx			;dx aus stack
cmp al,8
je .continue
cmp ah, 0
je .newline
jmp .continue
.newline
;mov ah,0eh
mov al,0xA
mov [es:anzeige+bx], al
inc bx
mov al,0xD
mov [es:anzeige+bx], al
inc bx
inc cl
cmp cl,'9'
je .continue
mov al,cl
mov [es:anzeige+bx], al
inc bx
mov al,' '
mov [es:anzeige+bx], al
inc bx
.continue
inc dx
cmp dx,65
je .printout
jmp .for			;jne und maximale Sprungweite umgangen
.printout
mov si,anzeige
call AfficheText
ret

AfficheText:			;Sub: Text anzeigen
mov ah,0eh
xor bl,bl				;muss sein, warum auch immer
mov bl,3
.Chsuite mov al,[ds:si]
cmp al,'$'
je .Chfin
int 10h
inc si
jmp .Chsuite
.Chfin ret

;Subprogramme fr die einzelnen Bewegungen (bauer, diagonal, gerade, springerzug)
bauer_weiss:					;nur der Bauer braucht ein getrenntes Subprogramm für Schwarz und Weiß
;vertikal-start muss größer als vertikal-ziel sein!
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
cmp bl,al
jg .false						;Wenn al kleiner als bl ist, sofort mit false beenden
mov ah,[zielfeld]
cmp ah,2
je .einfeld	
cmp al,7						;aus der Startaufstellung heraus darf ein Bauer zwei Felder vor
je .zweifelder
jmp .einfeld					;sonst: ein Feld (wenn al <> 7 ist)
.zweifelder
cmp bl,5
je .ok1
jmp .einfeld
.ok1
push ax
push bx
push cx
push dx
dec al
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .ok1_true
jmp .ok1_false
.ok1_true
;Hello world!
pop dx
pop cx
pop bx
pop ax
dec al
jmp .einfeld
.ok1_false
pop dx
pop cx
pop bx
pop ax
mov ax,0						;Zug nicht erlaubt: Das Feld zwischen v7 und v5 ist besetzt (=nicht leer)
ret			
.einfeld
dec al
cmp al,bl
je .true
jmp .false	;sonst: nicht erlaubt
.false
mov ax,0
ret
.true
cmp cl,dl
je .feldfrei
inc cl							;diagonal nach rechts?
cmp cl,dl
je .diagonal
sub cl,2						;diagonal nach links? (muss wegen inc 2 abziehen!)
cmp cl,dl
je .diagonal
jmp .false						;nicht erlaubt
.diagonal
mov cl,[zielfeld]
cmp cl,2
je .really_true
;---------------------
jmp .false						;Bauer kann nur diagonal SCHLAGEN!
jmp .really_true
.feldfrei
mov cl,[zielfeld]
cmp cl,0
je .really_true
jmp .false						;Bauer kann nicht geradeaus schlagen
.really_true					;Zug ist wirklich zulï¿½sig :)
mov ax,1
ret

bauer_schwarz:					;nur der Bauer braucht ein getrenntes Subprogramm fr Schwarz und Weiï¿½
;vertikal-start muss grï¿½er als vertikal-ziel sein!
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
cmp bl,al
jl .false						;Wenn al kleiner als bl ist --> false (Bauer darf nur nach "vorne" ziehen)
mov ah,[zielfeld]
cmp ah,2
je .einfeld	
cmp al,2						;aus der Startaufstellung heraus darf ein Bauer zwei Felder vor
je .zweifelder
jmp .einfeld					;sonst: ein Feld (wenn al <> 2 ist)
.zweifelder
cmp bl,4
je .ok1
jmp .einfeld
.ok1
push ax
push bx
push cx
push dx
;Hello world!
inc al
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .ok1_true
jmp .ok1_false
.ok1_true
pop dx
pop cx
pop bx
pop ax
inc al
jmp .einfeld
.ok1_false
pop dx
pop cx
pop bx
pop ax
mov ax,0						;Zug nicht erlaubt: Das Feld zwischen v2 und v4 ist besetzt (=nicht leer)
ret			
.einfeld
inc al
cmp al,bl
je .true
jmp .false	;sonst: nicht erlaubt
.false
mov ax,0
ret
.true
cmp cl,dl
je .feldfrei
inc cl							;diagonal nach rechts?
cmp cl,dl
je .diagonal
sub cl,2						;diagonal nach links? (muss wegen inc 2 abziehen!)
cmp cl,dl
je .diagonal
jmp .false						;nicht erlaubt
.diagonal
mov cl,[zielfeld]
cmp cl,2
je .really_true
jmp .false						;Bauer kann nur diagonal SCHLAGEN!
jmp .really_true
.feldfrei
mov cl,[zielfeld]
cmp cl,0
je .really_true
jmp .false						;Bauer kann nicht geradeaus schlagen
.really_true					;Zug ist wirklich zulï¿½sig :)
mov ax,1
ret

Gerade:
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
mov dh,0					;Anzahl der "gelaufenen Felder"

;berprfen, ob die Bewegung wirklich geradlinig ist:
cmp cl,dl
je .obenunten
cmp al,bl
je .linksrechts
jmp .false			;eins von beiden muss gleich sein, sonst ist die Bewegung nicht geradlinig

;wenn ja, zum entsprechenden Label (oben, unten, links, rechts) springen
.obenunten
cmp al,bl
jg .jump_oben_for				;wenn al > bl, dann --> Bewegung nach oben
jl .jump_unten_for				;wenn al < bl, dann --> Bewegung nach unten
jmp .false						;cl = dl, al darf nicht = bl sein, sonst wï¿½en Start- und Zielfeld gleich
.linksrechts
cmp cl,dl
jg .jump_links_for				;wenn cl > dl, dann --> Bewegung nach links
jl .jump_rechts_for				;wenn cl < dl, dann --> Bewegung nach rechts
.jump_oben_for
jmp .oben_for
.jump_unten_for
jmp .unten_for
.jump_links_for
jmp .links_for
.jump_rechts_for
jmp .rechts_for

.false						;sonst: Zielfeld = Startfeld darf nicht sein
mov ax,0
ret

.oben_for
inc dh						;dh ist wie ein index
sub al,dh					;Bewegung nach oben (Richtung weiï¿½)
cmp al,bl
je .oben_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
	dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .oben_continue
jmp .false
.oben_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .oben_for
.oben_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .oben_true
cmp cl,0						;letztes Feld ist leer
je .oben_true
jmp .false
.oben_true
jmp .true

.unten_for
inc dh						;dh ist wie ein index
add al,dh					;Bewegung nach unten (Richtung weiï¿½)
cmp al,bl
je .unten_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
	dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .unten_continue
jmp .false
.unten_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .unten_for
.unten_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .unten_true
cmp cl,0						;letztes Feld ist leer
je .unten_true
jmp .false
.unten_true
jmp .true

.links_for
inc dh						;dh ist wie ein index
sub cl,dh					;Bewegung nach links
cmp cl,dl
je .links_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,cl					;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
	dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .links_continue
jmp .false
.links_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .links_for
.links_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .links_true
cmp cl,0						;letztes Feld ist leer
je .links_true
jmp .false
.links_true
jmp .true

.rechts_for
inc dh						;dh ist wie ein index
add cl,dh					;Bewegung nach rechts
cmp cl,dl
je .rechts_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,cl					;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
	dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .rechts_continue
jmp .false
.rechts_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .rechts_for
.rechts_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .rechts_true
cmp cl,0						;letztes Feld ist leer
je .rechts_true
jmp .false
.rechts_true					;es wird kein JMP mehr benï¿½igt
.true
mov ax,1
ret

Diagonal:
mov al,[ds:vertikal]		;Vertikal-Start
sub al,[ds:vertikal+1]		;Vertikal-Ziel subtrahieren
mov bl,[ds:horizontal]		;Horizontal-Start
sub bl,[ds:horizontal+1]	;Horizontal-Ziel subtrahieren
;Absoluter Wert von beiden Zahlen ist gleich:
cmp al,bl
je .diagonal_ok				;gleiche Vorzeichen
add al,bl
cmp al,0
je .diagonal_ok				;verschiedene Vorzeichen
jmp .false					;sonst: keine diagonale Bewegung

;berprfen, ob die Bewegung wirklich geradlinig ist:
.diagonal_ok
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
mov dh,0					;Anzahl der "gelaufenen Felder", Index der "for-schleife"
cmp al,bl
jg .nach_oben
jl .nach_unten
jmp .false					;darf nicht gleich sein!

;wenn ja, zum entsprechenden Label (oben, unten, links, rechts) springen
.nach_oben
cmp cl,dl
jg .jump_obenlinks_for
jl .jump_obenrechts_for
jmp .false					;darf nicht gleich sein!
.nach_unten
cmp cl,dl
jg .jump_untenlinks_for
jl .jump_untenrechts_for
jmp .false					;darf nicht gleich sein!

.jump_obenrechts_for
jmp .obenrechts_for
.jump_obenlinks_for
jmp .obenlinks_for
.jump_untenrechts_for
jmp .untenrechts_for
.jump_untenlinks_for
jmp .untenlinks_for

.obenrechts_for
inc dh						;dh ist wie ein index von einer for-schleife
add cl,dh					;Bewegung nach rechts...
sub al,dh					;...und nach oben
cmp cl,dl
je .obenrechts_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...(Vertikal - !1!
mov dl,8
mul dl							;vertikal mal 8
add al,cl					;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .obenrechts_continue
jmp .false
.obenrechts_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .obenrechts_for
.obenrechts_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .obenrechts_true
cmp cl,0						;letztes Feld ist leer
je .obenrechts_true
jmp .false
.obenrechts_true
jmp .true

.obenlinks_for
inc dh						;dh ist wie ein index von einer for-schleife
sub cl,dh					;Bewegung nach links...
sub al,dh					;...und nach oben
cmp cl,dl
je .obenlinks_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...(Vertikal - !1!
mov dl,8
mul dl							;vertikal mal 8
add al,cl					;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .obenlinks_continue
jmp .false
.obenlinks_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .obenlinks_for
.obenlinks_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .obenlinks_true
cmp cl,0						;letztes Feld ist leer
je .obenlinks_true
jmp .false
.obenlinks_true
jmp .true

.untenrechts_for
inc dh						;dh ist wie ein index von einer for-schleife
add cl,dh					;Bewegung nach rechts...
add al,dh					;...und nach unten
cmp cl,dl
je .untenrechts_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...(Vertikal - !1!
mov dl,8
mul dl							;vertikal mal 8
add al,cl					;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .untenrechts_continue
jmp .false
.untenrechts_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .untenrechts_for
.untenrechts_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .untenrechts_true
cmp cl,0						;letztes Feld ist leer
je .untenrechts_true
jmp .false
.untenrechts_true
jmp .true

.untenlinks_for
inc dh						;dh ist wie ein index von einer for-schleife
sub cl,dh					;Bewegung nach links...
add al,dh					;...und nach unten
cmp cl,dl
je .untenlinks_last				;evtl. letztes Feld berprfen (darf auch gegerische Figur sein)
dec al							;siehe Formel...(Vertikal - !1!)
mov dl,8
mul dl							;vertikal mal 8
add al,cl					;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]
cmp cl,0
je .untenlinks_continue
jmp .false
.untenlinks_continue
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
jmp .untenlinks_for
.untenlinks_last
mov cl,[zielfeld]
cmp cl,2						;auf dem letzten Feld steht eine gegnerische Figur
je .untenlinks_true
cmp cl,0						;letztes Feld ist leer
je .untenlinks_true
jmp .false
.untenlinks_true
jmp .true
.false
mov ax,0
ret
.true
mov ax,1
ret

Koenig:
mov al,[ds:vertikal]		;Vertikal-Start
sub al,[ds:vertikal+1]		;Vertikal-Ziel
mov bl,[ds:horizontal]		;Horizontal-Start
sub bl,[ds:horizontal+1]	;Horizontal-Ziel
cmp al,0
je .ok1_gerade
cmp al,1
je .ok1
cmp al,-1
je .ok1
jmp .false
.ok1
cmp bl,0
je .ok2
.ok1_gerade
cmp bl,1
je .ok2
cmp bl,-1
je .ok2
jmp .false
.ok2
mov cl,[zielfeld]
cmp cl,0
je .true
cmp cl,2
je .true
.false
mov ax,0
ret
.true
mov ax,1
ret

Springerzug:			;3 geradeaus, 1 zur Seite, es gibt acht Mï¿½lichkeiten (in vier Richtungen)
mov cl,[zielfeld]
cmp cl,1				;darf keine eigene Figur sein
je .jump_false			;Lï¿½ge des Sprungs berbrcken
jmp .start_check
.jump_false
jmp .false
;Mï¿½lichkeit 1:
.start_check
mov al,[ds:vertikal]		;Vertikal-Start
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov cl,[ds:horizontal]		;Horizontal-Start
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
sub bl,2
sub dl,1
cmp al,bl
jne .check2
cmp cl,dl
jne .check2
jmp .true					;sonst: Bewegung ist erlaubt
;Mï¿½lichkeit 2:
.check2
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
sub bl,2
add dl,1
cmp al,bl
jne .check3
cmp cl,dl
jne .check3
jmp .true					;sonst: Bewegung ist erlaubt
.check3
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
add bl,2
sub dl,1
cmp al,bl
jne .check4
cmp cl,dl
jne .check4
jmp .true					;sonst: Bewegung ist erlaubt
.check4
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
add bl,2
add dl,1
cmp al,bl
jne .check5
cmp cl,dl
jne .check5
jmp .true					;sonst: Bewegung ist erlaubt
.check5
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
sub bl,1
sub dl,2
cmp al,bl
jne .check6
cmp cl,dl
jne .check6
jmp .true					;sonst: Bewegung ist erlaubt
.check6
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
add bl,1
sub dl,2
cmp al,bl
jne .check7
cmp cl,dl
jne .check7
jmp .true					;sonst: Bewegung ist erlaubt
.check7
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
add bl,1
add dl,2
cmp al,bl
jne .check8
cmp cl,dl
jne .check8
jmp .true					;sonst: Bewegung ist erlaubt
.check8
mov bl,[ds:vertikal+1]		;Vertikal-Ziel
mov dl,[ds:horizontal+1]	;Horizontal-Ziel
sub bl,1
add dl,2
cmp al,bl
jne .false
cmp cl,dl
jne .false
jmp .true					;sonst: Bewegung ist erlaubt
.false
mov ax,0
ret
.true
mov ax,1
ret


makemovesblack:					;erstellt Liste mit allen möglichen Zügen!
mov al,[searchtype]
cmp al,3						;bei Suche nach Killermove die Koordinaten nicht zurücksetzen
je .for						
mov [ds:horizontal], byte 1		;horizontal und vertikal werden wie ein 8*8*8*8-Stellen-System gerechnet
mov [ds:horizontal+1], byte 1	;jeder Zug wird getestet!
mov [ds:vertikal], byte 1
mov [ds:vertikal+1],byte 1

.for		             ;gut, dass ich keine Buchstaben genommen habe!!!

mov al,[byte ds:vertikal]
dec al						;siehe Formel...					
mov dl,8
mul dl						;vertikal mal 8
add al,[byte ds:horizontal]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]	;Figur auf der Startposition in cl zwischenspeichern
mov [figur],cl

cmp cl,0
je .jump_next				;Feld ist leer!
jmp .dont_jump_next			;kontrolle wäre berflssig
.jump_next
jmp .next

.dont_jump_next

mov al,[byte ds:vertikal+1]
dec al						;siehe Formel...					
mov dl,8
mul dl						;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)
mov bx,ax
dec bx
mov cl,[ds:brett+bx]	;Figur auf der Startposition in cl zwischenspeichern

cmp cl,0
je .zielfeld_leer

cmp cl,6
jg .zielfeld_eigene		;jg > 6 anstatt jl < 7

jmp .zielfeld_gegner

.zielfeld_leer
mov [zielfeld], byte 0
jmp .move_control

.zielfeld_eigene
mov [zielfeld], byte 1
jmp .move_control

.zielfeld_gegner
mov [zielfeld], byte 2

.move_control

mov cl,[figur]

;Köng s: 12
;Dame s: 11
;Turm s: 10
;Läufer s: 9
;Pferd s: 8
;Bauer s: 7

;mov [zielfeld],al			???WAS IST DAS DENN???
cmp cl,7				;schwarze Figuren					
je .move_wbauer			;w-bauer, ich weiß
cmp cl,8				;keine Lust, das noch zu ändern...
je .move_wspringer
cmp cl,9
je .move_wlaeufer
cmp cl,10
je .move_wturm
cmp cl,11
je .move_wdame
cmp cl,12
je .move_wkoenig

jmp .next			;Feld ist von einer weißen Figur besetzt, hier unwichtig, zumindest für den computer :->

.move_wbauer
call bauer_schwarz		;Zug erlaubt?
cmp ax,1
je .move_bauer_true
jmp .next			;Zug nicht erlaubt!!!
.move_bauer_true
jmp .addwhite			;Zug erlaubt!!!
.move_wspringer
call Springerzug
cmp ax,1
je .move_wspringer_true
jmp .next
.move_wspringer_true
jmp .addwhite
.move_wlaeufer
call Diagonal
cmp ax,1
je .move_wlaeufer_true
jmp .next
.move_wlaeufer_true
jmp .addwhite
.move_wturm
call Gerade
cmp ax,1
je .move_wturm_true
jmp .next
.move_wturm_true
jmp .addwhite
.move_wdame
call Gerade
push ax
call Diagonal
mov bx,ax
pop ax
or ax,bx				;eins von beiden muss stimmen, damit der Zug erlaubt ist (Gerade OR Diagonal)
cmp ax,1
je .move_wdame_true
jmp .next
.move_wdame_true
jmp .addwhite
.move_wkoenig
call Koenig
cmp ax,1
je .move_wkoenig_true
jmp .next
.move_wkoenig_true
jmp .addwhite

.addwhite
push ax

mov al,[zielfeld]		;untersuchen, ob es sich um einen sog. "Killer-move" handelt
cmp al,2
je .killermove
jmp .addwhite_continue
.killermove				;es ist ein "Killer-move", Suche sofort beenden (ist ein bisschen sehr dumm, ich weiß)
mov ax,[brettwert]
add ax,9				;Schlagen einer gegnerischen Figur, Brettwert um 10 (=9+1) erhöhen
mov [brettwert],ax

mov al,[searchtype]
cmp al,3				;killermoves nur bei 3 suchen!
jne .addwhite_continue
.dokillermove
pop ax		;ax schnell noch eben aus dem Stack entfernen
mov ax,1
ret
.addwhite_continue

mov al,[searchtype]
cmp al,1
je .next2				;wenn searchtype = 1 (nur Brettwert berechnen), dann den teil bis .next berspringen

mov ax,[brettwert]		;sonst: weitermachen
inc ax					;normaler Zug, Brettwert um 1 erhöhen
mov [brettwert],ax
mov ax,[movesblack]
inc ax
mov [movesblack],ax
mov si,maxmoves_black
add si,ax
mov bl,[ds:horizontal]
mov [ds:si],bl
inc si
mov bl,[ds:vertikal]
mov [ds:si],bl
inc si
mov bl,[ds:horizontal+1]
mov [ds:si],bl
inc si
mov bl,[ds:vertikal+1]
mov [ds:si],bl
mov cl,[figur]
inc si
mov [ds:si],cl
add ax,4				;4 INCs von si mit "add ax,4" ausgleichen
mov [movesblack],ax		;!!!!Wichtig (noch wichtiger als mein gelaber)


.next2
pop ax

.next
mov al,[ds:horizontal]   ;Horizontal-Start
mov ah,[ds:horizontal+1] ;Horizontal-Ziel
mov bl,[ds:vertikal] 	 ;Vertikal-Start
mov bh,[ds:vertikal+1]   ;Vertikal-Ziel			-->Stellenwertsystem: al:bl:ah:bh
inc bh
cmp bh,9
je .bh_9
jmp .continue
.bh_9
mov bh,1
inc ah
cmp ah,9
je .ah_9
jmp .continue
.ah_9
mov ah,1
inc bl
cmp bl,9
je .bl_9
jmp .continue
.bl_9
mov bl,1
inc al
cmp al,9
je .last		;Schleife ist fertig - endlich :)
.continue
mov [ds:horizontal],al   ;Horizontal-Start
mov [ds:horizontal+1],ah ;Horizontal-Ziel
mov [ds:vertikal],bl 	 ;Vertikal-Start
mov [ds:vertikal+1],bh   ;Vertikal-Ziel
jmp .for

.last			;makemovesblack beenden
mov ax,0		;kein Killer-Move!
ret

domove:
;für undomove den letzten Zug speichern:
mov al,[ds:horizontal]
mov [ds:old_horizontal],al
mov al,[ds:horizontal+1]
mov [ds:old_horizontal+1],al
mov al,[ds:vertikal]
mov [ds:old_vertikal],al
mov al,[ds:vertikal+1]
mov [ds:old_vertikal+1],al
mov al,[figur]
mov [old_figur],al

;Zug ausführen:
mov al,[byte ds:vertikal]
dec al						;siehe Formel...					
mov dl,8
mul dl						;vertikal mal 8
add al,[byte ds:horizontal]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)

mov bx,ax
dec bx
mov [ds:brett+bx], byte 0	;Startposition ist jetzt leer

mov al,[byte ds:vertikal+1]
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)

mov cl,[figur]
mov bx,ax
dec bx
mov al,[ds:brett+bx]
mov [old_ziel],al			;Zielposition für undomove kopieren (könnte nämlich auch eine gegnerische Figur sein)
mov [ds:brett+bx], cl	;Zielposition erhöht jetzt den Wert von Startposition
ret

undomove:		;letzten Zug (vom Computer) rückgängig machen
mov al,[byte ds:old_vertikal+1]
dec al						;siehe Formel...					
mov dl,8
mul dl						;vertikal mal 8
add al,[byte ds:old_horizontal+1]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)

mov bx,ax
dec bx
mov al,[old_ziel]
mov [ds:brett+bx], al   ;Zielposition ist jetzt leer

mov al,[byte ds:old_vertikal]
dec al							;siehe Formel...					
mov dl,8
mul dl							;vertikal mal 8
add al,[byte ds:old_horizontal]	;Formel: Position auf dem Brett = Horizontal + ((Vertikal-1)*8)

mov cl,[old_figur]
mov bx,ax
dec bx
mov [ds:brett+bx], cl	;NOTA BENE: Startposition erhï¿½t jetzt den Wert von Zielposition
ret

[SEGMENT .data]
prompt db 'W>    $'
horizontal db 0,0,
old_horizontal db 0,0
vertikal db 0,0,
old_vertikal db 0,0
old_figur db 0
old_ziel db 0
figur db 0, '$'
helloworld db 'xx:Hello world!$'
removeinit db '               ', 0xA, 0xD, '              ', 0xA, 0xD, 0xA, 0xD,  '                  ', 0xA, 0xD, '          ', 0xA, 0xD, '                   $'
init db       'CasioSchach 1.0', 0xA, 0xD, 'von Jan Balzer', 0xA, 0xD,  0xA, 0xD, 'Hilfe = 0 eingeben', 0xA, 0xD, 'Weiter mit', 0xA, 0xD, 'beliebiger Taste...$'
;AFX 2.0 Bildschirm hat 8 Zeilen und 21 Spalten:
removehelp db '            ', 0xA, 0xD, '               ', 0xA, 0xD, '             ', 0xA, 0xD, '              ', 0xA, 0xD, '            ', 0xA, 0xD, '             ', 0xA, 0xD, '           $'
help db       'Zug eingeben', 0xA, 0xD, '1-8 waagerecht,', 0xA, 0xD, '1-8 senkrecht', 0xA, 0xD, 'Beispiel: 2526', 0xA, 0xD, 'von Feld 2|5', 0xA, 0xD, 'nach Feld 2|6', 0xA, 0xD, 'Beenden = 9$'
abc db ' 12345678', 0xA, 0xD, '$'
;Gesamtanzeige (fr AfficheText)
anzeige db '1 xxxxxxx',0xA,0xD,'2 xxxxxxxx',0xA,0xD,'3 xxxxxxxx',0xA,0xD,'4 xxxxxxxx',0xA,0xD,'5 xxxxxxxx',0xA,0xD,'6 xxxxxxxx',0xA,0xD,'7 xxxxxxxx',0xA,0xD,'8 xxxxxxxx$$$$$$$$$$$$$$$$$$' ;$$$...$$$ sollte eigentlich nicht sein, na ja...
;Spielbrett mit Startaufstellung
brett db 10,8,9,11,12,9,8,10,7,7,7,7,7,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,4,2,3,5,6,3,2,4					;Kï¿½ig braucht nicht (wenn EIN Kï¿½ig geschlagen wird, ist das Spiel zuende, nicht
;Testbretter fr die Schachengine
;Zge von schwarz	(320 drften hoffentlich reichen!)
maxmoves_black db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
movesblack dw 0		;Anzahl der mï¿½lichen Zge von schwarz
zielfeld db 0,'$'
searchtype db 0		;0 = maxmoves_black erstellen, 1 = nur Brettwert berechnen
brettwert dw 0		;Wert der aktuellen Position (fr Schwarz)  !!!WORD!!!
bestbrettwert dw 0
best_h db 0,0
best_v db 0,0
best_figur db 0
think db       '....$'
removethink db '    $'
EXE_end