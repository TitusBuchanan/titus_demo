(function () {
  const clockEl = document.getElementById('clock');
  const dateEl = document.getElementById('date');

  function updateClock() {
    const now = new Date();

    const time = new Intl.DateTimeFormat(undefined, {
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    }).format(now);

    const date = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    }).format(now);

    clockEl.textContent = time;
    dateEl.textContent = date;
  }

  updateClock();
  setInterval(updateClock, 1000);
})();


