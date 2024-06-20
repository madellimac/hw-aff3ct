#include "SerialPort.hpp"
#include <chrono>

using namespace spu;
using namespace spu::module;

SerialPort::SerialPort(const std::string& port_name, unsigned int baud_rate, int frame_size)
    : io(), serial(io, port_name), Module(), frame_size(frame_size)
{
    serial.set_option(boost::asio::serial_port_base::baud_rate(baud_rate));
    serial.set_option(boost::asio::serial_port_base::character_size(8));
    serial.set_option(boost::asio::serial_port_base::parity(boost::asio::serial_port_base::parity::none));
    serial.set_option(boost::asio::serial_port_base::stop_bits(boost::asio::serial_port_base::stop_bits::one));
    serial.set_option(boost::asio::serial_port_base::flow_control(boost::asio::serial_port_base::flow_control::none));

    this->set_name("SerialPort");
    this->set_short_name("SerialPort");
    
    auto &t = create_task("write");
    auto input   = create_socket_in<int>(t, "input", frame_size);
    auto output   = create_socket_out<int>(t, "output", frame_size);
    this->create_codelet(t, [input, output](Module &m, runtime::Task &t, const size_t frame_id) -> int {
        static_cast<SerialPort&>(m).write(   static_cast<int*>(t[input].get_dataptr()),
                                                static_cast<int*>(t[output].get_dataptr()),
                                                        frame_id);
        return 0;
    });

}

void SerialPort::write(int* input, int* output, const int frame_id)
{
    std::vector<unsigned char> data_in(frame_size);
    std::vector<unsigned char> data_out(frame_size);

    for (auto i = 0; i < frame_size; i++)
    {
        data_in[i] = static_cast<char>(input[i]);            
    }

    size_t bytes_written = boost::asio::write(serial, boost::asio::buffer(data_in));
    size_t bytes_read = boost::asio::read(serial, boost::asio::buffer(data_out, frame_size));
    for (auto i = 0; i < frame_size; i++)
    {
        output[i] = data_out[i];
    }
}

void SerialPort::close()
{
    serial.close();
}

void SerialPort::run()
{
    io.run();
}