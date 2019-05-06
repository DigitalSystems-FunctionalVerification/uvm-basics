/*
//  File: add_sub_seq_item.sv
//  Author: Darlan Alves Jurak
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

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