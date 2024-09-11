#include <stdlib.h>
#include <stdbool.h>
#include <time.h>

int pixel_buffer_start; // global variable
volatile int *pixel_ctrl_ptr = (int *)0xFF203020;
void wait_for_vsync();
void draw_line(int x0, int y0, int x1, int y1, short int line_color);
void draw_box(int x, int y, short int box_color);
void plot_pixel(int x, int y, short int line_color);
void clear_screen();

short int Buffer1[240][512]; // 240 rows, 512 (320 + padding) columns
short int Buffer2[240][512];

int main(void)
{
    // declare other variables(not shown)
	int N = 8;					// number of blocks
	// srand(time(NULL));
    // initialize location and direction of rectangles(not shown)
	int x_box[N], y_box[N]; 	// location of each box
	int colour_box[N];
	int dx[N], dy[N];
	
	// initialize
	for (int i = 0; i < N; i++){
		x_box[i] = (rand() % 318) + 1;
		y_box[i] = (rand() % 218) + 1;
		colour_box[i] = rand() % (0x10000);
		dx[i] = 2 * (rand() % 2) - 1;
		dy[i] = 2 * (rand() % 2) - 1;
	}

    /* set front pixel buffer to Buffer 1 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer1; // first store the address in the  back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    /* set back pixel buffer to Buffer 2 */
    *(pixel_ctrl_ptr + 1) = (int) &Buffer2;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
        for (int i = 0; i < N-1; i++){
			draw_line(x_box[i]-dx[i], y_box[i]-dy[i], x_box[i+1]-dx[i+1], y_box[i+1]-dy[i+1], 0);
			draw_line(x_box[i], y_box[i], x_box[i+1], y_box[i+1], 0);
		}
		draw_line(x_box[N-1]-dx[N-1], y_box[N-1]-dy[N-1], x_box[0]-dx[0], y_box[0]-dy[0], 0);
		draw_line(x_box[N-1], y_box[N-1], x_box[0], y_box[0], 0);
		for (int i = 0; i < N; i++){
			draw_box(x_box[i]-dx[i], y_box[i]-dy[i], 0);
			draw_box(x_box[i], y_box[i], 0);
		}
		// clear_screen();

		// code for updating the locations of boxes (not shown)
		for (int i = 0; i < N; i++){
			// x range: 1-318; y-range: 1-218
			if (x_box[i] <= 1 || x_box[i] >= 318)
				dx[i] = -dx[i];
			if (y_box[i] <= 1 || y_box[i] >= 218)
				dy[i] = -dy[i];
			x_box[i] = x_box[i] + dx[i];
			y_box[i] = y_box[i] + dy[i];
		}
		
        // code for drawing the boxes and lines (not shown)
		for (int i = 0; i < N-1; i++){
			draw_line(x_box[i], y_box[i], x_box[i+1], y_box[i+1], colour_box[i]);
		}
		draw_line(x_box[N-1], y_box[N-1], x_box[0], y_box[0], colour_box[N-1]);
		for (int i = 0; i < N; i++){
			draw_box(x_box[i], y_box[i], colour_box[i]);
		}

        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)

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

void draw_box(int x, int y, short int box_color){
	plot_pixel(x, y, box_color);
	plot_pixel(x, y-1, box_color);
	plot_pixel(x, y+1, box_color);
	plot_pixel(x-1, y, box_color);
	plot_pixel(x-1, y-1, box_color);
	plot_pixel(x-1, y+1, box_color);
	plot_pixel(x+1, y, box_color);
	plot_pixel(x+1, y-1, box_color);
	plot_pixel(x+1, y+1, box_color);
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
