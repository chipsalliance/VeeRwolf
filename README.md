SweRVolf
========

is a FuseSoC-based SoC for the [SweRV](https://github.com/chipsalliance/Cores-SweRV) RISC-V core.

This can be used to run the [RISC-V compliance tests](https://github.com/riscv/riscv-compliance), [Zephyr OS](https://www.zephyrproject.org) or other software in simulators or on FPGA boards. The SoC consists of the SweRV CPU with a boot ROM, DDR2 controller, UART and GPIO.

# Memory map

| Core     | Address               |
| -------- | --------------------- |
| RAM      | 0x00000000-0x07FFFFFF |
| Boot ROM | 0x80000000-0x80000FFF |
| GPIO     | 0x80001000-0x8000000F |
| UART     | 0x80002000-0x80002FFF |

For simulation targets there are also two extra registers defined. Writing to 0x80001008 will print a character to stdout. Writing to 0x80001009 will end the simulation.

## How to use

### Prerequisites

Install verilator

Create a directory structure consisting of a workspace directory (from now on called `$WORKSPACE`) and a root directory for the SweRV SoC (from now on called `$CORES_ROOT`). All further commands will be run from `$WORKSPACE` unless otherwise stated. The structure will look like this

    ├──cores
    └──workspace

1. Make sure you have [FuseSoC](https://github.com/olofk/fusesoc) installed or install it with `pip install fusesoc`
2. Initialize the FuseSoC base library with `fusesoc init`
3. From `$CORES_ROOT`, clone the SweRVolf repository `git clone https://github.com/chipsalliance/Cores-SweRVolf`
4. Add the cores directory as a FuseSoC core library `fusesoc library add swervolf ../cores`
5. Make sure you have verilator installed to run the simulation. **Note** This requires at least version 3.918. The version that is shipped with Ubuntu 18.04 will NOT work

## Running the SoC

The SweRVolf SoC can be run in simulation or on hardware (Digilent Nexys A7 currently supported). In either case FuseSoC is used to launch the simulation or build and run the FPGA build. To select what to run, use the `fusesoc run` command with the `--target` parameter. To run in simulation use

    fusesoc run --target=sim swervolf

To build (and optionally program) an image for a Nexys A7 board, run

    fusesoc run --target=nexys_a7 swervolf

All targets support different compile- and run-time options. To see all options for a target run

    fusesoc run --target=$TARGET swervolf --help

To list all available targets, run

    fusesoc core show swervolf

### Run a precompiled example in simulation

In simulation, SweRVolf supports preloading an application to memory with the `--ram_init_file` parameter. SweRVolf comes bundled with some example applications in the `sw` directory.

To build the simulation model and run the bundled Zephyr Hello world example in a simulator. `fusesoc run --target=sim swervolf --ram_init_file=../cores/Cores-SweRVolf/sw/zephyr_hello.vh`.

After running the above command, the simulation model should be built and run. At the end it will output

    Releasing reset
    ***** Booting Zephyr OS zephyr-v1.14.0 *****
    Hello World! swervolf_nexys

At this point the simulation can be aborted with `Ctrl-C`.

Another example to run is the Zephyr philosophers demo.

    fusesoc run --run --target=sim swervolf --ram_init_file=../cores/Cores-SweRVolf/sw/zephyr_philosophers.vh

* Note the `--run` option which will prevent rebuilding the simulator model

### Run RISC-V compliance tests

1. Build the simulation model, if that hasn't already been done, with `fusesoc run --target=sim --setup --build swervolf`
2. Download the RISC-V compliance tests somewhere. `git clone https://github.com/riscv/riscv-compliance` in a sibling directory to the workspace and work root. Your directory structure should now look like this
├──cores
├──riscv-compliance
└──workspace

3. Copy the compiled simulation model into the target directory `cp $WORKSPACE/build/swervolf_0/sim-verilator/Vswervolf_core_tb $CORES_ROOT/Cores-SweRVolf/riscv-target/swerv/`
4. Enter the riscv-compliance directory and run `make TARGETDIR=$CORES_ROOT/Cores-SweRVolf/riscv-target/swerv riscv-target $RISCV_TARGET=swerv RISCV_DEVICE=rv32i RISCV_ISA=rv32imc`

*Note: Other test suites can be run by replacing RISCV_ISA=rv32imc with rv32im or rv32i*

### Run on hardware

The SweRVolf SoC can be built for a Digilent Nexys A7 board with

    fusesoc run --target=nexys_a7 swervolf

If the board is connected, it will automatically be programmed when the FPGA image has been built. It can also be programmed manually afterwards by running `fusesoc run --target=nexys_a7 --run swervolf` or running OpenOCD as described in the debugging chapter.

The default bootloader will just blink the LED and other programs are uploaded through the debug interface. The default bootloader can be replaced with the `--bootrom_file` parameter. Note that the boot ROM is not connected to the data port, so it can only execute instructions. Data can not be read or written to this segment. The below example will compile the memtest application and use that as boot ROM instead.

    make -C ../cores/Cores-SweRVolf/sw memtest.vh
    fusesoc run --target=nexys_a7 swervolf --bootrom_file=../cores/Cores-SweRVolf/sw/memtest.vh

#### I/O

The active on-board I/O consists of a LED, a switch and the microUSB connector for UART, JTAG and power.

##### LED 0

LED 0 is controlled by memory-mapped GPIO at address 0x80001010

##### Switch 0

Switch 0 selects whether to output serial communication from the SoC or from the embedded self-test program in the DDR2 controller.

##### micro USB

UART and JTAG communication is tunneled through the microUSB port on the board and will appear as `/dev/ttyUSB0`, `/dev/ttyUSB1` or similar depending on OS configuration. A terminal emulator can be used to connect to the UART (e.g. by running `screen /dev/ttyUSB0 115200`) and OpenOCD can connect to the JTAG port.

## Build Zephyr applications

1. Download and install Zephyr according to the official guidelines at https://www.zephyrproject.org/
2. Enter the directory of the application to build in the samples directory (e.g. `basic/blinky` for the Zephyr blinky example). From now on, the program to build and run will be called `$APP`
3. Build the code with
    mkdir build
    cd build
    `cmake -GNinja -DBOARD=swervolf_nexys -DBOARD_ROOT=$CORES_ROOT/swervolf/zephyr -DSOC_ROOT=$CORES_ROOT/swervolf/zephyr ..`
    ninja
4. There will now be a binary file in `zephyr/zephyr.bin`
5. Enter the FuseSoC workspace directory and convert the binary file into a suitable verilog hex file with
    `python $CORES_ROOT/swervolf/sw/makehex.py $ZEPHYR_BASE/samples/$APP/build/zephyr/zephyr.bin > $APP.hex`
6. The new hex file can now be embedded as a bootloader for a new FPGA build with

    fusesoc run --target=nexys_a7 swervolf --bootrom_file=$APP.hex

or in a simulation with

    fusesoc run --target=sim swervolf --ram_init_file=$APP.hex

## Debugging

SweRVolf supports debugging both on hardware and in simulation. There are different procedures on how to connect the debugger, but once connected, the same commands can be used (although it's a lot slower in simulations).

### Prerequisites

Install the RISC-V-specific version of OpenOCD

    git clone https://github.com/riscv/riscv-openocd
    cd riscv-openocd
    ./bootstrap
    ./configure --enable-jtag_vpi --enable-ftdi
    make
    sudo make install

### Connecting debugger to simulation

When a SweRVolf simulation is launched with the `--jtag_vpi_enable`, it will start a JTAG server waiting for a client to connect and send JTAG commands.

    fusesoc run --target=sim swervolf --jtag_vpi_enable

After compilation, the simulation should now say

    Listening on port 5555

This means that it's ready to accept a JTAG client.

Open a new terminal, navigate to the workspace directory and run `openocd -f $CORES_ROOT/Cores-SweRVolf/data/swervolf_sim.cfg` to connect OpenOCD to the simulation instance. If successful, OpenOCD should output

    Info : only one transport option; autoselect 'jtag'
    Info : Set server port to 5555
    Info : Set server address to 127.0.0.1
    Info : Connection to 127.0.0.1 : 5555 succeed
    Info : This adapter doesn't support configurable speed
    Info : JTAG tap: riscv.cpu tap/device found: 0x00000001 (mfg: 0x000 (<invalid>), part: 0x0000, ver: 0x0)
    Info : datacount=2 progbufsize=0
    Warn : We won't be able to execute fence instructions on this target. Memory may not always appear consistent. (progbufsize=0, impebreak=0)
    Info : Examined RISC-V core; found 1 harts
    Info :  hart 0: XLEN=32, misa=0x40001104
    Info : Listening on port 3333 for gdb connections
    Info : Listening on port 6666 for tcl connections
    Info : Listening on port 4444 for telnet connections

and the simulation should report

    Waiting for client connection...ok
    Preloading TOP.swervolf_core_tb.swervolf.bootrom.ram from jumptoram.vh
    Releasing reset

Open a third terminal and connect to the debug session through OpenOCD with `telnet localhost 4444`. From this terminal, it is now possible to view and control the state of of the CPU and memory. Try this by running `mwb 0x80001010 1`. This will write to the GPIO register. To verify that it worked, there should now be a message from the simulation instance saying `gpio0 is on`. By writing 0 to the same register (`mwb 0x80001010 0`), the gpio will be turned off.

### Connecting debugger to Nexys A7

SweRVolf can be debugged using the same USB cable that is used for programming the FPGA, communicating over UART and powering the board. There is however one restriction. If the Vivado programmer has been used, it will have exclusive access to the JTAG channel. For that reason it is recommended to avoid using the Vivado programming tool and instead use OpenOCD for programming the FPGA as well. Unplugging and plugging the USB cable back will make Vivado lose the grip on the JTAG port.

Programming the board with OpenOCD can be performed by running (from $WORKSPACE)

    openocd -f ../cores/Cores-SweRVolf/data/swervolf_nexys_program.cfg

To change the default FPGA image to load, add `-c "set BITFILE /path/to/bitfile"` as the first argument to openocd.

If everything goes as expected, this should output

    Info : ftdi: if you experience problems at higher adapter clocks, try the command "ftdi_tdo_sample_edge falling"
    Info : clock speed 10000 kHz
    Info : JTAG tap: xc7.tap tap/device found: 0x13631093 (mfg: 0x049 (Xilinx), part: 0x3631, ver: 0x1)
    Warn : gdb services need one or more targets defined
    loaded file build/swervolf_0/nexys_a7-vivado/swervolf_0.bit to pld device 0 in 3s 201521us
    shutdown command invoked

OpenOCD can now be connected to SweRVolf by running

    openocd -f ../cores/Cores-SweRVolf/data/swervolf_nexys_debug.cfg

This should output

    Info : ftdi: if you experience problems at higher adapter clocks, try the command "ftdi_tdo_sample_edge falling"
    Info : clock speed 10000 kHz
    Info : JTAG tap: riscv.cpu tap/device found: 0x13631093 (mfg: 0x049 (Xilinx), part: 0x3631, ver: 0x1)
    Info : datacount=2 progbufsize=0
    Warn : We won't be able to execute fence instructions on this target. Memory may not always appear consistent. (progbufsize=0, impebreak=0)
    Info : Examined RISC-V core; found 1 harts
    Info :  hart 0: XLEN=32, misa=0x40001104
    Info : Listening on port 3333 for gdb connections
    Info : Listening on port 6666 for tcl connections
    Info : Listening on port 4444 for telnet connections

Open a third terminal and connect to the debug session through OpenOCD with `telnet localhost 4444`. From this terminal, it is now possible to view and control the state of of the CPU and memory. Try this by running `mwb 0x80001010 1`. This will write to the GPIO register. To verify that it worked, LED0 should light up. By writing 0 to the same register (`mwb 0x80001010 0`), the LED will be turned off.

### Loading programs with OpenOCD

OpenOCD support loading ELF program files by running `load_image /path/to/file.elf`. Remember that the path is relative to the directory from where OpenOCD was launched.

After the program has been loaded, set the program counter to address zero with `reg pc 0` and run `resume` to start the program.
