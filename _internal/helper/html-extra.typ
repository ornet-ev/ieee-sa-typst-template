#import "@preview/bullseye:0.1.0": *

#let add-html-view-mode = context on-target(html: {
  html.elem("style", read("style.css"))
  html.elem("script", "
    (function() {
      const stored = localStorage.getItem('theme');
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      const theme = stored ?? (prefersDark ? 'dark' : 'light');
      document.documentElement.setAttribute('data-theme', theme);
    })();

    function themeToggle() {
      const html = document.documentElement;
      const next = html.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      html.setAttribute('data-theme', next);
      localStorage.setItem('theme', next);
    }
  ")
  html.elem("button", attrs: (
    id: "theme-toggle",
    onclick: "themeToggle()",
    "aria-label": "Toggle dark mode"
  ))[
      #html.elem("span", attrs: (class: "theme-icon"))[]
  ]
})