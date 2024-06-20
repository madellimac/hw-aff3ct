package Incrementer

import stream_PU._
import UART._

import chisel3._
import chisel3.util._

class Top_FPGA[T <: Bits](dataType : T, pFrameSize: Int) extends Module {
    val io = IO(new Bundle {
        val i_data    = Input(Bool())
        val o_data    = Output(Bool())
    })

    val incr1 = Module(new Incrementer(dataType.getWidth, pFrameSize))
    val incr2 = Module(new Incrementer(dataType.getWidth, pFrameSize))
    val incr3 = Module(new Incrementer(dataType.getWidth, pFrameSize))
    val incr4 = Module(new Incrementer(dataType.getWidth, pFrameSize))
    val sock1 = Module(new Socket(dataType, pFrameSize))
    // val sock2 = Module(new Socket(dataType, pFrameSize))
    
    val tx = Module(new UART_Tx(baudRate = 115200, clockFreq = 100000000))
    val rx = Module(new UART_Rx(baudRate = 115200, clockFreq = 100000000))

    rx.io.rx := io.i_data
    rx.io.out <> incr1.io.enq
    incr1.io.deq <> incr2.io.enq
    incr2.io.deq <> incr3.io.enq
    incr3.io.deq <> incr4.io.enq
    incr4.io.deq <> sock1.io.enq
    sock1.io.deq <> tx.io.in
    io.o_data := tx.io.tx

}