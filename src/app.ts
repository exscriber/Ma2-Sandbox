import { toBase26 } from "./utils/base26"
let utils = require("./utils/nnz")
let template = require("lib/pl/template")

if (gma) {
    gma.echo("123")
    gma.feedback(1, 2, 3)
    gma.sleep(1)
}

print(toBase26(33))

let sum = (x: number, y: number): number => {
    return x + y;
}

gma.show.getobj.class(1)

let a = gma.show.property
a.amount(1)

gma.show.getobj.label(111)

let num = 514
let div = Lua.FloorDiv(num, 512);
let mod = Lua.Modulo(num, 512)


function Start() { }
function Cleanup() { }

// @ts-expect-error
return $multi(Start, Cleanup)
