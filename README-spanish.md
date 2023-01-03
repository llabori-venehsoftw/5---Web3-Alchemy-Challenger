# Solution al desafio #5 Universidad de Alchemy

Objetivos:

En este tutorial, vas a construir una NFT Dinámica utilizando la red de oráculos descentralizada y 
criptográficamente segura de Chainlink para obtener y rastrear datos de precios de activos.

A continuación, utilizará las automatizaciones de la red Chainlink Keepers para automatizar su contrato 
inteligente NFT para actualizar los NFT de acuerdo con los datos de precios de los activos que está 
rastreando.

Si el precio del mercado sube, el contrato inteligente elegirá aleatoriamente el URI de la NFT para que 
apunte a una de estas tres imágenes alcistas y la NFT se actualizará dinámicamente.

Traducción realizada con la versión gratuita del traductor www.DeepL.com/Translator

## Comenzando 🚀

Estas instrucciones te permitirán tener una copia del proyecto corriendo en tu máquina local para
propósitos de desarrollo y pruebas.

Ver **Despliegue** para saber cómo desplegar el proyecto.

### Prerrequisitos 📋

1. IDE

En este tutorial, vamos a utilizar el IDE VS Code y la red blockchain incorporada "London VM", pero
utilizando el marco de desarrollo de contratos inteligentes Hardhat.

2. Github Repo

Aquí, hay un [Github repo para el texto Dynamic NFT tutoriallinks](https://github.com/zeuslawyer/
chainlink-dynamic-nft-alchemy) que hemos creado para ustedes.

El repositorio refleja la estructura que seguiremos.

- La rama principal

La rama principal contiene la línea de base ERC721 Token utilizando el Asistente OpenZeppelin.

- La rama price-feeds

La rama price-feeds añade la implementación de Chainlink Keepers y se conecta a los datos de precios de
Chainlink Asset que utilizaremos para rastrear el precio de un activo específico.

- La rama de aleatoriedad

La rama de aleatoriedad contiene la lógica para añadir aleatoriedad de modo que nuestra NFT dinámica se
elija aleatoriamente entre los URI de metadatos NFT que tenemos en nuestro contrato inteligente.

¡Esta parte es para que la hagas como una tarea especial para construir tus habilidades!

3. Compañero IPFS

Instala la extensión de navegador IPFS Companion (para cualquier navegador basado en Chromium).

Esto contendrá el URI de tu token y la información de metadatos.

4. Grifos y Testnet Tokens

Asegúrate de que tu monedero MetaMask está conectado a Goerli.

Una vez que su cartera esté conectada a Rinkeby, obtenga Goerli ETH del grifo Goerli de Alchemy.

También necesitarás conseguir tokens LINK de testnet.

Para tu asignación, añadirás aleatoriedad, pero te desplegarás en la testnet Goerli de Ethereum.

Si necesitas tokens Goerli testnet, consigue Goerli ETH del grifo Goerli de Alchemy.

Ahora vamos a empezar a construir nuestro contrato inteligente

### Instalación 🔧

_Instalación de todos los framework/bibliotecas necesarios_.

Abre tu terminal y crea un nuevo directorio:

```
mkdir 5-APIsSmartContractsChainlink
cd 5-APIsSmartContractsChainlink
```

Instale Hardhat ejecutando el siguiente comando:

```
yarn install hardhat
```

A continuación, inicialice hardhat para crear la estructura del proyecto:

```
npx hardhat init
```

Aparecerá un mensaje de bienvenida y varias opciones. Seleccione crear un proyecto JavaScript
(Todos los ajustes por defecto están bien):

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat init
888    888                      888 888               888
888    888                      888 888               888
888    888                      888 888               888
8888888888  8888b.  888d888 .d88888 88888b.   8888b.  888888
888    888     "88b 888P"  d88" 888 888 "88b     "88b 888
888    888 .d888888 888    888  888 888  888 .d888888 888
888    888 888  888 888    Y88b 888 888  888 888  888 Y88b.
888    888 "Y888888 888     "Y88888 888  888 "Y888888  "Y888

Welcome to Hardhat v2.12.4

✔ What do you want to do? · Create a JavaScript project
✔ Hardhat project root: · /home/llabori/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink
✔ Do you want to add a .gitignore? (Y/n) · y
✔ Do you want to install this sample project's dependencies with yarn (@nomicfoundation/
hardhat-toolbox @nomicfoundation/hardhat-network-helpers @nomicfoundation/hardhat-chai-matchers
@nomiclabs/hardhat-ethers @nomiclabs/hardhat-etherscan chai ethers hardhat-gas-reporter
solidity-coverage @typechain/hardhat typechain @typechain/ethers-v5 @ethersproject/abi @ethersproject/
providers)? (Y/n) · y
```

Para comprobar que todo funciona correctamente, ejecute:

```
npx hardhat test
```

Si todo está bien, hay que ver:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat test
Compiled 1 Solidity file successfully


  Lock
    Deployment
      ✔ Should set the right unlockTime (2757ms)
      ✔ Should set the right owner (41ms)
      ✔ Should receive and store the funds to lock
      ✔ Should fail if the unlockTime is not in the future (79ms)
    Withdrawals
      Validations
        ✔ Should revert with the right error if called too soon (66ms)
        ✔ Should revert with the right error if called from another account (58ms)
        ✔ Shouldn't fail if the unlockTime has arrived and the owner calls it (82ms)
      Events
        ✔ Should emit an event on withdrawals (76ms)
      Transfers
        ✔ Should transfer the funds to the owner (79ms)


  9 passing (3s)
```

Ahora necesitaremos instalar el paquete OpenZeppelin para tener acceso al estándar de contratos 
inteligentes ERC721 que utilizaremos como plantilla para construir nuestro contrato inteligente NFTs:

```
yarn add @openzeppelin/contracts
```

Deberíamos observar algo similar a:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ yarn
add @openzeppelin/contracts
yarn add v1.22.17
warning package.json: No license field
warning No license field
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/chai@^4.2.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/mocha@^9.1.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/node@>=12.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "ts-node@>=8.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "typescript@>=4.5.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "@ethersproject/bytes@^5.0.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "typescript@>=4.3.0".
warning "@typechain/ethers-v5 > ts-essentials@7.0.3" has unmet peer dependency "typescript@>=3.7.0".
warning " > typechain@8.1.1" has unmet peer dependency "typescript@>=4.3.0".
[4/4] Building fresh packages...
success Saved lockfile.
warning No license field
success Saved 1 new dependency.
info Direct dependencies
└─ @openzeppelin/contracts@4.8.0
info All dependencies
└─ @openzeppelin/contracts@4.8.0
Done in 25.94s.Your inputs will now store in their respective variables the addresses we'll write inside.
```

Ahora descargamos o copiamos el código fuente del Contrato Inteligente principal que se encuentra en la 
Rama Principal del repositorio de GitHub al que se hace referencia más arriba [repositorio de Github para 
el texto de Dynamic NFT tutoriallinks](https://github.com/zeuslawyer/chainlink-dynamic-nft-alchemy)

## Desarrollo de cambios en el Código fuente ⚙️

Los primeros pasos para crear una NFT actualizable en nuestro caso son:

_Instalación de las dependencias necesarias_.

Abra su terminal y escriba lo siguiente:

```
yarn add @chainlink/contracts
```

Deberías observar algo similar a:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ yarn
add @chainlink/contracts
yarn add v1.22.17
warning package.json: No license field
warning No license field
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/chai@^4.2.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/mocha@^9.1.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "@types/node@>=12.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "ts-node@>=8.0.0".
warning " > @nomicfoundation/hardhat-toolbox@2.0.0" has unmet peer dependency "typescript@>=4.5.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "@ethersproject/bytes@^5.0.0".
warning " > @typechain/ethers-v5@10.2.0" has unmet peer dependency "typescript@>=4.3.0".
warning "@typechain/ethers-v5 > ts-essentials@7.0.3" has unmet peer dependency "typescript@>=3.7.0".
warning " > typechain@8.1.1" has unmet peer dependency "typescript@>=4.3.0".
[4/4] Building fresh packages...
success Saved lockfile.
warning No license field
success Saved 5 new dependencies.
info Direct dependencies
└─ @chainlink/contracts@0.5.1
info All dependencies
├─ @chainlink/contracts@0.5.1
├─ @eth-optimism/contracts@0.5.39
├─ @eth-optimism/core-utils@0.12.0
├─ @openzeppelin/contracts-v0.7@3.4.2
└─ bufio@1.2.0
Done in 122.84s.
```

_Actualizamos los valores y variables que se necesitan en nuestro Contrato Inteligente_.

Actualiza los enlaces en los URIs IPFS:

Ahora tienes que asegurarte de actualizar los enlaces en los URIs IPFS para vegetationUrisIpfs y 
citiesUrisIpfs para que apunten a los archivos alojados en tu IPFS.

Existen varias formas de alojar archivos y documentos en la red IPFS. Principalmente podríamos establecer 
dos formas:
a.- Instalar tu propio nodo de red (para lo cual necesitarás cumplir ciertos requisitos de hardware así 
como instalar cierto software).

b.- Utilizar el potencial de servicios prestados por terceros (por ejemplo Infura, Chainlink, otros, etc.).

En nuestro caso utilizamos un servicio prestado por un tercero con el que tenemos la posibilidad de alojar 
tanto las imágenes como sus correspondientes ficheros de metadatos en la red; con lo que obtenemos:

```
// For Images

"https://ipfs.io/ipfs/Qme2nQTmjPJ1gqFZdC8rVS3AEae9fXtYzbcPi6opRu3nFD?filename=vegetation01.png"
"https://ipfs.io/ipfs/QmZZUBWLi9CAjzEGRnyCB2LTnEUYdSSzSHtjarqkwzfK3J?filename=vegetation02.png"
"https://ipfs.io/ipfs/QmZic4h6kf3xRS9sqhAwbtKFeLtwrb2QcezygDKRuUuyXM?filename=vegetation03.png"

"https://ipfs.io/ipfs/QmfZ4qx9U9CAJif3RhqgV2CZjMtp5ptpRS6LvFXKJiNiFC?filename=cities01.png"
"https://ipfs.io/ipfs/QmS1MsNFdZxYsiVBKKB4Dz5VSznuZfLfzZR8bjwc8gsmay?filename=cities02.png"
"https://ipfs.io/ipfs/Qmej59n5SumntWipapMLrsrLPptCchuifSgozMm99axf2f?filename=cities03.png"

// For Metadata
"https://ipfs.io/ipfs/QmbqiQuNFYuTX55UdSyCSzaPnPWGvduQnq2WbLwwhA9o49?filename=vegetation01.json"
"https://ipfs.io/ipfs/QmQESBNenESMZ6i3BpYLnHigiRHHNh2mCg9hrHGE66EyZS?filename=vegetation02.json"
"https://ipfs.io/ipfs/QmQh3tXJ1NF6gauVGxeW9pumtiBS4NfepBN8C1xVzWjRWx?filename=vegetation03.json"

"https://ipfs.io/ipfs/QmZM76tG6opdKPTXnUsmniATac2ti237WDLrJgdZfSRuw1?filename=cities01.json"
"https://ipfs.io/ipfs/QmVnifCC387zLCafq5X4dKSWpPzGhmRTNU6AaUYUfp2GEQ?filename=cities02.json"
"https://ipfs.io/ipfs/QmQeU4uypSGgop7V8x6Xt5vZsRSKGMft4Lu6kLWao89d6m?filename=cities03.json"

```

_Despliega tu contrato inteligente Vegetation&Cities.sol en la red de pruebas de Ethereum Goerli utilizando Alchemy y MetaMask_.


Cuando abras tu archivo hardhat.config.js, verás un ejemplo de código de despliegue. Elimínalo y pega
esta versión:

```
// hardhat.config.js

require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config()

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const GOERLI_URL = process.env.GOERLI_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: GOERLI_URL,
      accounts: [PRIVATE_KEY]
    }
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000,
    }
  }
};
```

Ahora, antes de que podamos hacer nuestro despliegue, necesitamos asegurarnos de que tenemos una última 
herramienta instalada, el módulo dotenv. Como su nombre indica, dotenv nos ayuda a conectar un archivo .
env al resto de nuestro proyecto. Vamos a instalarlo:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npm
install dotenv

added 1 package, and audited 924 packages in 34s

129 packages are looking for funding
  run `npm fund` for details
```

Crear un archivo .env (Usando de VSCode IDE) Rellenar el archivo .env con las variables que necesitamos:

```
GOERLI_URL=https://eth-goerli.alchemyapi.io/v2/<your api key>
GOERLI_API_KEY=<your api key>
PRIVATE_KEY=<your metamask api key>
```

Además, para obtener lo que necesitas para las variables de entorno, puedes utilizar los siguientes 
recursos:

    GOERLI_URL - regístrate para obtener una cuenta en Alchemy, crea una aplicación Ethereum -> Goerli, y utiliza la HTTP URL
    GOERLI_API_KEY - desde tu misma aplicación Alchemy Ethereum Goerli, puedes obtener la última parte de la URL, y esa será tu API KEY
    PRIVATE_KEY - Sigue estas instrucciones de MetaMask para exportar tu clave privada.

Asegúrate de que .env aparece en tu .gitignore:

```
node_modules
.env
coverage
coverage.json
typechain
typechain-types

#Hardhat files
cache
artifacts
```

Vamos a crear un nuevo archivo scripts/deploy.js que será super simple, sólo para desplegar nuestro
a cualquier red que elijamos más adelante (elegiremos Goerli más adelante por si no te has dado cuenta).

El archivo deploy.js debería tener este aspecto:

```
// scripts/deploy.js
// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const hre = require("hardhat");

async function main() {
  // We get the contract to deploy.
  const Vegetation_Cities = await hre.ethers.getContractFactory("Vegetation&Cities");
  const vegetation_Cities = await Vegetation_Cities.deploy();

  await buyMeACoffee.deployed();

  console.log("Vegetation&Cities deployed to:", vegetation_Cities.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Ahora con este script deploy.js codificado y guardado, si ejecutas el siguiente comando:

```
npx hardhat run scripts/deploy.js --network goerli
```
Verás que se imprime una sola línea:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat run scripts/deploy.js --network goerli
Compiled 23 Solidity files successfully
VegetationCities deployed to: 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf (The address of your Smart
contrat must be different from this one )
```

Verificamos que el SmartContract está realmente desplegado en Goerli Tesnet utilizando
https://goerli.etherscan.io/

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")

_Verificar y publicar el código fuente del contrato_

Nos dirigimos a la siguiente dirección:

https://goerli.etherscan.io/verifyContract

y rellenamos todos los datos solicitados. Para este caso concreto, como el Smart Contract importa otros 
Smart Contracts en su código, no será posible pegar únicamente el código fuente del Smart Contract, sino 
que tendremos que recurrir a una funcionalidad Hardhat para unir el código de todos los Smart Contracts en 
un único único. Para la generación de dicho fichero utilizaremos:

```
npx hardhat flatten contracts/VegetationCities.sol > contracts/VegetationCities_flat.sol
```

Ahora copiamos el código del archivo recién generado y lo utilizamos en la interfaz web de EtherScan para 
verificar y publicar el Contrato Inteligente.

Entonces veremos:

```
ParserError: Multiple SPDX license identifiers found in source file. Use "AND" or "OR" to combine multiple 
licenses. Please see https://spdx.org for more information.
```

Buscando una solución a esta eventualidad, nos encontramos con la opción de incluir una tarea en el código 
de el archivo hardhat.config.js que se encarga tanto de fusionar todos los Contratos Inteligentes en un 
único archivo como de como de unificar sus licencias en una sola para salvar la incompatibilidad de las 
mismas. El código a incluir en el archivo hardhat.config.js es:

```
task("flat", "Flattens and prints contracts and their dependencies (Resolves licenses)")
  .addOptionalVariadicPositionalParam("files", "The files to flatten", undefined, types.inputFile)
  .setAction(async ({ files }, hre) => {
    let flattened = await hre.run("flatten:get-flattened-sources", { files });

    // Remove every line started with "// SPDX-License-Identifier:"
    flattened = flattened.replace(/SPDX-License-Identifier:/gm, "License-Identifier:");
    flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`;

    // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
    flattened = flattened.replace(/pragma experimental ABIEncoderV2;\n/gm, ((i) => (m) => (!i++ ? m : ""))(0));
    console.log(flattened);
  });
```

Ahora se ejecutará la verificación y publicación del código fuente del Contrato Inteligente a través de la
ventana de comandos (Terminal) del IDE. Para ello debemos añadir el siguiente código a nuestro hardhat.
config.js:

```
etherscan: {
    apiKey: "4H3N6G1PG17FGV2G968PJ8DIQ3DJSX1W1R", // Your Etherscan API key
  },
```

Las API Keys se obtienen accediendo al sistema Web https://etherscan.io y generando una nueva
aplicación para la cual en la sección de configuración obtendremos la respectiva API Key.

Luego ejecutamos la siguiente instrucción desde la ventana de comandos:

```
npx hardhat verify --contract contracts/VegetationCities_flat.sol:VegetationCities --network goerli 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf
```

Por fin vamos a ver:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCities_flat.sol:VegetationCities --network goerli 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf
Nothing to compile
Successfully submitted source code for contract
contracts/VegetationCities_flat.sol:VegetationCities at 0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf
for verification on the block explorer. Waiting for verification result...

Successfully verified contract VegetationCities on Etherscan.
https://goerli.etherscan.io/address/0xAB6bA7Ad6d17F196083b1c7Ff4d442A1AD11aBcf#code
```

Con esto ya podemos interactuar con nuestro Contrato Inteligente desde la interfaz web de EtherScan.

_Interactuar con nuestro Contrato Inteligente_

Copia la dirección de tu monedero Metamask y pégala en el campo safeMint para acuñar un token (Usa la 
Interfaz Web de goerli.etherscan.io, Escribir Contrato):

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")

Utilice la Interfaz Web de goerli.etherscan.io, Leer Contrato; Seleccione TokenURI y escriba el número 0 
en este campo:

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")

Como tu primer token tiene un ID de token cero, devolverá el tokenURI que apunta al archivo JSON
vegetación01`.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")


_Haga su contrato compatible con Keepers_

Ahora, podemos hacer que nuestro contrato NFT no sólo sea dinámico, ¡sino automáticamente dinámico!

Este código está referenciado en la rama [price-feeds branch](https://github.com/zeuslawyer/chainlink-dynamic-nft-alchemy/tree/price-feeds/contracts) del repo.

En primer lugar, añadimos la capa de automatización con Chainlink Keepers, lo que significa que tenemos 
que ampliar nuestro contrato inteligente NFT para hacerlo "compatible con Keepers".

Aquí están los pasos claves:

    * Importar "@chainlink/contracts/src/v0.8/KeeperCompatible.sol"
    * Haz que tu contrato herede de KeeperCompatibleInterface
    * Ajuste su constructor para tomar en un período de intervalo que se establece como un contrato statevariable y
    esto establece los intervalos en los que se producirá la automatización.
    * Implementa las funciones checkUpkeep y performUpkeep en el contrato inteligente NFT para satisfacer la interfaz.
    interfaz.
    * [Registrar el contrato "upkeep"](https://docs.chain.link/chainlink-automation/register-upkeep) con
    la red Chainlink Keeper.

  La red Chainlink Keepers comprobará nuestra función checkUpkeep() cada vez que se añada un nuevo bloque a la cadena de bloques y simulará la ejecución de nuestra función fuera de la cadena. 
y simulará la ejecución de nuestra función fuera de la cadena.

Esa función devuelve un booleano:

    Si es falso, significa que aún no se ha realizado ningún mantenimiento automatizado.
    Si devuelve true, significa que el intervalo que establecimos ha pasado, y una acción de mantenimiento está pendiente.

La Red de Keepers llama a nuestra función performUpkeep() automáticamente, y ejecuta la lógica en la 
cadena.

No es necesaria ninguna acción por parte del desarrollador.

¡Es como magia!

Nuestro checkUpkeep será sencillo porque sólo queremos comprobar si el intervalo ha expirado y
devolver ese booleano, pero nuestro performUpkeep necesita comprobar un feed de precios.

Para ello, tenemos que hacer que nuestro Contrato Inteligente interactúe con los oráculos de precios de 
Chainlinks.

Utilizaremos el [contrato proxy de alimentación BTC/USD en Goerli](https://goerli.etherscan.io/address/
0xA39434A63A52E749F02807ae27335515BA4b07F7), pero puede [elegir otro](https://docs.chain.link/data-feeds/price-feeds/addresses/?network=ethereum#Goerli%20Testnet) de la red Goerli.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")

_Interactuar con los Price Feeds de la cadena_

Para interactuar con el oráculo de Price Feed elegido, necesitamos utilizar la AggregatorV3Interface.

En nuestro código de referencia en la rama [price-feeds](https://github.com/zeuslawyer/
chainlink-dynamic-nft-alchemy/tree/price-feeds/contracts), el constructor acepta la dirección del
como parámetro en el constructor. Aceptar un parámetro en tiempo de despliegue es super útil
ya que lo hace configurable cuando desarrollamos localmente.

Para interactuar con un oráculo en vivo en Goerli, nuestro contrato necesita ser desplegado en Goerli. 
Esto es necesario para las pruebas de integración, pero durante el desarrollo nos ralentiza un poco.

¿Cómo podemos acelerar nuestro bucle de desarrollo local editar-compilar-depurar?

_Mocking Live Net Smart Contracts_

En lugar de volver a desplegar constantemente a una red de prueba como Goerli, el pago de prueba ETH, etc, 
podemos (mientras que iterando en nuestro contrato inteligente) usar mocks.

Por ejemplo, podemos simular el contrato de agregador de precios utilizando este [contrato simulado de precios](https://github.com/zeuslawyer/chainlink-dynamic-nft-alchemy/blob/price-feeds/contracts/MockPriceFeed.sol).

La ventaja es que podemos desplegar el simulacro en nuestro entorno Remix, en el navegador London VM y 
ajustar los valores que devuelve para probar diferentes escenarios, sin tener que desplegar constantemente 
nuevos contratos a redes en vivo, a continuación, aprobar las transacciones a través de MetaMask y pagar 
ETH prueba cada vez.

Esto es lo que hay que hacer:

    Copia ese archivo a tu Remix
    Guárdalo como MockPriceFeed
    Despliégalo

Es simplemente importar el [mock que Chainlink ha escrito](https://github.com/smartcontractkit/
chainlink/blob/develop/contracts/src/v0.6/tests/MockV3Aggregator.sol) para el agregador de precios.
proxy. NOTA = Debe cambiar el compilador a 0.6.x para compilar este mock.

Al desplegar un simulacro, debe introducir los decimales con los que el sistema de precios calculará los 
precios.

Puedes encontrarlos en [list of price feed contract addresses](https://docs.chain.link/docs/
ethereum-addresses/), después de hacer clic en "Mostrar más detalles".

El feed BTC/USD toma 8 decimales.

También necesitas pasar el valor inicial del feed.

Como elegí al azar el precio del activo BTC/USD, le pasé un valor antiguo que obtuve cuando estaba 
probando: 3034715771688

NOTA = Cuando lo despliegues localmente, asegúrate de anotar la dirección del contrato que te da Remix.

Esto es lo que usted pasa en el constructor de su Contrato Inteligente NFT para que sepa usar el mock como
como fuente de precios.

También deberías jugar con tu simulacro de alimentación de precios desplegado localmente.

Llame a latestRoundData para ver el último precio de la fuente de precios simulada y otros datos que se 
ajusten a la API de fuente de precios de Chainlink.

Puede actualizar el precio llamando a updateAnswer e introduciendo un valor mayor o menor (para simular la 
subida y bajada de los precios).

Puedes hacer que el precio baje pasando 2534715771688 o que suba pasando 4534715771688.

Muy útil para probar en el navegador tu contrato inteligente NFT.

Volviendo al contrato inteligente NFT, asegúrate de actualizarlo para reflejar el código de referencia.

Esto es lo que te sugiero que hagas:

    Primero lee este breve documento sobre cómo hacer compatible nuestro contrato inteligente NFT Keepers
    Lea la forma sencilla de utilizar los feeds de datos
    Despliegue el feed de datos falso
    Lea su código fuente para entender cómo se escriben los contratos inteligentes Chainlink Price Feed

Una vez que haya leído estos recursos, inténtelo usted mismo.

Si quieres saltar directamente a nuestra implementación, está en la rama price-feeds.

Tenga en cuenta que hemos establecido el feed de precios como una variable de estado pública para que 
podamos cambiarla, utilizando el método setPriceFeed() y también hemos añadido la lógica NFT dinámica a 
performUpkeep().

Cada vez que la red Chainlink Keepers llame a eso, ejecutará esa lógica en la cadena y si el
Chainlink Price Feed informa de un precio diferente del último que rastreamos, se actualizan los URI.

Esta demo no optimiza los costes de gas de la actualización de todos los Token URIs en el contrato 
inteligente. Nos centramos en cómo los NFT pueden hacerse dinámicos. Los costes de actualizar todos los 
NFT que están en circulación podrían ser extremadamente altos en la red Ethereum, así que considérelo con 
cuidado y explore soluciones de capa 2 u otras arquitecturas para optimizar las tasas de gas.

Resumiendo las actividades:

1.- Generar y desplegar el contrato inteligente MockPriceFeed01

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat run --network goerli scripts/deploy-mock01.js

Compiled 31 Solidity files successfully
MockPriceFeed01 deployed to: 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc (NOTE = You contract address must be diferent to this)
```

2.- Generar un único fichero con todo el código fuente (El contrato inteligente principal + la librería 
importada) siguiendo las siguientes instrucciones:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat flat contracts/MockPriceFeed01.sol > contracts/MockPriceFeed01_flat.sol
```

Debemos obtener un nuevo archivo en la carpeta de contratos (MockPriceFeed01.sol)

3.- Verificar y publicar el Código del Contrato Inteligente MockPriceFeed utilizando en el terminal la 
siguiente instrucción:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat verify --contract contracts/MockPriceFeed01_flat.sol:MockPriceFeed01 --constructor-args argumentsMock.js --network goerli 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc (NOTE = You contract address must be diferent to this)
```

Debemos ver:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx
hardhat verify --contract contracts/MockPriceFeed01_flat.sol:MockPriceFeed01 --constructor-args argumentsMock.js --network goerli 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc
Nothing to compile
Successfully submitted source code for contract
contracts/MockPriceFeed01_flat.sol:MockPriceFeed01 at 0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc
for verification on the block explorer. Waiting for verification result...

Successfully verified contract MockPriceFeed01 on Etherscan.
https://goerli.etherscan.io/address/0x19bE1625bA1a2f1e3e191C52a6283F4AB2F9f9Dc#code
```

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

4.- Despliega el contrato Smart token VegetationCitiesUpd (Recuerda actualizar la versión del compilador). 
Para los argumentos del constructor, puedes pasar 10 segundos para el intervalo y la dirección del Mock 
Price Feed como segundo argumento.

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat run --network goerli scripts/deployUpd.js
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
   --> contracts/VegetationCitiesUpd.sol:110:109:
    |
110 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
    |                                                                                                             ^^^^^^^^^^^^


Compiled 32 Solidity files successfully
VegetationCitiesUpd deployed to: 0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You
contract address must be diferent to this)
```

5.- Generar un único fichero con todo el código fuente (El contrato inteligente principal + librería
importados) utilizando la siguiente instrucción:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat flat contracts/VegetationCitiesUpd.sol > contracts/
VegetationCitiesUpd_flat.sol
```

Debemos obtener un nuevo archivo en la carpeta de contratos (VegetationCitiesUpd_flat.sol)

6.- Verificar y publicar el Código del Contrato Inteligente VegetationCitiesUpd.sol utilizando en el terminal la siguiente instrucción:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpd_flat.
sol:VegetationCitiesUpd --constructor-args argumentsVeget.js --network goerli
0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You contract address must be diferent to
this)
```

Debemos ver:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpd_flat.
sol:VegetationCitiesUpd --constructor-args argumentsVeget.js --network goerli
0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You contract address must be diferent to
this)
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to
all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpd_flat.sol:3620:109:
     |
3620 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns
(bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Compiled 1 Solidity file successfully
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to
all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpd_flat.sol:3620:109:
     |
3620 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Successfully submitted source code for contract
contracts/VegetationCitiesUpd_flat.sol:VegetationCitiesUpd at
0x42E7121856440E2886b5914Ae10e2391569F1f79 (NOTE = You contract address must be diferent to
this) for verification on the block explorer. Waiting for verification result...

Successfully verified contract VegetationCitiesUpd on Etherscan.
https://goerli.etherscan.io/address/0x42E7121856440E2886b5914Ae10e2391569F1f79#code
```

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/2-BuyMeCoffeeDeFidapp$ npx
hardhat run scripts/deploy.js
BuyMeACoffee deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/2-BuyMeCoffeeDeFidapp$ npx
hardhat run scripts/deploy.js
BuyMeACoffee deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/2-BuyMeCoffeeDeFidapp$ npx
hardhat run scripts/deploy.js
BuyMeACoffee deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/2-BuyMeCoffeeDeFidapp$ npx
hardhat run scripts/deploy.js
BuyMeACoffee deployed to: 0x5FbDB2315678afecb367f032d93F642f64180aa3
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/2-BuyMeCoffeeDeFidapp$
```

7.- Acuña uno o dos tokens: Acuña uno o dos tokens y comprueba sus tokenURIs haciendo clic en tokenURI 
después de pasar 0, 1, o cualquiera que sea el ID del token acuñado que tengas.

Todos los token URI deberían ser por defecto el vegetation01.json

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")

![Texto alternativo](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")


8- Compruebe el constructor del contrato NFT: Comprueba que en el constructor del contrato NFT se llama a
getLatestPrice() y que a su vez actualiza la variable de estado currentPrice. Para ello, haga clic en
el botón currentPrice - el resultado debería coincidir con el precio que estableciste en tu Mock Price Feed.

9.- Pasar un array vacío:

Haga clic en checkUpkeep y pase un array vacío ([]) como argumento. Debería devolver un booleano de
true porque pasamos 10 segundos como duración del intervalo y habrán pasado 10 segundos desde
cuando desplegó Bull&Bear. El repositorio de referencia incluye una función setter para que pueda 
actualizar el campo intervalo para mayor comodidad.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")

10.- Asegúrese de que el Mock Price Feed está actualizado: Asegúrese de que su Mock Price Feed está 
actualizado para devolver un que sea diferente del que tiene almacenado actualmente en el campo 
currentPrice de su contrato inteligente NFT.

Si actualiza el contrato simulado con un número inferior, por ejemplo, es de esperar que su contrato 
inteligente NFT cambie los NFT para mostrar un token URI "bajista".

11.- Simula la llamada a tu contrato:

Haga clic en performUpkeep después de pasarle un array vacío. Así simulará que su contrato es
llamado por la red de Chainlink Keepers en Goerli. No se olvide, usted tiene que desplegar a Goerli y
registro de su mantenimiento y conectarse a Goerli Precio alimenta como parte de su asignación.

Dado que ahora estamos en la red Remix en el navegador tenemos que simular el flujo de automatización por
llamando a performUpkeep nosotros mismos.

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "un título")

12.- Comprobar el último precio y actualizar todos los token URIs

performUpkeep debe comprobar el último precio y actualizar todas las URIs de los tokens.

    📘

    Esto es instantáneo en el navegador Remix. En Goerli esto puede tomar algún tiempo.

No necesitas firmar ninguna transacción en MetaMask cuando lo haces localmente, pero cuando te conectas a
Goerli, MetaMask te pedirá que firmes las transacciones de cada paso.

13.- Actualice el precio actual y compruebe el tokenURI: Si pulsa el precio actual debería ver el precio 
basado en el precio simulado actualizado.

A continuación, vuelva a hacer clic en tokenURI y debería ver que el tokenURI ha cambiado. Si el precio
por debajo del nivel anterior se cambiaría a Ciudades. Si el último token URI era Ciudades y el precio 
aumentó, debería cambiar a un token URI de Vegetación.

## Desafío ⚙️

Este Challenger utiliza una nueva herramienta: la función aleatoria verificable Chainlink.

Esta herramienta proporciona aleatoriedad criptográficamente demostrable y es ampliamente utilizada en 
juegos y otras aplicaciones en las que la aleatoriedad demostrable y a prueba de manipulaciones es 
esencial para obtener resultados justos.

En este momento, hemos codificado el URI del token que aparece: el primer URI (índice 0) de la matriz. 
Necesitamos que sea un número de índice aleatorio para que aparezca una imagen NFT aleatoria como URI del 
token.

Estos son los pasos:

1. Revisar un ejemplo de Chainlink VRF

Mira el super breve ejemplo de uso de Chainlink VRF - sólo tienes que implementar dos funciones para
obtener aleatoriedad criptográficamente demostrable dentro del Contrato Inteligente NFT.

2. Actualiza tu contrato inteligente NFT para utilizar dos funciones VRF

Actualiza tu contrato inteligente NFT para usar requestRandomWords y fulfillRandomWords

3. Utiliza el simulacro VRF en la rama de aleatoriedad
 
Utiliza el mock VRF proporcionado en la rama randomness del repositorio de referencia, y asegúrate de leer cuidadosamente las instrucciones comentadas en el mock VRF para saber exactamente cómo usarlo.

4. Despliega tu NFT Dinámico en Goerli

Por último, una vez que hayas jugado con el contrato inteligente NFT y hayas conseguido que cambie el tokenURI dinámicamente unas cuantas veces en Remix, conecta Metamask y Remix a Rinkeby y despliega la NFT.

    📘

    Cuando despliegues la NFT en Rinkeby, podrás seguir utilizando los mocks, pero tendrás que desplegarlos también y en el orden correcto.

Complete lo siguiente en el orden correcto:

1. Conecta tu Metamask a Goerli

2. Adquiere LINK de prueba y ETH de prueba del Chainlink Faucet.

Si planea desplegar el agregador de precios de prueba y actualizarlo a los precios de Chainlink Goerli más 
tarde, despliegue el simulacro ahora. Del mismo modo, si tiene intención de realizar pruebas en Goerli 
utilizando el simulador VRF debe desplegarlo en Goerli.

3. Despliega el contrato inteligente NFT en Goerli.

Asegúrate de pasar los parámetros correctos del constructor.

Si estás usando los mocks, asegúrate de que se despliegan primero para que puedas pasar sus direcciones 
Goerli al constructor del contrato NFT.

Si utiliza una fuente de precios en tiempo real de Chainlink, su dirección debe ser la del repositorio de 
referencia o la dirección Goerli que elija aquí.

Dado que puede conectar su "entorno" Remix al contrato NFT desplegado en Goerli, y llamar al performUpkeep 
del contrato NFT desde Remix, puede mantener el intervalo corto para la primera ejecución de prueba.

    📘

    Recuerde aumentar el intervalo llamando a setInterval, de lo contrario la red de Keepers ejecutará su performUpkeep mucho más a menudo de lo que el Price Feed mostrará nuevos datos.

También puedes cambiar la dirección de tu Price Feed llamando a setPriceFeed y pasando la dirección a la 
que quieres que apunte.

    📘

    Si performUpkeep comprueba que no hay cambios en el precio, ¡los token URI no se actualizarán!

Hay que ver:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat run --network goerli scripts/deployUpdf.js
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
   --> contracts/VegetationCitiesUpdf.sol:139:109:
    |
139 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
    |                                                                                                             ^^^^^^^^^^^^


Compiled 1 Solidity file successfully
VegetationCitiesUpdf deployed to: 0xADA0d5670004E808206595b9AA7Bf920c3679Ea8 (NOTE = You contract address
must be diferent to this)
```

Genere la Suscripción de Upkeep y VRF en la interfaz Web de la neetwork ChainLink:

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")
![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

Genere un único archivo con todo el código fuente (el contrato inteligente principal + la biblioteca 
importado) usando la siguiente instrucción:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat flat contracts/VegetationCitiesUpdf.sol > contracts/
VegetationCitiesUpdf_flat.sol

```

Debemos ver un nuevo archivo en la carpeta contratos (VegetationCitiesUpdf_flat.sol)

Ahora verifique y publique el contrato inteligente VegetationCitiesUpfs.sol usando:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/
5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpdf_flat.
sol:VegetationCitiesUpdf --constructor-args argumentsVeget01.js --network goerli
0xADA0d5670004E808206595b9AA7Bf920c3679Ea8 (NOTE = You contract address must be diferent to
this)
```

Entonces deberíamos ver algo similar a:

```
llabori@Xubuntu64Bits-virtual-machine:~/BlockChains/AlchemyUniversity/5-APIsSmartContractsChainlink$ npx hardhat verify --contract contracts/VegetationCitiesUpdf_flat.sol:VegetationCitiesUpdf --constructor-args argumentsVeget01.js --network goerli 0xADA0d5670004E808206595b9AA7Bf920c3679Ea8
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpdf_flat.sol:3917:109:
     |
3917 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Compiled 1 Solidity file successfully
Warning: Unnamed return variable can remain unassigned. Add an explicit return with value to all non-reverting code paths or name the variable.
    --> contracts/VegetationCitiesUpdf_flat.sol:3917:109:
     |
3917 |     function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /*performData*/) {
     |                                                                                                             ^^^^^^^^^^^^


Successfully submitted source code for contract
contracts/VegetationCitiesUpdf_flat.sol:VegetationCitiesUpdf at 0xADA0d5670004E808206595b9AA7Bf920c3679Ea8
for verification on the block explorer. Waiting for verification result...

Successfully verified contract VegetationCitiesUpdf on Etherscan.
https://goerli.etherscan.io/address/0xADA0d5670004E808206595b9AA7Bf920c3679Ea8#code
```

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

4. Mintea tu primer token, y comprueba su URI a través de la Interfaz Web en https://goerli.etherscan.io/

![Alt text](https://www.github.com/assets.digitalocean.com/articles/alligator/boo.svg "a title")

Debería ser el vegetation01.json. ¡Compruébalo en OpenSea si quieres!

5. Juega con los valores simulados

Si estás usando los dos mocks, juega con los valores y mira los cambios en los NFTs llamando a 
tokenURI.

6. Cambiar a los contratos Chainlink en vivo en Goerli

Cuando esté listo para cambiar a los contratos Chainlink en vivo en Rinkeby, actualice la dirección del 
feed de precios y el vrfCoordinator en el contrato NFT llamando a sus funciones setter.

6. Registre su contrato inteligente NFT

A continuación, registre su contrato inteligente NFT desplegado en Goerli como un nuevo "mantenimiento" en 
el registro Chainlink Keepers Registry

7. Cree y financie una suscripción VRF*\*.

Si estás usando el VRF en vivo de Goerli Chainlink asegúrate de llamar a setVrfCoordinator() para dejar de 
usar tu VRF Mock en Goerli. 

Si no lo has implementado, eso es parte de tu aprendizaje, y puedes comprobar el repo de referencia.

8. Comprueba OpenSea en una o dos horas

Dependiendo de la frecuencia con la que cambien los precios (y si quieres hacerlo inmediatamente, entonces 
sigue usando los mocks en Goerli).

    📘

    OpenSea almacena en caché los metadatos y puede que no se muestren durante un tiempo aunque puedes llamar a tokenURI y ver los metadatos actualizados.

    Puedes intentar forzar una actualización en OpenSea con el parámetro force_update pero puede que no actualice las imágenes a tiempo. El nombre de la NFT debería actualizarse como mínimo.

Ahora vamos a añadir algunos retos divertidos para que los pruebes por tu cuenta antes de enviar tu 
proyecto:

    Añada un icono junto a las direcciones NFT para facilitar a las personas que vean su sitio web la copia de la dirección del contrato.
    del contrato.
    Añada un sistema de paginación para ver más de 100 NFT, utilizando el parámetro pageKey del endpoint getNFTs
    endpoint.

Y asegúrate de compartir tus reflexiones sobre este proyecto para ganar tu token de Prueba de Conocimiento (PoK): https://university.alchemy.com/discord


## Construido con 🛠️

_Herramientas que utilizamos para crear el proyecto y las cuales utilizamos para desarrollar el Desafio_

- [Visual Studio Code](https://code.visualstudio.com/) - El IDE
- [Alchemy](https://dashboard.alchemy.com) - Interfaz/API para la Red Goerli Tesnet
- [Xubuntu](https://xubuntu.org/) - Sistema operativo basado en la distribución Ubuntu
- [Goerli Testnet](https://goerli.etherscan.io) - Sistema web utilizado para verificar transacciones,
  verificar contratos, desplegar contratos, verificar y publicar código fuente de contratos, etc.
- [Opensea](https://testnets.opensea.io) - Sistema web utilizado para verificar/visualizar nuestra NFT
- [Solidity](https://soliditylang.org) Lenguaje de programación orientado a objetos para implementar
  contratos inteligentes en varias plataformas de cadenas de bloques.
- [Hardhat](https://hardhat.org) - Entorno utilizado por los desarrolladores para probar, compilar,
  desplegar y depurar dApps basadas en la cadena de bloques Ethereum.
- [GitHub](https://github.com/) - Servicio de alojamiento en Internet para el desarrollo de software y
  el control de versiones mediante Git.
- [Goerli Faucet](https://goerlifaucet.com/) - Faucet que es usado para obtener ETH y utilizar los mismos 
  para deployar los Smart Contract asi como para interactuar con los mismos.
- [ChainLink Faucet](https://faucets.chain.link/) - Faucet used to obtain LINK los cuales son empleados en 
  la interacción con el sistema de Automatización así como con el Verificador de números aleatorios en la 
  Red de ChainLink.
- [Ether Scan](https://etherscan.io/myaccount) - Para generar las claves de la API para interactuar con 
Goerli Tesnet.
- [Automation ChainLink](https://automation.chain.link/goerli/) - Para generar la asociación de 
  Mantenimiento de Automatización a Contrato Inteligente desplegado en Goerli Tesnet.
- [VRF ChainLink](https://vrf.chain.link/goerli) - To generate the VRF association pointing to the smart 
  contract for Random Number Verification in Goerli Tesnet.
- [GitHub ChainLink repo](https://github.com/zeuslawyer/chainlink-dynamic-nft-alchemy) - GitHub Repo with 
  the principal code used to development all the systems.
- [MetaMask](https://metamask.io) - MetaMask es una cartera de criptodivisas de software utilizada
  para interactuar con la blockchain de Ethereum.
- [UpScaler](https://imageupscaler.com/ai-image-generator/) - Sistema Web utilizado para la generación de 
las seis (6) imágenes utilizadas que fueron publicadas en IPFS. Este sistema emplea Inteligencia 
Artificial para generar las imágenes con base a un textos referidos como Inputs.

## Contribuir 🖇️

Por favor, lee [CONTRIBUTING.md](https://gist.github.com/llabori-venehsoftw/xxxxxx) para más detalles sobre
nuestro código de conducta, y el proceso para enviarnos pull requests.

## Wiki 📖

N/A

## Versionado 📌

Utilizamos [GitHub] para versionar todos los archivos utilizados (https://github.com/tu/proyecto/tags).

## Autores ✒️

_Personas que colaboraron con el desarrollo del reto_.

- **VeneHsoftw** - _Trabajo Inicial_ - [venehsoftw](https://github.com/venehsoftw)
- **Luis Labori** - _Trabajo inicial_, _Documentaciónn_ - [llabori-venehsoftw](https://github.com/
  llabori-venehsoftw)

## Licencia 📄

Este proyecto está licenciado bajo la Licencia (MIT) - ver el archivo [LICENSE.md](LICENSE.md)
para más detalles.

## Gratitud 🎁

- Si la información reflejada en este Repo te ha parecido de gran importancia, por favor, amplía tu
  colaboración pulsando el botón de la estrella en el margen superior derecho. 📢
- Si está dentro de sus posibilidades, puede ampliar su donación a través de la siguiente dirección:
  `0xAeC4F555DbdE299ee034Ca6F42B83Baf8eFA6f0D`

---

⌨️ con ❤️ por [Venehsoftw](https://github.com/llabori-venehsoftw) 😊
