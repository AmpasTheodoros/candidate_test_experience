const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());
app.use(cors());

// Set up the PostgreSQL connection pool.
// Replace 'your_neon_connection_string_here' with your actual Neon PostgreSQL connection string
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

// Login endpoint: validates user credentials using Neon PostgreSQL
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const result = await pool.query("SELECT * FROM users WHERE username = $1", [username]);
    if (result.rows.length > 0) {
      const user = result.rows[0];
      // For demonstration, we're doing a plain text match.
      // In production, store hashed passwords and compare using bcrypt.
      if (user.password === password) {
        res.json({ success: true, token: 'dummy-jwt-token' });
      } else {
        res.status(401).json({ success: false, message: 'Invalid credentials' });
      }
    } else {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
  } catch (err) {
    console.error("Error during login: ", err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Test Dialogs endpoint: serves JSON data for the test dialog
app.get('/test-dialogs', (req, res) => {
  const dialogData = {
    language: 'en-GB',
    title: 'Demo Test Dialog',
    nodes: [
      {
        id: 1,
        text: 'Do you want to play a game?',
        options: [
          { id: 1, text: 'Yes', next: 2, points: 1 },
          { id: 2, text: 'No', next: 3, points: 0 }
        ]
      },
      {
        id: 2,
        text: 'Great! Let’s start.',
        options: []
      },
      {
        id: 3,
        text: 'Maybe next time.',
        options: []
      }
    ]
  };
  res.json(dialogData);
});

app.listen(port, () => {
  console.log(`Backend API is running on port ${port}`);
});
