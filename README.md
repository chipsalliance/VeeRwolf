SweRVolf
========

is a FuseSoC-based SoC for the [SweRV](https://github.com/chipsalliance/Cores-SweRV) RISC-V core.

This can be used to run the [RISC-V compliance tests](https://github.com/riscv/riscv-compliance), Zephyr OS or other software in simulators or on FPGA boards. The SoC consists of the SweRV CPU with a boot ROM, DDR2 controller, on-chip RAM, UART and GPIO.

# Memory map

| Core     | Address               |
| -------- | --------------------- |
| RAM      | 0x00000000-0x0000FFFF |
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

### Run a precompiled example in simulation

At this point we can now build the simulation model and run the bundled Zephyr Hello world example in a simulator. `fusesoc run --target=sim swervolf --ram_init_file=../cores/Cores-SweRVolf/sw/zephyr_hello.vh`.

After running the above command, the simulation model should be built and run. At the end it will output

    Releasing reset
    ***** Booting Zephyr OS zephyr-v1.14.0 *****
    Hello World! swervolf_nexys

At this point the simulation can be aborted with `Ctrl-C`.

*Note: To see all available options for the simulation target, run `fusesoc run --target=sim swervolf --help`*

Another example to run is the Zephyr philosophers demo.

    fusesoc run --run --target=sim swervolf --ram_init_file=../cores/Cores-SweRVolf/sw/zephyr_philosophers.vh

* Note the `--run` option which will prevent rebuilding the simulator model

### Run RISC-V compliance tests

1. Build the simulation model, if that hasn't already been done, with `fusesoc run --target=sim --setup --build swervolf`
2. Download the RISC-V compliance tests somewhere. `git clone https://github.com/riscv/riscv-compliance` in a sibling directory to the workspace and work root. Your directory structure should now look like this
├──cores
├──riscv-compliance
└──workspace

3. Copy the compiled simulation model into the target directory `cp $WORKSPACE/build/swervolf_0/sim-verilator/Vswervolf_core_tb $CORES_ROOT/swervolf/riscv-target/swerv/`
4. Enter the riscv-compliance directory and run `make TARGETDIR=$CORES_ROOT/swervolf/riscv-target/swerv riscv-target $RISCV_TARGET=swerv RISCV_DEVICE=rv32i RISCV_ISA=rv32imc`

*Note: Other test suites can be run by replacing RISCV_ISA=rv32imc with rv32im or rv32i*

### Run on hardware

The SweRVolf SoC can be built for a Digilent Nexys A7 board. Programs can be preloaded to the on-chip RAM at compile time. In the example below we will embed the Zephyr blinky example program.

    fusesoc run --target=nexys_a7 swervolf --ram_init_file=../cores/swervolf/sw/zephyr_blinky.vh

If the board is connected, it will automatically be programmed when the FPGA image has been built. It can also be programmed manually afterwards by running `fusesoc run --target=nexys_a7 --run swervolf`

In case you wonder why the LED blinks so fast, the reason is that we want to be able to run the same thing in a simulator without having to wait for a second of simulated time. To run the same system in verilator, change the target to simulation by running `fusesoc run --target=nexys_a7 swervolf --ram_init_file=../cores/swervolf/sw/zephyr_blinky.vh`. Eventually it will output notifications that the GPIO pin have changed which will result in an output looking like

    Loading RAM contents from /home/olof/projects/swerv/cores/swervolf/sw/zephyr_blinky.vh
    Releasing reset
    5074080: gpio0 is on
    10090350: gpio0 is off
    15106420: gpio0 is on
    20122690: gpio0 is off
    25138760: gpio0 is on

To find all available targets, you can run `fusesoc core show swervolf`

### Run on hardware (with DDR2 controller)

As there is yet no way to load an external program, the easiest way to run software is to preload it into the on-chip RAM. But there is also a DDR2 controller that can be enabled instead of the on-chip RAM by using the nexys_a7_ddr target. If the DDR2 controller is used, there is no RAM initialization file and programs have to be preloaded into the bootloader memory instead. Currently, the only supported program in this mode is the memory test application. This configuration can be built with

    fusesoc run --target=nexys_a7_ddr swervolf --bootrom_file=../cores/Cores-SweRVolf/sw/memtest.vh

If the memory test is successful, one LED should light up on the board

### Build Zephyr applications

1. Download and install Zephyr according to the official guidelines at https://www.zephyrproject.org/
2. Enter the directory of the application to build in the samples directory (e.g. `basic/blinky` for the Zephyr blinky example). From now on, the program to build and run will be called `$APP`
3. Build the code with
    mkdir build
    cd build
    cmake -GNinja -DBOARD=swervolf_nexys -DBOARD_ROOT=$CORES_ROOT/swervolf/zephyr -DSOC_ROOT=$CORES_ROOT/swervolf/zephyr ..
    ninja
4. There will now be a binary file in `zephyr/zephyr.bin`
5. Enter the FuseSoC workspace directory and convert the binary file into a suitable verilog hex file with
    python $CORES_ROOT/swervolf/sw/makehex.py $ZEPHYR_BASE/samples/$APP/build/zephyr/zephyr.bin > $APP.hex
6. The new hex file can now be embedded for a new FPGA build with

    fusesoc run --target=nexys_a7 swervolf --ram_init_file=$APP.hex

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

OpenOCD also support loading ELF program files by running `load_image /path/to/file.elf`, setting the program counter to address zero with `reg pc 0` and finally running `resume`.

