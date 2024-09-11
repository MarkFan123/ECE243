#include <stdlib.h>
#include <stdbool.h>

int pixel_buffer_start; // global variable
volatile int *pixel_ctrl_ptr = (int *)0xFF203020;
void wait_for_vsync();
void draw_line(int x0, int y0, int x1, int y1, short int line_color);
void plot_pixel(int x, int y, short int line_color);
void clear_screen();

int main(void)
{
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
	int y_pos = 239, y_dir = 1;
	while (1){
		draw_line(0, y_pos, 319, y_pos, 0xFFFF);   // new white line
		draw_line(0, y_pos-y_dir, 319, y_pos-y_dir, 0x0000);	// clear line
		wait_for_vsync();
		y_pos = y_pos+y_dir;
		if (y_pos < 2 || y_pos >= 240)
			y_dir = -y_dir;
	}
    
}

// code not shown for clear_screen() and draw_line() subroutines

void wait_for_vsync(){
	int status;
	*pixel_ctrl_ptr = 1; // start the synchronization process
	// - write 1 into front buffer address register
	status = *(pixel_ctrl_ptr + 3); // read the status register
	while ((status & 0x01) != 0) // polling loop waiting for S bit to go to 0
	{
		status = *(pixel_ctrl_ptr + 3);
	}
}

void draw_line(int x0, int y0, int x1, int y1, short int line_color){
    bool is_steep = abs(y1 - y0) > abs(x1 - x0);
	double slope = (double)(y1 - y0) / (x1 - x0);
	int temp;
	if (is_steep){
		// vertical line
		if (y0 > y1){ 
			temp = x0; x0 = x1; x1 = temp; 
			temp = y0; y0 = y1; y1 = temp; 
		}	// swap
		for (int i = y0; i <= y1; i++){
			temp = x0 + (i-y0) / slope;
			plot_pixel(temp, i, line_color);
		}
	} else {
		// horizontal line
		if (x0 > x1){ 
			temp = x0; x0 = x1; x1 = temp; 
			temp = y0; y0 = y1; y1 = temp; 
		}	// swap
		for (int i = x0; i <= x1; i++){
			temp = y0 + (i-x0) * slope;
			plot_pixel(i, temp, line_color);
		}
	}
}

void plot_pixel(int x, int y, short int line_color)
{
    volatile short int *one_pixel_address;

        one_pixel_address = pixel_buffer_start + (y << 10) + (x << 1);

        *one_pixel_address = line_color;
}

void clear_screen(){
	int y, x;
	for (x = 0; x < 320; x++)
		for (y = 0; y < 240; y++)
			plot_pixel (x, y, 0);
}
