# remix-solidity-basics

## assignment_M2.sol - Trabajo Final Módulo 2 

Este es mi trabajo final del Módulo 2 del curso, donde desarrollé y desplegué un contrato inteligente de subasta en la red de prueba Sepolia.

### Descripción del Proyecto

El contrato permite realizar una subasta en la cual:

- Los participantes pueden hacer ofertas en ETH.
- Cada nueva oferta válida debe superar en al menos un 5% la anterior.
- Si una oferta se realiza, se extiende la duración de la subasta.
- Se lleva un historial completo de ofertas.
- Los oferentes no ganadores pueden retirar sus depósitos con una comisión del 2%.
- El ganador no puede retirar, y el owner puede reclamar el monto final (menos la comisión).

### Tecnologías

- Solidity `^0.8.26`
- Red de prueba: **Sepolia**
- IDE usado: Remix
- Wallet usada: MetaMask

### Funcionalidades implementadas

- Constructor que inicializa la subasta.
- Lógica de ofertas con control de mínimo requerido.
- Registro de historial completo por participante.
- Eventos emitidos para nuevas ofertas, extensión y finalización.
- Función `withdrawExcess()` para permitir reembolsos parciales durante la subasta.
- Función `getAllBids()` para visualizar todos los datos de las ofertas.
- Función `withdraw()` para devoluciones post-subasta a no ganadores.
- Control de acceso por `modifiers`.

### Contrato desplegado

- Dirección del contrato: `0x...`
- Red: Sepolia
- Verificado en: [Etherscan Sepolia](https://sepolia.etherscan.io/address/0x...)

### Repositorio

Puedes ver el código fuente completo aquí:  
[https://github.com/miusuario/subasta-flash](https://github.com/miusuario/subasta-flash)

---

