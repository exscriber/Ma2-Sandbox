/** Convert number to Base26 string
 * @param {number} num
 * @param {number} offset A=1 by default, but can be A=0
 */
export function toBase26(num: number, offset: number = 1): string {
    const keys = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    const radix = keys.length
    let result = [];
    do {
        let rem = (num - offset) % radix;
        result.unshift(keys[rem]);
        num = Math.floor((num - offset) / radix);
    } while (num)
    return result.join('');
}
