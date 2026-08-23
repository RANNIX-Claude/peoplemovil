import React, { useEffect } from 'react';

export default function Modal({ open, onClose, title, children, footer, wide = false }) {
  useEffect(() => {
    function onKey(e) { if (e.key === 'Escape' && open) onClose?.(); }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  return (
    <div className={'modal-overlay' + (open ? ' open' : '')}
      onClick={e => e.target === e.currentTarget && onClose?.()}>
      <div className={'modal-box' + (wide ? ' wide' : '')}>
        <div className="modal-head">
          <span className="modal-title">{title}</span>
          <button className="modal-close" onClick={onClose} aria-label="Cerrar">×</button>
        </div>
        <div className="modal-body">{children}</div>
        {footer && <div className="modal-foot">{footer}</div>}
      </div>
    </div>
  );
}
