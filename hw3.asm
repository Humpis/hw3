 # Homework #3
 # name: Vidar Minkovsky
 # sbuid: 109756598


##############################
#
# TEXT SECTION
#
##############################
 .text

##############################
# PART I FUNCTIONS
##############################

##############################
# This function reads a byte at a time from the file and puts it
# into the appropriate position into the MMIO with the correct
# FG and BG color.
# The function begins each time at position [0,0].
# If a newline character is encountered, the function must
# populate the rest of the row in the MMIO with the spaces and
# then continue placing the bytes at the start of the next row.
#
# @param fd file descriptor of the file.
# @param BG four-bit value indicating background color
# @param FG four-bit value indication foreground color
# @return int 1 means EOF has not been encountered yet, 0 means
# EOF reached, -1 means invalid file.
##############################
load_code_chunk:
	bne $a0, 0xffffffff, load_code_chunk_valid	# if file desc is non meg, go for it
	li $v0, -1					# return -1
	j load_code_chunk_read_loop_done
	
load_code_chunk_valid:
	blt $a1, 0, load_code_chunk_bgdefault		# if its out of bounds, set it to default color
	bgt $a1, 15, load_code_chunk_bgdefault
	
load_code_chunk_bgdone:
	blt $a2, 0, load_code_chunk_fgdefault		# if its out of bounds, set it to default color
	bgt $a2, 15, load_code_chunk_fgdefault
	
load_code_chunk_fgdone:	
	sll $a1, $a1, 4
	add $s0, $a1, $a2				# set s0 to color
	li $s1, 0					# number of bytes in the line
	li $s2, 0					# number of bytes in all lines
	li $s3, 0xffff0000				# current storage pointer
	
load_code_chunk_read_loop:
	li   $v0, 14       				# system call for read from file
 	#move $a0, $a0      				# file descriptor 
 	la   $a1, buffer   				# address of buffer from which to write
  	li   $a2, 1       				# hardcoded buffer length
  	syscall            				# read from file
  	lb $t1, buffer					# set t1 to the letter read
  	beq $s2, 4000, load_code_chunk_read_loop_done	# when the screen is full
  	beq $t1, '\n', load_code_chunk_newline		# if it reads \n, put in spaces and go to next line
  	sb $t1, ($s3)					# store the ascii letter
  	addi $s3, $s3, 1				# increment storage pointer
  	sb $s0, ($s3)					# store the color 
  	addi $s3, $s3, 1				# increment storage pointer
  	addi $s1, $s1, 2				# icrement line byte counter
  	addi $s2, $s2, 2				# icrement total byte counter
  	j load_code_chunk_read_loop			# loop to next letter
  	
load_code_chunk_newline:
	beq $s1, 160, load_code_chunk_newline_done
	li $t1, ' '					# put space in t1
	sb $t1, ($s3)					# store the ascii letter
  	addi $s3, $s3, 1				# increment storage pointer
  	sb $s0, ($s3)					# store the color 
  	addi $s3, $s3, 1				# increment storage pointer
  	addi $s1, $s1, 2				# icrement line byte counter
  	addi $s2, $s2, 2				# icrement total byte counter
	j load_code_chunk_newline
	
load_code_chunk_newline_done:
	li $s1, 0					# reset bytes in line counter
	j load_code_chunk_read_loop	
			
load_code_chunk_read_loop_done:
	jr $ra
	
load_code_chunk_bgdefault:
	li $a1, 15					# set bg to white
	j load_code_chunk_bgdone
	
load_code_chunk_fgdefault:
	li $a2, 0					# set fg to african american
	j load_code_chunk_fgdone	
		
##############################
# PART II FUNCTIONS
##############################

##############################
# This function should go through the whole memory array and clear the contents of the screen.
##############################
clear_screen:
	li $s0, 0x000000f0				# set s0 to white on black
	li $s2, 0					# number of bytes in all lines
	li $s3, 0xffff0000				# current storage pointer
clear_screen_loop:
	beq $s2, 4000, clear_screen_done
	li $t1, ' '					# put space in t1
	sb $t1, ($s3)					# store the ascii letter
  	addi $s3, $s3, 1				# increment storage pointer
  	sb $s0, ($s3)					# store the color 
  	addi $s3, $s3, 1				# increment storage pointer
  	addi $s2, $s2, 2				# icrement total byte counter
	j clear_screen_loop
	
clear_screen_done:
	jr $ra



##############################
# PART III FUNCTIONS
##############################

##############################
# This function updates the color specifications of the cell
# specified by the cell index. This function should not modify
# the text in any fashion.
#
# @param i row of MMIO to apply the cell color.
# @param j column of MMIO to apply the cell color.
# @param FG the four bit value specifying the foreground color
# @param BG the four bit value specifying the background color
##############################
apply_cell_color:
	li $t0, 0xffff0000				# base memory
	li $t1, 160					# for mult
	mul $a0, $a0, $t1				# set a0 to number of bytes of i
	li $t1, 2  					# for mult
	mul $a1, $a1, $t1				# set a1 to number of bytes of j
	add $t0, $t0, $a0				# add i bytes to base adress
	add $t0, $t0, $a1				# add i bytes to base adress
	addi $t0, $t0, 1				# add 1 byte to get to the color
	
	bge $a0, 0, apply_cell_color_igood		# i is greater than or = 0
	j apply_cell_color_done				# else return
	
apply_cell_color_igood:
	ble $a0, 24, apply_cell_color_igood2		# i is <= 24
	j apply_cell_color_done				# else return
	
apply_cell_color_igood2:
	bge $a1, 0, apply_cell_color_jgood		# j is >=0
	j apply_cell_color_done				# else return
	
apply_cell_color_jgood:
	ble $a1, 79, apply_cell_color_chk_fg		# j is <= 79
	j apply_cell_color_done				# else return

apply_cell_color_chk_fg:
	bge $a2, 0, apply_cell_color_fggood		# fg is greater than or = 0
	j apply_cell_color_chk_bg			# else go to bgcolor
	
apply_cell_color_fggood:
	ble $a2, 15, apply_cell_color_change_fg		# fg is <= 15
	j apply_cell_color_chk_bg			# else go to bgcolor
	
apply_cell_color_change_fg:
	lb $t2, ($t0)					# set t2 to the color in t0
	li $t3, 0x0000000f				# for anding
	and $t1, $t2, $t3				# set t2 to just the fg hex bit of the color
	sub $t2, $t2, $t1				# set t2 to just the bg color by subtracting the fg
	add $t2, $t2, $a2				# set t2 to the new color by adding the new fg
	sb $t2, ($t0)					# store the new color
	
apply_cell_color_chk_bg:
	bge $a3, 0, apply_cell_color_bggood		# bg is greater than or = 0
	j apply_cell_color_done				# else return
	
apply_cell_color_bggood:
	ble $a3, 15, apply_cell_color_change_bg		# bg is <= 15
	j apply_cell_color_done				# else return
	
apply_cell_color_change_bg:
	lb $t2, ($t0)					# set t2 to the color in t0
	li $t3, 0x000000f0				# for anding
	and $t1, $t2, $t3				# set t1 to just the bg hex bit of the color
	sub $t2, $t2, $t1				# set t2 to just the fg color by subtracting the bg
	sll $a3, $a3, 4					# shift the bg color
	add $t2, $t2, $a3				# set t2 to the new color by adding the new bg
	sb $t2, ($t0)					# store the new color
	
apply_cell_color_done:
	jr $ra


##############################
# This function goes through and clears any cell with oldBG color
# and sets it to the newBG color. It preserves the foreground
# color of the text that was present.
#
# @param oldBG old background color specs.
# @param newBG new background color defining the color specs
##############################
clear_background:
	li $t0, 0xffff0001				# base color memory
	blt $a0, 0, clear_background_done		# return if invalid bg
	bgt $a0, 15, clear_background_done		# return if invalid bg
	sll $a0, $a0, 4					# shift the bg to where its supposed to go
	blt $a1, 0, clear_background_default		# default if invalid newbg
	bgt $a1, 15, clear_background_default		# default if invalid newbg
	sll $a1, $a1, 4					# shift the newbg to where its supposed to go
	
clear_background_loop:
	li $t4, 0xffff0fa1
	beq $t0, $t4, clear_background_done		# reached end of mem
	lb $t2, ($t0)					# set t2 to the color in t0
	li $t3, 0x000000f0				# for anding
	and $t1, $t2, $t3				# set t1 to just the bg hex bit of the color
	beq $t1, $a0, clear_background_loop_valid	# if the bg and oldbg are =
	addi $t0, $t0, 2				# increment to next color byte
	j clear_background_loop
	
clear_background_loop_valid:	
	sub $t2, $t2, $t1				# set t2 to just the fg color by subtracting the bg
	add $t2, $t2, $a1				# set t2 to the new color by adding the new bg
	sb $t2, ($t0)					# store the new color
	addi $t0, $t0, 2				# increment to next color byte
	j clear_background_loop
	
clear_background_default:
	li $a1, 15					# set newbg to white 
	sll $a1, $a1, 4					# shift the newbg to where its supposed to go
	j clear_background_loop
	
clear_background_done:
	jr $ra


##############################
# This function will compare cmp_string to the string in the MMIO
# starting at position (i,j). If there is a match the function
# will return (1, length of the match).
#
# @param cmp_string start address of the string to look for in
# the MMIO
# @param i row of the MMIO to start string compare.
# @param j column of MMIO to start string compare.
# @return int length of match. 0 if no characters matched.
# @return int 1 for exact match, 0 otherwise
##############################
string_compare:
	jr $ra


##############################
# This function goes through the whole MMIO screen and searches
# for any string matches to the search_string provided by the
# user. This function should clear the old highlights first.
# Then it will call string_compare on each cell in the MMIO
# looking for a match. If there is a match it will apply the
# background color using the apply_cell_color function.
#
# @param search_string Start address of the string to search for
# in the MMIO.
# @param BG background color specs defining.
##############################
search_screen:
	jr $ra


##############################
# PART IV FUNCTIONS
##############################

##############################
# This function goes through the whole MMIO screen and searches
# for Java syntax keywords, operators, data types, etc and
# applies the appropriate color specifications for to that match.
##############################
apply_java_syntax:
	jr $ra


##############################
# This function goes through the whole MMIO screen finds any java
# comments and applies a blue foreground color to all of the text
# in that line.
##############################
apply_java_line_comments:
	jr $ra



##############################
#
# DATA SECTION
#
##############################
.data
#put the users search string in this buffer


.align 2
negative: .word -1

#java keywords red
java_keywords_public: .asciiz "public"
java_keywords_private: .asciiz "private"
java_keywords_import: .asciiz "import"
java_keywords_class: .asciiz "class"
java_keywords_if: .asciiz "if"
java_keywords_else: .asciiz "else"
java_keywords_for: .asciiz "for"
java_keywords_return: .asciiz "return"
java_keywords_while: .asciiz "while"
java_keywords_sop: .asciiz "System.out.println"
java_keywords_sop2: .asciiz "System.out.print"

.align 2
java_keywords: .word java_keywords_public, java_keywords_private, java_keywords_import, java_keywords_class, java_keywords_if, java_keywords_else, java_keywords_for, java_keywords_return, java_keywords_while, java_keywords_sop, java_keywords_sop2, negative

#java datatypes
java_datatype_int: .asciiz "int "
java_datatype_byte: .asciiz "byte "
java_datatype_short: .asciiz "short "
java_datatype_long: .asciiz "long "
java_datatype_char: .asciiz "char "
java_datatype_boolean: .asciiz "boolean "
java_datatype_double: .asciiz "double "
java_datatype_float: .asciiz "float "
java_datatype_string: .asciiz "String "

.align 2
java_datatypes: .word java_datatype_int, java_datatype_byte, java_datatype_short, java_datatype_long, java_datatype_char, java_datatype_boolean, java_datatype_double, java_datatype_float, java_datatype_string, negative

#java operators
java_operator_plus: .asciiz "+"
java_operator_minus: .asciiz "-"
java_operator_division: .asciiz "/"
java_operator_multiply: .asciiz "*"
java_operator_less: .asciiz "<"
java_operator_greater: .asciiz ">"
java_operator_and_op: .asciiz "&&"
java_operator_or_op: .asciiz "||"
java_operator_not_op: .asciiz "!="
java_operator_equal: .asciiz "="
java_operator_colon: .asciiz ":"
java_operator_semicolon: .asciiz ";"

.align 2
java_operators: .word java_operator_plus, java_operator_minus, java_operator_division, java_operator_multiply, java_operator_less, java_operator_greater, java_operator_and_op, java_operator_or_op, java_operator_not_op, java_operator_equal, java_operator_colon, java_operator_semicolon, negative

#java brackets
java_bracket_paren_open: .asciiz "("
java_bracket_paren_close: .asciiz ")"
java_bracket_square_open: .asciiz "["
java_bracket_square_close: .asciiz "]"
java_bracket_curly_open: .asciiz "{"
java_bracket_curly_close: .asciiz "}"

.align 2
java_brackets: .word java_bracket_paren_open, java_bracket_paren_close, java_bracket_square_open, java_bracket_square_close, java_bracket_curly_open, java_bracket_curly_close, negative

java_line_comment: .asciiz "//"

.align 2
user_search_buffer: .space 101
buffer: .space 1
