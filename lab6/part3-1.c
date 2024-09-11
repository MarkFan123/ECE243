#include <time.h>
#define AUDIO_BASE 0xFF203040
int main(void) {
// Audio port structure
struct audio_t {
volatile unsigned int control; // The control/status register
volatile unsigned char rarc; // the 8 bit RARC register
volatile unsigned char ralc; // the 8 bit RALC register
volatile unsigned char wsrc; // the 8 bit WSRC register
volatile unsigned char wslc; // the 8 bit WSLC register
volatile unsigned int ldata;
volatile unsigned int rdata;
};

struct audio_t *const audiop = ((struct audio_t *) AUDIO_BASE);
volatile int *sw=0xFF200040;
int left, right, swnum, i=0;
double avgf= 1900/1024; 	// halfwave

while (1) {
	swnum=*sw;
	int f= swnum*avgf;
	int hf=(int)((8000/f)/2);
	
	for(i=0; i<hf; i++){
		if(audiop->wsrc>0 && audiop->wslc>0){
			audiop->ldata=0xffffff;
			audiop->rdata=0xffffff;
		}
	}
	for(i=0; i<hf; i++){
		if(audiop->wsrc>0 && audiop->wslc>0){
			audiop->ldata=0x0;
			audiop->rdata=0x0;
		}
	}
}
}
	