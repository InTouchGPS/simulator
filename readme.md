# CalAmp Reading Simulator

This project contains a simulator to send CalAmp device readings to a
gateway in order to test functionality and load capability of the
InTouchGPS solution.

## Simulator Modes

There are 2 simulation modes.

- Playback
- Simulated Load

### Playback Mode

The playback mode is intended to playback a real history of device
readings in the same order and frequency as originally received.
Playback mode does support a time multiplier to make the simulation
run faster than real time.  The reading time stamps will still be set
at the same frequency as they were originally, but the actual
submission frequency will be increased allowing 24 hours of data to be
submitted in 12 hours (x2 multiplier) or 2.4 hours (x10 multiplier).
This allows both the execution of a test to complete faster, but also
allows impact testing to see what would happen if the number of
reporting devices doubled (for example).

### Simulated Load Mode

The simulated load takes a smaller set of sample readings, but
repeated sends them according to desired frequencies to test load
capacities of the gateways.

## Gateway Simulator

A simple gateway simulator is also included to receive readings, parse
them, and log them.

## Usage

1. Edit `config.yml` to point to desired gateway(s).

2. If using the gateway simulator, start up the server using `ruby server.rb`.  The server port can be specified on the command-line (`ruby server.rb 1234`) or will be prompted for upon start up.  Be sure to match ports specific in the `config.yml` file.

3. Start the simulator with the command `ruby simulator.rb` and specify desired runtime options.


