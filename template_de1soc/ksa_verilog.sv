
module ksa_verilog(CLOCK_50, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	input logic CLOCK_50;
	input logic [3:0] KEY;
   input logic [9:0] SW;
   output logic [9:0] LEDR;
   output logic [6:0] HEX0;
   output logic [6:0] HEX1;
   output logic [6:0] HEX2;
   output logic [6:0] HEX3;
   output logic [6:0] HEX4;
   output logic [6:0] HEX5;
	

	logic [24:0] state;
	reg [7:0] address;
	reg [7:0] counter,data_i, i,j, SW_pos, data_j, first_add, modulo;
	reg enable; 
	reg reset;
	logic [7:0] q;
	reg [7:0] data;
	reg [23:0] secret_key_a;
//for part 2b

	reg [7:0] read_address_2b, read_data_2b, k, f;
	reg [7:0] write_address_2b, write_data_2b, q_2b;
	reg [7:0] data_si, data_sj, data_sij, data_f, data_enc_k, data_dec_k, XOR_data;
	reg enable_2b;
	
	SevenSegmentDisplayDecoder display_cracking(HEX5, secret_key_a[23:20], CLOCK_50);
	SevenSegmentDisplayDecoder display_cracking1(HEX4, secret_key_a[19:16], CLOCK_50);
	SevenSegmentDisplayDecoder display_cracking2(HEX3, secret_key_a[15:12], CLOCK_50);
	SevenSegmentDisplayDecoder display_cracking3(HEX2, secret_key_a[11:8], CLOCK_50);
	SevenSegmentDisplayDecoder display_cracking4(HEX1, secret_key_a[7:4], CLOCK_50);
	SevenSegmentDisplayDecoder display_cracking5(HEX0, secret_key_a[3:0], CLOCK_50);
	
	
	//start of part 1
	parameter idle =   							25'b100_000_000_000_000_000_000_000_0;
	parameter start =  							25'b010_000_000_000_000_000_000_000_0;
	parameter increment_counter = 			25'b001_000_000_000_000_000_000_000_0;
	parameter memory_assignment = 			25'b000_100_000_000_000_000_000_000_0;
	parameter finish_1 = 						25'b000_010_000_000_000_000_000_000_0;

//start of part2a	
	parameter start_2a = 						25'b000_001_000_000_000_000_000_000_0;
	parameter get_value_si = 					25'b000_000_100_000_000_000_000_000_0;
	parameter wait_si = 							25'b000_000_010_000_000_000_000_000_0;
	parameter addition_1 = 						25'b000_000_001_000_000_000_000_000_0;
	parameter calculate_modulus = 			25'b000_000_000_100_000_000_000_000_0;
	parameter get_SW_pos = 						25'b000_000_000_010_000_000_000_000_0;
	parameter addition_2 = 						25'b000_000_000_001_000_000_000_000_0;
	parameter get_value_sj = 					25'b000_000_000_000_100_000_000_000_0;
	parameter wait_sj = 							25'b000_000_000_000_010_000_000_000_0;
	parameter swap_i = 							25'b000_000_000_000_001_000_000_000_0;
	parameter wait_swap_i = 					25'b000_000_000_000_000_100_000_000_0;
	parameter wait_again_swap_i  = 			25'b000_000_000_000_000_010_000_000_0;
	parameter swap_j  = 							25'b000_000_000_000_000_001_000_000_0;
	parameter wait_swap_j  = 					25'b000_000_000_000_000_000_100_000_0;
	parameter  wait_again_swap_j  = 			25'b000_000_000_000_000_000_010_000_0;
	parameter increment_i = 					25'b000_000_000_000_000_000_001_000_0;
	parameter wait_si_again = 					25'b000_000_000_000_000_000_000_100_0;
	parameter  finish_2a = 						25'b000_000_000_000_000_000_000_010_0;
	parameter wait_for_increment = 			25'b000_000_000_000_000_000_000_001_0;
	parameter wait_sj_again = 					25'b000_000_000_000_000_000_000_000_1;
	parameter wait_for_j = 						25'b100_000_000_000_000_000_000_000_1;
	parameter wait_for_modulo =  				25'b100_000_000_000_000_000_000_001_1;
	parameter wait_for_SW_pos = 				25'b100_000_000_000_000_000_000_011_1;

//start of part2b
	
	parameter start_2b =							25'b100_000_000_000_000_001_000_000_0;
	parameter increment_i_2b =					25'b100_000_000_000_000_010_000_000_0;
	parameter wait_inc_2b =    				25'b100_000_000_000_000_011_000_000_0;
	parameter read_si_2b =   					25'b100_000_000_000_000_100_000_000_0;
	parameter wait_si_2b =   					25'b100_000_000_000_000_101_000_000_0;
	parameter wait_si_again_2b =   			25'b100_000_000_000_000_110_000_000_0;
	parameter calculate_j_2b =   				25'b100_000_000_000_000_111_000_000_0;
	parameter wait_j_2b =   					25'b100_000_000_000_001_000_000_000_0;
	parameter swap_si_2b =   					25'b100_000_000_000_001_001_000_000_0;
	parameter wait_swap_si_2b =   			25'b100_000_000_000_001_010_000_000_0; 
	parameter wait_again_swap_si_2b =   	25'b100_000_000_000_001_011_000_000_0;
	parameter swap_j_2b =   					25'b100_000_000_000_001_100_000_000_0;
	parameter wait_swap_sj_2b =   			25'b100_000_000_000_001_101_000_000_0;
	parameter wait_again_swap_sj_2b =   	25'b100_000_000_000_001_110_000_000_0;
	parameter addition_1_2b =   				25'b100_000_000_000_001_111_000_000_0;
	parameter read_sij_2b =   					25'b100_000_000_000_010_000_000_000_0;
	parameter wait_sij_2b =   					25'b100_000_000_000_010_001_000_000_0;
	parameter wait_again_sij_2b =   			25'b100_000_000_000_010_010_000_000_0;
	parameter assign_f_2b =   					25'b100_000_000_000_010_011_000_000_0;
	parameter wait_assign_2b =   				25'b100_000_000_000_010_100_000_000_0;
	parameter read_encrypt_2b =   			25'b100_000_000_000_010_101_000_000_0;
	parameter wait_encrypt_2b =   			25'b100_000_000_000_010_110_000_000_0;
	parameter wait_again_encrypt_2b =   	25'b100_000_000_000_010_111_000_000_0;
	parameter XOR_2b =   						25'b100_000_000_000_011_000_000_000_0;
	
	parameter write_dec_data_2b =   				25'b100_000_000_000_011_001_000_000_0;
	parameter wait_write_dec_data_2b =   		25'b100_000_000_000_011_010_000_000_0;
	parameter wait_again_write_dec_data_2b =   25'b100_000_000_000_011_011_000_000_0;
	parameter increment_k_2b =   				25'b100_000_000_000_011_100_000_000_0;
	parameter finish_2b =    					25'b100_000_000_000_011_101_000_000_0;
	parameter read_sj_2b =   					25'b100_000_000_000_011_111_000_000_0;
	parameter wait_sj_2b =   					25'b100_000_000_000_100_000_000_000_0;
	parameter wait_sj_again_2b =   			25'b100_000_000_000_100_001_000_000_0;
	parameter wait_XOR_2b = 					25'b100_000_000_000_100_010_000_000_0;
	parameter check_valid_data =  			25'b100_000_000_000_100_011_000_000_0;
	parameter wait_check_valid_data = 		25'b100_000_000_000_100_100_000_000_0;
	parameter increment_secret_key = 		25'b100_000_000_000_100_101_000_000_0;
	parameter fail = 								25'b100_000_000_000_100_110_000_000_0;
	parameter wait_increment_secret_key = 	25'b100_000_000_000_100_111_000_000_0;
	parameter  done_cracking = 				25'b100_000_000_000_101_000_000_000_0;
	parameter reset_secret_key = 				25'b100_000_000_000_101_001_000_000_0;
	
	/*
	assign secret_key_a[23:16] = 8'h00;
	assign secret_key_a[15:8] = 8'h02;
	assign secret_key_a[7:0] = 8'hAA;
	*/
	
always_ff @(posedge CLOCK_50 or posedge reset) begin
	if(reset)
	state <= idle;
	else begin
	case(state)
		idle: begin if(SW[0] ==1'b1)
						state <= start;
						else
						state <= idle;
						end
		start : state <= increment_counter;
		increment_counter :  begin if(counter == 8'd255)
							state <= finish_1;
							else
							state <= memory_assignment;
							end
		memory_assignment: state <= increment_counter;
		finish_1: state <= start_2a;
		//task_2a_starts from here
		
		start_2a : state <= get_value_si;							
		get_value_si : state <= wait_si;
		wait_si : state <= wait_si_again;
		wait_si_again : state <= addition_1;
		addition_1 : state <= calculate_modulus;
		calculate_modulus : state <= wait_for_modulo;
		wait_for_modulo : state <= get_SW_pos;
		get_SW_pos : state <= wait_for_SW_pos;
		wait_for_SW_pos : state <= addition_2;
		addition_2  : state <= wait_for_j;
		wait_for_j : state <= get_value_sj;
		get_value_sj : state <= wait_sj;
		wait_sj : state <= wait_sj_again;
		wait_sj_again : state <= swap_i;
		swap_i : state <= wait_swap_i;
		wait_swap_i : state <= wait_again_swap_i;
		wait_again_swap_i : state <= swap_j;
		swap_j : state <= wait_swap_j;
		wait_swap_j : state <= wait_again_swap_j;
		wait_again_swap_j : begin if(i == 8'd255)
										state <= finish_2a; 
										else
										state <= increment_i;
										end
		increment_i :	state <= wait_for_increment;
		
		wait_for_increment : state <= start_2a;						
		
		finish_2a : state <= start_2b;
		//task_2b starts from here
		
		start_2b : state <= increment_i_2b;		
		increment_i_2b : state <= wait_inc_2b;					
		wait_inc_2b : state <= read_si_2b;    				
		read_si_2b : state <= wait_si_2b;   					
		wait_si_2b : state <= wait_si_again_2b;   					
		wait_si_again_2b : state <= calculate_j_2b;   			
		calculate_j_2b : state <= wait_j_2b;  				
		wait_j_2b : state <= read_sj_2b;
		read_sj_2b : state <= wait_sj_2b;
		wait_sj_2b : state <= wait_sj_again_2b;
		wait_sj_again_2b : state <= swap_si_2b; 					
		swap_si_2b : state <= wait_swap_si_2b;
		wait_swap_si_2b : state <= wait_again_swap_si_2b;	
		wait_again_swap_si_2b : state <= swap_j_2b;
		swap_j_2b : state <= wait_swap_sj_2b;
		wait_swap_sj_2b : state <= wait_again_swap_sj_2b;
		wait_again_swap_sj_2b : state <= addition_1_2b;   	
		addition_1_2b : state <= read_sij_2b;
		read_sij_2b : state <= wait_sij_2b;
		wait_sij_2b : state <= wait_again_sij_2b;
		wait_again_sij_2b : state <= assign_f_2b;  			
		assign_f_2b : state <= wait_assign_2b;
		wait_assign_2b : state <= read_encrypt_2b;
		read_encrypt_2b : state <= wait_encrypt_2b;
		wait_encrypt_2b : state <= wait_again_encrypt_2b;
		wait_again_encrypt_2b : state <= XOR_2b; 	
		XOR_2b : state <= check_valid_data;
		check_valid_data : state <= wait_check_valid_data;
		wait_check_valid_data : begin if({data_dec_k >= 8'h61 && data_dec_k <= 8'h7A} || data_dec_k == 8'h20)
												state <= wait_XOR_2b;
												else
												state <= increment_secret_key;
												end
		wait_XOR_2b : 	state <= write_dec_data_2b;
		write_dec_data_2b : state <= wait_write_dec_data_2b;
		wait_write_dec_data_2b : state <= wait_again_write_dec_data_2b;
		wait_again_write_dec_data_2b : state <= increment_k_2b;
		increment_k_2b :  begin if(k == 31)
										state <= finish_2b;
										else
										state <= start_2b;
										end
		increment_secret_key : begin if((secret_key_a == 24'b001_111_111_111_111_111_111_111) && k ==31)
									state <= fail;
									else
									state <= wait_increment_secret_key;
									end
		wait_increment_secret_key : state <= idle;
		finish_2b : state <= done_cracking;
		fail : state <= fail;
		done_cracking : state <= done_cracking;
		
		default : state <= idle;
		endcase
		end
		end
		
		
		always_ff@(posedge CLOCK_50) begin
		if(reset)begin
		counter <= 8'b0;
		end
		else begin
		case(state)
		//start of task 1
		idle : {enable, address, data, counter, secret_key_a} <= {enable, address, data, counter, secret_key_a};	
		start :  {enable, address, data} <= {1'b1, 8'b0, 8'b0};
		increment_counter : counter <= (counter+1'b1);
		memory_assignment : {enable, address, data,counter} <= {1'b1, counter, counter,counter}; 
		finish_1: {i, j, enable,counter} <= {8'b0, 8'b0, 1'b0, 8'b0};
		//start of task 2a
		start_2a : {address, enable} <= {i, enable};
		get_value_si : {address, enable} <= {address, enable};
		wait_si : data_i <= q;
		wait_si_again : data_i <= data_i;
		addition_1 : first_add <= (data_i + j);
		calculate_modulus : {modulo, first_add} <= {(i%3), first_add};
		wait_for_modulo : modulo <= modulo;
		get_SW_pos : begin 
									if(modulo == 8'd0)
										SW_pos <= secret_key_a[23:16];
									else if(modulo == 8'd1)
										SW_pos <= secret_key_a[15:8];
									else if(modulo == 8'd2)
										SW_pos <= secret_key_a[7:0];
									end
		wait_for_SW_pos : SW_pos <= SW_pos;
		addition_2  : j <= (first_add + SW_pos);
		wait_for_j : {j, enable} <= {j, 1'b0} ;
		get_value_sj : {address, enable} <= {j, enable};
		wait_sj : {address, enable,data_j}<= {address, enable, q};
		wait_sj_again : data_j <= q;
		swap_i : {address,data} <= {i, data_j};
		wait_swap_i : {address, data, enable} <= {address, data, 1'b1};
		wait_again_swap_i : {address, data, enable} <= {address, data, enable};
		swap_j : {address, data, enable} <= {j, data_i,enable};
		wait_swap_j : {address, data, enable} <= {j, data_i,enable};
		wait_again_swap_j : {address, data, enable} <= {j, data_i, enable};
		increment_i : { i, address, data, enable} <= {(i+1'b1), address, data, enable};
		wait_for_increment : {i, enable} <= {i, 1'b0};
		finish_2a : {i, j, enable, address, data} <= {8'b0, 8'b0, 1'b0, 8'b0, 8'b0};
		//start of task_2b
		
		start_2b :	{i, j, k, enable, address, data, enable_2b} <= {i, j, k, enable, address, data, enable_2b};
		increment_i_2b : i <= i+1'b1;
		wait_inc_2b : i<= i;
		read_si_2b 	: {address, enable} <= {i, enable};	
		wait_si_2b 	: {address, enable} <= {address, enable};				
		wait_si_again_2b : data_si <= q;
		calculate_j_2b : {j,data_si} <= {(j + data_si), data_si};			
		wait_j_2b : j <= j;
		read_sj_2b : address <= j;
		wait_sj_2b : address <= address;
		wait_sj_again_2b :  data_sj <= q;
		swap_si_2b : {data_sj, address, data} <= {data_sj, i, data_sj};		
		wait_swap_si_2b : {address, data, enable} <= {address, data, 1'b1};
		wait_again_swap_si_2b : {address, data, enable} <= {address, data, enable};	
		swap_j_2b : {address, data, enable} <= {j, data_si, enable};
		wait_swap_sj_2b : {address, data, enable} <= {address, data, enable};
		wait_again_swap_sj_2b : {address, data, enable} <= {address, data, enable};	
		addition_1_2b : {data_f, enable} <= {(data_si + data_sj), 1'b0};				
		read_sij_2b : {data_f, enable} <= {data_f, enable};					
		wait_sij_2b : address <= data_f;					
		wait_again_sij_2b : {address, enable}	<= {data_f, enable};		
		assign_f_2b : f <= q;					
		wait_assign_2b : f <= f;			
		read_encrypt_2b : read_address_2b <= k; 
		wait_encrypt_2b : read_address_2b <= read_address_2b; 		
		wait_again_encrypt_2b : data_dec_k <= (f ^ read_data_2b);
		XOR_2b : data_dec_k <= data_dec_k;	
		check_valid_data : data_dec_k <= data_dec_k;
		wait_check_valid_data : data_dec_k <= data_dec_k;
		wait_XOR_2b : {write_data_2b, write_address_2b} <= {data_dec_k, k};
		write_dec_data_2b  : {write_data_2b, write_address_2b} <= {data_dec_k, k};				
		wait_write_dec_data_2b : {write_data_2b, write_address_2b, enable_2b} <= {data_dec_k, k, 1'b1};
		wait_again_write_dec_data_2b : {write_data_2b, write_address_2b, enable_2b} <= {write_data_2b, write_address_2b, enable_2b};
		increment_k_2b : {k, enable_2b} <= {(k+1'b1), 1'b0}; 
		increment_secret_key : {secret_key_a[23:22],secret_key_a[21:0], enable_2b,k} <= {2'b0, (secret_key_a[21:0] + 1'b1), enable_2b,8'b0};
		wait_increment_secret_key : {secret_key_a, k} <= {secret_key_a, k};
		fail : LEDR[9] <= 1'b1; 
		done_cracking : LEDR <= 10'b1;


		default : {i, j, modulo, enable, data_i, data_j, counter} <= {8'b0, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'b0};
endcase
end
end



s_memory S(.address(address), 
		.clock(CLOCK_50),
		.data(data),
		.wren(enable),
		.q(q));  //S_memory as specified in the file
		
read_memory read(.address(read_address_2b), 
						.clock(CLOCK_50), 
						.q(read_data_2b)); //ROM where the encrypted message is stored 

r_memory R(.address(write_address_2b), 
				.clock(CLOCK_50),
				.data(write_data_2b), 
				.wren(enable_2b), 
				.q(q_2b));  //RAM where the decrypted message will be stored
		

endmodule
		
	
	
