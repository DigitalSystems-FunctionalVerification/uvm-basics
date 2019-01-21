/*
 this flat sequence injects 'npackets' into a single port 'port'   
*/
class basic_seq extends base_vseq; 
`uvm_object_utils(basic_seq)

// sequence configuration 
seq_config cfg;

function new(string name = "basic_seq");
  super.new(name);
endfunction: new

task pre_body();
  super.pre_body();
  //`uvm_info("basic_seq", get_sequencer(), UVM_HIGH)
  if(!uvm_config_db #(seq_config)::get(get_sequencer(), "", "config", cfg))
    `uvm_fatal(get_type_name(), "config config_db lookup failed")
endtask


task body;
  packet_t tx;
  //$display("NAME ---- %s",get_full_name());
  //if ( !uvm_config_db#(seq_config)::get(get_sequencer(), "", "config", cfg) )
  //  `uvm_error(get_type_name(), "Failed to get seq_config object")
  repeat(cfg.npackets)
  begin
    tx = packet_t::type_id::create("tx");
    // set the driver port where these packets will be injected
    tx.dport = cfg.port;
    // disable packets with zero payload
    //tx.w_zero = 0;
    start_item(tx);
    if( ! tx.randomize() with {
        tx.p_size == cfg.p_size;
        //tx.header == cfg.header;
        //tx.cycle2send == cfg.cycle2send;
        //tx.cycle2flit == cfg.cycle2flit;
      }
    )
      `uvm_error("rand", "invalid seq item randomization"); 
    `uvm_info("basic_seq", cfg.convert2string(), UVM_HIGH)

    finish_item(tx);
  end
endtask: body

endclass: basic_seq

