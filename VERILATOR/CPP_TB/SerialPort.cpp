#include "SerialPort.hpp"

using namespace spu;
using namespace spu::module;

SerialPort::SerialPort(const std::string& port_name, unsigned int baud_rate, int frame_size)
    : io(), serial(io, port_name), Module(), frame_size(frame_size)
{
    serial.set_option(boost::asio::serial_port_base::baud_rate(baud_rate));

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
    boost::asio::mutable_buffer buffer(input, sizeof(int) * frame_size);
    boost::asio::write(serial, boost::asio::buffer(buffer));
    read(output, frame_id);
}

void SerialPort::read(int* data, const int frame_id)
{
    const std::size_t N = frame_size;
    // char data[N];

    // Lecture synchrone de N octets
    boost::system::error_code ec;
    std::size_t bytes_read = boost::asio::read(serial, boost::asio::buffer(data, N), ec);

    if (ec) {
        std::cerr << "Erreur de lecture : " << ec.message() << std::endl;
    } else {
        std::cout << "Nombre d'octets lus : " << bytes_read << std::endl;
        std::cout << "Données lues : ";
        for (std::size_t i = 0; i < bytes_read; ++i) {
            std::cout << data[i];
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