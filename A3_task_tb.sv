module A3_task_tb;

localparam DESER_W = 35;
localparam VAL_BITS = ( $clog2( DESER_W ) +1 );
localparam MAX_DATA = 200;

// DUT wire
bit               d_data_i, d_data_val_i;
bit               d_deser_data_val_o;
bit [DESER_W-1:0] d_deser_data_o;

// serial transmitter wire
bit                st_data_val_i;
bit                st_ser_data_o;
bit                st_ser_data_val_o;
bit                st_busy_o;
bit [DESER_W-1:0]  st_data_i;
bit [VAL_BITS-1:0] st_data_mod_i;

// test internal signal & var & common wire
bit                clk, reset; 
bit                data_transit, data_val_transit;

int                test_counter, dut_counter;

mailbox #( bit [DESER_W-1:0]) tr_data = new();

task   data_ser_send;
  
input int iter_num;
  
  st_data_val_i = 0;
  for ( int i = 0; i <= iter_num; i++ )
    begin
      wait ( !st_busy_o );
      @( posedge clk)
        begin
          st_data_i = ( $urandom_range ( 420000000, 0 ) );
          tr_data.put( st_data_i );
          st_data_mod_i = DESER_W;
        end  
  @( posedge clk ) st_data_val_i = 1;
  @( posedge clk ) st_data_mod_i = 0;
  test_counter++;
  #10;
  end
endtask

task ser_data_recieve;

input int iter_num;
bit [DESER_W-1:0] temp_val;
   
  for ( int i = 0; i <= iter_num; i++ )
    begin
      wait ( d_deser_data_val_o );
      tr_data.get( temp_val );
      if ( temp_val == d_deser_data_o )
        begin
          dut_counter++;
          $display ( "data send = %d, data recieve = %d, at iteration = %d", temp_val, d_deser_data_o, dut_counter );
        end
      else
        begin 
          $display ( "error in data = %b, iteration = %d", temp_val, dut_counter );
          $stop;
        end  
        
      @( posedge clk );
      @( posedge clk );
    end

endtask  

// takt generator
initial 
  forever #5 clk = !clk;

// port mapping serialyzer
A2_task #( DESER_W, VAL_BITS) SER_TRST (
  .clk_i          ( clk ),
  .srst_i         ( reset ),
  .data_val_i     ( st_data_val_i ),
  .data_i         ( st_data_i ),
  .data_mod_i     ( st_data_mod_i ),
  .ser_data_val_o ( data_val_transit ),
  .ser_data_o     ( data_transit ),
  .busy_o         ( st_busy_o )
);

// port mapping DUT 
A3_task #( DESER_W) DUT (
  .clk_i            ( clk ),
  .srst_i           ( reset ),
  .data_val_i       ( data_val_transit ),
  .data_i           ( data_transit ),
  .deser_data_val_o ( d_deser_data_val_o ),
  .deser_data_o     ( d_deser_data_o )
);

// start initialization
initial 
  begin
  test_counter = 0;
  dut_counter  = 0;
    #10;
    @( posedge clk ) reset = 1'b1;
    @( posedge clk ) reset = 1'b0;	
    #10;
  
fork 
 
  data_ser_send   ( MAX_DATA );
  ser_data_recieve( MAX_DATA);
  
join

  $display( "Number send = %d", test_counter );
  $display( "Number recived = %d", dut_counter );
  $display( "Test sucsessful!" );
  $stop;
end
  
endmodule

