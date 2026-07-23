<?php
declare(strict_types=1);
require __DIR__ . '/app/bootstrap.php';

$ok = database_ready();
$message = $ok ? 'La base de datos ya está instalada.' : '';

if (!$ok && ($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
    try {
        verify_csrf();
        $sql = file_get_contents(__DIR__ . '/database/schema.sql');
        if ($sql === false) throw new RuntimeException('No se encontró database/schema.sql.');
        foreach (preg_split('/;\s*(?:\r?\n|$)/', $sql) as $statement) {
            $statement = trim($statement);
            if ($statement !== '') db()->exec($statement);
        }
        ensure_admin();
        $ok = database_ready();
        $message = $ok ? 'Instalación completada correctamente.' : 'No fue posible comprobar las tablas.';
    } catch (Throwable $e) {
        $message = 'No se pudo instalar: ' . $e->getMessage();
    }
}
?><!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Instalar Hotel Rarinco</title><style>body{margin:0;background:#f2f4f7;font-family:Arial;color:#172033}.box{max-width:620px;margin:8vh auto;background:#fff;padding:36px;box-shadow:0 20px 60px #10204018;border-top:5px solid #0753b8}h1{font-size:30px;margin-top:0}p{line-height:1.6}.status{padding:14px;background:#eef5ff;border-left:4px solid #0753b8;margin:20px 0;overflow-wrap:anywhere}.error{background:#fff1f0;border-color:#b42318}button,a{display:inline-block;border:0;background:#0753b8;color:#fff;padding:14px 20px;text-decoration:none;font-weight:700;cursor:pointer}</style></head><body><main class="box"><h1>Instalación Hotel Rarinco</h1><p>Este asistente conectará el proyecto con MySQL, creará las tablas y cargará las habitaciones iniciales.</p><?php if($message):?><div class="status <?=$ok?'':'error'?>"><?=htmlspecialchars($message,ENT_QUOTES,'UTF-8')?></div><?php endif?><?php if($ok):?><a href="<?=htmlspecialchars(url(),ENT_QUOTES,'UTF-8')?>">Abrir sitio</a><?php else:?><form method="post"><input type="hidden" name="_token" value="<?=htmlspecialchars(csrf(),ENT_QUOTES,'UTF-8')?>"><button type="submit">Instalar base de datos</button></form><?php endif?></main></body></html>
