<?php

header("Content-Type: application/json");

$comment=$_POST['comment']??'';

echo json_encode([

"success"=>true,

"message"=>"Komentar berhasil ditambahkan",

"comment"=>$comment

]);