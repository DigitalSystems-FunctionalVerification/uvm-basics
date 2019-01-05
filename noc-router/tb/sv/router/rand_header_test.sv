/*
simple test that injects 10 packets into the west port targeting random routers
*/
class rand_header_test extends base_test;
`uvm_component_utils(rand_header_test)

function new (string name, uvm_component parent);
  super.new(name,parent);
endfunction : new

task run_phase(uvm_phase phase);
  rand_header_seq seq;
  seq_config cfg;

  // configuring seqe=uence parameters
  cfg = seq_config::type_id::create("seq_cfg");
  assert(cfg.randomize() with { 
      // number of packets to be simulated
      npackets == 10; 
      // set the timing behavior of the sequence
      cycle2send == 1;
      cycle2flit == 0;
      // this seq will inject packets into the NORTH port only
      port == router_pkg::WEST;
      // only small packets
      p_size == packet_t::SMALL;
    }
  );

  phase.raise_objection(this);

  // create the sequence and initialize it 
  seq = rand_header_seq::type_id::create("seq");
  init_vseq(seq); 
  seq.set_seq_config(cfg);

  assert(seq.randomize());

  seq.start(null);  

  // end the simulation a little bit latter
  phase.phase_done.set_drain_time(this, 100ns);
  phase.drop_objection(this);
endtask

endclass: rand_header_test
