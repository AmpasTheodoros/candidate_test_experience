import http from 'k6/http';
import { check, sleep } from 'k6';

// Define the load test options
export let options = {
  stages: [
    { duration: '1m', target: 1000 }, // Ramp up to 1000 virtual users over 1 minute
    { duration: '3m', target: 1000 }, // Maintain 1000 users for 3 minutes
    { duration: '1m', target: 0 }     // Ramp down to 0 users over 1 minute
  ],
};

// The default function that k6 executes for each virtual user
export default function () {
  // Update the URL to match your backend's public URL or IP if deployed.
  // For local testing, ensure your backend is running at http://localhost:3000
  let res = http.get('http://localhost:3000/test-dialogs');
  
  // Check if the response status is 200
  check(res, {
    'status is 200': (r) => r.status === 200,
  });
  
  // Pause for 1 second between iterations
  sleep(1);
}
