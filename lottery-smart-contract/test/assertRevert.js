// error를 try-catch로 잡는다.
// 이때 error 문구에 revert가 있다면 정상적으로 수행 완료
module.exports = async (promise) => {
    try {
        await promise;
        assert.fail('Expected revert not received');
    } catch (error) {
        const revertFound = error.message.search('revert') >= 0;
        assert(revertFound, `Expected "revert", got ${error} instead`);
    }
}