; Unfortunately we have not YET installed Windows or Linux on the LC-3,
; so we are going to have to write some operating system code to enable
; keyboard interrupts. The OS code does three things:
;
;    (1) Initializes the interrupt vector table with the starting
;        address of the interrupt service routine. The keyboard
;        interrupt vector is x80 and the interrupt vector table begins
;        at memory location x0100. The keyboard interrupt service routine
;        begins at x1000. Therefore, we must initialize memory location
;        x0180 with the value x1000.
;    (2) Sets bit 14 of the KBSR to enable interrupts.
;    (3) Pushes a PSR and PC to the system stack so that it can jump
;        to the user program at x3000 using an RTI instruction.

        .ORIG   x0800
        ; (1) Initialize interrupt vector table.
        LD      R0, VEC
        LD      R1, ISR
        STR     R1, R0, #0

        ; (2) Set bit 14 of KBSR.
        LDI     R0, KBSR
        LD      R1, MASK
        NOT     R1, R1
        AND     R0, R0, R1
        NOT     R1, R1
        ADD     R0, R0, R1
        STI     R0, KBSR

        ; (3) Set up system stack to enter user space.
        LD      R0, PSR
        ADD     R6, R6, #-1
        STR     R0, R6, #0
        LD      R0, PC
        ADD     R6, R6, #-1
        STR     R0, R6, #0
        ; Enter user space.
        RTI
        HALT

VEC     .FILL   x0180             // Interrupt vector table. 
ISR     .FILL   x1000             // Interrupt service routine.
KBSR    .FILL   xFE00             // Keyboard status register.
MASK    .FILL   x4000             // Bit mask for enabling interrupts.
PSR     .FILL   x8002             // PSR for user program.
PC      .FILL   x3000             // PC for user program.
        .END