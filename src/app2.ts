import { toBase26 } from './utils/base26'

let print = console.log

print("hello2")

print(" 1: ", toBase26(1))
print(" 2: ", toBase26(2))
print("26: ", toBase26(26))
print("27: ", toBase26(27))
print("28: ", toBase26(28))
print("52: ", toBase26(52))

function calcDMXAddress(address: number) {
    let univ = 1 + Math.floor((address - 1) / 512)
    let chan = 1 + (address - 1) % 512
    return univ + '/' + chan
}

function calcDMXAddress2(address: number) {
    let univ = 1 + Math.floor((address - 1) / 512)
    let chan = 1 + (address - 1) % 512
    return univ + '/' + chan
}

print("  1:", calcDMXAddress(1))
print("512:", calcDMXAddress(512))
print("513:", calcDMXAddress(513))

function Start() { }
function Cleanup() { }

export { Start, Cleanup }