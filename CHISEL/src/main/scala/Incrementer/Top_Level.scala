package Incrementer

import stream_PU._
import UART._

import chisel3._
import chisel3.util._
import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
import firrtl.options.TargetDirAnnotation
import firrtl.transforms.FlattenAnnotation

class Top_Level[T <: Bits](dataType : T, pFrameSize: Int) extends Module {
    val io = IO(new Bundle {
        val i_dv    = Input(Bool())
        val i_data  = Input(dataType)
        val i_ready = Input(Bool())
        val o_dv    = Output(Bool())
        val o_data  = Output(dataType)
        val o_ready = Output(Bool())
    })

    val sock1 = Module(new Socket(dataType, pFrameSize))
    val sock2 = Module(new Socket(dataType, pFrameSize))
    
    val tx = Module(new UART_Tx(baudRate = 5000000, clockFreq = 50000000))
    val rx = Module(new UART_Rx(baudRate = 5000000, clockFreq = 50000000))

    val fpga = Module(new Top_FPGA(dataType, pFrameSize))


    // in => sock1 => tx => fpga => tx => sock2 => out

    // in => sock1
    sock1.io.enq.valid := io.i_dv
    sock1.io.enq.bits  := io.i_data
    io.o_ready := sock1.io.enq.ready

    // sock1 => tx
    sock1.io.deq <> tx.io.in

    // tx => fpga
    fpga.io.i_data := tx.io.tx

    // fpga => rx
    rx.io.rx := fpga.io.o_data

    // rx => sock2
    rx.io.out <> sock2.io.enq

    // sock2 => out
    io.o_dv := sock2.io.deq.valid
    io.o_data := sock2.io.deq.bits
    sock2.io.deq.ready := io.i_ready

}

object Top_LevelMain extends App {
  val stage = new ChiselStage
  stage.execute(
    Array(
    "-X", "verilog", 
    "-e", "verilog",
    "--target-dir", "../VERILOG/generated/Incrementer"), 
  Seq(ChiselGeneratorAnnotation(() => new Top_Level(UInt(8.W), 20)))
  )
}