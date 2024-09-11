#include <stdlib.h>
#include <stdbool.h>

int pixel_buffer_start; // global variable
void draw_line(int x0, int y0, int x1, int y1, short int line_color);
void plot_pixel(int x, int y, short int line_color);
void clear_screen();

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clear_screen();
    draw_line(0, 0, 150, 150, 0x001F);   // this line is blue
    draw_line(150, 150, 319, 0, 0x07E0); // this line is green
    draw_line(0, 239, 319, 239, 0xF800); // this line is red
    draw_line(319, 0, 0, 239, 0xF81F);   // this line is a pink color
}

// code not shown for clear_screen() and draw_line() subroutines

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
