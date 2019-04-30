/*
An absolut minimal working UVM example adapted from
https://www.edaplayground.com/s/example/546
to work with Questa

Alexandre Amory 
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

//----------------
// Sequence Item
//----------------
class Seq_Item extends uvm_sequence_item;
  //Control Information
  rand bit       doAdd0;
   
  //Payload Information
  rand bit [7:0] a0;
  rand bit [7:0] b0;
     
  //Utility and Field macros,
  `uvm_object_utils_begin(Seq_Item)
    `uvm_field_int(doAdd0,UVM_ALL_ON)
    `uvm_field_int(a0,UVM_ALL_ON)
    `uvm_field_int(b0,UVM_ALL_ON)
  `uvm_object_utils_end
   
  //Constructor
  function new(string name = "Seq_Item");
    super.new(name);
  endfunction
   
endclass : Seq_Item

interface add_sub_if;

  logic       clk;
  bit         doAdd0;
  bit   [7:0] a0;
  bit   [7:0] b0;
  bit   [7:0] result0;
  
endinterface //add_sub_if

//----------------
// Driver
//----------------
class Driver extends uvm_driver;
 
  virtual add_sub_if vif;
  `uvm_component_utils(Driver) // create() and get_type_name()
 
  // Constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase); // phase: synchronizing mechanism for the environment
    super.build_phase(phase);

    if (!uvm_config_db#(virtual add_sub_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
    else
    begin
      // Get the interface from the resource database.
      assert(uvm_resource_db#(virtual add_sub_if)::read_by_name(get_full_name(), "add_sub_if", vif));
    end

  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask // 

  virtual task drive();

    int a = 8'h2, b = 8'h3; // applies 2 + 3 as stimuli

    // req.print();

    @(vif.cb);
    vif.cb.a0     = a;    // req.a0;
    vif.cb.b0     = b;    // req.b0;
    vif.cb.doAdd0 = 1'b1; // req.doAdd0;
    repeat(2) @(vif.cb);
    `uvm_info("RESULT", $sformatf("%0d + %0d = %0d",
      a, b, vif.cb.result0), UVM_LOW); // gets 5 as response
    
  endtask //

endclass : Driver

//----------------
// environment env
//----------------
class env extends uvm_env;

  virtual add_sub_if m_if;
  // Driver driver;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    `uvm_info("LABEL", "Started connect phase.", UVM_HIGH);

    // Conect driver
    // if(get_is_active() == UVM_ACTIVE)begin
    //   driver.seq_item_port.connect(sequencer.seq_item_export);
    // end

    `uvm_info("LABEL", "Finished connect phase.", UVM_HIGH);
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("LABEL", "Started run phase.", UVM_HIGH);
    begin
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
  add_sub_if  duv_if(clk);
  env         environment;
  Driver      driver;

  ADD_SUB dut(
  .clk(clk),
  .a0(duv_if.a0),
  .b0(duv_if.b0),
  .doAdd0(duv_if.doAdd0),
  .result0(duv_if.result0)
);

  initial begin
    environment = new("env");
    driver = new("drv", environment);
    // Put the interface into the resource database.
    uvm_resource_db#(virtual add_sub_if)::set("env", "add_sub_if", duv_if);
    clk = 0;
    run_test();
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
