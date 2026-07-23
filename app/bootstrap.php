<?php
declare(strict_types=1);

session_start([
    'cookie_httponly' => true,
    'cookie_samesite' => 'Lax',
    'cookie_secure' => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
]);

$configFile = dirname(__DIR__) . '/config/config.php';
if (!is_file($configFile)) {
    http_response_code(503);
    exit('Configuración pendiente. Copia config/config.example.php como config/config.php y completa los datos de MySQL.');
}
$config = require $configFile;

function db(): PDO {
    static $pdo;
    global $config;
    if (!$pdo) {
        $d = $config['db'];
        $dsn = "mysql:host={$d['host']};port={$d['port']};dbname={$d['name']};charset={$d['charset']}";
        $pdo = new PDO($dsn, $d['user'], $d['pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }
    return $pdo;
}

function e(?string $value): string { return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8'); }
function url(string $path = ''): string { global $config; return rtrim($config['app_url'], '/') . '/' . ltrim($path, '/'); }
function redirect(string $path): never { header('Location: ' . url($path)); exit; }
function csrf(): string { if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(32)); return $_SESSION['csrf']; }
function verify_csrf(): void { if (!hash_equals($_SESSION['csrf'] ?? '', $_POST['_token'] ?? '')) { http_response_code(419); exit('La sesión expiró. Recarga la página.'); } }
function flash(string $type, string $message): void { $_SESSION['flash'] = compact('type', 'message'); }
function pull_flash(): ?array { $f = $_SESSION['flash'] ?? null; unset($_SESSION['flash']); return $f; }
function admin(): bool { return !empty($_SESSION['admin_id']); }
function require_admin(): void { if (!admin()) redirect('admin/login'); }
function clp(int|float $value): string { return '$' . number_format((float)$value, 0, ',', '.'); }
function nights(string $from, string $to): int { return max(0, (int)(new DateTime($from))->diff(new DateTime($to))->days); }

function setting(string $key, string $fallback = ''): string {
    try { $q = db()->prepare('SELECT value FROM settings WHERE setting_key = ?'); $q->execute([$key]); return (string)($q->fetchColumn() ?: $fallback); }
    catch (Throwable) { return $fallback; }
}

function ensure_admin(): void {
    global $config;
    try {
        if ((int)db()->query('SELECT COUNT(*) FROM users')->fetchColumn() === 0) {
            $q = db()->prepare('INSERT INTO users (name,email,password_hash,role) VALUES (?,?,?,?)');
            $q->execute(['Administrador', $config['admin_email'], password_hash($config['admin_password'], PASSWORD_DEFAULT), 'admin']);
        }
    } catch (Throwable) {}
}
ensure_admin();
