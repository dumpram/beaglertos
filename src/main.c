#include "consoleUtils.h"
#include "soc_AM335x.h"
#include "beaglebone.h"
#include "interrupt.h"
#include "dmtimer.h"
#include "error.h"

#include "FreeRTOS.h"

void configure_platform(void);
extern volatile unsigned int cntValue;

int main() {
    configure_platform();
    ConsoleUtilsPrintf("Platform initialized.\r\n");

    while (1) {
        if (cntValue == 1000) {
            ConsoleUtilsPrintf("One second passed!\r\n");
            cntValue = 0;
        }
    }
}
