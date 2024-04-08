.text               
.globl  main            

main:
    j draw
display:
    jal displayBoard
finishDisplaying:
    jal input_playerOne
gameOver:
    li $v0, 10
    syscall 



draw:
    addi $s1, $zero, 42 
    la $s2, board  
    li $s3, 0      
    subi $t3, $s3, 42
    la $t2, space
    lb $t1, 0($t2)    
    j drawLoop      


drawLoop:
    subi $t3, $s3, 42
    bge $t3, $zero, display
    sb  $t1, 0($s2) 
    addi $s2, $s2, 1   
    addi $s3, $s3, 1  
    j drawLoop



displayBoard:
    li $s4, 0   
    li $s5, 0    
    j loop_toDisplayRow  
loopingRow_return:
    jr $ra         

loop_toDisplayRow:
    bnez $s4, not_beginingRow    
    li $v0, 4
    la $a0, row               
    syscall
not_beginingRow:
    li $s5, 0     
    j loop_toDisplayColumn
loopingCol_return:
    subi $t4, $s4, 5
    beq $t4, $zero, finish_rowLoop 
    li $v0, 4              
    la $a0, row      
    syscall                  
    addi $s4, $s4, 1       
    j loop_toDisplayRow

finish_rowLoop:
    li $v0, 4       
    la $a0, rowLast   
    syscall         
    j loopingRow_return

loop_toDisplayColumn:
    bnez $s5, not_beginningCol 
    li $v0, 11      
    la $t2, border      
    lb $a0, 0($t2)     
    syscall      

not_beginningCol:
    li $v0, 11       
    la $t2, border     
    lb $a0, 0($t2)      
    syscall        
    la $t2, space    
    lb $a0, 0($t2)      
    syscall               
    add $a0, $s4, $zero    
    add $a1, $s5, $zero    
    sw $ra, 0($sp)     
    jal arr_idx        
    lw $ra, 0($sp)        
    add $s6, $v0, $zero      
    li $v0, 11          
    la $s7, board        
    add $s7, $s7, $s6     
    lb $a0, 0($s7)       
    syscall                
    la $t2, space       
    lb $a0, 0($t2)      
    syscall                 
    subi $t4, $s5, 6       
    beq $t4, 0, lastColumn      
    addi $s5, $s5, 1          
    j loop_toDisplayColumn     

lastColumn:
    li $v0, 4            
    la $a0, pattern     
    syscall               
    j loopingCol_return       


arr_idx:
    add $t0, $a0, $zero 
    add $v0, $a1, $zero 
idxLoop:
    ble $t0, $zero, idxLoopEnd
    addi $v0, $v0, 7         
    subi $t0, $t0, 1        
    j idxLoop              
idxLoopEnd:
    jr $ra                   



input_playerOne:
    li $v0, 4            
    la $a0, playerOne_turn    
    syscall                   
    li $v0, 5              
    syscall                   
    add $a1, $v0, $zero    
    j check_playerOne     



input_playerTwo:
    li $v0, 4              
    la $a0, playerTwo_turn    
    syscall                   
    li $v0, 5                
    syscall                   
    add $a1, $v0, $zero   
    li $a2, 2      
    j check_playerTwo      


check_playerOne:
    sw $ra, 0($sp)         
    jal is_idxOK                
    lw $ra, 0($sp)            
    add $t3, $v0, $zero		
    li $a2, 1				
    bne $t3, $zero, invalidIndex    
    sw $ra, 0($sp)              
    jal availableSpace       
    lw $ra, 0($sp)           
    li $t3, -1			
    add $a0, $v0, $zero
    li $a2, 1				
    beq $a0, $t3, invalidSpace    
    sw $ra, 0($sp)         
    jal arr_idx            
    lw $ra, 0($sp)         
    la $t2, playerOne       
    lb $t1, 0($t2)          
    addi $s6, $v0, 0
    la $s7, board           
    add $s7, $s7, $s6         
    sb $t1, 0($s7)             
    add $a3, $t1, $zero		
    li $a2, 1				
    sw $ra, 0($sp)          
    jal winning             
    lw $ra, 0($sp)          
    li $t4, 1				
    beq $t4, $v0, gameOver      
    li $a0, 1				
    j switchSide              


check_playerTwo:
    sw $ra, 0($sp)         
    jal is_idxOK           
    lw $ra, 0($sp)            
    add $t3, $v0, $zero        
    li $a2, 2                  
    bne $t3, $zero, invalidIndex    
    sw $ra, 0($sp)              
    jal availableSpace          
    lw $ra, 0($sp)             
    li $t3, -1                  
    add $a0, $v0, $zero         
    li $a2, 2                     
    beq $a0, $t3, invalidSpace   
    sw $ra, 0($sp)              
    jal arr_idx                
    lw $ra, 0($sp)              
    la $t2, playerTwo          
    lb $t1, 0($t2)            
    add $s6, $v0, $zero     
    la $s7, board           
    add $s7, $s7, $s6        
    sb $t1, 0($s7)             
    addi $a3, $t1, 0
    li $a2, 2               
    sw $ra, 0($sp)         
    jal winning           
    lw $ra, 0($sp)       
    li $t4, 1             
    beq $t4, $v0, gameOver         
    li $a0, 2             
    j switchSide          


is_idxOK:
    slti $v0, $a1, 0
    bne $v0, $0, indexReturn  
    add $t0, $a1, $zero          
    subi $t0, $t0, 6      
    slt $v0, $0, $t0    
indexReturn:
    jr $ra         

invalidIndex:
violateCheck:
	addi $t0, $a2, -1
	sll $t0, $t0, 2
	lw $t1, violate($t0)
	addi $t1, $t1, 1
	beq $t1, 3, lose
	sw $t1, violate($t0)
	beq $a2, 1, input_playerOne
	beq $a2, 2, input_playerTwo
	lose:
		beq $a2, 1, oneViolate
		beq $a2, 2, twoViolate
	oneViolate:
		li $a2, 2
		j p2Wins
	twoViolate:
		li $a2,1
		j winner
		
    li $v0, 4                 
    la $a0, invalidNumber     
    syscall                     
    li $t2, 2             
    beq $a2, $t2, input_playerTwo    
    j input_playerOne            



invalidSpace:
	violateCheck2:
	addi $t0, $a2, -1
	sll $t0, $t0, 2
	lw $t1, violate($t0)
	addi $t1, $t1, 1
	beq $t1, 3, lose
	sw $t1, violate($t0)
	beq $a2, 1, input_playerOne
	beq $a2, 2, input_playerTwo
	lose2:
		beq $a2, 1, oneViolate2
		beq $a2, 2, twoViolate2
	oneViolate2:
		li $a2, 2
		j p2Wins
	twoViolate2:
		li $a2,1
		j winner
    li $v0, 4                 
    la $a0, invalidNumber     
    syscall               
    addi $t2, $zero, 2      
    beq $a2, $t2, input_playerTwo  
    j input_playerOne     



availableSpace:
    li $a0, 5
spaceLoop:
    sw $ra, 0($sp)       
    jal arr_idx          
    lw $ra, 0($sp)       
    la $t2, space         
    lb $s5, 0($t2)          
    add $s6, $v0, $zero    
    li $v0, 11               
    la $s7, board            
    add $s7, $s7, $s6             
    lb $s4, 0($s7)                
    beq $s4, $s5, spaceAvailable    
    subi $a0, $a0, 1                 
    slti $t5, $a0, 0             
    bnez $t5, noSpaceAvailable    
    j spaceLoop                  



winning:
    add $s1, $a0, $zero       
    add $s2, $a1, $zero       
    sw $ra, 0($sp)            
    sw $a0, -4($sp)           
    sw $a1, -8($sp)         
    j horizontal          
horizontal_return:
    j vertical          
vertical_return:
    j diagonal         
diagonalRet:
    j tie            

horizontal:
    lw $s1, -4($sp)         
    li $s2, 0           
    li $s3, 0      
    j  horizontalLoop          

horizontalLoop:
    addi $t6, $s2, 0       
    subi $t6, $t6, 6       
    bgt $t6, $zero, horizontal_return     
    addi $a0, $s1, 0         
    addi $a1, $s2, 0         
    sw $ra, -12($sp)         
    jal arr_idx              
    lw $ra, -12($sp)         
    addi $s6, $v0, 0          
    la $s7, board             
    add $s7, $s7, $s6         
    lb $s4, 0($s7)           
    bne $a3, $s4, horizontal_reset    
    addi $s3, $s3, 1         
    subi $t4, $s3, 3          
    bgt $t4, $zero, winner       
    addi $s2, $s2, 1        
    j horizontalLoop       

horizontal_reset:
    li $s3, 0                     
    addi $s2, $s2, 1
    j horizontalLoop         

vertical:
    li $s3, 0                  
    lw $s2, -8($sp)            
    li $s1, 5             
    j verticalLoop          

verticalLoop:
    slti $t4, $s1, 0               
    bnez $t4, vertical_return       
    add $a0, $s1, $zero			
    add $a1, $s2, $zero		  
    sw $ra, -12($sp)            
    jal arr_idx                
    lw $ra, -12($sp)           
    addi $s6, $v0, 0 		
    la $s7, board            
    add $s7, $s7, $s6          
    lb $s4, 0($s7)             
    bne $a3, $s4, vertical_reset       
    addi $s3, $s3, 1              
    subi $t4, $s3, 3               
    bgt $t4, $zero, winner           
    subi $s1, $s1, 1                 
    j verticalLoop                  

vertical_reset:
    li $s3, 0                    
    subi $s1, $s1, 1                  
    j verticalLoop                    

diagonal:
    lw      $s1, -4($sp)             
    lw      $s2, -8($sp)             
    j       right_diagonal            
right_diagonal_return:
    lw      $s1, -4($sp)               
    lw      $s2, -8($sp)              
    j       left_diagonal         

right_diagonal:
    li $s3, 0                   
    slti $t4, $s1, 5                    
    beqz $t4, check_right_diagonal  
    blez $s2, check_right_diagonal        
    addi $s1, $s1, 1                    
    subi $s2, $s2, 1                   
    j right_diagonal              

left_diagonal:
    li $s3, 0                    
    slti $t4, $s1, 5              
    beqz $t4, check_left_diagonal   
    slti $t4, $s2, 6                     
    beqz $t4, check_left_diagonal   
    addi $s1, $s1, 1                     
    addi $s2, $s2, 1                    
    j left_diagonal                

check_right_diagonal: 
    add $t6, $s2, $zero                      
    subi $t6, $t6, 6                  
    bgt $t6, $zero, right_diagonal_return      
    addi $a0, $s1, 0                       
    addi $a1, $s2, 0                       
    sw $ra, -12($sp)                  
    jal arr_idx                   
    lw $ra, -12($sp)                 
    addi $s6, $v0, 0                      
    la $s7, board                  
    add $s7, $s7, $s6               
    lb $s4, 0($s7)                
    lw $a0, -4($sp)               
    bne $a3, $s4, right_diagonal_reset     
    addi $s3, $s3, 1                    
    subi $t4, $s3, 3                    
    bgt $t4, $zero, winner                 
    subi $s1, $s1, 1                    
    addi $s2, $s2, 1                    
    j check_right_diagonal              

right_diagonal_reset:
    li $s3, 0                      
    subi $s1, $s1, 1                    
    addi $s2, $s2, 1                     
    j check_right_diagonal            

check_left_diagonal: 
    slti $t4, $s2, 0        
    bnez $t4, diagonalRet       
    slti $t4, $s1, 0          
    bnez $t4, diagonalRet     
    add $a0, $s1, $zero             
    add $a1, $s2, $zero             
    sw $ra, -12($sp)          
    jal arr_idx              
    lw $ra, -12($sp)              
    add $s6, $v0, $zero              
    la $s7, board             
    add $s7, $s7, $s6            
    lb $s4, 0($s7)
    lw $a0, -4($sp)               
    bne $a3, $s4, left_diagonal_reset       
    addi $s3, $s3, 1                    
    subi $t4, $s3, 3                   
    bgt $t4, $zero, winner              
    subi $s1, $s1, 1                  
    subi $s2, $s2, 1                  
    j check_left_diagonal              

left_diagonal_reset:
    li $s3, 0                      
    subi $s1, $s1, 1            
    subi $s2, $s2, 1           
    j check_left_diagonal         

tie:
    li $t4, 0
    la $t5, board                
    la $t2, space               
    lb $t1, 0($t2)               
    j tie_check              

tie_check:
    subi $t3, $t4, 42        
    bge $t3, $zero, tieGame      
    lb $t6, 0($t5)             
    beq $t1, $t6, finish_winning       
    addi $t4, $t4, 1                   
    addi $t5, $t5, 1                 
    j tie_check         

tieGame:
    jal displayBoard               
    li $v0, 4                  
    la $a0, tieGameString       
    syscall                         
    j gameOver                

winner:
    jal displayBoard                  
    lw $ra, -12($sp)             
    li $t2, 1               
    bne $a2, $t2, p2Wins         
    li $v0, 4                 
    la $a0, oneWins          
    syscall                 
    lw $a0, -4($sp)        
    lw $a1, -8($sp)         
    li $v0, 10
    syscall                   
p2Wins:
    li $v0, 4                
    la $a0, twoWins           
    syscall                       
    lw $a0, -4($sp)            
    lw $a1, -8($sp)          
    li $v0, 10
    syscall
finish_winning:
    li $v0, 0             
    lw $ra, 0($sp)            
    lw $a0, -4($sp)           
    lw $a1, -8($sp)          
    jr $ra                    


switchSide:
    sw $ra, 0($sp)        
    sw $a0, -4($sp)          
    jal displayBoard            
    lw $ra, 0($sp)            
    lw $a0, -4($sp)            
    li $t3, 1                   
    bne $a0, $t3, input_playerOne   
    j input_playerTwo              
    
spaceAvailable:
    add $v0, $a0, $zero                 
    jr $ra                      
noSpaceAvailable:
    li $v0, -1
    jr $ra                            






.data
    row: .asciiz "\n|+---+---+---+---+---+---+---+|\n"
    rowLast: .asciiz "\n|+---+---+---+---+---+---+---+|\n   0   1   2   3   4   5   6\n"
    pattern: .asciiz "|"
    playerOne_turn: .asciiz "Choose a number (0-6 to place): "
    playerTwo_turn: .asciiz "Choose a number (0-6 to place): "
    invalidNumber: .asciiz "Invalid number. Please try again!\n"
    oneWins: .asciiz "Victory for player 1!\n"
    twoWins: .asciiz "Victory for player 2!\n"
    tieGameString: .asciiz "Tie.\n"
    space:  .ascii " "
    border: .ascii "|"
    board:  .space  42
    playerOne: .asciiz "X"
    playerTwo: .asciiz "O"
    violate: .word 0 0
