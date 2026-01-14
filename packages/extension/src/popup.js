const statusEl = document.getElementById('status');
const statusTextEl = document.getElementById('statusText');
const connectBtn = document.getElementById('connectBtn');
const disconnectBtn = document.getElementById('disconnectBtn');

function updateUI(status) {
  statusEl.className = `status ${status}`;

  const labels = {
    connected: 'Connected',
    connecting: 'Connecting...',
    reconnecting: 'Reconnecting...',
    disconnected: 'Disconnected',
    failed: 'Connection Failed',
  };
  statusTextEl.textContent = labels[status] || status;

  const showConnect = status === 'disconnected' || status === 'failed';
  const showDisconnect = status === 'connected' || status === 'connecting' || status === 'reconnecting';
  connectBtn.style.display = showConnect ? 'block' : 'none';
  disconnectBtn.style.display = showDisconnect ? 'block' : 'none';
}

// Get initial status
chrome.runtime.sendMessage({ type: 'getStatus' }, (response) => {
  if (response) {
    updateUI(response.status);
  }
});

// Listen for status updates
chrome.runtime.onMessage.addListener((message) => {
  if (message.type === 'status') {
    updateUI(message.status);
  }
});

connectBtn.addEventListener('click', () => {
  chrome.runtime.sendMessage({ type: 'connect' });
  updateUI('connecting');
});

disconnectBtn.addEventListener('click', () => {
  chrome.runtime.sendMessage({ type: 'disconnect' });
  updateUI('disconnected');
});
