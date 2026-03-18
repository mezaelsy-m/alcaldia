//Función para generar Reporte PDF
function generarReportePDF() {
	// Obtener los datos de la tabla
	var table = $('#tbllistado').DataTable();
	var data = table.data().toArray();
	
	// Crear el contenido del PDF
	var content = `
		<html>
		<head>
			<title>Reporte de Bitácora</title>
			<style>
				body { font-family: Arial, sans-serif; margin: 20px; }
				h1 { color: #333; text-align: center; }
				table { width: 100%; border-collapse: collapse; margin-top: 20px; }
				th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
				th { background-color: #f2f2f2; font-weight: bold; }
				.header { text-align: center; margin-bottom: 30px; }
				.date { text-align: right; margin-bottom: 20px; }
			</style>
		</head>
		<body>
			<div class="header">
				<h1>Sala Situacional Libertador</h1>
				<h2>Reporte de Bitácora del Sistema</h2>
			</div>
			<div class="date">
				<p>Fecha: ${new Date().toLocaleDateString('es-VE')}</p>
			</div>
			<table>
				<thead>
					<tr>
						<th>ID</th>
						<th>Usuario</th>
						<th>Resumen</th>
						<th>Detalle</th>
						<th>Fecha y Hora</th>
						<th>Dirección IP</th>
					</tr>
				</thead>
				<tbody>
	`;
	
	// Agregar los datos de la tabla
	data.forEach(function(row) {
		content += `
					<tr>
						<td>${row[0] || ''}</td>
						<td>${row[1] || ''}</td>
						<td>${row[2] || ''}</td>
						<td>${row[3] || ''}</td>
						<td>${row[4] || ''}</td>
						<td>${row[5] || ''}</td>
					</tr>
		`;
	});
	
	content += `
				</tbody>
			</table>
			<div style="margin-top: 30px; text-align: center;">
				<p>Total de Registros: ${data.length}</p>
			</div>
		</body>
		</html>
	`;
	
	// Crear una ventana temporal para imprimir
	var printWindow = window.open('', '_blank');
	printWindow.document.write(content);
	printWindow.document.close();
	
	// Esperar a que cargue y luego mostrar diálogo de impresión
	printWindow.onload = function() {
		printWindow.print();
		// Opcional: cerrar la ventana después de imprimir
		setTimeout(function() {
			printWindow.close();
		}, 1000);
	};
}

function listar() {
	tabla = $('#tbllistado').DataTable({
	  "aProcessing": true,
	  "aServerSide": true,
	  dom: 'lfrtip',
	  "ajax": {
		url: '../ajax/bitacora.php?op=listar',
		type: "get",
		dataType: "json",
		error: function (e) {
		  console.log(e.responseText);
		}
	  },
	  "bDestroy": true,
	  "iDisplayLength": 25,
	  "order": [
		[0, "desc"]
	  ],
	  "language": {
		"decimal": "",
		"emptyTable": "No hay datos disponibles en la tabla",
		"info": "Mostrando _START_ a _END_ de _TOTAL_ registros",
		"infoEmpty": "Mostrando 0 a 0 de 0 registros",
		"infoFiltered": "(filtrado de _MAX_ registros totales)",
		"infoPostFix": "",
		"thousands": ",",
		"lengthMenu": "Mostrar _MENU_ registros",
		"loadingRecords": "Cargando...",
		"processing": "Procesando...",
		"search": "Buscar:",
		"zeroRecords": "No se encontraron resultados",
		"paginate": {
		  "first": "Primero",
		  "last": "Último",
		  "next": "Siguiente",
		  "previous": "Anterior"
		},
		"aria": {
		  "sortAscending": ": Activar para ordenar la columna de manera ascendente",
		  "sortDescending": ": Activar para ordenar la columna de manera descendente"
		}
	  }
	});
}

//Función que se ejecuta al inicio
function init(){
	listar();
}

init();
