// Export the functionality defined in another internal Javascript file of this service compnent
export { multiplyTwoNumbers } from './multiple';

// We define only one function, and we do a "named export"
export function sumTwoNumbers(a, b){
    return a + b;
}