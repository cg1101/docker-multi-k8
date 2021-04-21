const keys = require('./keys');
const redis = require('redis');

const redisClient = redis.createClient({
  host: keys.redisHost,
  port: keys.redisPort,
  retry_strategy: () => 1000
});
const sub = redisClient.duplicate();

function fib(index) {
  if (index < 2) return 1;
  return fib(index - 1) + fib(index - 2);
}

const func_maker = (initializer, op_func) => {
  var seq = initializer.slice();
  return n => {
    for (let i = seq.length; i <= n; i++) {
      seq[i] = op_func(seq, i);
    }
    return seq[n];
  };
}
fib = func_maker([0, 1], (seq, n) => seq[n - 1] + seq[n - 2]);
/*
for (let i = 0; i <= 40; i++) {
  console.log(`fib(${i}) = ${fib(i)}`);
}
 */

sub.on('message', (channel, message) => {
  redisClient.hset('values', message, fib(parseInt(message)));
});
sub.subscribe('insert');
