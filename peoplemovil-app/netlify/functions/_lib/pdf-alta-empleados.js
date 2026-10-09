// Genera el PDF "Relación de personal dado de alta" que el legado adjunta al
// correo de alta automática (ver NOTIFICACIONES_RECLUTAMIENTO.md §1.2).
// Columnas replicadas del PDF original: Num.Empleado, Nombre, Puesto, Solicitud.

import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';

const MARGIN = 40;
const ROW_H = 16;
const COLS = [
  { key: 'numEmpleado', label: 'Num.Empleado', w: 90 },
  { key: 'nombre',      label: 'Nombre',       w: 230 },
  { key: 'puesto',      label: 'Puesto',       w: 120 },
  { key: 'solicitud',   label: 'Solicitud',    w: 80 }
];

export async function generarPdfAltaEmpleados(empleados, fecha) {
  const pdf = await PDFDocument.create();
  const font = await pdf.embedFont(StandardFonts.Helvetica);
  const fontBold = await pdf.embedFont(StandardFonts.HelveticaBold);

  let page = pdf.addPage([612, 792]); // carta
  let y = 792 - MARGIN;

  const titulo = `Relación de personal dado de alta con fecha: ${fecha || ''}`;
  page.drawText(titulo, { x: MARGIN, y, size: 12, font: fontBold, color: rgb(0.1, 0.1, 0.1) });
  y -= 28;

  const drawRow = (values, opts = {}) => {
    let x = MARGIN;
    for (let i = 0; i < COLS.length; i++) {
      const text = String(values[i] ?? '');
      page.drawText(text.slice(0, 48), { x, y, size: 9, font: opts.bold ? fontBold : font, color: rgb(0.15, 0.15, 0.15) });
      x += COLS[i].w;
    }
  };

  drawRow(COLS.map(c => c.label), { bold: true });
  y -= 6;
  page.drawLine({ start: { x: MARGIN, y }, end: { x: 612 - MARGIN, y }, thickness: 0.75, color: rgb(0.6, 0.6, 0.6) });
  y -= ROW_H;

  for (const e of empleados) {
    if (y < MARGIN + ROW_H) {
      page = pdf.addPage([612, 792]);
      y = 792 - MARGIN;
    }
    drawRow([e.numEmpleado, e.nombre, e.puesto, e.solicitud]);
    y -= ROW_H;
  }

  return pdf.save();
}
