<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="Portal de acceso a la Sala Situacional de la Alcaldia Bolivariana de Libertador">
  <title>Acceso | Sala Situacional Libertador</title>

  <link rel="icon" type="image/x-icon" href="favicon.png">
  <link rel="stylesheet" href="../assets/plugins/fontawesome-free/css/all.min.css">
  <link rel="stylesheet" href="css/login.css">
</head>
<body>
  <main class="auth-page">
    <section class="auth-shell">
      <aside class="auth-brand">
        <div class="brand-copy">
          <p class="brand-kicker">Alcald&iacute;a Bolivariana de Libertador</p>
          <h1>Sala Situacional</h1>
          <p>Panel de gesti&oacute;n y seguimiento de solicitudes ciudadanas.</p>
        </div>

        <ul class="brand-points">
          <li><i class="fas fa-shield-alt" aria-hidden="true"></i> Acceso seguro al sistema</li>
          <li><i class="fas fa-chart-line" aria-hidden="true"></i> Monitoreo en tiempo real</li>
          <li><i class="fas fa-users" aria-hidden="true"></i> Gesti&oacute;n centralizada por m&oacute;dulos</li>
        </ul>
      </aside>

      <section class="auth-card-wrap">
        <article class="auth-card">
          <header class="auth-card-header">
            <img src="../assets/images/logo_login.png" alt="Alcaldia Libertador" class="form-logo-main">
            <img src="../assets/images/logo_login1x10.png" alt="Programa 1x10" class="form-logo-side">
            <p class="auth-badge">Ingreso</p>
            <h2>Iniciar sesi&oacute;n</h2>
            <p>Ingresa tus credenciales para continuar al escritorio.</p>
          </header>

          <div id="loginMessage" class="login-message" role="alert" aria-live="polite"></div>

          <form id="frmAcceso" method="post" novalidate>
            <div class="field-group">
              <label for="logina">Usuario</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-user"></i></span>
                <input type="text" id="logina" name="logina" autocomplete="username" placeholder="Ej: operador1" required>
              </div>
            </div>

            <div class="field-group">
              <div class="field-label-row">
                <label for="clavea">Contrase&ntilde;a</label>
              </div>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-lock"></i></span>
                <input type="password" id="clavea" name="clavea" autocomplete="current-password" placeholder="Ingresa tu contrase&ntilde;a" required>
                <button type="button" class="toggle-pass" id="togglePassword" aria-label="Mostrar u ocultar contrase&ntilde;a">
                  <i class="fas fa-eye"></i>
                </button>
              </div>
            </div>

            <div class="login-actions">
              <label class="remember-check">
                <input type="checkbox" id="remember" name="remember">
                <span>Recordar sesi&oacute;n</span>
              </label>
              <button type="button" class="link-recovery" id="btnMostrarRecuperacion">Recuperar contrase&ntilde;a</button>
            </div>

            <button type="submit" class="btn-login" id="btnLogin">
              <span class="btn-label">Entrar al sistema</span>
              <span class="btn-loader" aria-hidden="true"></span>
            </button>
          </form>

          <footer class="auth-card-footer">
            <small>Plataforma institucional - <span id="yearNow"></span></small>
          </footer>
        </article>
      </section>
    </section>
  </main>

  <div id="modalRecuperacion" class="recovery-modal" aria-hidden="true" role="dialog" aria-modal="true" aria-labelledby="modalRecuperacionTitulo">
    <div class="recovery-modal-dialog">
      <section class="recovery-modal-card">
        <header class="recovery-header">
          <h3 id="modalRecuperacionTitulo">Recuperar contrase&ntilde;a</h3>
          <button type="button" class="recovery-close" id="btnCerrarRecuperacion" aria-label="Cerrar recuperaci&oacute;n">
            <i class="fas fa-times"></i>
          </button>
        </header>
        <p class="recovery-intro">Ingresa tu usuario y c&eacute;dula para recibir una clave temporal en el correo del empleado asociado.</p>

        <form id="frmRecuperacion" novalidate>
          <div class="field-group">
            <label for="usuarioRecuperacion">Usuario</label>
            <div class="field-control">
              <span class="field-icon"><i class="fas fa-user"></i></span>
              <input type="text" id="usuarioRecuperacion" name="usuario_recuperacion" autocomplete="username" placeholder="Usuario del sistema" required>
            </div>
          </div>

          <div class="field-group">
            <label for="cedulaRecuperacion">C&eacute;dula</label>
            <div class="field-control">
              <span class="field-icon"><i class="fas fa-id-card"></i></span>
              <input type="text" id="cedulaRecuperacion" name="cedula_recuperacion" inputmode="numeric" placeholder="Solo n&uacute;meros" required>
            </div>
          </div>

          <div class="recovery-actions">
            <button type="button" class="btn-recovery btn-recovery-muted" id="btnCancelarRecuperacion">
              Cerrar
            </button>
            <button type="submit" class="btn-recovery" id="btnRecuperarClave">
              <span class="btn-label">Enviar clave temporal</span>
              <span class="btn-loader" aria-hidden="true"></span>
            </button>
          </div>
        </form>
      </section>
    </div>
  </div>

  <div id="modalPrimerUsuario" class="recovery-modal bootstrap-modal" aria-hidden="true" role="dialog" aria-modal="true" aria-labelledby="modalPrimerUsuarioTitulo">
    <div class="recovery-modal-dialog bootstrap-modal-dialog">
      <section class="recovery-modal-card bootstrap-modal-card">
        <header class="recovery-header">
          <h3 id="modalPrimerUsuarioTitulo">Configuracion inicial del sistema</h3>
        </header>
        <p class="recovery-intro">No existen usuarios registrados. Cree el primer usuario administrador con acceso total para comenzar a usar el sistema.</p>

        <form id="frmPrimerUsuario" novalidate>
          <div class="bootstrap-grid">
            <div class="field-group">
              <label for="primerUsuario">Usuario</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-user"></i></span>
                <input type="text" id="primerUsuario" name="primer_usuario" placeholder="Usuario administrador" autocomplete="username" required>
              </div>
            </div>

            <div class="field-group">
              <label for="primerCedula">Cedula</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-id-card"></i></span>
                <input type="text" id="primerCedula" name="primer_cedula" placeholder="Solo numeros" inputmode="numeric" required>
              </div>
            </div>

            <div class="field-group">
              <label for="primerNombre">Nombre</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-user-tag"></i></span>
                <input type="text" id="primerNombre" name="primer_nombre" placeholder="Nombre" required>
              </div>
            </div>

            <div class="field-group">
              <label for="primerApellido">Apellido</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-user-tag"></i></span>
                <input type="text" id="primerApellido" name="primer_apellido" placeholder="Apellido" required>
              </div>
            </div>

            <div class="field-group">
              <label for="primerCorreo">Correo</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-envelope"></i></span>
                <input type="email" id="primerCorreo" name="primer_correo" placeholder="correo@dominio.com">
              </div>
            </div>

            <div class="field-group">
              <label for="primerDependencia">Dependencia</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-building"></i></span>
                <input type="text" id="primerDependencia" name="primer_dependencia" placeholder="Direccion General" value="Direccion General">
              </div>
            </div>

            <div class="field-group">
              <label for="primerClave">Contrasena</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-lock"></i></span>
                <input type="password" id="primerClave" name="primer_clave" placeholder="Minimo 8 caracteres" required>
              </div>
            </div>

            <div class="field-group">
              <label for="primerClaveConfirmar">Confirmar contrasena</label>
              <div class="field-control">
                <span class="field-icon"><i class="fas fa-lock"></i></span>
                <input type="password" id="primerClaveConfirmar" name="primer_clave_confirmar" placeholder="Repita la contrasena" required>
              </div>
            </div>
          </div>

          <div class="recovery-actions">
            <button type="submit" class="btn-recovery btn-recovery-primary-full" id="btnCrearPrimerUsuario">
              <span class="btn-label">Crear primer administrador</span>
              <span class="btn-loader" aria-hidden="true"></span>
            </button>
          </div>
        </form>
      </section>
    </div>
  </div>

  <script src="../assets/plugins/jquery/jquery.min.js"></script>
  <script src="../assets/plugins/bootstrap/js/bootstrap.bundle.min.js"></script>
  <script src="scripts/login.js"></script>
</body>
</html>

