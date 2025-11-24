/* Système d'alertes/notifications */
function showAlert(type, message, duration = 5000) {
  let alertContainer = document.getElementById('alertContainer');
  if (!alertContainer) {
    alertContainer = createAlertContainer();
  }

  const alert = document.createElement('div');
  alert.className = `alert alert-${type}`;
  alert.innerHTML = `
    <span class="alert-icon">${getAlertIcon(type)}</span>
    <span class="alert-message">${message}</span>
    <button class="alert-close" onclick="this.parentElement.remove()">×</button>
  `;

  alertContainer.appendChild(alert);
  setTimeout(() => alert.classList.add('show'), 10);

  if (duration > 0) {
    setTimeout(() => {
      alert.classList.remove('show');
      setTimeout(() => alert.remove(), 300);
    }, duration);
  }
}

function createAlertContainer() {
  const container = document.createElement('div');
  container.id = 'alertContainer';
  container.className = 'alert-container';
  document.body.appendChild(container);
  return container;
}

function getAlertIcon(type) {
  const icons = {
    success: '✔',
    error: '✖',
    warning: '⚠',
    info: 'ℹ'
  };
  return icons[type] || 'ℹ';
}
