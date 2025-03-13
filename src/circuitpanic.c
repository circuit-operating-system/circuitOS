#include "kernel.h"
#include "circuitpanic.h"


void CPanic1(const char* message) 
{
    terminal_writestring(message);
    terminal_writestring("\n\n");
    terminal_writestring("Circuit Panic 1.0\n");
    terminal_writestring("Please restart your computer.\n");
    terminal_writestring("Halting CPU...\n");
    while (1) {}
}