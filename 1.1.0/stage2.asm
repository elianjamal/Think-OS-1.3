; ============================================================================
; THINK OS - STAGE 2 KERNEL v1.2.1 ULTIMATE - THE WHOLE SHABANG!
; ============================================================================

[BITS 16]
[ORG 0x0000]

; Define variable addresses
%define password_buffer 0x7000
%define term_buffer 0x7100
%define temp_filename 0x7200
%define temp_file 0x7300
%define temp_file_size 0x8100
%define calc_num1 0x8102
%define calc_num2 0x8104
%define calc_operator 0x8106
%define ttt_board 0x8107
%define ttt_turn 0x8110
%define ttt_wins 0x8111
%define ttt_losses 0x8113
%define ttt_draws 0x8115
%define chess_games 0x8117
%define monopoly_money 0x8119
%define monopoly_turn 0x811B
%define monopoly_record 0x811C
%define oregon_food 0x811E
%define oregon_bullets 0x8120
%define oregon_miles 0x8122
%define oregon_health 0x8124
%define oregon_completed 0x8125
%define file_count 0x8127
%define file_storage 0x8200
%define basic_line_count 0xD000
%define basic_auto_mode 0xD002
%define basic_auto_line 0xD003
%define basic_program 0xD100

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
    mov byte [file_count], 0
    mov word [basic_line_count], 0
    mov byte [basic_auto_mode], 0
    mov word [basic_auto_line], 10
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
    mov si, correct_password
    mov di, password_buffer
    call strcmp
    je .ok
    mov bl, 0x0C
    mov si, str_wrong
    call print_color
    call wait_key
    jmp password_screen
.ok:
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
    cmp byte [basic_auto_mode], 1
    je .auto_line
    mov si, term_prompt
    call print
    jmp .get_input
.auto_line:
    mov ax, [basic_auto_line]
    call print_number
    mov al, ' '
    mov ah, 0x0E
    int 0x10
.get_input:
    mov di, term_buffer
    call get_string
    mov si, term_buffer
    lodsb
    cmp al, '0'
    jb .not_basic_line
    cmp al, '9'
    ja .not_basic_line
    call store_basic_line
    jmp .loop
.not_basic_line:
    mov si, term_buffer
    mov di, cmd_list
    call strcmp_upper
    cmp al, 1
    je .list
    mov si, term_buffer
    mov di, cmd_run
    call strcmp_upper
    cmp al, 1
    je .run
    mov si, term_buffer
    mov di, cmd_new
    call strcmp_upper
    cmp al, 1
    je .new
    mov si, term_buffer
    mov di, cmd_neofetch
    call strcmp_upper
    cmp al, 1
    je .neofetch
    mov si, term_buffer
    mov di, cmd_help
    call strcmp_upper
    cmp al, 1
    je .help
    mov si, term_buffer
    mov di, cmd_exit
    call strcmp_upper
    cmp al, 1
    je .exit
    mov si, term_buffer
    mov di, cmd_home
    call strcmp_upper
    cmp al, 1
    je .home
    mov si, term_buffer
    mov di, cmd_hello
    call strcmp_upper
    cmp al, 1
    je .hello
    mov si, term_buffer
    mov di, cmd_auto
    call strcmp_upper
    cmp al, 1
    je .auto
    mov si, term_buffer
    mov di, cmd_save
    call strcmp_upper
    cmp al, 1
    je .save
    mov si, term_buffer
    mov di, cmd_load
    call strcmp_upper
    cmp al, 1
    je .load
    mov si, term_buffer
    mov di, cmd_catalog
    call strcmp_upper
    cmp al, 1
    je .catalog
    mov si, term_buffer
    mov di, cmd_print_short
    mov cx, 5
    call strncmp_upper
    cmp al, 1
    je .print_cmd
    mov si, str_syntax_error
    call print
    jmp .loop
.list:
    call basic_list
    jmp .loop
.run:
    call basic_run
    jmp .loop
.new:
    call basic_new
    mov si, str_basic_new
    call print
    jmp .loop
.neofetch:
    call neofetch_display
    jmp .loop
.help:
    call terminal_help
    jmp .loop
.exit:
    jmp desktop
.home:
    call clear_screen
    jmp .loop
.hello:
    call newline
    mov si, str_hello_msg
    call print
    jmp .loop
.auto:
    mov byte [basic_auto_mode], 1
    mov word [basic_auto_line], 10
    call newline
    mov si, str_auto_on
    call print
    jmp .loop
.save:
    call newline
    cmp word [basic_line_count], 0
    je .no_program_save
    mov si, str_save_name
    call print
    mov di, temp_filename
    call get_string
    cmp byte [file_count], 10
    jge .storage_full_save
    mov al, [file_count]
    xor ah, ah
    mov cx, 2112
    mul cx
    mov di, file_storage
    add di, ax
    mov si, temp_filename
    mov cx, 64
    rep movsb
    mov si, basic_program
    mov cx, [basic_line_count]
    cmp cx, 16
    jle .save_copy
    mov cx, 16
.save_copy:
    push cx
    shl cx, 7
    rep movsb
    pop cx
    inc byte [file_count]
    mov si, str_program_saved
    call print
    jmp .loop
.no_program_save:
    mov si, str_no_program
    call print
    jmp .loop
.storage_full_save:
    mov si, str_storage_full
    call print
    jmp .loop
.load:
    call newline
    cmp byte [file_count], 0
    je .no_files_load
    mov si, str_load_which
    call print
    call get_number
    cmp ax, 0
    je .loop
    dec ax
    cmp al, [file_count]
    jge .loop
    xor ah, ah
    mov cx, 2112
    mul cx
    mov si, file_storage
    add si, ax
    add si, 64
    mov di, basic_program
    mov cx, 2048
    rep movsb
    mov cx, 16
    mov si, basic_program
    xor bx, bx
.count_lines:
    push cx
    push si
    lodsb
    test al, al
    jz .count_done
    inc bx
    pop si
    add si, 128
    pop cx
    loop .count_lines
.count_done:
    pop si
    pop cx
    mov [basic_line_count], bx
    mov si, str_program_loaded
    call print
    jmp .loop
.no_files_load:
    mov si, str_no_files
    call print
    jmp .loop
.catalog:
    call newline
    cmp byte [file_count], 0
    je .no_files_catalog
    mov si, str_catalog_list
    call print
    xor bx, bx
    mov cl, [file_count]
    xor ch, ch
.catalog_loop:
    push cx
    push bx
    mov ax, bx
    inc ax
    call print_number
    mov si, str_dot
    call print
    pop bx
    push bx
    mov ax, bx
    mov cx, 2112
    mul cx
    mov si, file_storage
    add si, ax
    call print
    call newline
    pop bx
    inc bx
    pop cx
    loop .catalog_loop
    call newline
    jmp .loop
.no_files_catalog:
    mov si, str_no_files
    call print
    jmp .loop
.print_cmd:
    mov si, term_buffer
    add si, 6
    call newline
    call print
    call newline
    jmp .loop

store_basic_line:
    cmp word [basic_line_count], 50
    jge .full
    mov bx, [basic_line_count]
    mov ax, bx
    mov cx, 128
    mul cx
    mov di, basic_program
    add di, ax
    mov si, term_buffer
    mov cx, 128
    rep movsb
    inc word [basic_line_count]
    add word [basic_auto_line], 10
.full:
    ret

basic_list:
    call newline
    cmp word [basic_line_count], 0
    je .empty
    mov cx, [basic_line_count]
    mov si, basic_program
.loop:
    push cx
    push si
    call print
    call newline
    pop si
    add si, 128
    pop cx
    loop .loop
    ret
.empty:
    mov si, str_no_program
    call print
    ret

basic_run:
    call newline
    cmp word [basic_line_count], 0
    je .no_program
    mov cx, [basic_line_count]
    mov si, basic_program
.loop:
    push cx
    push si
    call find_print
    cmp al, 1
    je .has_print
    jmp .next
.has_print:
    mov al, '"'
.find_quote:
    lodsb
    test al, al
    jz .next
    cmp al, '"'
    jne .find_quote
.print_loop:
    lodsb
    cmp al, '"'
    je .next
    test al, al
    jz .next
    mov ah, 0x0E
    int 0x10
    jmp .print_loop
.next:
    call newline
    pop si
    add si, 128
    pop cx
    loop .loop
    call newline
    ret
.no_program:
    mov si, str_no_program
    call print
    ret

basic_new:
    mov word [basic_line_count], 0
    mov byte [basic_auto_mode], 0
    mov word [basic_auto_line], 10
    ret

find_print:
    push si
.loop:
    lodsb
    test al, al
    jz .not_found
    cmp al, 'P'
    jne .loop
    lodsb
    cmp al, 'R'
    jne .loop
    lodsb
    cmp al, 'I'
    jne .loop
    lodsb
    cmp al, 'N'
    jne .loop
    lodsb
    cmp al, 'T'
    jne .loop
    pop si
    mov al, 1
    ret
.not_found:
    pop si
    xor al, al
    ret

strncmp_upper:
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
    dec cx
    jz .match
    test al, al
    jnz .loop
.match:
    pop di
    pop si
    mov al, 1
    ret
.ne:
    pop di
    pop si
    xor al, al
    ret

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
    mov si, help_header
    call print
    mov si, help_list
    call print
    mov si, help_run
    call print
    mov si, help_new
    call print
    mov si, help_auto
    call print
    mov si, help_home
    call print
    mov si, help_print
    call print
    mov si, help_hello
    call print
    mov si, help_neofetch
    call print
    mov si, help_exit
    call print
    call newline
    mov si, help_prog_header
    call print
    mov si, help_prog1
    call print
    mov si, help_prog2
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
    mov si, str_first_num
    call print
    call get_number
    mov [calc_num1], ax
    mov si, str_operator
    call print
    xor ah, ah
    int 0x16
    mov ah, 0x0E
    int 0x10
    mov [calc_operator], al
    call newline
    mov si, str_second_num
    call print
    call get_number
    mov [calc_num2], ax
    mov ax, [calc_num1]
    mov bx, [calc_num2]
    mov cl, [calc_operator]
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
    jmp .error
.add:
    add ax, bx
    jmp .show
.sub:
    sub ax, bx
    jmp .show
.mul:
    mul bx
    jmp .show
.div:
    cmp bx, 0
    je .error
    xor dx, dx
    div bx
    jmp .show
.mod:
    cmp bx, 0
    je .error
    xor dx, dx
    div bx
    mov ax, dx
    jmp .show
.pow:
    cmp bx, 0
    je .pow_zero
    cmp bx, 1
    je .show
    mov cx, bx
    mov bx, ax
    dec cx
.pow_loop:
    push cx
    mul bx
    pop cx
    loop .pow_loop
    jmp .show
.pow_zero:
    mov ax, 1
    jmp .show
.error:
    mov si, str_calc_error
    call print
    jmp .continue
.show:
    mov si, str_result
    call print
    call print_number
    call newline
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
    mov word [temp_file_size], cx
    cmp byte [file_count], 10
    jge .storage_full
    mov al, [file_count]
    xor ah, ah
    mov cx, 2112
    mul cx
    mov di, file_storage
    add di, ax
    mov si, temp_filename
    mov cx, 64
    rep movsb
    mov si, temp_file
    mov cx, [temp_file_size]
    cmp cx, 2048
    jle .copy_content
    mov cx, 2048
.copy_content:
    rep movsb
    inc byte [file_count]
    call newline
    call newline
    mov si, str_file_saved
    call print
    mov si, temp_filename
    call print
    mov si, str_saved_to_slot
    call print
    mov al, [file_count]
    xor ah, ah
    call print_number
    call newline
    call wait_key
    jmp desktop
.storage_full:
    call newline
    call newline
    mov si, str_storage_full
    call print
    call wait_key
    jmp desktop

app_documents:
    call clear_screen
    mov bl, 0x0A
    mov si, docs_header
    call print_color
    call newline
    cmp byte [file_count], 0
    je .no_docs
    mov si, str_docs_list
    call print
    call newline
    xor bx, bx
    mov cl, [file_count]
    xor ch, ch
.list_loop:
    push cx
    push bx
    mov ax, bx
    inc ax
    call print_number
    mov si, str_dot
    call print
    pop bx
    push bx
    mov ax, bx
    mov cx, 2112
    mul cx
    mov si, file_storage
    add si, ax
    call print
    call newline
    pop bx
    inc bx
    pop cx
    loop .list_loop
    call newline
    mov si, str_view_which
    call print
    call get_number
    cmp ax, 0
    je .done
    dec ax
    cmp al, [file_count]
    jge .done
    xor ah, ah
    mov cx, 2112
    mul cx
    mov si, file_storage
    add si, ax
    add si, 64
    call newline
    call newline
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
    pop di
    pop si
    mov al, 1
    ret
.ne:
    pop di
    pop si
    xor al, al
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

; ============================================================================
; DATA SECTION
; ============================================================================

art_line1 db '================================================', 13, 10, 0
art_line2 db '                                                ', 13, 10, 0
art_line3 db '        TTTTT  H   H  III  N   N  K  K          ', 13, 10, 0
art_line4 db '          T    H   H   I   NN  N  K K           ', 13, 10, 0
art_line5 db '          T    HHHHH   I   N N N  KK            ', 13, 10, 0
art_line6 db '          T    H   H   I   N  NN  K K           ', 13, 10, 0
art_line7 db '          T    H   H  III  N   N  K  K    -OS   ', 13, 10, 0
art_line8 db '         Ultimate Edition v1.2.1                ', 13, 10, 0

str_password db 13, 10, 'Password: ', 0
correct_password db '123', 0
str_wrong db 13, 10, 'WRONG!', 13, 10, 0

box_top db '========================================', 13, 10, 0
box_mid db '----------------------------------------', 13, 10, 0
box_bottom db '========================================', 13, 10, 0

desktop_art1 db '                                        ', 13, 10, 0
desktop_art2 db '  _____ _     _       _        ___  ____', 13, 10, 0
desktop_art3 db ' |_   _| |__ (_)_ __ | | __   / _ \/ ___|', 13, 10, 0
desktop_art4 db '   | | |  _ \| |  _ \| |/ /  | | | \___ \', 13, 10, 0
desktop_art5 db '   | | | | | | | | | |   <   | |_| |___) |', 13, 10, 0
desktop_art6 db '   |_| |_| |_|_|_| |_|_|\_\   \___/|____/', 13, 10, 0
desktop_art7 db '                                        ', 13, 10, 0
desktop_art8 db '             VERSION 1.2.1              ', 13, 10, 0

welcome_msg db 'Welcome! (c) HBREW Inc.', 13, 10, 0
str_date db 'Date: ', 0

menu1 db '1-Write      2-Docs        3-Calc ', 13, 10, 0
menu2 db '4-Games      5-Terminal    6-SysInfo ', 13, 10, 0
menu3 db '        7-Mods       8-Logout', 13, 10, 0
menu4 db 0

select_prompt db 'Select: ', 0

term_header db 'THINK OS TERMINAL - BASIC READY', 13, 10, 0
term_ready db 'READY', 13, 10, 0
term_prompt db '] ', 0

cmd_list db 'LIST', 0
cmd_run db 'RUN', 0
cmd_new db 'NEW', 0
cmd_neofetch db 'NEOFETCH', 0
cmd_help db 'HELP', 0
cmd_exit db 'EXIT', 0
cmd_home db 'HOME', 0
cmd_hello db 'HELLO', 0
cmd_auto db 'AUTO', 0
cmd_save db 'SAVE', 0
cmd_load db 'LOAD', 0
cmd_catalog db 'CATALOG', 0
cmd_print_short db 'PRINT', 0

str_syntax_error db '?SYNTAX ERROR', 13, 10, 0
str_no_program db 'NO PROGRAM', 13, 10, 0
str_basic_new db 'PROGRAM CLEARED', 13, 10, 0
str_hello_msg db 'HELLO FROM THINK OS!', 13, 10, 0
str_auto_on db 'AUTO MODE ON', 13, 10, 0
str_save_name db 'Save as: ', 0
str_program_saved db 'PROGRAM SAVED!', 13, 10, 0
str_load_which db 'Load file #: ', 0
str_program_loaded db 'PROGRAM LOADED!', 13, 10, 0
str_no_files db 'NO FILES', 13, 10, 0
str_catalog_list db 'SAVED PROGRAMS:', 13, 10, 0

help_header db 'AVAILABLE COMMANDS:', 13, 10, 0
help_list db 'LIST - Display program', 13, 10, 0
help_run db 'RUN - Execute program', 13, 10, 0
help_new db 'NEW - Clear program', 13, 10, 0
help_auto db 'AUTO - Auto line numbering', 13, 10, 0
help_home db 'HOME - Clear screen', 13, 10, 0
help_print db 'PRINT - Print value', 13, 10, 0
help_hello db 'HELLO - Display greeting', 13, 10, 0
help_neofetch db 'NEOFETCH - System info', 13, 10, 0
help_exit db 'EXIT - Return to desktop', 13, 10, 0
help_prog_header db 13, 10, 'FILE COMMANDS:', 13, 10, 0
help_prog1 db 'SAVE - Save program to file', 13, 10, 0
help_prog2 db 'LOAD - Load program from file', 13, 10, 0

neo_art1 db '@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 13, 10, 0
neo_art2 db '@@@@   THINK OS v1.2.1  @@@@', 13, 10, 0
neo_art3 db '@@@@    ULTIMATE ED.    @@@@', 13, 10, 0
neo_art4 db '@@@@   (C) HBREW 2025   @@@@', 13, 10, 0
neo_art5 db '@@@@    ELIAN J.        @@@@', 13, 10, 0
neo_art6 db '@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 13, 10, 0

neo_info_line1 db 'OS: Think OS v1.2.1 Ultimate', 13, 10, 0
neo_info_line2 db 'Shell: BASIC Interpreter', 13, 10, 0
neo_info_line3 db 'CPU: Intel x86 Compatible', 13, 10, 0
neo_info_line4 db 'Memory: 640K + Extended', 13, 10, 0
neo_info_line5 db 'Features: Files, Games, Calc', 13, 10, 0
neo_info_line6 db 'Status: FULLY OPERATIONAL!', 13, 10, 0

calc_header db 'CALCULATOR', 13, 10, 0
calc_info db 'Ops: + - * / % ^', 13, 10, 0
str_first_num db 'Num 1: ', 0
str_operator db 'Op: ', 0
str_second_num db 'Num 2: ', 0
str_result db 'Result: ', 0
str_calc_error db 'ERROR!', 13, 10, 0
str_calc_again db 'Again? (y/n): ', 0

games_header db 'GAMES MENU', 13, 10, 0
games_menu1 db '1) Tic-Tac-Toe', 13, 10, 0
games_menu2 db '2) Chess', 13, 10, 0
games_menu3 db '3) Monopoly', 13, 10, 0
games_menu4 db '4) Oregon Trail', 13, 10, 0
games_menu5 db '5) Game Stats', 13, 10, 0
games_menu6 db '6) Back', 13, 10, 0
games_menu7 db 13, 10, 'Select: ', 0

ttt_header db 'TIC-TAC-TOE', 13, 10, 0
ttt_grid_header db '  1|2|3', 13, 10, 0
ttt_row_prefix db '  ', 0
ttt_row_div db '  -+-+-', 13, 10, 0
str_player db 'Player ', 0
str_move_pos db ' (1-9): ', 0
str_wins db ' WINS!', 13, 10, 0
str_draw db 'DRAW!', 13, 10, 0

stats_header db 'GAME STATS', 13, 10, 0
stats_ttt db 'Tic-Tac-Toe:', 13, 10, 0
stats_wins db '  Wins: ', 0
stats_losses db '  Losses: ', 0
stats_draws db '  Draws: ', 0
stats_chess db 'Chess:', 13, 10, 0
stats_games_played db '  Games: ', 0
stats_monopoly db 'Monopoly:', 13, 10, 0
stats_record db '  Record: ', 0
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
chess_info db 'Simplified chess board', 13, 10, 0

mono_header db 'MONOPOLY', 13, 10, 0
mono_money db 'Money: ', 0
mono_turn db 'Turn: ', 0
mono_roll db 'Roll (any key, Q=quit): ', 0
mono_gained db 'Gained: ', 0
mono_final db 'Final: ', 0
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
oregon_win db 'YOU WIN!', 13, 10, 0
oregon_lose db 'GAME OVER', 13, 10, 0

write_header db 'WRITE FILE', 13, 10, 0
str_filename db 'Filename: ', 0
str_enter_text db 'Text (ESC=save):', 13, 10, 0
str_file_saved db 'Saved: ', 0

docs_header db 'DOCUMENTS', 13, 10, 0
str_no_docs db 'No docs yet.', 13, 10, 0
str_docs_list db 'SAVED FILES:', 0
str_dot db '. ', 0
str_view_which db 'View file # (0=exit): ', 0
str_saved_to_slot db ' (slot ', 0
str_storage_full db 'Storage full! (Max 10 files)', 13, 10, 0

sysinfo_header db 'SYSTEM INFO', 13, 10, 0
sysinfo_header1 db ' +==========================================+', 0
sysinfo_header2 db ' |                                          |', 0
sysinfo_header3 db ' |            T H I N K   O S               |', 0
sysinfo_header4 db ' |                                          |', 0
sysinfo_header5 db ' |              Version 1.2.1               |', 0
sysinfo_header6 db ' |            (C) HBREW Inc.                |', 0
sysinfo_header7 db ' |            Made by Elian J.              |', 0
sysinfo_header8 db ' +==========================================+', 0
sysinfo_os db 'Think OS v1.2.1 Ultimate', 13, 10, 0
sysinfo_ver db '(c) HBREW Inc. 2025', 13, 10, 0

mods_header db 'MODS CENTER', 13, 10, 0
mods_coming db 'Mods ready!', 13, 10, 0

str_press_key db 'Press key...', 0
str_goodbye db 'Goodbye from Think OS!', 13, 10, 0
str_shutdown_options db '1) Reboot  2) Shutdown: ', 0
str_safe_shutdown db 'System halted. Safe to power off.', 13, 10, 0

times 32768-($-$) db 0