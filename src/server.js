const express = require('express');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

app.disable('x-powered-by');

const publicDirectoryPath = path.join(__dirname, '..', 'public');
app.use(express.static(publicDirectoryPath));

app.get('/healthz', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Clock app listening on http://0.0.0.0:${port}`);
});


