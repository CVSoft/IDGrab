# IDGrab
Send a TI Link Protocol Ready Check packet from a TI-83 Plus with arbitrary Machine ID and show the received Machine ID

## Usage
Store a number between 0 and 255 in Ans. This will be the Machine ID sent by the calculator. A ready-check packet (command $68) is sent with that ID, and the other device sends an acknowledgement packet (command $56). The program stores the received machine ID in Ans and exits. If the other device sends a NACK (command $5A), the result is negative. If a link error occurs, the result is -256.  

Note that results are decimal, while programmers work with the value almost exclusively in hexadecimal. It is up to you to convert the format. 
