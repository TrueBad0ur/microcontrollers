#include <avr/io.h>
#include <util/delay.h>

// One stage of an 8-bit ripple counter. Eight chips chained = counter 0..255.
// PB2 (pin 7) - clock in: button to GND on bit 0, previous chip's Q on others
// PB3 (pin 2) - LED, active low (LED module: VCC -> R -> LED -> pin)
// PB4 (pin 3) - Q out, clocks the next chip
// Stage toggles its bit on falling edge (1 -> 0) of the clock input.

int main(void) {
    DDRB  = (1 << PB3) | (1 << PB4);                            // LED, Q outputs
    PORTB = (1 << PB0) | (1 << PB1) | (1 << PB2) | (1 << PB3);  // pull-ups on inputs, LED off, Q = 0

    _delay_ms(50);                         // let all chips start driving their outputs
    uint8_t prev = !!(PINB & (1 << PB2));
    uint8_t q = 0;

    while (1) {
        uint8_t in = !!(PINB & (1 << PB2));
        if (in == prev) continue;

        _delay_ms(20);                     // debounce
        if (!!(PINB & (1 << PB2)) != in) continue;

        if (prev && !in) {                 // falling edge
            q ^= 1;
            if (q) PORTB = (PORTB & ~(1 << PB3)) | (1 << PB4);
            else   PORTB = (PORTB | (1 << PB3)) & ~(1 << PB4);
        }
        prev = in;
    }
}
