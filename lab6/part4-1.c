
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
int echor[3201]={ }, echol[3201]={ };
int left, right, i=0,  j=0;

while (1) {

if ( audiop->rarc > 0) // check RARC to see if there is data to read
{

left = audiop->ldata; // load the left input fifo
right = audiop->rdata; // load the right input fifo
audiop->ldata = left + 1.2*echol[i]; // store to the left output fifo
audiop->rdata = right + 1.2*echor[i]; // store to the right output fifo


echor[i]= right;
echol[i]= left;
i++;
if(i == 3200){
	i=0;
}
}
}
	
}