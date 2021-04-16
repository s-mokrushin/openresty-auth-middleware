<?php

if (isset($_GET['ip'])) {
    $ip = $_GET['ip'] ?? '';
    $domain = $_GET['domain'] ?? '';

    // emulate access by IP (http://localhost:8091)
    if ($ip && $_GET['port'] == '81') {
        http_response_code(200);
        exit;
    }
}

http_response_code(403);
