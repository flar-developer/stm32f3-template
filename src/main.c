#include <stm32f30x.h>
#include "stm32f3_discovery.h"

/* Private function prototypes -----------------------------------------------*/


int main()
{
    STM_EVAL_LEDInit(LED3);
    while (1)
    {
        STM_EVAL_LEDToggle(LED3);
        for (int i = 0; i < 50000; i++) {
            ;
        }
    }
//	return 0;
}
