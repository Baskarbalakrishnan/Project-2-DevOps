const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from AWS DevOps CI/CD Pipeline dev test6 - environment test');
});

app.listen(port, '0.0.0.0', () => {
  console.log(`App running on port ${port}`);
});

