const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();

// Serve Flutter web build
app.use(express.static(path.join(__dirname, '../build/web')));

// Proxy API requests
app.use('/auth', createProxyMiddleware({
  target: 'https://admin.manamanasuites.com',
  changeOrigin: true,
  secure: true,
  pathRewrite: { '^/auth': '/auth' },
}));

// Fallback for Flutter routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../build/web/index.html'));
});

const PORT = 5001;
app.listen(PORT, () => console.log(`App running at http://localhost:${PORT}`));
