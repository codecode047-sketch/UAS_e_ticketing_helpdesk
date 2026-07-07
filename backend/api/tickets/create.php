<?php

header("Content-Type: application/json");

$title=$_POST['title']??'';

$description=$_POST['description']??'';

echo json_encode([

"success"=>true,

"message"=>"Ticket berhasil dibuat",

"data"=>[

"id"=>16,

"title"=>$title,

"description"=>$description

]

]);