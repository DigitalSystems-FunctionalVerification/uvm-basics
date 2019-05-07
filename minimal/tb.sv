/*
An absolut minimal working UVM example adapted from
https://www.edaplayground.com/s/example/546
to work with Questa

Alexandre Amory 
*/

import uvm_pkg::*;
`include "uvm_macros.svh"

//-------------------------------------------------------------------------
//						add_sub_interface
//-------------------------------------------------------------------------
interface add_sub_if(input logic clk, rst);

  //---------------------------------------
  // declaring the signals
  //---------------------------------------
  //Control Information
  bit doAdd;
  //Payload Information
  bit [7:0] a;
  bit [7:0] b;
  //Analysis Information
  bit [8:0] result;

  //---------------------------------------
  // driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    default input #1 output #1;

    //Control Information
    output doAdd;
    //Payload Information
    output a;
    output b;

  endclocking  

  //---------------------------------------
  // monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;

    //Control Information
    input doAdd;
    //Payload Information
    input a;
    input b;

    //Analysis Information
    input result;

  endclocking  

  //---------------------------------------
  // driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb, input clk, rst);

  //---------------------------------------
  // monitor clocking block
  //---------------------------------------
  modport MONITOR (clocking monitor_cb, input clk, rst);
  
endinterface //add_sub_if

//-------------------------------------------------------------------------
//						add_sub_seq_item
//-------------------------------------------------------------------------
class add_sub_seq_item extends uvm_sequence_item;

  //---------------------------------------
  //data and control fields
  //---------------------------------------
  //Control Information
  rand  bit doAdd;

  //Payload Information
  rand  bit [7:0] a;
  rand  bit [7:0] b;

  //Analysis Information
        bit [8:0] result;

  //---------------------------------------
  // Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(add_sub_seq_item)
    `uvm_field_int(doAdd, UVM_ALL_ON)
    `uvm_field_int(a,     UVM_ALL_ON)
    `uvm_field_int(b,     UVM_ALL_ON)
    `uvm_field_int(result,UVM_ALL_ON)
  `uvm_object_utils_end
  
  function void post_randomize();    
    $display("Randomized values: doAdd: ", doAdd, "Op1: ", a, "Op2: ", b);
  endfunction

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name = "add_sub_seq_item");
    super.new(name);    
  endfunction

endclass

//-------------------------------------------------------------------------
//						add_sub_sequence
//-------------------------------------------------------------------------
//=========================================================================
// add_sub_sequence - random stimulus 
//=========================================================================
class add_sub_sequence extends uvm_sequence#(add_sub_seq_item);

  `uvm_object_utils(add_sub_sequence)
  
  //--------------------------------------- 
  // Constructor
  //---------------------------------------
  function new(string name = "add_sub_sequence");
    super.new(name);
  endfunction //new()

  // `uvm_declare_p_sequencer(add_sub_sequencer)
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
   repeat(2) begin
    req = add_sub_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass
//=========================================================================

//-------------------------------------------------------------------------
//						add_sub_sequencer
//-------------------------------------------------------------------------
class add_sub_sequencer extends uvm_sequencer#(add_sub_seq_item);

  `uvm_component_utils(add_sub_sequencer) 

  //--------------------------------------- 
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

  //--------------------------------------- 
  // Connect phase
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction: connect_phase

  //--------------------------------------- 
  // Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase

  //--------------------------------------- 
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()
  
endclass //add_sub_sequencer extends uvm_sequencer

//-------------------------------------------------------------------------
//						add_sub_driver
//-------------------------------------------------------------------------
class add_sub_driver extends uvm_driver #(add_sub_seq_item);

  `uvm_component_utils(add_sub_driver);

  virtual interface add_sub_if vif;
  
  //--------------------------------------- 
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()

  //--------------------------------------- 
  // Build phase
  //---------------------------------------  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual add_sub_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", {"virtual interface must be set for:", get_full_name(), ".vif"});
  endfunction: build_phase

  //--------------------------------------- 
  // Run phase
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);

    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
    
  endtask

  virtual task drive();

    req.print();
    @(posedge vif.DRIVER.clk);
      vif.DRIVER.driver_cb.doAdd  <= req.doAdd;
      vif.DRIVER.driver_cb.a      <= req.a;
      vif.DRIVER.driver_cb.b      <= req.b;
    
  endtask //drive
  
endclass //add_sub_driver extends uvm_driver

//-------------------------------------------------------------------------
//						add_sub_monitor
//-------------------------------------------------------------------------
class add_sub_monitor extends uvm_monitor;

  `uvm_component_utils(add_sub_monitor);

  //--------------------------------------- 
  // Interface, port, and seq_item
  //---------------------------------------
  virtual add_sub_if                    vif;
  uvm_analysis_port #(add_sub_seq_item) item_collected_port;
  add_sub_seq_item                      trans_collected;
  
  //--------------------------------------- 
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(virtual add_sub_if)::get(this, "", "vif", vif))
      `uvm_fatal("NO_VIF", {"Virtual interface must be set for:", get_full_name(),".vif"})

  endfunction : build_phase

  //--------------------------------------- 
  // Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    monitor();
    
  endtask //run_phase
  
  virtual task monitor ();
    forever begin

      @(posedge vif.MONITOR.clk);
        trans_collected.doAdd   = vif.monitor_cb.doAdd;
        trans_collected.a       = vif.monitor_cb.a;
        trans_collected.b       = vif.monitor_cb.b;
        trans_collected.result  = vif.monitor_cb.result;

      item_collected_port.write(trans_collected);

    end
  endtask //monitor

  //--------------------------------------- 
  // Constructor phase
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);

    trans_collected = new();
    item_collected_port = new("item_collected_port", this);

  endfunction //new()

endclass //add_sub_monitor extends uvm_monitor

//-------------------------------------------------------------------------
//						add_sub_agent
//-------------------------------------------------------------------------
class add_sub_agent extends uvm_agent;

  `uvm_component_utils(add_sub_agent)

  // uvm_analysis_port#(add_sub_seq_item) agent_mon_port;
  //--------------------------------------- 
  // Active agent's components
  //---------------------------------------
  add_sub_driver    driver;
  add_sub_sequencer sequencer;
  add_sub_monitor   monitor;
  
  //--------------------------------------- 
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // agent_mon_port = new("agent_mon_port", this);

    // passive agents have monitor only
    monitor = add_sub_monitor::type_id::create("monitor", this);
    
    //creating driver and sequencer only for ACTIVE agent
    if(get_is_active() == UVM_ACTIVE)begin  // monitor active
      driver    = add_sub_driver::type_id::create("driver", this);
      sequencer = add_sub_sequencer::type_id::create("sequencer", this);
    end
    
  endfunction

  //---------------------------------------  
  // Connect phase - connecting the driver and sequencer port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect driver monitor to sequencer port
    if(get_is_active() == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    
    // connect monitor port to agent port
    // monitor.item_collected_port.connect(agent_mon_port);

  endfunction

  //---------------------------------------  
  // Constructor
  //---------------------------------------  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()

endclass //add_sub_agent extends uvm_agent

//-------------------------------------------------------------------------
//						add_sub_scoreboard
//-------------------------------------------------------------------------
// `uvm_analysis_imp_decl(_add_sub)
class add_sub_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(add_sub_scoreboard);
  //Declare port
  uvm_analysis_imp#(add_sub_seq_item, add_sub_scoreboard) item_collected_export;

  //---------------------------------------
  // declaring pkt_qu to store the pkt's recived from monitor
  //---------------------------------------
  add_sub_seq_item pkt_qu[$];

  // uvm_analysis_export#(add_sub_seq_item)    get_export_add_sub;
  // uvm_tlm_analysis_fifo#(add_sub_seq_item)  get_add_sub;
  
  //---------------------------------------
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Creating
    item_collected_export = new("item_collected_export", this);

  endfunction

  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write(add_sub_seq_item pkt);
    pkt.print();
    pkt_qu.push_back(pkt);
  endfunction : write

  //---------------------------------------
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()

endclass //add_sub_scoreboard extends uvm_scoreboard

//-------------------------------------------------------------------------
//						add_sub_environment
//-------------------------------------------------------------------------
class add_sub_env extends uvm_env;

  `uvm_component_utils(add_sub_env);

  //---------------------------------------
  // agent and scoreboard instance
  //---------------------------------------
  add_sub_agent       agent;
  add_sub_scoreboard  scoreboard;

  //--------------------------------------- 
  // Build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent       = add_sub_agent::type_id::create("add_sub_agent", this);
    scoreboard  = add_sub_scoreboard::type_id::create("add_sub_scoreboard", this);

  endfunction

  //---------------------------------------
  // Connect phase - connecting monitor and scoreboard port
  //---------------------------------------
  function void connect_phase(uvm_phase phase);
    agent.monitor.item_collected_port.connect(scoreboard.item_collected_export);
  endfunction : connect_phase
  
  //--------------------------------------- 
  // Constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction //new()

endclass //add_sub_env extends uvm_env

//-------------------------------------------------------------------------
//						test
//-------------------------------------------------------------------------
class add_sub_test extends uvm_test;
 
  `uvm_component_utils(add_sub_test)
 
  //---------------------------------------
  // environment instance 
  //---------------------------------------
  add_sub_env       env;

  //---------------------------------------
  // sequence instance 
  //--------------------------------------- 
  add_sub_sequence seq;
 
  //--------------------------------------- 
  // Build phase
  //---------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
 
    // Create the environment
    env = add_sub_env::type_id::create("env", this);
    // Create the sequence
    seq = add_sub_sequence::type_id::create("seq");

  endfunction : build_phase

  //---------------------------------------
  // end_of_elabaration phase
  //---------------------------------------  
  virtual function void end_of_elaboration();
    //print's the topology
    print();
  endfunction

  //---------------------------------------
  // end_of_elabaration phase
  //---------------------------------------   
 function void report_phase(uvm_phase phase);
   uvm_report_server svr;
   super.report_phase(phase);
   
   svr = uvm_report_server::get_server();
   if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
    else begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
  endfunction
 
  //--------------------------------------- 
  // Run phase
  //---------------------------------------
  task run_phase(uvm_phase phase);

    phase.raise_objection(this);
      seq.start(env.agent.sequencer);
    phase.drop_objection(this);
    
    //set a drain-time for the environment if desired
    phase.phase_done.set_drain_time(this, 50);

  endtask : run_phase

  //--------------------------------------- 
  // Constructor
  //---------------------------------------
  function new(string name = "add_sub_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction : new
 
endclass : add_sub_test

//----------------
// environment env
//----------------
// class env extends uvm_env;

//   `uvm_component_utils(env);

//   virtual add_sub_if m_if;

//   add_sub_agent       agent;
//   add_sub_scoreboard  scoreboard;

//   function new(string name, uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);

//     // agent       = add_sub_agent::type_id::create("agent", this);
//     // scoreboard  = add_sub_scoreboard::type_id::create("scoreboard", this);
    
//   endfunction
  
//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);    
//     `uvm_info("LABEL", "Started connect phase.", UVM_HIGH);
//     // Get the interface from the resource database.
//     assert(uvm_resource_db#(virtual add_sub_if)::read_by_name(get_full_name(), "add_sub_if", m_if));
//     `uvm_info("LABEL", "Finished connect phase.", UVM_HIGH);
//   endfunction: connect_phase

//   task run_phase(uvm_phase phase);
//     phase.raise_objection(this);
//     `uvm_info("LABEL", "Started run phase.", UVM_HIGH);
//     begin
//       int a = 8'h2, b = 8'h3; // applies 2 + 3 as stimuli
//       @(m_if.driver_cb);
//       m_if.driver_cb.a <= a;
//       m_if.driver_cb.b <= b;
//       m_if.driver_cb.doAdd <= 1'b1;
//       repeat(2) @(m_if.driver_cb);
//       `uvm_info("RESULT", $sformatf("%0d + %0d = %0d",
//         a, b, m_if.result), UVM_LOW); // gets 5 as response
//     end
//     `uvm_info("LABEL", "Finished run phase.", UVM_HIGH);
//     phase.drop_objection(this);
//   endtask: run_phase
  
// endclass

//-----------
// module top
//-----------
// module top;

//   // clock and reset
//   bit clk;
//   bit rst;

//   // interface to connect DUT and testcases
//   add_sub_if  duv_if(clk);

  
//   env         env;

//   ADD_SUB dut(
//   .clk(clk),
//   .a0(duv_if.a),
//   .b0(duv_if.b),
//   .doAdd0(duv_if.doAdd),
//   .result0(duv_if.result)
//   );

//   add_sub_seq_item seq_item;

//   initial begin

//     // Put the interface into the resource database.
//     uvm_resource_db#(virtual add_sub_if)::set("env", "add_sub_if", duv_if);
    
//     env = new("env");
    
//     clk = 0;
//     run_test();

//     // seq_item = add_sub_seq_item::type_id::create();
//     // seq_item.randomize();
//     // seq_item.print();

//   end
  
//   initial begin
//     forever begin
//       #(50) clk = ~clk;
//     end
//   end
  
//   initial begin
//     // Dump waves
//     $dumpvars(0, top);
//   end
  
// endmodule

module top;
   
  //clock and reset signal declaration
  bit clk;
  bit reset;
   
  //clock generation
  always #5 clk = ~clk;
   
  //reset Generation
  initial begin
    reset = 1;
    #5 reset =0;
  end
   
  //creatinng instance of interface, inorder to connect DUT and testcase
  add_sub_if duv_if(clk);
   
  //DUT instance, interface signals are connected to the DUT ports
  ADD_SUB dut(
  .clk(clk),
  .a0(duv_if.a),
  .b0(duv_if.b),
  .doAdd0(duv_if.doAdd),
  .result0(duv_if.result)
  );
   
  //enabling the wave dump
  initial begin
    uvm_config_db#(virtual add_sub_if)::set(uvm_root::get(),"*","vif",duv_if);
    $dumpfile("dump.vcd"); $dumpvars;
  end
   
  initial begin
    run_test("add_sub_test");
  end
endmodule