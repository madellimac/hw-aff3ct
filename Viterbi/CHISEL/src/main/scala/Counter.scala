package Viterbi

import chisel3._
import chisel3.util._

class Counter(val width: Int) extends Module {
  val io = IO(new Bundle {
    val count = Output(UInt(width.W))
    val data_valid = Input(Bool())
  })

  // Register to hold the counter value
  val counter = RegInit(0.U(width.W))
  dontTouch(counter)

  // Increment the counter only when data_valid is true
  when(io.data_valid) {
    counter := counter + 1.U
  }

  // Connect the counter value to the output
  io.count := counter
}
