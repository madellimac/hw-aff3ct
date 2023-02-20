instrreset

tx_data = [1 5 4]
s = send_UART(tx_data, 3)
rx_data = recv_UART(s, 3)
