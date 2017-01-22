#include "consoleUtils.h"
#include "soc_AM335x.h"
#include "beaglebone.h"
#include "interrupt.h"
#include "dmtimer.h"
#include "error.h"

#include "FreeRTOS.h"
#include "task.h"

void configure_platform(void);
extern volatile unsigned int cntValue;

void vTask1(void *pvParameters) {
    int i = 0;
    while (1) {
       vTaskSuspendAll();
       ConsoleUtilsPrintf("Task 1 message %d!\r\n", i++);
       xTaskResumeAll();
       vTaskDelay(1000);

    }
}

void vTask2(void *pvParameters) {
    int i = 0, j;
    while (1) {
        vTaskSuspendAll();
        ConsoleUtilsPrintf("Task 2 message %d!\r\n", i++);
        xTaskResumeAll();
        vTaskDelay(500);

    }
}

int main() {
    configure_platform();
    ConsoleUtilsPrintf("Platform initialized.\r\n");

    int ret = xTaskCreate(vTask1, "Task 1", 1000, NULL, 1, NULL);
    if (ret == pdPASS) {
        ConsoleUtilsPrintf("Task %x succesfully created.\r\n", vTask1);
    } else {
        ConsoleUtilsPrintf("Task not created: %d", ret);
    }
    ret =  xTaskCreate(vTask2, "Task 2", 1000, NULL, 2, NULL);
    if (ret == pdPASS) {
        ConsoleUtilsPrintf("Task %x succesfully created.\r\n", vTask2);
    } else {
        ConsoleUtilsPrintf("Task not created: %d", ret);
    }
    vTaskStartScheduler();

    while(1);


}
