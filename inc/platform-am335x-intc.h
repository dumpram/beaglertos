#ifndef PLATFORM_AM335X_INTC_H
#define PLATFORM_AM335X_INTC_H


/* Define these here for now until we drop all board-files */
#define OMAP24XX_IC_BASE	0x480fe000
#define OMAP34XX_IC_BASE	0x48200000

/* selected INTC register offsets */

#define INTC_REVISION		0x0000
#define INTC_SYSCONFIG		0x0010
#define INTC_SYSSTATUS		0x0014
#define INTC_SIR		    0x0040
#define INTC_CONTROL		0x0048
#define INTC_PROTECTION		0x004C
#define INTC_IDLE		    0x0050
#define INTC_THRESHOLD		0x0068
#define INTC_MIR0		    0x0084
#define INTC_MIR_CLEAR0		0x0088
#define INTC_MIR_SET0		0x008c
#define INTC_PENDING_IRQ0	0x0098
#define INTC_PENDING_IRQ1	0x00b8
#define INTC_PENDING_IRQ2	0x00d8
#define INTC_PENDING_IRQ3	0x00f8
#define INTC_ILR0		    0x0100

#define ACTIVEIRQ_MASK		0x7f	/* omap2/3 active interrupt bits */
#define SPURIOUSIRQ_MASK	(0x1ffffff << 7)
#define INTCPS_NR_ILR_REGS	128
#define INTCPS_NR_MIR_REGS	4


#endif /* end of include guard: PLATFORM_AM335X_INTC_H */
