int main(void){
    volatile int *KEYs = (int *)0xff200050;
    volatile int *LEDs = (int *)0xff200000;
    int edge_cap;
    
    while(1){
        // getting the KEYs edge capture register into the variable edge_cap:
        edge_cap = *(KEYs + 3);
        
        if ((*LEDs == 0) && (edge_cap & 0x1)){ 
            // key 0 is turned on when light is off
            *LEDs = 0x3ff;
			*(KEYs + 3) = 0xFFFFFFFF;
        }
        
        if ((*LEDs != 0) && (edge_cap & 0x2)){ 
            // key 1 is turned on when light is on
            *LEDs = 0;
			*(KEYs + 3) = 0xFFFFFFFF;
        }
    }
}

	