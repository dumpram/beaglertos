#ifndef PLATFORM_C
#define PLATFORM_C

#include "consoleUtils.h"
#include "soc_AM335x.h"
#include "beaglebone.h"
#include "interrupt.h"
#include "dmtimer.h"
#include "error.h"

void vSetupTickInterrupt()
{
    // basic initialization is done platform configuration
    // RTOS only enables interrupt

    ConsoleUtilsPrintf("Enabling timer interrupt!\r\n");
    DMTimerIntEnable(SOC_DMTIMER_2_REGS, DMTIMER_INT_OVF_EN_FLAG);
}

void vApplicationFPUSafeIRQHandler()
{

}

#endif /* end of include guard: PLATFORM_C */
