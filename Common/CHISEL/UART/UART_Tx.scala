package UART

import chisel3._
import chisel3.util._

class UART_Tx(baudRate: Int, clockFreq: Int) extends Module {

  val io = IO(new Bundle {
    val in = Flipped(Decoupled(UInt(8.W))) // Data input
    val tx = Output(Bool())                // UART transmit line
  })

  // Calculate the number of clock cycles per bit
  val baudDivisor = (clockFreq / baudRate).U

  // State machine states
  val idle :: start :: data :: stop :: Nil = Enum(4)
  val state = RegInit(idle)
  
  // Baud rate counter
  val baudCounter = RegInit(0.U(log2Ceil(clockFreq / baudRate).W))
  val bitCounter = RegInit(0.U(3.W)) // 3 bits to count up to 8 data bits
  
  // Shift register for data to be transmitted
  val shiftReg = RegInit(0.U(8.W))
  
  // Default values
  io.tx := true.B // Idle state is high
//   io.in.ready := (state === idle)

    // when(state === stop ){
    //     io.in.ready := true.B
    // }.otherwise{
    //     io.in.ready := false.B
    // }
    io.in.ready := false.B
    switch(state) {
        is(idle) {
            io.tx := true.B
            io.in.ready := true.B
            when(io.in.valid) {
                state := start
                shiftReg := io.in.bits
            }
        }

        is(start) {
            io.tx := false.B
            when(baudCounter === baudDivisor - 1.U) {
                baudCounter := 0.U
                state := data
                bitCounter := 0.U
            } .otherwise {
            baudCounter := baudCounter + 1.U
            }
        }

        is(data) {
            io.tx := shiftReg(0)
            when(baudCounter === baudDivisor - 1.U) {
                baudCounter := 0.U
                shiftReg := shiftReg >> 1
                bitCounter := bitCounter + 1.U
                when(bitCounter === 7.U) {
                    state := stop
                }
            }.otherwise {
                baudCounter := baudCounter + 1.U
            }
        }

        is(stop) {
            io.tx := true.B
            when(baudCounter === baudDivisor - 1.U) {
                baudCounter := 0.U
                state := idle
            } .otherwise {
                baudCounter := baudCounter + 1.U
            }
        }
    }
}