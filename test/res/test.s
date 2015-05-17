 #----------------------------------------------------
# test.s
#----------------------------------------------------

# Im Abschnitt .data liegen die vorinitialisierten Variablen
.data

msg:
    .ascii      "Test successful!\n"
len = . - msg

# Im Abschnitt .text liegt das Programm
.text

.globl _start
_start:
    /* Systemaufruf write zusammensetzen
    write(int fd, const void *buf, size_t count) */
    mov     %r0, $1     /* Ausgabe auf stdout: fd -> stdout */
    ldr     %r1, =msg   /* Der Text ist der buf-Parameter: buf -> msg */
    ldr     %r2, =len   /* Länge in den counter: count -> len(msg) */
    mov     %r7, $4     /* write ist Systemaufruf #4 */
    swi     $0          /* Software interrupt um Kernel aufzurufen */

    /* Programmressourcen freigeben
    Systemaufruf exit(int status) */
    mov     %r0, $0     /* status -> 0 */
    mov     %r7, $1     /* exit ist Systemaufruf #1 */
    swi     $0          /* Kernel aufrufen*/
