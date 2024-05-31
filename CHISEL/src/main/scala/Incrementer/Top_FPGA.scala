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
    
    val tx = Module(new UART_Tx(baudRate = 5000000, clockFreq = 50000000))
    val rx = Module(new UART_Rx(baudRate = 5000000, clockFreq = 50000000))

    rx.io.rx := io.i_data
    rx.io.out <> incr1.io.enq
    incr1.io.deq <> tx.io.in
    io.o_data := tx.io.tx

}