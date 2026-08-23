// Espejo en cliente del catálogo cat_plan_suscripcion.
// La verdad-verdad la impone la base con verificar_limite() en triggers,
// esto es solo para deshabilitar UI de forma amable.
export const PLANES = {
  FREE: {
    codigo: 'FREE',
    titulo: 'FREE / Piloto',
    max_sitios: 1,
    max_empleados_activos: 15,
    incluye_checador_movil: false,
    incluye_asignacion: false,
    incluye_nomina: false,
    incluye_repse: false,
    precio_mensual_mxn: 0
  },
  PRO: {
    codigo: 'PRO',
    titulo: 'PRO',
    max_sitios: null,
    max_empleados_activos: null,
    incluye_checador_movil: true,
    incluye_asignacion: true,
    incluye_nomina: true,
    incluye_repse: true,
    precio_mensual_mxn: 1499
  }
};

export function limiteExcede(plan, campo, usados) {
  const max = plan?.[campo];
  return max != null && usados >= max;
}
