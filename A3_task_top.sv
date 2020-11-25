module A3_task_top

#( parameter DESER_W = 8 )

(
  input logic                clk_i, srst_i,
  input logic                data_val_i,
  input logic                data_i,
  
  output logic [DESER_W-1:0] deser_data_o,
  output logic               deser_data_val_o
);

logic               srst_i_buf;
logic               data_val_i_buf;
logic               data_i_buf;
logic [DESER_W-1:0] deser_data_o_buf;  
logic               deser_data_val_o_buf;


// port mapping
A3_task #( DESER_W ) A3_task_core_unit
(
  .clk_i            ( clk_i ),
  .srst_i           ( srst_i_buf ),
  .data_val_i       ( data_val_i_buf ),
  .data_i           ( data_i_buf ),
  .deser_data_o     ( deser_data_o_buf ),
  .deser_data_val_o ( deser_data_val_o_buf )
);

//data locking
always_ff @( posedge clk_i )
  begin
    srst_i_buf       <= srst_i;
    data_val_i_buf   <= data_val_i;
    data_i_buf       <= data_i;
    deser_data_o     <= deser_data_o_buf;
    deser_data_val_o <= deser_data_val_o_buf;
  end

endmodule
