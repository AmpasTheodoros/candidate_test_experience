import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '1m', target: 1000 },
    { duration: '3m', target: 1000 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  let res = http.get('https://candidate.ampassador.com/test-dialogs');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
