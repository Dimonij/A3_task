// deserialyzer with parameterized output data width
module A3_task

#( parameter DESER_W = 8 )

(
  input logic                clk_i, srst_i, 
  input logic                data_val_i, 
  input logic                data_i,
  
  output logic [DESER_W-1:0] deser_data_o,
  output logic               deser_data_val_o
);  

logic [DESER_W-1:0]             data_temp;
logic                           sh_flag, start_flag;
logic [$clog2( DESER_W ) + 1:0] sh_count;

//data lock
always_ff @( posedge clk_i )
  begin
    if ( srst_i ) 
      begin
        data_temp        <= 0;
        deser_data_o     <= 0;
        deser_data_val_o <= 0;
        sh_count         <= 0;
        sh_flag          <= 0;
      end
    else 
      if ( ( data_val_i ) && ( sh_count <= ( DESER_W -1 ) ) )
        begin
          data_temp[ ( ( DESER_W - 1 ) - sh_count ) ] <= data_i;
          if ( sh_count == ( DESER_W - 1 ) )
            sh_flag <= 1;
          sh_count  <= sh_count + 1;
        end
      else 
        if ( sh_flag )
          begin
            deser_data_o     <= data_temp;
            deser_data_val_o <= 1;
            sh_flag          <= 0;
          end
        else  
          begin
            deser_data_val_o <= 0;
            sh_count         <= 0;
            data_temp        <= 0;
            deser_data_o     <= 0;
          end

  end

endmodule
