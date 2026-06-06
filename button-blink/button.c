#include <avr/io.h>

int main(void) {
    DDRB  |=  (1 << PB4);   // PB4 output (LED)
    DDRB  &= ~(1 << PB3);   // PB3 input (button)
    PORTB |=  (1 << PB3);   // enable internal pull-up on PB3

    while(1) {
        if (PINB & (1 << PB3)) {
            PORTB &= ~(1 << PB4);  // button not pressed - LED off
        } else {
            PORTB |=  (1 << PB4);  // button pressed - LED on
        }
    }
}