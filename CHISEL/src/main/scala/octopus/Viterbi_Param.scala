package octopus

import chisel3._
import chisel3.util._

class Viterbi_Param(val polynomial : Array[Int], val Q_LLR : Int){
    
    val poly_deg : Int = log2Ceil(polynomial(0))

    val N_outputs : Int = polynomial.length
    val N_BM : Int = 1 << N_outputs
    val SP_length : Int = 6*(poly_deg+1)

    val Q_BM : Int = Q_LLR + log2Ceil(N_BM)
    val Q_IN : Int = Q_LLR * log2Ceil(N_BM)
    val Q_SM : Int = 1 + log2Ceil(poly_deg*scala.math.pow(2, Q_LLR).toInt)
    
    val N_states : Int = (1 << (poly_deg-1))
    val Next_State : Array[Array[Int]] = Array.tabulate(2)(i => Array.tabulate(N_states)(j => ((i*N_states + j) / 2)))

    val y : Array[Array[Array[Int]]] = Array.ofDim[Int](N_outputs, 2, N_states)
    for {
        i <- 0 until N_outputs
        j <- 0 until 2
        k <- 0 until N_states
    } y(i)(j)(k) = encode(i,j,k)

    val z : Array[Array[Int]] = Array.tabulate(2)(i => Array.tabulate(N_states)(j => encode_int(i,j)  ))

    println("N states =" + N_states)
    println("Poly 0 =" + polynomial(0))
    println("poly_deg =" + poly_deg)
    // Next_State.foreach { innerArray => innerArray.foreach(value => println(s"Value: $value"))}

    z.foreach { innerArray => innerArray.foreach(value => println(s"Value: $value"))}

    def bitsForOctalUInt(octalNumber: UInt): Int = {
        octalNumber.getWidth
    }

    def encode_int(bit : Int, state : Int): Int = { 
        val shift_bit = bit*N_states
        val concat = shift_bit + state
        val prod: Array[Int] = Array.tabulate(N_outputs)(p => concat & polynomial(p))
        val sum: Array[Int] = Array.tabulate(N_outputs)(p => countOnes(prod(N_outputs-p-1)) & 1)
        val res = sum.foldLeft(0)((acc, bit) => (acc << 1) | bit)
        res
    }

    def encode(p : Int, bit : Int, state : Int): Int = { 
        val shift_bit = bit*N_states
        val concat = shift_bit + state
        val prod = concat & polynomial(p)
        val sum = countOnes(prod) & 1
        sum
    }

    def countOnes(intValue: Int): Int = {
        var count = 0
        var value = intValue
        while (value != 0) {
            count += value & 1
            value >>= 1
        }
        count
    }

}