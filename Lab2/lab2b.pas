{;
; Lab 2 Part B Serial Port programming
;*************************************************************************
; Before you start filling in the code, you are going to need the following 
; documents for technical information or reference:
;	4601 Lab 2 Appendix C
;	http://retired.beyondlogic.org/serial/serial.htm 
;        - has description of the registers and sample code in C that gives
;          you an idea of how to program a UART
;
;	http://umcs.maine.edu/~cmeadow/courses/cos335/80x86InstructionReference.pdf
;
;*************************************************************************
; Start with standard 80x86 assembler boilerplate i.e. a skeleton of a program
; which is common to most assembler code. This programme is more comments and
; discussion than anything else. The actual assembler code that needs to be
; written is only about 20 lines.
;
; This code is exactly the same as Part A, except for setting up the serial
; port, changing the address and IRQ of the device and the name of the ISR
; 
; All the heavy lifting is again done for you. In the areas marked as
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
  EOI  = $20 ;
  PIC  = $20 ;  { the 8259 interrupt controller } 
  IRQ4 = $C ;	{ the IRQ + vector offset used by the serial port }
  COM1 = $3F8 ; { the address of the serial port, an INS8250 chip }
  LPT1 = $378 ;
{;
; variables to be used (a Pascal construct)
;}
var
  counter : word ; { 16-bit number }
  saveint : pointer ; { 32-bit pointer }
  rxchar  : byte ; { the received serial character }
  txchar  : byte ; { the transmitted character } 
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
; For this processor, the FLAGS register and the Program Counter (CS:IP) are pushed
; onto the stack when the interrupt handler is called (automatically) and popped
; off the stack with the IRET instruction
;*********************************************************************
; Important steps
; 1 - Save any registers that you are going to change
; 2 - Set the DS register to point to the data segment of your variables so 
;     you can reference variables properly 
;     (two hints: 
;     (1) look above at variables that were instantiated. Like an array in C, 
;         the first variable is the start of your segment
;	  (2) To get the 'address of' a variable you need to use SEG,(2) Remember
;         your assembly class, you can't populate your DS register directly)
; 3 - Read and Write to the serial port register
; 4 - Increment the interrupt counter
; 5 - Send the EOI command to the PIC otherwise you'll never see another interrupt
;     (hint: the PIC is a port)
; 6 - Restore the registers that you changed (put your toys away)
; 7 - Use the interrupt return as opposed to a regular procedure return
;     and done
;}
Procedure ComIsr ; far ; assembler ; { this is a Pascal construct for assembly procedures, pretty much like C }
asm
{_____________________________________________>}
push ax
push ds
push dx

mov ax, seg counter
mov ds, ax

mov dx, COM1
in al, dx
out dx, al

inc counter

mov al, EOI
out PIC, al

pop dx
pop ds
pop ax

iret
{<_____________________________________________}
end ;
{
;
; The main programme that just waits for an interrupt and counts incoming serial
; characters
;}
begin
  asm
{;
; Below is where we write code to replace the stock hardware interrupt
; vector with our custom vector. Fill in the blanks below with code to
; step though how to do this.
;---------------------------------------------------------
;
;
; Put zero in the 'count' variable there are lots of ways of doing this
; about 1 to 3 lines of assembler code should do}
{_____________________________________________>}
	mov counter, 0
{<_____________________________________________}
{;
; The need to set up the serial parameters for COM 1 to allow communication
; with a serial terminal. 
; Programming UART is requires that the configuration bits within registers need 
; to be set in a specific order, it would be good to review the
; Appendix C of the Lab 2 document and the "serial.pdf" documentation to minimize
; on pain getting this right.
;
; The basic steps:
; 1 - Figure out the 16-bit baud rate divisor value from this formula (Appendix C):
;                divisor = 1843200/16/baud_rate 
;     Where baud_rate is a number like 2400, 9600, 19200 up to 115200.
; 2 - Set the most significant bit of the byte at address (COM1 + 3) (the line
;     control register) to a '1' (DLAB = 1)
; 3 - Now you have write access to the baud rate bytes at COM1 (the low byte) and
;     (COM1 + 1) the high byte; set the two bytes according to your divisor value
;     that you calculated in step 1.
; 4 - Toggle the most significant bit of the byte at address (COM1 + 3) to a '0' (DLAB = 0);
;     the baud rate is set. 
; 5 - Next, need to set: The number of serial bits, the number of stop bits and the parity. 
;     This is just a single byte code from the documentation (page 3):
;      no parity    (....0...),
       one stop bit (.....0..),
	   8-bit data   (......11)
;     Which comes to 00000011 or just a value of 03.
; 6 - Write this value to register (COM1 + 3) and the serial communications are all set up
; }
{_____________________________________________>}
{ Choose 9600 baud rate, which gives divisor 12}
	mov dx, COM1+3
	in al, dx
	or al, $80
	out dx, al
	
	mov dx, COM1
	mov al, $C
	out dx, al

	mov dx, COM1+1
	mov al, $0
	out dx, al
	
	mov dx, COM1+3
	in al, dx
	and al, $7F
	out dx, al
	
	mov al, $3
	out dx, al
	
{<_____________________________________________}
{;
;***********************************************************************
; If you have done lab 2 part A, this is almost the same, except for
; the name of the interrupt service routine and a bonus bit before step 5.
; Carefully copy bits of the code over (watch what you are doing and don't blindly
; copy it over.... bad practice) and make the edits to work with IRQ 4
;***********************************************************************
;
;
; Now the painful steps of setting the system up to allow recognising and 
; handling the interrupt }
{
; !! Step 1
; send the EOI command to the PIC to ready it for interrupts
;}
{_____________________________________________>}
	mov al, EOI
	out PIC, al
{<_____________________________________________}
{;
; !! Step 2
; Disable IRQ4 using the interrupt mask register IMR bit in the PIC#1 for now
; so that we don't get an interrupt before we are ready to actually
; process one. IRQ 4 is the one assigned to the COM1 serial port
; Refer to Appendix C in the lab document if you are unsure.
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
;
{_____________________________________________>}
	in al, PIC+1
	or al, $10
	out PIC+1, al
{<_____________________________________________}
{;
; !! Step 3
; Save the current IRQ4 vector for restoring later . For this processor
; this is just always done.
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
	mov al, IRQ4
	int $21
{<_____________________________________________}
{;
; Put the values of ES and BX into the 32-bit 'saveint' variable
; so that we can restore the interrupt pointer at the end of the programme.
; We'll use the saveint variable like an array; we'll need to cast the saveint
; to a word.
;}
{_____________________________________________>}
	mov word ptr [saveint], BX
	mov word ptr [saveint+2], ES
{<_____________________________________________}
{
; !! Step 4 
; Move the address of our ISR into the IRQ4 slot in the table
; Unless you do this step, nothing is going to happen when an interrupt
; occurs, at least nothing that you have any control over
; Just like above, there is a system call to do this. You could do it
; yourself but it is always good policy to use a system call if there is
; one.
; Again, the call is made through INT 0x21 with some registers
; defined as follows in order to set up the call:
;   AH = 0x25  this is the function number that sets a vector
;   AL = the software interrupt vector that we want to set 0..255
;   DS:DX = the 32-bit address of our ISR
;
; If you change the value of the DS register to satisfy the function call,
; be sure to SAVE IT, then RESTORE IT after the call.
;
; You can find the segment part and offset part of the address
; of the procedure ComIsr using the 'seg' and 'offset' assembler operations
}
{_____________________________________________>}
	push ds

	mov ah, $25
	mov al, IRQ4

	mov dx, offset ComIsr
	mov bx, seg ComIsr
	mov ds, bx
	int $21 

	pop ds
{<_____________________________________________}
{; 
;
;***************** BONUS ********** BONUS ***********************
; !! This is a given because you would likely never find this step.
; BONUS, describe what this does and why this is necessary }

		mov dx,COM1+4	{ ; !! odd bit only required on some systems, like this one. typical pain }
		mov al,$0F
		out dx,al
{;
;***************** BONUS ********** BONUS ***********************
;
; !! Step 5
; Enable interrupts at the COM1 device itself so that once a serial character
; is received from the Windows terminal, you will get an interrupt
; Hint: Look at Interrupt Enable Register on page 2.
{_____________________________________________>}
	mov dx, COM1+1
	in al, dx
	or al, $1
	out dx, al
{<_____________________________________________}
{;
; !! Step 6
; everything is ready, so lastly set up the PIC to allow
; interrupts on IRQ4
{_____________________________________________>}
	in al, PIC+1
	and al, $EF
	out PIC+1, al
{<_____________________________________________}
{
; At this point, interrupts should be enabled and if they occur, our
; interrupt service routine is set up to handle the interrupt by just
; counting the interrupts as they occur and echoing a character. This is happening in the
; 'background' so we can do whatever we want in the 'foreground'. In this
; case, we will simply give some sort of indication of the value of the
; interrupt counter. The LEDs on the printer port would be easy.
;}
@loop:
{;
; Check for a key press to exit out, otherwise send the low 8-bits of the
; counter variable to the LED display on LPT1 so that you can see the 
; results of counting the interrupts;
;}
    mov ah,1
    int $16
    jnz @alldone
{;
; Write OUT the value of the counter variable to the LPT1 port to light the LEDs    
; the interrupt service routine takes care of echoing the received character.
;}
{_____________________________________________>}
	mov ax, counter
	mov dx, LPT1
	out dx, ax
{<_____________________________________________}
	jmp @loop	{; jump back to loop and check for key to quit}
	
@alldone:
{;
; An interrupt was generated, the code handled it and displayed something. 
; Now undo all the steps that we went through to try and restore the machine to
; it's original state
;
; ! Undo Step 6 by disabling the IRQ4 interrupt on the PIC
;}
{_____________________________________________>}
	in al, PIC+1
	or al, $10
	out PIC+1, al
{<_____________________________________________}
{;
; ! Undo Step 5 by disabling the COM1 port's ability to interrupt
;}
{_____________________________________________>}
	mov dx, COM1+1
	in al, dx
	and al, $FE
	out dx, al
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
	mov al, IRQ4

	mov dx, word ptr saveint
	mov bx, word ptr saveint+2
	mov ds, bx

	int $21

	pop ds
{<_____________________________________________}
{;
; Everything that was done to the system has been undone and it should be safe to quit
;}
  end ;
end .