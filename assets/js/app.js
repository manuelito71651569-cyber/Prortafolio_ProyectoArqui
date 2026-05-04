// ============================================================
//  APP.JS – Core Portfolio Logic
// ============================================================

const TEMA = {
  init() {
    const saved = localStorage.getItem('rm_tema') || 'dark';
    document.documentElement.setAttribute('data-theme', saved);
    this.updateIcon(saved);
  },
  toggle() {
    const cur = document.documentElement.getAttribute('data-theme');
    const next = cur === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('rm_tema', next);
    this.updateIcon(next);
  },
  updateIcon(tema) {
    // Ya no usamos emojis, el estilo se maneja por CSS
    const btn = document.getElementById('themeBtn');
    if (btn) btn.setAttribute('aria-label', tema === 'dark' ? 'Activar modo claro' : 'Activar modo oscuro');
  }
};

// Global Helpers
function getExtension(filename) {
  if (!filename) return '';
  return filename.split('.').pop().toLowerCase();
}

function getFileIcon(ext) {
  const icons = {
    pdf: '📄', doc: '📝', docx: '📝',
    xls: '📊', xlsx: '📊', ppt: '🪧', pptx: '🪧',
    zip: '🗜️', rar: '🗜️', jpg: '🖼️', png: '🖼️',
    mp4: '🎞️', html: '🌐', sql: '💾'
  };
  return icons[ext] || '📄';
}

// Auto-init on load
window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('themeBtn')) TEMA.init();
  
  // Auto-active nav link
  const currentPath = window.location.pathname;
  const navLinks = document.querySelectorAll('.nav-links a');
  navLinks.forEach(link => {
    const href = link.getAttribute('href');
    if (href && currentPath.endsWith(href)) {
      link.classList.add('active');
    } else if (currentPath.endsWith('/') && href === 'index.html') {
      link.classList.add('active');
    }
  });
});
