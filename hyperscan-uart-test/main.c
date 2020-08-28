#define BIT(n)			(1 << n)

#define P_UART_TXRX_DATA	(*(volatile unsigned int*)0x88150000)
#define P_UART_TXRX_STATUS	(*(volatile unsigned int*)0x88150010)
#define P_UART_INTERFACE_SEL	(*(volatile unsigned int*)0x88200000)

#define SW_UART_GPIO		(0)
#define SW_UART_UART		BIT(24)

extern char _gp[];

int globalInt;
int globalInitInt = 256;

int globalArray[256];

void uart_enable_interface() {
	P_UART_INTERFACE_SEL |= SW_UART_UART;
}

void uart_wait_nonbusy() {
        unsigned int status = P_UART_TXRX_STATUS;
        while ((status & BIT(3)) && (status & BIT(5)) && ~status & BIT(7)) {
                status = P_UART_TXRX_STATUS;
        }
}

void uart_write_byte(unsigned int c) {
	P_UART_TXRX_DATA = c;
	uart_wait_nonbusy();
}

void uart_write_word(unsigned int w) {
	uart_write_byte(w >>  0);
	uart_write_byte(w >>  8);
	uart_write_byte(w >> 16);
	uart_write_byte(w >> 24);
}

void uart_write_string(const char* str) {
	const char* s = str;
	while(*s) {
		globalArray[0] += 1;
		globalInt += 1;
		globalInitInt -= 1;
		uart_write_byte(*s++);
	}
}

int main(int argc, char **argv) {
	uart_enable_interface();
	uart_write_string("Hello, world!\n");

	return 0;
}
