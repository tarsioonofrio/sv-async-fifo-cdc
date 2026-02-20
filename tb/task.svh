// task 01: Reset + Empty/Full inicial
// - Após reset: p_read_empty=1 e p_write_full=0.
// - Ponteiros iniciam consistentes.
// - Sem X em flags/saídas.

// task 02: Smoke write N then read N
// - Escrever sequência conhecida (0,1,2,...).
// - Ler tudo depois.
// - Validar ordem e integridade (sem perda/duplicação).

// task 03: Interleaved (ping-pong)
// - Escrever 1, ler 1, repetidamente.
// - Clocks diferentes (ex.: write 100 MHz, read 60 MHz).
// - Garantir funcionamento sem depender de encher FIFO.

// task 04: Write clock muito mais rápido que read
// - Ex.: razão 4:1 (write >> read).
// - Atingir full várias vezes.
// - Não aceitar write quando full e sem corrupção.

// task 05: Read clock muito mais rápido que write
// - Ex.: razão 1:4 (read >> write).
// - Atingir empty várias vezes.
// - Não aceitar read quando empty e sem dado inválido.

// task 06: Clocks quase iguais
// - Ex.: 100 MHz vs 99/101 MHz.
// - Cobrir phase drift e casos raros de sincronização.

// task 07: Jitter / phase randomness
// - Variação leve no período (ex.: ±1% a ±5%).
// - Expor casos de alinhamento de borda.

// task 08: Random bursts de tráfego
// - wr_en/rd_en aleatórios.
// - Bursts longos com gaps longos.
// - Scoreboard valida todos os dados.

// task 09: Burst fill/drain
// - Encher até full (ou quase), drenar até empty.
// - Repetir múltiplas vezes.
// - Checar transições de flags sem instabilidade.

// task 10: Sustained throughput
// - Manter write/read ativos quando possível.
// - Clocks diferentes.
// - Verificar 1 transação/ciclo quando aplicável.

// task 11: Overflow attempt (write while full)
// - Forçar p_write_en=1 com p_write_full=1 por vários ciclos.
// - Verificar: ponteiro write não avança.
// - Verificar: memória/dados não corrompem.
// - Verificar: recuperação normal ao sair de full.

// task 12: Underflow attempt (read while empty)
// - Forçar p_read_en=1 com p_read_empty=1.
// - Verificar: ponteiro read não avança.
// - Verificar: não há salto de dados.
// - Verificar: leitura correta quando novos dados chegam.

// task 13: Wrap-around (múltiplas voltas)
// - Rodar 10x DEPTH (ou mais).
// - Cobrir múltiplos wraps de ponteiro.
// - Detectar bugs de MSB e full/empty.

// task 14: Depth variants
// - Regressão em DEPTH pequeno (4 ou 8), médio (16), e opcional maior (64).
// - Capturar bugs de $clog2 e indexação.

// task 15: Width variants
// - Regressão em BITS=8 e BITS=32.
// - Capturar bugs de packing e memória.

// task 16: Reset simultâneo nos dois domínios
// - Reset de write/read juntos (fluxo nominal).
// - Checar retorno limpo ao estado inicial.

// task 17: Reset assimétrico (um domínio resetado, outro rodando)
// - Ex.: reset write enquanto read continua.
// - Comportamento deve ser suportado ou explicitamente restrito.
// - Mesmo sem suporte, não gerar X/glitch grosseiro.

// task 18: Reset during traffic
// - Aplicar reset no meio de writes/reads.
// - Caracterizar comportamento suportado vs restrito.
// - Verificar retorno controlado após reset.
