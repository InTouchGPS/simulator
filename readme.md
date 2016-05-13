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

Since the included history data file is a full day starting at
midnight, you may wish to skip some initial slow hours, so a option is
provided to skip a number of hours of data.

Playback mode also supports a time multiplier to make the simulation
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
them, and log them.  Logging can be done either to a gataway database,
or simply to a log file.

If logging to the database, be sure to correctly define the database
configuration in the `config.yml` file following typical Rails format
other than the root idenfier is simply 'database' rather than the
runtime environment.  For example:

```
database:
  database: gw_calamp_development
  username: root
  host: localhost
```

An SQL file to create the `gw_calamp_development` database is included
in the `db` directory.

If logging to a log file, the log file will be in the `log` directory.
Logs are named according to the port the gateway simulator is
listening on (ex. `log/server-1234.log` for port 1234).

## Usage

1. Edit `config.yml` to point to desired gateway(s) and database.  For example:

   ```
   gateway:
     count: 2
       gateway1:
         ip: 127.0.0.1
         port: 1234
       gateway2:
         ip: 127.0.0.1
         port: 2234

   database:
     database: gw_calamp_development
     username: root
     host: localhost

   system:
     debug: true
  ```

2. If using the gateway simulator, start up the server using `ruby server.rb`.  

3. Start the simulator with the command `ruby simulator.rb` and specify desired runtime options.

** NOTE ** All runtime parameters that are prompted for by running the scripts can be added in order to the command-line to automate the entry.  For example,

- To start the server on port `1234`, choosing to log to the database, and purge the old readings from the table, you could start the server with the command `ruby server.rb 1234 Y Y`.  The device simulator will send to the port(s) specificed in the `config.yml` file, so be sure to match server ports accordingly.

- To start the simulator in playback mode, sending to servers (specified in `config.yml`) using the full day data set, skipping the first 12 hours and running at real-time, the simulator could be started with the command `ruby simulator.rb P Y data/full_day_test.txt.gz 12 1`.

- A simple test script (for OSX) that starts up 2 server instances in separate terminals, and a simulator to send data to them is included in the `bin` directory.  It is inteneded to be run from the project root directory as `bin/test.sh`.


