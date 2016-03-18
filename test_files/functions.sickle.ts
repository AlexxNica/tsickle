function FunctionsTest1(a: any): string;
/**
 * @param { number} a
 * @return { string}
 */
function FunctionsTest1(a: number): string {
  return "a";
}
/**
 * @param { number} a
 * @param { number} b
 */
function FunctionsTest2(a: number, b: number) {}
/**
 * @ngInject
 * @param { number} a
 * @param { number} b
 */
function FunctionsTest3(a: number, b: number) {}
/**
 * @param { {a: number, b: number}} param0
 */
function Destructuring({a, b}: {a: number, b: number}) {}
/**
 * @param {... number} a
 */
function FunctionsTestsSplat(...a: number[]) {}
FunctionsTestsSplat(1, 2);
