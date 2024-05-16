
package octopus

import chisel3._
import chisel3.util._

class Socket(pFrameSize: Int, pDataWidth: Int) extends Module {
    val io = IO(new Bundle {
        val enq = Flipped(Decoupled(SInt(pDataWidth.W)))
        val deq = Decoupled(SInt(pDataWidth.W))
    })
    
    val fifo = Module(new FIFO(pFrameSize, pDataWidth)) // Crée une FIFO de profondeur 16 et de largeur 8 bits

    fifo.io.enq <> io.enq
    io.deq <> fifo.io.deq    

}