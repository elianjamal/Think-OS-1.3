; ============================================================================
; THINK OS - STAGE 2 COMPLETE KERNEL (CLEAN - NO DUPLICATES)
; ============================================================================

[BITS 16]
[ORG 0x0000]

start:
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFF
    call init_system
    call password_screen
    jmp desktop

init_system:
    mov ax, 0x0003
    int 0x10
    mov word [ttt_wins], 0
    mov word [ttt_losses], 0
    mov word [ttt_draws], 0
    mov word [chess_games], 0
    mov word [monopoly_record], 0
    mov word [oregon_completed], 0
    mov byte [file_saved], 0
    ret

password_screen:
    call clear_screen
    mov bl, 0x0B
    mov si, art_line1
    call print_color
    mov si, art_line2
    call print_color
    mov si, art_line3
    call print_color
    mov si, art_line4
    call print_color
    mov si, art_line5
    call print_color
    mov si, art_line6
    call print_color
    mov si, art_line7
    call print_color
    mov si, art_line8
    call print_color
    call newline
    mov bl, 0x0E
    mov si, str_password
    call print_color
    call get_password
    
    ; Compare password
    mov si, password_buffer
    mov di, correct_password
    call strcmp_fixed
    cmp al, 1           ; AL = 1 means passwords match
    je .ok
    
    ; Wrong password
    mov bl, 0x0C
    mov si, str_wrong
    call print_color
    call wait_key
    jmp password_screen
.ok:
    ret

strcmp_fixed:
    ; Compare strings at SI and DI
    ; Returns AL=1 if match, AL=0 if no match
    push si
    push di
    push bx
    
.loop:
    lodsb           ; Load byte from SI into AL
    mov bl, [di]    ; Load byte from DI into BL
    inc di
    
    cmp al, bl      ; Compare characters
    jne .not_equal
    
    test al, al     ; Check if we reached null terminator
    jz .equal
    
    jmp .loop
    
.equal:
    mov al, 1       ; Strings match
    pop bx
    pop di
    pop si
    ret
    
.not_equal:
    xor al, al      ; Strings don't match (AL = 0)
    pop bx
    pop di
    pop si
    ret

desktop:
    call clear_screen
    mov bl, 0x0B
    mov si, box_top
    call print_color
    mov bl, 0x0A
    mov si, desktop_art1
    call print_color
    mov si, desktop_art2
    call print_color
    mov si, desktop_art3
    call print_color
    mov si, desktop_art4
    call print_color
    mov si, desktop_art5
    call print_color
    mov si, desktop_art6
    call print_color
    mov si, desktop_art7
    call print_color
    mov si, desktop_art8
    call print_color
    mov bl, 0x0B
    mov si, box_mid
    call print_color
    mov bl, 0x0E
    mov si, welcome_msg
    call print_color
    call display_datetime
    mov bl, 0x0B
    mov si, box_mid
    call print_color
    mov bl, 0x0F
    mov si, menu1
    call print_color
    mov si, menu2
    call print_color
    mov si, menu3
    call print_color
    mov si, menu4
    call print_color
    mov bl, 0x0B
    mov si, box_bottom
    call print_color
    call newline
    mov bl, 0x0E
    mov si, select_prompt
    call print_color
.loop:
    xor ah, ah
    int 0x16
    cmp al, '1'
    je app_write_file
    cmp al, '2'
    je app_documents
    cmp al, '3'
    je app_calculator
    cmp al, '4'
    je app_games
    cmp al, '5'
    je app_terminal
    cmp al, '6'
    je app_system_info
    cmp al, '7'
    je app_mods
    cmp al, '8'
    je app_logout
    jmp .loop

; Replace the terminal loop section with this fixed version:

app_terminal:
    call clear_screen
    mov bl, 0x0B
    mov si, term_header
    call print_color
    call newline
    mov si, term_ready
    call print
    call newline
.loop:
    mov si, term_prompt
    call print
    mov di, term_buffer
    call get_string
    
    ; Check NEOFETCH
    mov si, term_buffer
    mov di, cmd_neofetch
    call strcmp_upper
    je .neofetch
    
    ; Check HELP
    mov si, term_buffer
    mov di, cmd_help
    call strcmp_upper
    je .help
    
    ; Check EXIT
    mov si, term_buffer
    mov di, cmd_exit
    call strcmp_upper
    je .exit
    
    ; Check LIST
    mov si, term_buffer
    mov di, cmd_list
    call strcmp_upper
    je .list
    
    ; If we get here, unknown command
    mov si, str_syntax_error
    call print
    jmp .loop
.neofetch:
    call neofetch_display
    jmp .loop
.help:
    call terminal_help
    jmp .loop
.list:
    call newline
    mov si, str_no_program
    call print
    jmp .loop
.exit:
    jmp desktop

; And replace the strcmp_upper function with this corrected version:


neofetch_display:
    call newline
    mov si, neo_art1
    call print
    call newline
    mov si, neo_art2
    call print
    call newline
    mov si, neo_art3
    call print
    call newline
    mov si, neo_art4
    call print
    call newline
    mov si, neo_art5
    call print
    call newline
    mov si, neo_art6
    call print
    call newline
    mov si, neo_art7
    call print
    call newline
    mov si, neo_art8
    call print
    call newline
    mov si, neo_art9
    call print
    call newline
    mov si, neo_art10
    call print
    call newline
    mov si, neo_art11
    call print
    call newline
    mov si, neo_art12
    call print
    call newline
    call newline
    mov si, neo_info_line1
    call print
    mov si, neo_info_line2
    call print
    mov si, neo_info_line3
    call print
    mov si, neo_info_line4
    call print
    mov si, neo_info_line5
    call print
    mov si, neo_info_line6
    call print
    call newline
    ret

terminal_help:
    call newline
    mov si, help_basic1
    call print
    mov si, help_basic2
    call print
    mov si, help_cmd1
    call print
    call newline
    ret

app_calculator:
    call clear_screen
    mov bl, 0x0D
    mov si, calc_header
    call print_color
    call newline
    mov si, calc_info
    call print
    call newline
.loop:
    mov si, calc_equation_prompt
    call print
    mov di, calc_equation_buffer
    call get_string
    
    ; Parse and evaluate the equation
    mov si, calc_equation_buffer
    call evaluate_expression
    cmp dx, 0xFFFF  ; Error flag
    je .error
    
    ; Show result
    mov si, str_result
    call print
    mov ax, [calc_result]
    call print_number
    call newline
    jmp .continue
    
.error:
    mov si, str_calc_error
    call print
    
.continue:
    call newline
    mov si, str_calc_again
    call print
    xor ah, ah
    int 0x16
    cmp al, 'y'
    je .loop
    cmp al, 'Y'
    je .loop
    jmp desktop

evaluate_expression:
    ; Evaluates full expression with operator precedence
    ; Returns result in [calc_result], DX=0xFFFF on error
    push si
    push di
    
    ; Initialize value stack
    mov word [calc_stack_ptr], 0
    mov word [calc_op_stack_ptr], 0
    
    call skip_spaces
    
.parse_loop:
    lodsb
    test al, al
    jz .finish
    
    ; Check for number
    cmp al, '0'
    jb .check_operator
    cmp al, '9'
    ja .check_operator
    
    ; Parse number
    dec si
    call parse_number
    cmp dx, 0
    je .error
    
    ; Push to value stack
    call push_value
    jmp .continue_parse
    
.check_operator:
    cmp al, ' '
    je .continue_parse
    
    ; Check for special functions
    cmp al, 's'
    je .check_sqrt
    cmp al, 'S'
    je .check_sqrt
    
    cmp al, 'f'
    je .check_factorial
    cmp al, 'F'
    je .check_factorial
    
    cmp al, 'a'
    je .check_abs
    cmp al, 'A'
    je .check_abs
    
    ; Regular operator
    call process_operator
    jmp .continue_parse
    
.check_sqrt:
    ; Check if next chars are "qrt"
    push si
    lodsb
    cmp al, 'q'
    jne .not_sqrt
    lodsb
    cmp al, 'r'
    jne .not_sqrt
    lodsb
    cmp al, 't'
    jne .not_sqrt
    
    ; It's sqrt - pop value and calculate
    call pop_value
    call calculate_sqrt
    call push_value
    jmp .continue_parse
    
.not_sqrt:
    pop si
    jmp .error
    
.check_factorial:
    ; Check if next chars are "act"
    push si
    lodsb
    cmp al, 'a'
    jne .not_fact
    lodsb
    cmp al, 'c'
    jne .not_fact
    lodsb
    cmp al, 't'
    jne .not_fact
    
    ; It's fact - pop value and calculate
    call pop_value
    call calculate_factorial
    call push_value
    jmp .continue_parse
    
.not_fact:
    pop si
    jmp .error
    
.check_abs:
    ; Check if next chars are "bs"
    push si
    lodsb
    cmp al, 'b'
    jne .not_abs
    lodsb
    cmp al, 's'
    jne .not_abs
    
    ; It's abs - pop value and calculate
    call pop_value
    test ax, ax
    jns .abs_positive
    neg ax
.abs_positive:
    call push_value
    jmp .continue_parse
    
.not_abs:
    pop si
    jmp .error
    
.continue_parse:
    call skip_spaces
    jmp .parse_loop
    
.finish:
    ; Process remaining operators
    call flush_operators
    
    ; Get final result
    call pop_value
    mov [calc_result], ax
    
    xor dx, dx
    pop di
    pop si
    ret
    
.error:
    mov dx, 0xFFFF
    pop di
    pop si
    ret

process_operator:
    ; Process operator with precedence
    ; AL contains the operator
    push ax
    
    ; Get precedence of current operator
    call get_precedence
    mov bx, ax  ; BX = current precedence
    
    ; Check operator stack
.check_stack:
    mov cx, [calc_op_stack_ptr]
    test cx, cx
    jz .push_op
    
    ; Get top operator precedence
    dec cx
    mov bx, cx
	mov [calc_op_stack + bx], al
    call get_precedence
    
    ; If stack precedence >= current, evaluate
    cmp ax, bx
    jl .push_op
    
    call pop_operator
    call evaluate_top_operator
    jmp .check_stack
    
.push_op:
    pop ax
    call push_operator
    ret

get_precedence:
    ; Returns precedence of operator in AL
    ; Higher number = higher precedence
    cmp al, '^'
    je .pow_prec
    cmp al, '*'
    je .mul_prec
    cmp al, '/'
    je .mul_prec
    cmp al, '%'
    je .mul_prec
    cmp al, '+'
    je .add_prec
    cmp al, '-'
    je .add_prec
    cmp al, '&'
    je .bit_prec
    cmp al, '|'
    je .bit_prec
    cmp al, 'x'
    je .bit_prec
    cmp al, 'X'
    je .bit_prec
    xor ax, ax
    ret
.pow_prec:
    mov ax, 4
    ret
.mul_prec:
    mov ax, 3
    ret
.add_prec:
    mov ax, 2
    ret
.bit_prec:
    mov ax, 1
    ret

evaluate_top_operator:
    ; Evaluate the top operator on stacks
    call pop_value
    mov bx, ax  ; Second operand
    call pop_value  ; First operand in AX
    
    mov cl, [calc_last_op]
    
    cmp cl, '+'
    je .add
    cmp cl, '-'
    je .sub
    cmp cl, '*'
    je .mul
    cmp cl, '/'
    je .div
    cmp cl, '%'
    je .mod
    cmp cl, '^'
    je .pow
    cmp cl, '&'
    je .and
    cmp cl, '|'
    je .or
    cmp cl, 'x'
    je .xor
    cmp cl, 'X'
    je .xor
    ret
    
.add:
    add ax, bx
    jmp .done
.sub:
    sub ax, bx
    jmp .done
.mul:
    mul bx
    jmp .done
.div:
    cmp bx, 0
    je .done
    xor dx, dx
    div bx
    jmp .done
.mod:
    cmp bx, 0
    je .done
    xor dx, dx
    div bx
    mov ax, dx
    jmp .done
.pow:
    cmp bx, 0
    je .pow_zero
    cmp bx, 1
    je .done
    mov cx, bx
    mov bx, ax
    dec cx
.pow_loop:
    push cx
    mul bx
    pop cx
    loop .pow_loop
    jmp .done
.pow_zero:
    mov ax, 1
    jmp .done
.and:
    and ax, bx
    jmp .done
.or:
    or ax, bx
    jmp .done
.xor:
    xor ax, bx
    
.done:
    call push_value
    ret

flush_operators:
    ; Process all remaining operators
.loop:
    mov cx, [calc_op_stack_ptr]
    test cx, cx
    jz .done
    
    call pop_operator
    call evaluate_top_operator
    jmp .loop
.done:
    ret

calculate_sqrt:
    ; Calculate square root of AX using binary search
    ; Returns result in AX
    push bx
    push cx
    push dx
    
    cmp ax, 0
    je .done
    cmp ax, 1
    je .done
    
    mov cx, ax  ; CX = target number
    mov bx, 1   ; BX = low
    mov dx, ax  ; DX = high
    
.loop:
    ; Calculate mid = (low + high) / 2
    mov ax, bx
    add ax, dx
    shr ax, 1   ; Divide by 2
    
    ; Calculate mid * mid
    push ax
    mul ax
    
    ; Compare with target
    cmp ax, cx
    je .found
    jb .adjust_low
    
    ; mid^2 > target, adjust high
    pop ax
    mov dx, ax
    dec dx
    jmp .continue
    
.adjust_low:
    pop ax
    mov bx, ax
    inc bx
    
.continue:
    cmp bx, dx
    jbe .loop
    
    ; Return lower bound
    mov ax, bx
    dec ax
    jmp .done
    
.found:
    pop ax
    
.done:
    pop dx
    pop cx
    pop bx
    ret

calculate_factorial:
    ; Calculate factorial of AX
    ; Returns result in AX (max input ~8 to avoid overflow)
    push bx
    push cx
    
    cmp ax, 0
    je .zero
    cmp ax, 1
    je .done
    
    mov cx, ax
    mov bx, ax
    dec cx
    
.loop:
    mul bx
    dec bx
    cmp bx, 1
    jg .loop
    jmp .done
    
.zero:
    mov ax, 1
    
.done:
    pop cx
    pop bx
    ret

push_value:
    ; Push AX onto value stack
    push bx
    mov bx, [calc_stack_ptr]
    cmp bx, 32
    jge .done
    shl bx, 1
    mov [calc_value_stack + bx], ax
    shr bx, 1
    inc bx
    mov [calc_stack_ptr], bx
.done:
    pop bx
    ret

pop_value:
    ; Pop value from stack into AX
    push bx
    mov bx, [calc_stack_ptr]
    test bx, bx
    jz .error
    dec bx
    mov [calc_stack_ptr], bx
    shl bx, 1
    mov ax, [calc_value_stack + bx]
    pop bx
    ret
.error:
    xor ax, ax
    pop bx
    ret

push_operator:
    ; Push AL onto operator stack
    push bx
    mov bx, [calc_op_stack_ptr]
    cmp bx, 32
    jge .done
    mov [calc_op_stack + bx], al
    inc bx
    mov [calc_op_stack_ptr], bx
.done:
    pop bx
    ret

pop_operator:
    ; Pop operator from stack into [calc_last_op]
    push bx
    mov bx, [calc_op_stack_ptr]
    test bx, bx
    jz .error
    dec bx
    mov [calc_op_stack_ptr], bx
    mov al, [calc_op_stack + bx]
    mov [calc_last_op], al
    pop bx
    ret
.error:
    pop bx
    ret

skip_spaces:
    ; Skip whitespace characters
.loop:
    lodsb
    cmp al, ' '
    je .loop
    cmp al, 9  ; Tab
    je .loop
    dec si  ; Go back one character
    ret

parse_number:
    ; Parse number from string at SI
    ; Returns number in AX, DX=1 if valid, DX=0 if invalid
    xor ax, ax
    xor dx, dx
    xor cx, cx
    
.loop:
    lodsb
    cmp al, '0'
    jb .done
    cmp al, '9'
    ja .done_back
    
    ; Valid digit
    mov dx, 1  ; Mark as valid
    sub al, '0'
    xor ah, ah
    xchg ax, cx
    push dx
    mov bx, 10
    mul bx
    pop dx
    add ax, cx
    xchg ax, cx
    jmp .loop
    
.done_back:
    dec si  ; Go back one since we read a non-digit
.done:
    mov ax, cx
    ret

; Add these to the data section at the end:
calc_info   db 'Ops: + - * / % ^ & | x  Functions: sqrt fact abs', 13, 10, 0
calc_equation_prompt db 'Equation: ', 0
calc_equation_buffer times 128 db 0
calc_value_stack times 64 dw 0
calc_op_stack times 32 db 0
calc_stack_ptr dw 0
calc_op_stack_ptr dw 0
calc_last_op db 0
calc_result dw 0

app_games:
    call clear_screen
    mov bl, 0x0C
    mov si, games_header
    call print_color
    mov bl, 0x0F
    mov si, games_menu1
    call print_color
    mov si, games_menu2
    call print_color
    mov si, games_menu3
    call print_color
    mov si, games_menu4
    call print_color
    mov si, games_menu5
    call print_color
    mov si, games_menu6
    call print_color
    mov si, games_menu7
    call print_color
.loop:
    xor ah, ah
    int 0x16
    cmp al, '1'
    je game_tictactoe
    cmp al, '2'
    je game_chess
    cmp al, '3'
    je game_monopoly
    cmp al, '4'
    je game_oregon
    cmp al, '5'
    je game_stats
    cmp al, '6'
    je desktop
    jmp .loop

game_tictactoe:
    call clear_screen
    mov bl, 0x0E
    mov si, ttt_header
    call print_color
    call newline
    mov di, ttt_board
    mov cx, 9
    mov al, ' '
    rep stosb
    mov byte [ttt_turn], 'X'
.loop:
    call draw_ttt_board
    mov si, str_player
    call print
    mov al, [ttt_turn]
    mov ah, 0x0E
    int 0x10
    mov si, str_move_pos
    call print
    xor ah, ah
    int 0x16
    sub al, '1'
    cmp al, 8
    ja .loop
    xor ah, ah
    mov bx, ax
    cmp byte [ttt_board + bx], ' '
    jne .loop
    mov al, [ttt_turn]
    mov [ttt_board + bx], al
    call check_ttt_winner
    cmp al, 1
    je .winner
    call check_ttt_draw
    cmp al, 1
    je .draw
    mov al, [ttt_turn]
    cmp al, 'X'
    je .set_o
    mov byte [ttt_turn], 'X'
    jmp .loop
.set_o:
    mov byte [ttt_turn], 'O'
    jmp .loop
.winner:
    call draw_ttt_board
    mov si, str_player
    call print
    mov al, [ttt_turn]
    mov ah, 0x0E
    int 0x10
    mov si, str_wins
    call print
    mov al, [ttt_turn]
    cmp al, 'X'
    je .player_win
    inc word [ttt_losses]
    jmp .end
.player_win:
    inc word [ttt_wins]
    jmp .end
.draw:
    call draw_ttt_board
    mov si, str_draw
    call print
    inc word [ttt_draws]
.end:
    call wait_key
    jmp app_games

draw_ttt_board:
    call newline
    mov si, ttt_grid_header
    call print
    mov si, ttt_row_prefix
    call print
    mov ah, 0x0E
    mov al, [ttt_board + 0]
    int 0x10
    mov al, '|'
    int 0x10
    mov al, [ttt_board + 1]
    int 0x10
    mov al, '|'
    int 0x10
    mov al, [ttt_board + 2]
    int 0x10
    call newline
    mov si, ttt_row_div
    call print
    mov si, ttt_row_prefix
    call print
    mov al, [ttt_board + 3]
    int 0x10
    mov al, '|'
    int 0x10
    mov al, [ttt_board + 4]
    int 0x10
    mov al, '|'
    int 0x10
    mov al, [ttt_board + 5]
    int 0x10
    call newline
    mov si, ttt_row_div
    call print
    mov si, ttt_row_prefix
    call print
    mov al, [ttt_board + 6]
    int 0x10
    mov al, '|'
    int 0x10
    mov al, [ttt_board + 7]
    int 0x10
    mov al, '|'
    int 0x10
    mov al, [ttt_board + 8]
    int 0x10
    call newline
    call newline
    ret

check_ttt_winner:
    mov al, [ttt_board + 0]
    cmp al, ' '
    je .no
    cmp al, [ttt_board + 1]
    jne .no
    cmp al, [ttt_board + 2]
    jne .no
    mov al, 1
    ret
.no:
    xor al, al
    ret

check_ttt_draw:
    mov cx, 9
    mov si, ttt_board
.loop:
    lodsb
    cmp al, ' '
    je .no
    loop .loop
    mov al, 1
    ret
.no:
    xor al, al
    ret

game_chess:
    call clear_screen
    mov bl, 0x0D
    mov si, chess_header
    call print_color
    call newline
    mov si, chess_board1
    call print
    mov si, chess_board2
    call print
    mov si, chess_board3
    call print
    mov si, chess_board4
    call print
    mov si, chess_board5
    call print
    mov si, chess_board6
    call print
    mov si, chess_board7
    call print
    mov si, chess_board8
    call print
    mov si, chess_board9
    call print
    call newline
    mov si, chess_info
    call print
    inc word [chess_games]
    call wait_key
    jmp app_games

game_monopoly:
    call clear_screen
    mov bl, 0x0A
    mov si, mono_header
    call print_color
    call newline
    mov word [monopoly_money], 1500
    mov byte [monopoly_turn], 0
.loop:
    call newline
    mov si, mono_money
    call print
    mov ax, [monopoly_money]
    call print_number
    call newline
    mov si, mono_turn
    call print
    xor ah, ah
    mov al, [monopoly_turn]
    call print_number
    call newline
    call newline
    mov si, mono_roll
    call print
    xor ah, ah
    int 0x16
    cmp al, 'q'
    je .end
    cmp al, 'Q'
    je .end
    call get_random
    and al, 0x05
    add al, 1
    xor ah, ah
    add [monopoly_money], ax
    mov si, mono_gained
    call print
    call print_number
    call newline
    inc byte [monopoly_turn]
    cmp byte [monopoly_turn], 20
    jl .loop
.end:
    call newline
    mov si, mono_final
    call print
    mov ax, [monopoly_money]
    call print_number
    call newline
    mov ax, [monopoly_money]
    cmp ax, [monopoly_record]
    jle .no_record
    mov [monopoly_record], ax
    mov si, mono_new_record
    call print
.no_record:
    call wait_key
    jmp app_games

game_oregon:
    call clear_screen
    mov bl, 0x0C
    mov si, oregon_header
    call print_color
    call newline
    mov si, oregon_intro
    call print
    call newline
    mov word [oregon_food], 200
    mov word [oregon_bullets], 50
    mov word [oregon_miles], 0
    mov byte [oregon_health], 5
.loop:
    call newline
    mov si, oregon_status
    call print
    mov si, oregon_miles_label
    call print
    mov ax, [oregon_miles]
    call print_number
    call newline
    mov si, oregon_food_label
    call print
    mov ax, [oregon_food]
    call print_number
    call newline
    mov si, oregon_bullets_label
    call print
    mov ax, [oregon_bullets]
    call print_number
    call newline
    call newline
    mov si, oregon_options
    call print
    xor ah, ah
    int 0x16
    cmp al, '1'
    je .travel
    cmp al, '2'
    je .hunt
    cmp al, '3'
    je .rest
    cmp al, '4'
    je .quit
    jmp .loop
.travel:
    call get_random
    and al, 0x0F
    add al, 10
    xor ah, ah
    add [oregon_miles], ax
    sub word [oregon_food], 5
    mov si, oregon_traveled
    call print
    jmp .check
.hunt:
    cmp word [oregon_bullets], 10
    jl .no_bullets
    sub word [oregon_bullets], 10
    call get_random
    and al, 0x1F
    add al, 20
    xor ah, ah
    add [oregon_food], ax
    mov si, oregon_hunted
    call print
    jmp .check
.no_bullets:
    mov si, oregon_no_bullets
    call print
    jmp .loop
.rest:
    inc byte [oregon_health]
    mov si, oregon_rested
    call print
.check:
    cmp word [oregon_miles], 500
    jge .win
    cmp word [oregon_food], 0
    jle .lose
    cmp byte [oregon_health], 0
    je .lose
    jmp .loop
.win:
    call newline
    mov si, oregon_win
    call print
    inc word [oregon_completed]
    call wait_key
    jmp app_games
.lose:
    call newline
    mov si, oregon_lose
    call print
    call wait_key
    jmp app_games
.quit:
    jmp app_games

game_stats:
    call clear_screen
    mov bl, 0x0D
    mov si, stats_header
    call print_color
    call newline
    mov si, stats_ttt
    call print
    mov si, stats_wins
    call print
    mov ax, [ttt_wins]
    call print_number
    call newline
    mov si, stats_losses
    call print
    mov ax, [ttt_losses]
    call print_number
    call newline
    mov si, stats_draws
    call print
    mov ax, [ttt_draws]
    call print_number
    call newline
    call newline
    mov si, stats_chess
    call print
    mov si, stats_games_played
    call print
    mov ax, [chess_games]
    call print_number
    call newline
    call newline
    mov si, stats_monopoly
    call print
    mov si, stats_record
    call print
    mov ax, [monopoly_record]
    call print_number
    call newline
    call newline
    mov si, stats_oregon
    call print
    mov si, stats_completed
    call print
    mov ax, [oregon_completed]
    call print_number
    call newline
    call newline
    call wait_key
    jmp app_games

app_write_file:
    call clear_screen
    mov bl, 0x0A
    mov si, write_header
    call print_color
    call newline
    mov si, str_filename
    call print
    mov di, temp_filename
    call get_string
    call newline
    mov si, str_enter_text
    call print
    call newline
    mov di, temp_file
    xor cx, cx
.loop:
    xor ah, ah
    int 0x16
    cmp al, 27
    je .save
    cmp al, 13
    je .newline
    cmp al, 8
    je .backspace
    cmp cx, 2000
    jge .loop
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .loop
.newline:
    mov al, 13
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    mov al, 10
    int 0x10
    jmp .loop
.backspace:
    test cx, cx
    jz .loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .loop
.save:
    mov byte [di], 0
    mov word [file_size], cx
    mov byte [file_saved], 1
    call newline
    call newline
    mov si, str_file_saved
    call print
    mov si, temp_filename
    call print
    call newline
    call wait_key
    jmp desktop

app_documents:
    call clear_screen
    mov bl, 0x0A
    mov si, docs_header
    call print_color
    call newline
    cmp byte [file_saved], 0
    je .no_docs
    mov si, str_docs_list
    call print
    mov si, temp_filename
    call print
    mov si, str_size
    call print
    mov ax, [file_size]
    call print_number
    mov si, str_bytes
    call print
    call newline
    call newline
    mov si, str_view_file
    call print
    xor ah, ah
    int 0x16
    cmp al, 'y'
    je .view
    cmp al, 'Y'
    je .view
    jmp .done
.view:
    call newline
    call newline
    mov si, temp_file
    call print
    call newline
    jmp .done
.no_docs:
    mov si, str_no_docs
    call print
.done:
    call wait_key
    jmp desktop

app_system_info:
    call clear_screen
    mov bl, 0x0D
    mov si, sysinfo_header
    call print_color
    call newline
	mov si, sysinfo_header1
    call print_color
    call newline
	mov si, sysinfo_header2
    call print_color
    call newline
	mov si, sysinfo_header3
    call print_color
    call newline
	mov si, sysinfo_header4
    call print_color
    call newline
	mov si, sysinfo_header5
    call print_color
    call newline
	mov si, sysinfo_header6
    call print_color
    call newline
	mov si, sysinfo_header7
    call print_color
    call newline
	mov si, sysinfo_header8
    call print_color
    call newline
    mov si, sysinfo_os
    call print
    mov si, sysinfo_ver
    call print
    call newline
    call wait_key
    jmp desktop

app_mods:
    call clear_screen
    mov bl, 0x0C
    mov si, mods_header
    call print_color
    call newline
    mov si, mods_coming
    call print
    call wait_key
    jmp desktop

app_logout:
    call clear_screen
    mov bl, 0x0C
    mov si, str_goodbye
    call print_color
    call newline
    mov si, str_shutdown_options
    call print_color
    xor ah, ah
    int 0x16
    cmp al, '1'
    je .reboot
    cmp al, '2'
    je .shutdown
    jmp desktop
.reboot:
    jmp start
.shutdown:
    call clear_screen
    mov si, str_safe_shutdown
    call print
    cli
    hlt

clear_screen:
    mov ax, 0x0003
    int 0x10
    ret

print:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

print_color:
    pusha
    mov ah, 0x0E
.loop:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .loop
.done:
    popa
    ret

newline:
    pusha
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    popa
    ret

get_password:
    pusha
    mov di, password_buffer
    xor cx, cx
.loop:
    xor ah, ah
    int 0x16
    cmp al, 13
    je .done
    cmp al, 8
    je .backspace
    cmp cx, 16
    jge .loop
    stosb
    inc cx
    mov ah, 0x0E
    mov al, '*'
    int 0x10
    jmp .loop
.backspace:
    test cx, cx
    jz .loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .loop
.done:
    mov byte [di], 0
    call newline
    popa
    ret

get_string:
    pusha
    xor cx, cx
.loop:
    xor ah, ah
    int 0x16
    cmp al, 13
    je .done
    cmp al, 8
    je .backspace
    cmp cx, 64
    jge .loop
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .loop
.backspace:
    test cx, cx
    jz .loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .loop
.done:
    mov byte [di], 0
    call newline
    popa
    ret

get_number:
    xor ax, ax
    xor cx, cx
.loop:
    xor ah, ah
    int 0x16
    cmp al, 13
    je .done
    cmp al, '0'
    jb .loop
    cmp al, '9'
    ja .loop
    sub al, '0'
    xor ah, ah
    xchg ax, cx
    mov bx, 10
    mul bx
    add ax, cx
    xchg ax, cx
    add al, '0'
    mov ah, 0x0E
    int 0x10
    jmp .loop
.done:
    mov ax, cx
    call newline
    ret

print_number:
    pusha
    xor cx, cx
    mov bx, 10
.loop:
    xor dx, dx
    div bx
    add dl, '0'
    push dx
    inc cx
    test ax, ax
    jnz .loop
.print:
    pop ax
    mov ah, 0x0E
    int 0x10
    loop .print
    popa
    ret

strcmp:
    push si
    push di
.loop:
    lodsb
    mov bl, [di]
    inc di
    cmp al, bl
    jne .ne
    test al, al
    jnz .loop
    pop di
    pop si
    ret
.ne:
    pop di
    pop si
    add sp, 2
    ret

strcmp_upper:
    push si
    push di
.loop:
    lodsb
    cmp al, 'a'
    jb .check
    cmp al, 'z'
    ja .check
    sub al, 32
.check:
    mov bl, [di]
    inc di
    cmp al, bl
    jne .ne
    test al, al
    jnz .loop
    ; Strings match - set zero flag
    pop di
    pop si
    xor al, al  ; Set ZF by making al=0
    cmp al, 0   ; Ensures ZF is set
    ret
.ne:
    ; Strings don't match - clear zero flag
    pop di
    pop si
    mov al, 1   ; Clear ZF
    or al, al   ; Ensures ZF is clear
    ret

wait_key:
    call newline
    mov si, str_press_key
    call print
    xor ah, ah
    int 0x16
    ret

get_random:
    mov ah, 0x00
    int 0x1A
    mov ax, dx
    ret

display_datetime:
    mov ah, 0x02
    int 0x1A
    mov si, str_date
    call print
    mov al, dl
    shr al, 4
    add al, '0'
    mov ah, 0x0E
    int 0x10
    mov al, dl
    and al, 0x0F
    add al, '0'
    int 0x10
    mov al, '/'
    int 0x10
    mov al, dh
    shr al, 4
    add al, '0'
    int 0x10
    mov al, dh
    and al, 0x0F
    add al, '0'
    int 0x10
    call newline
    ret

art_line1   db '================================================', 13, 10, 0
art_line2   db '                                                ', 13, 10, 0
art_line3   db '        TTTTT  H   H  III  N   N  K  K          ', 13, 10, 0
art_line4   db '          T    H   H   I   NN  N  K K           ', 13, 10, 0
art_line5   db '          T    HHHHH   I   N N N  KK            ', 13, 10, 0
art_line6   db '          T    H   H   I   N  NN  K K           ', 13, 10, 0
art_line7   db '          T    H   H  III  N   N  K  K    -OS   ', 13, 10, 0
art_line8   db '         Ultimate Edition v1.1.0                ', 13, 10, 0

str_password db 13, 10, 'Password: ', 0
correct_password db '123', 0
str_wrong   db 13, 10, 'WRONG!', 13, 10, 0

box_top     db '========================================', 13, 10, 0
box_mid     db '----------------------------------------', 13, 10, 0
box_bottom  db '========================================', 13, 10, 0

desktop_art1 db '                                        ', 13, 10, 0
desktop_art2 db '  _____ _     _       _        ___  ____', 13, 10, 0
desktop_art3 db ' |_   _| |__ (_)_ __ | | __   / _ \/ ___|', 13, 10, 0
desktop_art4 db '   | | |  _ \| |  _ \| |/ /  | | | \___ \', 13, 10, 0
desktop_art5 db '   | | | | | | | | | |   <   | |_| |___) |', 13, 10, 0
desktop_art6 db '   |_| |_| |_|_|_| |_|_|\_\   \___/|____/', 13, 10, 0
desktop_art7 db '                                        ', 13, 10, 0
desktop_art8 db '             VERSION 1.1.0                ', 13, 10, 0

welcome_msg db 'Welcome! (c) HBREW Inc.', 13, 10, 0
str_date    db 'Date: ', 0

menu1       db '1-Write      2-Docs        3-Calc ', 13, 10, 0
menu2       db '4-Games      5-Terminal    6-SysInfo ', 13, 10, 0
menu3       db '        7-Mods       8-Logout', 13, 10, 0
menu4       db 0


select_prompt db 'Select: ', 0

term_header db 'THINK OS TERMINAL v1.0', 13, 10, 0
term_ready  db 'READY', 13, 10, 0
term_prompt db '] ', 0

cmd_list    db 'LIST', 0
cmd_neofetch db 'NEOFETCH', 0
cmd_help    db 'HELP', 0
cmd_exit    db 'EXIT', 0

str_syntax_error db '?SYNTAX ERROR', 13, 10, 0
str_no_program db 'NO PROGRAM', 13, 10, 0

help_basic1 db 'BASIC: LIST RUN NEW LOAD SAVE', 13, 10, 0
help_basic2 db 'PRINT LET FOR NEXT IF GOTO', 13, 10, 0
help_cmd1   db 'Commands: NEOFETCH HELP EXIT', 13, 10, 0

neo_art1    db '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,,,,,,,,,,,,,,,@@@@@@@@@@@@@@@@@@@@@@@@', 0
neo_art2    db '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@((,,,,,,,,,,,,,,,,,,,,,,,,,,,((@@@@@@@@@@@@@@', 0
neo_art3    db '@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@', 0
neo_art4    db '@@@@@@@@@@@@@@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,@@@@@@@@', 0
neo_art5    db '@@@@@@@@@@@@@@@@@@@@%,,,,,,,,,,,,,,,,,,,,,,,,,(,,,,,,,,,,,,,,,,,,,,,@@@@@@@@', 0
neo_art6    db '@@@@@@@@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,%@@@@@@@@@@@@@@@,,,,,,,,,,,,,,@@@@@@@@', 0
neo_art7    db '@@@@@@@@@@@@@@@/,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@@@@@@@@@@@@,,,,,,,,,@@@@@@@@', 0
neo_art8    db '@@@@@@@@@@@@@(,,,,,,,,,,,,,,,,,,,,,(@@@@@@@@@@@@@@@@@@@@@@@@@,,,,,,,(@@@@@@@@', 0
neo_art9    db '@@@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@/,,,@@@@@@@@@@@@@@@@@,,,,,,#@@@@@@@@', 0
neo_art10   db '@@@@@@@@@@,,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,,,&@@@@@@@@', 0
neo_art11   db '@@@@@@@@@,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%&@@@@@@@@', 0
neo_art12   db '@@@@@@@@,,,,,,,,,,,,,,,,,,,,@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 0

neo_info_line1 db 'OS: Think OS v1.1.0 Ultimate', 13, 10, 0
neo_info_line2 db 'Host: x86 Computer', 13, 10, 0
neo_info_line3 db 'Kernel: Real Mode 16-bit', 13, 10, 0
neo_info_line4 db 'Shell: BASIC Interpreter', 13, 10, 0
neo_info_line5 db 'CPU: Intel x86 Compatible', 13, 10, 0
neo_info_line6 db 'Memory: 640K + Extended', 13, 10, 0

calc_header db 'CALCULATOR', 13, 10, 13, 10, 0
str_first_num db 'Num 1: ', 0
str_operator db 'Op: ', 0
str_second_num db 'Num 2: ', 0
str_result  db 'Result: ', 0
str_calc_error db 'ERROR!', 13, 10, 0
str_calc_again db 'Again? (y/n): ', 0

games_header db 'GAMES MENU', 13, 10, 13, 10, 0
games_menu1 db '1) Tic-Tac-Toe', 13, 10, 0
games_menu2 db '2) Chess', 13, 10, 0
games_menu3 db '3) Monopoly', 13, 10, 0
games_menu4 db '4) Oregon Trail', 13, 10, 0
games_menu5 db '5) Game Stats', 13, 10, 0
games_menu6 db '6) Back', 13, 10, 0
games_menu7 db 13, 10, 'Select: ', 0

ttt_header  db 'TIC-TAC-TOE', 13, 10, 0
ttt_grid_header db '  1|2|3', 13, 10, 0
ttt_row_prefix db '  ', 0
ttt_row_div db '  -+-+-', 13, 10, 0
str_player  db 'Player ', 0
str_move_pos db ' (1-9): ', 0
str_wins    db ' WINS!', 13, 10, 0
str_draw    db 'DRAW!', 13, 10, 0

stats_header db 'GAME STATS', 13, 10, 13, 10, 0
stats_ttt   db 'Tic-Tac-Toe:', 13, 10, 0
stats_wins  db '  Wins: ', 0
stats_losses db '  Losses: ', 0
stats_draws db '  Draws: ', 0
stats_chess db 'Chess:', 13, 10, 0
stats_games_played db '  Games: ', 0
stats_monopoly db 'Monopoly:', 13, 10, 0
stats_record db '  Record: ' , 0
stats_oregon db 'Oregon Trail:', 13, 10, 0
stats_completed db '  Completed: ', 0

chess_header db 'CHESS GAME', 13, 10, 0
chess_board1 db '   a b c d e f g h', 13, 10, 0
chess_board2 db ' 8 r n b q k b n r', 13, 10, 0
chess_board3 db ' 7 p p p p p p p p', 13, 10, 0
chess_board4 db ' 6 . . . . . . . .', 13, 10, 0
chess_board5 db ' 5 . . . . . . . .', 13, 10, 0
chess_board6 db ' 4 . . . . . . . .', 13, 10, 0
chess_board7 db ' 3 . . . . . . . .', 13, 10, 0
chess_board8 db ' 2 P P P P P P P P', 13, 10, 0
chess_board9 db ' 1 R N B Q K B N R', 13, 10, 0
chess_info  db 'Simplified chess board', 13, 10, 0

mono_header db 'MONOPOLY', 13, 10, 0
mono_money  db 'Money: ', 0
mono_turn   db 'Turn: ', 0
mono_roll   db 'Roll (any key, Q=quit): ', 0
mono_gained db 'Gained: ' , 0
mono_final  db 'Final: ', 0
mono_new_record db 'NEW RECORD!', 13, 10, 0

oregon_header db 'THE OREGON TRAIL', 13, 10, 0
oregon_intro db 'Travel 500 miles to win!', 13, 10, 0
oregon_status db '--- STATUS ---', 13, 10, 0
oregon_miles_label db 'Miles: ', 0
oregon_food_label db 'Food: ', 0
oregon_bullets_label db 'Bullets: ', 0
oregon_options db '1-Travel 2-Hunt 3-Rest 4-Quit: ', 0
oregon_traveled db 'Traveled!', 13, 10, 0
oregon_hunted db 'Hunt success!', 13, 10, 0
oregon_no_bullets db 'No bullets!', 13, 10, 0
oregon_rested db 'Rested.', 13, 10, 0
oregon_win  db 'YOU WIN!', 13, 10, 0
oregon_lose db 'GAME OVER', 13, 10, 0

write_header db 'WRITE FILE', 13, 10, 0
str_filename db 'Filename: ', 0
str_enter_text db 'Text (ESC=save):', 13, 10, 0
str_file_saved db 'Saved!', 13, 10, 0

docs_header db 'DOCUMENTS', 13, 10, 0
str_no_docs db 'No docs yet.', 13, 10, 0
str_docs_list db 'Saved file: ', 0
str_size db ' (', 0
str_bytes db ' bytes)', 13, 10, 0
str_view_file db 'View file? (y/n): ', 0

sysinfo_header db 'SYSTEM INFO', 13, 10, 0
sysinfo_header1     db ' +==========================================+', 0
sysinfo_header2     db ' |                                          |', 0
sysinfo_header3     db ' |            T H I N K   O S               |', 0
sysinfo_header4     db ' |                                          |', 0
sysinfo_header5     db ' |              Version 1.1.0               |', 0
sysinfo_header6     db ' |            (C) HBREW Inc.                |', 0
sysinfo_header7     db ' |            Made by Elian J.              |', 0
sysinfo_header8     db ' +==========================================+', 0


sysinfo_os  db 'Think OS v1.1.0 Ultimate', 13, 10, 0
sysinfo_ver db '(c) HBREW Inc. 2025', 13, 10, 0

mods_header db 'MODS CENTER', 13, 10, 0
mods_coming db 'Mods ready!', 13, 10, 0

str_press_key db 'Press key...', 0
str_goodbye db 'Goodbye from Think OS!', 13, 10, 13, 10, 0
str_shutdown_options db '1) Reboot  2) Shutdown: ', 0
str_safe_shutdown db 'System halted. Safe to power off.', 13, 10, 0

password_buffer times 32 db 0
term_buffer times 128 db 0
temp_filename times 64 db 0
temp_file times 2048 db 0



ttt_board   times 9 db ' '
ttt_turn    db 'X'
ttt_wins    dw 0
ttt_losses  dw 0
ttt_draws   dw 0

chess_games dw 0

monopoly_money dw 0
monopoly_turn db 0
monopoly_record dw 0

oregon_food dw 0
oregon_bullets dw 0
oregon_miles dw 0
oregon_health db 0
oregon_completed dw 0

file_saved  db 0
file_size   dw 0

times 32768-($-$) db 0