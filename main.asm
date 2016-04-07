
# Helper macro for grabbing two command line arguments
.macro load_two_args
	lw $t0, 0($a1)
	sw $t0, arg1
	lw $t0, 4($a1)
	sw $t0, arg2
.end_macro

# Helper macro for grabbing one command line argument
.macro load_one_arg
	lw $t0, 0($a1)
	sw $t0, arg1
.end_macro

############################################################################
##
##  TEXT SECTION
##
############################################################################
.text
.globl main

main:
#check if command line args are provided
#if zero command line arguments are provided exit
beqz $a0, exit_program
li $t0, 1
#check if only one command line argument is given and call marco to save them
beq $t0, $a0, one_arg
#else save the two command line arguments
load_two_args()
j done_saving_args

#if there is only one arg, call macro to save it
one_arg:
	load_one_arg()

#you are done saving args now, start writing your code.
done_saving_args:
	lw $a0, arg1		# put the filename into a0
	#lw $t9, 3($a0)
	#addi $a0, $a0, -5
	li $a1, 0		# 0 for read		
	li $a2, 0		# ignore mode
	li $v0, 13		# syscall for open file
	syscall
	move $a0, $v0		# store the file discriptor in a0
	move $s7, $v0		# store the file discriptor in s0 for closing
	li $a1, 6		# store variable background color in a1 [0-15]
	li $a2, 9		# store variable foreground color in a2 [0-15]
	jal load_code_chunk
	li   $v0, 16       	# system call for close file
  	move $a0, $s7     	# file descriptor to close
  	syscall           	# close file
  	j clear_screen
exit_program:
li $v0, 10
syscall

############################################################################
##
##  DATA SECTION
##
############################################################################
.data

.align 2

#for arguments read in
arg1: .word 0
arg2: .word 0

#prompts to display asking for user input
prompt: .asciiz "\nSpace or Enter to continue\n'q' to Quit\n'/' to search for text\n: "
search_prompt: .asciiz "\nEnter search string: "




#################################################################
# Student defined functions will be included starting here
#################################################################

.include "hw3.asm"
