import { toBase26 } from './utils/base26'
// import * as nnz from './utils/nnz'
// let template = require("lib/pl/template")


if (gma) {
    gma.echo("123")
    gma.feedback(1, 2, 3)
    gma.sleep(1)
}

print("hello")

print(" 1: ", toBase26(1))
print(" 2: ", toBase26(2))
print("26: ", toBase26(26))
print("27: ", toBase26(27))
print("28: ", toBase26(28))
print("52: ", toBase26(52))

function calcDMXAddress(address: number) {
    let univ = 1 + Lua.FloorDiv(address - 1, 512)
    let chan = 1 + Lua.Modulo(address - 1, 512)
    return univ + '/' + chan
}

print("  1:", calcDMXAddress(1))
print("512:", calcDMXAddress(512))
print("513:", calcDMXAddress(513))

function Start() { }
function Cleanup() { }

// @ts-expect-error
return $multi(Start, Cleanup)
