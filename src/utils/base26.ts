/** Convert number to Base26 string
 * @param {number} num one based number
 */
export function toBase26(num: number): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    const radix = chars.length

    let result = ''
    while (num > 0) {
        let index = (num - 1) % radix
        result = chars[index] + result
        num = Math.floor((num - 1) / radix)
    }
    return result
}
