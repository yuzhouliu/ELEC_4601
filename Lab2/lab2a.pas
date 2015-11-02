{;	
;	Lab 2 Part A Parallel Port programming
;*************************************************************************
; Before you start filling in the code, you are going to need the following 
; documents for technical information:
;	4601-Lab2 Appendix C
;   http://retired.beyondlogic.org/spp/parallel.htm -How do parallel ports work
;	http://umcs.maine.edu/~cmeadow/courses/cos335/80x86InstructionReference.pdf
;
;
;*************************************************************************
; Start with standard 80x86 assembler boilerplate i.e. a skeleton of a program
; which is common to most assembler code. This programme is more comments and
; discussion than anything else. 
; 
; The actual assembler code that needs to be written is only about 20 lines.
;
; All the heavy lifting is done for you. In the areas marked as:
;__________________________________________>
; Your code goes here
;<__________________________________________
; the student will put a few lines of code to become familiar with writing code. 
; The important things to note are the steps and the how they relate to handling
; interrupts in this particular microprocessor i.e. the 80x86 in real mode
;
; some acronyms that we'll use
; PIC  priority interrupt controller. There are 2 in a classic PC
; OS   operating system
; ISR  interrupt service routine
;
; NOTE
; ****
; For this particular exercise, you are actually using a Pascal compiler
; to 'assemble' your program. The advantage is that you still get to see
; how the actual code does stuff, but you don't have to worry about every little
; detail. It is the main advantage of any compiler. We could have used a C compiler
; as well but this one works just fine. The little constructs that make your life
; easier will be noted. 
;
;*******************************************************************************
;* Note that hex values are designated by a '$' symbol so                      *
;* the usual 0x0FF or 0FFh notation becomes $FF. Comments are also noted as    *
;* anything enclosed in curly brackets.                                        *
;*******************************************************************************
; define some constants that we will use. It is always best to define all constants
; and use the name rather than to use the raw number in the code
;}
const
  EOI   = $20 ;
  PIC   = $20 ; { the 8259 interrupt controller }
  IRQ7  = $F ;
  LPT1  = $378 ;
  BUSY  : string[4] = '-\|/' ;
{;
; variables to be used (a Pascal construct)
;}
var
  counter : word ; { 16-bit number }
  saveint : pointer ; { 32-bit pointer }
{;
; This is the Interrupt Service Routine (ISR). This is where the interrupt handler
; code lives.
; If you only ever call your own routines and they are all in this
; file AND if everything fits in a single 64K segment, then you probably
; wouldn't have to worry about making sure that the segment registers
; are valid and point to your variables.
;
; An interrupt can occur at any time and a jump to this routine will just happen. 
; It is up to you to set things up the way that you want them, handle the
; interrupt and then put everything back the way it was. Interrupt handlers
; must put everything back EXACTLY as it was before the handler was called.
; For this processor, the FLAGS register and the Program Counter (CS:IP) are pushed onto the
; stack when the interrupt handler is called (automatically) and popped off the stack
; with the IRET instruction
;*********************************************************************
; important steps
; 1 - sve any registers that you are going to change
; 2 - set the DS register to point to the data segment of your variables so 
;     you can reference variables properly (two hints: (1) look above at variables that were 
;	  instantiated. Like an array in C, the first variable is the start of your segment
;	  (2)To get the 'address of' a variable you need to use SEG,(2) Remember your assembly class,
;     you can't populate your DS register directly)
; 3 - Increment the interrupt counter
; 4 - send the EOI command to the PIC otherwise you'll never see another interrupt
;     (hint: the PIC is a port)
; 5 - restore the registers that you changed (put your toys away)
; 6 - make interrupt return as opposed to a regular procedure return
; and done
;}
Procedure LptIsr ; far ; assembler ; { this is a Pascal construct for assembly procedures, pretty much like C }
asm
{_____________________________________________>}
push ds
push ax
push dx

// marker
mov dx, $379
in al, dx

mov ax, seg counter
mov ds, ax

inc counter

mov al, EOI
out PIC, al

pop dx
pop ax
pop ds

iret
{<_____________________________________________}
end ;
{
;
; The main program that just waits for an interrupt and puts up some
; sort of a status display
;}
begin
  asm
{
; 
; Below is where we write code to replace the stock hardware interrupt
; vector with our custom vector. Fill in the blanks below with code to
; step though how to do this.
;---------------------------------------------------------
;
;
; Put zero in the 'count' variable
; there are lots of ways of doing this
; about 1 to 3 lines of assembler code should do}
{_____________________________________________>}
	MOV counter, 0
{<_____________________________________________}
{;
; now the painful steps of setting the system up to allow
; recognising and handling the interrupt }
{
; !! Step 1
; send the EOI command to the PIC to ready it for interrupts
; hint: look for information on how to write to x86 ports.
;}
{_____________________________________________>}
	mov al, EOI
	out PIC, al
{<_____________________________________________}
{;
; !! Step 2
; Disable IRQ7 using the interrupt mask register IMR bit in the PIC #1 for now
; so that we don't get an interrupt before we are ready to actually
; process one. Refer to Appendix C in the lab document
;
; A quick word about setting bits,
; We can individually set bits in a register easily by using a bit mask and
; then depending on the activity (set a bit high or low) apply a logical
; operation to the register with the mask. For example:
;
; We want to set bit 5 low of an 8 bit word; we use a mask: 11101111.
; We then read in the value from an external port register(e.g. 11010110)
; To set the bit LOW, we then AND the mask and the received word:
;          11101111 AND 11010110 = 11000110
; We would then write that word back to the external port register.
;
; To set bit 5 HIGH, we have another mask: 00010000. As above, we read in
; in the word from the port, then OR it to set the bit high:
;          11000110 OR 00010000 = 11010110
; Again, we would write this to the external port register.
;		  
{_____________________________________________>}
	in al, PIC+1
	or al, $80
	out PIC+1, al
{<_____________________________________________}
{;
; !! Step 3
; - Save the current IRQ7 vector for restoring later. For this processor,
;   this is just always done.
; - This is a system function call in any OS; We are running this in DOS
;   we will use the DOS INT 21 call to retrieve the interrupt vector.
;   reference http://en.wikipedia.org/wiki/MS-DOS_API	
;	To set up the call:
;   AH = 0x35  this is the function number that fetches a vector
;   AL = the software interrupt vector that we want to read 0..255
;   INT 0x21 is the standard way of getting at DOS services. Any OS running
;            on this processor will use some variation of this idea.
; When the function call returns, you will find the interrupt vector
; in the es:bx registers; the es holds the segment, the bx holds the offset.
;}
{_____________________________________________>}
	mov ah, $35
	mov al, IRQ7
	int $21
{<_____________________________________________}
{;
; Put the values of ES and BX into the 32-bit 'saveint' variable
; so that we can restore the interrupt pointer at the end of the programme.
; We'll use the saveint variable like an array; we'll need to cast the saveint
; to a word.
;}
{_____________________________________________>}

	mov word ptr saveint, BX
	mov word ptr saveint+2, ES
{<_____________________________________________}
{
; !! Step 4 
; Move the address of our ISR into the IRQ7 slot in the table
; Unless you do this step, nothing is going to happen when an interrupt
; occurs, at least nothing that you have any control over
; Just like above, there is a DOS system call to do this. You could do it
; yourself, but it is always good policy to use a system call if there is
; one.
; Again, the call is made through INT 0x21 with some registers
; defined as follows in order to set up the call:
;   AH = 0x25  this is the function number that sets a vector
;   AL = the software interrupt vector that we want to set 0..255
;   DS:DX = the 32-bit address of our ISR
;
; If you change the value of the DS register to satisfy the function call,
; be sure to save it, then restore it after the call.
;
; You can find the segment part and offset part of the address
; of the procedure LptIsr using the 'seg' and 'offset' assembler operations
}
{_____________________________________________>}
	push ds
	move ah, $25
	mov al, IRQ7

	mov bx, seg LptIsr
	mov ds, bx
	mov dx, offset LptIsr

	int $21
	pop ds
{<_____________________________________________}
{;
; !! Step 5
; Enable interrupts at the LPT1 device itself so that signals coming
; in on pin 10 on the LPT1 connector will cause an interrupt.
; Set the bit in the control register (byte) of LPT1 which should be
; at address LPT1+2. Look at Appendix C, you need to toggle specific 
; bits and leave the other bits alone.
{_____________________________________________>}
	mov dx, LPT1+2
	in al, dx
	or al, $10
	out dx, al
{<_____________________________________________}
{;
; !! Step 6
; Lastly set up the PIC to allow interrupts on IRQ7. Same here, you need 
; to toggle specific bits while leaving other bits alone.
{_____________________________________________>}
	mov dx, PIC+1
	in al, DX
	and al, $7F
	out dx, al
{<_____________________________________________}
{
; At this point, interrupts should be enabled and if they occur, our
; interrupt service routine is set up to handle the interrupt by just
; counting the interrupts as they occur. This is happening in the
; 'background' so we can do whatever we want in the 'foreground'. 
; In this case, we will simply give some sort of indication of the
; value of the interrupt counter; using the LEDs on the printer port
; is an easy way of accomplishing this.
;
; We now go into a continuous loop (this is common programming practise in
; embedded systems.)
;}
@loop:
{;
; Check for a keypress to exit out, if no keypress: send the low 8-bits of the
; counter variable to the LED display on LPT1 so that you can see the 
; results of counting the interrupts;
;}
    mov ah,1
    int $16
    jnz @alldone
{;
; write the value of the counter variable to the LPT1 port to light the LEDs    
;}
{_____________________________________________>}
	mov ax, counter
	mov dx, LPT1
	out dx, ax
{<_____________________________________________}
	jmp @loop	{; jump back to loop and check for key to quit}
	
@alldone:
{;
;
; so we have done what we set out to do. An interrupt was generated
; the code handled it and displayed something. Now undo all the steps
; that we went through to try and restore the machine to it's original
; state
;
; ! Undo Step 6 by disabling the IRQ7 interrupt on the PIC
;}
{_____________________________________________>}
    mov dx, PIC+1
	in al, dx
	or al, $80
	out dx, al
{<_____________________________________________}
{;
; ! Undo Step 5 by disabling the LPT1's ability to interrupt
;}
{_____________________________________________>}
	mov dx, LPT1+2
	in al, dx
	and al, $EF
	out dx, AL
{<_____________________________________________}
{;
; ! Undo Step 4 by replacing the interrupt service routine address with the original
; one that we saved in 'saveint' when we started up. This is the same system call
; that you made before which sets a vector in the interrupt table except this time
; the value for the pointer is in 'saveint'
;}
{_____________________________________________>}
	push ds

	mov ah, $25
	mov al, IRQ7

	mov dx, word ptr saveint
	mov bx, word ptr saveint+2
	mov ds, bx

	int $21

	pop ds
{<_____________________________________________}
{;
; and that should do it. Everything that was done to the system has been undone and it should be safe to quit
;}
  end ;
end .