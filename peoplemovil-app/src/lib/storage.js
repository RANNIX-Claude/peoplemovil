import { supabase } from './supabase.js';

// Bucket privado (Migración 024) — fotos y documentos con datos personales
// (INE, CURP, comprobante de domicilio) nunca se sirven públicos; todo pasa
// por signed URLs de corta duración generadas bajo demanda.
const BUCKET = 'expedientes';

function sanitizar(nombre) {
  return (nombre || 'archivo').replace(/[^a-zA-Z0-9.\-_]/g, '_');
}

// Sube un archivo del expediente de un empleado. Devuelve el path guardado
// (no una URL pública — el bucket es privado).
export async function subirArchivoEmpleado(tenantId, empleadoId, file, carpeta = 'documentos') {
  const path = `${tenantId}/${empleadoId}/${carpeta}/${Date.now()}_${sanitizar(file.name)}`;
  const { error } = await supabase.storage.from(BUCKET).upload(path, file, { upsert: false, cacheControl: '3600' });
  if (error) throw error;
  return path;
}

// Los datos sembrados (demo) traen URLs públicas de DiceBear en foto_url;
// los archivos subidos desde esta pantalla guardan un path del bucket privado.
// Esta función resuelve cualquiera de los dos a algo que <img>/<a> pueda usar.
export async function resolverUrlArchivo(valor, segundos = 3600) {
  if (!valor) return null;
  if (/^https?:\/\//i.test(valor)) return valor;
  const { data, error } = await supabase.storage.from(BUCKET).createSignedUrl(valor, segundos);
  if (error) return null;
  return data.signedUrl;
}

export async function eliminarArchivoEmpleado(path) {
  if (!path || /^https?:\/\//i.test(path)) return; // no se borran URLs externas (demo)
  await supabase.storage.from(BUCKET).remove([path]);
}
