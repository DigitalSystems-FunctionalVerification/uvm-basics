/*
//  File: add_sub_sequencer.sv
//  Author: Darlan Alves Jurak
*/

import uvm_pkg::*;
`include "uvm_macros.svh"
import UVM_ADD_SUB::*;

//----------------
// sequencer add_sub_sequencer
//----------------
class add_sub_sequencer extends uvm_sequencer#(add_sub_seq_item);

  `uvm_sequencer_utils(add_sub_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()
  
endclass //add_sub_sequencer extends uvm_sequencer