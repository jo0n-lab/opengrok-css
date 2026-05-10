(function () {
  var storageKey = 'opengrok-theme';
  var root = document.documentElement;

  function currentTheme() {
    return root.getAttribute('data-og-theme') || 'dark';
  }

  function setTheme(theme) {
    root.setAttribute('data-og-theme', theme);
    try {
      window.localStorage.setItem(storageKey, theme);
    } catch (error) {
      // Ignore private-mode storage failures.
    }
    var button = document.querySelector('.og-theme-toggle');
    if (button) {
      button.setAttribute('aria-pressed', theme === 'light' ? 'true' : 'false');
      button.setAttribute('title', theme === 'light' ? 'Switch to dark theme' : 'Switch to light theme');
    }
  }

  function addToggle() {
    var bar = document.querySelector('#bar ul');
    if (!bar || document.querySelector('.og-theme-switcher')) {
      return;
    }

    var item = document.createElement('li');
    item.className = 'og-theme-switcher';

    var button = document.createElement('button');
    button.type = 'button';
    button.className = 'og-theme-toggle';
    button.innerHTML = '<span class="og-theme-option og-theme-dark">dark</span><span class="og-theme-separator">|</span><span class="og-theme-option og-theme-light">light</span>';
    button.addEventListener('click', function () {
      setTheme(currentTheme() === 'light' ? 'dark' : 'light');
    });

    item.appendChild(button);
    bar.appendChild(item);
    setTheme(currentTheme());
  }

  addToggle();
  document.addEventListener('DOMContentLoaded', addToggle);
})();
