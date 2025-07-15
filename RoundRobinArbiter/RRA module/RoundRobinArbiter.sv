`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2025 01:51:17
// Design Name: 
// Module Name: RoundRobinArbiter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/////// TS_WIDTH is the bit width required to store the largest time slice any client may be assigned.

module RoundRobinArbiter # (parameter N, ts_width)(
        input logic clk,reset,
        input logic [N-1:0] req,
        output logic [N-1:0] grant
    );
    
    initial $display("[MOD]DUT instantiated");
    
    typedef enum logic {s0,s1} state_t;
    state_t state;
    logic [ $clog2(N)-1:0] ptr , i;
    logic [ ts_width-1:0] count;
    ///// Per client time slice array
    logic [N-1:0][ts_width-1:0] client_time_slice; // ? packed array

    ///// For simulation, initializing this array
    initial begin
        client_time_slice[0] = 2;
        client_time_slice[1] = 4;
        client_time_slice[2] = 3;
        client_time_slice[3] = 1;
    end
    ////// for Custom Priority 
    logic [$clog2(N)-1:0] priority_list[N];
    ////// Priority goes like this - 2 > 0 > 3 > 1
        initial begin
        priority_list[0] = 2;
        priority_list[1] = 0;
        priority_list[2] = 3;
        priority_list[3] = 1;
    end
    always_ff@(posedge clk)begin
        if(reset) begin
            state <= s0;
            count <= 0;
            ptr <= 0;
            i <= 0;
            grant <= '0;
            $display("[MOD] Reset"); 
        end
        else begin
        $display ("[MOD] Else statement");
            case (state)
                s0 : begin
                    grant <= '0;
                    $display ("[MOD] For loop begins");
                    for (int offset = 0; offset < N; offset++) begin
                        int index = (ptr + offset) % N;
                        logic [$clog2(N)-1:0] temp_i;
                        temp_i = priority_list[index];
                        
                        $display("[DBG] offset=%0d | index=%0d | temp_i=%0d | req[temp_i]=%b", offset, index, temp_i, req[temp_i]);
                        
                        if (req[temp_i]) begin
                            i <= temp_i;
                            grant[temp_i] <= 1;
                            count <= 1;
                            $display(" granted to %0d | cycle = %d", temp_i, count);
                            state <= s1;
                            break;
                        end
                    end
                  
                end
                s1 : begin                    
                    count <= count + 1;
                    $display ("[MOD] IN s1 , cycle = %d", count);                    
                    if(count == client_time_slice[i])begin
                        ptr <= (i + 1) % N;
                        count <= 0;
                        state <= s0;
                        grant <= '0;
                    end                    
                end
            endcase
        end
    end
endmodule
