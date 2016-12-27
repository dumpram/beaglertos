# beaglertos
FreeRTOS BeagleBone Black (Sitara am3358) port

## portable part of code
Official Cortex A9 port will be amended because Sitara am3358 uses TI
INTC interrupt controller. This is registers are changed:

GIC | INTC

ICCPMR | INTC_THRESHOLD
ICCIAR | INTC_SIR_IRQ(currently active irq) + INTC_CONTROL(acknowledgement)
ICCEOIR | ?


Priority grouping code is removed because INTC doesn't support priority
grouping.
