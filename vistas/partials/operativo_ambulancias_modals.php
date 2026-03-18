<div class="modal fade" id="choferOperativoModal" tabindex="-1" aria-labelledby="choferOperativoModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form id="formularioChoferOperativo" novalidate>
                <div class="modal-header">
                    <h5 class="modal-title" id="choferOperativoModalLabel">Registrar chofer operativo</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p class="operativo-help mb-3">Usa este formulario para crear o actualizar el perfil operativo del conductor. Si seleccionas un empleado ya registrado, el sistema actualiza su ficha.</p>
                    <div class="form-group">
                        <label for="id_empleado_operativo" data-toggle="tooltip" title="Empleado que recibira el perfil operativo de chofer de ambulancia.">Empleado</label>
                        <select id="id_empleado_operativo" name="id_empleado" class="form-control" required title="Seleccione el empleado que conducira la ambulancia.">
                            <option value="">Seleccione un empleado</option>
                        </select>
                        <small class="form-text text-muted">Puedes escribir nombre o cedula para encontrar rapidamente al empleado.</small>
                    </div>
                    <div class="alert alert-info d-none mb-3" id="choferExistenteHint"></div>
                    <div class="alert alert-danger d-none mb-3" id="licenciaVencidaHint"></div>
                    <div class="form-group">
                        <label for="id_unidad_asignada_chofer" data-toggle="tooltip" title="Unidad disponible que se asignara directamente al chofer al guardar el perfil. Solo se muestran ambulancias disponibles.">Unidad disponible</label>
                        <select id="id_unidad_asignada_chofer" name="id_unidad_asignada" class="form-control" title="Busque por codigo o placa la unidad que desea dejar conectada a este chofer.">
                            <option value="">Dejar sin unidad por ahora</option>
                        </select>
                        <small class="form-text text-muted">Puedes escribir el codigo o la placa. Si el chofer ya tiene una unidad activa, el sistema la mostrara y no permitira asignarle otra desde este formulario.</small>
                    </div>
                    <div class="alert alert-warning d-none mb-3" id="unidadChoferOperativoHint"></div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="numero_licencia" data-toggle="tooltip" title="Numero oficial de la licencia de conducir del chofer.">Numero de licencia</label>
                            <input type="text" id="numero_licencia" name="numero_licencia" class="form-control" maxlength="60" placeholder="Ej: LIC-000123" autocomplete="off" required title="Escriba el numero exacto de la licencia del chofer.">
                        </div>
                        <div class="form-group col-md-6">
                            <label for="categoria_licencia" data-toggle="tooltip" title="Grado vigente de la licencia de conducir del chofer.">Grado de licencia</label>
                            <select id="categoria_licencia" name="categoria_licencia" class="form-control" required title="Seleccione el grado de licencia vigente del chofer.">
                                <option value="">Seleccione el grado</option>
                                <option value="2do grado">2do grado</option>
                                <option value="3er grado">3er grado</option>
                                <option value="4to grado">4to grado</option>
                                <option value="5to grado">5to grado</option>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group col-md-6">
                            <label for="vencimiento_licencia" data-toggle="tooltip" title="Fecha en la que vence la licencia del conductor.">Vencimiento</label>
                            <input type="date" id="vencimiento_licencia" name="vencimiento_licencia" class="form-control" required title="Seleccione la fecha de vencimiento de la licencia.">
                            <small class="form-text text-muted">Si la licencia ya vencio, el sistema no permitira guardar el perfil operativo.</small>
                        </div>
                        <div class="form-group col-md-6">
                            <label for="telefono_contacto_emergencia" data-toggle="tooltip" title="Telefono del familiar o contacto que se llamaria en caso de contingencia.">Telefono de emergencia</label>
                            <input type="text" id="telefono_contacto_emergencia" name="telefono_contacto_emergencia" class="form-control" maxlength="30" placeholder="Ej: 0414-1234567" autocomplete="off" required title="Indique el telefono del contacto de emergencia del chofer.">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="contacto_emergencia" data-toggle="tooltip" title="Nombre y parentesco del contacto de emergencia del conductor.">Contacto de emergencia</label>
                        <input type="text" id="contacto_emergencia" name="contacto_emergencia" class="form-control" maxlength="120" placeholder="Ej: Maria Perez - esposa" autocomplete="off" required title="Escriba nombre y parentesco del contacto de emergencia.">
                    </div>
                    <div class="form-group mb-0">
                        <label for="observaciones_chofer" data-toggle="tooltip" title="Observaciones del perfil: guardias, restricciones o detalles medicos relevantes.">Observaciones</label>
                        <textarea id="observaciones_chofer" name="observaciones_chofer" class="form-control" rows="2" placeholder="Datos adicionales del conductor" title="Agregue notas utiles del perfil operativo del chofer."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary" id="btnGuardarChoferOperativo">
                        <i class="fas fa-save"></i> Guardar chofer
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="controlUnidadOperativaModal" tabindex="-1" aria-labelledby="controlUnidadOperativaModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content">
            <form id="formularioControlUnidad" novalidate>
                <div class="modal-header">
                    <h5 class="modal-title" id="controlUnidadOperativaModalLabel">Unidades operativas</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Cerrar">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <p class="operativo-help mb-3">Desde aqui puedes ver las ambulancias registradas, crear nuevas unidades y actualizar su estado operativo, prioridad y ubicacion.</p>
                    <div class="row">
                        <div class="col-lg-5 mb-4 mb-lg-0">
                            <div class="d-flex align-items-center justify-content-between flex-wrap mb-3" style="gap:10px;">
                                <h6 class="mb-0">Unidades registradas</h6>
                                <button type="button" class="btn btn-outline-primary btn-sm" id="btnNuevaUnidadOperativa">
                                    <i class="fas fa-plus"></i> Nueva unidad
                                </button>
                            </div>
                            <div class="form-group">
                                <label for="buscadorUnidadesControl" data-toggle="tooltip" title="Filtra rapidamente por codigo, placa o descripcion.">Buscar unidad</label>
                                <input type="text" id="buscadorUnidadesControl" class="form-control" placeholder="Escribe codigo, placa o descripcion" autocomplete="off">
                            </div>
                            <div id="listaUnidadesControl" class="operativo-unit-list"></div>
                        </div>
                        <div class="col-lg-7">
                            <input type="hidden" id="id_unidad_control" name="id_unidad" value="">
                            <div class="alert alert-info d-none" id="unidadControlHint"></div>
                            <div class="form-row">
                                <div class="form-group col-md-6">
                                    <label for="codigo_unidad_control" data-toggle="tooltip" title="Codigo interno corto de la ambulancia.">Codigo de unidad</label>
                                    <input type="text" id="codigo_unidad_control" name="codigo_unidad" class="form-control" maxlength="40" placeholder="Ej: AMB-02" autocomplete="off" required title="Escriba el codigo con el que se identifica la unidad.">
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="placa_unidad_control" data-toggle="tooltip" title="Placa oficial de la ambulancia.">Placa</label>
                                    <input type="text" id="placa_unidad_control" name="placa" class="form-control" maxlength="20" placeholder="Ej: AB123CD" autocomplete="off" required title="Indique la placa exacta de la unidad.">
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="descripcion_unidad_control" data-toggle="tooltip" title="Descripcion o detalle corto de la ambulancia.">Descripcion</label>
                                <input type="text" id="descripcion_unidad_control" name="descripcion" class="form-control" maxlength="140" placeholder="Ej: Ambulancia de soporte basico" autocomplete="off" required title="Describa brevemente la unidad.">
                            </div>
                            <div class="form-row">
                                <div class="form-group col-md-4">
                                    <label for="estado_operativo_control" data-toggle="tooltip" title="Disponible deja la unidad lista para salida. Fuera de servicio la oculta de las asignaciones.">Estado operativo</label>
                                    <select id="estado_operativo_control" name="estado_operativo" class="form-control" required title="Defina el estado operativo actual de la unidad.">
                                        <option value="DISPONIBLE">Disponible</option>
                                        <option value="FUERA_SERVICIO">Fuera de servicio</option>
                                    </select>
                                </div>
                                <div class="form-group col-md-4">
                                    <label for="prioridad_despacho_control" data-toggle="tooltip" title="Orden de sugerencia automatica. El numero mas bajo sale primero.">Prioridad</label>
                                    <input type="number" id="prioridad_despacho_control" name="prioridad_despacho" class="form-control" min="1" placeholder="1" autocomplete="off" required title="Indique el orden de despacho de la unidad.">
                                </div>
                                <div class="form-group col-md-4">
                                    <label for="codigo_estado_unidad_control" data-toggle="tooltip" title="Resumen visual del estado actual cargado para la unidad seleccionada.">Resumen</label>
                                    <input type="text" id="codigo_estado_unidad_control" class="form-control" value="Sin seleccionar" readonly>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group col-md-6">
                                    <label for="ubicacion_actual_control" data-toggle="tooltip" title="Ubicacion textual mas reciente de la ambulancia.">Ubicacion actual</label>
                                    <input type="text" id="ubicacion_actual_control" name="ubicacion_actual" class="form-control" maxlength="190" placeholder="Ej: Base central, CDI, parroquia" autocomplete="off" required title="Escriba la ubicacion actual de la unidad.">
                                </div>
                                <div class="form-group col-md-6">
                                    <label for="referencia_actual_control" data-toggle="tooltip" title="Referencia rapida para ubicar la unidad con precision.">Referencia</label>
                                    <input type="text" id="referencia_actual_control" name="referencia_actual" class="form-control" maxlength="190" placeholder="Ej: Frente al ambulatorio, estacionamiento lateral" autocomplete="off" title="Agregue una referencia que facilite el hallazgo de la unidad.">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-secondary" id="btnGuardarControlUnidad">
                        <i class="fas fa-save"></i> Guardar unidad
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
