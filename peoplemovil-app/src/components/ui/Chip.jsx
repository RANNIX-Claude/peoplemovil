import React from 'react';

// Chip de filtro. Un clic activa/desactiva (togglea entre valor y 'todos' cuando aplique).
export default function Chip({ active, onClick, children }) {
  return (
    <button type="button" className={'chip' + (active ? ' on' : '')} onClick={onClick}>
      {children}
    </button>
  );
}
