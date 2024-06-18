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

    // auto &t1 = create_task("write");
    // auto input   = create_socket_in<int>(t1, "input", frame_size);
    // this->create_codelet(t1, [input](Module &m, runtime::Task &t1, const size_t frame_id) -> int {
    //     static_cast<SerialPort&>(m).write(   static_cast<int*>(t1[input].get_dataptr()),
    //                                                     frame_id);
    //     return 0;
    // });

    // auto &t = create_task("read");
    //     auto output   = create_socket_out<int>(t, "output", frame_size);

    //     this->create_codelet(t, [output](Module &m, runtime::Task &t, const size_t frame_id) -> int {
    //     static_cast<SerialPort&>(m).read(  static_cast<int*>(t[output].get_dataptr()),
    //                                                     frame_id);
    //     return 0;
    // });
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
    char data_in[frame_size];
    char data_out[frame_size];

    for (int i = 0; i < frame_size; i++) {
            data_in[i] = static_cast<char>(input[i]);
            std::cout << static_cast<int>(data_in[i]) << " ";
    }std::cout << std::endl;

    // boost::asio::mutable_buffer buffer(data, sizeof(unsigned char) * frame_size);
    size_t bytes_written = boost::asio::write(serial, boost::asio::buffer(input,sizeof(int) * 20));
    // std::this_thread::sleep_for(std::chrono::seconds(2));
    size_t bytes_read = boost::asio::read(serial, boost::asio::buffer(output, sizeof(int) *4));
    for (int i = 0; i < frame_size; i++) {
            std::cout << static_cast<int>(data_out[i]) << std::endl;
        }

    // std::cout << "bytes written : " << bytes_written << std::endl;
    // for(int i = 0; i < frame_size; i++)std::cout << (unsigned char)data[i] << "X";
    // std::cout << std::endl;
    // std::this_thread::sleep_for(std::chrono::seconds(2));
    // read(output, frame_id);
}

void SerialPort::read(int* output, const int frame_id)
{
    
    char data[frame_size];

    for (int i = 0; i < frame_size; i++) {
            output[i] = 0;
    }


    // Lecture synchrone de N octets
    boost::system::error_code ec;

    size_t bytes_read = boost::asio::read(serial, boost::asio::buffer(output, 10), ec);
    std::cout << "bytes read : " << bytes_read << std::endl;
    if (ec) {
        std::cerr << "Erreur de lecture : " << ec.message() << std::endl;
    } else {
        std::cout << "Nombre d'octets lus : " << bytes_read << std::endl;
        std::cout << "Données lues : ";
        for (int i = 0; i < frame_size; i++) {
            output[i] = data[i];
            std::cout << output[i] << " ";
        }
        std::cout << std::endl;
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