package Viterbi

import chisel3._
import chisel3.util._

class UIntToSIntConverter ( data_width : Int) extends Module {
  val io = IO(new Bundle {
    val in = Flipped(Decoupled(UInt(data_width.W))) // Port d'entrée de type Decoupled(SInt(8.W))
    val out = Decoupled(SInt(data_width.W))          // Port de sortie de type Decoupled(UInt(8.W))
  })

  // Connecter les signaux `valid` et `ready`
  io.out.valid := io.in.valid
  io.in.ready := io.out.ready

  // Convertir le signal `bits` de SInt à UInt
  io.out.bits := io.in.bits.asSInt
}
