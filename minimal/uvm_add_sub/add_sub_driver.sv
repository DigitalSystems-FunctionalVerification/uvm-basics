/*
//  File: add_sub_driver.sv
//  Author: Darlan Alves Jurak
*/

import uvm_pkg::*;
`include "uvm_macros.svh"
import UVM_ADD_SUB::*;

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