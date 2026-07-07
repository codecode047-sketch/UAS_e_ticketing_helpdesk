<?php

$host = "localhost";
$user = "root";
$password = "";
$database = "e_ticketing_helpdesk";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Database connection failed"
    ]));
}
?>