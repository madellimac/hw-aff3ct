package UART

import chisel3._
import chisel3.util._

class UART_Rx(baudRate: Int, clockFreq: Int) extends Module {
  val io = IO(new Bundle {
    val rx = Input(Bool())                 // UART receive line
    val out = Decoupled(UInt(8.W))         // Data output
  })

  // Calculate the number of clock cycles per bit
  val baudDivisor = (clockFreq / baudRate).U

  // State machine states
  val idle :: start :: data :: stop :: Nil = Enum(4)
  val state = RegInit(idle)

  // Baud rate counter
  val counterSize = log2Ceil(clockFreq / baudRate)
  val baudCounter = RegInit(0.U(counterSize.W))
  val bitCounter = RegInit(0.U(3.W)) // 3 bits to count up to 8 data bits
  
  // Shift register for data to be received
  val shiftReg = RegInit(0.U(8.W))

  // Default values
  io.out.valid := false.B
  io.out.bits := shiftReg

  switch(state) {
    is(idle) {
      when(io.rx === false.B) { // Start bit detected (line goes low)
        state := start
        baudCounter := 0.U
      }
    }

    is(start) {
      when(baudCounter === (baudDivisor / 2.U(counterSize.W))) { // Midpoint of the start bit
        baudCounter := 0.U
        state := data
        bitCounter := 0.U
      } .otherwise {
        baudCounter := baudCounter + 1.U
      }
    }

    is(data) {
      when(baudCounter === baudDivisor - 1.U) {
        baudCounter := 0.U
        shiftReg := (io.rx << 7) | (shiftReg >> 1) // Shift in the new bit
        bitCounter := bitCounter + 1.U
        when(bitCounter === 7.U) {
          state := stop
        }
      } .otherwise {
        baudCounter := baudCounter + 1.U
      }
    }

    is(stop) {
      when(baudCounter === baudDivisor - 1.U) {
        baudCounter := 0.U
        state := idle
        io.out.valid := true.B // Output the received data
      } .otherwise {
        baudCounter := baudCounter + 1.U
      }
    }
  }
}