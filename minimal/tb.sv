/*
An absolut minimal working UVM example adapted from
https://www.edaplayground.com/s/example/546
to work with Questa

Alexandre Amory 
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

interface add_sub_if(input logic clk);

  //Control Information
  bit doAdd;
  //Payload Information
  bit [7:0] a;
  bit [7:0] b;
  //Analysis Information
  bit [8:0] result;

  clocking cb_driver @(posedge clk);

    //Control Information
    output doAdd;
    //Payload Information
    output a;
    output b;

  endclocking  

  clocking cb_monitor @(posedge clk);

    //Analysis Information
    input result;

  endclocking  

  // ??
  modport DRIVER  (clocking cb_driver);
  modport MONITOR (clocking cb_monitor);
  
endinterface //add_sub_if

//----------------
// sequence item add_sub_seq_item
//----------------
class add_sub_seq_item extends uvm_sequence_item;

  //Control Information
  rand  bit doAdd;

  //Payload Information
  rand  bit [7:0] a;
  rand  bit [7:0] b;

  //Analysis Information
        bit [8:0] result;

  //Utility and Field macros
  `uvm_object_utils_begin(add_sub_seq_item)
    `uvm_field_int(doAdd, UVM_ALL_ON)
    `uvm_field_int(a,     UVM_ALL_ON)
    `uvm_field_int(b,     UVM_ALL_ON)
    `uvm_field_int(result,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //Constructor
  function new(string name = "add_sub_seq_item");
    super.new(name);    
  endfunction

endclass

//----------------
// sequence add_sub_sequence
//----------------
class add_sub_sequence extends uvm_sequence#(add_sub_seq_item);

  `uvm_object_utils(add_sub_sequence)
  
  function new(string name = "add_sub_sequence");
    super.new(name);
  endfunction //new()

  virtual task body();
    
    `uvm_do(req); // execute 6 steps of handshaking with driver

  endtask //body 

endclass//add_sub_sequence

//----------------
// sequencer add_sub_sequencer
//----------------
class add_sub_sequencer extends uvm_sequencer#(add_sub_seq_item);

  `uvm_sequencer_utils(add_sub_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()
  
endclass //add_sub_sequencer extends uvm_sequencer

//----------------
// driver add_sub_driver
//----------------
class add_sub_driver extends uvm_driver #(add_sub_seq_item);

  `uvm_component_utils(add_sub_driver);

  virtual interface add_sub_if vif;
  
  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_sub_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", {"virtual interface must be set for:", get_full_name(), ".vif"});
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);

    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
    
  endtask

  virtual task drive();

    req.print();
    @(posedge vif.clk);
      vif.cb_driver.doAdd  <= req.doAdd;
      vif.cb_driver.a      <= req.a;
      vif.cb_driver.b      <= req.b;
    
  endtask //drive
  
endclass //add_sub_driver extends uvm_driver

//----------------
// monitor add_sub_monitor
//----------------
class add_sub_monitor extends uvm_monitor;

  `uvm_component_utils(add_sub_monitor);

  virtual add_sub_if vif;
  uvm_analysis_port #(add_sub_seq_item) item_collected_port;
  add_sub_seq_item trans_collected;
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_sub_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", {"Virtual interface must be set for:", get_full_name(),".vif"})
  endfunction : build_phase
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction //new()

endclass //add_sub_monitor extends uvm_monitor

//----------------
// agent add_sub_agent
//----------------
class add_sub_agent extends uvm_agent;

  `uvm_component_utils(add_sub_agent)

  add_sub_driver    driver;
  add_sub_sequencer sequencer;
  add_sub_monitor   monitor;
  
  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(get_is_active() == UVM_ACTIVE)begin
      driver    = add_sub_driver::type_id::create("driver", this);
      sequencer = add_sub_sequencer::type_id::create("sequencer", this);
    end

    monitor = add_sub_monitor::type_id::create("monitor", this);
    
  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);

    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
  endfunction

  // Constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()

endclass //add_sub_agent extends uvm_agent

//----------------
// scoreboard add_sub_scoreboard
//----------------
class add_sub_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(add_sub_scoreboard);
  //Declare port
  uvm_analysis_imp#(add_sub_seq_item, add_sub_scoreboard) item_collected_export;
  
  //Constructor
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //Creating
    item_collected_export = new("item_collected_export", this);

  endfunction

  virtual function void write(add_sub_seq_item pkt);
    $display("SCB:: Packet received:");
    pkt.print();
  endfunction

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()

endclass //add_sub_scoreboard extends uvm_scoreboard

//----------------
// environment add_sub_env
//----------------
// class add_sub_env extends uvm_env;

//   `uvm_component_utils(add_sub_env);

//   add_sub_agent agent;

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
    
//     agent = add_sub_agent::type_id::create("add_sub_agent", this);

//   endfunction
  
//   function new(string name, uvm_component parent);
//     super.new(name, parent);
//   endfunction //new()

// endclass //add_sub_env extends uvm_env

//----------------
// test
//----------------
// class add_sub_test extends uvm_test;
 
//   `uvm_component_utils(add_sub_test)
 
//   add_sub_env       env;
//   add_sub_sequence  seq;
 
//   function new(string name = "add_sub_test",uvm_component parent=null);
//     super.new(name,parent);
//   endfunction : new
 
//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
 
//     env = add_sub_env::type_id::create("env", this);
//     seq = add_sub_sequence::type_id::create("seq");

//   endfunction : build_phase
 
//   task run_phase(uvm_phase phase);
//     seq.start(env.agent.sequencer);
//   endtask : run_phase
 
// endclass : add_sub_test



//----------------
// environment env
//----------------
class env extends uvm_env;

  virtual add_sub_if m_if;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    `uvm_info("LABEL", "Started connect phase.", UVM_HIGH);
    // Get the interface from the resource database.
    assert(uvm_resource_db#(virtual add_sub_if)::read_by_name(get_full_name(), "add_sub_if", m_if));
    `uvm_info("LABEL", "Finished connect phase.", UVM_HIGH);
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("LABEL", "Started run phase.", UVM_HIGH);
    begin
      int a = 8'h2, b = 8'h3; // applies 2 + 3 as stimuli
      @(m_if.cb_driver);
      m_if.cb_driver.a <= a;
      m_if.cb_driver.b <= b;
      m_if.cb_driver.doAdd <= 1'b1;
      repeat(2) @(m_if.cb_driver);
      `uvm_info("RESULT", $sformatf("%0d + %0d = %0d",
        a, b, m_if.result), UVM_LOW); // gets 5 as response
    end
    `uvm_info("LABEL", "Finished run phase.", UVM_HIGH);
    phase.drop_objection(this);
  endtask: run_phase
  
endclass

//-----------
// module top
//-----------
module top;

  bit         clk;
  bit         rst;
  add_sub_if  duv_if(clk);
  // add_sub_env environment;
  env         env;

  ADD_SUB dut(
  .clk(clk),
  .a0(duv_if.a),
  .b0(duv_if.b),
  .doAdd0(duv_if.doAdd),
  .result0(duv_if.result)
  );

  add_sub_seq_item seq_item;

  initial begin

    env = new("env");

    // Put the interface into the resource database.
    uvm_resource_db#(virtual add_sub_if)::set("env", "add_sub_if", duv_if);
    clk = 0;
    run_test();

    // seq_item = add_sub_seq_item::type_id::create();
    // seq_item.randomize();
    // seq_item.print();

  end
  
  initial begin
    forever begin
      #(50) clk = ~clk;
    end
  end
  
  initial begin
    // Dump waves
    $dumpvars(0, top);
  end
  
endmodule

// module top;
   
//   //clock and reset signal declaration
//   bit clk;
//   bit reset;
   
//   //clock generation
//   always #5 clk = ~clk;
   
//   //reset Generation
//   initial begin
//     reset = 1;
//     #5 reset =0;
//   end
   
//   //creatinng instance of interface, inorder to connect DUT and testcase
//   add_sub_if duv_if(clk,reset);
   
//   //DUT instance, interface signals are connected to the DUT ports
//   ADD_SUB dut(
//   .clk(clk),
//   .a0(duv_if.a),
//   .b0(duv_if.b),
//   .doAdd0(duv_if.doAdd),
//   .result0(duv_if.result)
//   );
   
//   //enabling the wave dump
//   initial begin
//     uvm_config_db#(virtual add_sub_if)::set(uvm_root::get(),"*","vif",duv_if);
//     $dumpfile("dump.vcd"); $dumpvars;
//   end
   
//   initial begin
//     run_test();
//   end
// endmodule