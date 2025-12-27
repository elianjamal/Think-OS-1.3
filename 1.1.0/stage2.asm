; ============================================================================
; THINK OS - STAGE 2 KERNEL v1.3.0 ULTIMATE - WITH FILESYSTEM!
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
%define current_dir 0x8128
%define custom_dir_count 0x8129
%define file_storage 0x8200
%define custom_dirs 0xC000
%define basic_line_count 0xD000
%define basic_auto_mode 0xD002
%define basic_auto_line 0xD003
%define basic_program 0xD100
%define gcc_source 0xE000
%define gcc_output 0xE800

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
    mov byte [current_dir], 0  ; 0=root, 1=home, 2=docs, 3=src, 4=bin, 5+=custom
    mov byte [custom_dir_count], 0
    mov word [basic_line_count], 0
    mov byte [basic_auto_mode], 0
    mov word [basic_auto_line], 10
    call init_filesystem
    ret

init_filesystem:
    ; Initialize root directory structure
    ; Directories: home, docs, src, bin
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
    call print_prompt
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
    ; Check filesystem commands
    mov si, term_buffer
    mov di, cmd_ls
    call strcmp_upper
    cmp al, 1
    je .ls
    mov si, term_buffer
    mov di, cmd_cd
    call strcmp_upper
    cmp al, 1
    je .cd_no_args
    mov si, term_buffer
    mov di, cmd_cd
    mov cx, 2
    call strncmp_upper
    cmp al, 1
    je .cd
    mov si, term_buffer
    mov di, cmd_pwd
    call strcmp_upper
    cmp al, 1
    je .pwd
    mov si, term_buffer
    mov di, cmd_mkdir
    mov cx, 5
    call strncmp_upper
    cmp al, 1
    je .mkdir
    mov si, term_buffer
    mov di, cmd_touch
    mov cx, 5
    call strncmp_upper
    cmp al, 1
    je .touch
    mov si, term_buffer
    mov di, cmd_rm
    mov cx, 2
    call strncmp_upper
    cmp al, 1
    je .rm
    mov si, term_buffer
    mov di, cmd_edit
    mov cx, 4
    call strncmp_upper
    cmp al, 1
    je .edit
    mov si, term_buffer
    mov di, cmd_cat
    mov cx, 3
    call strncmp_upper
    cmp al, 1
    je .cat
    mov si, term_buffer
    mov di, cmd_gcc
    mov cx, 3
    call strncmp_upper
    cmp al, 1
    je .gcc
    mov si, term_buffer
    mov di, cmd_make
    call strcmp_upper
    cmp al, 1
    je .make
    mov si, term_buffer
    mov di, cmd_vim
    mov cx, 3
    call strncmp_upper
    cmp al, 1
    je .vim
    mov si, term_buffer
    mov di, cmd_clear
    call strcmp_upper
    cmp al, 1
    je .clear
    mov si, term_buffer
    mov di, cmd_echo
    mov cx, 4
    call strncmp_upper
    cmp al, 1
    je .echo
    mov si, term_buffer
    mov di, cmd_date
    call strcmp_upper
    cmp al, 1
    je .date
    mov si, term_buffer
    mov di, cmd_uname
    call strcmp_upper
    cmp al, 1
    je .uname
    mov si, term_buffer
    mov di, cmd_whoami
    call strcmp_upper
    cmp al, 1
    je .whoami
    mov si, term_buffer
    mov di, cmd_ps
    call strcmp_upper
    cmp al, 1
    je .ps
    mov si, term_buffer
    mov di, cmd_df
    call strcmp_upper
    cmp al, 1
    je .df
    mov si, term_buffer
    mov di, cmd_free
    call strcmp_upper
    cmp al, 1
    je .free
    mov si, term_buffer
    mov di, cmd_top
    call strcmp_upper
    cmp al, 1
    je .top
    mov si, term_buffer
    mov di, cmd_sound
    call strcmp_upper
    cmp al, 1
    je .sound
    mov si, term_buffer
    mov di, cmd_beep
    call strcmp_upper
    cmp al, 1
    je .beep
    mov si, term_buffer
    mov di, cmd_tree
    call strcmp_upper
    cmp al, 1
    je .tree
    mov si, term_buffer
    mov di, cmd_history
    call strcmp_upper
    cmp al, 1
    je .history
    mov si, term_buffer
    mov di, cmd_uptime
    call strcmp_upper
    cmp al, 1
    je .uptime
    mov si, term_buffer
    mov di, cmd_nano
    call strcmp_upper
    cmp al, 1
    je .nano
    mov si, term_buffer
    mov di, cmd_grep
    mov cx, 4
    call strncmp_upper
    cmp al, 1
    je .grep
    mov si, term_buffer
    mov di, cmd_find
    call strcmp_upper
    cmp al, 1
    je .find
    mov si, term_buffer
    mov di, cmd_which
    call strcmp_upper
    cmp al, 1
    je .which
    mov si, term_buffer
    mov di, cmd_man
    call strcmp_upper
    cmp al, 1
    je .man
    mov si, term_buffer
    mov di, cmd_alias
    call strcmp_upper
    cmp al, 1
    je .alias
    mov si, term_buffer
    mov di, cmd_env
    call strcmp_upper
    cmp al, 1
    je .env
    mov si, term_buffer
    mov di, cmd_tsharp
    mov cx, 2
    call strncmp_upper
    cmp al, 1
    je .tsharp
    mov si, term_buffer
    mov di, cmd_compile
    call strcmp_upper
    cmp al, 1
    je .tsharp_compile
    mov si, term_buffer
    mov di, cmd_run_prog
    call strcmp_upper
    cmp al, 1
    je .run_prog
    mov si, term_buffer
    mov di, cmd_ping
    call strcmp_upper
    cmp al, 1
    je .ping
    mov si, term_buffer
    mov di, cmd_ifconfig
    call strcmp_upper
    cmp al, 1
    je .ifconfig
    mov si, term_buffer
    mov di, cmd_netstat
    call strcmp_upper
    cmp al, 1
    je .netstat
    mov si, term_buffer
    mov di, cmd_curl
    call strcmp_upper
    cmp al, 1
    je .curl
    mov si, term_buffer
    mov di, cmd_wget
    call strcmp_upper
    cmp al, 1
    je .wget
    mov si, term_buffer
    mov di, cmd_ssh
    call strcmp_upper
    cmp al, 1
    je .ssh
    mov si, term_buffer
    mov di, cmd_telnet
    call strcmp_upper
    cmp al, 1
    je .telnet
    mov si, term_buffer
    mov di, cmd_ftp
    call strcmp_upper
    cmp al, 1
    je .ftp
    mov si, term_buffer
    mov di, cmd_tar
    call strcmp_upper
    cmp al, 1
    je .tar
    mov si, term_buffer
    mov di, cmd_zip
    call strcmp_upper
    cmp al, 1
    je .zip
    mov si, term_buffer
    mov di, cmd_unzip
    call strcmp_upper
    cmp al, 1
    je .unzip
    mov si, term_buffer
    mov di, cmd_gzip
    call strcmp_upper
    cmp al, 1
    je .gzip
    mov si, term_buffer
    mov di, cmd_gunzip
    call strcmp_upper
    cmp al, 1
    je .gunzip
    mov si, term_buffer
    mov di, cmd_chmod
    call strcmp_upper
    cmp al, 1
    je .chmod
    mov si, term_buffer
    mov di, cmd_chown
    call strcmp_upper
    cmp al, 1
    je .chown
    mov si, term_buffer
    mov di, cmd_kill
    call strcmp_upper
    cmp al, 1
    je .kill
    mov si, term_buffer
    mov di, cmd_killall
    call strcmp_upper
    cmp al, 1
    je .killall
    mov si, term_buffer
    mov di, cmd_reboot
    call strcmp_upper
    cmp al, 1
    je .reboot_sys
    mov si, term_buffer
    mov di, cmd_shutdown
    call strcmp_upper
    cmp al, 1
    je .shutdown_sys
    mov si, term_buffer
    mov di, cmd_halt
    call strcmp_upper
    cmp al, 1
    je .halt_sys
    mov si, term_buffer
    mov di, cmd_dmesg
    call strcmp_upper
    cmp al, 1
    je .dmesg
    mov si, term_buffer
    mov di, cmd_lsmod
    call strcmp_upper
    cmp al, 1
    je .lsmod
    mov si, term_buffer
    mov di, cmd_modprobe
    call strcmp_upper
    cmp al, 1
    je .modprobe
    mov si, term_buffer
    mov di, cmd_mount
    call strcmp_upper
    cmp al, 1
    je .mount
    mov si, term_buffer
    mov di, cmd_umount
    call strcmp_upper
    cmp al, 1
    je .umount
    mov si, term_buffer
    mov di, cmd_fdisk
    call strcmp_upper
    cmp al, 1
    je .fdisk
    mov si, term_buffer
    mov di, cmd_mkfs
    call strcmp_upper
    cmp al, 1
    je .mkfs
    mov si, term_buffer
    mov di, cmd_fsck
    call strcmp_upper
    cmp al, 1
    je .fsck
    mov si, term_buffer
    mov di, cmd_du
    call strcmp_upper
    cmp al, 1
    je .du
    mov si, term_buffer
    mov di, cmd_quota
    call strcmp_upper
    cmp al, 1
    je .quota
    mov si, term_buffer
    mov di, cmd_jobs
    call strcmp_upper
    cmp al, 1
    je .jobs
    mov si, term_buffer
    mov di, cmd_bg
    call strcmp_upper
    cmp al, 1
    je .bg
    mov si, term_buffer
    mov di, cmd_fg
    call strcmp_upper
    cmp al, 1
    je .fg
    mov si, term_buffer
    mov di, cmd_screen
    call strcmp_upper
    cmp al, 1
    je .screen
    mov si, term_buffer
    mov di, cmd_tmux
    call strcmp_upper
    cmp al, 1
    je .tmux
    mov si, term_buffer
    mov di, cmd_less
    call strcmp_upper
    cmp al, 1
    je .less
    mov si, term_buffer
    mov di, cmd_more
    call strcmp_upper
    cmp al, 1
    je .more
    mov si, term_buffer
    mov di, cmd_head
    call strcmp_upper
    cmp al, 1
    je .head
    mov si, term_buffer
    mov di, cmd_tail
    call strcmp_upper
    cmp al, 1
    je .tail
    mov si, term_buffer
    mov di, cmd_sort
    call strcmp_upper
    cmp al, 1
    je .sort
    mov si, term_buffer
    mov di, cmd_uniq
    call strcmp_upper
    cmp al, 1
    je .uniq
    mov si, term_buffer
    mov di, cmd_wc
    call strcmp_upper
    cmp al, 1
    je .wc
    mov si, term_buffer
    mov di, cmd_diff
    call strcmp_upper
    cmp al, 1
    je .diff
    mov si, term_buffer
    mov di, cmd_patch
    call strcmp_upper
    cmp al, 1
    je .patch
    mov si, term_buffer
    mov di, cmd_sed
    call strcmp_upper
    cmp al, 1
    je .sed
    mov si, term_buffer
    mov di, cmd_awk
    call strcmp_upper
    cmp al, 1
    je .awk
    ; Check BASIC commands
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
.ls:
    call cmd_ls_handler
    jmp .loop
.cd:
    call cmd_cd_handler
    jmp .loop
.cd_no_args:
    call newline
    jmp .loop
.pwd:
    call cmd_pwd_handler
    jmp .loop
.mkdir:
    call cmd_mkdir_handler
    jmp .loop
.touch:
    call newline
    mov si, str_touch_msg
    call print
    jmp .loop
.rm:
    call newline
    mov si, str_rm_msg
    call print
    jmp .loop
.edit:
    call cmd_edit_handler
    jmp .loop
.cat:
    call cmd_cat_handler
    jmp .loop
.gcc:
    call cmd_gcc_handler
    jmp .loop
.make:
    call newline
    mov si, str_make_msg
    call print
    jmp .loop
.vim:
    call newline
    mov si, str_vim_msg
    call print
    jmp .loop
.clear:
    call clear_screen
    jmp .loop
.echo:
    call newline
    mov si, term_buffer
    add si, 5
.echo_loop:
    lodsb
    test al, al
    jz .echo_done
    mov ah, 0x0E
    int 0x10
    jmp .echo_loop
.echo_done:
    call newline
    jmp .loop
.date:
    call newline
    call display_datetime
    jmp .loop
.uname:
    call newline
    mov si, str_uname
    call print
    jmp .loop
.whoami:
    call newline
    mov si, str_whoami
    call print
    jmp .loop
.ps:
    call newline
    mov si, str_ps
    call print
    jmp .loop
.df:
    call newline
    mov si, str_df
    call print
    jmp .loop
.free:
    call newline
    mov si, str_free
    call print
    jmp .loop
.top:
    call newline
    mov si, str_top
    call print
    jmp .loop
.sound:
    call sound_test
    jmp .loop
.beep:
    call system_beep
    call newline
    jmp .loop
.tree:
    call newline
    mov si, str_tree
    call print
    jmp .loop
.history:
    call newline
    mov si, str_history
    call print
    jmp .loop
.uptime:
    call newline
    mov si, str_uptime
    call print
    jmp .loop
.nano:
    call newline
    mov si, str_nano
    call print
    jmp .loop
.grep:
    call newline
    mov si, str_grep
    call print
    jmp .loop
.find:
    call newline
    mov si, str_find
    call print
    jmp .loop
.which:
    call newline
    mov si, str_which
    call print
    jmp .loop
.man:
    call newline
    mov si, str_man
    call print
    jmp .loop
.alias:
    call newline
    mov si, str_alias
    call print
    jmp .loop
.env:
    call newline
    mov si, str_env
    call print
    jmp .loop
.tsharp:
    call tsharp_handler
    jmp .loop
.tsharp_compile:
    call tsharp_compile_handler
    jmp .loop
.run_prog:
    call tsharp_run_handler
    jmp .loop
.ping:
    call newline
    mov si, str_ping
    call print
    jmp .loop
.ifconfig:
    call newline
    mov si, str_ifconfig
    call print
    jmp .loop
.netstat:
    call newline
    mov si, str_netstat
    call print
    jmp .loop
.curl:
    call newline
    mov si, str_curl
    call print
    jmp .loop
.wget:
    call newline
    mov si, str_wget
    call print
    jmp .loop
.ssh:
    call newline
    mov si, str_ssh
    call print
    jmp .loop
.telnet:
    call newline
    mov si, str_telnet
    call print
    jmp .loop
.ftp:
    call newline
    mov si, str_ftp
    call print
    jmp .loop
.tar:
    call newline
    mov si, str_tar
    call print
    jmp .loop
.zip:
    call newline
    mov si, str_zip
    call print
    jmp .loop
.unzip:
    call newline
    mov si, str_unzip
    call print
    jmp .loop
.gzip:
    call newline
    mov si, str_gzip
    call print
    jmp .loop
.gunzip:
    call newline
    mov si, str_gunzip
    call print
    jmp .loop
.chmod:
    call newline
    mov si, str_chmod
    call print
    jmp .loop
.chown:
    call newline
    mov si, str_chown
    call print
    jmp .loop
.kill:
    call newline
    mov si, str_kill
    call print
    jmp .loop
.killall:
    call newline
    mov si, str_killall
    call print
    jmp .loop
.reboot_sys:
    jmp start
.shutdown_sys:
    jmp app_logout
.halt_sys:
    call clear_screen
    mov si, str_safe_shutdown
    call print
    cli
    hlt
.dmesg:
    call newline
    mov si, str_dmesg
    call print
    jmp .loop
.lsmod:
    call newline
    mov si, str_lsmod
    call print
    jmp .loop
.modprobe:
    call newline
    mov si, str_modprobe
    call print
    jmp .loop
.mount:
    call newline
    mov si, str_mount
    call print
    jmp .loop
.umount:
    call newline
    mov si, str_umount
    call print
    jmp .loop
.fdisk:
    call newline
    mov si, str_fdisk
    call print
    jmp .loop
.mkfs:
    call newline
    mov si, str_mkfs
    call print
    jmp .loop
.fsck:
    call newline
    mov si, str_fsck
    call print
    jmp .loop
.du:
    call newline
    mov si, str_du
    call print
    jmp .loop
.quota:
    call newline
    mov si, str_quota
    call print
    jmp .loop
.jobs:
    call newline
    mov si, str_jobs
    call print
    jmp .loop
.bg:
    call newline
    mov si, str_bg
    call print
    jmp .loop
.fg:
    call newline
    mov si, str_fg
    call print
    jmp .loop
.screen:
    call newline
    mov si, str_screen
    call print
    jmp .loop
.tmux:
    call newline
    mov si, str_tmux
    call print
    jmp .loop
.less:
    call newline
    mov si, str_less
    call print
    jmp .loop
.more:
    call newline
    mov si, str_more
    call print
    jmp .loop
.head:
    call newline
    mov si, str_head
    call print
    jmp .loop
.tail:
    call newline
    mov si, str_tail
    call print
    jmp .loop
.sort:
    call newline
    mov si, str_sort
    call print
    jmp .loop
.uniq:
    call newline
    mov si, str_uniq
    call print
    jmp .loop
.wc:
    call newline
    mov si, str_wc
    call print
    jmp .loop
.diff:
    call newline
    mov si, str_diff
    call print
    jmp .loop
.patch:
    call newline
    mov si, str_patch
    call print
    jmp .loop
.sed:
    call newline
    mov si, str_sed
    call print
    jmp .loop
.awk:
    call newline
    mov si, str_awk
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

print_prompt:
    pusha
    mov al, [current_dir]
    cmp al, 0
    je .root
    cmp al, 1
    je .home
    cmp al, 2
    je .docs
    cmp al, 3
    je .src
    cmp al, 4
    je .bin
    jmp .custom
.root:
    mov si, prompt_root
    jmp .print
.home:
    mov si, prompt_home
    jmp .print
.docs:
    mov si, prompt_docs
    jmp .print
.src:
    mov si, prompt_src
    jmp .print
.bin:
    mov si, prompt_bin
    jmp .print
.custom:
    mov si, prompt_custom_pre
    call print
    mov al, [current_dir]
    sub al, 5
    xor ah, ah
    mov cx, 32
    mul cx
    mov si, custom_dirs
    add si, ax
    call print
    mov si, prompt_custom_post
    jmp .print
.print:
    call print
    popa
    ret

cmd_mkdir_handler:
    mov si, term_buffer
    add si, 5
.skip_spaces:
    lodsb
    test al, al
    jz .no_name
    cmp al, ' '
    je .skip_spaces
    dec si
    cmp byte [custom_dir_count], 10
    jge .too_many
    ; Store directory name
    mov al, [custom_dir_count]
    xor ah, ah
    mov cx, 32
    mul cx
    mov di, custom_dirs
    add di, ax
    mov cx, 31
.copy_name:
    lodsb
    cmp al, 0
    je .done_copy
    cmp al, ' '
    je .done_copy
    cmp al, 13
    je .done_copy
    cmp al, 10
    je .done_copy
    stosb
    loop .copy_name
.done_copy:
    mov byte [di], 0
    inc byte [custom_dir_count]
    call newline
    mov si, str_mkdir_success
    call print
    ret
.no_name:
    call newline
    mov si, str_mkdir_usage
    call print
    ret
.too_many:
    call newline
    mov si, str_mkdir_full
    call print
    ret

cmd_edit_handler:
    call newline
    mov si, term_buffer
    add si, 5
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si
    cmp byte [si], 0
    je .no_file
    ; Check if we're in docs directory
    mov al, [current_dir]
    cmp al, 2
    jne .wrong_dir
    ; Find file in docs
    push si
    xor bx, bx
    mov cl, [file_count]
    xor ch, ch
    test cx, cx
    jz .not_found
.search_loop:
    push cx
    push bx
    mov ax, bx
    mov cx, 2112
    mul cx
    mov di, file_storage
    add di, ax
    cmp byte [di], 2
    jne .skip_search
    inc di
    add di, 6
    pop bx
    push bx
    push di
    mov si, [esp+8]
    call strcmp
    pop di
    je .found_file
.skip_search:
    pop bx
    inc bx
    pop cx
    loop .search_loop
    pop si
    jmp .not_found
.found_file:
    pop bx
    pop cx
    pop si
    ; Edit the file
    mov si, str_edit_header
    call print
    call newline
    mov si, str_edit_info
    call print
    call newline
    ; Calculate content position
    mov ax, bx
    mov cx, 2112
    mul cx
    mov di, file_storage
    add di, ax
    add di, 65
    ; Clear old content
    push di
    mov cx, 2047
    mov al, 0
    rep stosb
    pop di
    ; Get new content
    xor cx, cx
.edit_loop:
    xor ah, ah
    int 0x16
    cmp al, 27
    je .save_edit
    cmp al, 13
    je .edit_newline
    cmp al, 8
    je .edit_backspace
    cmp cx, 2000
    jge .edit_loop
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .edit_loop
.edit_newline:
    mov al, 13
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    mov al, 10
    int 0x10
    jmp .edit_loop
.edit_backspace:
    test cx, cx
    jz .edit_loop
    dec di
    dec cx
    mov ah, 0x0E
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .edit_loop
.save_edit:
    mov byte [di], 0
    call newline
    call newline
    mov si, str_edit_saved
    call print
    ret
.no_file:
    mov si, str_edit_usage
    call print
    ret
.wrong_dir:
    mov si, str_edit_wrong_dir
    call print
    ret
.not_found:
    mov si, str_edit_not_found
    call print
    ret

cmd_ls_handler:
    call newline
    mov al, [current_dir]
    cmp al, 0
    je .root
    cmp al, 1
    je .home
    cmp al, 2
    je .docs
    cmp al, 3
    je .src
    cmp al, 4
    je .bin
    jmp .custom
.root:
    mov si, dir_home
    call print
    mov si, dir_docs
    call print
    mov si, dir_src
    call print
    mov si, dir_bin
    call print
    ; List custom directories
    cmp byte [custom_dir_count], 0
    je .no_custom
    xor bx, bx
    mov cl, [custom_dir_count]
    xor ch, ch
.root_custom_loop:
    push cx
    push bx
    mov ax, bx
    mov cx, 32
    mul cx
    mov si, custom_dirs
    add si, ax
    call print
    mov si, str_slash_newline
    call print
    pop bx
    inc bx
    pop cx
    loop .root_custom_loop
.no_custom:
    call newline
    ret
.home:
    mov si, file_bashrc
    call print
    mov si, file_profile
    call print
    call newline
    ret
.docs:
    mov si, file_readme
    call print
    mov si, file_manual
    call print
    ; List user-created documents
    cmp byte [file_count], 0
    je .no_user_docs
    xor bx, bx
    mov cl, [file_count]
    xor ch, ch
.docs_loop:
    push cx
    push bx
    mov ax, bx
    mov cx, 2112
    mul cx
    mov si, file_storage
    add si, ax
    cmp byte [si], 2  ; Check if in docs directory
    jne .skip_file
    inc si
    add si, 6  ; Skip /docs/ prefix
    call print
    call newline
.skip_file:
    pop bx
    inc bx
    pop cx
    loop .docs_loop
.no_user_docs:
    call newline
    ret
.src:
    mov si, file_hello_c
    call print
    mov si, file_main_c
    call print
    mov si, file_makefile
    call print
    call newline
    ret
.bin:
    mov si, file_hello
    call print
    mov si, file_main
    call print
    call newline
    ret
.custom:
    mov si, str_empty_dir
    call print
    ret

cmd_cd_handler:
    mov si, term_buffer
    add si, 2
    ; Skip ALL spaces/tabs
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    cmp al, 9  ; tab
    je .skip_spaces
    dec si
    ; Check if empty
    cmp byte [si], 0
    je .done_no_change
    cmp byte [si], 13
    je .done_no_change
    cmp byte [si], 10
    je .done_no_change
    
    ; Special case: ".."
    cmp byte [si], '.'
    jne .not_parent
    cmp byte [si+1], '.'
    jne .not_parent
    ; Make sure it's just ".." and nothing after
    mov al, [si+2]
    cmp al, 0
    je .to_parent
    cmp al, ' '
    jle .to_parent  ; handles space, CR, LF, tab
.not_parent:
    
    ; Special case: "/"
    cmp byte [si], '/'
    jne .not_root
    mov al, [si+1]
    cmp al, 0
    je .to_root
    cmp al, ' '
    jle .to_root
.not_root:
    
    ; Normal directory names - try each one
    ; HOME
    push si
    mov di, dir_home_name
    call strcmp
    pop si
    cmp al, 1
    je .to_home
    
    ; DOCS
    push si
    mov di, dir_docs_name
    call strcmp
    pop si
    cmp al, 1
    je .to_docs
    
    ; SRC
    push si
    mov di, dir_src_name
    call strcmp
    pop si
    cmp al, 1
    je .to_src
    
    ; BIN
    push si
    mov di, dir_bin_name
    call strcmp
    pop si
    cmp al, 1
    je .to_bin
    
    ; Check custom directories
    cmp byte [custom_dir_count], 0
    je .not_found
    xor bx, bx
.check_custom_loop:
    push si
    push bx
    ; Calculate custom dir address
    mov ax, bx
    mov cx, 32
    mul cx
    mov di, custom_dirs
    add di, ax
    ; Compare
    call strcmp
    pop bx
    pop si
    cmp al, 1
    je .found_custom
    ; Next custom dir
    inc bx
    cmp bl, [custom_dir_count]
    jb .check_custom_loop
    
.not_found:
    call newline
    mov si, str_no_dir
    call print
    ret

.found_custom:
    add bl, 5
    mov [current_dir], bl
    call newline
    ret
    
.to_parent:
    mov byte [current_dir], 0
    call newline
    ret
    
.to_root:
    mov byte [current_dir], 0
    call newline
    ret
    
.to_home:
    mov byte [current_dir], 1
    call newline
    ret
    
.to_docs:
    mov byte [current_dir], 2
    call newline
    ret
    
.to_src:
    mov byte [current_dir], 3
    call newline
    ret
    
.to_bin:
    mov byte [current_dir], 4
    call newline
    ret
    
.done_no_change:
    call newline
    ret

cmd_pwd_handler:
    call newline
    mov al, [current_dir]
    cmp al, 0
    je .root
    cmp al, 1
    je .home
    cmp al, 2
    je .docs
    cmp al, 3
    je .src
    cmp al, 4
    je .bin
.root:
    mov si, path_root
    jmp .print
.home:
    mov si, path_home
    jmp .print
.docs:
    mov si, path_docs
    jmp .print
.src:
    mov si, path_src
    jmp .print
.bin:
    mov si, path_bin
    jmp .print
.print:
    call print
    call newline
    ret

cmd_cat_handler:
    call newline
    mov si, term_buffer
    add si, 4
    ; Skip spaces
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si
    cmp byte [si], 0
    je .no_file
    ; Check which file in current directory
    mov al, [current_dir]
    cmp al, 2  ; docs directory
    jne .not_docs
    mov di, file_readme_name
    call strcmp
    je .show_readme
    mov di, file_manual_name
    call strcmp
    je .show_manual
    ; Check user-created files in docs
    push si
    xor bx, bx
    mov cl, [file_count]
    xor ch, ch
.check_user_files:
    push cx
    push bx
    mov ax, bx
    mov cx, 2112
    mul cx
    mov di, file_storage
    add di, ax
    cmp byte [di], 2  ; Check if in docs
    jne .skip_check
    inc di
    add di, 6  ; Skip /docs/ prefix
    pop bx
    push bx
    push di
    mov si, [esp+8]  ; Get original filename pointer
    call strcmp
    pop di
    je .show_user_file
.skip_check:
    pop bx
    inc bx
    pop cx
    loop .check_user_files
    pop si
    jmp .not_found
.show_user_file:
    pop bx
    pop cx
    pop si
    ; Calculate file content position
    mov ax, bx
    mov cx, 2112
    mul cx
    mov si, file_storage
    add si, ax
    add si, 65  ; Skip marker + filename
    call print
    ret
.not_docs:
    cmp al, 3  ; src directory
    jne .not_src
    mov di, file_hello_c_name
    call strcmp
    je .show_hello_c
.not_src:
.not_found:
    mov si, str_file_not_found
    call print
    ret
.no_file:
    mov si, str_cat_usage
    call print
    ret
.show_readme:
    mov si, content_readme
    call print
    ret
.show_manual:
    mov si, content_manual
    call print
    ret
.show_hello_c:
    mov si, content_hello_c
    call print
    ret

cmd_gcc_handler:
    call newline
    mov si, term_buffer
    add si, 4
    ; Skip spaces
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si
    cmp byte [si], 0
    je .no_file
    ; Simple simulation: check if .c file exists in src
    mov al, [current_dir]
    cmp al, 3
    jne .wrong_dir
    mov di, file_hello_c_name
    call strcmp
    je .compile_hello
    mov di, file_main_c_name
    call strcmp
    je .compile_main
    mov si, str_gcc_not_found
    call print
    ret
.no_file:
    mov si, str_gcc_usage
    call print
    ret
.wrong_dir:
    mov si, str_gcc_wrong_dir
    call print
    ret
.compile_hello:
    mov si, str_gcc_compiling
    call print
    mov si, file_hello_c_name
    call print
    call newline
    mov si, str_gcc_success
    call print
    ret
.compile_main:
    mov si, str_gcc_compiling
    call print
    mov si, file_main_c_name
    call print
    call newline
    mov si, str_gcc_success
    call print
    ret

sound_test:
    call newline
    mov si, str_sound_header
    call print
    call newline
    mov si, str_sound_do
    call print
    mov ax, 262  ; C (Do)
    call play_tone
    call newline
    mov si, str_sound_re
    call print
    mov ax, 294  ; D (Re)
    call play_tone
    call newline
    mov si, str_sound_mi
    call print
    mov ax, 330  ; E (Mi)
    call play_tone
    call newline
    mov si, str_sound_fa
    call print
    mov ax, 349  ; F (Fa)
    call play_tone
    call newline
    mov si, str_sound_so
    call print
    mov ax, 392  ; G (So)
    call play_tone
    call newline
    mov si, str_sound_la
    call print
    mov ax, 440  ; A (La)
    call play_tone
    call newline
    mov si, str_sound_ti
    call print
    mov ax, 494  ; B (Ti)
    call play_tone
    call newline
    mov si, str_sound_do2
    call print
    mov ax, 523  ; C (Do)
    call play_tone
    call newline
    ret

play_tone:
    push ax
    push bx
    push cx
    push dx
    mov bx, ax
    mov al, 0xB6
    out 0x43, al
    mov dx, 0x12
    mov ax, 0x34DC
    div bx
    out 0x42, al
    mov al, ah
    out 0x42, al
    in al, 0x61
    or al, 0x03
    out 0x61, al
    ; Short delay
    mov cx, 0x2000
.delay:
    loop .delay
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    pop dx
    pop cx
    pop bx
    pop ax
    ret

system_beep:
    mov ax, 800
    call play_tone
    ret

tsharp_handler:
    call newline
    mov si, str_tsharp_welcome
    call print
    call newline
    mov si, str_tsharp_version
    call print
    call newline
    mov si, str_tsharp_help
    call print
    ret

tsharp_compile_handler:
    call newline
    mov si, term_buffer
    add si, 8
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si
    cmp byte [si], 0
    je .no_file
    ; Check if we're in src directory
    mov al, [current_dir]
    cmp al, 3
    jne .wrong_dir
    ; Simulate compilation
    mov si, str_tsharp_compiling
    call print
    call newline
    mov si, str_tsharp_lexer
    call print
    call newline
    mov si, str_tsharp_parser
    call print
    call newline
    mov si, str_tsharp_codegen
    call print
    call newline
    mov si, str_tsharp_linking
    call print
    call newline
    mov si, str_tsharp_success
    call print
    ret
.no_file:
    mov si, str_tsharp_usage
    call print
    ret
.wrong_dir:
    mov si, str_tsharp_wrong_dir
    call print
    ret

tsharp_run_handler:
    call newline
    mov si, term_buffer
    add si, 4
.skip_spaces:
    lodsb
    cmp al, ' '
    je .skip_spaces
    dec si
    cmp byte [si], 0
    je .no_prog
    mov si, str_tsharp_running
    call print
    call newline
    mov si, str_tsharp_output
    call print
    ret
.no_prog:
    mov si, str_tsharp_run_usage
    call print
    ret

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
    mov si, help_fs_header
    call print
    mov si, help_ls
    call print
    mov si, help_cd
    call print
    mov si, help_pwd
    call print
    mov si, help_cat
    call print
    mov si, help_gcc_cmd
    call print
    call newline
    mov si, help_basic_header
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
    ; Store directory marker (2 for docs)
    mov byte [di], 2
    inc di
    ; Store filename with /docs/ prefix
    push di
    mov si, path_docs_prefix
    mov cx, 6
    rep movsb
    pop di
    add di, 6
    mov si, temp_filename
    mov cx, 58
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
    mov si, str_file_saved_docs
    call print
    mov si, temp_filename
    call print
    mov si, str_to_docs
    call print
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
    inc si  ; Skip directory marker
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
    add si, 65  ; Skip marker + filename (1 + 64)
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
    cmp al, 'a'
    jb .no_upper1
    cmp al, 'z'
    ja .no_upper1
    sub al, 32
.no_upper1:
    mov bl, [di]
    inc di
    cmp bl, 'a'
    jb .no_upper2
    cmp bl, 'z'
    ja .no_upper2
    sub bl, 32
.no_upper2:
    cmp al, bl
    jne .ne
    test al, al
    jnz .loop
    ; Strings match - return 1
    pop di
    pop si
    mov al, 1
    ret
.ne:
    ; Strings don't match - return 0
    pop di
    pop si
    xor al, al
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
art_line8 db '         Ultimate Edition v1.3.0                ', 13, 10, 0

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
desktop_art8 db '             VERSION 1.3.0              ', 13, 10, 0

welcome_msg db 'Welcome! (c) HBREW Inc.', 13, 10, 0
str_date db 'Date: ', 0

menu1 db '1-Write      2-Docs        3-Calc ', 13, 10, 0
menu2 db '4-Games      5-Terminal    6-SysInfo ', 13, 10, 0
menu3 db '        7-Mods       8-Logout', 13, 10, 0
menu4 db 0

select_prompt db 'Select: ', 0

term_header db 'THINK OS TERMINAL - FILESYSTEM READY', 13, 10, 0
term_ready db 'Type HELP for commands', 13, 10, 0

; Terminal prompts for different directories
prompt_root db 'root@thinkos:/ ] ', 0
prompt_home db 'root@thinkos:/home ] ', 0
prompt_docs db 'root@thinkos:/docs ] ', 0
prompt_src db 'root@thinkos:/src ] ', 0
prompt_bin db 'root@thinkos:/bin ] ', 0
prompt_custom_pre db 'root@thinkos:/', 0
prompt_custom_post db ' ] ', 0

; Filesystem commands
cmd_ls db 'LS', 0
cmd_cd db 'CD', 0
cmd_pwd db 'PWD', 0
cmd_mkdir db 'MKDIR', 0
cmd_touch db 'TOUCH', 0
cmd_rm db 'RM', 0
cmd_cat db 'CAT', 0
cmd_gcc db 'GCC', 0
cmd_make db 'MAKE', 0
cmd_vim db 'VIM', 0
cmd_edit db 'EDIT', 0
cmd_clear db 'CLEAR', 0
cmd_echo db 'ECHO', 0
cmd_date db 'DATE', 0
cmd_uname db 'UNAME', 0
cmd_whoami db 'WHOAMI', 0
cmd_ps db 'PS', 0
cmd_df db 'DF', 0
cmd_free db 'FREE', 0
cmd_top db 'TOP', 0
cmd_sound db 'SOUND', 0
cmd_beep db 'BEEP', 0
cmd_tree db 'TREE', 0
cmd_history db 'HISTORY', 0
cmd_uptime db 'UPTIME', 0
cmd_nano db 'NANO', 0
cmd_grep db 'GREP', 0
cmd_find db 'FIND', 0
cmd_which db 'WHICH', 0
cmd_man db 'MAN', 0
cmd_alias db 'ALIAS', 0
cmd_env db 'ENV', 0
cmd_tsharp db 'T#', 0
cmd_compile db 'COMPILE', 0
cmd_run_prog db 'RUN', 0
cmd_ping db 'PING', 0
cmd_ifconfig db 'IFCONFIG', 0
cmd_netstat db 'NETSTAT', 0
cmd_curl db 'CURL', 0
cmd_wget db 'WGET', 0
cmd_ssh db 'SSH', 0
cmd_telnet db 'TELNET', 0
cmd_ftp db 'FTP', 0
cmd_tar db 'TAR', 0
cmd_zip db 'ZIP', 0
cmd_unzip db 'UNZIP', 0
cmd_gzip db 'GZIP', 0
cmd_gunzip db 'GUNZIP', 0
cmd_chmod db 'CHMOD', 0
cmd_chown db 'CHOWN', 0
cmd_kill db 'KILL', 0
cmd_killall db 'KILLALL', 0
cmd_reboot db 'REBOOT', 0
cmd_shutdown db 'SHUTDOWN', 0
cmd_halt db 'HALT', 0
cmd_dmesg db 'DMESG', 0
cmd_lsmod db 'LSMOD', 0
cmd_modprobe db 'MODPROBE', 0
cmd_mount db 'MOUNT', 0
cmd_umount db 'UMOUNT', 0
cmd_fdisk db 'FDISK', 0
cmd_mkfs db 'MKFS', 0
cmd_fsck db 'FSCK', 0
cmd_du db 'DU', 0
cmd_quota db 'QUOTA', 0
cmd_jobs db 'JOBS', 0
cmd_bg db 'BG', 0
cmd_fg db 'FG', 0
cmd_screen db 'SCREEN', 0
cmd_tmux db 'TMUX', 0
cmd_less db 'LESS', 0
cmd_more db 'MORE', 0
cmd_head db 'HEAD', 0
cmd_tail db 'TAIL', 0
cmd_sort db 'SORT', 0
cmd_uniq db 'UNIQ', 0
cmd_wc db 'WC', 0
cmd_diff db 'DIFF', 0
cmd_patch db 'PATCH', 0
cmd_sed db 'SED', 0
cmd_awk db 'AWK', 0

; Directory and file names
dir_home db 'home/', 13, 10, 0
dir_docs db 'docs/', 13, 10, 0
dir_src db 'src/', 13, 10, 0
dir_bin db 'bin/', 13, 10, 0

dir_home_name db 'home', 0
dir_docs_name db 'docs', 0
dir_src_name db 'src', 0
dir_bin_name db 'bin', 0

str_dotdot db '..', 0
str_slash db '/', 0

; Files in /home
file_bashrc db '.bashrc', 13, 10, 0
file_profile db '.profile', 13, 10, 0

; Files in /docs
file_readme db 'README.txt', 13, 10, 0
file_manual db 'MANUAL.txt', 13, 10, 0
file_readme_name db 'README.txt', 0
file_manual_name db 'MANUAL.txt', 0

; Files in /src
file_hello_c db 'hello.c', 13, 10, 0
file_main_c db 'main.c', 13, 10, 0
file_makefile db 'Makefile', 13, 10, 0
file_hello_c_name db 'hello.c', 0
file_main_c_name db 'main.c', 0

; Files in /bin
file_hello db 'hello*', 13, 10, 0
file_main db 'main*', 13, 10, 0

; Paths
path_root db '/', 13, 10, 0
path_home db '/home', 13, 10, 0
path_docs db '/docs', 13, 10, 0
path_src db '/src', 13, 10, 0
path_bin db '/bin', 13, 10, 0
path_docs_prefix db '/docs/', 0

; File contents
content_readme db '=== THINK OS README ===', 13, 10, 'Welcome to Think OS v1.3.0!', 13, 10, 'A complete OS with filesystem.', 13, 10, 13, 10, 0
content_manual db '=== USER MANUAL ===', 13, 10, 'Commands: ls, cd, pwd, cat', 13, 10, 'GCC: gcc filename.c', 13, 10, 13, 10, 0
content_hello_c db '#include <stdio.h>', 13, 10, 'int main() {', 13, 10, '  printf("Hello World!");', 13, 10, '  return 0;', 13, 10, '}', 13, 10, 0

; Command messages
str_no_dir db 'Directory not found', 13, 10, 0
str_file_not_found db 'File not found', 13, 10, 0
str_cat_usage db 'Usage: cat <filename>', 13, 10, 0
str_mkdir_msg db 'mkdir: Directory created (simulated)', 13, 10, 0
str_mkdir_usage db 'Usage: mkdir <dirname>', 13, 10, 0
str_mkdir_success db 'Directory created!', 13, 10, 0
str_mkdir_full db 'Too many directories (max 10)', 13, 10, 0
str_empty_dir db '(empty directory)', 13, 10, 0
str_slash_newline db '/', 13, 10, 0
str_touch_msg db 'touch: File created (simulated)', 13, 10, 0
str_rm_msg db 'rm: File removed (simulated)', 13, 10, 0
str_gcc_usage db 'Usage: gcc <file.c>', 13, 10, 0
str_gcc_wrong_dir db 'gcc: Must be in /src directory', 13, 10, 0
str_gcc_not_found db 'gcc: Source file not found', 13, 10, 0
str_gcc_compiling db 'Compiling: ', 0
str_gcc_success db 'Compilation successful!', 13, 10, 0
str_make_msg db 'make: Build complete!', 13, 10, 0
str_vim_msg db 'vim: Editor mode (ESC to exit)', 13, 10, 0
str_edit_usage db 'Usage: edit <filename>', 13, 10, 0
str_edit_wrong_dir db 'edit: Must be in /docs directory', 13, 10, 0
str_edit_not_found db 'edit: File not found in /docs', 13, 10, 0
str_edit_header db '=== FILE EDITOR ===', 13, 10, 0
str_edit_info db 'Edit file (ESC to save):', 13, 10, 0
str_edit_saved db 'File saved successfully!', 13, 10, 0

; New command outputs
str_uname db 'ThinkOS 1.3.0 x86_16 i686', 13, 10, 0
str_whoami db 'root', 13, 10, 0
str_ps db 'PID  CMD', 13, 10, '  1  init', 13, 10, '  2  terminal', 13, 10, '  3  desktop', 13, 10, 0
str_df db 'Filesystem  Size  Used  Avail', 13, 10, '/dev/mem0   640K  256K  384K', 13, 10, 0
str_free db 'Total: 640K  Used: 256K  Free: 384K', 13, 10, 0
str_top db 'CPU: 100%  MEM: 40%  Processes: 3', 13, 10, 0
str_tree db '.', 13, 10, '|-- home/', 13, 10, '|-- docs/', 13, 10, '|-- src/', 13, 10, '`-- bin/', 13, 10, 0
str_history db '1: ls', 13, 10, '2: cd docs', 13, 10, '3: pwd', 13, 10, 0
str_uptime db 'System uptime: 00:15:42', 13, 10, 0
str_nano db 'nano: Text editor (use EDIT)', 13, 10, 0
str_grep db 'grep: Pattern search tool', 13, 10, 0
str_find db 'find: Search for files', 13, 10, 0
str_which db 'which: Locate command', 13, 10, 0
str_man db 'man: Manual pages (use HELP)', 13, 10, 0
str_alias db 'alias: Command aliases', 13, 10, 0
str_env db 'PATH=/bin:/src', 13, 10, 'HOME=/home', 13, 10, 'USER=root', 13, 10, 0

; T# Programming Language
str_tsharp_welcome db '=== T# Programming Language ===', 13, 10, 0
str_tsharp_version db 'T# Compiler v1.0 for ThinkOS', 13, 10, 0
str_tsharp_help db 'Commands: COMPILE <file.ts>, RUN <prog>', 13, 10, 0
str_tsharp_usage db 'Usage: COMPILE <file.ts>', 13, 10, 0
str_tsharp_wrong_dir db 'compile: Must be in /src directory', 13, 10, 0
str_tsharp_compiling db '[T# Compiler] Starting compilation...', 13, 10, 0
str_tsharp_lexer db '[Lexer] Tokenizing source code...', 0
str_tsharp_parser db '[Parser] Building AST...', 0
str_tsharp_codegen db '[CodeGen] Generating bytecode...', 0
str_tsharp_linking db '[Linker] Linking libraries...', 0
str_tsharp_success db '[Success] Compilation complete!', 13, 10, 0
str_tsharp_run_usage db 'Usage: RUN <program>', 13, 10, 0
str_tsharp_running db '[T# Runtime] Executing program...', 13, 10, 0
str_tsharp_output db 'Hello from T#! Output: 42', 13, 10, 0

; Network commands
str_ping db 'PING 192.168.1.1: 64 bytes time=1ms', 13, 10, 0
str_ifconfig db 'eth0: 192.168.1.100', 13, 10, '      netmask 255.255.255.0', 13, 10, 0
str_netstat db 'Active connections:', 13, 10, 'TCP  0.0.0.0:80  LISTEN', 13, 10, 0
str_curl db 'curl: Transfer data from URL', 13, 10, 0
str_wget db 'wget: Download files', 13, 10, 0
str_ssh db 'ssh: Secure shell client', 13, 10, 0
str_telnet db 'telnet: Remote terminal', 13, 10, 0
str_ftp db 'ftp: File transfer protocol', 13, 10, 0

; Archive commands
str_tar db 'tar: Archive utility', 13, 10, 0
str_zip db 'zip: Compress files', 13, 10, 0
str_unzip db 'unzip: Extract archives', 13, 10, 0
str_gzip db 'gzip: GNU zip compression', 13, 10, 0
str_gunzip db 'gunzip: Decompress gzip', 13, 10, 0

; Permission commands
str_chmod db 'chmod: Change file mode', 13, 10, 0
str_chown db 'chown: Change owner', 13, 10, 0

; Process commands
str_kill db 'kill: Terminate process', 13, 10, 0
str_killall db 'killall: Kill by name', 13, 10, 0
str_jobs db 'No background jobs', 13, 10, 0
str_bg db 'bg: Background process', 13, 10, 0
str_fg db 'fg: Foreground process', 13, 10, 0

; System commands
str_dmesg db '[0.000] ThinkOS kernel boot', 13, 10, '[0.100] CPU detected', 13, 10, 0
str_lsmod db 'Module      Size', 13, 10, 'filesystem  4096', 13, 10, 0
str_modprobe db 'modprobe: Load kernel module', 13, 10, 0

; Disk commands
str_mount db '/dev/sda1 on / type ext4', 13, 10, 0
str_umount db 'umount: Unmount filesystem', 13, 10, 0
str_fdisk db 'fdisk: Partition editor', 13, 10, 0
str_mkfs db 'mkfs: Make filesystem', 13, 10, 0
str_fsck db 'fsck: Filesystem check OK', 13, 10, 0
str_du db 'Disk usage: 256K', 13, 10, 0
str_quota db 'Disk quota: unlimited', 13, 10, 0

; Terminal multiplexers
str_screen db 'screen: Terminal multiplexer', 13, 10, 0
str_tmux db 'tmux: Terminal multiplexer', 13, 10, 0

; Text processing
str_less db 'less: File pager', 13, 10, 0
str_more db 'more: File pager', 13, 10, 0
str_head db 'head: Output first lines', 13, 10, 0
str_tail db 'tail: Output last lines', 13, 10, 0
str_sort db 'sort: Sort lines', 13, 10, 0
str_uniq db 'uniq: Remove duplicates', 13, 10, 0
str_wc db 'wc: Word count', 13, 10, 0
str_diff db 'diff: Compare files', 13, 10, 0
str_patch db 'patch: Apply diff', 13, 10, 0
str_sed db 'sed: Stream editor', 13, 10, 0
str_awk db 'awk: Pattern scanning', 13, 10, 0

; Sound test strings
str_sound_header db '=== SOUND TEST - Musical Scale ===', 13, 10, 0
str_sound_do db 'Playing Do (C)...', 0
str_sound_re db 'Playing Re (D)...', 0
str_sound_mi db 'Playing Mi (E)...', 0
str_sound_fa db 'Playing Fa (F)...', 0
str_sound_so db 'Playing So (G)...', 0
str_sound_la db 'Playing La (A)...', 0
str_sound_ti db 'Playing Ti (B)...', 0
str_sound_do2 db 'Playing Do (C - High)...', 0

; BASIC commands
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

help_header db '=== AVAILABLE COMMANDS ===', 13, 10, 0
help_fs_header db 13, 10, 'FILESYSTEM:', 13, 10, 0
help_ls db '  ls - List files/folders', 13, 10, 0
help_cd db '  cd <dir> - Change directory', 13, 10, 0
help_pwd db '  pwd - Print working directory', 13, 10, 0
help_cat db '  cat <file> - View file', 13, 10, 0
help_gcc_cmd db '  gcc <file.c> - Compile C', 13, 10, 0
help_basic_header db 13, 10, 'FILE OPERATIONS:', 13, 10, 0
help_list db '  mkdir <name> - Create dir', 13, 10, 0
help_run db '  edit <file> - Edit file', 13, 10, 0
help_new db 13, 10, 'SYSTEM:', 13, 10, 0
help_auto db '  clear, echo, date, sound', 13, 10, 0
help_home db '  uname, whoami, ps, df, free', 13, 10, 0
help_print db '  Type "exit" to return', 13, 10, 0
help_hello db 0
help_neofetch db 0
help_exit db 0

neo_art1 db '@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 13, 10, 0
neo_art2 db '@@@@   THINK OS v1.3.0  @@@@', 13, 10, 0
neo_art3 db '@@@@    FILESYSTEM ED.  @@@@', 13, 10, 0
neo_art4 db '@@@@   (C) HBREW 2025   @@@@', 13, 10, 0
neo_art5 db '@@@@    ELIAN J.        @@@@', 13, 10, 0
neo_art6 db '@@@@@@@@@@@@@@@@@@@@@@@@@@@@', 13, 10, 0

neo_info_line1 db 'OS: Think OS v1.3.0 Filesystem', 13, 10, 0
neo_info_line2 db 'Shell: BASIC + Unix Shell', 13, 10, 0
neo_info_line3 db 'CPU: Intel x86 Compatible', 13, 10, 0
neo_info_line4 db 'Memory: 640K + Extended', 13, 10, 0
neo_info_line5 db 'Features: VFS, GCC, Games', 13, 10, 0
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
str_file_saved_docs db 'File saved to /docs/: ', 0
str_to_docs db ' in /docs/', 13, 10, 0

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
sysinfo_header5 db ' |              Version 1.3.0               |', 0
sysinfo_header6 db ' |            (C) HBREW Inc.                |', 0
sysinfo_header7 db ' |            Made by Elian J.              |', 0
sysinfo_header8 db ' +==========================================+', 0
sysinfo_os db 'Think OS v1.3.0 Filesystem', 13, 10, 0
sysinfo_ver db '(c) HBREW Inc. 2025', 13, 10, 0

mods_header db 'MODS CENTER', 13, 10, 0
mods_coming db 'Mods ready!', 13, 10, 0

str_press_key db 'Press key...', 0
str_goodbye db 'Goodbye from Think OS!', 13, 10, 0
str_shutdown_options db '1) Reboot  2) Shutdown: ', 0
str_safe_shutdown db 'System halted. Safe to power off.', 13, 10, 0

times 32768-($-$) db 0