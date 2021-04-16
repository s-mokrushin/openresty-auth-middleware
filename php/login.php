<?php

if (isset($_POST['username'])) {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    $domain = $_POST['domain'] ?? '';
    $port = $_POST['port'] ?? '';

    // allow access by username/password (http://localhost:8090)
    if ($username == 'test' && $password == 'test' && $port == '80') {
        http_response_code(200);
        exit;
    }
}

http_response_code(403);
