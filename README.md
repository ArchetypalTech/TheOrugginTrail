# TheOrugginTrail ZorkMUD<>ZorkDojo
A MUD (and eventually also Dojo) based Zork-like experiment in fully onchain text adventures, onchain games framework interoperability, and the engines that drive them.

>        \/|
>       /"" ;,_               _________
>      oo _. //..___.._      |,--------
>      `-' `//=========================
>          `'\          |    ||
>            |//-----'\ (    || ,d88b,
>            //       |||    `|_888888_
>            \\_      |||       888888
>           '-\/     '/_(       `Y88P' fL

What lies ahead, is anyone's guess...

This project is a test-case for taking a zork-like text adventure engine and porting it to onchain gaming engines and frameworks like MUD and Dojo, and from there seeing if interesting interoperability between the engines can be connected and experimented with.

We are porting / reinterpreting the MIT Zork design and architecture for text adventure engines onchain, this model eventualy became the base for Infocom games and such favoured classics as Commodore64's The Hitchikers Guide To The Galaxy, one of the most ambitious and complex text adventures ever made. To get a primer and learn more about the engine and explore it's history and and the engineering principles under the hood please read these resources:

https://mud.co.uk/richard/zork.htm

https://github.com/MITDDC/zork

https://medium.com/swlh/zork-the-great-inner-workings-b68012952bdc

This will Zork-like MUD engine be piloted by a text adventure called the O'ruggin Trail.

WARNING: attempting a crossing to the frontiers of crypto country ultimately always results in horrible death... physical, moral, ego, or otherwise.

Pre death you'll want to run `pnpm install` at the root 
of this repo because we aren't checking in the node_modules folder.
cruft....

**Really**. Run `pnpm install` at the project root. Or be dead. Pfft.

## Dev Setup
### Windows
- Install [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) to access a Linux terminal.
- Make sure you have [Node.js](https://nodejs.org/en/download/) v18.20.2 installed or are using [nvm](https://github.com/nvm-sh/nvm) via `nvm use` with an `.nvmrc` file at the top directory pointing to that version.
- Install [Forge](https://book.getfoundry.sh/getting-started/installation) to run the local blockchain.
- Make sure you have [pnpm](https://pnpm.io/installation) installed, as it is the package manager used in this project.
- Install [mprocs](https://github.com/pvolok/mprocs) to run multiple terminal windows simultaneously.
- Run `pnpm install` or `pnpm i` to install the dependencies.
- Run `pnpm dev` to start the local blockchain and deploy the contracts.
