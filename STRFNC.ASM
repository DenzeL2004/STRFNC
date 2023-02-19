.model tiny
.code
org 100h

locals @@


MIDDLE_SCREEN 	 equ 80d * 12d + 40d 
SIZE_VIDMEM_LINE equ 80d
VIDMEM_ADR 	  	 equ 0B800h

START_INPUT_PARAM equ 0080h

COLOR_FRAME	equ 3F00h 			;white symbol on cyan frame				

NOPE equ nop

;-----------------------------------------------------------------
;Exit
;-----------------------------------------------------------------
;Entrt: nope
;Exit: N/A
;Destroy: N/A
;-----------------------------------------------------------------

Exit	macro code
		NOPE

		mov AX, 4c00h or code
		int 21h		

		NOPE
		endm

;-----------------------------------------------------------------
;Set Memory Address
;-----------------------------------------------------------------
;Entrt: nope
;Exit: es
;Destroy: di
;-----------------------------------------------------------------

SET_MEMADRESS	macro
				NOPE

				mov di, VIDMEM_ADR		;video memory address
				mov es, di

				NOPE
				endm

;-----------------------------------------------------------------
;multiplies the value of a register bx by 10 use bit shifting
;-----------------------------------------------------------------
;Entrt: bx (input val)
;Exit: bx 
;Destroy: dx
;-----------------------------------------------------------------
MUL10		macro
			NOPE

			mov dx, bx 	;save bx val

			shl bx, 3d 	;bx = bx * 8
			shl dx, 1d	;dx = dx * 2

			add bx, dx	
			
			NOPE
			endm



Start:

    push offset Str1
    push offset Str2
    
    call Strcmp

    SET_MEMADRESS

    mov di, SIZE_VIDMEM_LINE * 2d
    mov ax, cx
    call DecRep    

    Exit 0;

    ;-----------------------------------------------------------------
	;calculate the length of a string (PASCAL)
	;-----------------------------------------------------------------
    ;Param: strPtr (addres to start string)
	;Exit: si 
	;Destroy: si
	;-----------------------------------------------------------------
    Strlen proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strPtr equ [bp + 4] ;input param

        mov si, word ptr strPtr  ;si = strPtr

        cmp byte ptr [si], '$' ;check on terminate symbol
        je @@goToRet

        @@next:
            inc si  ;si++
        cmp byte ptr [si], '$' ;check on terminate symbol
        jne @@next

    @@goToRet:
        sub si, strPtr

        pop bp      ;recover bp value
        ret 2d * 1d ;free stack memory from parameters
    Strlen endp

    ;-----------------------------------------------------------------
	;find addres first symbol (CDECL)
	;-----------------------------------------------------------------
    ;Param: strPtr (addres to start string), findCh (given symbol)
	;Exit: si 
	;Destroy: al, si
	;-----------------------------------------------------------------
    Memchr proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strPtr  equ [bp + 4] ;input param
        findCh  equ byte ptr [bp + 6] ;input param
        prefLen equ word ptr [bp + 8] ;input param

        mov si, word ptr strPtr  ;si = strPtr

        @@next:

            cmp byte ptr [si], '$' ;check is symol is det
            je @@break

            mov al, findCh
            cmp al, byte ptr [si] ;check cur symbol is given
            je @@goToRet

            inc si  ;si++

        dec prefLen     ;pref--
        cmp prefLen, 0d ;check counter is zero
        jne @@next


    @@break:
        mov si, strPtr ;string without given sybol 
        dec si

    @@goToRet:
        sub si, strPtr ;get address given symbol in string
        inc si

        pop bp      ;recover bp value
        ret 
    Memchr endp

    ;-----------------------------------------------------------------
	;copy n symbols from src ro dst string(CDECL)
	;----------------------------------------------------------------- 
    ;Param: strDstPtr (addres destination string), strSrcPtr (addres source string), prefLen (counter)
    ;Entry: none
	;Exit: di 
	;Destroy: di, si
	;-----------------------------------------------------------------
    Memcpy proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strDstPtr  equ [bp + 4] ;input param
        strSrcPtr  equ [bp + 6] ;input param
        prefLen    equ word ptr [bp + 8] ;input param

        mov si, word ptr strSrcPtr  ;si = strSrcPtr
        mov di, word ptr strDstPtr  ;di = strDstPtr

        @@next:
            
            movsb

        dec prefLen     ;pref--
        cmp prefLen, 0d ;check counter is zero
        jne @@next


    @@goToRet:
        mov byte ptr [di], '$' ;set terminate symbol
        mov di, strDstPtr      ;return value

        pop bp      ;recover bp value
        ret 
    Memcpy endp

    ;-----------------------------------------------------------------
	;string comparison (CDECL)
	;----------------------------------------------------------------- 
    ;Param: strDstPtr (addres destination string), strSrcPtr (addres source string), prefLen (counter)
    ;Entry: none
	;Exit: cx 
	;Destroy: di, si
	;-----------------------------------------------------------------
    Memcmp proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strDstPtr  equ [bp + 4] ;input param
        strSrcPtr  equ [bp + 6] ;input param
        prefLen    equ word ptr [bp + 8] ;input param

        mov si, word ptr strSrcPtr  ;si = strSrcPtr
        mov di, word ptr strDstPtr  ;di = strDstPtr

        xor cx, cx

        @@next:
            mov cl, byte ptr [di]
            sub cl, byte ptr [si] 
            je @@endIf1
                mov prefLen, 1d
            @@endIf1:

            inc si ;si++
            inc di ;di++
        
        dec prefLen     ;pref--
        cmp prefLen, 0d ;check counter is zero
        jne @@next

        pop bp      ;recover bp value
        ret 
    Memcmp endp

    ;-----------------------------------------------------------------
	;set n symbols to src (CDECL)
	;----------------------------------------------------------------- 
    ;Param: strDstPtr (addres destination string), cpyCh (given symbol)
    ;Entry: none
	;Exit: di 
	;Destroy: al, di
	;-----------------------------------------------------------------
    Memset proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strDstPtr  equ [bp + 4] ;input param
        cpyCh      equ [bp + 6] ;input param
        prefLen    equ word ptr [bp + 8] ;input param

        mov di, word ptr strDstPtr  ;di = strDstPtr

        @@next:
            
            mov al, byte ptr cpyCh
            STOSB

        dec prefLen     ;pref--
        cmp prefLen, 0d ;check counter is zero
        jne @@next

        mov di, strDstPtr      ;return value

        pop bp      ;recover bp value
        ret 
    Memset endp

    ;-----------------------------------------------------------------
	;find addres first symbol (PASCAL)
	;-----------------------------------------------------------------
    ;Param: strPtr (addres to start string), findCh (given symbol)
	;Exit: si 
	;Destroy: al, si
	;-----------------------------------------------------------------
    Strchr proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strPtr  equ [bp + 6] ;input param
        findCh  equ byte ptr [bp + 4] ;input param

        mov si, word ptr strPtr  ;si = strPtr

        @@next:

            mov al, findCh
            cmp al, byte ptr [si] ;check cur symbol is given
            je @@goToRet

            inc si  ;si++

        cmp byte ptr [si], '$' ;check is symol is det
        jne @@next

        mov si, strPtr ;string without given sybol 
        dec si

    @@goToRet:
        sub si, strPtr ;get address given symbol in string
        inc si

        pop bp      ;recover bp value
        ret 2d * 2d ;delet two paramtrs
    Strchr endp

    ;-----------------------------------------------------------------
	;string comparison (CDECL)
	;----------------------------------------------------------------- 
    ;Param: strDstPtr (addres destination string), strSrcPtr (addres source string), prefLen (counter)
    ;Entry: none
	;Exit: cx 
	;Destroy: di, si
	;-----------------------------------------------------------------
    Strcmp proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strSrcPtr  equ [bp + 4] ;input param
        strDstPtr  equ [bp + 6] ;input param
        
        mov si, word ptr strSrcPtr  ;si = strSrcPtr
        mov di, word ptr strDstPtr  ;di = strDstPtr

        xor cx, cx

        @@next:
            mov cl, byte ptr [di]
            sub cl, byte ptr [si] 
            je @@endIf1
                mov prefLen, 1d
                jmp @@goToRet
            @@endIf1:

            inc si ;si++
            inc di ;di++
        
        cmp byte ptr [si], '$' ;check counter is zero
        jne @@next

        @@goToRet:

        pop bp      ;recover bp value
        ret 
    Strcmp endp


    ;-----------------------------------------------------------------
	;copy symbols from src to dst string(CDECL)
	;----------------------------------------------------------------- 
    ;Param: strDstPtr (addres destination string), strSrcPtr (addres source string), prefLen (counter)
    ;Entry: none
	;Exit: di 
	;Destroy: di, si
	;-----------------------------------------------------------------
    Strcpy proc
        push bp    ;save bp value to stack
        mov bp, sp ;save bp value to bp

        strDstPtr  equ [bp + 6] ;input param
        strSrcPtr  equ [bp + 4] ;input param

        mov si, word ptr strSrcPtr  ;si = strSrcPtr
        mov di, word ptr strDstPtr  ;di = strDstPtr

        @@next:

            movsb

        cmp byte ptr [si], '$' ;check is symol is det
        jne @@next

    @@goToRet:
        mov byte ptr [di], '$'
        mov di, strDstPtr

        pop bp      ;recover bp value
        ret 2d * 2d ;delet two paramtrs
    Strcpy endp
    
    ;-----------------------------------------------------------------
	;Deс representation of a number
	;-----------------------------------------------------------------
	;Assumes: es = VIDMEM_ADR
	;Entry: ax (input number), di (address in video mem)
	;Exit: none
	;Destroy: ax, cx, dx
	;-----------------------------------------------------------------
    DecRep	proc

		push bp  		;save bp to stack
 		mov bp, sp
		sub sp, 2d 		 ;local var

		quotient equ word ptr [bp-2] ;local var 'quotient'

		mov quotient, ax	;dublicate ax value
		mov cx, 10000d
		
		@@next:
			xor dx, dx
			mov ax, quotient
			div cx 				;dx:ax div cx
			
			or al, '0'
			or ax, COLOR_FRAME
			mov word ptr es:[di], ax	;set symbol to video mem
			add di, 2d 					;increse di pointere

			mov quotient, dx

			mov ax, cx		;ax = 10^i
			xor dx, dx 		;

			mov cx, 10d 	;-----------------------+
			div cx			;dx:ax div cx (cx / 10)	|
			mov cx, ax 		;save quotient to cx

		cmp cx, 0d
		jne @@next

		mov word ptr es:[di], COLOR_FRAME or 'd' ;set 'd' sumbol to video mem

		mov sp, bp 		;abandoning the place of local variables
		pop bp 			;bp recovery

		ret
	DecRep	endp

.data
Str1 db "Hello world!", '$' ;debug string
Str2 db "Hello Ded!", '$' ;debug string
	
end Start