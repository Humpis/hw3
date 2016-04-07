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
