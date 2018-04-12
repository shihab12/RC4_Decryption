module ksa_part2a(reset,start_2a, CLOCK_50, finish_2a, data_i, ask_i,  
 i_a, j_a, enable_a, finish_swapping, start_swapping);

input logic CLOCK_50, reset, start_2a, finish_swapping;
 logic [23:0] secret_key;
 logic [17:0] state;
output reg [7:0] i_a, j_a; 
input logic [7:0] data_i;
logic [2:0] modulo;
output logic start_swapping, enable_a, finish_2a, ask_i;

parameter idle = 					18'b000_001_0000_0000_0001;
parameter send_i = 				18'b000_010_0000_0000_0010;
parameter wait_si = 				18'b000_011_0000_0000_0100;
parameter read_si = 				18'b000_100_0000_0000_1000;
parameter calculate_modulo = 	18'b000_101_0000_0001_0000;
parameter calculate_j =  		18'b000_110_0000_0010_0000;
parameter send_j = 				18'b000_111_0000_0100_0000;
parameter start_swap = 			18'b001_000_0000_1000_0000;
parameter wait_swap = 			18'b001_001_0001_0000_0000;
parameter increment_i = 		18'b001_010_0010_0000_0000;
parameter finish = 				18'b001_011_0100_0000_0000;
parameter wait_calculate_modulo = 18'b001_100_1000_0000_0000;

/*
logic [17:0] idle_s, send_i_s, wait_si_s, read_si_s, calculate_modulo_s;
logic [17:0] increment_i_s, finish_s, wait_calculate_modulo_s,calculate_j_s, send_j_s, start_swap_s,wait_swap_s;

assign idle_s = state[0];
assign send_i_s = state[1];
assign wait_si_s = state[2];
assign read_si_s = state[3];
assign calculate_modulo_s = state[4];
assign calculate_j_s = state[5];
assign send_j_s = state[6]; 
assign start_swap_s = state[7];
assign wait_swap_s = state[8];
assign increment_i_s = state[9]; 
assign finish_s = state[10]; 
assign wait_calculate_modulo_s = state[11];  

*/

always@(*) begin
if(modulo == 3'd0)
	secret_key = 24'd1;
else if(modulo == 3'd1)
	secret_key = 24'd2;
else if(modulo == 3'd2)
	secret_key = 24'd73;
	end
	


always_ff@(posedge CLOCK_50 or posedge reset)begin
if(reset)
	state <= idle;
else begin
	case(state) 
		idle : begin if(start_2a)
			state <= send_i;
			else 
			state <= idle;
			end
		send_i : state <= wait_si;
		wait_si : state <= read_si;
		read_si : state <= calculate_modulo;
		calculate_modulo : state <= wait_calculate_modulo;
		wait_calculate_modulo: state <= calculate_j;
		calculate_j : state <= send_j;
		send_j : state <= start_swap;
		start_swap : state <= wait_swap;
		wait_swap : begin if(finish_swapping)
				state <= increment_i;
				else
				state <= wait_swap;
				end
		increment_i : begin if(i_a <= 8'd255)
							state <= idle;
							else
							state <= finish;
						end
		finish : state <= finish;
		default : state <= idle;
	endcase
	end
	end
	
	always_ff@(posedge CLOCK_50)begin
	if(reset)
	{i_a, j_a, start_swapping, modulo, finish_2a, enable_a, ask_i} <= {8'b0, 8'b0, 1'b0, 1'b0};
	
	else begin
	case(state)
	idle : {i_a, j_a, start_swapping, modulo, ask_i} <= {i_a, j_a, start_swapping, modulo, ask_i};
	
	send_i : {i_a, j_a, start_swapping, modulo, ask_i} <= {i_a, j_a, start_swapping, modulo, state[1]};
	
	wait_si : {i_a, j_a, start_swapping, modulo, ask_i} <= {i_a, j_a, start_swapping, modulo, ask_i};
	
	read_si : {i_a, j_a, start_swapping, modulo, ask_i} <= {i_a, j_a, start_swapping, modulo, ask_i};
	
	calculate_modulo : {i_a, j_a, start_swapping, modulo, ask_i} <= {i_a, j_a, start_swapping, i_a%3, ask_i};
	
	calculate_j : {i_a, j_a, start_swapping, modulo,  ask_i} <= {i_a, (i_a+data_i+secret_key) , start_swapping, modulo, ask_i};
	
	send_j : {i_a, j_a, start_swapping, modulo,  ask_i} <= {i_a, j_a, start_swapping, modulo,  ask_i};
	
	start_swap : {i_a, j_a, start_swapping, modulo, ask_i} <= {i_a, j_a, state[7], modulo,  ask_i};
	
	wait_swap : {i_a, j_a, start_swapping, modulo, ask_i} <= {i_a, j_a, start_swapping, modulo, ask_i};
	
	increment_i : {i_a, j_a, start_swapping, modulo, ask_i} <= {(i_a +1'b1), j_a, start_swapping, modulo, ask_i};
	
	finish : {i_a, j_a, start_swapping, modulo, finish_2a, ask_i} <= {8'b0, 8'b0, 1'b0, 3'b0, 1'b0, 1'b0, 1'b0};
	
	wait_calculate_modulo : {i_a, j_a, start_swapping, modulo, finish_2a, ask_i} <= {i_a, j_a, start_swapping, modulo, finish_2a, ask_i};
	
	default : {i_a, j_a, start_swapping, modulo, finish_2a, enable_a, ask_i} <= {8'b0, 8'b0, 1'b0, 3'b0, 1'b0, 1'b0, 1'b0};
	endcase

	end
	end

	endmodule
	


		
				
		
	