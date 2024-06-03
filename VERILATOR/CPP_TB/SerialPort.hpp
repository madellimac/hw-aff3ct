#ifndef SERIALPORT_HPP
#define SERIALPORT_HPP

#include "streampu.hpp"

#include <boost/asio.hpp>
#include <iostream>
#include <memory>
#include <array>
#include <thread>

namespace spu
{
namespace module
{

class SerialPort : public Module {

public:

    SerialPort(const std::string& port_name, unsigned int baud_rate, int frame_size);
    void write(int* input, int* output, const int frame_id);
    void read(int* data, const int frame_id);
    void close();
    void run();

private:

    int frame_size;
    boost::asio::io_service io;
    boost::asio::serial_port serial;
    std::array<char, 128> read_buffer;

};
}
}

#endif // SERIALPORT_HPP
