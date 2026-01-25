# pillar creation kit

you can view documentation [here](https://pillarworks-rbx.github.io/kit/).

## non-rojo users
1. open the place file at assets/place.rbxl.
2. nothing else is needed.

## rojo users
1. install rokit *(the toolchain manager)* and pesde *(the package manager)*.
2. run `rokit install` in a terminal or command prompt.
3. run `rojo plugin install` in a terminal or command prompt.
4. run `pesde install` in a terminal or command prompt.
5. open the place file at assets/place.rbxl.
6. depending on your ide of choice, go to your chapter below. or, you can run `lune run sync` in a terminal or command prompt, which will execute all of the commands for you.

### for zed
1. for zed users, i have provided a list of tasks you can use by pressing alt + shift + t.
2. use them in this order: autogenerate sourcemap, build network, darklua process, serve.
3. start syncing with the roblox plugin.

### for any other ides
1. create four new terminals or command prompts.
2. run `rojo sourcemap --output sourcemap.json --watch` in the first terminal.
3. run `blink ext/network/core.blink --watch` in the second terminal.
4. run `darklua process src out --watch` in the third terminal.
5. run `rojo serve game.project.json` in the fourth terminal.
6. start syncing with the roblox plugin.