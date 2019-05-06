/*
//  File: add_sub_sequence.sv
//  Author: Darlan Alves Jurak
*/

import uvm_pkg::*;
`include "uvm_macros.svh"
import UVM_ADD_SUB::*;

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