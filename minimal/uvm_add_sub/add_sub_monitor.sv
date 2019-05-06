/*
//  File: add_sub_monitor.sv
//  Author: Darlan Alves Jurak
*/

import uvm_pkg::*;
`include "uvm_macros.svh"
import UVM_ADD_SUB::*;

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