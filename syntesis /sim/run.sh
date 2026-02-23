

rm -rf dut.shm
rm -rf xcelium.d

module purge
module load xcelium > /dev/null 2>&1

TB=../../tb/test_async_fifo.sv
GATE=../logical/results/gate_level/async_fifo_logic_mapped.v

# Chamada do xrun (mantendo args.txt como no histórico)
xrun -f args.txt $TB $GATE -define GATE_LEVEL -define XRUN -run -exit
