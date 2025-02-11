package Viterbi

import stream_PU._
import UART._

import chisel3._
import chisel3.util._
import _root_.circt.stage.{ChiselStage}
// import chisel3.stage.{ChiselStage, ChiselGeneratorAnnotation}
// import firrtl.options.TargetDirAnnotation
// import firrtl.transforms.FlattenAnnotation

class Top_FPGA[T <: Data](dataType : T, pFrameSize: Int) extends Module {
    val io = IO(new Bundle {
        val i_data    = Input(Bool())
        val o_data    = Output(Bool())
    })

    // A Viterbi decoder between two sockets

    //val polynomial = Array("o13".U, "o15".U, "o10".U)
    // val Q_LLR = 3

    // val polynomial = Array(Integer.parseInt("13", 8), Integer.parseInt("15", 8))
    val Q_LLR = 4
    val K = pFrameSize

    val octal_poly: Array[String] = Array("5", "7")
    // val octal_poly: Array[String] = Array("13", "15")
    // val octal_poly: Array[String] = Array("11", "13", "15")
    // val octal_poly: Array[String] = Array("133", "155")
    // val octal_poly: Array[String] = Array("13", "15", "10")
    val polynomial: Array[Int] = octal_poly.map(octalString => Integer.parseInt(octalString, 8))

    val viterbi_param = new Viterbi_Param(polynomial, Q_LLR, K)

    val vit_dec = Module(new ViterbiDecoder(viterbi_param))
    // val scr = Module(new Scrambler(pFrameSize, pDataWidth))
    val sock1 = Module(new Socket(SInt(8.W), K))
    val sock2 = Module(new Socket(SInt(1.W), K))
    
    val tx = Module(new UART_Tx(baudRate = 115200, clockFreq = 100000000))
    val rx = Module(new UART_Rx(baudRate = 115200, clockFreq = 100000000))

    val s2u = Module(new SIntToUIntConverter(1))
    val u2s = Module(new UIntToSIntConverter(8))

    rx.io.rx := io.i_data
    rx.io.out <> u2s.io.in
    u2s.io.out <> sock1.io.enq
    
    sock1.io.deq <> vit_dec.io.enq
    vit_dec.io.deq <> sock2.io.enq
    // dontTouch(vit_dec.io.debug)
    // dontTouch(vit_dec.io.deq)

    sock2.io.deq <> s2u.io.in
    s2u.io.out <> tx.io.in
    io.o_data := tx.io.tx


}
